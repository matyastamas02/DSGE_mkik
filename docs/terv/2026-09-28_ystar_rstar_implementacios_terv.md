# Külföldi kereslet/kamat csatorna (`ystar`/`rstar`) visszaépítése — végső implementációs terv

*2026-09-28 · Tomi. Előzmény: Samu jelezte, hogy az EAGLE-mag (`kkv_dsge_v07_access.mod`)
külkereskedelmi csatornája nem került át a JV fő modellbe
(`jv_dsge_v09_access.mod`) — ezt megerősítettem a kód közvetlen összevetésével.
Az első tervet ([`2026-09-28_tomi_chatgpt_review_ystar_rstar_terv.md`](2026-09-28_tomi_chatgpt_review_ystar_rstar_terv.md))
adversarial review-ra küldtem; a review egy valódi diagnosztikai hibát talált
(lásd 1. szakasz) és több konkrét, kód-alapú hiányosságot a bevezetési tervben.
Ez a dokumentum a **javított, implementálásra kész terv** — csak azután
kerüljön branch-re, hogy Samuval egyeztettünk (ő piszkálja épp ezt a fájlt).*

> **2. review-kör (2026-09-28):** a tervet adversarial review-ra küldtük
> újra — a válasz szerint az egyenletek és a fő szerkezet alapján
> implementálható, három érdemi kiegészítéssel: (1) a három új paraméter
> tényleges, kapcsolható érték-hozzárendelése hiányzott (4.2b szakasz,
> most pótolva), (2) a 91/94-es regiszterellenőrzést implementációkor kell
> megoldani, nem csak eredményközlés előtt (6. szakasz, most kéttrackesre
> bővítve), (3) névütközés volt a tervben (`rho_rstar`/`eps_r_for` a
> ténylegesen deklarált `rho_rfor`/`eps_rfor` helyett — D6 sor, javítva).
> Mindhárom pontot közvetlenül a dokumentumban ellenőriztem és javítottam.
> Ezekkel a javításokkal a terv **jóváhagyott**.

---

## 1. Korrigált diagnózis

**Az eredeti tervben tévesen "idioszinkratikus exportár-sokként" jellemeztem
az `e_x_ar`-t. Ez hibás volt — leellenőrizve a kódból:**

```
x_E = hx*x_E(-1) + (1-hx)*(-mu_x*(p_E - rer)) + e_x_ar;
x_D = hx*x_D(-1) + (1-hx)*(-mu_x*(p_D - rer)) + e_x_ar;   // (713-716. sor)
x_L = hx*x_L(-1) + (1-hx)*(-mu_x*(p_L - rer)) + e_x_ar;
e_x_ar = rho_x*e_x_ar(-1) + eps_x;                          // rho_x = 0.625
```

`e_x_ar` **közös** (mindhárom típusban ugyanaz), és **exportkeresleti** hatás
(közvetlenül az `x_j` szintbe megy be) — nem idioszinkratikus, és nem
exportár-sokk. (Az exportár/markup-sokk `e_mx_ar`, de az csak a `pi_L`
Phillips-görbében szerepel — az exporthoz semmi köze.)

**Következmény:** ha `ystar`-t változatlan `e_x_ar` mellett vezetnénk be, a
két csatorna részben ugyanazt a szerepet töltené be (mindkettő közös,
mindhárom típusra egyformán ható exportkeresleti tag) — anélkül, hogy
`ystar` megfigyelt lenne, a szétválasztásukat csak az előre rögzített
perzisztencia-paraméterek végeznék, nem az adat. Ezért **`e_x_ar`-t nem
hagyjuk változatlanul** — lásd 3. szakasz, D1 döntés.

---

## 2. Mit mutat az EAGLE-referencia (emlékeztető)

