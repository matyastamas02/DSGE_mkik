/*
 * jv_dsge_v01.mod — Jakab–Világi (MNB WP 2008/9) alapú mag, v01
 * =====================================================================
 * ALAPCIKK-VÁLTÁS (2026-07-13, csapatdöntés): az alap a Jakab–Világi:
 * "An estimated DSGE model of the Hungarian economy" (MNB WP 2008/9),
 * NEM az EAGLE-HU. Indok: magyar adaton BECSÜLT (Bayes-i) paraméterek,
 * karcsú egyblokkos szerkezet, natív ár/bér-Calvo indexálással.
 *
 * Ez a fájl a JV log-linearizált modelljének (Appendix A.4–A.9)
 * újraimplementációja az INFLÁCIÓS CÉLKÖVETÉSES rezsim becsült
 * (poszterior átlag) paramétereivel. A tilde-változók log-eltérések.
 *
 * A JV-modell szerkezete, amit átveszünk:
 *  - két termelő szektor: hazai (d) és export (x); mindkettő tőkét és
 *    egy MUNKA+IMPORT kompozit inputot (z) használ — a magas magyar
 *    import-tartalom így a költségoldalon él (JV kulcsvonás);
 *  - optimalizáló (75%) + hitelpiachoz nem férő (25%) háztartások;
 *  - hibrid (indexált) Phillips-görbék: hazai ár, exportár, BÉR;
 *  - Tobin-Q beruházás magas kiigazítási költséggel (Phi''=13);
 *  - UIP adósság-rugalmas prémiummal, Taylor-szabály.
 *
 * DOKUMENTÁLT EGYSZERŰSÍTÉSEK (v01):
 *  1. Csak az IT-rezsim: nincs csúszó-leértékelés blokk (d_e_bar = 0).
 *  2. Nincs adaptív tanulás (a JV "perceived underlying inflation"
 *     blokkja): pi_bar konstans -> pi_hat = pi. (A JV 7. fejezete maga
 *     is bemutat egy tanulás nélküli változatot.)
 *  3. Nincs foglalkoztatás-egyenlet (A.10) — becslési segédblokk volt.
 *  4. Import-árszint exogén (P_m* = 0), az árfolyam viszi a variációt.
 *  5. Néhány SS-arány a cikkből nem olvasható ki egyértelműen — jelölve
 *     "KOZELITES" kommenttel, ellenőrizendő a szerzői kóddal/adattal.
 *
 * Futtatás:  matlab -batch "cd('src/model'); dynare jv_dsge_v01 console"
 */

var
    c_o          // optimalizáló háztartás fogyasztása
    c_no         // nem-optimalizáló (kézről szájra) fogyasztás
    c            // aggregált fogyasztás
    ii           // beruházás
    k            // tőkeállomány (periódus végi)
    q            // Tobin-Q
    rk           // tőke bérleti díja (reál)
    w            // reálbér (CPI-vel deflálva)
    piw          // nominális bérinfláció
    infl         // hazai (CPI-) infláció
    pix          // exportár-infláció
    px           // export relatív ár (P_x/P_C)
    wz_d wz_x    // munka+import kompozit input ára szektoronként
    mc_d         // hazai szektor reál határköltsége
    mcx_rel      // export szektor határköltsége az exportárhoz képest
    y_d y_x      // szektorális kibocsátás
    z_d z_x      // munka+import kompozit kereslete
    l_d l_x ll   // munkakereslet szektoronként + aggregált
    im           // import (termelési input)
    xx           // exportkereslet
    y            // GDP
    r            // nominális kamat (negyedéves eltérés)
    dep          // nominális leértékelődés
    rer          // reálárfolyam
    bstar        // nettó külföldi eszközpozíció (GDP-arányos)
    // sokk-állapotok
    a            // termelékenység
    g            // kormányzati kereslet
    e_c_ar       // fogyasztási preferencia
    e_x_ar       // exportkereslet
    e_w_ar       // bér- (munkapiaci) markup
    e_i_ar       // beruházási
    e_pr_ar      // pénzügyi prémium
    e_mx_ar      // export-markup
;

varexo
    eps_a eps_x eps_c eps_md eps_mx eps_w eps_i eps_q eps_r eps_pr eps_g
;

