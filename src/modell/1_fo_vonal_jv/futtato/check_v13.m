% check_v13.m -- v13: a v12 kiegeszitese (kozos fiskalis blokk, konzisztens kalibracio,
%                nettovagyon-javitas, haztartas, erzekenysegek, elobeallitasok)
% =====================================================================
% Modell: jv_dsge_v13.mod = a jv_dsge_v12.mod (da98d3d) uj kapcsolokkal (munkanev: v12k):
%   -DFISCK=1   kozos fiskalis blokk (a helyi blokk szunet nelkul; ket adossag,
%               tobbeves allampapir, automatikus bevetel + adossagszabaly, a
%               teher egy resze a likviditaskorlatos haztartasokon, a
%               kulfoldiek kamatjovedelme a kulso pozicioban)
%   -DNWKAM=1   a v12 nettovagyon-javitasa (NWFIX) a kotelezettsegek mert
%               felarat hordozo reszere szukitve (alap E 0.5249, D 0.5192,
%               L 0.5073: hitel + kolcson + szallitok + hosszu egyeb, v94)
%   -DSSKONZ=1  konzisztens allandosult allapot: a zeta_j es az aa_j szintje
%               a nemzeti szamlakbol (S11) es a modell sajat makrosulyaibol,
%               az Opten E/D/L aranyaival
%   -DSHLNORM=1|2 a munkasulyok (shl_j, KALIB-osszeg 1.0712) osszege 1:
%               1 = a mert sulyok az osszegukkel osztva, 2 = a modell
%               berkoltseg-hanyadaibol (om*(1-zeta)*aa / osszeg)
%   -DHHB=1     hitelfelvevo haztartas puha hitelkorlattal (haztartas_v96/terv_hhb.md)
%   -DSZOCHO=1  a kozos blokk adossagszabalyanak adoja szochon keresztul (szocho_v99)
%   -DSBAR=1    a felar-atgyuruzes a hitellel rendelkezo cegek tokejere (sbar_v100)
%   -DSIGW, -DNUB, -DEXPEL  erzekenysegi parameterek (erzekenyseg_v101)
%   -DDRULE=1   celpalyas adossagszabaly a kozos blokkban (adossagszabaly_v102)
%   -DLEVKAM=1  a tokeattetel a kamatozo adossagra (levkam_v103)
%   -DHHB=2     torlesztesi korlatos hitelfelvevo haztartas (hhb_jtm_v104)
%   -DSWAPED=1  kiserlet: az E es a D penzugyi parametereinek csereje (csere_v106)
%   -DPRESET=1|2 elobeallitas: kozponti (1), javitott (2) jelolt
% A zarojelben a reszletes meresek munkamappai (codex, nem a repoban).
% A hozzaferesi forma a v12 B-formaja (-DACCFORM=1); ket beallitassal fut:
%   v12:   mu E 0.0051 / D 0.0116, rho_acc 0.85 (a v12 alapertelmezese)
%   helyi: mu 0.005 (nem mert), rho_acc 0.9673 (osszetetel_hozzaferes_lepesek)
%
% ELORE ROGZITETT ELVARASOK:
%   K1  Nesting: az uj kapcsolok nelkul minden palya bitre a v12
%       (max |elteres| = 0).
%   K2  Tiszta teszt: a kozos blokk kulfoldi tulajdon (THETAH = THETAX = 0) es
%       likviditaskorlatos teher (TAXCASH = 0) nelkul nyilvantartas: a v12
%       valtozoinak palyaja valtozatlan (max |elteres| < 1e-9).
%   K3  Reprodukcio: a v11-es alapra visszaallitva (EXPJV=0, NWFIX=0, helyi
%       hozzaferes, HORIZON=800) a helyi Python-megoldo szamai visszajonnek
%       (szuk_blokk_v71/results.json, "Word" oszlopok): fiskalis blokk nelkul,
%       kozos blokk, helyi blokk (FISCPAUSE=32). Tures 0.001 szazalekpont; a
%       tartos ertekeknel 0.005, mert a referencia "tartos" szama a 800
%       negyedeves palya utolso eve, itt a zaro allandosult allapot.
%   K4  BK: a gyokszam- es rangfeltetel mindket rezsimben, minden futasban.
%   K5  Azonossagok a kozos blokkban: adossagegyenlet, egyenleg, GDP
%       (max |maradek| < 1e-10).
%   K6  -DSSKONZ=1 mellett (max |hiba| < 1e-12): az om-sulyozott zeta =
%       ZETABAR; az import a brutto kibocsatasban = sm/(sc+si+sg+sx); a
%       zeta_j es az aa_j E/D/L aranyai a KALIB-eval azonosak; a konzisztens
%       beruhazasi suly (delta/rk*zeta*G, eves felar 0-2%) savja tartalmazza
%       az si-t. Kapcsolo nelkul ugyanez a sav NEM tartalmazza az si-t (ez az
%       ellentmondas, amit a kapcsolo megszuntet).
%   K7  -DSHLNORM (max |hiba| < 1e-12): kapcsolo nelkul az shl_j osszege
%       1.0712; SHLNORM=1 mellett 1, es az E/D/L aranyok a KALIB-eval
%       azonosak; SHLNORM=2 mellett shl_j = om_j*(1-zeta_j)*aa_j / osszeg, a
%       futas sajat (SSKONZ=1 mellett az ujraszamolt) zeta_j es aa_j ertekeibol.
%   K8  -DHHB: (a) -DOMB=0 -DOMNOB=0.25 -DTAXB=0 mellett a kozos valtozok
%       palyaja a v12-e, illetve a FISCK-futase (< 1e-12); (b) a hitelfelvevo
%       koltsegvetesi korlatjanak maradeka < 1e-12; (c) a tartos tobbletadossag
%       d_b - inc_b = -hhp*(sov+bank)/nu_hh (< 1e-8); (d) a tartos adossag a
%       nu_hh-ban csokken (0.00125 > 0.0035 > 0.00625).
%   K9  -DSZOCHO: (a) -DSZD=0 mellett a kozos valtozok palyaja a FISCK-futase
%       (< 1e-12); (b) wf - w = sz_debt*tax_debt/wlc minden idoszakban (< 1e-12);
%       (c) SSKONZ mellett wlc = a K6 munka-jovedelemhanyada (< 1e-12).
%   K10 -DSBAR: -DSBE=-DSBD=-DSBL=1 mellett a palyak a v12-e, illetve a FISCK-futase
%       (< 1e-12); a mert aranyokkal a felarcsokkenes minden tipusnal kisebb.
%   K11 -DSIGW=1.814 -DNUB=0.001 -DEXPEL=0.534/0.493 mellett a palyak a FISCK-futase
%       (< 1e-12; az EXPEL-nel a kerekites miatt < 1e-9).
%   K12 -DDRULE=1: a tartos adossagrata-elteres 0 (< 1e-8), es a tartos allapot
%       FELEZES 20 es 10 mellett azonos (< 1e-8).
%   K13 -DLEVKAM: (a) egyes aranyokkal a palyak a FISCK-futase (< 1e-12); (b) a v12-n
%       a 03_FABLE_JELENTES aranyaival (v78) a 16-20. evi GDP 0.306 (+-0.005).
%   K14 -DHHB=2: (a) -DOMB=0 -DOMNOB=0.25 -DTAXB=0 mellett a kozos valtozok palyaja a
%       v12-e (< 1e-12); (b) a hitelfelvevo korlatjanak maradeka < 1e-12; (c) a tartos
%       tobbletadossag d_b - (w + ll) = -rbe/(r_bss + kap_b) (< 1e-8).
%   K15 Elobeallitasok: -DPRESET=1 es -DPRESET=2 bitre azonos a kiirt kapcsololistaval
%       (max |elteres| = 0); mindket jeloltnel a 16-20. evben a belpiaci KKV (y_D)
%       kibocsatasa no a legjobban, utana a nagyvallalate (y_L), utana az exportalo
%       KKV-e (y_E).
% Idoszakok (mint a check_v12-ben): konvergencia 1-12., kozeptav 21-32.
% negyedev (a belepes utani 3-5. ev), 16-20. ev = 61-80. negyedev, tartos = a
% zaro allandosult allapot. Minden szam elteres az euro nelkuli palyatol.
%
% Kimenet (a repoban output/tables; a repon kivul a futtato melletti eredmeny/ mappa):
%   t69_v13_racs.csv          futasonkent: kapcsolok, BK, fo mutatok, fiskalis mutatok
%   t69b_v13_osszegzes.csv    K1-K15 es a kozolt szamok
%   t69c_v13_reprodukcio.csv  K3: a helyi referencia es a mostani ertek
%   t69d_v13_allandosult.csv  K6: a konzisztens allandosult allapot sulyai
%   t69e_v13_eves_palya.csv   eves palya 2026-2045 a fo futasokra
%   t69f_v13_jeloltek.csv     a jeloltek: GDP, GNI, fogyasztas, E/D/L kibocsatas
%
% Futtatas:
%   matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_v13"
% Kornyezeti valtozok:
%   DSGE_REPO    a DSGE_mkik repo gyokere (a jv_dsge_v12.mod es a
%                bk_check_metrics.m innen jon); nem kell, ha a futtato a repo
%                futtato/ mappajaban van
%   DYNARE_PATH  a Dynare matlab mappaja
%   V13_CACHE=1  a legutobbi futasok betoltese (csak az utofeldolgozashoz)
% A futasok ideiglenes munkamappaban keszulnek, a repoba semmi nem irodik.

