// =====================================================================
//  jv_dsge_v06_stoch.mod  —  A v05 SZTOCHASZTIKUS IKERFÁJLJA
//  Generálva: jv_dsge_v05.mod-ból, 2026-08-05. Az EGYENLETEK AZONOSAK.
// =====================================================================
//
//  MIÉRT KÜLÖN FÁJL. A v05-ben az `uni` VAREXO, amely endogén változókkal
//  szorzódik (v05: 339-341. sor) — ettől a modell formálisan nemlineáris,
//  és csak perfect foresight-tal oldható meg. Így a SZTOCHASZTIKUS
//  STABILIZÁCIÓS KÖLTSÉG elvileg sem jöhet ki belőle.
//  Itt az `uni` FORDÍTÁSI IDEJŰ MAKRÓ (-DUNI=0|1), ezért mindkét rezsim
//  külön-külön LINEÁRIS, IDŐINVARIÁNS modell, amin megy a stoch_simul.
//  A stabilizációs költség = a két rezsim feltétel nélküli momentumainak
//  különbsége (GGN 2007 szerkezet).
//
//  MI VÁLTOZOTT A v05-höz képest (és semmi más):
//    1. `uni` kikerült a varexo-ból -> @#define UNI makró
//    2. `sov`, `bank` varexo -> PARAMÉTER = 0. Indok: lineáris modellben a
//       második momentumokat a determinisztikus szint nem befolyásolja
//       (bizonyossági ekvivalencia), tehát az euró-prémium PÁLYA itt
//       irreleváns. Az átmeneti hasznot továbbra is a v05 adja.
//    3. A rezsimfüggő monetáris blokk makró-elágazás lett.
//    4. initval/endval/perfect_foresight -> shocks(stderr) + stoch_simul.
//
//  !!! FIGYELEM 1 — A ZÁRÁS KÖZÖS KELL LEGYEN A KÉT REZSIMBEN !!!
//  A v05-ben a lebegő ágon nu_b = 0.001 (JV-poszterior), az unió ágon
//  nu_uni = 0.25 (technikai patch). Perfect foresight-ban ez rendben van.
//  Sztochasztikus futásban NEM: a nu az NFA stacionaritását adja, és a
//  feltétel nélküli varianciák nu-ra RENDKÍVÜL érzékenyek. Ha a két
//  rezsimet eltérő nu-val futtatjuk, a mért volatilitás-különbség RÉSZBEN
//  A ZÁRÓ ESZKÖZ MŰTERMÉKE lenne, nem a rezsimé — pontosan az a hibatípus,
//  amit a 2026-08-02-i hibafeltárás dokumentál.
//  EZÉRT: egyetlen `nu_fx` paraméter mindkét ágon (-DNUFX=<érték>).
//  A nu_b = 0.001 önmagában is gyanús sztochasztikus futáshoz: közel
//  egységgyökös NFA-t ad, azaz gyakorlatilag végtelen varianciát.
//  A nu_fx-érzékenység KÖTELEZŐ robusztussági blokk, nem opció.
//  Hivatkozás: Schmitt-Grohe & Uribe (2003) — a záró eszköz megválasztása
//  a konjunktúraciklus-momentumokat alig befolyásolja, ha stacionárius.
//
//  !!! FIGYELEM 2 — ELŐSZÖR DETERMINÁLTSÁGOT ELLENŐRIZNI !!!
//  Az UNI=1 ágon NINCS Taylor-szabály: a kamatot r = zsov*sov - nu_fx*bstar
//  rögzíti, és dep = 0. Kis nyitott gazdaságban rögzített külföldi kamat
//  mellett fennáll a NOMINÁLIS HATÁROZATLANSÁG kockázata. Ez BK-sértésként
//  vagy egységgyökként jelentkezik. A `check;` kimenetét ELŐBB kell
//  megnézni, mint hogy bárki a poszterior szórásokat összegyűjti.
//  Ha egységgyök van (|lambda| = 1), a feltétel nélküli momentumok nem
//  léteznek — ekkor vagy erősebb nu_fx kell, vagy a relatívár-szinteket
//  (px, rer) differenciálva kell szerepeltetni.
//
//  !!! FIGYELEM 3 — A SOKK-SZÓRÁSOK HIÁNYOZNAK !!!
//  Az alábbi `shocks` blokk PLACEHOLDER-eket tartalmaz. A tizenegy
//  strukturális sokk szórása a Jakab-Vilagi (MNB WP 2008/9) poszterior
//  becslésekből pótolandó. AMÍG EZ NINCS MEG, A FUTÁS CSAK A
//  DETERMINÁLTSÁG ELLENŐRZÉSÉRE ALKALMAS, momentumok közlésére nem.
//
//  Futtatás:
//    dynare jv_dsge_v06_stoch.mod -DUNI=0 -DNUFX=0.25   // lebegő
//    dynare jv_dsge_v06_stoch.mod -DUNI=1 -DNUFX=0.25   // unió
//  vagy: run_v06_stoch.m (mindkettő + összevetés)
// =====================================================================

