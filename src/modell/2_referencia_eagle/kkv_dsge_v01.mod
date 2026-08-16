/*
 * kkv_dsge_v01.mod — Euró/KKV DSGE, v0.1 (futó váz)
 * =====================================================================
 * Kétszektoros (S = KKV, L = nagyvállalat) kis nyitott gazdaság,
 * új-keynesi mag + BGG-típusú pénzügyi akcelerátor szektoronként eltérő
 * (méretfüggő) chi paraméterrel. A két hitelköltség-csatorna exogén
 * EFP-sokként lép be (szuverén prémium, banki forrásköltség) — a
 * modellválasztási döntés szerint (lásd Notion döntésnapló, 2026-07-06,
 * és docs/modell_vazlat/).
 *
 * Log-linearizált egyenletek (minden változó százalékos eltérés a
 * steady state-től; kamatok/inflációk negyedéves, abszolút eltérések).
 *
 * v0.1 TUDATOS EGYSZERŰSÍTÉSEI (későbbi verziókban feloldandók):
 *  - rugalmas bérek (EAGLE: Calvo-bér)
 *  - import csak LOP-pal, nincs import-árazási ragadósság
 *  - a CPI/hazai ár relatívár-ék a tényezőárakban elhanyagolva
 *  - kormányzati blokk: exogén AR(1) kiadás
 *  - egyetlen külföld-blokk (EAGLE: EA/US/RW kereskedelmi mátrix)
 *  - nettó vagyon egyenlet BGG-lite közelítés (Christensen–Dib jelleg)
 *
 * Kalibráció forrásai:
 *  - Békési–Kaszab–Szentmihályi (MNB WP 2017/7) appendix-táblák
 *  - Opten-panel (output/tables): tőkeáttétel medián S: 0.38 -> lev 1.6,
 *    L: 0.46 -> lev 1.85; EFP-szintek az implicit kamatrátákból
 *  - pitch (2026-07-06): sokk-transzmissziós súlyok
 *
 * Futtatás:  matlab -batch "addpath('C:\dynare\6.5\matlab'); dynare kkv_dsge_v01"
 */

// ---------------------------------------------------------------------
// 1. Változók
// ---------------------------------------------------------------------

var
    c           // fogyasztás
    lam         // fogyasztás határhaszna
    w           // reálbér
    nn          // aggregált munka
    r           // nominális kamat (jegybanki)
    infl        // CPI-infláció
    inflH       // hazai (termelői) infláció
    y           // aggregált kibocsátás (hazai kompozit)
    ii          // aggregált beruházás
    xx          // export
    imp         // import
    rer         // reálárfolyam (emelkedés = leértékelődés)
    dep         // nominális leértékelődés (Δs)
    bstar       // nettó külföldi eszközök (GDP-arányos eltérés)

    // S-szektor (KKV)
    y_S n_S k_S i_S q_S rr_S ret_S efp_S nw_S mc_S inflH_S p_S
    // L-szektor (nagyvállalat)
    y_L n_L k_L i_L q_L rr_L ret_L efp_L nw_L mc_L inflH_L p_L

    // exogén állapotok
    a           // TFP (közös)
    gg          // kormányzati kereslet
    ystar       // külföldi kereslet
    rstar       // külföldi kamat
    sov         // szuverén prémium sokk-állapot (primer, bp-eltérés)
    bank        // banki forrásköltség sokk-állapot (primer)
;

varexo
    e_a e_m e_g e_ystar e_rstar e_sov e_bank
;

// ---------------------------------------------------------------------
// 2. Paraméterek
// ---------------------------------------------------------------------

parameters
    beta sigma habit sigma_n
    alpha delta phi_i
    kappa eps_ces
    sy_S sn_S si_S
    om_m eta_x eta_m
    c_y i_y g_y x_y m_y
    rho_r phi_pi phi_y
    phi_b
    chi_S chi_L eps_q omega_nw lev_S lev_L
    tsov_S tsov_L tbank_S tbank_L
    rho_a rho_g rho_ystar rho_rstar rho_sov rho_bank
;

// --- háztartás ---
beta    = 0.9925;   // negyedéves diszkont (reálkamat ~3%/év)
sigma   = 1.5;      // CRRA
habit   = 0.7;      // fogyasztási habit (Jakab–Világi 2008 közeli)
sigma_n = 2.0;      // inverz Frisch

// --- technológia ---
alpha   = 0.33;
delta   = 0.025;
phi_i   = 2.5;      // beruházási kiigazítási költség

// --- árazás ---
kappa   = 0.085;    // NKPC meredekség (Calvo ~0.75)
eps_ces = 6.0;      // szektortermékek közti helyettesítés

// --- szektorsúlyok (Opten + nemzeti számlák, első közelítés) ---
sy_S    = 0.55;     // KKV kibocsátási súly
sn_S    = 0.70;     // KKV foglalkoztatási súly
si_S    = 0.50;     // KKV beruházási súly

// --- nyitott gazdaság ---
om_m    = 0.35;     // importhányad a CPI-ben
eta_x   = 1.0;      // export-árrugalmasság
eta_m   = 1.0;      // import-árrugalmasság
c_y     = 0.55; i_y = 0.22; g_y = 0.20; x_y = 0.80; m_y = 0.77;

// --- monetáris politika ---
rho_r   = 0.80; phi_pi = 1.50; phi_y = 0.125;
phi_b   = 0.01;     // adósság-rugalmas országprémium (SOE-zárás)