check_v13_fo_(fileparts(mfilename('fullpath')));

% =====================================================================
function check_v13_fo_(itt)
% A torzs fuggvenyben van, mert a Dynare a parametereket az alap munkaterulet
% valtozoikent is beirja (pl. sc, pg), es azok a szkript valtozoit felulirnak.

% --- utvonalak --------------------------------------------------------------------------
repo = getenv('DSGE_REPO');
if isempty(repo)
    repo = itt;
    while ~isfile(fullfile(repo, 'CLAUDE.md')) || ~isfolder(fullfile(repo, 'src', '4_infra'))
        szulo = fileparts(repo);
        if strcmp(szulo, repo)
            error('Nem talalom a DSGE_mkik repot: allitsd be a DSGE_REPO kornyezeti valtozot.');
        end
        repo = szulo;
    end
end
moddir = fullfile(repo, 'src', 'modell', '1_fo_vonal_jv');
assert(isfile(fullfile(moddir, 'jv_dsge_v12.mod')), 'Nincs jv_dsge_v12.mod itt: %s', moddir);
kmod = fullfile(itt, 'jv_dsge_v13.mod');
if ~isfile(kmod), kmod = fullfile(fileparts(itt), 'jv_dsge_v13.mod'); end
assert(isfile(kmod), 'Nem talalom a jv_dsge_v13.mod fajlt.');
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path)
    jel = {'C:\dynare\6.5\matlab', '/Applications/Dynare/7.2-arm64/matlab'};
    dynare_path = jel(cellfun(@isfolder, jel));
    assert(~isempty(dynare_path), 'Nem talalom a Dynare-t: add meg a DYNARE_PATH kornyezeti valtozoban.'); dynare_path = dynare_path{1};
end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
if startsWith(itt, repo), tab = fullfile(repo, 'output', 'tables');
else, tab = fullfile(itt, 'eredmeny'); end
if ~isfolder(tab), mkdir(tab); end
munka = fullfile(tempdir, 'check_v13_munka');
if ~isfolder(munka), mkdir(munka); end
copyfile(fullfile(moddir, 'jv_dsge_v12.mod'), munka);
copyfile(kmod, munka);
vissza = onCleanup(@() cd(itt));
cd(munka);