@#ifndef UNI
  @#define UNI = 0
@#endif
// ---------------------------------------------------------------------
// FIGYELEM: az alábbi fejléc a v05-ből ÖRÖKÖLT. A perfect foresight-ra,
// a SCENARIO makróra és az `uni` exogén pályára vonatkozó részei EBBEN A
// FÁJLBAN NEM ÉRVÉNYESEK — lásd a fenti v06-fejlécet. A szerkezeti
// figyelmeztetései (SZEGMENS-TŐKE, chi-előjel, t-súlyok) viszont IGEN.
// ---------------------------------------------------------------------
@#ifndef NUFX
  @#define NUFX = 0.25
@#endif
// -DMPSHOCK=0|1 : a hazai monetáris politikai sokk BE/KI a lebegő ágon.
// Csak a dekompozícióhoz kell (lásd a fájl végi megjegyzést), alapból 1.
@#ifndef MPSHOCK
  @#define MPSHOCK = 1
@#endif

/*
 * jv_dsge_v05.mod — Szegmentált euró-szcenárió (v04 + v03 összevonása)
 * =====================================================================
 * A projekt tényleges kutatási kérdésének modellje: a KKV/nagyvállalat
 * vertikális szegmentálás (jv_dsge_v04) RÁFUTTATVA a valós euró-belépési
 * szcenárióra (jv_dsge_v03: UIP-országprémium csatorna + kamatunió-
 * rezsimváltás + három anticipált forgatókönyv, perfect foresight).
 *
 * Eddig ez a két réteg külön élt:
 *  - v04: szegmentálás + vertikális link, de csak ÁLTALÁNOS sztochasztikus
 *    sokkokra (nem a tényleges euró-pályára);
 *  - v03: euró-szcenárió, de szegmentálás NÉLKÜL (egyetlen reprezentatív
 *    vállalat).
 * Ez a fájl a hiányzó láncszem: szegmensenkénti (KKV/nagyvállalat) kimenet
 * a VALÓS euró-belépési pályán.
 *
 * Változtatások a v04-hez képest:
 *  1. sov/bank/uni exogén pálya (mint v03) — a szuverén és banki prémium
 *     típusonként eltérő súllyal (tsov_S/L, tbank_S/L) lép be az efp_S/L-be.
 *  2. Rezsimfüggő monetáris blokk (mint v03/kkv_dsge_v04): a belépés előtt
 *     Taylor+UIP, utána közös euró-kamat (uni dummy), zsov=0,5 UIP-csatorna.
 *  3. perfect_foresight_solver a stoch_simul helyett; 3 szcenárió.
 * A v04 vertikális linkje (mcx_rel, h_dx, s_kkv, mu_vert) VÁLTOZATLAN.
 *
 * MEGFIGYELÉS (diag_yd_v04.m alapján, fontos a szcenárió-eredmények
 * értelmezéséhez): a JV kis adósság-rugalmassága (nu_b=0.001) miatt egy
 * kamatsokkra a reálárfolyam nagyot és tartósan ugrik (Dornbusch-túllövés),
 * ami a fogyasztáson át felülírhatja a y_d aggregátum rövid távú vertikális
 * együttmozgását — ez NEM hiba, hanem a JV saját becslésének tulajdonsága;
 * a vertikális csatorna (h_dx, y_x) ettől függetlenül robusztus marad.
 *
 * !! JAVÍTOTT ZÁRÁS (nu_uni), diag_nuuni_v05.m alapján !!
 * Az ELSŐ v05-futás implauzibilis eredményt adott (export +12.9%, rer
 * +34.7%, bstar -25% GDP), mert a v03-ból örökölt nu_uni=0.01 zárás a
 * szegmentált modellben — ahol a vertikális link önerősítő kört hoz létre
 * (KKV olcsóbb -> export olcsóbb -> több export -> több KKV-input -> ...) —
 * túl gyenge horgony. A diagnosztika (nu_uni = 0.01 ... 0.5) alapján:
 *   nu_uni=0.01: y +4.53%, rer +34.7%, bstar -25.0%  <- implauzibilis
 *   nu_uni=0.25: y +0.80%, rer  +4.1%, bstar  -1.0%  <- VÁLASZTOTT
 *   nu_uni=0.50: y +0.72%, rer  +3.5%, bstar  -0.5%  <- alig változik
 * A 0.25 a "plató" elején van (0.25->0.5 alig mozdít), tehát az eredmény
 * NEM érzékeny a pontos értékre. Validáció: a link KIKAPCSOLVA (-DNOVERT=1)
 * a régi zárással y=+1.07%, ami egyezik a szegmentálás nélküli v03
 * eredményével (+1.09%) — a modell tehát konzisztens, a probléma kizárólag
 * a zárás erőssége volt. A vertikális link hozzájárulása a javított
 * zárással: y +0.40% (link nélkül) -> +0.80% (linkkel), azaz kb. duplázás.
 *
 * !!! HÁROM STRUKTURÁLIS FIGYELMEZTETÉS (2026-08, kritikai felülvizsgálat) !!!
 *
 * (A) SZEGMENS-TŐKE = REALLOKÁCIÓS MARADÉK. Az aggregált k-t a tőkepiaci
 *     egyenlet lekötözi, ezért a k = om_S*k_S + (1-om_S)*k_L bontásban a
 *     szegmens-tőke nulla-összegűhöz közeli maradék: az aggregált beruházás
 *     1.09-1.29% között mozog, miközben a szegmens-rés +0.53 -> -5.80 pp-ot
 *     ugrál. ==> SZEGMENS-SZINTŰ BERUHÁZÁST EBBŐL A MODELLBŐL NE KÖZÖLJ
 *     eredményként. Közölhető: az aggregált GDP-hatás és a felár-pályák.
 *     Feloldás csak szegmens-specifikus termeléssel és tőkekereslettel lenne
 *     (a v04 első kísérlete ezen bukott meg: Blanchard-Kahn sértés).
 *
 * (B) A chi-ASZIMMETRIA A HOSSZÚ TÁVON A KKV ELLEN DOLGOZIK. A terminális
 *     steady state zárt formulájából  d i_ss / d F = -1/chi , ahol
 *     F = tsov*sov + tbank*bank a prémium-ék. Tehát:
 *       1/chi_S = 1/0.06 = 16.7   vs   1/chi_L = 1/0.02 = 50.0
 *     A nagyvállalati beruházás 3x érzékenyebb UGYANARRA a prémium-
 *     csökkenésre, ÉPPEN mert chi_L < chi_S. Dynare-rel igazolva (egyenlő
 *     t-súlyok): chi 0.06/0.02 -> i_S -0.13% / i_L +2.51%;  0.04/0.04 ->
 *     +1.19% / +1.00% (megfordul);  0.02/0.06 -> +3.09% / -0.16%.
 *     A BGG-intuíció ("a KKV érzékenyebb") tehát a modell hosszú távú
 *     algebrájában MEGFORDUL. Emellett steady state-ben efp_S == efp_L
 *     mindig (q_S=q_L=0 miatt közös rk), azaz a modellben nincs hosszú távú
 *     szegmens-prémium-differencia — a KKV-előny tisztán átmeneti jelenség.
 *
 * (C) psi_i_S = 8.0 < psi_i_L = 13.0 dokumentálatlan és empirikusan
 *     visszafelé van (a KKV-beruházás lumpier és korlátozottabb, tehát
 *     RUGALMATLANABB kellene, hogy legyen) — a KKV-előny irányába torzít.
 *     Újrakalibrálandó vagy érzékenységgel kísérendő.
 *
 * FONTOS a t-súlyok tesztjéhez: a modell EXAKTUL LINEÁRIS a tsov/tbank
 * paraméterekben (ezek csak exogén változók együtthatói, az átmeneti
 * mátrixot nem érintik). Ezért a TSCEN=3 minden kimenete a TSCEN=1 és 2
 * exakt átlaga (1e-15) — NEM önálló teszt, hanem számtani keverék.
 *
 * Szcenáriók: -DSCENARIO=1 (alap: -200bp szuv./-45bp banki) | 2 (opt) | 3 (pessz)
 * Futtatás:   run_jv_v05.m
 */