```
// EAGLE, kkv_dsge_v07_access.mod
var ... a gg ystar rstar;
varexo e_a e_m e_g e_ystar e_rstar;
rho_a = 0.90; rho_g = 0.85; rho_ystar = 0.85; rho_rstar = 0.85;
...
x_E = ystar + eta_x*rer - eps_ces*p_E;   // es x_D, x_L ugyanigy
...
(1-uni)*(r - rho_r*r(-1) - (1-rho_r)*(phi_pi*infl + phi_y*y) - e_m)
    + uni*(r - rstar - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - rstar - dep(+1) + phi_b*bstar - zsov*sov) + uni*dep = 0;
...
ystar = rho_ystar*ystar(-1) + e_ystar;
rstar = rho_rstar*rstar(-1) + e_rstar;
```

**Fontos, a review 9. pontja nyomán tisztázva:** az EAGLE-fájlban VAN
`ystar`/`rstar`, de a repóban futtatott korábbi EAGLE-forgatókönyvek
`shocks;` blokkjai **nem aktiválták** az `e_ystar`/`e_rstar` innovációkat —
tehát a korábbi EAGLE-futások **nem validálják** sem a `0,85` értéket, sem a
csatorna euró-csatlakozási viselkedését. Ennek jó oldala: a JV-ből való
eddigi hiányuk valószínűleg nem torzította a korábbi, nulla-külső-sokkos
JV-forgatókönyveket sem.

---

## 3. Tervezési döntések (a review nyomán lezárva)

| # | Kérdés | Döntés | Indoklás |
|---|---|---|---|
| D1 | `e_x_ar` és `ystar` viszonya | `ystar` = megfigyelt/exogén külső kereslet; `e_x_ar` marad, de **átcímkézve** "közös reziduális exportkeresleti sokk"-ként (nem idioszinkratikus, nem árhatás). `rho_x=0,625`-öt **nem** becsüljük újra ebben a körben. | A review 1. pontja. A re-becslés külön munka (identifikációs kérdés — lásd 9. szakasz), amíg nincs meg, ez tudatosan vállalt közelítés, nem végleges megoldás. **Érvényességi határ (2. review-kör):** ez a megoldás a jelenlegi, **determinisztikus perfect-foresight** kiterjesztéshez elfogadható, KÜLÖNÖSEN ha a `ystar`-t használó (`-DFOREIGN=1`) forgatókönyvekben `eps_x=0`-t írunk elő. Sztochasztikus becsléshez, vagy ha egyszerre aktiválunk `ystar`- és `eps_x`-sokkot, az azonosítás **még nem megfelelő** — ez explicit korlátja a tervnek, nem hallgatólagosan megoldott kérdés. |
| D2 | `ystar` együtthatója az exportegyenletben | Külön `eta_ystar` paraméter, NEM beégetett 1-es. | A review 5. pontja: ha a `(1-hx)` zárójelen belül marad `eta_ystar*ystar`, a hosszú távú multiplikátor `eta_ystar`, a becsapódási hatás `(1-hx)*eta_ystar` — ezt explicit paraméterként kell tartani, nem hallgatólagos feltételezésként. |
| D3 | `FOREIGN=0` viselkedés | **Fordítási idejű** (`@#if`) kizárás — deklarációk ÉS egyenletek is, nem csak nulla-pálya. | A review 2. pontja: nulla pálya mellett is más a modell (82 vs. 80 endogén változó, 2 új AR-egyenlet), ez sérti a `t54` regiszter-őr 91-es paraméterszám-ellenőrzését. |
| D4 | `rho_ystar`/`rho_rstar` kalibráció | **Érzékenységi rács** (0,40 / 0,625 / 0,85), explicit "nem becsült, érzékenységi pont" címkével, NEM egyetlen, irodalmilag megalapozottként bemutatott érték. | A review 8. pontja + a saját `rho_x=0,625` egyezése egy állítólagos MNB WP 2008/9 forrással — **ez utóbbi nincs általam leellenőrizve**, lásd 9. szakasz. |
| D5 | Névválasztás | `rstar` → **`r_for`** | A review apró pontja: `rstar` könnyen összekeverhető a természetes reálkamattal; a repóban ütközés nincs, de a névváltás olcsó és tisztább. `ystar` marad (nincs hasonló kockázat). |
| D6 | Szintpálya vs. innováció | Forgatókönyv-építéskor mindig `eps_rfor_t = r_for_t - rho_rfor*r_for_{t-1}` (és `eps_ystar_t = ystar_t - rho_ystar*ystar_{t-1}`) — SOHA nem írjuk közvetlenül a kívánt szintet az `eps_*` sokkba. | A review 3. pontja — enélkül az AR-folyamat felhalmozná a beírt értékeket, más pályát adva, mint a szándékolt. **Névhasználat:** kizárólag a ténylegesen deklarált `rho_rfor`/`eps_rfor` nevek (NEM `rho_rstar`/`eps_r_for`) — a 2. review-kör 3. pontja szerint az első kiadás itt névütközést tartalmazott. |
| D7 | Counterfactual-konzisztencia | Az euró-csatlakozási és a nem-csatlakozási ellenpontban **ugyanazt** a külföldi (`ystar`/`r_for`) pályát kell használni. | A review 3. pontja — különben a számított különbség nem tisztán a csatlakozás hatása. |
| D8 | BK-ellenőrzés | Ténylegesen lefuttatva `bk_check_metrics`-szel (kezdeti `uni=0` ÉS terminális `uni=1` állapotra), nem csak érveléssel ("nincs új forward változó") alátámasztva. | A review 7. pontja + a `CLAUDE.md` saját, korábban rögzített elve: "BK-teszt nem elég… kell független verifikáció". |