M12 = 'jv_dsge_v12'; MK = 'jv_dsge_v13';
FK = {'-DFISCK=1'}; NK = {'-DNWKAM=1'};
HELYI = {'-DACCMUE=0.005', '-DACCMUD=0.005', '-DRHOACC=0.9673'};
V11 = [HELYI, {'-DEXPJV=0', '-DNWFIX=0', '-DHORIZON=800'}];      % a helyi referencia alapja
% a v12 sajat fiskalis blokkja a helyi szamokkal ("harmonizalt"), osszevetesre
th = 0.2227*0.706 + 0.968*0.294; rm = 0.706*0.918 + 0.294*0.972;
HARM = {'-DFISCAL=1', '-DBBARG=2.7737', '-DRGBAR=1.013', sprintf('-DTHETAF=%.10g', th), ...
        sprintf('-DRHOM=%.10g', rm), sprintf('-DPHIB=%.10g', 1.013 - 2^(-1/20))};

% a jeloltek kozos resze (a PRESET 1 es 2 kapcsololistaja, lasd a .mod 13. pontjat)
K0 = {'-DSSKONZ=1', '-DFISCK=1', '-DKAPX=0.38', '-DGAPHX=0.0031', '-DGAPINF=0.00125'};

% --- futasok ----------------------------------------------------------------------------
% {nev, modell, kapcsolok}
F = {
    'v12',            M12, {}
    'k_ki',           MK,  {}
    'k_tiszta',       MK,  [FK, {'-DTHETAH=0', '-DTHETAX=0', '-DTAXCASH=0'}]
    % --- a v12 hozzaferesevel ---
    'k_fisc',         MK,  FK
    'k_nwk',          MK,  NK
    'k_fisc_nwk',     MK,  [FK, NK]
    'k_fisc_szunet',  MK,  [FK, {'-DFISCPAUSE=32'}]
    'v12_harm',       M12, HARM
    % --- a helyi hozzaferessel ---
    'h_ki',           MK,  HELYI
    'h_fisc',         MK,  [HELYI, FK]
    'h_nwk',          MK,  [HELYI, NK]
    'h_fisc_nwk',     MK,  [HELYI, FK, NK]
    % --- reprodukcio a v11-es alapon (K3) ---
    'ref_nincs',      MK,  V11
    'ref_kozos',      MK,  [V11, FK]
    'ref_helyi',      MK,  [V11, FK, {'-DFISCPAUSE=32'}]
    % --- konzisztens allandosult allapot (K6) ---
    's_konz',         MK,  {'-DSSKONZ=1'}
    's_konz_fisc',    MK,  {'-DSSKONZ=1', '-DFISCK=1'}
    's_konz_nwk',     MK,  {'-DSSKONZ=1', '-DNWKAM=1'}
    's_konz_fisc_nwk', MK, {'-DSSKONZ=1', '-DFISCK=1', '-DNWKAM=1'}
    's_konz_zeta213', MK,  {'-DSSKONZ=1', '-DZETABAR=0.213'}
    's_konz_zeta245', MK,  {'-DSSKONZ=1', '-DZETABAR=0.245'}
    's_konz_imp464',  MK,  {'-DSSKONZ=1', '-DIMPQ=0.464'}
    % --- munkasulyok (K7) ---
    'w_shl1',         MK,  {'-DSHLNORM=1'}
    'w_shl2',         MK,  {'-DSHLNORM=2'}
    'w_konz_shl1',    MK,  {'-DSSKONZ=1', '-DSHLNORM=1'}
    'w_konz_shl2',    MK,  {'-DSSKONZ=1', '-DSHLNORM=2'}
    % --- hitelfelvevo haztartas (K8) ---
    'b_nul',          MK,  {'-DHHB=1', '-DOMB=0', '-DOMNOB=0.25', '-DTAXB=0'}
    'b_nul_fisc',     MK,  [FK, {'-DHHB=1', '-DOMB=0', '-DOMNOB=0.25', '-DTAXB=0'}]
    'b_hhb',          MK,  {'-DHHB=1'}
    'b_hhb_fisc',     MK,  [FK, {'-DHHB=1'}]
    'b_hhb_nu1',      MK,  [FK, {'-DHHB=1', '-DNUHH=0.00125'}]
    'b_hhb_nu6',      MK,  [FK, {'-DHHB=1', '-DNUHH=0.00625'}]
    % --- visszaadas szochon keresztul (K9) ---
    'z_nul',          MK,  [FK, {'-DSZOCHO=1', '-DSZD=0'}]
    'z_szo',          MK,  [FK, {'-DSZOCHO=1'}]
    'z_szo_konz',     MK,  [FK, {'-DSZOCHO=1', '-DSSKONZ=1'}]
    % --- felar-atgyuruzes a hiteles cegek tokejere (K10) ---
    's_egy',          MK,  {'-DSBAR=1', '-DSBE=1', '-DSBD=1', '-DSBL=1'}
    's_egy_fisc',     MK,  [FK, {'-DSBAR=1', '-DSBE=1', '-DSBD=1', '-DSBL=1'}]
    's_sbar',         MK,  {'-DSBAR=1'}
    % --- erzekenysegi parameterek (K11) ---
    'p_nest',         MK,  [FK, {'-DSIGW=1.814', '-DNUB=0.001'}]
    'p_expel',        MK,  [FK, {sprintf('-DEXPEL=%.15g', 0.534/0.493)}]
    % --- celpalyas adossagszabaly (K12) ---
    'r_cel',          MK,  [FK, {'-DDRULE=1'}]
    'r_cel_f10',      MK,  [FK, {'-DDRULE=1', '-DFELEZES=10'}]
    % --- tokeattetel a kamatozo adossagra (K13) ---
    'l_egy',          MK,  [FK, {'-DLEVKAM=1', '-DLVE=1', '-DLVD=1', '-DLVL=1'}]
    'l_fable',        MK,  {'-DLEVKAM=1', '-DLVE=0.1897', '-DLVD=0.1627', '-DLVL=0.1397'}
    % --- torlesztesi korlatos hitelfelvevo (K14) ---
    'j_nul',          MK,  {'-DHHB=2', '-DOMB=0', '-DOMNOB=0.25', '-DTAXB=0'}
    'j_hhb_fisc',     MK,  [FK, {'-DHHB=2'}]
    % --- a kozos blokk erzekenysege (v12 hozzaferes) ---
    'e_chi0',         MK,  [FK, {'-DTAXCASH=0'}]
    'e_chi50',        MK,  [FK, {'-DTAXCASH=0.5'}]
    'e_thetah1225',   MK,  [FK, {'-DTHETAH=0.1225'}]
    'e_thetah30',     MK,  [FK, {'-DTHETAH=0.30'}]
    'e_kapx0',        MK,  [FK, {'-DKAPX=0'}]
    'e_kapx50',       MK,  [FK, {'-DKAPX=0.5'}]
    'e_nincsres',     MK,  [FK, {'-DGAPHX=0', '-DGAPINF=0'}]
    'e_felezes10',    MK,  [FK, {'-DFELEZES=10'}]
    'e_felezes40',    MK,  [FK, {'-DFELEZES=40'}]
    'e_nincselore',   MK,  [FK, {'-DRHONH=0', '-DRHONX=0'}]
    % --- a jeloltek (K15, t69f) ---
    'j1_preset',      MK,  {'-DPRESET=1'}
    'j1_kezi',        MK,  [K0, NK]
    'j2_preset',      MK,  {'-DPRESET=2'}
    'j2_kezi',        MK,  [K0, {'-DLEVKAM=1', '-DDRULE=1', '-DSBAR=1', '-DNUB=0.0025'}]
    'j2_sigw06',      MK,  {'-DPRESET=2', '-DSIGW=0.6'}
    'j2_szocho',      MK,  {'-DPRESET=2', '-DSZOCHO=1'}
    'j2_swaped',      MK,  {'-DPRESET=2', '-DSWAPED=1'}
    };