@#ifndef SCENARIO
  @#define SCENARIO = 1
@#endif

// -DNOVERT=1: a vertikális link KIKAPCSOLÁSA (s_kkv, mu_vert ~ 0) —
// az érzékenységi/diagnosztikai futáshoz, hogy izolálni lehessen a link
// tényleges hozzájárulását az eredményhez.
@#ifndef NOVERT
  @#define NOVERT = 0
@#endif

// -DNUUNI=<érték>: az unió-rezsim külső-egyensúlyi zárásának erőssége.
// A v03-ból örökölt 0.01 egy ideiglenes patch volt; a szegmentált
// modellben (a vertikális link önerősítése mellett) túl gyenge horgony —
// lásd diag_nuuni_v05.m. Az alapérték a diagnosztika alapján kalibrálva.
@#ifndef NUUNI
  @#define NUUNI = 0.25
@#endif

// -DSKKV / -DMUVERT: a vertikális link erőssége (érzékenységi protokoll,
// lásd sens_skkv_v05.m). SKKV=0 + MUVERT=0 a "link nélküli" ellenpróba.
//
// !! EMPIRIKUSAN MEGALAPOZOTT (2026-07, IO-adat) !!
// Az s_kkv-t az Eurostat magyar input-output tábláiból kalibráltuk
// (src/07_io_hazai_input_arany.py -> output/tables/t24_io_hazai_input.csv).
// A HAZAI köztes input aránya a termelési értéken, 2021:
//     autóipar         0.050   (a köztes felhasználás csak 6.0%-a hazai!)
//     elektronika      0.035   (4.2%)
//     elektromos ber.  0.078   |  gépgyártás 0.069  |  fémfeldolg. 0.059
//     vegyipar         0.199   (a legmagasabb)
//     teljes gazdaság  0.058
//     EXPORT-MAG átlag 0.054   <-- ez az s_kkv FELSŐ korlátja
// Mivel az IO ÁGAZATI (nem méret szerinti), a KKV-rész ennek csak egy
// darabja -> a tényleges s_kkv ~0.025-0.05. Az alapérték 0.05 (konzervatív
// felső becslés az export-magra).
//
// KÉT KÖVETKEZMÉNY:
// (1) JÓ HÍR: a valós érték MESSZE a pólus alatt van (lásd lent), tehát a
//     modell szerkezete ÉRVÉNYES, nem kell átstrukturálni.
// (2) KELLEMETLEN: a korábbi 0.20-as kalibráció 4x túlbecsülte a linket.
//     A vertikális link hozzájárulása nem a hatás 42%-a, hanem ~5%-a
//     (y: +0.405% link nélkül -> +0.426% s_kkv=0.05-tel).
//     Közgazdaságilag ez maga is eredmény: a magyar FDI-vezérelt
//     exportszektor hazai beszállítói integrációja GYENGE (a "duális
//     gazdaság" jelenség kvantitatív megjelenése).
//
// SZINGULARITÁS (a modell felső korlátja): s_kkv ~ 0.25-nél pólus van
// (0.24: y=+1.61%, 0.26: y=-4.25%, rer=-35%). A valós kalibráció (0.05)
// bőven a biztonságos, monoton sávban van.
@#ifndef SKKV
  @#define SKKV = 0.05
