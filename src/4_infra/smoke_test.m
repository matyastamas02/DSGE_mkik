% smoke_test.m — gyors ellenőrzés push előtt ("ne törjön a main")
% =====================================================================
% A kulcskimenetek meglétét ÉS a fő tartalmi állításokat ellenőrzi.
% Futtatás:  matlab -batch "cd('<repo>/src/4_infra'); smoke_test"
% Hibánál error-ral áll le (CI-ben / run_all-ban is használható).

function smoke_test
repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
ok = 0; hiba = 0;

% Az ellenorzesek eredmenyet CSV-be is kiirjuk, hogy az allapotlap
% (src/13_allapotlap.py) MATLAB nelkul is generalhato legyen. A fusttest
% marad a FORRAS: az allapotlap nem allithat semmit, amire itt nincs or.
global SMOKE_LOG
SMOKE_LOG = struct('nev', {}, 'rendben', {});

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

% --- CALIB: EAGLE-kalibralt vs JV-becsult parameterkeszlet ---------------
v7_cal = fullfile(repo, 'output', 'tables', 't39b_calib_kuszob_osszegzes.csv');
[ok, hiba] = ell(exist(v7_cal, 'file') == 2, 't39b calib-kuszob osszegzes letezik', ...
    ok, hiba);
if exist(v7_cal, 'file') == 2
    C = readtable(v7_cal);
    e = C.kuszob_KKV_L(strcmp(string(C.kalibracio), "EAGLE_kalibralt"));
    j = C.kuszob_KKV_L(strcmp(string(C.kalibracio), "JV_becsult"));
    % REGRESSZIOS GUARD: az EAGLE-oszlopnak reprodukalnia kell a szerzo
    % kozolt kuszobet (101.0) -- ha nem, a CALIB-kapcsolo elrontotta az alapot.
    [ok, hiba] = ell(abs(e - 101.0) < 1.0, ...
        sprintf('t39b: a CALIB=1 ag reprodukalja a kozolt kuszobet (%.1f)', e), ...
        ok, hiba);
    % A JV-keszlettel a kuszobnek 100 ALATT kell lennie (a borotvael feloldodik).
    [ok, hiba] = ell(j < 100, ...
        sprintf(['t39b: JV-keszlettel a kuszob 100 ALATT (%.1f) - a ' ...
        'szektoralis sorrend megfordul'], j), ok, hiba);
end

% --- 2. LEPCSO: haromtipusos JV-mag, kozos arszint ------------------------
t3 = fullfile(repo, 'output', 'tables', 't40_jv_3type_stressz.csv');
[ok, hiba] = ell(exist(t3, 'file') == 2, 't40 jv_3type stresszteszt letezik', ...
    ok, hiba);
if exist(t3, 'file') == 2
    S3 = readtable(t3);
    % Ez csak a perfect-foresight solver statisztikaja; nem BK-teszt.
    [ok, hiba] = ell(all(S3.konvergalt == 1), ...
        sprintf('t40: mind a %d kombinacio PF-solverrel megoldodott', ...
        height(S3)), ok, hiba);
    % Plauzibilitas: a zaras ne engedje elszaladni a realarfolyamot/NFA-t.
    [ok, hiba] = ell(all(abs(S3.rer_pct) < 15) && all(abs(S3.bstar_pct) < 5), ...
        't40: realarfolyam es NFA plauzibilis savban', ok, hiba);
    % REGRESSZIOS GUARD a dokumentalt KORLATRA: a tipus-kibocsatas
    % mechanikusan (1-phi)*y_d + phi*y_x. Ha valaki tipusonkenti keresletet
    % vezet be (3. lepcso), ennek EL KELL BUKNIA -- akkor a guardot frissiteni
    % kell, mert az mar a 3. lepcso, nem hiba.
    a1 = S3(S3.SCENARIO == 1 & S3.TSCEN == 3 & S3.NOVERT == 0, :);
    if height(a1) == 1
        [ok, hiba] = ell(a1.y_E_pct > a1.y_L_pct && a1.y_L_pct > a1.y_D_pct, ...
            ['t40: a tipus-kibocsatas sorrendje a phi_j sorrendje ' ...
            '(dokumentalt KORLAT, nem eredmeny)'], ok, hiba);
    end
end

% --- 3. LEPCSO: tipusonkenti ar es kereslet -------------------------------
t41 = fullfile(repo, 'output', 'tables', 't41_jv_3type_arak_stressz.csv');
[ok, hiba] = ell(exist(t41, 'file') == 2, 't41 jv_3type_arak stressz letezik', ...
    ok, hiba);
if exist(t41, 'file') == 2
    S4 = readtable(t41);
    [ok, hiba] = ell(all(S4.konvergalt == 1), ...
        sprintf(['t41: mind a %d kombinacio PF-solverrel megoldodott; ' ...
        'ez nem BK-teszt'], height(S4)), ok, hiba);
    % A v01-es EGYSEGGYOK-CSAPDA elkerulese: sum(wd_j*p_j) == 0.
    [ok, hiba] = ell(max(abs(S4.normalizacio)) < 1e-10, ...
        sprintf('t41: relativar-normalizacio tart (max %.1e) - v01 egyseggyok elkerulve', ...
        max(abs(S4.normalizacio))), ok, hiba);
    [ok, hiba] = ell(all(abs(S4.rer_pct) < 15) && all(abs(S4.bstar_pct) < 5), ...
        't41: realarfolyam es NFA plauzibilis savban', ok, hiba);
end

t42 = fullfile(repo, 'output', 'tables', 't42_jv_3type_epsces_sens.csv');
[ok, hiba] = ell(exist(t42, 'file') == 2, 't42 eps_ces erzekenyseg letezik', ok, hiba);
if exist(t42, 'file') == 2
    Ec = readtable(t42);
    Ec = Ec(Ec.konvergalt == 1, :);
    % AZ AGGREGATUM ROBUSZTUS: a GDP-hatas ne fuggjon az eps_ces-tol.
    [ok, hiba] = ell(max(Ec.GDP_pct) - min(Ec.GDP_pct) < 0.05, ...
        sprintf('t42: az aggregalt GDP eps_ces-re ERZEKETLEN (sav %.3f pp)', ...
        max(Ec.GDP_pct) - min(Ec.GDP_pct)), ok, hiba);
    % A SZEGMENS TOREKENY: a dokumentalt elojelvaltas alljon fenn. Ha valaki
    % horgonyozza az eps_ces-t es szukiti a savot, ezt frissiteni kell.
    [ok, hiba] = ell(any(Ec.y_E_pct > 0) && any(Ec.y_E_pct < 0), ...
        't42: az y_E ELOJELE eps_ces-fuggo (dokumentalt KORLAT, kuszobforma kell)', ...
        ok, hiba);
end