gyorsitotar = fullfile(tempdir, 'check_v13_futasok.mat');
if strcmp(getenv('V13_CACHE'), '1') && isfile(gyorsitotar)
    load(gyorsitotar, 'R');
else
    R = struct();
    for i = 1:size(F, 1)
        fprintf('\n=== %2d / %d  %s  %s\n', i, size(F, 1), F{i, 1}, strjoin(F{i, 3}, ' '));
        R.(F{i, 1}) = fut_(F{i, 2}, F{i, 3});
    end
    save(gyorsitotar, 'R');
end
nevek = F(:, 1);
hibas = nevek(cellfun(@(n) R.(n).ok ~= 1, nevek));
assert(isempty(hibas), 'Sikertelen futas: %s', strjoin(hibas, ', '));

% --- K1, K2 -----------------------------------------------------------------------------
k1 = elteres_(R.k_ki, R.v12);
k2 = elteres_(R.k_tiszta, R.v12);
fprintf('\nK1 %.3g  K2 %.3g\n', k1, k2);

% --- mutatok ----------------------------------------------------------------------------
Mt = struct();
for i = 1:numel(nevek), Mt.(nevek{i}) = mutat_(R.(nevek{i})); end

% --- K3: a helyi referencia (szuk_blokk_v71/results.json, Word-oszlopok) ----------------
% {futas, mutato, referencia}
C = {
    'ref_nincs', 'GDPkozep',  0.200545
    'ref_nincs', 'Ckozep',   -0.111832
    'ref_nincs', 'yEkozep',   0.025515
    'ref_nincs', 'yDkozep',   0.485529
    'ref_nincs', 'GDP1620',   0.213449
    'ref_nincs', 'GDPtartos', 0.168067
    'ref_kozos', 'GDPkozep',  0.280848
    'ref_kozos', 'Ckozep',    0.437537
    'ref_kozos', 'yEkozep',   0.083727
    'ref_kozos', 'yDkozep',   0.782466
    'ref_kozos', 'fsav_k',    0.675841
    'ref_kozos', 'gain_k',    0.188735
    'ref_kozos', 'szabaly_k', -0.299879
    'ref_kozos', 'egyenleg_k', 0.646765
    'ref_kozos', 'adossag_k', -2.544965
    'ref_kozos', 'GDP1620',   0.322557
    'ref_kozos', 'GDPtartos', 0.293271
    'ref_kozos', 'adossag_t', -7.148469
    'ref_kozos', 'fsav_t',    0.827079
    'ref_helyi', 'GDPkozep',  0.266121
    'ref_helyi', 'Ckozep',    0.279622
    'ref_helyi', 'yEkozep',   0.072766
    'ref_helyi', 'yDkozep',   0.730266
    'ref_helyi', 'szabaly_k', 0.0
    'ref_helyi', 'egyenleg_k', 0.976061
    'ref_helyi', 'adossag_k', -3.316630
    'ref_helyi', 'GDP1620',   0.325001
    };
T3 = cell2table(C, 'VariableNames', {'futas', 'mutato', 'referencia'});
T3.mienk = cellfun(@(f, m) Mt.(f).(m), T3.futas, T3.mutato);
T3.elteres = T3.mienk - T3.referencia;
tures = 1e-3 + 4e-3*(endsWith(T3.mutato, '_t') | endsWith(T3.mutato, 'tartos'));
T3.ok = double(abs(T3.elteres) <= tures);
writetable(T3, fullfile(tab, 't69c_v13_reprodukcio.csv'));
fprintf('K3: %d / %d egyezik (max |elteres| %.2g)\n', sum(T3.ok), height(T3), max(abs(T3.elteres)));

% --- K5: azonossagok a kozos blokkban ---------------------------------------------------
k5 = 0;
for n = {'k_fisc', 'h_fisc', 'k_fisc_szunet'}
    k5 = max(k5, azonossag_(R.(n{1})));
end
fprintf('K5 %.3g\n', k5);

% --- K6: a konzisztens allandosult allapot azonossagai -------------------------------
a0 = ssmutat_(R.v12); a1 = ssmutat_(R.s_konz);
k6 = max(abs([a1.zetabar - 0.233, a1.imp - a1.impmakro, ...
    a1.zeta/a1.zeta(3) - a0.zeta/a0.zeta(3), a1.aa/a1.aa(3) - a0.aa/a0.aa(3)]));