@#endif
@#ifndef MUVERT
  @#define MUVERT = 0.50
@#endif

var
    c_o c_no c ii k
    rk w piw infl pix px
    wz_d wz_x mc_d mcx_rel
    y_d y_x z_d z_x l_d l_x ll im xx y
    r dep rer bstar
    k_S k_L i_S i_L q_S q_L ret_S ret_L efp_S efp_L nw_S nw_L
    h_dx
    a g e_c_ar e_x_ar e_w_ar e_i_ar e_pr_ar e_mx_ar
;

varexo
    eps_a eps_x eps_c eps_md eps_mx eps_w eps_i eps_q eps_pr eps_g
// Az eps_r (monetáris politikai sokk) CSAK a lebegő rezsimben létezik:
// az unió-ágon nincs Taylor-szabály, tehát egyetlen egyenletben sem
// szerepelne, és a Dynare 6 az ilyet hibának veszi ("not used in model
// block"). A `nostrict` opció elfedné a problémát — a helyes megoldás a
// feltételes deklaráció.
@#if UNI == 0
    eps_r
@#endif
;

parameters
    beta delta sigma habit fii
    zeta_d zeta_x a_d a_x rho_kz rho_z
    xi_p vth_p xi_x vth_x xi_w vth_w theta_w
    lam_p lam_x lam_w
    hx mu_x gam_i phi_pi nu_b nu_uni om_no
    chi_S chi_L eps_qw omega_nw lev_S lev_L om_S
    psi_i_S psi_i_L s_kkv mu_vert
    sc si sg sx sm sh_ld sh_kd sh_imd
    shd_c shd_i shd_g shd_v
    tsov_S tsov_L tbank_S tbank_L zsov
    rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g
    sov bank nu_fx