% --- FUGGETLEN ELLENORZES: szimmetria, aggregacio, nulla-sokk, nesting ----
% Ezek NEM BK-tesztek: olyan azonossagokat ellenoriznek, amiknek a
% szerkezetbol kovetkezniuk kell. Egy elgepelt index vagy suly mellett is
% lehet 18/18 BK-konvergencia -- ezek fogjak el az olyan hibat.
t43 = fullfile(repo, 'output', 'tables', 't43_ellenorzes_3type.csv');
[ok, hiba] = ell(exist(t43, 'file') == 2, 't43 fuggetlen ellenorzes letezik', ok, hiba);
if exist(t43, 'file') == 2
    V3 = readtable(t43);
    [ok, hiba] = ell(all(V3.rendben == 1), ...
        sprintf('t43: mind a %d fuggetlen ellenorzes atment', height(V3)), ok, hiba);
    szim = V3(contains(string(V3.teszt), 'szimmetria'), :);
    [ok, hiba] = ell(~isempty(szim) && max(szim.elteres) < 1e-8, ...
        sprintf(['t43 SZIMMETRIA: azonos parameterek -> azonos tipusok ' ...
        '(max %.1e)'], max(szim.elteres)), ok, hiba);
    nulla = V3(contains(string(V3.teszt), 'nulla-sokk'), :);
    [ok, hiba] = ell(~isempty(nulla) && max(nulla.elteres) < 1e-9, ...
        't43 NULLA-SOKK: sokk nelkul minden valtozo 0', ok, hiba);
end

% --- 4. LEPCSO: access-margo a JV-magon (v09) -----------------------------
t44 = fullfile(repo, 'output', 'tables', 't44_jv_access_stressz.csv');
[ok, hiba] = ell(exist(t44, 'file') == 2, 't44 jv_access stressz letezik', ok, hiba);
if exist(t44, 'file') == 2
    A9 = readtable(t44);
    require_columns_(A9, {'solver_ok','bk_check_ok','bk_ok','ervenyes', ...
        'n_forward','n_unstable','bk_qz_criterium'}, 't44');
    [ok, hiba] = ell(height(A9) == 18 && all(A9.solver_ok == 1), ...
        sprintf('t44: mind a %d perfect-foresight futas megoldodott', height(A9)), ok, hiba);
    [ok, hiba] = ell(all(A9.bk_check_ok == 1 & A9.bk_ok == 1), ...
        sprintf('t44: mind a %d terminalis lokalis BK-ellenorzes atment', ...
        height(A9)), ok, hiba);
    A9v = A9(A9.ervenyes == 1, :);
    [ok, hiba] = ell(all(abs(A9v.rer_pct) < 15) && all(abs(A9v.bstar_pct) < 5), ...
        't44: realarfolyam es NFA plauzibilis savban', ok, hiba);
end
t45b = fullfile(repo, 'output', 'tables', 't45b_jv_access_kuszob_osszegzes.csv');
[ok, hiba] = ell(exist(t45b, 'file') == 2, 't45b jv_access kuszob letezik', ok, hiba);
if exist(t45b, 'file') == 2
    Kb = readtable(t45b);
    require_columns_(Kb, {'bk_ok_D_L','bk_ok_KKV_L','bk_ok_E_L'}, 't45b');
    % NESTING GUARD: ACCSCALE=0 mellett a v09-nek PONTOSAN a v08-at kell adnia.
    [ok, hiba] = ell(Kb.nesting_elteres(1) < 1e-12, ...
        sprintf('t45b NESTING: ACCSCALE=0 == v08 (elteres %.1e)', ...
        Kb.nesting_elteres(1)), ok, hiba);
    % Letezik VEGES kuszob a JV-magon.
    [ok, hiba] = ell(isfinite(Kb.kuszob_KKV_L(1)) && Kb.kuszob_KKV_L(1) > 0, ...
        sprintf('t45b: veges access-kuszob a JV-magon (ACCSCALE=%.1f)', ...
        Kb.kuszob_KKV_L(1)), ok, hiba);
    [ok, hiba] = ell(all(Kb.bk_ok_D_L == 1 & Kb.bk_ok_KKV_L == 1 & ...
        Kb.bk_ok_E_L == 1), ...
        't45b: minden kozolt JV access-kuszob terminalisan BK-stabil', ok, hiba);
end

% --- OPTEN-KALIBRACIO: a 14 parameter ujraszamolasa a panelbol ------------
% Ezek REPLIKACIOS ORok: ha valaki ujrafuttatja az s15-ot es mas jon ki,
% az vagy a panel valtozasa, vagy hiba -- mindketto tudni valo.
t46 = fullfile(repo, 'output', 'tables', 't46_opten_kalibracio.csv');
[ok, hiba] = ell(exist(t46, 'file') == 2, 't46 opten-kalibracio letezik', ok, hiba);
if exist(t46, 'file') == 2
    C = readtable(t46);
    par = string(C.parameter);
    ert = @(p) C.uj_ALAP(par == p);
    [ok, hiba] = ell(height(C) == 14, ...
        sprintf('t46: mind a 14 parameter megvan (%d)', height(C)), ok, hiba);
    % A sulyoknak 1-re kell osszegzodniuk (definicio szerint).
    [ok, hiba] = ell(abs(ert("om_E")+ert("om_D")+ert("om_L") - 1) < 1e-6 && ...
        abs(ert("shl_E")+ert("shl_D")+ert("shl_L") - 1) < 1e-6, ...
        't46: az om_j es az shl_j sulyok 1-re osszegzodnek', ok, hiba);
    % AMIT AZ ADAT MEGERSIT: a phi_L es a delta atvett erteke helyes volt.
    [ok, hiba] = ell(abs(ert("phi_L") - 0.365) < 0.005, ...
        sprintf('t46: phi_L = %.4f megerositi az atvett 0.365-ot', ...
        ert("phi_L")), ok, hiba);
    [ok, hiba] = ell(abs(ert("delta") - 0.025) < 0.002, ...
        sprintf('t46: delta = %.4f megerositi az atvett 0.0250-et', ...
        ert("delta")), ok, hiba);
    % AMIT AZ ADAT MEGCAFOL: a lev_E = lev_D kenyszeritett egyenloseg.
    [ok, hiba] = ell(ert("lev_E") - ert("lev_D") > 0.1, ...
        sprintf(['t46: a lev_E = lev_D kenyszeritett egyenloseg NEM ALL ' ...
        '(%.3f vs %.3f)'], ert("lev_E"), ert("lev_D")), ok, hiba);
end

