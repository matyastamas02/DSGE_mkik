/*
 * jv_dsge_v07_3type.mod — HAROMTIPUSOS SZERKEZET A JAKAB-VILAGI MAGON
 * =====================================================================
 * 2. LEPCSO a lepcsozetes tervbol (2026-08-12).
 *
 * MIERT. A haromtipusos (E/D/L) szerkezet eddig CSAK az EAGLE-magon
 * letezett (kkv_dsge_v06_3type / v07_access). A csapat viszont
 * 2026-07-13-an azzal az ervvel dontott a Jakab-Vilagi alapmodell mellett,
 * hogy annak parameterei magyar adaton BECSULTEK. Ez a fajl azt teszteli,
 * hogy a haromtipusos bontas a JV-magon egyaltalan MEGOLDHATO-e.
 *
 * MIERT ERDEMES a JV-magon: a JV termelesi blokkja GAZDAGABB, nem
 * szegenyebb. Harom input (toke, munka, IMPORT), explicit helyettesitesi
 * rugalmassagokkal (rho_kz, rho_z), es szektoronkent elteroe
 * import-intenzitassal (a_d=0.80 vs a_x=0.45). Az EAGLE ketinputos
 * Cobb-Douglasa (y = a + alpha*k + (1-alpha)*n) ezt EGYALTALAN nem tudja
 * kifejezni -- pedig az exportszektor import-intenzitasa a magyar dualis
 * gazdasag kozponti tenye, tehat pont a projekt fo kerdesehez tartozik.
 *
 * =====================================================================
 * MIT CSINAL EZ A LEPCSO, ES MIT NEM
 * =====================================================================
 * CSINALJA (a meret dimenzio):
 *   Harom kulon TERMELOEGYSEG: E = export-orientalt KKV, D = hazai
 *   orientacioju KKV, L = nagyvallalat. Mindegyiknek SAJAT tokéje,
 *   tokehozama (rk_j), input-kompozitja (wz_j), hatarkoltsege (mc_j),
 *   toke- es munkakereslete (z_j, l_j), BGG-blokkja (q_j, ret_j, efp_j,
 *   nw_j) es beruhazasa (i_j).
 *
 * NEM CSINALJA (a piac dimenzio ARAZASI resze) -- SZANDEKOSAN:
 *   Nincs tipusonkenti ar (p_E, p_D, p_L) es nincs tipusonkenti
 *   exportkereslet. Az arszint KOZOS: tovabbra is ket jószag-ar van
 *   (hazai: infl, export: px), ahogy a JV-ben.
 *
 * MIERT EZ A SORREND. A v04 elso kiserlete Blanchard-Kahn-on bukott meg,
 * es a v06 PONTOSITOTTA a leckét: nem a szegmens-specifikus tokehozam
 * volt a hibas, hanem a KOMBINACIO az arszint-szetvalasztassal. A
 * tipusonkenti ar tehat epp a dokumentaltan kockazatos elem -> kulon
 * lepcsore kerul (3. lepcso). Ha MAR EZ a lepcso elbukik BK-n, akkor a
 * 3. lepcsonek nincs is ertelme; ha atmegy, sokkal jobban meg tudjuk
 * itelni, erdemes-e tovabbmenni.
 *
 * A PIAC DIMENZIO ATTOL MEG BENNE VAN, csak a jószag szintjen kezelve:
 * minden tipus MINDKET piacon ertekesit, phi_j exporthanyaddal
 *     y_j = (1-phi_j)*y_d + phi_j*y_x
 * es a ket jószag hatarkoltsege a tipusok mc_j-jenek sulyozott atlaga,
 * a domesztikus/export ertekesitesi sulyokkal. Vagyis a Samu-jegyzet
 * kovetelmenye ("KKV: hazai + export ertekesites, nagyvallalat: hazai +
 * export ertekesites") MAR EBBEN A LEPCSOBEN teljesul -- csak az ARAK
 * nem tipusfuggoek meg.
 *
 * KONZISZTENCIA-ELLENORZES: a wx_j export-sulyok (om_j*phi_j normalizalva)
 * 0.356 / 0.065 / 0.579-re jonnek ki, ami PONTOSAN a kkv_dsge_v07_access
 * sx_E / sx_D / sx_L parametere. Ket fuggetlen uton ugyanaz -> a
 * formalizalas egyezik Samuéval.
 *
 * KIINDULAS: jv_dsge_v06.mod (ott mar bizonyitott, hogy a
 * szegmens-specifikus rk a JV-magon BK-stabil, 18/18 kombinacioban).
 *
 * =====================================================================
 * !!! DONTO KORLAT: A TIPUS-KIBOCSATAS (y_j) MECHANIKUS !!!
 * =====================================================================
 * A kozos arszint ARA az, hogy a tipusoknak nem lehet sajat keresletuk.
 * Emiatt a tipus kibocsatasa DEFINICIO SZERINT ket kozos valtozo fix
 * sulyu keverek:
 *     y_j = (1-phi_j)*y_d + phi_j*y_x
 * Numerikusan ellenorizve (SCENARIO=1, TSCEN=3):
 *     y_d = +0.1059, y_x = +0.3476
 *     0.44*y_d + 0.56*y_x = +0.2413  ==  y_E = +0.2413  (bitre)
 * Vagyis a tipusok kibocsatasi SORRENDJE teljes egeszeben a phi_j
 * sorrendje (0.56 > 0.365 > 0.05), es a tipus SAJAT koltsege, felara,
 * tokehozama EGYALTALAN NEM hat a sajat kibocsatasara.
 *
 * ==> SZEGMENS-SZINTU KIBOCSATAST (y_E/y_D/y_L) EBBOL A LEPCSOBOL NEM
 *     SZABAD EREDMENYKENT KOZOLNI. Nem a meretrol szol, hanem a
 *     piaci orientaciorol -- ugyanaz a hibatipus, mint a v05-ben a
 *     "szegmens-toke reallokacios maradek" (v05 fejlec (A) pontja):
 *     egy szegmens-valtozo, ami eredmenynek latszik, de konstrukciobol
 *     adodik.
 *
 * AMI VISZONT VALODI STRUKTURALIS TARTALOM ebben a lepcsoben:
 * a PENZUGYI blokk tenylegesen differencial a tipusok kozott --
 *     efp_E = -2.80 bp | efp_D = -3.30 bp | efp_L = -6.40 bp
 *     i_E   = +0.99%   | i_D   = +0.75%   | i_L   = +1.46%
 *     rk_E  = -0.70%   | rk_D  = -0.83%   | rk_L  = -1.60%
 * (SCENARIO=1, TSCEN=3 = EGYENLO t-sulyok mellett!) Ezek a kulonbsegek
 * a chi_j-bol es a sajat tokehozambol jonnek, nem konstrukciobol.
 * Megjegyzendo: a nagyvallalati felar tobbet esik es a beruhazasa
 * erosebben no EGYENLO t-sulyok mellett is -- ez a v05-ben levezetett
 * d i_ss/d F = -1/chi hatas, valtozatlanul.
 *
 * EZT A KORLATOT EPP A 3. LEPCSO OLDANA FEL: tipusonkenti ar (p_E/p_D/p_L)
 * -> tipusonkenti kereslet -> a sajat koltseg hat a sajat kibocsatasra.
 * Vagyis a 2. lepcso a MEGVALOSITHATOSAGOT bizonyitja, nem a szegmens-
 * eredmenyt szallitja.
 *
 * Szcenariok: -DSCENARIO=1|2|3, -DTSCEN=1|2|3, -DNOVERT=1, -DNUUNI=<x>
 * Futtatas:   run_jv_v07_3type.m
 */

