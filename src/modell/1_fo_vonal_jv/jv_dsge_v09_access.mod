/*
 * jv_dsge_v09_access.mod — 4. LEPCSO: HITELHOZZAFERESI (EXTENZIV) MARGO
 *                          A JAKAB-VILAGI HAROMTIPUSOS MAGON
 * =====================================================================
 * Ezzel a JV-vonal MINDENT tud, amit a kkv_dsge_v07_access (Samu,
 * EAGLE-mag) -- de a magyar adaton BECSULT parametereken es a JV
 * gazdagabb (harominputos, import-intenzitast megkulonbozteto) termelesi
 * oldalan.
 *
 * ELOZMENY (a lepcsozetes terv):
 *   1. lepcso  jv_dsge_v06          szegmens-specifikus tokehozam   PF 18/18; BK nem merve
 *   2. lepcso  jv_dsge_v07_3type    harom tipus, kozos ar           PF 18/18; BK nem merve
 *   3. lepcso  jv_dsge_v08_3type_arak  tipusonkenti ar es kereslet  PF 18/18; BK nem merve
 *   + fuggetlen verifikacio (szimmetria, aggregacio, nulla-sokk,
 *     egymasba agyazas): 17/17 -- t43.
 *
 * =====================================================================
 * A FORDITAS: MIERT NEM MASOLHATO AT AZ EAGLE-BLOKK
 * =====================================================================
 * Samu v07_access-eben (EAGLE-mag) a beruhazas Tobin-Q-bol adodik:
 *     q_j = phi_i*(i_j - k_j(-1) - omega_acc_j*acc_j)
 * atrendezve  i_j = k_j(-1) + q_j/phi_i + omega_acc_j*acc_j,
 * vagyis az acc KOZVETLENUL, ADDITIVAN emeli a beruhazast.
 *
 * A JV-ben viszont FORDITOTT a specifikacio: a beruhazas egy
 * kiigazitasi-koltseges EULER-EGYENLETBOL jon,
 *     i_j = 1/(1+beta)*i_j(-1) + beta/(1+beta)*i_j(+1)
 *           + 1/((1+beta)*psi_j)*q_j + e_i_ar
 * Az EAGLE-alak ide nem masolhato at. A GAZDASAGI TARTALMAT forditjuk le:
 * a jobb hozzaferes tobb beruhazast enged be ADOTT q mellett -- tehat az
 * acc a beruhazasi Euler ADDITIV forcing tagjakent lep be:
 *     ... + omega_acc_j*acc_j
 * A hozzaferesi allapot dinamikaja valtozatlanul Samu alakjaban:
 *     acc_j = rho_acc*acc_j(-1) - lambda_acc_j*efp_j
 * (a felar csokkenese javitja a hozzaferest), es a NAGYVALLALATNAK
 * NINCS acc-margoja -- ugyanugy, mint a v07_access-ben.
 *
 * FONTOS: mivel a specifikacio nem azonos, az ACCSCALE ertekei NEM
 * feleltethetok meg egy-az-egyben a v07_access ACCSCALE-jenek. A KUSZOB
 * (mekkora hozzaferesi reakcio kell a KKV-elonyhoz) ezert kulon
 * szamolando ezen a magon -- lasd sens_access_kuszob_v09.m.
 *
 * =====================================================================
 * MIT ORAKOL A v08-BOL (valtozatlanul)
 * =====================================================================
 * - harom tipus (E/D/L) sajat tokevel, tokehozammal, input-kompozittal,
 *   hatarkoltseggel, BGG-blokkal;
 * - tipusonkenti relativar, inflacio, Phillips-gorbe, hazai CES-kereslet
 *   es exportkereslet;
 * - a relativar-normalizacio (0 = sum wd_j*p_j), ami a v01-ben
 *   dokumentalt egyseggyokot kikeruli;
 * - -DSYM=1 szimmetria-teszt es -DSCENARIO=4 nulla-sokk kontroll.
 *
 * !! A v08 KORLATAI TOVABBRA IS ALLNAK !!
 * Az eps_ces (CES helyettesites a tipusok kozott) horgonyzatlan, es az
 * export-KKV kibocsatasanak elojele rajta fordul (~2.3-nal). Az access
 * bevezetese ezt NEM oldja meg -- ket kulon horgonyzatlan parameter lesz
 * (eps_ces es ACCSCALE), tehat a szektoralis eredmenyt KETTOS
 * kuszobformaban kell kozolni.
 *
 * Szcenariok: -DSCENARIO=1|2|3|4, -DTSCEN=1|2|3, -DACCSCALE=<0..150>,
 *             -DLAMSCALE=<x>, -DOMSCALE=<x>, -DEPSCES=<x>, -DSYM=1,
 *             -DNOVERT=1, -DNUUNI=<x>, -DOPTEN=0|1|2|3, -DRHOACC=<x>,
 *             -DDECOMP=0|1|2|3|4, -DDECOMPW=0|1
 * Futtatas:   stress_jv_access_v09.m, stress_opten_v09.m,
 *             sens_lam_om_v09.m (2D kuszobfelulet), dekomp_edl_v09.m
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
// -DACCSCALE=0 -> az access-csatorna KIKAPCSOLVA, a modell PONTOSAN a
// v08-at adja vissza (nesting-teszt). 100 = Samu baseline-janak megfelelo
// parameterertekek atvetele.
@#ifndef ACCSCALE
  @#define ACCSCALE = 100
@#endif
// --- -DLAMSCALE / -DOMSCALE: AZ ACCSCALE SZETBONTASA --------------------
// MIERT KELL (kulso biralat, 2026-08-21; korlatok-riport 1. teendo).
// Az ACCSCALE EGYETLEN szamkent KET kulon mechanizmust skalazott:
//     1. lepcso  felar -> hozzaferes        lambda_acc_j
//     2. lepcso  hozzaferes -> beruhazas    omega_acc_j
// A hosszu tavu beruhazasi hatas -omega*lambda/(1-rho_acc)*efp, tehat az
// ACCSCALE NEGYZETEVEL aranyos, nem a szintjevel. Kovetkezmeny: a kozolt
// "22.3-as kuszob" NEM egy rugalmassagon van, hanem KETTO SZORZATAN,
// ELORE ROGZITETT lambda:omega arany mellett -- es maga az arany
// (2.0:2.5 illetve 0.35:0.45) is atvett ertek a v07_access-bol. Igy a
// szam onmagaban nem interpretalhato.
//
// Ezert a ket lepcso kulon kapcsolot kap, es a kuszobot nem egy
// szamkent, hanem a (lambda, omega) sikon KETDIMENZIOS FELULETKENT
// kozoljuk (sens_lam_om_v09.m -> t52 / t52b).
//
// VISSZAFELE KOMPATIBILITAS: az alapertelmezes -1 = "nincs beallitva",
// ilyenkor MINDKETTO az ACCSCALE-t orokli, tehat minden korabbi futas
// (t44/t47/t48/t49/t51) valtozatlanul reprodukalodik. A sens_lam_om_v09.m
// (0) pontja ezt regresszios orkent le is meri.
@#ifndef LAMSCALE
  @#define LAMSCALE = -1
@#endif
@#ifndef OMSCALE
  @#define OMSCALE = -1
@#endif
@#if LAMSCALE < 0
  @#define LAMEFF = ACCSCALE
@#else
  @#define LAMEFF = LAMSCALE
@#endif
@#if OMSCALE < 0
  @#define OMEFF = ACCSCALE
@#else
  @#define OMEFF = OMSCALE
@#endif
// --- -DDECOMP: E/D/L DEKOMPOZICIOS SCAN ---------------------------------
// MIERT KELL (korlatok-riport 2. teendo / 7. szakasz).
// A harom tipus ELEVE kulonbozo technologiat kapott: a zeta_j es az aa_j
// a JV export-/hazai szektorabol van ATVIVE, nem becsulve. Ha az E es a D
// maskepp reagal, abban benne van az is, hogy mi adtunk nekik mas
// termelesi parametert. A referee elso kerdese ez lesz: "show me that
// your main conclusion is not an artifact of the E/D/L calibration."
//
// A kapcsolo egyszerre EGY heterogenitas-dimenziot hagy meg, a tobbit
// kozos ertekre allitja:
//   0 = KI (ALAPERTELMEZES; minden marad ugy, ahogy volt)
//   1 = A ag: CSAK phi_j (piaci orientacio) heterogen
//   2 = B ag: CSAK a penzugyi parameterek (chi, lev, psi, access)
//   3 = C ag: CSAK aa_j (import-intenzitas, a magyar dualis szerkezet)
//   4 = D ag: minden TECHNOLOGIAI parameter (zeta_j, aa_j) AZONOS; a
//             phi_j es a penzugyi heterogenitas marad -> a maradek
//
// ERTELMEZESI DONTES: mi legyen a "kozos ertek"? A -DDECOMPW=1
// (alapertelmezes) a MERETSULYOZOTT (om_j) atlagot hasznalja, mert az
// hagyja valtozatlanul az aggregalt technologiat -- igy a scan tisztan az
// ATRENDEZODES hatasat meri, nem egy szint-eltolodast. A -DDECOMPW=0 az
// egyszeru szamtani atlag: robusztussagi ellenproba, hogy a kovetkeztetes
// ne a semlegesites modjan mulljon.
//
// TECHNIKA: nem vezetunk be uj parametert (a regiszter 91 tetele igy
// valtozatlan marad). Az atlagot eloszor az EGYIK tipus parameterebe
// irjuk -- a jobb oldal ilyenkor meg vegig EREDETI ertekeket lat --,
// utana masoljuk a masik kettobe.
@#ifndef DECOMP
  @#define DECOMP = 0
@#endif
@#ifndef DECOMPW
  @#define DECOMPW = 1
@#endif
// -DOPTEN: 13 tipus-parameter forrasa es egy leiro rho-erzekenysegi pont
// (s15_opten_kalibracio.m).
//   0 = atvett indulo ertekek a kkv_dsge_v07_access-bol (ALAPERTELMEZES,
//       hogy a korabbi eredmenyek valtozatlanul reprodukalhatok legyenek)
//   1 = Opten-panel, ALAP szegmensdefinicio (E = barmilyen pozitiv export,
//       azonos az s14 hozzaferesi szamaival)
//   2 = Opten-panel, KUSZOB25 definicio (E = export_arany >= 25%)
//   3 = CSAK a leiro 0.9673 rho-erzekenysegi pont, minden mas atvett indulo
//       marad. Ez NEM horgony: a 0->3 lepes a rho-felteves hatasa, a 3->1
//       lepes a sulyoke es a tokeattetele.
// A kapcsolo azert kell felulíras helyett, mert az om_j/shl_j sulyok a
// 10+ fos populacion BELULI reszesedesek (a mikrocegek nincsenek a
// panelben), tehat NEM cserelhetok le vita nelkul -- lasd a
// t46-os tabla (1) korlatjat.
@#ifndef OPTEN
  @#define OPTEN = 0
@#endif

var
    // haztartas es aggregatumok
    c_o c_no c ii k
    // arak, berek -- TIPUSONKENTI ar es inflacio (3. lepcso)
    w piw infl px
    p_E p_D p_L pi_E pi_D pi_L
    // tipusonkenti kereslet (3. lepcso)
    d_E d_D d_L x_E x_D x_L
    // hitelhozzaferesi allapot -- CSAK a KKV-tipusoknak (4. lepcso)
    acc_E acc_D
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
    rho_acc lambda_acc_E lambda_acc_D omega_acc_E omega_acc_D
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
// Munka-sulyok: a v07 sn_* foglalkoztatasi reszesedesei. ITT allitjuk be,
// nem lejjebb a szarmaztatott sulyoknal: korabban a -DSYM=1 shl-beallitasa
// (1/3, 1/3, 1/3) HOLT KOD volt, mert egy kesobbi sor felulirta. A
// szimmetria-teszt eredmenyet ez nem valtoztatta meg (a harom suly osszege
// mindket esetben 1, es szimmetriaban l_E==l_D==l_L), de a sorrend igy
// egyertelmu, es az -DOPTEN felulíras is ide tud kapcsolodni.
shl_E = 0.20; shl_D = 0.50; shl_L = 0.30;

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

// --- -DOPTEN: EMPIRIKUS UJRAKALIBRACIO + RHO-ERZEKENYSEG -----------------
// Forras: src/s15_opten_kalibracio.m -> output/tables/t46_opten_kalibracio.csv
// Panel: 148 225 ceg-ev, 37 805 ceg, 2021-2024, 10+ fos cegek.
// A delta szegmensfuggetlen kalibracio; a rho_acc szinten kozos, de
// horgonyzatlan erzekenysegi felteves. A sajat helyukon vannak felulirva
// (delta itt, rho_acc a penzugyi blokk vegen).
//
// AMIT AZ ADAT MEGERSIT:
//   phi_L = 0.3649 vs a jelenlegi 0.365 -- gyakorlatilag azonos, tehat az
//     atvett ertek MAR EBBOL A PANELBOL szarmazhatott (fuggetlen proba).
//   delta = 0.0242 negyedeves vs a jelenlegi 0.0250 -- 3%-on belul.
// AMIT AZ ADAT MEGCAFOL:
//   lev_E = lev_D KENYSZERITETT EGYENLOSEG NEM ALL: 1.939 vs 1.719, azaz
//     az exportalo KKV TOKEATTETELESEBB, mint a hazai. Az iranyt a masik
//     merteke (kotelezettsegek/eszkozok -> 1.684 vs 1.579) is megerositi,
//     a SZINT viszont mero-fuggo -- ezert a szintre nem, csak az IRANYRA
//     hivatkozzunk.
// LEIRO RHO-ERZEKENYSEGI PONT (NEM KALIBRACIO):
//   A 0.9673 cegszintu hitelstatusz-perzisztencia mechanikusan ~4.5-szeresere
//   emeli a hosszu tavu access-szorzot 0.85-hoz kepest. A cegek 92.4%-a negy
//   ev alatt egyszer sem valtott, igy ez foleg allando heterogenitast tukroz;
//   nem dinamikus szegmens-rho-becsles es nem also korlat. Lasd t47.
@#if OPTEN == 1
// ALAP szegmensdefinicio (E = barmilyen pozitiv export; azonos az s14-gyel)
om_E = 0.2555; om_D = 0.1844; om_L = 0.5601;
shl_E = 0.1566; shl_D = 0.3775; shl_L = 0.4659;
// FIGYELEM: phi_D = 0 ebben a definicioban DEFINICIO SZERINTI nulla (a D
// szegmens epp a nem-exportalo cegeke), nem meres. Emiatt wx_D = 0 -- az
// x_D valtozot a sajat exportkereslet-egyenlete tovabbra is meghatarozza,
// csak az aggregatumokba nem szamit bele. Ha ez zavaro, hasznald az
// -DOPTEN=2-t, ahol a D szegmens kis exportot is tartalmaz.
phi_E = 0.3757; phi_D = 0.0000; phi_L = 0.3649;
lev_E = 1.9385; lev_D = 1.7185; lev_L = 2.3374;
delta = 0.0242;
@#endif
@#if OPTEN == 2
// KUSZOB25 (E = export_arany >= 25%): kozelebb all a modell "export-
// orientalt KKV" fogalmahoz, es a phi_D itt ertelmes szam.
om_E = 0.1287; om_D = 0.3112; om_L = 0.5601;
shl_E = 0.0749; shl_D = 0.4592; shl_L = 0.4659;
phi_E = 0.6911; phi_D = 0.0227; phi_L = 0.3649;
lev_E = 1.9314; lev_D = 1.7351; lev_L = 2.3374;
delta = 0.0242;
@#endif

// -DSYM=1: SZIMMETRIA-TESZT. Minden tipus-specifikus parametert azonosra
// allit. Ekkor a harom tipusnak DEFINICIO SZERINT azonosan kell viselkednie
// (y_E == y_D == y_L, es a v08-ban p_E == p_D == p_L == 0). Ha nem igy van,
// a szerkezetben hiba van -- ez fuggetlen ellenorzes a BK-teszt mellett.
@#ifndef SYM
  @#define SYM = 0
@#endif
@#if SYM == 1
phi_E = 0.30; phi_D = 0.30; phi_L = 0.30;
zeta_E = 0.155; zeta_D = 0.155; zeta_L = 0.155;
aa_E = 0.60; aa_D = 0.60; aa_L = 0.60;
chi_E = 0.04; chi_D = 0.04; chi_L = 0.04;
lev_E = 1.7; lev_D = 1.7; lev_L = 1.7;
psi_E = 10.5; psi_D = 10.5; psi_L = 10.5;
om_E = 1/3; om_D = 1/3; om_L = 1/3;
shl_E = 1/3; shl_D = 1/3; shl_L = 1/3;
tsov_E = 0.175; tsov_D = 0.175; tsov_L = 0.175;
tbank_E = 0.45; tbank_D = 0.45; tbank_L = 0.45;
@#endif

// --- -DDECOMP: A HETEROGENITAS-DIMENZIOK SZETVALASZTASA ------------------
// Itt all, mert (a) minden tipus-specifikus parameter mar megkapta a
// vegleges erteket (alap -> OPTEN -> SYM), es (b) a szarmaztatott sulyok
// (wd_j / wx_j / shm_j) MEG NEM keszultek el -- azok igy automatikusan a
// dekomponalt phi_j / aa_j ertekekbol allnak elo, tehat a modell belsoleg
// konzisztens marad. Az access-parametereket (lambda_acc, omega_acc) a
// sajat helyukon, a fajl vegen kezeljuk.
@#if DECOMP > 0
@#if DECOMPW == 1
@#define AVG3_PHI  = "om_E*phi_E + om_D*phi_D + om_L*phi_L"
@#define AVG3_ZETA = "om_E*zeta_E + om_D*zeta_D + om_L*zeta_L"
@#define AVG3_AA   = "om_E*aa_E + om_D*aa_D + om_L*aa_L"
@#define AVG3_CHI  = "om_E*chi_E + om_D*chi_D + om_L*chi_L"
@#define AVG3_LEV  = "om_E*lev_E + om_D*lev_D + om_L*lev_L"
@#define AVG3_PSI  = "om_E*psi_E + om_D*psi_D + om_L*psi_L"
@#else
@#define AVG3_PHI  = "(phi_E + phi_D + phi_L)/3"
@#define AVG3_ZETA = "(zeta_E + zeta_D + zeta_L)/3"
@#define AVG3_AA   = "(aa_E + aa_D + aa_L)/3"
@#define AVG3_CHI  = "(chi_E + chi_D + chi_L)/3"
@#define AVG3_LEV  = "(lev_E + lev_D + lev_L)/3"
@#define AVG3_PSI  = "(psi_E + psi_D + psi_L)/3"
@#endif

// zeta_j (tokehanyad): MINDEN agon kozos. Az 1/2/3 agban azert, mert nem
// az a vizsgalt dimenzio; a 4. agban azert, mert epp az a lenyeg.
zeta_L = @{AVG3_ZETA}; zeta_E = zeta_L; zeta_D = zeta_L;

@#if DECOMP == 1 || DECOMP == 2 || DECOMP == 4
// aa_j: kozos. A C agban (3) EZ az egyetlen, ami heterogen marad.
aa_L = @{AVG3_AA}; aa_E = aa_L; aa_D = aa_L;
@#endif

@#if DECOMP == 2 || DECOMP == 3
// phi_j: kozos. Az A agban (1) EZ marad egyedul heterogen; a D agban (4)
// szandekosan marad heterogen, mert nem technologiai parameter.
phi_L = @{AVG3_PHI}; phi_E = phi_L; phi_D = phi_L;
@#endif

@#if DECOMP == 1 || DECOMP == 3
// penzugyi blokk: kozos. A B (2) es a D (4) agban marad heterogen.
chi_L = @{AVG3_CHI}; chi_E = chi_L; chi_D = chi_L;
lev_L = @{AVG3_LEV}; lev_E = lev_L; lev_D = lev_L;
psi_L = @{AVG3_PSI}; psi_E = psi_L; psi_D = psi_L;
@#endif
@#endif

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

// (Munka-sulyok: feljebb, a tipus-sulyoknal -- lasd az ottani indoklast.)
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
// --- Hitelhozzaferesi margo (Samu v07_access ertekei, ACCSCALE-lel skalazva)
// FIGYELEM: HORGONYZATLAN. Az s14 szerint magyar 2021-24 adatbol NEM is
// horgonyozhato (a tamogatott programok kiiktattak a kamatciklust a
// KKV-hozzaferesbol). Kuszobformaban kozlendo.
rho_acc = 0.85;
// -DOPTEN>=1: az Opten-panel van_hitel atmenet-matrixabol szamolt LEIRO
// cegszintu statusz-perzisztencia. A pooled mutato rho_eves = p11-p01 =
// 0.8754 (n = 110 350 ceg-ev par), negyedevesen 0.8754^(1/4) = 0.9673.
// A cegek 92.4%-a negy ev alatt egyszer sem valtott, ezert a magas mutato
// foleg allando cegheterogenitast tukroz. NEM a modell dinamikus,
// SZEGMENS-szintu rho_acc parameterenek becslese, es NEM also korlat.
// A rho_acc tovabbra is horgonyzatlan; a 0.9673 csak erzekenysegi pont.
@#if OPTEN >= 1
rho_acc = 0.9673;
@#endif
// -DRHOACC=<x>: a rho_acc kozvetlen felulirasa (minden mas valtozatlan).
// AZERT KELL, mert a hosszu tavu access-hatas 1/(1-rho_acc)-kal aranyos,
// ami rho -> 1 kozeleben ROBBAN: 0.85 -> 6.7x, 0.95 -> 20x, 0.98 -> 50x.
// Horgony nelkul a teljes tartomanyt scanben kell kozolni (t49).
@#ifndef RHOACC
  @#define RHOACC = -1
@#endif
@#if RHOACC > 0
rho_acc = @{RHOACC};
@#endif
// A ket lepcso KULON skalazhato (-DLAMSCALE / -DOMSCALE). Ha egyiket sem
// adjuk meg, mindketto az ACCSCALE-t orokli -> bitre azonos a korabbival.
lambda_acc_E = 2.0*(@{LAMEFF}/100); lambda_acc_D = 2.5*(@{LAMEFF}/100);
omega_acc_E  = 0.35*(@{OMEFF}/100); omega_acc_D = 0.45*(@{OMEFF}/100);
@#if DECOMP == 1 || DECOMP == 3
// A / C ag: a penzugyi heterogenitast az ACCESS-bol is ki kell venni,
// kulonben az ag nem tiszta. FIGYELEM: ez CSAK az E-D kulonbseget tunteti
// el (2.0 vs 2.5, illetve 0.35 vs 0.45). A nagyvallalatnak DEFINICIO
// SZERINT nincs acc-egyenlete (omega_acc_L = 0), es azt ez a kapcsolo NEM
// semlegesiti -- az kulon teendo (korlatok-riport 4. pont).
@#if DECOMPW == 1
lambda_acc_D = (om_E*lambda_acc_E + om_D*lambda_acc_D)/(om_E+om_D);
omega_acc_D  = (om_E*omega_acc_E  + om_D*omega_acc_D )/(om_E+om_D);
@#else
lambda_acc_D = (lambda_acc_E + lambda_acc_D)/2;
omega_acc_D  = (omega_acc_E  + omega_acc_D )/2;
@#endif
lambda_acc_E = lambda_acc_D;
omega_acc_E  = omega_acc_D;
@#endif
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
// --- HITELHOZZAFERESI MARGO (4. lepcso) --------------------------------
// A felar csokkenese javitja a hozzaferest (korabban hitelkorlatos cegek
// bekerulnek a beruhazasi korbe). A nagyvallalatnak NINCS ilyen margoja.
acc_E = rho_acc*acc_E(-1) - lambda_acc_E*efp_E;
acc_D = rho_acc*acc_D(-1) - lambda_acc_D*efp_D;
// A jobb hozzaferes ADOTT q mellett is tobb beruhazast enged be -> additiv
// forcing tag a JV beruhazasi Euler-egyenletben (lasd fejlec: A FORDITAS).
i_E = 1/(1+beta)*i_E(-1) + beta/(1+beta)*i_E(+1)
      + 1/((1+beta)*psi_E)*q_E + omega_acc_E*acc_E + e_i_ar;
i_D = 1/(1+beta)*i_D(-1) + beta/(1+beta)*i_D(+1)
      + 1/((1+beta)*psi_D)*q_D + omega_acc_D*acc_D + e_i_ar;
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
@#elseif SCENARIO == 3
endval;
sov = -0.00375; bank = -0.0005; uni = 1;
end;
@#else
// SCENARIO=4: NULLA SOKK (ellenorzo eset). Minden valtozonak vegig 0-nak
// kell lennie -- ha nem, valahol konstans szivarog be a modellbe.
endval;
sov = 0; bank = 0; uni = 0;
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
@#elseif SCENARIO == 3
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
@#else
shocks;
var uni; periods 1:12; values 0;
end;
@#endif

perfect_foresight_setup(periods=120);
perfect_foresight_solver;