t47 = fullfile(repo, 'output', 'tables', 't47_opten_stressz.csv');
[ok, hiba] = ell(exist(t47, 'file') == 2, 't47 opten stressz letezik', ok, hiba);
if exist(t47, 'file') == 2
    O = readtable(t47);
    require_columns_(O, {'solver_ok','bk_check_ok','bk_ok','ervenyes', ...
        'n_forward','n_unstable','bk_qz_criterium'}, 't47');
    [ok, hiba] = ell(height(O) == 36 && all(O.solver_ok == 1) && ...
        all(O.bk_check_ok == 1), ...
        sprintf('t47: mind a %d PF/BK diagnosztika technikailag lefutott', ...
        height(O)), ok, hiba);
    [ok, hiba] = ell(all(O.bk_ok(O.OPTEN == 0) == 1) && ...
        all(O.bk_ok(O.OPTEN ~= 0) == 0) && ...
        all(O.n_unstable(O.OPTEN ~= 0) == 15) && ...
        all(O.n_forward == 13), ...
        sprintf(['t47 TERMINALIS BK: csak OPTEN=0 stabil; az OPTEN=1/2/3 ' ...
        'agakon 15 instabil gyok jut 13 eloretekinto valtozora (%d/%d stabil)'], ...
        sum(O.bk_ok == 1), height(O)), ok, hiba);
    % A korabbi +0.3...+2.9%-os sav BK-invalid sorokat is tartalmazott.
    % Most csak a ket feltetelt egyszerre teljesito sorokat orizzuk.
    Ov = O(O.ervenyes == 1, :);
    gmin = min(Ov.GDP_pct); gmax = max(Ov.GDP_pct);
    [ok, hiba] = ell(~isempty(Ov) && gmin > 0.50 && gmax < 1.20, ...
        sprintf(['t47 ERVENYES SZINT: a terminalisan determinált GDP-sav ' ...
        '%.2f%% ... %.2f%%'], gmin, gmax), ok, hiba);
    % REGRESSZIO: az OPTEN=0 ag adja-e a t44 tarolt eredmenyet? (Az shl_*
    % ertekadas athelyezese a .mod-ban nem valtoztathatta meg semmit.)
    if exist(t44, 'file') == 2
        a = O(O.OPTEN == 0 & O.SCENARIO == 1 & O.TSCEN == 3, :);
        b = A9(A9.SCENARIO == 1 & A9.TSCEN == 3 & A9.NOVERT == 0, :);
        d = max(abs([a.GDP_pct-b.GDP_pct, a.y_E_pct-b.y_E_pct, ...
            a.y_D_pct-b.y_D_pct, a.y_L_pct-b.y_L_pct]));
        [ok, hiba] = ell(d < 1e-9, ...
            sprintf('t47 REGRESSZIO: OPTEN=0 == t44 baseline (elteres %.1e)', ...
            d), ok, hiba);
    end
end

t48b = fullfile(repo, 'output', 'tables', 't48b_opten_kuszob_osszegzes.csv');
[ok, hiba] = ell(exist(t48b, 'file') == 2, 't48b opten-kuszob letezik', ok, hiba);
if exist(t48b, 'file') == 2
    Kk = readtable(t48b);
    require_columns_(Kk, {'bk_ok_D_L','bk_ok_KKV_L','bk_ok_E_L'}, 't48b');
    k0 = Kk.kuszob_KKV_L(Kk.OPTEN == 0);
    k1 = Kk.kuszob_KKV_L(Kk.OPTEN == 1);
    [ok, hiba] = ell(all(isfinite(Kk.kuszob_KKV_L)), ...
        't48b: minden agon letezik veges kuszob', ok, hiba);
    [ok, hiba] = ell(all(Kk.bk_ok_D_L == 1 & Kk.bk_ok_KKV_L == 1 & ...
        Kk.bk_ok_E_L == 1), ...
        't48b: minden kozolt kuszob terminalisan lokalisan BK-stabil', ok, hiba);
    [ok, hiba] = ell(all(Kk.kuszob_D_L < Kk.kuszob_KKV_L) && ...
        all(Kk.kuszob_KKV_L < Kk.kuszob_E_L), ...
        't48b: a kuszob-sorrend D < sulyozott KKV < E minden agon', ok, hiba);
    [ok, hiba] = ell(k1 < k0, ...
        sprintf(['t48b: a magas-rho kalibracios ag LEVISZI a kuszobot ' ...
        '(%.1f -> %.1f)'], k0, k1), ok, hiba);
    % SZINT-OR az F01 allitas szovegehez ("22,3" es "36,5").
    [ok, hiba] = ell(abs(k0 - 36.5) < 0.5 && abs(k1 - 22.3) < 0.5, ...
        sprintf('t48b SZINT: a kuszobok az F01-ben kozolt szamokon (%.1f / %.1f)', ...
        k0, k1), ok, hiba);
end

t49b = fullfile(repo, 'output', 'tables', 't49b_rhoacc_erzekenyseg_osszegzes.csv');
[ok, hiba] = ell(exist(t49b, 'file') == 2, 't49b rho_acc erzekenyseg letezik', ok, hiba);
if exist(t49b, 'file') == 2
    Rr = sortrows(readtable(t49b), 'rho_acc');
    require_columns_(Rr, {'bk_ok_ACC100'}, 't49b');
    [ok, hiba] = ell(all(diff(Rr.kuszob_KKV_L) < 0), ...
        sprintf(['t49b: a kuszob MONOTON csokken a rho_acc-ban ' ...
        '(%.1f -> %.1f)'], Rr.kuszob_KKV_L(1), Rr.kuszob_KKV_L(end)), ok, hiba);
    Rrv = Rr(Rr.bk_ok_ACC100 == 1, :);
    [ok, hiba] = ell(height(Rrv) >= 2 && all(diff(Rrv.GDP_pct_ACC100) > 0), ...
        't49b: a GDP-hatas a BK-ervenyes ACC100 pontokon monoton no', ok, hiba);
    high = Rr.rho_acc >= 0.93;
    [ok, hiba] = ell(all(Rr.bk_ok_ACC100(high) == 0) && ...
        all(isnan(Rr.GDP_pct_ACC100(high))), ...
        't49b KORLAT: rho_acc>=0.93 mellett ACCSCALE=100 BK-invalid, GDP nincs kozolve', ...
        ok, hiba);
end

% --- AZ s14 HOZZAFERESI TENYEI (a projekt legerosebb sajat adatai) --------
% Ezek eddig OR NELKUL alltak a doksikban -- az allapotlap konzisztencia-
% ellenorzese fogta el (allitasok.csv A02-A05).
t37 = fullfile(repo, 'output', 'tables', 't37_access_szegmens_evek.csv');
[ok, hiba] = ell(exist(t37, 'file') == 2, 't37 access szegmens-evek letezik', ok, hiba);
if exist(t37, 'file') == 2
    H = readtable(t37);
    sz = string(H.szegmens);
    atl = @(s) mean(H.hozzaferes_pct(sz == s));
    aE = atl("E_export_KKV"); aD = atl("D_hazai_KKV"); aL = atl("L_nagyvallalat");
    % SZINT-OR: az A02 allitas "13-szoros"-t mond, tehat a savot is orizzuk,
    % nem csak azt, hogy "sok".
    [ok, hiba] = ell(aE / aD > 12 && aE / aD < 14, ...
        sprintf('t37: az export-KKV hozzaferese 13x a hazaie (%.1fx: %.1f%% vs %.1f%%)', ...
        aE / aD, aE, aD), ok, hiba);
    [ok, hiba] = ell(aL < aE, ...
        sprintf('t37: a nagyvallalati hozzaferes ALACSONYABB az export-KKV-enal (%.1f%% < %.1f%%)', ...
        aL, aE), ok, hiba);
    bsav = max(H.bubor_pct) - min(H.bubor_pct);
    hsav = 0;
    for s = ["E_export_KKV" "D_hazai_KKV" "L_nagyvallalat"]
        hsav = max(hsav, max(H.hozzaferes_pct(sz == s)) - min(H.hozzaferes_pct(sz == s)));
    end
    % A korabbi doksiszoveg "kevesebb mint 2 pont"-ot mondott; a tenyleges
    % maximum 2.2 pp (az export-KKV-nal). A kuszob ezert 3, es az UZENET
    % viszi a valos szamot -- igy a szoveg es az adat nem tud szetcsuszni.
    [ok, hiba] = ell(bsav > 12 && hsav < 3, ...
        sprintf(['t37 PROGRAMVEZERELTSEG: a BUBOR %.1f pontot mozgott, a ' ...
        'hozzaferes legfeljebb %.1f-et'], bsav, hsav), ok, hiba);
    D21 = H.hozzaferes_pct(sz == "D_hazai_KKV" & H.ev == 2021);
    D23 = H.hozzaferes_pct(sz == "D_hazai_KKV" & H.ev == 2023);
    [ok, hiba] = ell(D23 > D21, ...
        sprintf(['t37: a hazai KKV hozzaferese NOTT a kamatcsucs fele ' ...
        '(%.1f%% -> %.1f%%)'], D21, D23), ok, hiba);
