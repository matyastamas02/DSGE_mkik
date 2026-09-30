# Review-kérés: hiányzó külföldi kereslet/kamat csatorna (`ystar`/`rstar`) visszaépítési terve

**Másold be ezt a teljes dokumentumot a ChatGPT-nek küldött üzenetbe.** Minden
szükséges kódrészlet (a jelenlegi két modellváltozatból) és a javasolt
implementációs terv is benne van — nincs szükség külön fájlmellékletre.

---

## 1. Kontextus (röviden)

Magyar euró-bevezetési/KKV New Keynesian DSGE-modell projekt (MKIK
megbízás). A repóban **két modellvonal** él:

- **EAGLE-vonal** (`kkv_dsge_v07_access.mod`) — referencia/robusztussági
  mag, Samu (kollégám) írta. Nem a fő modell, de strukturálisan gazdagabb
  a nyitott gazdasági blokkban (lásd lent).
- **JV-vonal** (`jv_dsge_v09_access.mod`, Jakab–Világi mag) — **ez a fő
  modell**, magyar adaton becsült paraméterekkel, három vállalattípussal
  (E = export-orientált KKV, D = hazai KKV, L = nagyvállalat) és egy
  hitelhozzáférési (BGG-stílusú, extenzív margós) blokkal.

A v09 a v06→v07_3type→v08_3type_arak→v09_access lépcsőzésben építette
vissza az EAGLE tudását a JV magra, **szándékosan nem másolva** az
EAGLE-egyenleteket szó szerint, hanem a gazdasági tartalmat a JV saját
specifikációjára (pl. beruházási Euler-egyenlet Tobin-Q helyett) fordítva.

**A most felmerült probléma:** Samu (a projekt egy másik tagja) írta
Messengeren:

> *"Illetve volt egy 'hiba': az eagle alapú modellből a kereskedelmi
> csatorna nem került át a v09-be."*

Ezt **közvetlenül leellenőriztem** a két `.mod` fájl összevetésével (nem
fogadtam el vakon az állítást) — az alábbiakban pontosan az van
bemutatva, amit találtam, plusz egy konkrét visszaépítési terv. **Erre
kérünk adversarial review-t: a diagnózisra ÉS a javasolt megoldásra is.**

---

## 2. Mit találtam — a jelenlegi állapot mindkét fájlból

### 2.1 EAGLE (`src/modell/2_referencia_eagle/kkv_dsge_v07_access.mod`)

**Változó- és sokk-deklarációk:**
```
var
    c c_R c_N lam w nn r infl inflH y yd ii xx imp rer dep bstar piw mrs
    ... (típusonkénti blokkok) ...
    a gg ystar rstar
    ...
varexo
    e_a e_m e_g e_ystar e_rstar
    ...
```

**Kalibráció (a külkereskedelmi/monetáris blokkhoz tartozó paraméterek):**
```
c_y = 0.61; i_y = 0.19; g_y = 0.20; x_y = 0.75; m_y = 0.75;
rho_r = 0.87; phi_pi = 1.70; phi_y = 0.10; phi_b = 0.01;
nu_uni = @{NUUNI};
om_m = 0.30; eta_x = 1.0; eta_m = 1.0;
sx_E = 0.356; sx_D = 0.065; sx_L = 0.579;
zsov = 0.5;
rho_a = 0.90; rho_g = 0.85; rho_ystar = 0.85; rho_rstar = 0.85;
```

**A modell-blokk releváns egyenletei:**
```
// --- Arak, nyitott gazdasag, aggregalas
rer   = rer(-1) + dep - infl;
yd    = c_y*c + i_y*ii + g_y*gg;
x_E   = ystar + eta_x*rer - eps_ces*p_E;
x_D   = ystar + eta_x*rer - eps_ces*p_D;
x_L   = ystar + eta_x*rer - eps_ces*p_L;
xx    = sx_E*x_E + sx_D*x_D + sx_L*x_L;
imp   = c_y/(c_y+i_y)*c + i_y/(c_y+i_y)*ii - eta_m*rer;
bstar = (1/beta)*bstar(-1) + x_y*xx - m_y*imp;

// --- Rezsimfuggo monetaris blokk
// Lebego rezsimben a regi kis SOE-zaras (phi_b) marad. Unio rezsimben
// kulon, erosebb horgony kell, kulonben a terminalis NFA mechanikusan
// nagyra ugrik: SCENARIO=1 mellett phi_b=0.01 -> bstar=-25% GDP.
(1-uni)*(r - rho_r*r(-1) - (1-rho_r)*(phi_pi*infl + phi_y*y) - e_m)
    + uni*(r - rstar - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - rstar - dep(+1) + phi_b*bstar - zsov*sov) + uni*dep = 0;

// --- Exogen folyamatok
a     = rho_a*a(-1) + e_a;
gg    = rho_g*gg(-1) + e_g;
ystar = rho_ystar*ystar(-1) + e_ystar;
rstar = rho_rstar*rstar(-1) + e_rstar;
```