@#ifndef SCENARIO
  @#define SCENARIO = 1
@#endif
@#ifndef NOVERT
  @#define NOVERT = 0
@#endif
@#ifndef NUUNI
  @#define NUUNI = 0.25
@#endif
@#ifndef SKKV
  @#define SKKV = 0.05
@#endif
@#ifndef MUVERT
  @#define MUVERT = 0.50
@#endif
@#ifndef TSCEN
  @#define TSCEN = 3
@#endif

var
    // haztartas es aggregatumok
    c_o c_no c ii k
    // arak, berek
    w piw infl pix px
    // jószag-szintu mennyisegek es hatarkoltsegek
    y_d y_x mc_d mc_x_rel ll im xx y h_dx
    // kulgazdasag, monetaris
    r dep rer bstar
    // === E tipus: export-orientalt KKV ===
    k_E i_E q_E ret_E efp_E nw_E rk_E wz_E mc_E z_E l_E y_E
    // === D tipus: hazai orientacioju KKV ===
    k_D i_D q_D ret_D efp_D nw_D rk_D wz_D mc_D z_D l_D y_D
    // === L tipus: nagyvallalat ===
    k_L i_L q_L ret_L efp_L nw_L rk_L wz_L mc_L z_L l_L y_L
    // sokk-folyamatok
    a g e_c_ar e_x_ar e_w_ar e_i_ar e_pr_ar e_mx_ar