end

% --- BGG-BLOKK: lev_j es chi_j az Opten-panelbol (11_bgg_blokk_kalibracio.py)
t50 = fullfile(repo, 'output', 'tables', 't50_bgg_blokk.csv');
[ok, hiba] = ell(exist(t50, 'file') == 2, 't50 bgg-blokk letezik', ok, hiba);
if exist(t50, 'file') == 2
    B = readtable(t50);
    bp = string(B.parameter);
    b = @(p) B.opten(bp == p);
    [ok, hiba] = ell(b("lev_L") > b("lev_E") && b("lev_E") > b("lev_D"), ...
        sprintf('t50: a tokeattetel-sorrend L > E > D (%.3f > %.3f > %.3f)', ...
        b("lev_L"), b("lev_E"), b("lev_D")), ok, hiba);
    % Az irodalmi horgony (BGG / Christensen-Dib k/n = 2) kornyeke.
    [ok, hiba] = ell(all(abs([b("lev_E") b("lev_D") b("lev_L")] - 2) < 0.4), ...
        't50: mindharom lev az irodalmi k/n = 2 kornyeken (+-0.4)', ok, hiba);
    % SZINT-OR. A SZABALY: ha egy allitas SZAMOT mond, az ort arra a szamra
    % kell rakni, nem csak a relaciora. Az A07 allitas szovege "2,34 > 1,94 >
    % 1,72" -- sorrend-or mellett ezek a SZINTEK nemán elavulhatnanak.
    [ok, hiba] = ell(abs(b("lev_E") - 1.939) < 0.02 && ...
        abs(b("lev_D") - 1.719) < 0.02 && abs(b("lev_L") - 2.337) < 0.02, ...
        sprintf(['t50 SZINT: a lev_j ertekek az A07-ben kozolt szamokon ' ...
        '(%.3f / %.3f / %.3f)'], b("lev_E"), b("lev_D"), b("lev_L")), ok, hiba);
end
t50b = fullfile(repo, 'output', 'tables', 't50b_bgg_chi_reszletes.csv');
[ok, hiba] = ell(exist(t50b, 'file') == 2, 't50b chi-specifikaciok letezik', ok, hiba);
if exist(t50b, 'file') == 2
    Cs = readtable(t50b);
    Cs = Cs(string(Cs.valtozo) == "log(lev)" & ...
        string(Cs.csoport) == "S_KKV_egyben", :);
    sA = Cs.egyutthato(startsWith(string(Cs.spec), 'A'));
    sC = Cs.egyutthato(startsWith(string(Cs.spec), 'C'));
    % A FO MODSZERTANI EREDMENY ORE: az "A" spec eros negativ egyutthatoja
    % MERESI MUTERMEK (ev vegi allomany a nevezoben). A "C" specben a helyes,
    % POZITIV elojel jon ki. Ha ez az or elhal, a doc allitasa nem all tobbe.
    [ok, hiba] = ell(~isempty(sA) && ~isempty(sC) && sA < 0 && sC > 0, ...
        sprintf(['t50b: a chi elojele atfordul a nevezo javitasaval ' ...
        '(A: %+.5f -> C: %+.5f) - a negativ eredmeny mutermek volt'], ...
        sA, sC), ok, hiba);
end

% --- A 2_empirikus VONAL EREDMENYEI (t10-t17, t25) -----------------------
% Ezek a tablak hosszu ideig OR NELKUL alltak: valodi empirikus eredmenyek,
% amikhez nem tartozott allitas. Az output/INDEX.md auditja fogta el oket
% (2026-08-16). Most mind kap allitast (A16-A21, F05) es SZINT-ort.

% t25 — KAMATTRANSZMISSZIO. A negy becslesbol MIND a nagyvallalatnal ad
% magasabb atgyuruzest, DE egyik kulonbseg sem szignifikans 5%-on. Ez a
% V03 (t_S > t_L) visszavonasanak empirikus alapja.
t25 = fullfile(repo, 'output', 'tables', 't25_transzmisszio.csv');
[ok, hiba] = ell(exist(t25, 'file') == 2, 't25 transzmisszio letezik', ok, hiba);
if exist(t25, 'file') == 2
    Tr = readtable(t25, 'VariableNamingRule', 'preserve');
    szeg = string(Tr.szegmens); csat = string(Tr.csatorna);
    irany_ok = true; szign = false;
    for c = unique(csat)'
        S = Tr(csat == c & szeg == "KKV", :);
        L = Tr(csat == c & szeg == "nagyvallalat", :);
        for oszlop = ["szint", "diff_kumulalt"]
            bS = S.(oszlop + "_beta"); bL = L.(oszlop + "_beta");
            seD = sqrt(S.(oszlop + "_se")^2 + L.(oszlop + "_se")^2);
            irany_ok = irany_ok && (bL > bS);
            szign = szign || (abs(bL - bS) / seD > 1.96);
        end
    end
    [ok, hiba] = ell(irany_ok, ...
        't25: mind a 4 becslesben a NAGYVALLALATI atgyuruzes a magasabb', ok, hiba);
    [ok, hiba] = ell(~szign, ...
        't25: egyik meret szerinti kulonbseg sem szignifikans 5%-on', ok, hiba);
end

% t10/t11 — HOZZAFERES. A nyers szakadek a kockazati besorolasok kozott
% nagyreszt OSSZETETEL-HATAS: meretre/agazatra/regiora/evre kiigazitva
% osszemegy.
t11 = fullfile(repo, 'output', 'tables', 't11_hozzaferes_kiigazitott.csv');
[ok, hiba] = ell(exist(t11, 'file') == 2, 't11 hozzaferes kiigazitott letezik', ok, hiba);
if exist(t11, 'file') == 2
    Hk = readtable(t11);
    b = string(Hk.besorolas);
    nyA = Hk.nyers_hozzaferes_pct(b == "A"); nyC = Hk.nyers_hozzaferes_pct(b == "C");
    kiA = Hk.kiigazitott_hozzaferes_pct(b == "A"); kiC = Hk.kiigazitott_hozzaferes_pct(b == "C");
    [ok, hiba] = ell((nyA - nyC) > 10 && (kiA - kiC) < 4, ...
        sprintf(['t11: a hozzaferesi res OSSZETETEL-HATAS (nyers %.1f pp -> ' ...
        'kiigazitott %.1f pp)'], nyA - nyC, kiA - kiC), ok, hiba);
end