**Értelmezés:** `ystar` (külföldi/eurozónás kereslet) egységnyi
rugalmassággal, additívan hajtja mindhárom típus exportkeresletét.
`rstar` (külföldi/EKB kamatláb) két helyen jelenik meg: (a) monetáris
unió rezsimben (`uni=1`) ez rögzíti a hazai kamatlábat `r = rstar +
zsov*sov - nu_uni*bstar` formában (irrevocábilis rögzített
árfolyam/euró-csatlakozás értelmezés — a hazai kamat az EKB-kamatot
követi kockázati felárral és NFA-visszacsatolással); (b) lebegő
rezsimben (`uni=0`) a fedezetlen kamatparitás (UIP) egyenletében,
ami a leértékelődést (`dep`) határozza meg.

### 2.2 JV v09 (`src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod`) — a fő modell

**Változó- és sokk-deklarációk (a teljes `varexo` blokk):**
```
var
    ...
    y_d y_x mc_d mc_x_rel ll im xx y h_dx
    // kulgazdasag, monetaris
    r dep rer bstar
    ...
    a g e_c_ar e_x_ar e_w_ar e_i_ar e_pr_ar e_mx_ar
;
varexo
    sov bank uni
;
```
**Nincs `ystar`, nincs `rstar` — sem a `var`, sem a `varexo` blokkban,
sehol a fájlban.**

**A releváns modell-egyenletek (714–728. sor):**
```
// TIPUSONKENTI exportkereslet, JV-stilusu reszleges alkalmazkodassal.
x_E = hx*x_E(-1) + (1-hx)*(-mu_x*(p_E - rer)) + e_x_ar;
x_D = hx*x_D(-1) + (1-hx)*(-mu_x*(p_D - rer)) + e_x_ar;
x_L = hx*x_L(-1) + (1-hx)*(-mu_x*(p_L - rer)) + e_x_ar;
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
```

**A releváns kalibráció:**
```
theta_w = 3.0; nu_b = 0.001; om_no = 0.25; fii = 2.0;
mu_x = 0.534; hx = 0.507; gam_i = 0.761; phi_pi = 1.379;
zsov = 0.5;
nu_uni = @{NUUNI};
hx = 0.50;      // review-racs (proxy 0.25-0.36 lefele torzithat); regi 0.507
mu_x = 0.545;   // Eurostat exportegyenlet-proxy 0.52-0.57; a regit megerositi
sc = 0.497; si = 0.267; sg = 0.203; sx = 0.829; sm = 0.796;
```
(A `sc/si/sg/sx/sm` makro-súlyok magyar nemzeti számla arányból
származnak, ez a blokk **rendben van**, nincs vele probléma — ez az
EAGLE `c_y/i_y/g_y/x_y/m_y` megfelelője, csak más forrásból kalibrálva.)

### 2.3 A pontos rés — összefoglalva

| | EAGLE (`v07_access`) | JV (`v09_access`) |
|---|---|---|
| Exportkereslet hajtóereje | saját ár/rer **+ `ystar` (külföldi kereslet)** | saját ár/rer + saját múlt + `e_x_ar` (idioszinkratikus exportár-sokk) — **nincs külföldi kereslet tag** |
| Unió-rezsim kamatszabály (`uni=1`) | `r = rstar + zsov*sov - nu_uni*bstar` | `r = zsov*sov - nu_uni*bstar` — **`rstar` hiányzik** |
| Lebegő-rezsim UIP (`uni=0`) | `dep(+1) = r - rstar + phi_b*bstar - zsov*sov` | `dep(+1) = r + nu_b*bstar - zsov*sov - e_pr_ar` — **`rstar` hiányzik** |
| Külföldi kereslet/kamat mint önálló exogén folyamat | `ystar`, `rstar` saját AR(1)-gyel, saját sokkal | **nem létezik ilyen változó a modellben** |