k6sav = a1.si_konz(1) <= a1.si && a1.si <= a1.si_konz(2);
k6regi = a0.si_konz(1) <= a0.si && a0.si <= a0.si_konz(2);
fprintf('K6 %.3g  si a savban: SSKONZ %d, v12 %d\n', k6, k6sav, k6regi);
SSt = table(["v12"; "SSKONZ"], [a0.zetabar; a1.zetabar], [a0.zeta; a1.zeta], [a0.aa; a1.aa], [a0.imp; a1.imp], ...
    [a0.impmakro; a1.impmakro], [a0.tokeGDP; a1.tokeGDP], [a0.si; a1.si], [a0.si_konz; a1.si_konz], [a0.munka; a1.munka], ...
    'VariableNames', {'kalibracio', 'zeta_atlag', 'zeta_EDL', 'aa_EDL', 'import_per_brutto', 'import_per_brutto_makro', ...
    'toke_GDP_hozzajarulas', 'si', 'si_konzisztens_sav', 'munka_jovedelemhanyad'});
writetable(SSt, fullfile(tab, 't69d_v13_allandosult.csv'));
disp(SSt);

% --- K7: a munkasulyok ------------------------------------------------------------------
sl = @(x) [x.p('shl_E') x.p('shl_D') x.p('shl_L')];
sk = @(x) [x.p('om_E')*(1-x.p('zeta_E'))*x.p('aa_E'), x.p('om_D')*(1-x.p('zeta_D'))*x.p('aa_D'), ...
           x.p('om_L')*(1-x.p('zeta_L'))*x.p('aa_L')];
w0 = sl(R.v12);
k7 = max(abs([sum(w0) - 1.0712, ...
    sum(sl(R.w_shl1)) - 1, sl(R.w_shl1) - w0/sum(w0), sum(sl(R.w_konz_shl1)) - 1, sl(R.w_konz_shl1) - w0/sum(w0), ...
    sl(R.w_shl2) - sk(R.w_shl2)/sum(sk(R.w_shl2)), sl(R.w_konz_shl2) - sk(R.w_konz_shl2)/sum(sk(R.w_konz_shl2))]));
fprintf('K7 %.3g  (shl_j: v12 %s; SHLNORM=1 %s; SHLNORM=2 %s; SSKONZ+2 %s)\n', k7, mat2str(w0, 4), ...
    mat2str(sl(R.w_shl1), 4), mat2str(sl(R.w_shl2), 4), mat2str(sl(R.w_konz_shl2), 4));

% --- K8: hitelfelvevo haztartas ---------------------------------------------------
k8a = max(elteres_(R.b_nul, R.v12), elteres_(R.b_nul_fisc, R.k_fisc));
k8b = 0; k8c = 0;
for n = {'b_hhb', 'b_hhb_fisc', 'b_hhb_nu1', 'b_hhb_nu6'}
    x = R.(n{1}); p = x.p; tt = 2:size(x.S, 2) - 1;
    k8b = max(k8b, max(abs(p('x_b')*x.pa('d_b', tt) - (p('x_b')*(1+p('r_bss'))*x.pa('d_b', tt-1) ...
        + p('x_b')*(x.pa('rbe', tt-1) - x.pa('infl', tt)) + x.pa('c_b', tt) - (1+p('r_bss')*p('x_b'))*x.pa('inc_b', tt)))));
    k8c = max(k8c, abs(x.ss('d_b') - x.ss('inc_b') + p('hhp_b')*(x.xs('sov') + x.xs('bank'))/p('nu_hh')));
end
k8d = R.b_hhb_nu1.ss('d_b') > R.b_hhb_fisc.ss('d_b') && R.b_hhb_fisc.ss('d_b') > R.b_hhb_nu6.ss('d_b');
fprintf('K8 %.3g / %.3g / %.3g / monoton %d\n', k8a, k8b, k8c, k8d);
k8ok = k8a < 1e-12 && k8b < 1e-12 && k8c < 1e-8 && k8d;

% --- K9: visszaadas szochon keresztul --------------------------------------------
k9a = elteres_(R.z_nul, R.k_fisc); k9b = 0;
for n = {'z_szo', 'z_szo_konz'}
    x = R.(n{1}); t = 1:size(x.S, 2);
    k9b = max(k9b, max(abs(x.pa('wf', t) - x.pa('w', t) - x.p('sz_debt')*x.pa('tax_debt', t)/x.p('wlc'))));
end
k9c = abs(R.z_szo_konz.p('wlc') - ssmutat_(R.z_szo_konz).munka);
fprintf('K9 %.3g / %.3g / %.3g\n', k9a, k9b, k9c);
k9ok = k9a < 1e-12 && k9b < 1e-12 && k9c < 1e-12;

% --- K10: felar-atgyuruzes a hiteles cegek tokejere --------------------------------
k10a = max(elteres_(R.s_egy, R.v12), elteres_(R.s_egy_fisc, R.k_fisc));
k10b = all(arrayfun(@(j) abs(Mt.s_sbar.(['efp' j 'kozep'])) < abs(Mt.v12.(['efp' j 'kozep'])), 'EDL'));
fprintf('K10 %.3g  kisebb felarcsokkenes %d\n', k10a, k10b);
k10ok = k10a < 1e-12 && k10b;

% --- K11: erzekenysegi parameterek -------------------------------------------------
k11a = elteres_(R.p_nest, R.k_fisc); k11b = elteres_(R.p_expel, R.k_fisc);
fprintf('K11 %.3g / %.3g\n', k11a, k11b);
k11ok = k11a < 1e-12 && k11b < 1e-9;