% t12 — ARAZAS. A KKV-hitelarazas LESZAKADT a piaci kamattol.
t12 = fullfile(repo, 'output', 'tables', 't12_rata_eloszlas_ev.csv');
[ok, hiba] = ell(exist(t12, 'file') == 2, 't12 rata-eloszlas letezik', ok, hiba);
if exist(t12, 'file') == 2
    Re = readtable(t12);
    r23 = Re(Re.ev == 2023, :); r21 = Re(Re.ev == 2021, :);
    [ok, hiba] = ell(r23.bubor_pct > 13 && r23.median < 6, ...
        sprintf(['t12 LESZAKADAS: 2023-ban a BUBOR %.1f%%, a median KKV-rata ' ...
        'csak %.1f%% (2021: %.1f%%)'], r23.bubor_pct, r23.median, r21.median), ok, hiba);
    [ok, hiba] = ell(r23.piaci_arazasu_pct < 25, ...
        sprintf('t12: 2023-ban a ratak mindossze %.1f%%-a volt piaci arazasu', ...
        r23.piaci_arazasu_pct), ok, hiba);
end

% t13 — A piaci alminta ratája a teljes minta TOBBSZOROSE, es ott a
% kockazati sorrend eltunik (a jobb besorolasu ceg dragabban hitelez).
t13 = fullfile(repo, 'output', 'tables', 't13_piaci_alminta_besorolas.csv');
[ok, hiba] = ell(exist(t13, 'file') == 2, 't13 piaci alminta letezik', ok, hiba);
if exist(t13, 'file') == 2
    Pa = readtable(t13);
    b = string(Pa.besorolas);
    ar = @(x) Pa.median_piaci_pct(b == x) / Pa.median_teljes_pct(b == x);
    [ok, hiba] = ell(all(arrayfun(@(x) ar(x) > 2.5, ["A" "B" "C"])), ...
        sprintf(['t13: a piaci alminta rataja a teljes minta tobbszorose ' ...
        '(A: %.1fx, B: %.1fx, C: %.1fx)'], ar("A"), ar("B"), ar("C")), ok, hiba);
    [ok, hiba] = ell(Pa.median_piaci_pct(b == "A") > Pa.median_piaci_pct(b == "C"), ...
        sprintf(['t13: a piaci almintaban a kockazati sorrend ELTUNIK ' ...
        '(A %.2f%% > C %.2f%%)'], Pa.median_piaci_pct(b == "A"), ...
        Pa.median_piaci_pct(b == "C")), ok, hiba);
end

% t14 — TAMOGATASI EK.
t14 = fullfile(repo, 'output', 'tables', 't14_tamogatasi_ek.csv');
[ok, hiba] = ell(exist(t14, 'file') == 2, 't14 tamogatasi ek letezik', ok, hiba);
if exist(t14, 'file') == 2
    Ek = readtable(t14);
    e23 = Ek(Ek.ev == 2023, :);
    [ok, hiba] = ell(e23.ek_bubor_MrdFt > 500 && e23.ek_allomany_aranyaban_pct > 9 ...
        && e23.alularazott_cegek_pct > 75, ...
        sprintf(['t14: 2023-ban az implicit tamogatasi ek %.0f Mrd Ft ' ...
        '(az allomany %.1f%%-a), a cegek %.1f%%-a alularazott'], ...
        e23.ek_bubor_MrdFt, e23.ek_allomany_aranyaban_pct, ...
        e23.alularazott_cegek_pct), ok, hiba);
end

% t15 — CSATORNA-DEKOMPOZICIO (a v03 ARCHIV modellen!).
t15 = fullfile(repo, 'output', 'tables', 't15_csatorna_dekompozicio.csv');
[ok, hiba] = ell(exist(t15, 'file') == 2, 't15 csatorna-dekompozicio letezik', ok, hiba);
if exist(t15, 'file') == 2
    Cd = readtable(t15);
    arany = abs(Cd.y_banki_pct(1)) / abs(Cd.y_teljes_pct(1));
    [ok, hiba] = ell(arany < 0.01, ...
        sprintf(['t15: a hatas gyakorlatilag teljesen a SZUVEREN csatornan ' ...
        'megy (a banki resz %.2f%%) — de a v03 ARCHIV modellen'], 100*arany), ...
        ok, hiba);
end

% t17 — BERMEREVSEG. A nominalis bercsokkentes MONOTON csokken a merettel.
t17 = fullfile(repo, 'output', 'tables', 't17_beralkalmazkodas.csv');
[ok, hiba] = ell(exist(t17, 'file') == 2, 't17 beralkalmazkodas letezik', ok, hiba);
if exist(t17, 'file') == 2
    Br = readtable(t17);
    cs = string(Br.csoport);
    cso = @(x) Br.nominalis_csokkentes_pct(cs == x);
    [ok, hiba] = ell(cso("10-49") > cso("50-249") && cso("50-249") > cso("250+"), ...
        sprintf(['t17: a nominalis bercsokkentes MONOTON csokken a merettel ' ...
        '(%.1f%% > %.1f%% > %.1f%%)'], cso("10-49"), cso("50-249"), cso("250+")), ...
        ok, hiba);
    [ok, hiba] = ell(cso("összes") > 8 && Br.befagyasztas_pm1_pct(cs == "összes") < 5, ...
        sprintf(['t17: GYENGE nominalis merevseg 2023-24-ben (%.1f%% csokkentett, ' ...
        'csak %.1f%% fagyasztott)'], cso("összes"), ...
        Br.befagyasztas_pm1_pct(cs == "összes")), ok, hiba);
end

% --- A KULSO BIRALAT NYOMAN BEVEZETETT KET TABLA (2026-08-21) -----------
% t25b: a meret szerinti transzmisszio-kulonbseg konfidencia-intervalluma.
% Az A16 mostantol NEM pontbecslest allit, hanem azt, hogy a kulonbseg
% egyiranyu DE nem szignifikans -- mindkettot orizni kell.
t25b = fullfile(repo, 'output', 'tables', 't25b_transzmisszio_ci.csv');
[ok, hiba] = ell(exist(t25b, 'file') == 2, 't25b transzmisszio-CI letezik', ok, hiba);
if exist(t25b, 'file') == 2
    Ci = readtable(t25b);
    [ok, hiba] = ell(all(Ci.kulonbseg_L_minus_S > 0), ...
        sprintf('t25b: mind a %d becslesben L > S (egyiranyu pontbecslesek)', ...
        height(Ci)), ok, hiba);
    [ok, hiba] = ell(all(Ci.ci95_also < 0 & Ci.ci95_felso > 0), ...
        't25b: mind a 4 CI TARTALMAZZA a nullat - a kulonbseg nem szignifikans', ...
        ok, hiba);
    [ok, hiba] = ell(all(Ci.szignifikans_5pct == 0), ...
        sprintf('t25b: 0 szignifikans kulonbseg (max |t| = %.2f)', ...
        max(abs(Ci.t_stat))), ok, hiba);
end

