# ⚠ FIGYELMEZTETÉS: a projekt fő állítása nem azonosítható

*2026-07, **javítva 2026-08** a kritikai felülvizsgálat után. A KKV/nagyvállalat
layer empirikus és modell-oldali tesztelésének eredménye. Ez a dokumentum
szándékosan éles és nem szépít — sem a projekt hipotézisét, sem a saját
korábbi verdiktünket illetően. Csapatdöntést igényel, mielőtt bármit
állítunk a KKV-előnyről.*

> **A 2026-08-i javítás lényege egy mondatban:** a dokumentum korábbi
> változata azt állította, hogy *„az adat az ellenkezőjét támogatja"*.
> Ez **túl erős volt, és a hozzá adott közgazdasági magyarázat téves.**
> A helyes verdikt: **azonosítási kudarc** — a feltevésre nincs empirikus
> fedezet, de az ellenkezőjére sem. Cserébe a felülvizsgálat **három
> strukturális hibát talált magában a modellben**, amelyek súlyosabbak,
> mint a t-paraméter kérdése.

---

## 1. Az állítás, amit teszteltünk

> „Az euró-bevezetés a KKV-knak többet segít, mint a nagyvállalatoknak,
> mert a KKV-k hitelfelára érzékenyebben reagál a prémium-csökkenésre."

Ez a projekt fő hipotézise, a modellválasztási javaslat központi tézise,
és a HTML-dokumentációkban közölt eredmények alapja. A modellben ez a
`tsov_S > tsov_L` és `tbank_S > tbank_L` paraméterválasztásban él
(2,50-szeres és 2,00-szeres arány).

## 2. Amit az adat mond — azonosítási kudarc

### 2.1 A becslés replikálható, de rossz sorozaton futott

A `src/08_mnb_transzmisszio.py` eredeti eredménye **bitre replikálódott**
(0,299 / 0,652 / 0,206 / 0,800) — nincs kódhiba, és az `AMOUNT_CAT`
„0" = ≤1M EUR / „1" = >1M EUR méret-leképezés helyes.

A hiba a **kamatfixálási kompozíció elsodródásában** van. A script a
`MATURITY_NOT_IRATE = "A"` (*Total initial rate fixation*) sorozatot
használta, amely két **nem összemérhető terméket** takar, és az arány a
mintán belül drámaian változik (új szerződések volumen-megoszlása, A2A, HUF):

| Év | KKV ≤1 év fix | KKV 1–5 év | Nagyváll. ≤1 év fix | Nagyváll. 1–5 év |
|---|---|---|---|---|
| 2018 | **81,4%** | 9,0% | **90,2%** | 6,4% |
| 2021 | 31,3% | 45,7% | 49,4% | 17,0% |
| 2023 | **21,8%** | 56,9% | 46,3% | 38,6% |
| 2026 | **18,8%** | 61,0% | **82,2%** | 8,2% |

Vagyis 2018-ban mindkét szegmens túlnyomóan változó kamatozású volt, 2026-ban
viszont a KKV a **hosszabb** fixálású. Egy „változó kamatozás" alapú érvelés
tehát a magyar adaton nem áll.

### 2.2 Újrabecslés az összemérhető szegmensen