---

## 4. Implementáció — lépésről lépésre

### 4.1 Makró-kapcsoló (a fájl elején, a többi `@#ifndef` mellé, ~78. sor környékére)

```
@#ifndef FOREIGN
  @#define FOREIGN = 0
@#endif
```

`FOREIGN=0` az alapértelmezés — **minden korábbi eredmény (`t46`–`t55`)
változatlanul, fordítási idejű kizárással, érintetlen marad.**

### 4.2 Új változók/paraméterek — fordítási idejű kizárással

A `var`/`varexo`/paraméter blokkokban (kb. 225–267. sor környékén, a
meglévő blokkok végére):

```
var
    ...
    a g e_c_ar e_x_ar e_w_ar e_i_ar e_pr_ar e_mx_ar
@#if FOREIGN == 1
    ystar r_for
@#endif
;

varexo
    sov bank uni
@#if FOREIGN == 1
    eps_ystar eps_rfor
@#endif
;

parameters
    ...
@#if FOREIGN == 1
    rho_ystar rho_rfor eta_ystar
@#endif
;
```

### 4.2b Kalibrációs érték-hozzárendelés (kötelező, a 2. review-kör 1. pontja szerint)

A puszta deklaráció önmagában **inicializálatlan** paramétereket hagy — a
tényleges értéket makró-kapcsolóval kell beállítani, hogy az 5. szakasz
érzékenységi rácsa `-D` argumentumokkal tisztán futtatható legyen. A
kalibrációs blokkba (a többi `rho_*` érték mellé, ~589. sor környékére):

```
@#ifndef RHOYSTAR
  @#define RHOYSTAR = 0.625
@#endif
@#ifndef RHORFOR
  @#define RHORFOR = 0.625
@#endif
@#ifndef ETAYSTAR
  @#define ETAYSTAR = 1.0
@#endif

@#if FOREIGN == 1
rho_ystar = @{RHOYSTAR};
rho_rfor  = @{RHORFOR};
eta_ystar = @{ETAYSTAR};
@#endif
```

Így az 5. szakasz érzékenységi rácsa (`0,40 / 0,625 / 0,85`) egyszerű
`-DFOREIGN=1 -DRHOYSTAR=0.40` stílusú hívásokkal futtatható, a repó összes
többi kapcsolójával (`-DACCSCALE`, `-DTSCEN` stb.) azonos konvencióban.

### 4.3 Exportegyenletek (714–716. sor helyére)