% t51: a kuszob nulla-kontura a (rho_acc, ACCSCALE) sikon. Az F01 mostantol
% erre hivatkozik, mert a kuszob a KET parameter EGYUTTES fuggvenye.
t51 = fullfile(repo, 'output', 'tables', 't51_kuszobfelulet.csv');
[ok, hiba] = ell(exist(t51, 'file') == 2, 't51 kuszobfelulet-kontur letezik', ok, hiba);
if exist(t51, 'file') == 2
    Kf = sortrows(readtable(t51), 'rho_acc');
    require_columns_(Kf, {'bk_ok_ACC100','bk_ok_kuszobon'}, 't51');
    [ok, hiba] = ell(all(Kf.bk_ok_kuszobon == 1), ...
        't51: a teljes kozolt nullkontur BK-ervenyes racspontok kozt fekszik', ...
        ok, hiba);
    [ok, hiba] = ell(all(diff(Kf.kuszob_ACCSCALE) < 0), ...
        sprintf('t51 KONTUR: a kuszob MONOTON csokken a rho_acc-ban (%.1f -> %.1f)', ...
        Kf.kuszob_ACCSCALE(1), Kf.kuszob_ACCSCALE(end)), ok, hiba);
    % SZINT-OR az F01 szovegehez: a ket nevezetes pont
    k85 = Kf.kuszob_ACCSCALE(abs(Kf.rho_acc - 0.85) < 1e-9);
    k97 = Kf.kuszob_ACCSCALE(abs(Kf.rho_acc - 0.9673) < 1e-9);
    [ok, hiba] = ell(abs(k85 - 47.8) < 0.5 && abs(k97 - 22.3) < 0.5, ...
        sprintf(['t51 SZINT: a kontur vegpontjai az F01-ben kozolt szamokon ' ...
        '(%.1f / %.1f)'], k85, k97), ok, hiba);
end

% --- t52: AZ ACCSCALE SZETBONTASA (lambda / omega) -----------------------
% MIT VED. A korlatok-riport 1. teendoje. Eddig EGY szam skalazta a
% hozzaferesi csatorna mindket lepcsojet, ezert a kozolt "22.3-as kuszob"
% ket rugalmassag szorzatan ult. A szetbontas utan kiderult, hogy a modell
% a ket parametert KULON NEM IS AZONOSITJA -- csak a szorzatukat. Ezek az
% orok ezt a szerkezeti allitast orzik: ha barmelyik elbukik, valaki
% elrontotta a szorzat-szerkezetet, es a kozolt kuszobforma ervenytelen.
t52e = fullfile(repo, 'output', 'tables', 't52e_lam_om_szorzat.csv');
[ok, hiba] = ell(exist(t52e, 'file') == 2, 't52e szorzat-azonossag letezik', ok, hiba);
if exist(t52e, 'file') == 2
    Sz = readtable(t52e);
    require_columns_(Sz, {'solver_ok','bk_check_ok','bk_ok','ervenyes', ...
        'n_forward','n_unstable','bk_qz_criterium'}, 't52e');
    maxelt = 0;
    n_csoport = 0;
    for pv = unique(Sz.szorzat)'
        v = Sz.KKV_minus_L_pp(Sz.szorzat == pv & Sz.ervenyes == 1);
        if numel(v) >= 2
            maxelt = max(maxelt, max(v) - min(v));
            n_csoport = n_csoport + 1;
        end
    end
    [ok, hiba] = ell(n_csoport >= 1 && maxelt < 1e-9, ...
        sprintf(['t52e SZERKEZET: a modell CSAK a lambda*omega szorzatot ' ...
        'azonositja a BK-ervenyes tartomanyban (max elteres %.1e pp)'], ...
        maxelt), ok, hiba);
    p2500 = Sz(Sz.szorzat == 2500 & Sz.ervenyes == 1, :);
    [ok, hiba] = ell(height(p2500) == 5, ...
        't52e: az 2500-as kontrollcsoport mind az 5 pontja BK-ervenyes', ok, hiba);
end

t52b = fullfile(repo, 'output', 'tables', 't52b_lam_om_kontur.csv');
[ok, hiba] = ell(exist(t52b, 'file') == 2, 't52b lam-om kontur letezik', ok, hiba);
if exist(t52b, 'file') == 2
    Kc = readtable(t52b);
    require_columns_(Kc, {'bk_ok_kuszobon'}, 't52b');
    Kc = Kc(isfinite(Kc.kuszob_omega) & Kc.bk_ok_kuszobon == 1, :);
    relszoras = std(Kc.szorzat) / mean(Kc.szorzat);
    [ok, hiba] = ell(height(Kc) >= 10 && relszoras < 0.01, ...
        sprintf(['t52b: a kuszob-kontur IZO-SZORZAT gorbe (%d pont, a ' ...
        'szorzat relativ szorasa %.2f%%)'], height(Kc), 100*relszoras), ...
        ok, hiba);
    % SZINT-OR: a kozolt szorzat-kuszob
    [ok, hiba] = ell(abs(median(Kc.szorzat) - 500) < 5, ...
        sprintf('t52b SZINT: a szorzat-kuszob a kozolt 500-on (%.1f)', ...
        median(Kc.szorzat)), ok, hiba);
    % a kontur MONOTON csokken: nagyobb lambda -> kisebb omega kell
    Kc = sortrows(Kc, 'lambda_skala');
    [ok, hiba] = ell(all(diff(Kc.kuszob_omega) < 0), ...
        sprintf('t52b: a kuszob-omega MONOTON csokken a lambda-ban (%.1f -> %.1f)', ...
        Kc.kuszob_omega(1), Kc.kuszob_omega(end)), ok, hiba);
end

t52d = fullfile(repo, 'output', 'tables', 't52d_lam_om_diagonalis.csv');
[ok, hiba] = ell(exist(t52d, 'file') == 2, 't52d lam-om atlo letezik', ok, hiba);
if exist(t52d, 'file') == 2
    Dg = readtable(t52d);
    require_columns_(Dg, {'bk_ok_kuszobon'}, 't52d');
    [ok, hiba] = ell(all(Dg.bk_ok_kuszobon == 1), ...
        't52d: mindket atlobeli kuszob terminalisan lokalisan BK-stabil', ok, hiba);
    a1 = Dg.kuszob_diagonalis(Dg.OPTEN == 1);
    a0 = Dg.kuszob_diagonalis(Dg.OPTEN == 0);
    % REGRESSZIOS HID: az atlo (lambda = omega) a REGI, egydimenzios
    % kuszobot kell visszaadja -- ez koti ossze a t52-t a t48b/t51-gyel.
    [ok, hiba] = ell(abs(a1 - 22.3) < 0.5 && abs(a0 - 36.5) < 0.5, ...
        sprintf(['t52d HID: az atlo visszaadja a t48b/t51 kuszobeit ' ...
        '(%.2f / %.2f vs 22.3 / 36.5)'], a1, a0), ok, hiba);
end

