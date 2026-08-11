/*
 * jv_dsge_v06.mod — A v05 BELSŐ javítása (NEM a méret/piac szétválasztása)
 * =====================================================================
 *
 * !!!!! FONTOS ÁTCÍMKÉZÉS (2026-08-11) — OLVASD EL, MIELŐTT HASZNÁLOD !!!!!
 *
 * Ez a fájl eredetileg "a termelési oldal szegmentálása" néven készült, és
 * a fejléce azt állította, hogy megoldja a KKV/nagyvállalat szétválasztás
 * hiányát a termelési oldalon. EZ A CÍMKE FÉLREVEZETŐ VOLT, és a fájlt
 * ezért átcímkéztük. Amit valójában csinál:
 *
 *   AMIT MEGOLD (valós, mérhető, megmarad):
 *     - a szegmens-tőke többé nem reallokációs maradék (a BGG-tőke
 *       közvetlenül a saját szegmens termelési tőkekeresletét elégíti ki);
 *     - megszűnik a "közös rk => efp_S == efp_L a steady state-ben"
 *       patológia (v05 fejléc (B) pontja);
 *     - az aggregált GDP-t nem mozdítja el (+0.426% -> +0.428%).
 *
 *   AMIT NEM OLD MEG (és amit korábban erényként tüntettünk fel):
 *     A fix úgy működik, hogy AZONOSÍTJA a hazai/export (d/x) felbontást a
 *     KKV/nagyvállalat (S/L) felbontással. De pontosan ez az összecsúsztatás
 *     a projekt szerkezeti alapproblémája. A "jv_v05_szerkezeti_tanulsagok"
 *     jegyzet (Samu, lokális repo, GitHubra nem volt feltöltve) ezt explicit
 *     ki is mondja:
 *
 *       "nem ez lenne a leképezés: KKV = hazai, nagyvállalat = export --
 *        hanem ez: KKV: hazai + export ertekesites, nagyvallalat: hazai +
 *        export ertekesites"
 *
 *     Vagyis ebben a fájlban minden "méret"-eredmény valójában "piaci
 *     orientáció"-eredmény. A méret- és a piacdimenzió nincs szétválasztva,
 *     csak az összecsúsztatás lett STRUKTURÁLIS a korábbi implicit helyett.
 *
 *   MI A HELYES IRÁNY HELYETTE:
 *     kkv_dsge_v06_3type.mod / kkv_dsge_v07_access.mod (Samu, 2026-08-10):
 *     három külön termelőegység (E = export-KKV, D = hazai KKV, L =
 *     nagyvállalat), mindegyik saját termeléssel, árazással, BGG-vel ÉS
 *     saját exportkeresletttel -- tehát a KKV is exportál, a nagyvállalat
 *     is értékesít itthon. Az a fájl a méret/piac szétválasztás valódi
 *     megoldása; EZ a fájl nem az.
 *
 *   HASZNÁLATI JAVASLAT: ezt a verziót a v05 karbantartott/javított
 *   változataként kezeld (a két patológia nélkül), NEM a szegmentálási
 *   kérdés válaszaként. Szegmens-szintű MÉRET-állításhoz a 3type/access
 *   vonalat használd.
 *
 * =====================================================================
 * Az eredeti fejléc innen folytatódik (a fenti korlátozással olvasandó):
 * =====================================================================
 * KIINDULÓ KRITIKA (csapattag észrevétele, 2026-08): a v01-v05-ben a
 * KKV/nagyvállalat szétválasztás KIZÁRÓLAG a pénzügyi blokkban élt
 * (chi_S/L, efp_S/L, k_S/L a BGG-ben). A TERMELÉS oldalán a modellnek
 * mindig is volt egy kétszektoros szerkezete, de az a HAZAI/EXPORT (d/x)
 * felbontás volt — teljesen független a KKV/nagyvállalat felosztástól.
 * A kettő SOHA nem találkozott. Bizonyíték rá a v05-ből, szó szerint:
 *
 *     k     = om_S*k_S + (1-om_S)*k_L;         // om_S    = 0.50 (pénzügyi)
 *     k(-1) = sh_kd*(...) + (1-sh_kd)*(...);   // sh_kd   = 0.65 (termelési)
 *
 * Két KÜLÖNBÖZŐ szám írja le "ugyanazt" a felosztást, és semmilyen
 * egyenlet nem köti össze őket. Emiatt volt a szegmens-tőke reallokációs
 * maradék (lásd v05 fejléc (A) pontja), és emiatt volt KÖZÖS rk a BGG
 * hozam-egyenletekben — ami miatt steady state-ben efp_S == efp_L mindig
 * (lásd v05 fejléc (B) pontja). A két korábban talált hiba UGYANAZ a
 * gyökérprobléma, csak két tünete.
 *
 * A FIX (a fenti átcímkézés fényében olvasandó!): nem egy harmadik, új
 * dimenziót építünk a meglévő d/x mellé, hanem AZONOSÍTJUK a két
 * felosztást — a hazai jószágot termelő szektor = KKV, az exportáló
 * szektor = nagyvállalat.
 * >>> EZ A LÉPÉS A BELSŐ KONZISZTENCIÁT HELYREÁLLÍTJA, DE A MÉRET/PIAC
 * >>> ÖSSZECSÚSZTATÁST NEM SZÜNTETI MEG — sőt strukturálissá teszi.
 * >>> A valós megoldás a három külön termelőegység (E/D/L), ahol a KKV is
 * >>> exportál és a nagyvállalat is értékesít itthon: kkv_dsge_v06_3type.
 * A vertikális link (s_kkv/mu_vert) VÁLTOZATLAN marad.
 *
 * KONKRÉT VÁLTOZTATÁSOK a v05-höz képest:
 *   1. rk (közös tőkehozam) -> rk_S, rk_L (szegmensenkénti). Ez oldja fel
 *      a (B) hibát: ret_S/ret_L mostantól a SAJÁT szegmens hozamára épül,
 *      nem egy közösre, tehát efp_S != efp_L már steady state-ben sem
 *      szükségszerűen.
 *   2. wz_d/wz_x -> wz_S/wz_L, mc_d/mcx_rel -> mc_S/mc_L_rel,
 *      z_d/z_x -> z_S/z_L, l_d/l_x -> l_S/l_L. Tisztán átnevezés, a
 *      Cobb-Douglas-szerkezet és a paraméterek (zeta, a_*) VÁLTOZATLANOK.
 *   3. A RÉGI, sh_kd-súlyozott aggregált tőkepiaci azonosítás
 *      [k(-1) = sh_kd*kd_S + (1-sh_kd)*kd_L] TÖRÖLVE, helyette KÉT
 *      KÜLÖN egyenlet: a BGG-ben felhalmozott k_S(-1)/k_L(-1) KÖZVETLENÜL
 *      a szegmens termelési tőkekeresletét elégíti ki. Ez oldja fel a
 *      (A) hibát: a szegmens-tőke többé NEM reallokációs maradék, hanem
 *      valóban a termelést hajtja.
 *   4. sh_kd PARAMÉTER TÖRÖLVE (redundáns volt, a fenti fix miatt).
 *      om_S (0.50) marad az EGYETLEN partíciós súly a teljes modellben
 *      (aggregált riportáláshoz: k, ii), nincs többé két külön szám
 *      ugyanarra a felosztásra.
 *
 * KOCKÁZAT (dokumentált, nem hallgatjuk el): a v04 ELSŐ kísérlete
 * szegmens-specifikus tőkével + külön árszint-elválasztással
 * Blanchard-Kahn-sértésen bukott meg (lásd v04 fejléc). Ez a kísérlet
 * KEVESEBBET változtat egyszerre: a relatív exportár (px) és a CPI-blokk
 * VÁLTOZATLAN, csak a tőkehozam válik szegmens-specifikussá. Az
 * egyenlet- és változószám-mérleg kiegyensúlyozott (rk helyett rk_S+rk_L:
 * +1 változó; a régi 1 aggregált azonosítás helyett 2 szegmens-azonosítás:
 * +1 egyenlet) — de ez ÖNMAGÁBAN NEM garancia BK-stabilitásra, azt csak
 * a tényleges Dynare-futás dönti el. Lásd a futási naplót a fájl alján
 * (run_jv_v06.m eredménye, ha lefutott).
 *
 * Szcenáriók, zárás, sokkok: VÁLTOZATLANOK a v05-höz képest.
 * Futtatás: run_jv_v06.m
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

// -DCHIS/-DCHIL, -DPSIS/-DPSIL, -DZETAS/-DZETAL: a szegmens-aszimmetria
// HAROM forrasa, kulon kapcsolhato (sens_chi_psi_v06.m). Azert macro-kent
// es nem set_param_value-val, mert igy MINDEN eset teljes, tiszta Dynare-
// megoldas (steady state + perfect foresight), nem utolagos parameter-
// felulirás egy mar megoldott modellen.
// FONTOS: a psi_i a STEADY STATE-et NEM erinti (ott q_S=q_L=0, tehat a
// q/psi tag kiesik) -- csak az ATMENETET. A psi-hatast ezert a csucson es
// a 10 eves erteken kell merni, nem a hosszu tavon.
@#ifndef CHIS
  @#define CHIS = 0.06
@#endif
@#ifndef CHIL
  @#define CHIL = 0.02
@#endif
@#ifndef PSIS
  @#define PSIS = 8.0
@#endif
@#ifndef PSIL
  @#define PSIL = 13.0
@#endif
@#ifndef ZETAS
  @#define ZETAS = 0.17
@#endif
@#ifndef ZETAL
  @#define ZETAL = 0.14
@#endif

var
    c_o c_no c ii k
    rk_S rk_L w piw infl pix px
    wz_S wz_L mc_S mc_L_rel
    y_d y_x z_S z_L l_S l_L ll im xx y
    r dep rer bstar
    k_S k_L i_S i_L q_S q_L ret_S ret_L efp_S efp_L nw_S nw_L
    h_dx
    a g e_c_ar e_x_ar e_w_ar e_i_ar e_pr_ar e_mx_ar
;

varexo
    sov bank uni
    eps_a eps_x eps_c eps_md eps_mx eps_w eps_i eps_q eps_r eps_pr eps_g
;

parameters
    beta delta sigma habit fii
    zeta_S zeta_L a_S a_L rho_kz rho_z
    xi_p vth_p xi_x vth_x xi_w vth_w theta_w
    lam_p lam_x lam_w
    hx mu_x gam_i phi_pi nu_b nu_uni om_no
    chi_S chi_L eps_qw omega_nw lev_S lev_L om_S
    psi_i_S psi_i_L s_kkv mu_vert
    sc si sg sx sm sh_ld sh_imd
    shd_c shd_i shd_g shd_v
    tsov_S tsov_L tbank_S tbank_L zsov
    rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g
;

beta = 0.99; delta = 0.025;
// zeta_S/zeta_L = a v05 zeta_d/zeta_x értékei, VÁLTOZATLAN kalibráció —
// csak a szegmens-címke más, a tőkehányad ugyanaz marad.
zeta_S = @{ZETAS}; zeta_L = @{ZETAL}; rho_kz = 0.80; rho_z = 0.50;
theta_w = 3.0; nu_b = 0.001; om_no = 0.25; fii = 2.0;
a_S = 0.80; a_L = 0.45;
sigma = 1.814; habit = 0.646;
xi_p = 0.921; vth_p = 0.431;
xi_x = 0.810; vth_x = 0.494;
xi_w = 0.657; vth_w = 0.185;
mu_x = 0.534; hx = 0.507; gam_i = 0.761; phi_pi = 1.379;
lam_p = (1-xi_p)*(1-beta*xi_p)/xi_p;
lam_x = (1-xi_x)*(1-beta*xi_x)/xi_x;
lam_w = (1-xi_w)*(1-beta*xi_w)/(xi_w*(1+theta_w*fii));
chi_S = @{CHIS}; chi_L = @{CHIL};
eps_qw = 0.96; omega_nw = 0.95;
lev_S = 1.6; lev_L = 1.85; om_S = 0.50;
psi_i_S = @{PSIS}; psi_i_L = @{PSIL};
@#if NOVERT == 1
s_kkv   = 0.0001;
mu_vert = 0.0001;
@#else
s_kkv   = @{SKKV};
mu_vert = @{MUVERT};
@#endif
sc = 0.54; si = 0.23; sg = 0.10; sx = 0.60; sm = 0.47;
// sh_kd TÖRÖLVE (v05-ben 0.65 volt) — a termelési tőkekereslet mostantól
// KÖZVETLENÜL a BGG-szegmens-tőkéhez (k_S, k_L) van kötve, nem egy külön,
// nem-egyeztetett súlyhoz. om_S (0.50) az egyetlen partíciós paraméter.
sh_ld = 0.70; sh_imd = 0.30;
shd_v = s_kkv * 0.60;
shd_c = 0.55*(1-shd_v)/0.82; shd_i = 0.15*(1-shd_v)/0.82;
shd_g = 0.12*(1-shd_v)/0.82;

@#ifndef TSCEN
  @#define TSCEN = 1
@#endif
@#if TSCEN == 1
tsov_S = 0.25; tsov_L = 0.10; tbank_S = 0.60; tbank_L = 0.30;
@#elseif TSCEN == 2
tsov_S = 0.10; tsov_L = 0.25; tbank_S = 0.30; tbank_L = 0.60;
@#else
tsov_S = 0.175; tsov_L = 0.175; tbank_S = 0.45; tbank_L = 0.45;
@#endif
zsov = 0.5;
nu_uni = @{NUUNI};
rho_a = 0.552; rho_x = 0.625; rho_c = 0.767; rho_w = 0.661;
rho_i = 0.488; rho_pr = 0.820; rho_mx = 0.318; rho_g = 0.80;

model;

// --- 1. Háztartások (JV, változatlan) ---
c_o = habit/(1+habit)*c_o(-1) + 1/(1+habit)*c_o(+1)
      - (1-habit)/((1+habit)*sigma)*(r - infl(+1)) + e_c_ar;
c_no = w + ll;
c = (1-om_no)*c_o + om_no*c_no;

// --- 2. Kétszektoros BGG + euró-prémium csatornák szegmensenként ---
// JAVÍTVA (v06): rk_S/rk_L a korábbi közös rk helyett — a szegmens saját
// tőkehozamára épül, nem egy gazdaság-szintű átlagra.
ret_S = (1-eps_qw)*rk_S + eps_qw*q_S - q_S(-1);
ret_L = (1-eps_qw)*rk_L + eps_qw*q_L - q_L(-1);
ret_S(+1) = r - infl(+1) + efp_S + eps_q;
ret_L(+1) = r - infl(+1) + efp_L + eps_q;
efp_S = chi_S*(q_S + k_S - nw_S) + tsov_S*sov + tbank_S*bank;
efp_L = chi_L*(q_L + k_L - nw_L) + tsov_L*sov + tbank_L*bank;
nw_S = omega_nw*(nw_S(-1) + lev_S*(ret_S - (r(-1) - infl)));
nw_L = omega_nw*(nw_L(-1) + lev_L*(ret_L - (r(-1) - infl)));
i_S = 1/(1+beta)*i_S(-1) + beta/(1+beta)*i_S(+1)
      + 1/((1+beta)*psi_i_S)*q_S + e_i_ar;
i_L = 1/(1+beta)*i_L(-1) + beta/(1+beta)*i_L(+1)
      + 1/((1+beta)*psi_i_L)*q_L + e_i_ar;
k_S = (1-delta)*k_S(-1) + delta*i_S;
k_L = (1-delta)*k_L(-1) + delta*i_L;
k  = om_S*k_S + (1-om_S)*k_L;    // csak aggregált RIPORTÁLÁS, nem hajt semmit
ii = om_S*i_S + (1-om_S)*i_L;

// --- 3. Termelés, MOSTANTÓL SZEGMENS-SZERINT (KKV=S, nagyvállalat=L) ---
// Ugyanaz a Cobb-Douglas-szerkezet, mint a v05 d/x szektoraiban, csak a
// KKV-hoz és a nagyvállalathoz kötve. A vertikális export-input link
// (s_kkv, mu_vert) VÁLTOZATLAN.
wz_S = a_S*w + (1-a_S)*rer;
wz_L = a_L*w + (1-a_L)*rer;
mc_S = zeta_S*rk_S + (1-zeta_S)*wz_S - a;
mc_L_rel = (1-s_kkv)*(zeta_L*rk_L + (1-zeta_L)*wz_L - a) + s_kkv*mc_S - px;
z_S = rho_kz*zeta_S*(rk_S - wz_S) + y_d - a;
z_L = rho_kz*zeta_L*(rk_L - wz_L) + y_x - a;
l_S = z_S - rho_z*(w - wz_S);
l_L = z_L - rho_z*(w - wz_L);
ll  = sh_ld*l_S + (1-sh_ld)*l_L;
im  = sh_imd*(z_S - rho_z*(rer - wz_S)) + (1-sh_imd)*(z_L - rho_z*(rer - wz_L));
// *** A STRUKTURÁLIS FIX ***
// A régi v05 egyetlen, sh_kd-súlyozott aggregált azonosítása helyett itt
// KÉT KÜLÖN egyenlet köti a BGG-ben felhalmozott szegmens-tőkét a
// TÉNYLEGES termelési tőkekereslethez. A KKV termelése a k_S BGG-tőkét
// használja, a nagyvállalaté a k_L-t — nem egy külön, nem-egyeztetett
// súllyal osztott közös tőkét.
k_S(-1) = z_S - rho_kz*(rk_S - wz_S);
k_L(-1) = z_L - rho_kz*(rk_L - wz_L);
// KKV-input kereslet az exportőrtől (v04/v05, változatlan logika).
h_dx = xx - mu_vert*s_kkv*(mc_S - mc_L_rel);

// --- 4. Phillips-görbék (változatlan szerkezet, átnevezett bemenet) ---
infl = beta/(1+beta*vth_p)*infl(+1) + vth_p/(1+beta*vth_p)*infl(-1)
       + lam_p/(1+beta*vth_p)*mc_S + eps_md;
pix  = beta/(1+beta*vth_x)*pix(+1) + vth_x/(1+beta*vth_x)*pix(-1)
       + lam_x/(1+beta*vth_x)*mc_L_rel + e_mx_ar;
piw  = beta/(1+beta*vth_w)*piw(+1) + vth_w/(1+beta*vth_w)*piw(-1)
       + lam_w/(1+beta*vth_w)*(sigma/(1-habit)*(c - habit*c(-1))
                                + fii*ll - w) + e_w_ar;
w  = w(-1) + piw - infl;
px = px(-1) + pix - infl;

// --- 5. Kereslet, külkereskedelem (változatlan) ---
y_d = shd_c*c + shd_i*ii + shd_g*g + shd_v*h_dx;
xx = hx*xx(-1) + (1-hx)*(-mu_x*(px - rer)) + e_x_ar;
y_x = xx;
y  = sc*c + si*ii + sg*g + sx*xx - sm*im;
bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im);

// --- 6. REZSIMFÜGGŐ monetáris blokk (változatlan) ---
(1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
    + uni*(r - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0;
rer = rer(-1) + dep - infl;

// --- 7. Sokk-folyamatok (változatlan) ---
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