```
@#if FOREIGN == 1
x_E = hx*x_E(-1) + (1-hx)*(-mu_x*(p_E - rer) + eta_ystar*ystar) + e_x_ar;
x_D = hx*x_D(-1) + (1-hx)*(-mu_x*(p_D - rer) + eta_ystar*ystar) + e_x_ar;
x_L = hx*x_L(-1) + (1-hx)*(-mu_x*(p_L - rer) + eta_ystar*ystar) + e_x_ar;
@#else
x_E = hx*x_E(-1) + (1-hx)*(-mu_x*(p_E - rer)) + e_x_ar;
x_D = hx*x_D(-1) + (1-hx)*(-mu_x*(p_D - rer)) + e_x_ar;
x_L = hx*x_L(-1) + (1-hx)*(-mu_x*(p_L - rer)) + e_x_ar;
@#endif
```

### 4.4 Monetáris/UIP-blokk (725–727. sor helyére)

```
@#if FOREIGN == 1
(1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
    + uni*(r - r_for - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - r_for - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0;
@#else
(1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
    + uni*(r - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0;
@#endif
rer = rer(-1) + dep - infl;
```

**Megjegyzés (D5/kalibrációs pontosítás a review 6. pontja alapján):**
`r_for` a külföldi nominális kamat **steady state-től vett, negyedéves
modellbeli eltérése** — éves százalékpontos ECB-adatot nem lehet közvetlenül
beírni, azt előbb negyedévesíteni és a modell steady state-jéhez viszonyítva
detrendelni kell (lásd 8. szakasz).

### 4.5 Sokk-folyamatok (a 730. sor körüli blokkba)

```
@#if FOREIGN == 1
ystar  = rho_ystar*ystar(-1) + eps_ystar;
r_for  = rho_rfor*r_for(-1) + eps_rfor;
@#endif
```

### 4.6 `initval;`/`endval;` blokkok kiegészítése

Minden meglévő `initval;`/`endval;` blokkban (a fájlban több szcenárió-ágon
is előfordul — mindegyiket meg kell találni és kiegészíteni):

```
@#if FOREIGN == 1
ystar = 0; r_for = 0;
@#endif
```

A review 2. pontja szerint ez technikailag nem feltétlenül szükséges a
Dynare működéséhez, de **reprodukálhatóság és auditálhatóság miatt kötelező**.

---

## 5. Kalibráció

- **`rho_ystar`, `rho_rfor`**: alapértelmezés a terven belül `0,625`
  (összhangban a modell saját, már használt exportkeresleti perzisztenciájával),
  de a `stress_*` futtatókban **kötelező érzékenységi rács** `0,40 / 0,625 / 0,85`
  mellett is lefuttatni, és minden riportban feltüntetni melyik értéken futott.
- **`eta_ystar`**: kiinduló érték `1,0` (EAGLE `eta_x`-szel analóg,
  strukturális benchmark), de **explicit megjelölve, hogy ez nem magyar
  empirikus becslés**.
- **Amit még ELLENŐRIZNI kell, mielőtt bármelyik szám "irodalmilag
  megalapozottként" bekerül egy csapat-dokumentumba** (a review 3 külső
  hivatkozást ad, ezeket **én magam még nem néztem meg**):
  - MNB Working Paper 2008/9 — állítólag `rho≈0,625` exportkeresleti sokk
    (gyanúsan pontosan egyezik a kódban már meglévő `rho_x=0,625`-tel, ami
    valószínűsíti hogy ez volt az eredeti forrás, de ez még nincs igazolva).
  - ECB EAGLE Working Paper 1195 — a négyrégiós EAGLE-modell monetáris
    perzisztencia-paraméterei (a review szerint ezek NEM azonos objektumok
    egy exogén `rstar` AR-paraméterrel, tehát még ha a hivatkozás valós is,
    a belőle vett szám átvétele külön indoklást igényel).
  - MNB Working Paper 2013/1 (MPM) — állítólag `~0,40` külsőkereslet-
    perzisztencia és `~0,85` külföldi kamatsimítás különböző specifikációkban.

  **Teendő:** valaki (Tomi vagy Samu) nézze meg ezt a három forrást
  ténylegesen, mielőtt a végleges kalibrációs döntés (nem csak az
  érzékenységi rács) megszületik.