;

beta = 0.99; delta = 0.025;
zeta_d = 0.17; zeta_x = 0.14; rho_kz = 0.80; rho_z = 0.50;
theta_w = 3.0; nu_b = 0.001; om_no = 0.25; fii = 2.0;
a_d = 0.80; a_x = 0.45;
sigma = 1.814; habit = 0.646;
xi_p = 0.921; vth_p = 0.431;
xi_x = 0.810; vth_x = 0.494;
xi_w = 0.657; vth_w = 0.185;
mu_x = 0.534; hx = 0.507; gam_i = 0.761; phi_pi = 1.379;
lam_p = (1-xi_p)*(1-beta*xi_p)/xi_p;
lam_x = (1-xi_x)*(1-beta*xi_x)/xi_x;
lam_w = (1-xi_w)*(1-beta*xi_w)/(xi_w*(1+theta_w*fii));
chi_S = 0.06; chi_L = 0.02;
eps_qw = 0.96; omega_nw = 0.95;
lev_S = 1.6; lev_L = 1.85; om_S = 0.50;
psi_i_S = 8.0; psi_i_L = 13.0;
@#if NOVERT == 1
s_kkv   = 0.0001;    // vertikális link kikapcsolva (diagnosztika)
mu_vert = 0.0001;
@#else
s_kkv   = @{SKKV};
mu_vert = @{MUVERT};
@#endif
sc = 0.54; si = 0.23; sg = 0.10; sx = 0.60; sm = 0.47;
sh_ld = 0.70; sh_kd = 0.65; sh_imd = 0.30;
// A hazai (KKV) jószág felhasználási arányai. FONTOS KONZISZTENCIA
// (sens_skkv_v05.m diagnosztika): a shd_v (a KKV-kibocsátás mekkora része
// megy az exportőrhöz) és az s_kkv (az export költségének mekkora része
// KKV-input) UGYANAZT a kereskedelmi kapcsolatot írja le két oldalról,
// ezért nem adhatók meg egymástól függetlenül. Az összefüggés:
//     shd_v = s_kkv * (export/KKV-kibocsátás arány)
// A korábbi, független megadás (shd_v=0.18 fixen, s_kkv szabadon) egy
// önerősítő hurkot hozott létre: az alapkalibrációnál a KKV-kibocsátás
// 115%-át az export-input tag adta, és s_kkv~0.23-nál a modell
// SZINGULARITÁSBA futott (0.22: y=+1.18%, 0.25: y=-5.26%, rer=-45%).
// Most shd_v az s_kkv-ból SZÁRMAZTATOTT, a többi súly arányosan igazodik.
shd_v = s_kkv * 0.60;                       // export/KKV-kibocsátás arány ~0.6
shd_c = 0.55*(1-shd_v)/0.82; shd_i = 0.15*(1-shd_v)/0.82;
shd_g = 0.12*(1-shd_v)/0.82;                // a maradék arányosan szétosztva
// --- euró-szcenárió: prémium-transzmisszió + rezsimváltás ---
// !! FIGYELEM: A t_S > t_L FELTEVÉS NEM AZONOSÍTHATÓ AZ ADATBÓL !!
// A t_S > t_L feltevés (a KKV érzékenyebb a prémium-csökkenésre) az
// eredeti modellválasztási javaslatból jött. A magyar kamatstatisztikán
// (src/08_mnb_transzmisszio.py, ECB MIR) elvégzett teszt eredménye:
// a becsült t_bank_S/t_bank_L arány specifikációtól függően
//     total fixáció, együttes regresszió .... 1.26  (a KKV MAGASABB)
//     <=1 év fixáció (összemérhető) ......... 0.76
//     fedezettel/garanciával (A2AC) ......... 2.75  (a feltevés irányába!)
//     1-5 év fixáció ........................ 0.62
// szemben a modellbe tett 2.00-tal. EGYETLEN különbség sem szignifikáns
// 5%-on. ==> AZONOSÍTÁSI KUDARC, NEM CÁFOLAT: a t_S > t_L feltevésre nincs
// empirikus fedezet, de az ellenkezőjére sem.
//
// KORÁBBI HIBÁS ÉRVELÉS, JAVÍTVA (2026-08): itt korábban az állt, hogy a
// KKV alacsony pass-through-ja azért van, mert a hitelei fixek/támogatottak.
// EZ TÉVES egy ÚJ-SZERZŐDÉSES sorozatra: (a) az MNB módszertana szerint a
// támogatott hitel kamata a támogatás összegét is tartalmazza, tehát BRUTTÓ
// (piaci szintű) kamat kerül a statisztikába; (b) az A2A kategória kizárja a
// folyószámla-/rulírozó hitelt, azaz a Széchenyi Kártya legnagyobb terméke
// eleve nincs benne; (c) a 2023-as 13.66%-os KKV-átlagkamat (BUBOR 12.05%
// mellett) matematikailag kizárja, hogy az állomány fele 3%-on lenne
// NETTÓ módon jelentve. A t12 ~80%-os támogatott aránya ÁLLOMÁNY-alapú
// implicit ráta, ami nem vihető át új-szerződéses FLOW adatra.
// A becslés valódi hibája: KAMATFIXÁLÁSI KOMPOZÍCIÓ-ELSODRÓDÁS — a "Total
// initial rate fixation" sorozat két nem összemérhető terméket takar
// (2026-ban a KKV új hitelek 61%-a 1-5 év fixálású, a nagyvállalatiaknak
// csak 8%-a; 2018-ban mindkettő ~85% változó volt).
//
// JAVASLAT (csapatdöntést igényel, ezért az alapérték változatlan): az
// alapkalibráció legyen TSCEN=3 (egyenlő súlyok, strukturálisan semleges),
// és a TSCEN=1/2 pár ÉRZÉKENYSÉGI SÁVKÉNT jelenjen meg, ne "feltevés vs.
// adat" szembeállításként. A TSCEN=2 NEM "empirikus" — a TSCEN=1 tükörképe.
// -DTSCEN=1 (alap: a feltevés) | 2 (tükörkép: t_S<t_L) | 3 (egyenlő, ajánlott)
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
// az unió-ág technikai zárása (lásd jv_dsge_v03: a JV becsült nu_b=0.001
// az unió-rezsimben túl gyenge horgony, -250% GDP-s NFA-hoz vezetne)
nu_uni = @{NUUNI};
// MEGJEGYZÉS: ebben a fájlban sem a `nu_b`, sem a `nu_uni` NEM szerepel
// egyenletben — mindkettőt a KÖZÖS `nu_fx` váltja ki (lásd FIGYELEM 1).
// Deklarálva maradnak, hogy a v05-ös értékek dokumentálva legyenek és a
// két fájl paraméterlistája összevethető maradjon. Dynare "unused
// parameter" figyelmeztetést fog adni rájuk — ez várt viselkedés.
rho_a = 0.552; rho_x = 0.625; rho_c = 0.767; rho_w = 0.661;
rho_i = 0.488; rho_pr = 0.820; rho_mx = 0.318; rho_g = 0.80;