**Következmény:** a v09-ben jelenleg **nem lehet exogén külföldi
(eurozónás) kereslet- vagy kamatsokkot szimulálni** — csak
árfolyam/versenyképesség-vezérelt exportváltozást, vagy egy tartalom
nélküli, idioszinkratikus exportár-sokkot. Egy euró-csatlakozási
projektnél ez pont egy központi transzmissziós csatorna volna.

---

## 3. Javasolt visszaépítési terv

### 3.1 Új állapotváltozók (JV-konvencióban, nem EAGLE-névvel másolva)

A v09 a sokkfolyamatokat endogén AR(1)-ként írja (`e_x_ar = rho_x*e_x_ar(-1)
+ eps_x` mintában), nem külön nevesített `varexo`-ként — ugyanezt a
konvenciót követve:

```
// var blokkba:
ystar rstar

// varexo blokkba:
eps_ystar eps_rstar

// paraméter blokkba (ÚJ, horgonyzatlan):
rho_ystar rho_rstar

// sokk-folyamatok köze (a 730. sor körüli blokkba):
ystar = rho_ystar*ystar(-1) + eps_ystar;
rstar = rho_rstar*rstar(-1) + eps_rstar;
```

### 3.2 Bekötés az exportkeresletbe (714–716. sor helyére)

A jelenlegi részleges-alkalmazkodású JV-alak megmarad, `ystar` additív
hosszú távú hajtóerőként lép be (ugyanaz a "gazdasági tartalmat
fordítjuk le, nem az EAGLE-alakot másoljuk" elv, amit a fájl fejléce a
beruházási Euler-egyenlet `acc_j`-bekötésénél már alkalmazott):

```
x_E = hx*x_E(-1) + (1-hx)*(-mu_x*(p_E - rer) + ystar) + e_x_ar;
x_D = hx*x_D(-1) + (1-hx)*(-mu_x*(p_D - rer) + ystar) + e_x_ar;
x_L = hx*x_L(-1) + (1-hx)*(-mu_x*(p_L - rer) + ystar) + e_x_ar;
```

### 3.3 Bekötés a monetáris/UIP-blokkba (725–727. sor helyére)

Szó szerint az EAGLE-alak hiányzó tagját visszatéve mindkét ágon:

```
(1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
    + uni*(r - rstar - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - rstar - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0;
```

### 3.4 Kalibráció / nyitott döntések

- **`rho_ystar`, `rho_rstar` horgonyzatlan** — EAGLE-ben mindkettő 0,85
  (ott is kalibrált, nem becsült érték). Kiindulásnak átvehető, de a
  projekt saját paraméter-regiszterébe fel kell venni mint "átvett,
  nem magyar adaton becsült" tétel.
- **`ystar` együtthatója az exportegyenletben** — a tervben 1
  (egységnyi rugalmasság, mint EAGLE-ben). Kérdés, hogy ez helyes-e a
  JV-specifikációban, vagy kellene egy külön skálázó paraméter.
- **A csatorna tényleges kihasználásához** kellene egy szcenárió-
  specifikus `eps_ystar`/`eps_rstar` pálya (a repó egésze perfect-
  foresight szcenáriókon megy, `-DSCENARIO=1|2|3|4` makrókkal) — pl.
  egy új `-DYSTARSCEN=<x>` kapcsoló, ami a `shocks;` blokkban ad egy
  konkrét külföldi keresleti sokk-utat.

### 3.5 Bevezetési módszer (nem felülírás, hanem makró-kapcsoló)

- Javaslat: `-DFOREIGN=0|1` kapcsoló. `0` = jelenlegi viselkedés bitre
  pontosan reprodukálva (ystar/rstar kikapcsolva vagy nulla pályán),
  `1` = az új csatorna aktív. Így a korábbi eredmények (`t46`–`t55`)
  újrafuttatás nélkül is érvényben maradnak.