---

## 6. Infra/regiszter frissítések

**Ezt implementációkor kell megoldani, nem csak eredményközlés előtt** (a
2. review-kör 2. pontja szerint — a `t54` őr `FOREIGN=1` mellett azonnal,
minden futtatáskor elbukna, ha nem bővítjük, tehát ezt nem lehet
"majd később" elintézni).

**Kéttrackes megoldás:**

- A jelenlegi `t54` (`smoke_test.m`, ~850. sor,
  `height(Pr) == 91 && height(Pd) == 91`) **változatlanul marad** —
  ez a `FOREIGN=0` (alapértelmezett) ágat védi, 91 paraméterrel.
- **Új, külön guard** készül `FOREIGN=1` ágra, 94 paraméterrel
  (`rho_ystar`, `rho_rfor`, `eta_ystar` hozzáadva) — ez csak akkor fut,
  ha valaki explicit `-DFOREIGN=1` mellett futtatja a füstteszt-dumpot.
- A `docs/regiszter/parameterek.csv`-ben a három új paraméter
  `aktiv_ha=FOREIGN=1` jelölést kap (hasonlóan ahhoz, ahogy az `OPTEN`/
  `CALIB26`-függő paraméterek is meg vannak jelölve melyik ágon aktívak) —
  így a legacy (91-es) regiszter nem törik el, de a bővített ág sem marad
  némán ellenőrizetlen.
- **`src/4_infra/12_regiszter_epito.py`**: a kategórialista jelenleg kézi —
  a három új paramétert (`rho_ystar`, `rho_rfor`, `eta_ystar`) fel kell
  venni ide is, `FOREIGN=1` címkével, egyszerre a `parameterek.csv`
  bővítésével.
- **`src/4_infra/12_regiszter_epito.py`**: ellenőrizni kell, hogy a `_params_dump.csv`
  generálása helyesen kezeli-e a feltételes (`@#if FOREIGN==1`) paramétereket —
  ha a dump-script minden futtatott konfigurációból csak a ténylegesen
  deklarált paramétereket olvassa ki, ez automatikusan működik; ha van benne
  kemény lista, azt is bővíteni kell.

---

## 7. Ellenőrzési terv / elfogadási kritériumok

Implementáció után, ebben a sorrendben:

1. **Fordítási/futási ellenőrzés**: `FOREIGN=0` mellett a modell **bitre
   azonos** eredményt ad, mint jelenleg (legacy-regressziós teszt) —
   minden meglévő smoke-test guard (`t01`–`t55`) változatlanul fusson át.
2. **Nulla-sokk kontroll `FOREIGN=1` mellett**: `eps_ystar=eps_rfor=0`
   pálya esetén az eredmény **numerikus tolerancián belül** (NEM feltétlenül
   bitre) egyezzen a `FOREIGN=0` ággal — a review szerint ez az elvárható
   szint, nem a bitazonosság, mert a modell szerkezete (endogén változók
   száma, sajátérték-vektor) ilyenkor is más.
3. **BK-ellenőrzés ténylegesen lefuttatva** `bk_check_metrics`-szel:
   - kezdeti (`uni=0`) lokális BK-státusz;
   - terminális (`uni=1`) lokális BK-státusz;
   - a régi hazai sajátértékek változatlansága;
   - pontosan két új stabil gyök (`rho_ystar`, `rho_rfor` miatt).
4. **Szimmetria-teszt** (`-DSYM=1`) újrafuttatása `FOREIGN=1` mellett is —
   a review 4. apró pontja szerint önmagában `SYM=1` nem teljes
   szimmetriateszt (az L-vállalat hozzáférési struktúrája eltér), ezért
   legalább `SYM=1, ACCSCALE=0` kombinációban kell futtatni.