t52c = fullfile(repo, 'output', 'tables', 't52c_lam_om_marginalis.csv');
[ok, hiba] = ell(exist(t52c, 'file') == 2, 't52c marginalis scan letezik', ok, hiba);
if exist(t52c, 'file') == 2
    Mg = readtable(t52c);
    require_columns_(Mg, {'solver_ok','bk_check_ok','bk_ok','ervenyes', ...
        'n_forward','n_unstable','bk_qz_criterium'}, 't52c');
    Ml = sortrows(Mg(string(Mg.irany) == "lambda" & Mg.ervenyes == 1, :), 'skala');
    Mo = sortrows(Mg(string(Mg.irany) == "omega"  & Mg.ervenyes == 1, :), 'skala');
    Me = sortrows(Mg(string(Mg.irany) == "egyutt" & Mg.ervenyes == 1, :), 'skala');
    [ok, hiba] = ell(height(Ml) == height(Mo) && ...
        max(abs(Ml.KKV_minus_L_pp - Mo.KKV_minus_L_pp)) < 1e-9, ...
        't52c: a "csak lambda" es a "csak omega" metszet AZONOS', ok, hiba);
    % A DIAGNOZIS ORE: az egyuttes skalazas hanyadosa NO (kvadratikus), az
    % egy-lepcsose CSOKKEN (GE-tompitas). Ha ez megfordul, a szoveget is
    % javitani kell.
    hl = Ml.hatas_per_skala(Ml.skala > 0);
    he = Me.hatas_per_skala(Me.skala > 0);
    [ok, hiba] = ell(max(he)/min(he) > 3*max(hl)/min(hl), ...
        sprintf(['t52c DIAGNOZIS: a kvadratikussag a KOZOS skalazas ' ...
        'mutermeke (egyutt %.1fx vs egy-lepcso %.1fx)'], ...
        max(he)/min(he), max(hl)/min(hl)), ok, hiba);
end

% --- t53: E/D/L DEKOMPOZICIO (technologia vagy finanszirozas?) -----------
% MIT VED. A korlatok-riport 2. teendoje, es a VARHATO FO REFEREE-KERDES:
% "show me that your main conclusion is not an artifact of the E/D/L
% calibration". A valasz az, hogy a technologiai heterogenitas teljes
% kivetele a kuszobot 3%-kal mozditja. Ha ez az or elbukik, a tanulmany fo
% allitasat at kell fogalmazni -- ezert kap SZINT-ort is.
t53d = fullfile(repo, 'output', 'tables', 't53d_dekomp_regresszio.csv');
[ok, hiba] = ell(exist(t53d, 'file') == 2, 't53d dekomp-regresszio letezik', ok, hiba);
if exist(t53d, 'file') == 2
    Rg = readtable(t53d);
    [ok, hiba] = ell(Rg.max_elteres < 1e-9, ...
        sprintf(['t53d REGRESSZIO: a -DDECOMP=0 ag == t44 baseline ' ...
        '(elteres %.1e)'], Rg.max_elteres), ok, hiba);
end

t53b = fullfile(repo, 'output', 'tables', 't53b_dekomp_kuszob.csv');
[ok, hiba] = ell(exist(t53b, 'file') == 2, 't53b dekomp-kuszob letezik', ok, hiba);
if exist(t53b, 'file') == 2
    Dk = readtable(t53b);
    require_columns_(Dk, {'kuszob_bk_ok'}, 't53b');
    m1 = Dk.OPTEN == 1;
    k0 = Dk.kuszob(m1 & Dk.DECOMP == 0);
    kB = Dk.kuszob(m1 & Dk.DECOMP == 2);
    kD = Dk.kuszob(m1 & Dk.DECOMP == 4);
    [ok, hiba] = ell(all(isfinite(Dk.kuszob)), ...
        't53b: minden dekompozicios agon letezik veges kuszob', ok, hiba);
    [ok, hiba] = ell(all(Dk.kuszob_bk_ok == 1), ...
        't53b: minden kozolt dekompozicios kuszob terminalisan BK-stabil', ...
        ok, hiba);
    % A FO ALLITAS ORE
    [ok, hiba] = ell(abs(kD/k0 - 1) < 0.15 && abs(kB/k0 - 1) < 0.15, ...
        sprintf(['t53b FO ALLITAS: a KKV-eredmeny NEM technologiai ' ...
        'mutermek (technologia azonos %.2fx, csak penzugyi %.2fx)'], ...
        kD/k0, kB/k0), ok, hiba);
    % SZINT-OR a kozolt szamokhoz (22.36 / 22.62 / 22.95)
    [ok, hiba] = ell(abs(k0 - 22.36) < 0.3 && abs(kB - 22.62) < 0.3 && ...
        abs(kD - 22.95) < 0.3, ...
        sprintf('t53b SZINT: a kuszobok a kozolt szamokon (%.2f / %.2f / %.2f)', ...
        k0, kB, kD), ok, hiba);
end

t53c = fullfile(repo, 'output', 'tables', 't53c_dekomp_bk.csv');
[ok, hiba] = ell(exist(t53c, 'file') == 2, 't53c dekomp BK-stressz letezik', ok, hiba);
if exist(t53c, 'file') == 2
    Db = readtable(t53c);
    require_columns_(Db, {'solver_ok','bk_check_ok','bk_ok','ervenyes', ...
        'n_forward','n_unstable','bk_qz_criterium'}, 't53c');
    [ok, hiba] = ell(all(Db.solver_ok == 1) && all(Db.bk_check_ok == 1), ...
        sprintf('t53c: mind a %d PF/BK diagnosztika technikailag lefutott', ...
        height(Db)), ok, hiba);
    [ok, hiba] = ell(height(Db) == 45 && all(Db.bk_ok == 0) && ...
        all(Db.ervenyes == 0) && all(Db.n_unstable == 15) && ...
        all(Db.n_forward == 13), ...
        sprintf(['t53c KORREKCIO: az OPTEN1 ACC100 racs pontosan 0/45 ' ...
        'terminalis BK-stabil (gyok/elo=%g/%g)'], ...
        min(Db.n_unstable), min(Db.n_forward)), ok, hiba);
end

t53 = fullfile(repo, 'output', 'tables', 't53_dekomp_edl.csv');
[ok, hiba] = ell(exist(t53, 'file') == 2, 't53 dekomp-agak letezik', ok, hiba);
if exist(t53, 'file') == 2
    De = readtable(t53);
    require_columns_(De, {'solver_ok','bk_check_ok','bk_ok','ervenyes', ...
        'n_forward','n_unstable'}, 't53');
    [ok, hiba] = ell(height(De) == 18 && all(De.solver_ok == 1) && ...
        all(De.bk_check_ok == 1), ...
        sprintf('t53: mind a %d dekompozicios PF/BK diagnosztika lefutott', ...
        height(De)), ok, hiba);
    m0 = De.OPTEN == 0;
    m1 = De.OPTEN == 1;
    [ok, hiba] = ell(sum(m0) == 9 && all(De.bk_ok(m0) == 1) && ...
        all(De.n_unstable(m0) == 13) && all(De.n_forward(m0) == 13) && ...
        sum(m1) == 9 && all(De.bk_ok(m1) == 0) && ...
        all(De.n_unstable(m1) == 15) && all(De.n_forward(m1) == 13), ...
        sprintf(['t53 KORREKCIO: OPTEN0 %d/9 BK (13/13), ' ...
        'OPTEN1 %d/9 BK (15/13)'], sum(De.bk_ok(m0) == 1), ...
        sum(De.bk_ok(m1) == 1)), ok, hiba);
    % SULYOZASI ELLENPROBA: a kovetkeztetes nem mulhat azon, hogy a "kozos
    % erteket" meretsulyozott vagy egyszeru atlagkent kepezzuk.
    d4w = De(De.DECOMP == 4 & De.DECOMPW == 1 & De.OPTEN == 0, :);
    d4u = De(De.DECOMP == 4 & De.DECOMPW == 0 & De.OPTEN == 0, :);
    [ok, hiba] = ell(height(d4w) == 1 && height(d4u) == 1 && ...
        d4w.ervenyes == 1 && d4u.ervenyes == 1 && ...
        abs(d4w.KKV_minus_L_pp - d4u.KKV_minus_L_pp) / ...
        abs(d4w.KKV_minus_L_pp) < 0.05, ...
        sprintf(['t53 ELLENPROBA (BK-ervenyes OPTEN0): a sulyozas ' ...
        'modja nem szamit (%.3f vs %.3f pp)'], ...
        d4w.KKV_minus_L_pp, d4u.KKV_minus_L_pp), ok, hiba);