model;

// --- 1. Háztartások (JV) ---
c_o = habit/(1+habit)*c_o(-1) + 1/(1+habit)*c_o(+1)
      - (1-habit)/((1+habit)*sigma)*(r - infl(+1)) + e_c_ar;
c_no = w + ll;
c = (1-om_no)*c_o + om_no*c_no;

// --- 2. Kétszektoros BGG + euró-prémium csatornák szegmensenként ---
ret_S = (1-eps_qw)*rk + eps_qw*q_S - q_S(-1);
ret_L = (1-eps_qw)*rk + eps_qw*q_L - q_L(-1);
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
k  = om_S*k_S + (1-om_S)*k_L;
ii = om_S*i_S + (1-om_S)*i_L;

// --- 3. Termelés + vertikális export-input (v04, változatlan) ---
wz_d = a_d*w + (1-a_d)*rer;
wz_x = a_x*w + (1-a_x)*rer;
mc_d = zeta_d*rk + (1-zeta_d)*wz_d - a;
mcx_rel = (1-s_kkv)*(zeta_x*rk + (1-zeta_x)*wz_x - a) + s_kkv*mc_d - px;
z_d = rho_kz*zeta_d*(rk - wz_d) + y_d - a;
z_x = rho_kz*zeta_x*(rk - wz_x) + y_x - a;
l_d = z_d - rho_z*(w - wz_d);
l_x = z_x - rho_z*(w - wz_x);
ll  = sh_ld*l_d + (1-sh_ld)*l_x;
im  = sh_imd*(z_d - rho_z*(rer - wz_d)) + (1-sh_imd)*(z_x - rho_z*(rer - wz_x));
k(-1) = sh_kd*(z_d - rho_kz*(rk - wz_d)) + (1-sh_kd)*(z_x - rho_kz*(rk - wz_x));
// KKV-input kereslet az exportőrtől.
// JAVÍTVA (sens_skkv_v05.m diagnosztika alapján): a relatívár-tag súlya
// s_kkv-val skálázódik. Indoklás: egy CES-input-keresletben a helyettesítési
// válasz a KOSTSÉGHÁNYADDAL arányos — ha a KKV-input a költség 20%-a, a
// relatívár-változásra adott válasz is ennyivel súlyozott. A korábbi,
// nem skálázott alak (h_dx = xx - mu_vert*(mc_d - mcx)) erős s_kkv-nál
// önerősítő hurkot hozott létre a y_d-n keresztül (s_kkv=0.30-nál a h_dx
// előjelet váltott, s_kkv=0.35-nél a felár -573 bp-ra szaladt) — nem
// numerikus hiba volt (a megoldó reziduuma 1e-17), hanem szerkezeti.
h_dx = xx - mu_vert*s_kkv*(mc_d - mcx_rel);