% --- K12: celpalyas adossagszabaly ------------------------------------------------
kozn = R.r_cel.nev(~startsWith(R.r_cel.nev, 'AUX_'));
ssd = max(abs(cellfun(@(v) R.r_cel.ss(v) - R.r_cel_f10.ss(v), kozn)));
k12a = abs(R.r_cel.ss('bgy_ratio')); k12b = ssd;
fprintf('K12 %.3g / %.3g\n', k12a, k12b);
k12ok = k12a < 1e-8 && k12b < 1e-8;

% --- K13: tokeattetel a kamatozo adossagra ----------------------------------------
k13a = elteres_(R.l_egy, R.k_fisc); k13b = Mt.l_fable.GDP1620;
fprintf('K13 %.3g / GDP 16-20 %.4f (Fable 0.306)\n', k13a, k13b);
k13ok = k13a < 1e-12 && abs(k13b - 0.306) < 0.005;

% --- K14: torlesztesi korlatos hitelfelvevo ---------------------------------------
k14a = elteres_(R.j_nul, R.v12);
x = R.j_hhb_fisc; p = x.p; tt = 2:size(x.S, 2) - 1;
k14b = max(abs(p('x_b')*x.pa('d_b', tt) - (p('x_b')*(1+p('r_bss'))*x.pa('d_b', tt-1) ...
    + p('x_b')*(x.pa('rbe', tt-1) - x.pa('infl', tt)) + x.pa('c_b', tt) - (1+p('r_bss')*p('x_b'))*x.pa('inc_b', tt))));
k14c = abs(x.ss('d_b') - x.ss('w') - x.ss('ll') + x.ss('rbe')/(p('r_bss') + p('kap_b')));
fprintf('K14 %.3g / %.3g / %.3g\n', k14a, k14b, k14c);
k14ok = k14a < 1e-12 && k14b < 1e-12 && k14c < 1e-8;

% --- racs: futasonkent ------------------------------------------------------------------
G = table();
for i = 1:numel(nevek)
    x = R.(nevek{i}); m = Mt.(nevek{i});
    erv = double(x.ok == 1 && x.B.check_ok == 1 && x.B.bk_ok == 1 && x.B0.check_ok == 1 && x.B0.bk_ok == 1);
    G = [G; table(string(nevek{i}), string(strjoin(F{i, 3}, ' ')), x.ok, erv, ...
        x.B0.n_unstable, x.B.n_unstable, x.B.n_forward, ...
        m.GDPkonv, m.GDPkozep, m.GDP1620, m.GDPtartos, m.Ckozep, m.Ctartos, ...
        m.yEkozep, m.yDkozep, m.yLkozep, m.yE1620, m.yD1620, m.yL1620, ...
        m.efpEkozep, m.efpDkozep, m.efpLkozep, ...
        m.fsav_k, m.gain_k, m.auto_k, m.szabaly_k, m.egyenleg_k, m.adossag_k, ...
        m.fsav_t, m.egyenleg_t, m.adossag_t, ...
        'VariableNames', {'futas', 'kapcsolok', 'solver_ok', 'ervenyes', ...
        'instabil_kezdeti', 'instabil_zaro', 'eloretekinto', ...
        'GDP_konv_pct', 'GDP_kozep_pct', 'GDP_1620_pct', 'GDP_tartos_pct', 'C_kozep_pct', 'C_tartos_pct', ...
        'yE_kozep_pct', 'yD_kozep_pct', 'yL_kozep_pct', 'yE_1620_pct', 'yD_1620_pct', 'yL_1620_pct', ...
        'felar_E_kozep_bp', 'felar_D_kozep_bp', 'felar_L_kozep_bp', ...
        'kamatmegtakaritas_kozep', 'kulfoldi_resz_kozep', 'automatikus_bevetel_kozep', ...
        'adossagszabaly_kozep', 'egyenleg_kozep', 'adossagrata_kozep', ...
        'kamatmegtakaritas_tartos', 'egyenleg_tartos', 'adossagrata_tartos'})]; %#ok<AGROW>
end
writetable(G, fullfile(tab, 't69_v13_racs.csv'));

% --- eves palya -------------------------------------------------------------------------
E = table();
for n = {'v12', 'k_fisc', 'k_fisc_nwk', 'h_fisc', 'h_fisc_nwk'}
    x = R.(n{1});
    for ev = 0:19
        t = 4*ev + (2:5);
        sor = table(string(n{1}), 2026 + ev, 'VariableNames', {'futas', 'ev'});
        for v = {'y', 'c', 'ii', 'y_E', 'y_D', 'y_L', 'fsav', 'gainf', 'tax_auto', 'tax_debt', 'pb', 'bal', 'bgy_ratio'}
            if x.van(v{1}), sor.(v{1}) = 100*mean(x.pa(v{1}, t)); else, sor.(v{1}) = NaN; end
        end
        E = [E; sor]; %#ok<AGROW>
    end
end
writetable(E, fullfile(tab, 't69e_v13_eves_palya.csv'));

% --- K15: elobeallitasok, a jeloltek (t69f) ----------------------------------------------
k15a = max(elteres_(R.j1_preset, R.j1_kezi), elteres_(R.j2_preset, R.j2_kezi));
J = table(); jn = {'v12', 'j1_preset', 'j2_preset', 'j2_sigw06', 'j2_szocho', 'j2_swaped'};
for i = 1:numel(jn)
    x = R.(jn{i}); g = @(v, t) 100*mean(x.pa(v, t)); f = @(v) 100*x.ss(v);
    be = x.p('beta'); tt = 2:size(x.S, 2);
    if x.van('fpay'), fp = x.pa('fpay', tt); fps = x.ss('fpay'); else, fp = 0*tt; fps = 0; end
    gni = x.pa('y', tt) + (1/be - 1)*x.pa('bstar', tt - 1) - fp; gn = @(t) 100*mean(gni(t - 1));
    gnt = 100*(x.ss('y') + (1/be - 1)*x.ss('bstar') - fps);
    J = [J; table(string(jn{i}), string(strjoin(F{strcmp(F(:, 1), jn{i}), 3}, ' ')), ...
        g('y', 22:33), gn(22:33), g('c', 22:33), g('y_E', 22:33), g('y_D', 22:33), g('y_L', 22:33), ...
        g('y', 62:81), gn(62:81), g('c', 62:81), g('y_E', 62:81), g('y_D', 62:81), g('y_L', 62:81), ...
        f('y'), gnt, f('c'), f('y_E'), f('y_D'), f('y_L'), ...
        'VariableNames', {'futas', 'kapcsolok', 'GDP_kozep', 'GNI_kozep', 'C_kozep', 'yE_kozep', 'yD_kozep', 'yL_kozep', ...
        'GDP_1620', 'GNI_1620', 'C_1620', 'yE_1620', 'yD_1620', 'yL_1620', ...
        'GDP_tartos', 'GNI_tartos', 'C_tartos', 'yE_tartos', 'yD_tartos', 'yL_tartos'})]; %#ok<AGROW>