;

varexo
    sov bank uni
    eps_a eps_x eps_c eps_md eps_mx eps_w eps_i eps_q eps_r eps_pr eps_g
;

parameters
    beta delta sigma habit fii
    rho_kz rho_z
    xi_p vth_p xi_x vth_x xi_w vth_w theta_w
    lam_p lam_x lam_w
    hx mu_x gam_i phi_pi nu_b nu_uni om_no
    eps_qw omega_nw
    // tipus-specifikus
    om_E om_D om_L phi_E phi_D phi_L
    zeta_E zeta_D zeta_L aa_E aa_D aa_L
    chi_E chi_D chi_L lev_E lev_D lev_L psi_E psi_D psi_L
    tsov_E tsov_D tsov_L tbank_E tbank_D tbank_L
    // szarmaztatott sulyok
    wd_E wd_D wd_L wx_E wx_D wx_L
    shl_E shl_D shl_L shm_E shm_D shm_L
    // aggregalt sulyok, zaras
    s_kkv mu_vert zsov
    sc si sg sx sm shd_c shd_i shd_g shd_v
    rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g
;

// --- JV-mag: VALTOZATLAN becsult ertekek (jv_dsge_v05/v06) --------------
beta = 0.99; delta = 0.025;
rho_kz = 0.80; rho_z = 0.50;
theta_w = 3.0; nu_b = 0.001; om_no = 0.25; fii = 2.0;
sigma = 1.814; habit = 0.646;
xi_p = 0.921; vth_p = 0.431;
xi_x = 0.810; vth_x = 0.494;
xi_w = 0.657; vth_w = 0.185;
mu_x = 0.534; hx = 0.507; gam_i = 0.761; phi_pi = 1.379;
lam_p = (1-xi_p)*(1-beta*xi_p)/xi_p;
lam_x = (1-xi_x)*(1-beta*xi_x)/xi_x;
lam_w = (1-xi_w)*(1-beta*xi_w)/(xi_w*(1+theta_w*fii));
eps_qw = 0.96; omega_nw = 0.95;

// --- Tipus-sulyok es exportkitettseg ------------------------------------
// FORRAS: kkv_dsge_v07_access sy_* es phi_* parametere. FIGYELEM: ezek a
// SAJAT .mod-juk szerint is INDULO ertekek ("Ezek indulok: empirikus
// ujrakalibracio kell"), es a kalibracios tabla A-kategoriaja szerint az
// Opten-panelbol KOZVETLENUL szamolhatok. Amig az nem tortent meg, ezek
// atvett indulok -- a BK-teszt szempontjabol ez nem szamit, az eredmenyek
// ertelmezesenel viszont igen.
om_E = 0.18; om_D = 0.37; om_L = 0.45;
phi_E = 0.56; phi_D = 0.05; phi_L = 0.365;

