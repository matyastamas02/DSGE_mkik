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

% --- v06: a termelesi oldalon is szegmentalt modell -----------------------
v6_ht = fullfile(repo, 'output', 'tables', 't34_jv_v06_hosszutav.csv');
[ok, hiba] = ell(exist(v6_ht, 'file') == 2, 't34 jv_v06 hosszutav letezik', ...
    ok, hiba);
if exist(v6_ht, 'file') == 2
    V = readtable(v6_ht);
    va = V(string(V.szcenario) == "alap", :);
    [ok, hiba] = ell(va.y > 0.002 && va.y < 0.03, ...
        sprintf('v06 alap GDP plauzibilis (%.3f%%)', 100*va.y), ok, hiba);
    % REGRESSZIOS GUARD 1 — a v06 LENYEGE: a szegmens-premium-differencia
    % a hosszu tavon NEM nulla. A v05-ben pontosan 0 volt (kozos rk miatt),
    % es ha valaki visszaallitja a kozos rk-t, ennek el kell buknia.
    [ok, hiba] = ell(all(abs(V.efp_S - V.efp_L) > 1e-7), ...
        sprintf(['v06: efp_S =/= efp_L a hosszu tavon (%.2f bp) - a ' ...
        'kozos-rk patologia megoldva'], 10000*(va.efp_S - va.efp_L)), ok, hiba);
    % REGRESSZIOS GUARD 2 — rk_S es rk_L genuinen eltér (ez hajtja az 1-est)
    [ok, hiba] = ell(all(abs(V.rk_S - V.rk_L) > 1e-6), ...
        sprintf('v06: rk_S =/= rk_L (%.2f pp) - szegmens-specifikus tokehozam', ...
        100*(va.rk_S - va.rk_L)), ok, hiba);
    % REGRESSZIOS GUARD 3 — az atalakitas NEM mozdithatja el az aggregalt
    % eredmenyt: a v06 GDP-nek a v05-ossel egyeznie kell 0.05 pp-on belul.
    if exist(jv_ht, 'file') == 2
        y5 = j.y(string(j.szcenario) == "alap");
        [ok, hiba] = ell(abs(va.y - y5) < 0.0005, ...
            sprintf(['v06 aggregalt GDP = v05 (%.3f%% vs %.3f%%) - a ' ...
            'termelesi atalakitas nem mozditotta el'], 100*va.y, 100*y5), ...
            ok, hiba);
    end
end

% --- v06 dekompozicio: a szegmens-eredmenyt a chi-valasztas hajtja --------
v6_sens = fullfile(repo, 'output', 'tables', 't35_sens_chi_psi_v06.csv');
[ok, hiba] = ell(exist(v6_sens, 'file') == 2, 't35 v06 chi/psi dekompozicio letezik', ...
    ok, hiba);
if exist(v6_sens, 'file') == 2
    D = readtable(v6_sens);
    [ok, hiba] = ell(all(D.konvergalt == 1), ...
        sprintf('t35: mind a %d eset konvergalt', height(D)), ok, hiba);
    % A psi_i a STEADY STATE-et nem erintheti (q=0 ott) — ha ez elbukik,
    % valaki elrontotta a beruhazasi Euler-egyenletet.
    psi_sorok = D(contains(string(D.eset), 'psi '), :);
    alap_ss = D.ss_KKV_elony_pp(1);
    [ok, hiba] = ell(all(abs(psi_sorok.ss_KKV_elony_pp - alap_ss) < 1e-9), ...
        't35: a psi_i a steady state-et nem erinti (q=0) - Euler OK', ok, hiba);
    % A chi FORDITASA fordit a szegmens-sorrenden — ez a fo dekompozicios
    % allitas: a nagyvallalati elony a chi-valasztas kovetkezmenye.
    ford = D(contains(string(D.eset), 'FORDITVA'), :);
    [ok, hiba] = ell(~isempty(ford) && ford.ss_KKV_elony_pp(1) > 0, ...
        't35: chi forditasa MEGFORDITJA a szegmens-sorrendet', ok, hiba);
end

% --- v07_access (Samu, 2026-08-10; atveve 2026-08-12) --------------------
v7_ht = fullfile(repo, 'output', 'tables', 't29_v07_access_hosszutav.csv');
[ok, hiba] = ell(exist(v7_ht, 'file') == 2, 't29 v07_access hosszutav letezik', ...
    ok, hiba);
if exist(v7_ht, 'file') == 2
    W = readtable(v7_ht);
    wa = W(string(W.szcenario) == "alap", :);
    [ok, hiba] = ell(wa.y > 0.002 && wa.y < 0.03, ...
        sprintf('v07 alap GDP plauzibilis (%.3f%%)', 100*wa.y), ok, hiba);
    % REPLIKACIOS GUARD: a szerzo altal kozolt alap-szamok (TSCEN=3,
    % ACCSCALE=100). Ha valaki hozzanyul a modellhez, ennek el kell buknia.
    [ok, hiba] = ell(abs(100*wa.y_D - 0.870) < 0.01 && ...
        abs(100*wa.y_L - 0.772) < 0.01, ...
        sprintf(['v07 replikacio: y_D=%.3f%% (kozolt 0.870), ' ...
        'y_L=%.3f%% (kozolt 0.772)'], 100*wa.y_D, 100*wa.y_L), ok, hiba);
end

v7_kuszob = fullfile(repo, 'output', 'tables', 't33_v07_access_threshold_summary.csv');
[ok, hiba] = ell(exist(v7_kuszob, 'file') == 2, 't33 v07 kuszob-osszefoglalo letezik', ...
    ok, hiba);
if exist(v7_kuszob, 'file') == 2
    Th = readtable(v7_kuszob);
    % A projekt fo szama: a sulyozott KKV-blokk ACCSCALE~101-nel elozi meg
    % az L-t. FIGYELEM: a baseline 100 -- azaz a kvalitativ valasz PONTOSAN
    % a valasztott kalibracios pontban fordul at (borotvael). Lasd
    % docs/2026-08-12_access_horgonyzas_eredmeny.md.
    v = Th{:, end};
    [ok, hiba] = ell(any(abs(v - 101.0) < 1.0), ...
        't33 replikacio: a KKV>=L kuszob ~101 (a baseline 100 -- borotvael!)', ...
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