end
writetable(J, fullfile(tab, 't69f_v13_jeloltek.csv'));
disp(J(:, [1 9:20]));
sor = @(n) J(strcmp(J.futas, n), :);
k15b = all(arrayfun(@(i) J.yD_1620(i) > J.yL_1620(i) && J.yL_1620(i) > J.yE_1620(i), ...
    find(ismember(J.futas, {'j1_preset', 'j2_preset'}))));
fprintf('K15 %.3g  sorrend D > L > E %d\n', k15a, k15b);
k15ok = k15a == 0 && k15b;

% --- osszegzes --------------------------------------------------------------------------
O = table();
O.K1_nest_maxdiff = k1; O.K2_tiszta_maxdiff = k2;
O.K3_egyezik = sum(T3.ok); O.K3_ossz = height(T3); O.K3_max_elteres = max(abs(T3.elteres));
O.K4_BK_db = sum(G.ervenyes == 1); O.K4_BK_ossz = height(G);
O.K5_azonossag_maxhiba = k5;
O.K6_ss_maxhiba = k6; O.K6_si_a_savban_SSKONZ = double(k6sav); O.K6_si_a_savban_v12 = double(k6regi);
O.K7_munkasuly_maxhiba = k7;
O.K8_nesting = k8a; O.K8_korlat_maradek = k8b; O.K8_tartos_adossag_hiba = k8c; O.K8_monoton = double(k8d);
O.K9_nesting = k9a; O.K9_ek_hiba = k9b; O.K9_wlc_hiba = k9c;
O.K10_nesting = k10a; O.K10_kisebb_felar = double(k10b);
O.K11_nesting = k11a; O.K11_expel = k11b;
O.K12_adossagrata = k12a; O.K12_felezes_fuggetlen = k12b;
O.K13_nesting = k13a; O.K13_fable_GDP1620 = k13b;
O.K14_nesting = k14a; O.K14_korlat_maradek = k14b; O.K14_tartos_adossag_hiba = k14c;
O.K15_preset_maxdiff = k15a; O.K15_sorrend = double(k15b);
for n = {'j1_preset', 'j2_preset', 'j2_sigw06', 'j2_szocho', 'j2_swaped'}
    s = sor(n{1}); b = strrep(n{1}, '_preset', '');
    for v = {'GDP_1620', 'GNI_1620', 'C_1620', 'yE_1620', 'yD_1620', 'yL_1620', 'C_tartos', 'GDP_kozep'}
        O.([b '_' v{1}]) = s.(v{1});
    end
end
for n = {'v12', 'k_fisc', 'k_nwk', 'k_fisc_nwk', 'v12_harm', 'h_ki', 'h_fisc', 'h_fisc_nwk', ...
         's_konz', 's_konz_fisc', 's_konz_nwk', 's_konz_fisc_nwk', 'w_shl1', 'w_shl2', 'w_konz_shl1', 'w_konz_shl2', 'b_hhb', 'b_hhb_fisc', 'z_szo', 'z_szo_konz', 's_sbar'}
    m = Mt.(n{1});
    O.([n{1} '_GDP_kozep_pct']) = m.GDPkozep; O.([n{1} '_GDP_1620_pct']) = m.GDP1620;
    O.([n{1} '_GDP_tartos_pct']) = m.GDPtartos;
    O.([n{1} '_yE_kozep_pct']) = m.yEkozep; O.([n{1} '_yD_kozep_pct']) = m.yDkozep;
end
% a ket uj kapcsolo hatasa a v12-n (szazalekpont)
O.fisck_GDP_kozep_pp = Mt.k_fisc.GDPkozep - Mt.v12.GDPkozep;
O.fisck_GDP_1620_pp = Mt.k_fisc.GDP1620 - Mt.v12.GDP1620;
O.nwkam_GDP_kozep_pp = Mt.k_nwk.GDPkozep - Mt.v12.GDPkozep;
O.nwkam_GDP_1620_pp = Mt.k_nwk.GDP1620 - Mt.v12.GDP1620;
O.kozos_kamatmegtakaritas_kozep = Mt.k_fisc.fsav_k; O.kozos_kamatmegtakaritas_tartos = Mt.k_fisc.fsav_t;
O.kozos_adossagrata_kozep = Mt.k_fisc.adossag_k; O.kozos_adossagrata_tartos = Mt.k_fisc.adossag_t;
e = nevek(startsWith(nevek, 'e_'));
g = cellfun(@(n) Mt.(n).GDPkozep, e);
O.kozos_GDP_kozep_erzekenyseg_min = min(g); O.kozos_GDP_kozep_erzekenyseg_max = max(g);
writetable(O, fullfile(tab, 't69b_v13_osszegzes.csv'));
disp(rows2vars(O));

k6ok = k6 < 1e-12 && k6sav && ~k6regi;
rendben = k1 == 0 && k2 < 1e-9 && all(T3.ok == 1) && all(G.ervenyes == 1) && k5 < 1e-10 && k6ok && k7 < 1e-12 && k8ok && k9ok && k10ok && k11ok && k12ok && k13ok && k14ok && k15ok;
fprintf('\nK1 %d  K2 %d  K3 %d  K4 %d  K5 %d  K6 %d  K7 %d  K8 %d  K9 %d  K10 %d  K11 %d  K12 %d  K13 %d  K14 %d  K15 %d  ->  %s\nKimenet: %s\n', k1 == 0, k2 < 1e-9, ...
    all(T3.ok == 1), all(G.ervenyes == 1), k5 < 1e-10, k6ok, k7 < 1e-12, k8ok, k9ok, k10ok, k11ok, k12ok, k13ok, k14ok, k15ok, char(string(rendben)), tab);