// --- Termelesi parameterek tipusonkent ----------------------------------
// A JV ket szektorra ad erteket: zeta_d=0.17 / zeta_x=0.14 (tokehanyad) es
// a_d=0.80 / a_x=0.45 (munka aranya a munka+import kompozitban). Harom
// tipusra a piaci orientacio szerint kepezzuk le: E export-jellegu, D
// hazai-jellegu, L a ketto kozott (phi_L=0.365 miatt kozel felezo).
// Ez ATVITEL, nem becsles -- a 3. lepcsonel vagy az empirikus
// ujrakalibracionál pontositando.
zeta_E = 0.14; zeta_D = 0.17; zeta_L = 0.155;
aa_E   = 0.45; aa_D   = 0.80; aa_L   = 0.60;

// --- Penzugyi blokk (jv_dsge_v05/v06-bol, valtozatlan) -------------------
// E es D egyelore azonos KKV-parametereket kap (mint Samu v07-eben).
// A kalibracios tabla jelzi, hogy a lev_E = lev_D kenyszeritett egyenloseg
// az Opten-panelbol szetszamolhato.
chi_E = 0.06; chi_D = 0.06; chi_L = 0.02;
lev_E = 1.6;  lev_D = 1.6;  lev_L = 1.85;
psi_E = 8.0;  psi_D = 8.0;  psi_L = 13.0;

// --- SZARMAZTATOTT sulyok (nem szabad parameterek) ----------------------
// A hazai jószag hatarkoltsege a tipusok mc_j-jenek sulyozott atlaga, a
// HAZAI ertekesitesi sulyokkal; az export jószage az EXPORT sulyokkal.
wd_E = om_E*(1-phi_E)/(om_E*(1-phi_E)+om_D*(1-phi_D)+om_L*(1-phi_L));
wd_D = om_D*(1-phi_D)/(om_E*(1-phi_E)+om_D*(1-phi_D)+om_L*(1-phi_L));
wd_L = om_L*(1-phi_L)/(om_E*(1-phi_E)+om_D*(1-phi_D)+om_L*(1-phi_L));
wx_E = om_E*phi_E/(om_E*phi_E+om_D*phi_D+om_L*phi_L);
wx_D = om_D*phi_D/(om_E*phi_E+om_D*phi_D+om_L*phi_L);
wx_L = om_L*phi_L/(om_E*phi_E+om_D*phi_D+om_L*phi_L);
// KONZISZTENCIA: wx_E/wx_D/wx_L = 0.356 / 0.065 / 0.579, ami PONTOSAN a
// kkv_dsge_v07_access sx_E/sx_D/sx_L erteke. Ket fuggetlen uton ugyanaz.

// Munka-sulyok: a v07 sn_* foglalkoztatasi reszesedesei.
shl_E = 0.20; shl_D = 0.50; shl_L = 0.30;
// Import-sulyok: az import-intenzitassal (1-aa_j) sulyozott meretaranyok.
shm_E = om_E*(1-aa_E)/(om_E*(1-aa_E)+om_D*(1-aa_D)+om_L*(1-aa_L));
shm_D = om_D*(1-aa_D)/(om_E*(1-aa_E)+om_D*(1-aa_D)+om_L*(1-aa_L));
shm_L = om_L*(1-aa_L)/(om_E*(1-aa_E)+om_D*(1-aa_D)+om_L*(1-aa_L));