≤1 év fixálás, 2010–2026 (198 hónap — a hosszabb minta is *nyereség*, mert
a „Total" sorozat csak 2017-08-tól létezik), HAC standard hibák, 0–3 késés:

| Referencia | KKV | Nagyvállalat | Különbség (közvetlen becslés) |
|---|---|---|---|
| 3M bankközi | **0,714** (0,120) | **0,951** (0,245) | −0,238 (0,183), t = −1,30 |
| 10 éves állampapír | 0,863 (0,317) | 1,296 (0,415) | −0,433 (0,222), t = −1,95 |
| **ECM, hosszú táv (bankközi)** | **0,990** | **1,211** | mindkettő ≈ teljes |

A KKV bankközi pass-through **0,299 → 0,714**-re emelkedik, a rés
−0,353 → −0,238-ra zsugorodik, és **hosszú távon mindkét szegmens
átgyűrűzése gyakorlatilag teljes**.

### 2.3 A sorrend NEM robusztus — ez a döntő megállapítás

A modell szerkezete `efp = t_bank·bank + t_sov·sov`, tehát a helyes becslés
**együttes** regresszió. (A korábbi script két *univariáns* becslést futtatott
erősen korrelált referenciákra — ez kihagyott-változó torzítás, és nem négy
független teszt, hanem kettő.)

| Specifikáció | t_bank_S / t_bank_L | t_sov_S / t_sov_L |
|---|---|---|
| **A modell feltevése** | **2,00** | **2,50** |
| Total fixáció, együttes *(= az eredeti minta)* | **1,26** ← a KKV **magasabb** | 0,26 |
| ≤1 év fixáció, együttes | 0,76 | 0,51 |
| **Fedezettel/garanciával (A2AC)** | **2,75** ← a feltevés irányába | 0,83 |
| 1–5 év fixáció | 0,62 | 2,18 |

**A becsült arány 0,26 és 2,75 között szóródik, és egyetlen különbség sem
szignifikáns 5%-on.** A fedezet-kontrollált mintában az előjel **megfordul**
és éppen a feltevést támogatja.

### 2.4 A korábbi közgazdasági magyarázat téves volt — javítva

A dokumentum korábbi változata azt írta: *„a KKV-hitelek nagy része fix
kamatozású vagy támogatott programban van, ezért nem követik a piaci
kamatot."* **Ez egy új-szerződéses sorozatra nem áll**, három okból:

1. Az MNB kamatstatisztikai módszertana szerint **a támogatott hitelek
   kamata a kliens által fizetett kamat mellett a támogatás összegét is
   tartalmazza** — tehát a statisztikába a **bruttó, piaci szintű** kamat
   kerül, nem a kedvezményes.
2. Az `A2A` kategória **kizárja a folyószámla- és rulírozó hitelt**, vagyis
   a Széchenyi Kártya legnagyobb terméke eleve nincs a mintában.
3. Számtani ellenőrzés: 2023-ban az 1–5 éves fixálású KKV új hitel
   átlagkamata **13,66%** volt (BUBOR-éves átlag 12,05%, NHP/Széchenyi
   ráták 2–5%). Ha az állomány fele 3%-on lenne **nettó** módon jelentve,
   ez az átlag matematikailag lehetetlen.

Ehhez kapcsolódóan: a `t12` ~80%-os támogatott aránya az Opten
**állomány-alapú implicit rátájára** vonatkozik (legacy NHP-vintage-ekkel),
és **nem vihető át** az ECB MIR **új-szerződéses flow** adatára. A két szám
nem ugyanazt méri.

### 2.5 A becslés további technikai hibái (mind javítandó a 08-as scriptben)

- **A szint-regressziók spuriózusak** (β = 1,657 és 1,772 > 1) — nem
  stacionárius sorozatok statikus regressziója kointegrációs teszt nélkül.
  **Ki kell venni.**
- **A 10 éves állampapír rossz referencia ezen a mintán:** 2023-ban BUBOR
  12,05% vs. 10Y 7,51% — a 2022–23-as monetáris epizódban a két horgony
  szétszakadt, ezért a 10Y-ra vetített regresszió mechanikusan >1
  együtthatót ad. A `t_sov` erre a mintára **gyakorlatilag nem azonosítható**.
- **A különbség standard hibája rossz volt:** `sqrt(se_S² + se_L²)`
  függetlenséget tételez, miközben a két reziduum erősen korrelált. (Ez a
  hiba a *korábbi* következtetés ellen dolgozott — de a helyes SE-vel sem
  szignifikáns semmi.)
- **Túl rövid késleltetés** (0+1 hónap). 0–3 késéssel már az eredeti mintán
  is 0,541 vs. 0,727 (t = −0,41), nem 0,299 vs. 0,652.

### 2.6 A helyes verdikt

> **A `t_S > t_L` feltevésre nincs empirikus fedezet — de az ellenkezőjére
> sem. A becsült arány 0,26 és 2,75 között szóródik, egyetlen specifikációban
> sem szignifikáns. Ez azonosítási kudarc, nem cáfolat.**

Ez a megfogalmazás **korrekten publikálható**, és nem igényli, hogy bármit
állítsunk arról, melyik szegmens érzékenyebb.

## 3. Elméleti oldal: a BGG-érv nem támogatja a t-t

Fontos fogalmi tisztázás: **a BGG-akcelerátor a `chi`-ről szól, nem a `t`-ről.**

- `chi` = a *belső*, tőkeáttételtől függő prémium érzékenysége → itt van
  értelme a méret-aszimmetriának.
- `t` = egy *exogén* forrásköltség-/szuverén-ék begyűrűzése a hitelkamatba.
  Monopolisztikus banki árazásnál, állandó felárral ez hosszú távon
  **≈1 mindkét szegmensre** — és pontosan ezt találja az ECM (0,99 vs. 1,21).

Vagyis a BGG-logikával **nem lehet legitimálni a `t`-be helyezett
aszimmetriát**. Ez egyszerre védelem és vád: a két objektum különböző, de
éppen ezért a KKV-előnyt nem a `t`-be kellene tenni.

A nemzetközi irodalom megosztott: van euróövezeti eredmény, amely szerint a
pass-through *csak* a kisvállalati hitelekre teljes (→ t_S > t_L), és van
fragmentáció-irodalom, amely szerint a kamatvágások átgyűrűzése *a kisebb
hitelekre gyengébb* (→ t_S < t_L). **Ami az irodalomban robusztus, az nem az
ár, hanem a mennyiség:** szigorodáskor a bankok a kicsiktől a nagyokhoz tolják
a hitelkínálatot.

## 4. A modell saját problémái — ez súlyosabb, mint a t-kérdés

A felülvizsgálat három strukturális hibát talált a `jv_dsge_v05.mod`-ban.
Mindhárom bekerült a fájl fejlécébe.

### 4.1 A `chi`-aszimmetria a hosszú távon a KKV ELLEN dolgozik

A terminális steady state zárt formulájából `∂i_ss/∂F = −1/chi`
(ahol `F = tsov·sov + tbank·bank` a prémium-ék), tehát:

- 1/chi_S = 1/0,06 = **16,7**
- 1/chi_L = 1/0,02 = **50,0**

**A nagyvállalati beruházás 3-szor érzékenyebb ugyanarra a
prémium-csökkenésre — éppen mert `chi_L < chi_S`.** Dynare-rel igazolva
(egyenlő t-súlyok, SCENARIO=1):

| chi_S / chi_L | i_S,ss | i_L,ss |
|---|---|---|
| 0,06 / 0,02 (alapkalibráció) | **−0,13%** | **+2,51%** |
| 0,04 / 0,04 (szimmetrikus) | **+1,19%** | +1,00% |
| 0,02 / 0,06 (fordított) | **+3,09%** | −0,16% |

Vagyis a `chi_S > chi_L` — amit a layer **fő mechanizmusaként** mutattunk be —
a modell hosszú távú algebrájában **megfordul**. Ez a felülvizsgálat legsúlyosabb
megtalált problémája, mert a narratíva ellentétes előjellel működik, mint a modell.

Ehhez tartozik: **steady state-ben `efp_S ≡ efp_L` mindig** (mert `q_S = q_L = 0`
mellett a két `ret` egyenlet ugyanarra a közös `rk`-ra vezet). A modellben tehát
**nincs hosszú távú szegmens-prémium-differencia** — a KKV-előny per definitionem
tisztán átmeneti jelenség.

### 4.2 A szegmens-tőke reallokációs maradék → nem közölhető

Az aggregált `k`-t a tőkepiaci egyenlet lekötözi, ezért a
`k = om_S·k_S + (1−om_S)·k_L` bontásban a szegmens-tőke közel nulla-összegű
maradék: az **aggregált** beruházás 1,09–1,29% között mozog, miközben a
**szegmens-rés +0,53 → −5,80 pp-ot ugrál**.

> **⚠ SZEGMENS-SZINTŰ BERUHÁZÁST EBBŐL A MODELLBŐL NEM SZABAD EREDMÉNYKÉNT
> KÖZÖLNI.** Ez érinti a HTML-dokumentációkat és az előadói jegyzetet is:
> a „KKV-beruházás +1,33% vs. nagyvállalati +0,79%" típusú számok
> **diagnosztikák, nem eredmények**.

Feloldás csak szegmens-specifikus termeléssel és tőkekereslettel lenne — a v04
első kísérlete pontosan ezen bukott meg (Blanchard–Kahn-sértés).

### 4.3 A t-paraméterekben a modell exaktul lineáris

`tsov`/`tbank` kizárólag exogén változók együtthatóiként jelennek meg, az
átmeneti mátrixot nem érintik. Dynare-rel ellenőrizve: **a TSCEN=3 minden
kimenete a TSCEN=1 és 2 exakt átlaga, 1e-15 pontossággal.**

Ezért a korábbi 3. következtetés („még a legsemlegesebb feltevéssel sem áll az
állítás") **nem önálló bizonyíték** — a TSCEN=3 mechanikus számtani keverék,
mert a TSCEN=2 a TSCEN=1 tükörképe. A TSCEN=2-t **nem szabad „empirikusnak"
nevezni.**

### 4.4 Két javított kódhiba

- **`sens_tsuly_v05.m`:** a csúcs-időpontot a script csak az `efp_S`-ből
  választotta, de az `efp_L`-t is azon a dátumon olvasta. A csúcs-index
  szcenárióról szcenárióra változik, ezért a felár-oszlopok **különböző
  dátumokon** mért értékeket tartalmaztak. Javítva: fix összehasonlítási
  dátum + mindkét szegmens saját csúcsa külön oszlopban. *(Ellenőrzés:
  a felár-oszlopok most már megfelelnek a 4.3-as linearitásnak — korábban
  +1,70 és −2,37 bp-tal tértek el tőle.)*
- **`jv_dsge_v05.mod`:** a `y_d` hazai jószág keresletében `shd_i*i_S`
  szerepelt `shd_i*ii` helyett (a v03-ban még helyesen `si*ii` volt, a v04-ben
  cserélődött ki, a v05 örökölte). Így a legkevésbé megbízható szegmens-változó
  0,177-es súllyal folyt közvetlenül a jelentett `KKV_kibocsatas`-ba. Javítva.
- **Nem hiba, de dokumentálatlan és torzít:** `psi_i_S = 8,0 < psi_i_L = 13,0`,
  azaz a KKV beruházási alkalmazkodási költsége *alacsonyabb*. Empirikusan
  visszafelé van (a KKV-beruházás lumpier és korlátozottabb) — és a KKV-előny
  irányába torzít. Újrakalibrálandó vagy érzékenységgel kísérendő.

## 5. Az érzékenységi sáv a javítások után

`src/model/sens_tsuly_v05.m` → `t26_tsuly_teszt.csv`. Ugyanaz a modell,
három paraméterezéssel (a felár q17-ben, fix összehasonlítási dátumon):

| Paraméterezés | GDP (h. táv) | KKV-felár | Nagyváll. felár | Melyik nyer többet? |
|---|---|---|---|---|
| **Feltevés** (t_S > t_L) | +0,426% | −35,8 bp | −24,6 bp | KKV, 11,1 bp-tal |
| **Tükörkép** (t_S < t_L) | +0,617% | −25,0 bp | −51,3 bp | nagyvállalat, 26,3 bp-tal |
| **Egyenlő** (t_S = t_L) | +0,522% | −30,4 bp | −38,0 bp | nagyvállalat, 7,6 bp-tal |

Figyeljük meg: a harmadik sor minden értéke az első kettő **átlaga** (4.3).
A tartalmi állítás tehát egyetlen: **a felár-rés előjele a t-súlyok
megválasztásán áll, és a súlyokat az adat nem azonosítja.**

## 6. Mi közölhető és mi nem

**Közölhető:**
- **Az aggregált GDP-hatás: +0,43% … +0,62%** a t-sáv fölött, ill. a
  szcenárió-sáv (`t21`): pesszimista +0,27% … optimista. Ez **robusztus** —
  a t-súlyok megválasztására is, a vertikális link ki-be kapcsolására is.
- **A felár-pályák** fix összehasonlítási dátumon, a t-súly-sáv megjelölésével.
- **A duális gazdaság kvantifikálása** (`t24`, IO-adat): az autóipar hazai
  köztes-input aránya **6,0%**, az elektronikáé 4,2%, a vegyiparé 27,1%.
  Ez önálló, publikálható, adatolt eredmény.
- **A támogatási ék nagyságrendje** (`t14`) — de **nem** költségvetési
  tételként (lásd 8.).
- **A hozzáférési heterogenitás** (`t10`/`t11`): 6,7% mikro vs. 41,6% közép.

**Nem közölhető:**
- Szegmens-szintű beruházás vagy tőke (4.2).
- „A KKV érzékenyebb a prémium-csökkenésre" mint *eredmény* (2.6, 3.).
- „Az adat az ellenkezőjét mutatja" mint *eredmény* (2.6).
- Bármely szám a `t26` `*_DIAG` oszlopaiból.

## 7. Ahol a KKV-történet valóban megalapozható

Négy irány, mindegyik jobban adatolt, mint a `t`-aszimmetria.

**(1) Szintbeli hatás, nem rugalmasság — a legtisztább.** 2017–19-ben a KKV
új-hitel kamata **167–238 bp-tal** volt a nagyvállalati fölött (2017: 3,35%
vs. 0,97%). **Azonos** (`t_S = t_L`) *arányos* prémium-csökkenés is nagyobb
**forintban mért** megtakarítást ad a KKV-nak. Ez nem igényel semmilyen
paraméter-aszimmetriát, csak a szintbeli különbséget — ami adatolt.

**(2) Extenzív margó / hozzáférés.** A projekt legerősebb empirikus eredménye,
és az irodalom is itt robusztus. **De a modellben nincs benne.**

**(3) Támogatás-kivezetési szcenárió.** Helyes irány (lásd a külön v06-tervet),
**de:** a Széchenyi Kártya 2025 októberétől egységes fix 3%-on fut, a Baross
Gábor program pedig **már nagyvállalatokra is** kiterjed — a kivezetés tehát
**nem tiszta KKV-aszimmetria**. Ezt a szcenárió tervezésénél figyelembe kell venni.

**(4) Devizakitettség.** A nagyvállalat/exportőr természetes EUR-bevétellel és
EUR-hitellel fedezett; a KKV forintban adósodik és fedezetlenül viseli az
input-árfolyam-átgyűrűzést. Az euró ezt az aszimmetrikus kockázatot **a
KKV-nál** szünteti meg. Elméletileg tiszta KKV-előny-csatorna, és nem ütközik
a kamatstatisztikával.

**Amire NE építsünk:** „a KKV rövidebb lejáratra hitelez, ezért gyakrabban
árazódik át" — a magyar adaton ez **nem áll** (2.1: 2026-ban a KKV 61%-a
1–5 év fixálású, a nagyvállalatoknak 8%-a).

## 8. Javasolt döntések (csapat)

1. **A prezentációból ki kell venni a szegmens-beruházási számokat** (4.2),
   és a felár-különbséget explicit „ez a t-súly-feltevésünk következménye,
   amit az adat nem azonosít" jelöléssel kell közölni.
2. **Alapkalibráció:** javaslat a `TSCEN=3`-ra (egyenlő súlyok,
   strukturálisan semleges), a `TSCEN=1/2` pár **érzékenységi sávként**.
   Az alapérték a `.mod`-ban **változatlanul 1**, mert ez csapatdöntés.
3. **A `chi` előjel-problémája (4.1)** — vagy fogadjuk el és mondjuk ki
   explicit eredményként (érdekes és publikálható: a magyar KKV magasabb
   mérleg-érzékenysége *csökkenti* a prémium-sokkra adott tőkeválaszát),
   vagy építsük át a szegmens-blokkot szegmens-specifikus termeléssel.
4. **A 08-as script javítása** (2.5) — a szint-regressziók kivétele, `"F"`
   fixálási sorozat, együttes regresszió, HAC, ECM, közvetlen
   differencia-becslés.
5. **Jobb azonosítás:** az MNB-nek van részletesebb, méret szerinti bontása,
   amihez kérésre hozzá lehet jutni. Ez eldöntheti, hogy van-e egyáltalán
   szegmens-különbség a transzmisszióban.
6. **Irányválasztás:** a DSGE-központú (v06, támogatás-kivezetés) vagy az
   extenzív-margó-központú történet legyen a fő szál? Ez a t-kérdésnél
   nagyobb döntés.

## 9. Korlátok (hogy a figyelmeztetés is korrekt legyen)

- Az összeg-kategória a méret **proxyja**, nem maga a méret.
- A kamatszintet más tényezők is befolyásolják (fedezet, lejárat, program) —
  a becslés irányadó, **nem strukturális azonosítás**.
- Egyetlen becsült különbség **sem szignifikáns** — tehát az sem bizonyított,
  hogy a nagyvállalat érzékenyebb. **A biztos állítás csak az, hogy a
  szegmens-különbség nem azonosított.**
- **A 557–665 Mrd Ft/év támogatási ék NEM költségvetési szám.** Az implicit
  ráta zajos, a rés egy része fix vintage-árazás (nem támogatás), és az
  NHP-éket az MNB viselte, nem a költségvetés. Költségvetési tételként
  közölni súlyos hiba lenne.
- A `t12`/`t14` arányok **cég-év arányok** a 10+ fős Opten-körből, nem
  állomány-súlyozottak; a mikrocégek (<10 fő) hiányoznak a panelből, pedig
  ott koncentráltabb a Széchenyi Kártya.