parameters
    beta delta sigma habit fii
    zeta_d zeta_x a_d a_x rho_kz rho_z
    xi_p vth_p xi_x vth_x xi_w vth_w theta_w
    lam_p lam_x lam_w
    psi_i hx mu_x
    gam_i phi_pi nu_b
    om_no
    sc si sg sx sm
    sh_ld sh_kd sh_imd sh_yd
    rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g
;

// --- Rögzített paraméterek (JV Table 1) ---
beta   = 0.99;      // KOZELITES: a cikk fix, de a kivonatban nem látszik
delta  = 0.025;     // KOZELITES: standard negyedéves amortizáció
zeta_d = 0.17;      // tőke részaránya a határköltségben, hazai (Table 1)
zeta_x = 0.14;      // ugyanez, export (Table 1)
rho_kz = 0.80;      // tőke vs. z-kompozit helyettesítés (Table 1)
rho_z  = 0.50;      // munka vs. import helyettesítés a z-ben (Table 1)
theta_w = 3.0;      // differenciált munka helyettesítése (Table 1)
psi_i  = 13.0;      // beruházási kiigazítási költség, Phi'' (Table 1)
nu_b   = 0.001;     // adósság-rugalmas prémium (Table 1)
om_no  = 0.25;      // nem-optimalizáló háztartások aránya (Table 1, survey)
fii    = 2.0;       // KOZELITES: inverz Frisch (a kivonatban nem látszik)
a_d    = 0.80;      // KOZELITES: munka súlya a z-ben, hazai szektor
a_x    = 0.45;      // KOZELITES: export — magas import-tartalom (~55%)

// --- Becsült paraméterek (JV Table 3, IT-rezsim poszterior átlag) ---
sigma  = 1.814;     // fogyasztási hasznosság görbülete
habit  = 0.646;     // szokás (habit)
xi_p   = 0.921;  vth_p = 0.431;   // Calvo + indexálás, fogyasztói árak
xi_x   = 0.810;  vth_x = 0.494;   // Calvo + indexálás, exportárak
xi_w   = 0.657;  vth_w = 0.185;   // Calvo + indexálás, bérek
mu_x   = 0.534;     // exportkereslet árrugalmassága
hx     = 0.507;     // exportkereslet simítása
gam_i  = 0.761;     // kamatsimítás
phi_pi = 1.379;     // Taylor inflációs válasz
lam_p  = (1-xi_p)*(1-beta*xi_p)/xi_p;
lam_x  = (1-xi_x)*(1-beta*xi_x)/xi_x;
lam_w  = (1-xi_w)*(1-beta*xi_w)/(xi_w*(1+theta_w*fii));

// --- SS-arányok (KOZELITES — a JV-ből nem mind olvasható ki) ---
sc = 0.54; si = 0.23; sg = 0.10; sx = 0.60; sm = 0.47;  // GDP-arányok
sh_yd = 0.60;       // hazai szektor súlya a kibocsátásban
sh_ld = 0.70;       // hazai szektor súlya a munkakeresletben
sh_kd = 0.65;       // hazai szektor súlya a tőkekeresletben
sh_imd = 0.30;      // hazai szektor súlya az import-inputban

// --- Sokk-perzisztenciák (JV Table 2, IT-oszlop poszterior átlag) ---
rho_a = 0.552; rho_x = 0.625; rho_c = 0.767; rho_w = 0.661;
rho_i = 0.488; rho_pr = 0.820; rho_mx = 0.318; rho_g = 0.80;

model(linear);

// --- 1. Háztartások ---
// Optimalizáló Euler habit-tal (JV eq. 73, IT-rezsim: d_e_bar=0)
c_o = habit/(1+habit)*c_o(-1) + 1/(1+habit)*c_o(+1)
      - (1-habit)/((1+habit)*sigma)*(r - infl(+1)) + e_c_ar;
// Nem-optimalizáló: folyó bérjövedelmet költi (JV 2.2)
c_no = w + ll;
c = (1-om_no)*c_o + om_no*c_no;

// --- 2. Beruházás, tőke (JV eq. 77–78 elsőrendű alakja) ---
q = beta*(1-delta)*q(+1) + (1-beta*(1-delta))*rk(+1)
    - (r - infl(+1)) + eps_q;
ii = 1/(1+beta)*ii(-1) + beta/(1+beta)*ii(+1)
     + 1/((1+beta)*psi_i)*q + e_i_ar;
k = (1-delta)*k(-1) + delta*ii;

