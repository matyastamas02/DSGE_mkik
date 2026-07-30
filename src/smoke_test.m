% smoke_test.m — gyors ellenőrzés push előtt ("ne törjön a main")
% =====================================================================
% A kulcskimenetek meglétét ÉS a fő tartalmi állításokat ellenőrzi.
% Futtatás:  matlab -batch "cd('src'); smoke_test"
% Hibánál error-ral áll le (CI-ben / run_all-ban is használható).

function smoke_test
repo = fileparts(pwd);
ok = 0; hiba = 0;

% --- 1. Panel megvan és annyi sora van, amennyinek lennie kell --------
f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');
[ok, hiba] = ell(exist(f, 'file') == 2, 'opten_panel.csv letezik', ok, hiba);
if exist(f, 'file') == 2
    o = detectImportOptions(f);
    o.SelectedVariableNames = {'ev'};
    n = height(readtable(f, o));
    [ok, hiba] = ell(n == 150982, ...
        sprintf('panel sorszam = 150982 (tenyleges: %d)', n), ok, hiba);
end

% --- 2. Modell-kimenetek ------------------------------------------------
irf_f = fullfile(repo, 'output', 'tables', 'irf_v01.csv');
[ok, hiba] = ell(exist(irf_f, 'file') == 2, 'irf_v01.csv letezik', ok, hiba);
if exist(irf_f, 'file') == 2
    irf = readtable(irf_f);
    % KKV-aszimmetria: banki sokkra a KKV-beruhazas valasza nagyobb
    [ok, hiba] = ell(abs(irf.i_S_e_bank(1)) > abs(irf.i_L_e_bank(1)), ...
        'aszimmetria: |i_S| > |i_L| banki sokkra', ok, hiba);
    [ok, hiba] = ell(abs(irf.efp_S_e_bank(1)) > abs(irf.efp_L_e_bank(1)), ...
        'aszimmetria: |efp_S| > |efp_L|', ok, hiba);
end

ht_f = fullfile(repo, 'output', 'tables', 'szcenario_v03_hosszutav.csv');
[ok, hiba] = ell(exist(ht_f, 'file') == 2, 'szcenario_v03_hosszutav letezik', ok, hiba);
if exist(ht_f, 'file') == 2
    ht = readtable(ht_f);
    ya = ht.y(string(ht.szcenario) == "alap");
    [ok, hiba] = ell(ya > 0.002 && ya < 0.008, ...
        sprintf('alap hosszu tavu GDP plauzibilis (%.3f%%)', 100*ya), ok, hiba);
    [ok, hiba] = ell(all(ht.y_S > ht.y_L), ...
        'KKV-tobblet minden szcenarioban (y_S > y_L)', ok, hiba);
    yo = ht.y(string(ht.szcenario) == "optimista");
    yp = ht.y(string(ht.szcenario) == "pesszimista");
    [ok, hiba] = ell(yo > ya && ya > yp, ...
        'szcenario-sorrend: opt > alap > pessz', ok, hiba);
end

% --- 3. Leképezés és extenzív margó ------------------------------------
lek_f = fullfile(repo, 'output', 'tables', 't09_szegmens_lekepezes.csv');
[ok, hiba] = ell(exist(lek_f, 'file') == 2, 't09 lekepezes letezik', ok, hiba);
if exist(lek_f, 'file') == 2
    lek = readtable(lek_f);
    [ok, hiba] = ell(height(lek) == 15, 't09: 3 szcenario x 5 szegmens', ok, hiba);
    [ok, hiba] = ell(all(lek.bp_hosszutav < 0), ...
        't09: minden szegmensben kamatCSOKKENES', ok, hiba);
end

% --- 4. JV-vonal (FŐ vonal): szegmentált euró-szcenárió (v05) -----------
jv_ht = fullfile(repo, 'output', 'tables', 't21_jv_v05_hosszutav.csv');
[ok, hiba] = ell(exist(jv_ht, 'file') == 2, 't21 jv_v05 hosszutav letezik', ok, hiba);
if exist(jv_ht, 'file') == 2
    j = readtable(jv_ht);
    ya = j.y(string(j.szcenario) == "alap");
    [ok, hiba] = ell(ya > 0.002 && ya < 0.03, ...
        sprintf('v05 alap GDP plauzibilis (%.3f%%)', 100*ya), ok, hiba);
    % a javitott unio-zaras utan a realarfolyamnak plauzibilisnek kell lennie
    % (a hibas nu_uni=0.01 mellett +34.7%% volt!)
    [ok, hiba] = ell(abs(j.rer(string(j.szcenario) == "alap")) < 0.15, ...
        sprintf('v05 realarfolyam plauzibilis (%.1f%%) - unio-zaras OK', ...
        100*j.rer(string(j.szcenario) == "alap")), ok, hiba);
    [ok, hiba] = ell(all(j.i_S > j.i_L), ...
        'v05: meret-aszimmetria minden szcenarioban (i_S > i_L)', ok, hiba);
end

jv_lek = fullfile(repo, 'output', 'tables', 't22_szegmens_lekepezes_v05.csv');
[ok, hiba] = ell(exist(jv_lek, 'file') == 2, 't22 v05-lekepezes letezik', ok, hiba);
if exist(jv_lek, 'file') == 2
    L = readtable(jv_lek);
    [ok, hiba] = ell(height(L) == 15, 't22: 3 szcenario x 5 szegmens', ok, hiba);
    % a KKV-felar csokkenese legyen nagyobb, mint a nagyvallalatie
    [ok, hiba] = ell(all(L.modell_kkv_bp_csucs < L.modell_nagyvallalat_bp_csucs), ...
        't22: a KKV hitelfelar-nyeresege > nagyvallalatie (modell-eredmeny)', ...
        ok, hiba);
end

% --- Összegzés ----------------------------------------------------------
fprintf('\nFUSTTESZT: %d rendben, %d hiba\n', ok, hiba);
if hiba > 0
    error('smoke_test: %d ellenorzes megbukott — NE pushold!', hiba);
end
end

function [ok, hiba] = ell(feltetel, nev, ok, hiba)
    if feltetel
        fprintf('  [OK]    %s\n', nev);
        ok = ok + 1;
    else
        fprintf('  [HIBA]  %s\n', nev);
        hiba = hiba + 1;
    end
end