end

% --- PHILLIPS-ASZIMMETRIA OR (kulso biralat, 2026-08-21) -----------------
% MIT VED. A harom tipus arazasi egyenlete NEM szimmetrikus sokkot kap:
%   pi_E, pi_D  ->  + eps_md    (NYERS sokk, varexo)
%   pi_L        ->  + e_mx_ar   (AR-FOLYAMAT, rho_mx = 0.318)
% Tehat nem csak a sokk forrasa mas, hanem a PERZISZTENCIAJA is. Ez jelenleg
% NEM erint egyetlen kozolt eredmenyt sem, mert a szcenariok csak az uni/sov/
% bank valtozokat hajtjak -- eps_md es eps_mx minden futasban azonosan nulla,
% tehat e_mx_ar is az. DE: ha barki bevezet egy ar-markup sokkot (peldaul a
% Szabo Bakos-fele "a piacszerkezet-valtozas markup-sokkkent" recept szerint),
% az AZONNAL es NEMAN eltolja a KKV/nagyvallalat osszevetest, es a
% szimmetria-teszt sem fogja el, mert az nulla sokk mellett fut.
% EZ AZ OR ELBUKIK, ha valaki ilyen sokkot hajt, azzal az uzenettel, hogy
% ELOBB a specifikaciot kell szimmetrizalni.
fo_mod = fullfile(repo, 'src', 'modell', '1_fo_vonal_jv', 'jv_dsge_v09_access.mod');
if isfile(fo_mod)
    sz = fileread(fo_mod);
    % a shocks; ... end; blokkok kigyujtese
    blokkok = regexp(sz, 'shocks;(.*?)end;', 'tokens');
    hajtott = false; melyik = "";
    for i = 1:numel(blokkok)
        b = blokkok{i}{1};
        for v = ["eps_md" "eps_mx"]
            if contains(b, v)
                hajtott = true; melyik = melyik + " " + v;
            end
        end
    end
    [ok, hiba] = ell(~hajtott, ...
        ['t00 PHILLIPS: az aszimmetrikus arsokkok (eps_md / eps_mx) egyik ' ...
        'szcenarioban sincsenek hajtva'], ok, hiba);
    if hajtott
        fprintf(2, ['          %s HAJTVA VAN. A pi_E/pi_D nyers sokkot, a ' ...
            'pi_L AR-folyamatot kap: ez elojel nelkul eltolja a ' ...
            'KKV/nagyvallalat osszevetest. ELOBB SZIMMETRIZALD.\n'], melyik);
    end
end

% --- SZERKEZET-OROK (repo-atrendezes, 2026-08-16) ------------------------
% MIERT KELL. A tobbi or TABLAKAT olvas, nem scripteket futtat -- tehat ha
% egy .mod utvonala eltorik, azok TOVABBRA IS ZOLDEK maradnak. Az
% atrendezes pont ezt a vakfoltot mutatta meg. Ezek az orok a
% FAJLSZERKEZETET orzik.
mo = fullfile(repo, 'src', 'modell');
vonalak = {'1_fo_vonal_jv', '2_referencia_eagle', '3_archiv_korai_jv', '4_app'};
szerk = true;
for i = 1:numel(vonalak)
    szerk = szerk && isfolder(fullfile(mo, vonalak{i})) && ...
        isfile(fullfile(mo, vonalak{i}, 'README.md'));
end
[ok, hiba] = ell(szerk, ...
    't00 SZERKEZET: mind a 4 modell-vonal megvan, README-vel', ok, hiba);

[ok, hiba] = ell(isfile(fullfile(mo, '1_fo_vonal_jv', 'jv_dsge_v09_access.mod')), ...
    't00 SZERKEZET: a FO MODELL a helyen van (1_fo_vonal_jv)', ok, hiba);

% Minden futtato minden dynare-hivasa letezo .mod-ra mutat-e?
modok = dir(fullfile(mo, '**', '*.mod'));
meglevo = string({modok.name});
futtatok = dir(fullfile(mo, '**', 'futtato', '*.m'));
hianyzo = strings(0, 1);
for i = 1:numel(futtatok)
    sz = fileread(fullfile(futtatok(i).folder, futtatok(i).name));
    hivott = regexp(sz, 'dynare\(''([A-Za-z_]\w*)''', 'tokens');
    for j = 1:numel(hivott)
        nev = string(hivott{j}{1}) + ".mod";
        if ~any(meglevo == nev)
            hianyzo(end+1) = string(futtatok(i).name) + " -> " + nev; %#ok<AGROW>
        end
    end
end
[ok, hiba] = ell(isempty(hianyzo), ...
    sprintf(['t00 SZERKEZET: minden futtato letezo .mod-ot hiv ' ...
    '(%d futtato, %d modell)'], numel(futtatok), numel(modok)), ok, hiba);
if ~isempty(hianyzo)
    fprintf('          hianyzo: %s\n', strjoin(hianyzo, ', '));
end

% --- Összegzés ----------------------------------------------------------
fprintf('\nFUSTTESZT: %d rendben, %d hiba\n', ok, hiba);

% --- az orok kiirasa adatkent (az allapotlaphoz) -------------------------
L = table(string({SMOKE_LOG.nev})', double([SMOKE_LOG.rendben])', ...
    'VariableNames', {'or', 'rendben'});
L.idopont(:) = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm'));
writetable(L, fullfile(repo, 'output', 'tables', 't00_orok.csv'));

if hiba > 0
    error('smoke_test: %d ellenorzes megbukott — NE pushold!', hiba);
end
end

function [ok, hiba] = ell(feltetel, nev, ok, hiba)
    global SMOKE_LOG
    SMOKE_LOG(end+1) = struct('nev', string(nev), ...
        'rendben', double(logical(feltetel)));
    if feltetel
        fprintf('  [OK]    %s\n', nev);
        ok = ok + 1;
    else
        fprintf('  [HIBA]  %s\n', nev);
        hiba = hiba + 1;
    end
end

function require_columns_(T, required, label)
missing = setdiff(required, T.Properties.VariableNames, 'stable');
if ~isempty(missing)
    error('smoke_test:elavultBKTabla', ...
        ['%s elavult: hianyzik a(z) %s oszlop. Elobb futtasd ujra a ' ...
        'megfelelo v09 MATLAB-futtatot.'], label, strjoin(missing, ', '));
end
end