// --- 3. Termelési input-árak és határköltségek ---
// z-kompozit ára: munka + import (import ára = rer, P_m* exogén 0)
wz_d = a_d*w + (1-a_d)*rer;
wz_x = a_x*w + (1-a_x)*rer;
mc_d = zeta_d*rk + (1-zeta_d)*wz_d - a;
mcx_rel = zeta_x*rk + (1-zeta_x)*wz_x - a - px;

// --- 4. Tényezőkeresletek (JV eq. 84–85 szerkezete) ---
// z-kereslet szektoronként (CES tőke és z között, rug. rho_kz):
z_d = rho_kz*zeta_d*(rk - wz_d) + y_d - a;
z_x = rho_kz*zeta_x*(rk - wz_x) + y_x - a;
// munka és import a z-n belül (CES, rug. rho_z):
l_d = z_d - rho_z*(w - wz_d);
l_x = z_x - rho_z*(w - wz_x);
ll  = sh_ld*l_d + (1-sh_ld)*l_x;
im  = sh_imd*(z_d - rho_z*(rer - wz_d)) + (1-sh_imd)*(z_x - rho_z*(rer - wz_x));
// tőkepiac-tisztulás (a tőke szektorok közt szabadon áramlik):
k(-1) = sh_kd*(z_d - rho_kz*(rk - wz_d)) + (1-sh_kd)*(z_x - rho_kz*(rk - wz_x));

// --- 5. Phillips-görbék (JV eq. 86–88, hibrid/indexált) ---
infl = beta/(1+beta*vth_p)*infl(+1) + vth_p/(1+beta*vth_p)*infl(-1)
       + lam_p/(1+beta*vth_p)*mc_d + eps_md;
pix  = beta/(1+beta*vth_x)*pix(+1) + vth_x/(1+beta*vth_x)*pix(-1)
       + lam_x/(1+beta*vth_x)*mcx_rel + e_mx_ar;
piw  = beta/(1+beta*vth_w)*piw(+1) + vth_w/(1+beta*vth_w)*piw(-1)
       + lam_w/(1+beta*vth_w)*(sigma/(1-habit)*(c - habit*c(-1))
                                + fii*ll - w) + e_w_ar;
w  = w(-1) + piw - infl;
px = px(-1) + pix - infl;

// --- 6. Kereslet, külkereskedelem ---
// exportkereslet simítással (JV: hx, mu_x becsült):
xx = hx*xx(-1) + (1-hx)*(-mu_x*(px - rer)) + e_x_ar;
y_x = xx;
y_d = (sc*c + si*ii + sg*g)/(sc+si+sg);
y  = sc*c + si*ii + sg*g + sx*xx - sm*im;
bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im);

// --- 7. Kamat, árfolyam, politika (JV A.9 + Table 3) ---
r = dep(+1) - nu_b*bstar + e_pr_ar;         // UIP (i* = 0 normálva)
rer = rer(-1) + dep - infl;
r = gam_i*r(-1) + (1-gam_i)*phi_pi*infl + eps_r;   // Taylor (IT)

// --- 8. Sokk-folyamatok (JV Table 2, IT poszterior) ---
a       = rho_a*a(-1) + eps_a;
e_x_ar  = rho_x*e_x_ar(-1) + eps_x;
e_c_ar  = rho_c*e_c_ar(-1) + eps_c;
e_w_ar  = rho_w*e_w_ar(-1) + eps_w;
e_i_ar  = rho_i*e_i_ar(-1) + eps_i;
e_pr_ar = rho_pr*e_pr_ar(-1) + eps_pr;
e_mx_ar = rho_mx*e_mx_ar(-1) + eps_mx;
g       = rho_g*g(-1) + eps_g;

end;

// Sokk-szórások (JV Table 2, IT-oszlop, százalék -> tizedes)
shocks;
var eps_a;  stderr 0.02152;
var eps_x;  stderr 0.02464;
var eps_c;  stderr 0.00203;
var eps_md; stderr 0.00420;
var eps_mx; stderr 0.02182;
var eps_w;  stderr 0.00932;
var eps_i;  stderr 0.01003;
var eps_q;  stderr 0.00393;
var eps_r;  stderr 0.00247;
var eps_pr; stderr 0.00666;
var eps_g;  stderr 0.01;
end;

stoch_simul(order=1, irf=24, nograph) y c ii xx im infl piw r rer w rk q;