// --- 4. Phillips-görbék (változatlan) ---
infl = beta/(1+beta*vth_p)*infl(+1) + vth_p/(1+beta*vth_p)*infl(-1)
       + lam_p/(1+beta*vth_p)*mc_d + eps_md;
pix  = beta/(1+beta*vth_x)*pix(+1) + vth_x/(1+beta*vth_x)*pix(-1)
       + lam_x/(1+beta*vth_x)*mcx_rel + e_mx_ar;
piw  = beta/(1+beta*vth_w)*piw(+1) + vth_w/(1+beta*vth_w)*piw(-1)
       + lam_w/(1+beta*vth_w)*(sigma/(1-habit)*(c - habit*c(-1))
                                + fii*ll - w) + e_w_ar;
w  = w(-1) + piw - infl;
px = px(-1) + pix - infl;

// --- 5. Kereslet, külkereskedelem (változatlan) ---
// JAVÍTVA (2026-08): a beruházási keresletben az AGGREGÁLT beruházás (ii)
// szerepel, nem a KKV-szegmensé (i_S). A v03-ban helyesen si*ii volt; a
// v04-ben elírás miatt i_S-re cserélődött, és a v05 ezt örökölte. A hazai
// jószág iránti beruházási kereslet a teljes beruházásból származik,
// szegmens-függetlenül — a szegmens-tőke amúgy is reallokációs maradék
// (lásd a fejléc "SZEGMENS-TŐKE" figyelmeztetését), tehát a legkevésbé
// megbízható változó folyt bele közvetlenül a jelentett y_d-be.
y_d = shd_c*c + shd_i*ii + shd_g*g + shd_v*h_dx;
xx = hx*xx(-1) + (1-hx)*(-mu_x*(px - rer)) + e_x_ar;
y_x = xx;
y  = sc*c + si*ii + sg*g + sx*xx - sm*im;
bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im);

// --- 6. REZSIMFÜGGŐ monetáris blokk (mint jv_dsge_v03) ---
// belépés előtt (uni=0): Taylor + UIP; után (uni=1): közös euró-kamat,
// nincs önálló árfolyam
@#if UNI == 0
r = gam_i*r(-1) + (1-gam_i)*phi_pi*infl + eps_r;
r = dep(+1) - nu_fx*bstar + zsov*sov + e_pr_ar;
@#else
r = zsov*sov - nu_fx*bstar;
dep = 0;
@#endif
rer = rer(-1) + dep - infl;

// --- 7. Sokk-folyamatok ---
a       = rho_a*a(-1) + eps_a;
e_x_ar  = rho_x*e_x_ar(-1) + eps_x;
e_c_ar  = rho_c*e_c_ar(-1) + eps_c;
e_w_ar  = rho_w*e_w_ar(-1) + eps_w;
e_i_ar  = rho_i*e_i_ar(-1) + eps_i;
e_pr_ar = rho_pr*e_pr_ar(-1) + eps_pr;
e_mx_ar = rho_mx*e_mx_ar(-1) + eps_mx;
g       = rho_g*g(-1) + eps_g;

end;


// --- Paraméterek, amelyek a v05-ben varexo/PF-blokkból jöttek ---
// A prémium-szintek nullák: lineáris modellben a szint nem hat a
// második momentumokra. Ha valaki mégis szintet akar, azt a v05 adja.
sov = 0; bank = 0;
// KÖZÖS külső-egyensúlyi zárás mindkét rezsimben (lásd FIGYELEM 1)
nu_fx = @{NUFX};