- **Ellenőrzési terv:** (a) nulla-sokk kontroll — `eps_ystar=eps_rstar=0`
  pálya mellett `FOREIGN=1` és `FOREIGN=0` bitre azonos eredményt kell
  adjon; (b) a determinisztikus Blanchard–Kahn állapot (terminális,
  nem csak a perfect-foresight solver-siker) újramérése — két új,
  tisztán AR(1) (lead nélküli) predetermined állapotváltozó
  szerkezetileg nem várt hogy rontson a BK-számláláson, de ezt mérni
  kell, nem feltételezni; (c) szimmetria-teszt (`-DSYM=1`) újrafuttatása.

---

## 4. Amit kérünk tőled (adversarial review, nem megerősítés)

1. **A diagnózis helyessége.** A fenti 2.3 táblázat valóban lefedi a
   teljes különbséget a két fájl nyitott gazdasági/monetáris blokkja
   között, vagy van olyan további hely (pl. a jóléti/aggregációs
   azonosságokban, vagy a `bstar` dinamikájában), ahol az EAGLE
   szintén használ `ystar`/`rstar`-t vagy azzal rokon mechanizmust,
   és ezt a fenti összevetés kihagyta?
2. **A javasolt bekötés közgazdasági/technikai helyessége.**
   - Az `ystar` additív, egységnyi együtthatós beillesztése a meglévő
     részleges-alkalmazkodású (`hx`) JV-exportegyenletbe konzisztens-e
     az EAGLE `x_E = ystar + eta_x*rer - eps_ces*p_E` alakjának
     gazdasági tartalmával, vagy torzítja a hosszú távú
     export-rugalmasságot valamilyen nem szándékolt módon (pl. mert a
     `hx` simítás miatt `ystar` hatása is csak fokozatosan érvényesül,
     miközben EAGLE-ben azonnali)?
   - Az `rstar` visszaillesztése mindkét rezsimágba (unió + lebegő)
     helyes-e úgy, ahogy fentebb írtuk, vagy a JV saját `gam_i`/`phi_pi`
     Taylor-szabálya (ami már eleve más, mint az EAGLE `rho_r`/`phi_y`
     szabálya) miatt máshogy kellene a `rstar`-t bekötni a lebegő
     rezsimbe is (EAGLE-ben ott NINCS `rstar`, csak az unió-ágban és
     az UIP-ban)?
3. **BK/determinisztikai kockázat.** Helyes-e az az érvelés, hogy két
   új, kizárólag hátranéző (AR(1), lead nélküli) állapotváltozó
   hozzáadása szerkezetileg nem növeli az előretekintő változók
   számát, tehát nem rontja a Blanchard–Kahn-számlálást — vagy van
   olyan közvetett csatorna (pl. az UIP-egyenletben megjelenő
   `dep(+1)` miatt), amin keresztül mégis hatással lehet rá?
4. **A makró-kapcsolós bevezetési terv (`-DFOREIGN=0|1`) elégséges-e**
   a "ne törjön semmi korábbi eredményt" célra, vagy hiányzik belőle
   egy lépés (pl. az `initval;` blokk kiegészítése `ystar=0; rstar=0;`
   kezdőértékkel, amit a tervben nem említettünk explicit)?
5. **Kalibrációs javaslat.** Az EAGLE `rho_ystar=rho_rstar=0.85`
   értékének kiinduló átvétele ésszerű placeholder-e egy magyar
   euró-csatlakozási modellhez, vagy van jobb, publikált referencia-
   érték (pl. eurozónás kibocsátási rés vagy EKB-kamatpálya
   perzisztenciájára), amit inkább érdemes lenne használni?
6. **Mi maradt ellenőrizetlen / mit hagytunk ki.**

**Formátum:** súlyosság szerint rendezett lista (súlyos / közepes /
apró), szakaszhivatkozással (2.1/2.2/2.3/3.x) és indoklással, majd egy
rövid összegzés a végén. Kritikus, adversarial átnézést kérünk — ha
valamelyik pontunk hibás vagy alultámasztott, ezt egyenesen mondd ki.

---

## 5. Fájlreferenciák (a repóban, csak nyilvántartás céljából)

- `src/modell/2_referencia_eagle/kkv_dsge_v07_access.mod` — EAGLE-mag,
  a fenti 2.1 szakasz forrása.
- `src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod` — JV-mag, a fő
  modell, a fenti 2.2 szakasz forrása (a releváns sorok: `var`/`varexo`
  deklaráció ~225–243. sor; exportkereslet 714–716. sor; monetáris/UIP
  blokk 725–728. sor; makro-súlyok 482–494. sor).