// --- Vertikalis link (v04/v05/v06, valtozatlan forma) -------------------
// FIGYELEM: az s_kkv IO-alapu kalibracioja NEM ALL (lasd
// docs/FIGYELMEZTETES_io_tabla_gyanus.md). Itt a BK-teszt szempontjabol
// lenyegtelen, de az eredmenyek ertelmezesenel jelolni kell. A -DNOVERT=1
// ellenprobával kikapcsolhato.
@#if NOVERT == 1
s_kkv = 0.0001; mu_vert = 0.0001;
@#else
s_kkv = @{SKKV}; mu_vert = @{MUVERT};
@#endif

// --- Kereslet-sulyok, zaras (jv_dsge_v06-bol valtozatlan) ---------------
sc = 0.54; si = 0.23; sg = 0.10; sx = 0.60; sm = 0.47;
shd_v = s_kkv * 0.60;
shd_c = 0.55*(1-shd_v)/0.82; shd_i = 0.15*(1-shd_v)/0.82;
shd_g = 0.12*(1-shd_v)/0.82;

// --- Premium-transzmisszio ----------------------------------------------
// TSCEN=3 (semleges) az ALAPERTELMEZES, mert a t_S>t_L feltevés nem
// azonosithato az adatbol (docs/FIGYELMEZTETES_fo_allitas.md). E es D
// azonos KKV-suly, mint Samu v07-eben.
@#if TSCEN == 1
tsov_E = 0.25; tsov_D = 0.25; tsov_L = 0.10;
tbank_E = 0.60; tbank_D = 0.60; tbank_L = 0.30;
@#elseif TSCEN == 2
tsov_E = 0.10; tsov_D = 0.10; tsov_L = 0.25;
tbank_E = 0.30; tbank_D = 0.30; tbank_L = 0.60;
@#else
tsov_E = 0.175; tsov_D = 0.175; tsov_L = 0.175;
tbank_E = 0.45; tbank_D = 0.45; tbank_L = 0.45;
@#endif
zsov = 0.5;
nu_uni = @{NUUNI};
rho_a = 0.552; rho_x = 0.625; rho_c = 0.767; rho_w = 0.661;
rho_i = 0.488; rho_pr = 0.820; rho_mx = 0.318; rho_g = 0.80;

model;

// === 1. Haztartasok (JV, valtozatlan) ===================================
c_o = habit/(1+habit)*c_o(-1) + 1/(1+habit)*c_o(+1)
      - (1-habit)/((1+habit)*sigma)*(r - infl(+1)) + e_c_ar;
c_no = w + ll;
c = (1-om_no)*c_o + om_no*c_no;

// === 2. BGG-blokk TIPUSONKENT ===========================================
// Sajat tokehozam (rk_j) tipusonkent -- ez a v06 bizonyitott ujitasa.
ret_E = (1-eps_qw)*rk_E + eps_qw*q_E - q_E(-1);
ret_D = (1-eps_qw)*rk_D + eps_qw*q_D - q_D(-1);
ret_L = (1-eps_qw)*rk_L + eps_qw*q_L - q_L(-1);
ret_E(+1) = r - infl(+1) + efp_E + eps_q;
ret_D(+1) = r - infl(+1) + efp_D + eps_q;
ret_L(+1) = r - infl(+1) + efp_L + eps_q;
efp_E = chi_E*(q_E + k_E - nw_E) + tsov_E*sov + tbank_E*bank;
efp_D = chi_D*(q_D + k_D - nw_D) + tsov_D*sov + tbank_D*bank;
efp_L = chi_L*(q_L + k_L - nw_L) + tsov_L*sov + tbank_L*bank;
nw_E = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl)));
nw_D = omega_nw*(nw_D(-1) + lev_D*(ret_D - (r(-1) - infl)));
nw_L = omega_nw*(nw_L(-1) + lev_L*(ret_L - (r(-1) - infl)));
i_E = 1/(1+beta)*i_E(-1) + beta/(1+beta)*i_E(+1)
      + 1/((1+beta)*psi_E)*q_E + e_i_ar;