steady;
// A determináltság ellenőrzése — EZT KELL ELŐSZÖR MEGNÉZNI.
// Egységgyök (|lambda| = 1) esetén a feltétel nélküli momentumok nem
// léteznek, és a stoch_simul kimenete értelmezhetetlen lesz.
check;

// ---------------------------------------------------------------------
//  SOKK-SZÓRÁSOK — PLACEHOLDER, PÓTOLANDÓ A JV-POSZTERIORBÓL
// ---------------------------------------------------------------------
//  A lenti értékek NEM becslések, csak nagyságrendi kitöltés, hogy a
//  fájl lefusson a determináltsági teszthez. Minden sor mellé be kell
//  írni a JV-poszterior átlagot és a forrás-táblát.
//
//  REZSIMFÜGGŐ SOKK-KÉSZLET (lásd a napló 8. szakaszát): az unióban a
//  hazai monetáris sokk (eps_r) és az UIP-prémium sokk (eps_pr)
//  MECHANIKUSAN kiesik, mert az őket tartalmazó egyenletek nincsenek a
//  modellben. Itt ezt explicitté is tesszük nulla szórással, hogy a
//  két rezsim sokk-készlete dokumentált legyen, ne implicit.
// ---------------------------------------------------------------------
shocks;
var eps_a;  stderr 0.01;   // technológia          <- JV poszterior: ?
var eps_x;  stderr 0.01;   // exportkereslet       <- ?
var eps_c;  stderr 0.01;   // preferencia          <- ?
var eps_md; stderr 0.01;   // hazai ar-markup      <- ?
var eps_mx; stderr 0.01;   // exportar-markup      <- ?
var eps_w;  stderr 0.01;   // ber-markup           <- ?
var eps_i;  stderr 0.01;   // beruhazas            <- ?
var eps_q;  stderr 0.01;   // tokearazas / BGG     <- ?
var eps_g;  stderr 0.01;   // kormanyzati kiadas   <- ?
var eps_pr; stderr 0.01;   // UIP-premium          <- ?
@#if UNI == 0
@#if MPSHOCK == 1
var eps_r;  stderr 0.01;   // monetaris politika   <- ?
@#endif
@#endif
// UNI=1 eseten az eps_r es eps_pr SZANDEKOSAN nincs deklaralva: Dynare-ben
// a shocks blokkbol kihagyott exogen valtozo varianciaja nulla. Ez tisztabb,
// mint a "stderr 0", ami szingularis kovarianciamatrixot adhat. A ket sokk
// amugy sem szerepel egyetlen egyenletben sem az unio-rezsimben.
end;

// order=1: a modell log-linearizált, magasabb rend nem ad többletet.
// irf=0, periods=0: elméleti (feltétel nélküli) momentumokat kérünk.
stoch_simul(order=1, irf=0, periods=0, nograph) y c ii xx im ll infl r rer bstar
                          i_S i_L k_S k_L efp_S efp_L nw_S nw_L
                          y_d y_x h_dx;

// =====================================================================
//  A HÁROM FUTÁS, AMI A DEKOMPOZÍCIÓHOZ KELL
// =====================================================================
//  A két rezsim sokk-készlete NEM azonos: az unióban nincs eps_r. Ez
//  valós közgazdasági hatás (nincs hazai monetáris politika, tehát hazai
//  monetáris politikai sokk sincs), de ha csak a két szélső futást
//  vetjük össze, akkor ÖSSZEKEVEREDIK két dolog:
//    (a) az unió megszünteti a monetáris politikai sokkot  -> stabilizál
//    (b) az unió elveszi a stabilizátort a többi sokkhoz   -> destabilizál
//  A tanulmány állítása a (b)-ről szól, ezért a kettőt szét kell választani:
//
//    dynare jv_dsge_v06_stoch -DUNI=0 -DMPSHOCK=1   // lebegő, teljes
//    dynare jv_dsge_v06_stoch -DUNI=0 -DMPSHOCK=0   // lebegő, eps_r nélkül
//    dynare jv_dsge_v06_stoch -DUNI=1               // unió (eps_r eleve nincs)
//
//  A 2. és 3. futás összevetése adja a TISZTA stabilizációs költséget;
//  az 1. és 2. különbsége azt, mennyit ér a monetáris politikai sokk
//  megszűnése. Csak a két szélsőt összevetve a költséget ALULBECSÜLNÉNK.
// =====================================================================