5. **Counterfactual-konzisztencia teszt**: az euró-csatlakozási és
   nem-csatlakozási forgatókönyv ugyanazt a `ystar`/`r_for` pályát kapja
   (lásd D7) — ezt kódszinten (nem csak dokumentációban) ellenőrizni kell,
   pl. egy assert-szerű guard-dal a scenario-builder scriptben.

---

## 8. Forgatókönyv-építés — szintpálya → innováció konverzió

Amikor egy `stress_*`-szerű futtató konkrét külföldi keresleti/kamatpályát
akar beadni (pl. "mi történik egy eurozónás recesszióban"), **nem** a
kívánt szintet kell az `eps_ystar`/`eps_rfor` sokkba írni. A recept:

```matlab
% adott: kivant_ystar_palya (1xN vektor, negyedeves, steady-state-tol
% vett log-elteres), rho_ystar (kalibralt ertek)
eps_ystar_palya = zeros(1, N);
eps_ystar_palya(1) = kivant_ystar_palya(1);   % ystar(0)=0 kezdofeltetel mellett
for t = 2:N
    eps_ystar_palya(t) = kivant_ystar_palya(t) - rho_ystar*kivant_ystar_palya(t-1);
end
% ez kerul a shocks; blokk 'values' mezojebe eps_ystar-ra, NEM a kivant_ystar_palya
```

Ugyanez `r_for`-ra `rho_rfor`-val. A `r_for` bemenő adatnak **negyedévesített,
a modell steady state-jéhez viszonyított eltérésként** kell rendelkezésre
állnia (nem nyers éves ECB-kamatszázalékként) — ez a review 6. pontjának
kötelező pontosítása.

---

## 9. Amit ez a terv NEM old meg — nyitva marad

Ezeket a review "Ami ellenőrizetlen maradt" szakasza sorolja fel, és a
terv jelen állapotában valóban nyitottak:

- A módosított `.mod` tényleges Dynare-fordítása és futtatása (ez a terv
  papíron van, nincs lefuttatva).
- Az összes `SCENARIO`/`OPTEN`/`CALIB26`/`DECOMP`/`NOVERT`/`SYM`/`FOREIGN`
  kapcsoló-kombináció együttes tesztelése.
- A külső GDP-/kamatsor pontos definíciója, frekvenciája, detrendelése —
  ez külön adatgyűjtési feladat, nincs benne ebben a tervben.
- Az `e_x_ar`/`ystar` és az `e_pr_ar`/`r_for` **együttes empirikus
  azonosíthatósága** — a D1 döntés szerint ezt tudatosan nyitva hagyjuk
  ebben a körben, nem oldjuk meg most.
- A sokkok varianciája/kovarianciája (ehhez a tervhez csak a perzisztencia
  kell, sztochasztikus szimulációhoz több paraméter).
- A 3 külső irodalmi hivatkozás (5. szakasz) tényleges ellenőrzése.
- Az app, riportgenerátorok, paraméterregiszterek teljes propagációja
  `FOREIGN=1` esetére (csak a smoke-test `t54` őrt említi a terv explicit,
  de lehet más helyen is kemény 91-es feltételezés).

---

## 10. Következő lépések

1. **Egyeztetés Samuval** mielőtt bárki hozzányúl a közös `.mod` fájlhoz
   (`CLAUDE.md` koordinációs szabálya) — ő találta a hiányt, valószínűleg
   van saját elképzelése is a megoldásról.
2. Rövid életű branch, implementáció a 4. szakasz szerint, **aznap** vissza
   a main-re (`CLAUDE.md` nagy-átalakítás szabálya).
3. A 7. szakasz ellenőrzési sorrendjét végigfuttatni, mielőtt bármilyen
   `FOREIGN=1` eredmény bekerül egy riportba vagy az `ALLAPOT.md`-be.
4. Az 5. szakasz három irodalmi hivatkozását ellenőrizni, mielőtt a
   kalibráció "megalapozottként" kerülne be bárhova.