i_D = 1/(1+beta)*i_D(-1) + beta/(1+beta)*i_D(+1)
      + 1/((1+beta)*psi_D)*q_D + e_i_ar;
i_L = 1/(1+beta)*i_L(-1) + beta/(1+beta)*i_L(+1)
      + 1/((1+beta)*psi_L)*q_L + e_i_ar;
k_E = (1-delta)*k_E(-1) + delta*i_E;
k_D = (1-delta)*k_D(-1) + delta*i_D;
k_L = (1-delta)*k_L(-1) + delta*i_L;
// aggregalt riportalas (nem hajt semmit)
k  = om_E*k_E + om_D*k_D + om_L*k_L;
ii = om_E*i_E + om_D*i_D + om_L*i_L;

// === 3. Termeles TIPUSONKENT (a JV harominputos szerkezetevel) ==========
// Munka+import kompozit ara, tipusonkent elteroe import-intenzitassal.
wz_E = aa_E*w + (1-aa_E)*rer;
wz_D = aa_D*w + (1-aa_D)*rer;
wz_L = aa_L*w + (1-aa_L)*rer;
// Hatarkoltseg: sajat tokehozammal es sajat kompozittal.
mc_E = zeta_E*rk_E + (1-zeta_E)*wz_E - a;
mc_D = zeta_D*rk_D + (1-zeta_D)*wz_D - a;
mc_L = zeta_L*rk_L + (1-zeta_L)*wz_L - a;
// *** A MERET x PIAC SZETVALASZTAS LENYEGE ***
// Minden tipus MINDKET piacon ertekesit: phi_j hanyadot exportal,
// (1-phi_j)-t belfoldon. Igy a KKV is exportal es a nagyvallalat is
// ertekesit itthon -- pontosan amit a szerkezeti kritika kovetelt.
y_E = (1-phi_E)*y_d + phi_E*y_x;
y_D = (1-phi_D)*y_d + phi_D*y_x;
y_L = (1-phi_L)*y_d + phi_L*y_x;
// Tenyezokereslet a SAJAT kibocsatasbol vezerelve.
z_E = rho_kz*zeta_E*(rk_E - wz_E) + y_E - a;
z_D = rho_kz*zeta_D*(rk_D - wz_D) + y_D - a;
z_L = rho_kz*zeta_L*(rk_L - wz_L) + y_L - a;
l_E = z_E - rho_z*(w - wz_E);
l_D = z_D - rho_z*(w - wz_D);
l_L = z_L - rho_z*(w - wz_L);
// A BGG-ben felhalmozott toke a SAJAT tipus termelesi tokekereslete.
k_E(-1) = z_E - rho_kz*(rk_E - wz_E);
k_D(-1) = z_D - rho_kz*(rk_D - wz_D);
k_L(-1) = z_L - rho_kz*(rk_L - wz_L);
// Aggregalt munka- es importkereslet.
ll = shl_E*l_E + shl_D*l_D + shl_L*l_L;
im = shm_E*(z_E - rho_z*(rer - wz_E))
   + shm_D*(z_D - rho_z*(rer - wz_D))
   + shm_L*(z_L - rho_z*(rer - wz_L));

// === 4. Jószag-szintu hatarkoltsegek (KOZOS AR!) ========================
// A ket jószag hatarkoltsege a tipusok mc_j-jenek sulyozott atlaga.
// EZ a "kozos arszint" lepcso lenyege: NINCS p_E/p_D/p_L, csak ket
// jószag-ar (infl, px), es a tipusok ezekbe aggregalodnak.
mc_d = wd_E*mc_E + wd_D*mc_D + wd_L*mc_L;
mc_x_rel = (1-s_kkv)*(wx_E*mc_E + wx_D*mc_D + wx_L*mc_L)
           + s_kkv*mc_d - px;
h_dx = xx - mu_vert*s_kkv*(mc_d - mc_x_rel);