// --- pénzügyi blokk (BGG-lite) ---
// -DNOACCEL kapcsolóval az akcelerátor kikapcsolható (chi=0) — az
// "akcelerátor ki/be" összehasonlító ábrához (s10), a BGG 1999 mintájára.
@#ifdef NOACCEL
chi_S   = 0;
chi_L   = 0;
@#else
chi_S   = 0.06;     // KKV: érzékeny akcelerátor
chi_L   = 0.02;     // nagyvállalat: tompított
@#endif
eps_q   = 0.96;     // tőkehozam-linearizációs súly
omega_nw = 0.95;    // nettó vagyon perzisztencia (túlélési ráta)
lev_S   = 1.6;      // eszköz/saját tőke — Opten medián tőkeáttételből
lev_L   = 1.85;

// --- hitelköltség-sokkok transzmissziós súlyai (pitch, 2026-07-06) ---
tsov_S  = 0.25;     // szuverén primer -> KKV EFP (~25% átvitel)
tsov_L  = 0.10;
tbank_S = 0.60;     // banki primer -> KKV EFP (~60% átvitel)
tbank_L = 0.30;

// --- sokk-perzisztenciák ---
rho_a = 0.90; rho_g = 0.85; rho_ystar = 0.85; rho_rstar = 0.85;
rho_sov = 0.95; rho_bank = 0.90;

// ---------------------------------------------------------------------
// 3. Modell
// ---------------------------------------------------------------------

model(linear);

// --- háztartás ---
lam = -sigma/(1-habit)*(c - habit*c(-1));
lam = lam(+1) + (r - infl(+1));
w   = sigma_n*nn - lam;

// --- S-szektor (KKV) ---
y_S  = a + alpha*k_S(-1) + (1-alpha)*n_S;
w    = p_S + mc_S + y_S - n_S;
rr_S = p_S + mc_S + y_S - k_S(-1);
ret_S = (1-eps_q)*rr_S + eps_q*q_S - q_S(-1);
ret_S(+1) = r - infl(+1) + efp_S;
efp_S = chi_S*(q_S + k_S - nw_S) + tsov_S*sov + tbank_S*bank;
nw_S  = omega_nw*(nw_S(-1) + lev_S*(ret_S - (r(-1) - infl)));
q_S   = phi_i*(i_S - k_S(-1));
k_S   = (1-delta)*k_S(-1) + delta*i_S;
inflH_S = beta*inflH_S(+1) + kappa*mc_S;
p_S   = p_S(-1) + inflH_S - inflH;
y_S   = y - eps_ces*p_S;

// --- L-szektor (nagyvállalat) ---
y_L  = a + alpha*k_L(-1) + (1-alpha)*n_L;
w    = p_L + mc_L + y_L - n_L;
rr_L = p_L + mc_L + y_L - k_L(-1);
ret_L = (1-eps_q)*rr_L + eps_q*q_L - q_L(-1);
ret_L(+1) = r - infl(+1) + efp_L;
efp_L = chi_L*(q_L + k_L - nw_L) + tsov_L*sov + tbank_L*bank;
nw_L  = omega_nw*(nw_L(-1) + lev_L*(ret_L - (r(-1) - infl)));
q_L   = phi_i*(i_L - k_L(-1));
k_L   = (1-delta)*k_L(-1) + delta*i_L;
inflH_L = beta*inflH_L(+1) + kappa*mc_L;
// a relatívárak súlyozott összege nulla (a p_L = p_L(-1)+inflH_L-inflH
// identitás ebből és az inflH-aggregációból következik; így nincs
// felesleges egységgyök a rendszerben)
0     = sy_S*p_S + (1-sy_S)*p_L;
y_L   = y - eps_ces*p_L;

// --- árak, nyitott gazdaság ---
inflH = sy_S*inflH_S + (1-sy_S)*inflH_L;
infl  = (1-om_m)*inflH + om_m*dep;
rer   = rer(-1) + dep - infl;
r - rstar = dep(+1) - phi_b*bstar;
xx    = ystar + eta_x*rer;
imp   = c_y/(c_y+i_y)*c + i_y/(c_y+i_y)*ii - eta_m*rer;
ii    = si_S*i_S + (1-si_S)*i_L;
nn    = sn_S*n_S + (1-sn_S)*n_L;
y     = c_y*c + i_y*ii + g_y*gg + x_y*xx - m_y*imp;
bstar = (1/beta)*bstar(-1) + x_y*xx - m_y*imp;

// --- monetáris politika ---
r = rho_r*r(-1) + (1-rho_r)*(phi_pi*infl + phi_y*y) + e_m;

// --- exogén folyamatok ---
a     = rho_a*a(-1) + e_a;
gg    = rho_g*gg(-1) + e_g;
ystar = rho_ystar*ystar(-1) + e_ystar;
rstar = rho_rstar*rstar(-1) + e_rstar;
sov   = rho_sov*sov(-1) + e_sov;
bank  = rho_bank*bank(-1) + e_bank;

end;

// ---------------------------------------------------------------------
// 4. Sokkok
// ---------------------------------------------------------------------
// Euró-szcenárió jellege: a sov és bank sokk NEGATÍV (prémium-csökkenés).
// Itt egységnyi (1 százalékpont/negyedév skálájú) szórásokkal futtatunk;
// a szcenárió-kalibráció (150-250 bp szuverén, 30-60 bp banki primer)
// a determinisztikus szimulációs verzióban (v0.2) kap helyet.

shocks;
var e_a;     stderr 0.01;
var e_m;     stderr 0.0025;
var e_g;     stderr 0.01;
var e_ystar; stderr 0.01;
var e_rstar; stderr 0.0025;
var e_sov;   stderr 0.005;   // 200 bp éves = 50 bp negyedéves primer
var e_bank;  stderr 0.001;
end;

stoch_simul(order=1, irf=24, nograph) y y_S y_L ii i_S i_L efp_S efp_L
    nw_S nw_L infl r rer xx c;
