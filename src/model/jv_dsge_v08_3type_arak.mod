/*
 * jv_dsge_v08_3type_arak.mod — 3. LEPCSO: TIPUSONKENTI AR ES KERESLET
 * =====================================================================
 * A lepcsozetes terv 3. lepcsoje (2026-08-12).
 *
 * A 2. LEPCSO (jv_dsge_v07_3type) ATMENT: a haromtipusos szerkezet a
 * Jakab-Vilagi magon BK-stabil, 18/18 kombinacioban. DE ott dokumentaltuk
 * a donto korlatot: KOZOS arszint mellett a tipus-kibocsatas MECHANIKUS
 *     y_j = (1-phi_j)*y_d + phi_j*y_x
 * ket kozos valtozo fix sulyu kevereke, tehat a tipus SAJAT koltsege
 * egyaltalan nem hat a sajat kibocsatasara. Szegmens-szintu kibocsatast
 * abbol a lepcsobol NEM lehet kozolni.
 *
 * EZ A FAJL OLDJA FEL AZT A KORLATOT: minden tipus sajat arat (p_j) es
 * sajat keresletet kap, tehat a sajat hatarkoltsege VEGRE HAT a sajat
 * kibocsatasara.
 *
 * =====================================================================
 * !!! EZ A DOKUMENTALTAN KOCKAZATOS LEPES !!!
 * =====================================================================
 * A v04 elso kiserlete pontosan ezen bukott meg, es a v06 pontositotta a
 * leckét: nem a szegmens-specifikus tokehozam volt a hibas, hanem a
 * KOMBINACIO az ARSZINT-SZETVALASZTASSAL. A masik felet (rk_j) a v06 es a
 * v07_3type mar bizonyitotta -- tehat ha ez a fajl BK-n bukik, az
 * IZOLALTAN az arra vezetheto vissza. Ez a lepcsozetes terv ertelme.
 *
 * A MASODIK ISMERT CSAPDA, amit eleve kikerulunk: a v01 fejlecéből ("a
 * relativar-identitasok naiv felirasa EGYSEGGYOKOT hagy a rendszerben --
 * a sulyozott relativar-osszeg nullara kotesevel javitottuk"). Ezert a
 * normalizaciot EXPLICIT egyenletkent tesszuk be:
 *     0 = wd_E*p_E + wd_D*p_D + wd_L*p_L
 * es az infl (hazai kompozit inflacio) ebbol adodik reziduumkent, nem
 * kulon identitaskent -- igy nincs tulhatarozas.
 *
 * MI VALTOZIK a v07_3type-hoz kepest:
 *   1. Tipusonkenti relativar p_j es inflacio pi_j (a kozos px/pix helyett).
 *   2. Tipusonkenti Phillips-gorbe, a SAJAT (mc_j - p_j) reallal hajtva,
 *      a JV hibrid (indexalt) alakjaban -- nem az EAGLE tisztan
 *      elorenezo alakjaban.
 *   3. Tipusonkenti hazai kereslet CES-sel: d_j = y_d - eps_ces*p_j
 *   4. Tipusonkenti exportkereslet, JV-stilusu reszleges alkalmazkodassal:
 *      x_j = hx*x_j(-1) + (1-hx)*(-mu_x*(p_j - rer)) + e_x_ar
 *   5. y_j = (1-phi_j)*d_j + phi_j*x_j   <-- MAR NEM mechanikus: d_j es
 *      x_j a sajat aron keresztul a sajat koltsegtol fugg.
 *   6. px es xx aggregalt INDEXEK lesznek (bstar-hoz es riportalashoz).
 *
 * UJ PARAMETER: eps_ces (CES helyettesitesi rugalmassag a tipusok kozott).
 * A JV-ben nincs ilyen (ott ket jószag van, nem differencialt tipusok).
 * Az EAGLE-vonal 6.0-t hasznal (20% markup). Ez tehat IRODALMI ATVETEL,
 * nem JV-becsles -- a kalibracios tabla C-kategoriaja. Erzekenyseggel
 * kiserendo: -DEPSCES=<ertek>.
 *
 * Szcenariok: -DSCENARIO=1|2|3, -DTSCEN=1|2|3, -DNOVERT=1, -DNUUNI, -DEPSCES
 * Futtatas:   stress_jv_3type_arak.m
 *
 * =====================================================================
 * EREDMENY (stress_jv_3type_arak.m, 2026-08-12)
 * =====================================================================
 * (A) BK: 18/18 kombinacio megoldodott. A normalizacio 6.9e-18-ig tart,
 *     a realarfolyam max 1.02%, az NFA max 1.25% -- minden plauzibilis.
 *     ==> AZ ARSZINT-SZETVALASZTAS A JV-MAGON NEM TORI EL A MODELLT.
 *     A v04-es kudarc tehat NEM volt elkerulhetetlen: ott a KOMBINACIO
 *     volt a baj, es a v01-es normalizacios javitassal mukodik.
 *
 * (B) A KORLAT FELOLDODOTT. A 2. lepcso mechanikus jóslata y_E-re
 *     +0.2249 lett volna; a tenyleges +(-0.2205), elteres -0.4455 pp.
 *     A tipus sajat koltsege VEGRE hat a sajat kibocsatasara.
 *
 * (C) !!! DE UJ HORGONYZATLAN PARAMETER VISZI A SZEKTORALIS EREDMENYT !!!
 *     Az eps_ces (CES helyettesites a tipusok kozott) UJ: a JV-ben NINCS
 *     ilyen, az ertek az EAGLE-vonalbol atvett irodalmi szam. Es az
 *     export-KKV kibocsatasanak ELOJELE ezen fordul (t42):
 *         eps_ces =  2 -> y_E = +0.022%
 *         eps_ces =  3 -> y_E = -0.047%
 *         eps_ces =  6 -> y_E = -0.221%   (jelenlegi alap)
 *         eps_ces = 11 -> y_E = -0.447%
 *     Elojelvaltas ~2.3 korul. UGYANAZ A MINTAZAT, mint a t_S>t_L, a
 *     chi-aszimmetria, az ACCSCALE es az IO-alapu s_kkv eseteben: egy
 *     nem horgonyzott parameter hordozza a fo szektoralis allitast.
 *     ==> Szektoralis kibocsatast KUSZOBFORMABAN kell kozolni, es az
 *         eps_ces-t horgonyozni kell (magyar markup/helyettesitesi becsles).
 *
 * (D) AMI VISZONT ROBUSZTUS: az aggregalt GDP-hatas az eps_ces teljes
 *     savjaban +0.466% ... +0.474% (gyakorlatilag mozdulatlan). Ugyanaz a
 *     kep, mint a projekt minden korabbi lepesenel: az AGGREGATUM stabil,
 *     a SZEGMENS-bontas torekeny.
 *
 * (E) A MECHANIZMUS VISZONT VALODI, es epp a JV-mag gazdagsagabol jon:
 *     az E tipus a leginkabb import-intenziv (aa_E=0.45 vs aa_D=0.80),
 *     ezert a realarfolyam-mozgas az O koltseget emeli a legjobban ->
 *     relativ ara no -> hazai keresletet veszit. Ezt az EAGLE ketinputos
 *     Cobb-Douglasa NEM tudna eloallitani. Tehat nem mutermek: a
 *     mechanizmus valodi, csak a NAGYSAGA (es igy az elojel) horgonyzatlan.
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
@#ifndef EPSCES
  @#define EPSCES = 6.0
@#endif

var
    // haztartas es aggregatumok
    c_o c_no c ii k
    // arak, berek -- TIPUSONKENTI ar es inflacio (3. lepcso)
    w piw infl px
    p_E p_D p_L pi_E pi_D pi_L
    // tipusonkenti kereslet (3. lepcso)
    d_E d_D d_L x_E x_D x_L
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
    s_kkv mu_vert zsov eps_ces
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
eps_ces = @{EPSCES};
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
// *** A 3. LEPCSO LENYEGE: a tipus kibocsatasa a SAJAT keresletebol ***
// A d_j es x_j a sajat aron (p_j) keresztul a sajat hatarkoltsegtol fugg,
// tehat y_j MAR NEM ket kozos valtozo mechanikus kevereke.
y_E = (1-phi_E)*d_E + phi_E*x_E;
y_D = (1-phi_D)*d_D + phi_D*x_D;
y_L = (1-phi_L)*d_L + phi_L*x_L;
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
// --- TIPUSONKENTI Phillips-gorbek, JV hibrid (indexalt) alakban --------
// A hajtoero a SAJAT relativ hatarkoltseg (mc_j - p_j), nem a kompozit.
pi_E = beta/(1+beta*vth_p)*pi_E(+1) + vth_p/(1+beta*vth_p)*pi_E(-1)
       + lam_p/(1+beta*vth_p)*(mc_E - p_E) + eps_md;
pi_D = beta/(1+beta*vth_p)*pi_D(+1) + vth_p/(1+beta*vth_p)*pi_D(-1)
       + lam_p/(1+beta*vth_p)*(mc_D - p_D) + eps_md;
pi_L = beta/(1+beta*vth_p)*pi_L(+1) + vth_p/(1+beta*vth_p)*pi_L(-1)
       + lam_p/(1+beta*vth_p)*(mc_L - p_L) + e_mx_ar;
// Relativ arak mozgasa.
p_E = p_E(-1) + pi_E - infl;
p_D = p_D(-1) + pi_D - infl;
p_L = p_L(-1) + pi_L - infl;
// *** A v01-BEN DOKUMENTALT EGYSEGGYOK-CSAPDA KIKERULESE ***
// "a relativar-identitasok naiv felirasa EGYSEGGYOKOT hagy a rendszerben
//  -- a sulyozott relativar-osszeg nullara kotesevel javitottuk" (v01).
// Ez az egyenlet hatarozza meg az infl-t (hazai kompozit inflacio), tehat
// NINCS kulon infl-identitas -> nincs tulhatarozas.
0 = wd_E*p_E + wd_D*p_D + wd_L*p_L;
piw  = beta/(1+beta*vth_w)*piw(+1) + vth_w/(1+beta*vth_w)*piw(-1)
       + lam_w/(1+beta*vth_w)*(sigma/(1-habit)*(c - habit*c(-1))
                                + fii*ll - w) + e_w_ar;
w  = w(-1) + piw - infl;

// === 6. Kereslet, kulkereskedelem (JV, valtozatlan) =====================
y_d = shd_c*c + shd_i*ii + shd_g*g + shd_v*h_dx;
// TIPUSONKENTI hazai kereslet: CES-helyettesites a tipusok kozott.
// (A normalizacio miatt sum(wd_j*d_j) = y_d automatikusan teljesul.)
d_E = y_d - eps_ces*p_E;
d_D = y_d - eps_ces*p_D;
d_L = y_d - eps_ces*p_L;
// TIPUSONKENTI exportkereslet, JV-stilusu reszleges alkalmazkodassal.
x_E = hx*x_E(-1) + (1-hx)*(-mu_x*(p_E - rer)) + e_x_ar;
x_D = hx*x_D(-1) + (1-hx)*(-mu_x*(p_D - rer)) + e_x_ar;
x_L = hx*x_L(-1) + (1-hx)*(-mu_x*(p_L - rer)) + e_x_ar;
// Aggregalt export-index es -ar (bstar-hoz es riportalashoz).
xx = wx_E*x_E + wx_D*x_D + wx_L*x_L;
px = wx_E*p_E + wx_D*p_D + wx_L*p_L;
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
