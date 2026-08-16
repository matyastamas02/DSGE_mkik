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
    % A 2. LEPCSO LENYEGE: BK minden kombinacioban teljesul.
    [ok, hiba] = ell(all(S3.konvergalt == 1), ...
        sprintf('t40: mind a %d kombinacio BK-stabil (2. lepcso ATMENT)', ...
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
        sprintf(['t41: mind a %d kombinacio BK-stabil (3. lepcso ATMENT - ' ...
        'az arszint-szetvalasztas nem tori el a JV-magot)'], height(S4)), ok, hiba);
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
    [ok, hiba] = ell(all(A9.konvergalt == 1), ...
        sprintf('t44: mind a %d kombinacio BK-stabil (4. lepcso)', height(A9)), ok, hiba);
    [ok, hiba] = ell(all(abs(A9.rer_pct) < 15) && all(abs(A9.bstar_pct) < 5), ...
        't44: realarfolyam es NFA plauzibilis savban', ok, hiba);
end
t45b = fullfile(repo, 'output', 'tables', 't45b_jv_access_kuszob_osszegzes.csv');
[ok, hiba] = ell(exist(t45b, 'file') == 2, 't45b jv_access kuszob letezik', ok, hiba);
if exist(t45b, 'file') == 2
    Kb = readtable(t45b);
    % NESTING GUARD: ACCSCALE=0 mellett a v09-nek PONTOSAN a v08-at kell adnia.
    [ok, hiba] = ell(Kb.nesting_elteres(1) < 1e-12, ...
        sprintf('t45b NESTING: ACCSCALE=0 == v08 (elteres %.1e)', ...
        Kb.nesting_elteres(1)), ok, hiba);
    % Letezik VEGES kuszob a JV-magon.
    [ok, hiba] = ell(isfinite(Kb.kuszob_KKV_L(1)) && Kb.kuszob_KKV_L(1) > 0, ...
        sprintf('t45b: veges access-kuszob a JV-magon (ACCSCALE=%.1f)', ...
        Kb.kuszob_KKV_L(1)), ok, hiba);
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
    [ok, hiba] = ell(all(O.konvergalt == 1), ...
        sprintf('t47: mind a %d kombinacio BK-stabil (az OPTEN=1 phi_D=0 is)', ...
        height(O)), ok, hiba);
    % SZINT-OR az A01 allitas savjahoz ("+0,3% ... +2,9%"). Ha a sav
    % elmozdul, a tanulmany fo szamat kell atirni -- ne csendben tortenjen.
    gmin = min(O.GDP_pct); gmax = max(O.GDP_pct);
    [ok, hiba] = ell(gmin > 0 && gmin > 0.3 && gmax < 2.95, ...
        sprintf(['t47 SZINT: az aggregalt GDP-sav az A01-ben kozolt ' ...
        '+0,3...+2,9%%-on belul (%.2f%% ... %.2f%%)'], gmin, gmax), ok, hiba);
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
    k0 = Kk.kuszob_KKV_L(Kk.OPTEN == 0);
    k1 = Kk.kuszob_KKV_L(Kk.OPTEN == 1);
    [ok, hiba] = ell(all(isfinite(Kk.kuszob_KKV_L)), ...
        't48b: minden agon letezik veges kuszob', ok, hiba);
    [ok, hiba] = ell(all(Kk.kuszob_D_L < Kk.kuszob_KKV_L) && ...
        all(Kk.kuszob_KKV_L < Kk.kuszob_E_L), ...
        't48b: a kuszob-sorrend D < sulyozott KKV < E minden agon', ok, hiba);
    [ok, hiba] = ell(k1 < k0, ...
        sprintf(['t48b: az empirikus horgony LEVISZI a kuszobot ' ...
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
    [ok, hiba] = ell(all(diff(Rr.kuszob_KKV_L) < 0), ...
        sprintf(['t49b: a kuszob MONOTON csokken a rho_acc-ban ' ...
        '(%.1f -> %.1f)'], Rr.kuszob_KKV_L(1), Rr.kuszob_KKV_L(end)), ok, hiba);
    [ok, hiba] = ell(all(diff(Rr.GDP_pct_ACC100) > 0), ...
        't49b: a GDP-hatas MONOTON no a rho_acc-ban', ok, hiba);
    % A DOKUMENTALT KORLAT ORE: a rho_acc-on a GDP-hatas tulmegy a korabban
    % "robusztus"-nak nevezett +0.27..+1.04% savon. Ha ez az or elhal, valaki
    % visszaallitotta a regi savot -- a szoveget is javitani kell.
    [ok, hiba] = ell(max(Rr.GDP_pct_ACC100) > 1.04, ...
        sprintf(['t49b KORLAT: a horgonyzott rho_acc mellett a GDP-hatas ' ...
        'TULMEGY a korabbi savon (%.2f%% > 1.04%%)'], ...
        max(Rr.GDP_pct_ACC100)), ok, hiba);
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
        'rendben', double(logical(feltetel))); %#ok<AGROW>
    if feltetel
        fprintf('  [OK]    %s\n', nev);
        ok = ok + 1;
    else
        fprintf('  [HIBA]  %s\n', nev);
        hiba = hiba + 1;
    end
end