assert(rendben, 'Legalabb egy elvaras (K1-K15) nem teljesult -- lasd fent.');
end

% =====================================================================
function R = fut_(modell, args)
% Egy futas a megadott kapcsolokkal; BK mindket rezsimben (kezdeti es zaro).
R = struct('ok', 0, 'B', [], 'B0', [], 'S', [], 'nev', {{}}, 'p', [], 'ss', [], 'pa', [], 'van', [], 'xs', []);
try
    dynare(modell, args{:}, 'console', 'nograph', 'nolog');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    R.ok = double(oo.deterministic_simulation.status == 1);
    R.B = bk_check_metrics(M, op, oo);
    oo0 = oo; oo0.steady_state(:) = 0; oo0.exo_steady_state(:) = 0;
    if isfield(oo0, 'exo_det_steady_state'), oo0.exo_det_steady_state(:) = 0; end
    R.B0 = bk_check_metrics(M, op, oo0);
    R.nev = cellstr(M.endo_names); R.S = oo.endo_simul; pn = cellstr(M.param_names);
    pv = M.params; ssv = oo.steady_state; n = R.nev; S = R.S;
    R.p   = @(x) pv(strcmp(pn, x));
    R.ss  = @(x) ssv(strcmp(n, x));
    R.pa  = @(x, t) S(strcmp(n, x), t);
    R.van = @(x) any(strcmp(n, x));
    xn = cellstr(M.exo_names); xsv = oo.exo_steady_state; R.xs = @(x) xsv(strcmp(xn, x));
catch ME
    fprintf(2, '  !! HIBA (%s %s): %s\n', modell, strjoin(args, ' '), ME.message);
end
end

function m = mutat_(R)
% Szintek: % (kibocsatas, fogyasztas), bp/ev (felar), a GDP %-a (fiskalis
% tetelek negyedeves aramlasa), az eves GDP szazalekpontja (adossagrata).
konv = 2:13; kozep = 22:33; ab = 62:81;
a = @(x, t) 100*mean(R.pa(x, t)); f = @(x) 100*R.ss(x);
m.GDPkonv = a('y', konv); m.GDPkozep = a('y', kozep); m.GDP1620 = a('y', ab); m.GDPtartos = f('y');
m.Ckozep = a('c', kozep); m.Ctartos = f('c');
for j = 'EDL'
    m.(['y' j 'kozep']) = a(['y_' j], kozep); m.(['y' j '1620']) = a(['y_' j], ab);
    m.(['efp' j 'kozep']) = 40000*mean(R.pa(['efp_' j], kozep));
end
fn = {'fsav', 'fsav'; 'gain', 'gainf'; 'auto', 'tax_auto'; 'szabaly', 'tax_debt'; 'egyenleg', 'bal'; 'adossag', 'bgy_ratio'};
for i = 1:size(fn, 1)
    if R.van(fn{i, 2})
        m.([fn{i, 1} '_k']) = a(fn{i, 2}, kozep); m.([fn{i, 1} '_t']) = f(fn{i, 2});
    else
        m.([fn{i, 1} '_k']) = NaN; m.([fn{i, 1} '_t']) = NaN;
    end
end
end

function a = ssmutat_(R)
% Az allandosult allapot sulyai a futas parametereibol.
p = R.p; om = [p('om_E') p('om_D') p('om_L')]; om = om/sum(om);
a.zeta = [p('zeta_E') p('zeta_D') p('zeta_L')]; a.aa = [p('aa_E') p('aa_D') p('aa_L')];
G = p('sc') + p('si') + p('sg') + p('sx');                 % brutto ertekesites / GDP
a.zetabar = om*a.zeta'; a.imp = om*((1-a.zeta).*(1-a.aa))'; a.impmakro = p('sm')/G;
a.tokeGDP = a.zetabar*G; a.si = p('si'); a.munka = G*(om*((1-a.zeta).*a.aa)');
r = 1/p('beta') - 1; d = p('delta');
a.si_konz = [d/(r + d + 0.005), d/(r + d)]*a.tokeGDP;      % eves felar 2% es 0%
end

function d = elteres_(A, B)
% Max |elteres| a B (a v12) valtozoin; a segedvaltozok nelkul.
kozos = B.nev(~startsWith(B.nev, 'AUX_'));
[van, ia] = ismember(kozos, A.nev); [~, ib] = ismember(kozos, B.nev);
if ~all(van) || size(A.S, 2) ~= size(B.S, 2), d = NaN; return; end
d = max(abs(A.S(ia, :) - B.S(ib, :)), [], 'all');
end

function h = azonossag_(R)
% A kozos blokk azonossagainak legnagyobb maradeka a szimulacios idoszakban.
T = size(R.S, 2) - 1; t = 2:T; l = t - 1;                 % t: idoszak, l: az elozo
x = @(v) R.pa(v, t); xl = @(v) R.pa(v, l); p = R.p;
h1 = x('bg') - (p('qbar')*xl('bg') + x('inth') + x('intx') + p('qbar')*p('bbar_x')*x('dep') ...
     - p('qbar')*p('bbar_g')*x('infl') + p('sg')*x('g') + x('ftrans') - x('tls'));
h2 = x('bal') - (x('pb') - x('intexp'));
h3 = x('y') - (p('sc')*x('c') + p('si')*x('ii') + p('sg')*x('g') + p('sx')*x('xx') - p('sm')*x('im'));
h4 = x('tls') - (x('tax_debt') + x('tax_auto') + x('rev_disc'));
h = max(abs([h1 h2 h3 h4]), [], 'all');
end