// === 5. Phillips-gorbek (JV hibrid, valtozatlan) ========================
infl = beta/(1+beta*vth_p)*infl(+1) + vth_p/(1+beta*vth_p)*infl(-1)
       + lam_p/(1+beta*vth_p)*mc_d + eps_md;
pix  = beta/(1+beta*vth_x)*pix(+1) + vth_x/(1+beta*vth_x)*pix(-1)
       + lam_x/(1+beta*vth_x)*mc_x_rel + e_mx_ar;
piw  = beta/(1+beta*vth_w)*piw(+1) + vth_w/(1+beta*vth_w)*piw(-1)
       + lam_w/(1+beta*vth_w)*(sigma/(1-habit)*(c - habit*c(-1))
                                + fii*ll - w) + e_w_ar;
w  = w(-1) + piw - infl;
px = px(-1) + pix - infl;

// === 6. Kereslet, kulkereskedelem (JV, valtozatlan) =====================
y_d = shd_c*c + shd_i*ii + shd_g*g + shd_v*h_dx;
xx = hx*xx(-1) + (1-hx)*(-mu_x*(px - rer)) + e_x_ar;
y_x = xx;
y  = sc*c + si*ii + sg*g + sx*xx - sm*im;
bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im);

// === 7. Rezsimfuggo monetaris blokk (JV v03/v05/v06) ====================
(1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
    + uni*(r - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0;
rer = rer(-1) + dep - infl;

// === 8. Sokk-folyamatok =================================================
a       = rho_a*a(-1) + eps_a;
e_x_ar  = rho_x*e_x_ar(-1) + eps_x;
e_c_ar  = rho_c*e_c_ar(-1) + eps_c;
e_w_ar  = rho_w*e_w_ar(-1) + eps_w;
e_i_ar  = rho_i*e_i_ar(-1) + eps_i;
e_pr_ar = rho_pr*e_pr_ar(-1) + eps_pr;
e_mx_ar = rho_mx*e_mx_ar(-1) + eps_mx;
g       = rho_g*g(-1) + eps_g;

end;

initval;
sov = 0; bank = 0; uni = 0;
end;

@#if SCENARIO == 1
endval;
sov = -0.005; bank = -0.001125; uni = 1;
end;
@#elseif SCENARIO == 2
endval;
sov = -0.00625; bank = -0.00175; uni = 1;
end;
@#else
endval;
sov = -0.00375; bank = -0.0005; uni = 1;
end;
@#endif

steady;

@#if SCENARIO == 1
shocks;
var uni;  periods 1:12; values 0;
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.00025 -0.0005 -0.00075 -0.001 -0.00125 -0.0015 -0.00175 -0.002
       -0.00225 -0.0025 -0.00275 -0.003 -0.0035 -0.004 -0.0045 -0.005;
var bank;
periods 1:12 13 14 15 16;
values 0 -0.00028125 -0.0005625 -0.00084375 -0.001125;
end;
@#elseif SCENARIO == 2
shocks;
var uni;  periods 1:12; values 0;
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.0003125 -0.000625 -0.0009375 -0.00125 -0.0015625 -0.001875
       -0.0021875 -0.0025 -0.0028125 -0.003125 -0.0034375 -0.00375
       -0.004375 -0.005 -0.005625 -0.00625;
var bank;
periods 1:12 13 14 15 16;
values 0 -0.0004375 -0.000875 -0.0013125 -0.00175;
end;
@#else
shocks;
var uni;  periods 1:12; values 0;
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.0001875 -0.000375 -0.0005625 -0.00075 -0.0009375 -0.001125
       -0.0013125 -0.0015 -0.0016875 -0.001875 -0.0020625 -0.00225
       -0.002625 -0.003 -0.003375 -0.00375;
var bank;
periods 1:12 13 14 15 16;
values 0 -0.000125 -0.00025 -0.000375 -0.0005;
end;
@#endif

perfect_foresight_setup(periods=120);
perfect_foresight_solver;
