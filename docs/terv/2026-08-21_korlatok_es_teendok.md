# Korlátok, turpisságok és teendők — 2026-08-21

*Három külső bírálati kör (ChatGPT Codex) + saját ellenőrzés. Minden állítás
mellett ott van, hogy **mértük-e** vagy elvi érv. A sorrend súlyosság szerint,
nem témakör szerint — mert a leadásig nem mindenre lesz idő.*

> **KORREKCIÓ — 2026-08-24 (valódi Blanchard–Kahn-audit).** A riportban
> történetileg `konvergalt` néven használt mező a perfect-foresight solver
> numerikus státusza volt, nem BK-teszt. A `t47` ezért PF szerint 36/36,
> de a terminális `uni=1` lokális rezsimben csak 9/36 BK-valid: az
> `OPTEN=0` ág 9/9 esetben 13 instabil / 13 előretekintő gyökkel helyes,
> míg az `OPTEN=1/2/3` ágak 27/27 esetben 15/13-mal hibásak. A `t53`
> `ACCSCALE=100` eredménye PF/check szerint 45/45, de BK szerint 0/45;
> ezért az ottani GDP-szintek és a minden ágon pozitív KKV-pontbecslés nem
> interpretálható. A `t53b` 10/10 küszöbpontja ugyanakkor BK-valid, így a
> 22,36 / 22,62 / 22,95 technológiai összevetés fennmarad. Ugyanígy a
> lambda–omega küszöbkontúr BK-valid, de az `OPTEN=1`, `ACCSCALE=100` pont
> nem az. A lent meghagyott történeti 36/36 és 45/45 BK-megfogalmazásokat,
> valamint az érintett `ACCSCALE=100` szintállításokat ez a blokk felülírja.

---

## 🔴 SÚLYOS — a fő eredményt érinti

### 1. Az `ACCSCALE` KÉT mechanizmust skáláz egyszerre — és a hatás KVADRATIKUS

**Ez a legélesebb technikai kritika, és mértük.** A kódban:

```
lambda_acc_E = 2.0*(ACCSCALE/100);   lambda_acc_D = 2.5*(ACCSCALE/100);
omega_acc_E  = 0.35*(ACCSCALE/100);  omega_acc_D  = 0.45*(ACCSCALE/100);
```

Vagyis **ugyanaz az egyetlen szám** szabályozza:

| | mechanizmus | paraméter |
|---|---|---|
| 1. lépcső | felár → hozzáférés | `λ_acc` |
| 2. lépcső | hozzáférés → beruházás | `ω_acc` |

A hosszú távú beruházási hatás `−ω·λ/(1−ρ)·efp`, tehát **az `ACCSCALE`
NÉGYZETÉVEL** arányos, nem a szintjével.

**Lemérve a `t49`-en (`rho_acc = 0,9673`, bázis `ACCSCALE = 0`-nál
`KKV−L = −0,412 pp`):**

| `ACCSCALE` | KKV−L | hatás | hatás/ACC | hatás/ACC² ×10⁴ |
|---:|---:|---:|---:|---:|
| 4 | −0,398 | +0,014 | 0,0035 | **8,77** |
| 10 | −0,326 | +0,087 | 0,0087 | **8,67** |
| 20 | −0,078 | +0,334 | 0,0167 | **8,35** |
| 40 | +0,758 | +1,170 | 0,0293 | 7,31 |
| 100 | +3,892 | +4,305 | 0,0431 | 4,30 |
| 140 | +5,728 | +6,140 | 0,0439 | 3,13 |

A `hatás/ACC` oszlop **12-szeresére nő**, a `hatás/ACC²` viszont kis
értékeknél **konstans** — a hatás tehát az origó közelében kvadratikus, nagy
értékeknél az általános egyensúlyi visszacsatolás tompítja.

**Miért turpisság ez:**

1. Aki azt gondolja, hogy „`ACCSCALE` 22,3 a 100 helyett ⇒ 4,5-szer gyengébb
   csatorna", **téved**: az origó közelében ~20-szoros a különbség.
2. A **22,3-as küszöb nem egy rugalmasságon van, hanem KETTŐ SZORZATÁN** — és
   előre rögzített `λ:ω` arány mellett. Vagyis a küszöb valójában azt mondja:
   *„mekkora közös skálázás mellett fordul meg az eredmény, ha az első és a
   második lépcső erősségét fix arányban EGYÜTT változtatjuk"*. Ez lényegesen
   gyengébb állítás, mint amit a szám sugall.
3. A `2,0 : 2,5` és `0,35 : 0,45` arányok maguk is átvett értékek — a
   csapattárs `v07_access`-éből —, tehát **az arány sincs horgonyozva**.

**Teendő:** az `ACCSCALE`-t **szét kell bontani** két külön kapcsolóra
(`-DLAMSCALE`, `-DOMSCALE`), és a küszöböt **kétdimenziós felületként**
közölni a `(λ, ω)` síkon — ahogy a `(ρ, ACCSCALE)` felületet már megtettük.
Fél nap, és utána a küszöb interpretálható. **Ez a legnagyobb hozamú
modellezési teendő.**

#### ✅ ELVÉGEZVE — 2026-08-24

Kapcsolók bekötve (`-DLAMSCALE`, `-DOMSCALE`; alapértelmezés `-1` = az
`ACCSCALE`-t örökli, tehát minden korábbi eredmény bitre változatlan).
Kód: `sens_lam_om_v09.m`, ábra: `18_lam_om_felulet.py` (`f28`).
Eredménydoc: [`../eredmenyek/2026-08-24_lambda_omega_szetbontas.md`](../eredmenyek/2026-08-24_lambda_omega_szetbontas.md).

**Az eredmény élesebb lett, mint amit a teendő megfogalmazása várt.**
A szétbontás után kiderült, hogy a modell a két rugalmasságot
**külön-külön nem is azonosítja** — kizárólag a **szorzatukon** keresztül
hatnak. Mérve (`t52c`, `t52e`): a „csak λ" és a „csak ω" marginális
metszet számjegyre azonos, és az azonos szorzatú, nagyságrendileg
különböző `(λ, ω)` párok eltérése numerikus nulla.

Ezért a küszöb **nem felület, hanem pontos izo-szorzat görbe**:
a nulla-kontúron `λ·ω = 500,0 ± 0,08%` 28-szoros λ-tartományon. A
korábbi „22,3" ennek egyetlen pontja (`√500 = 22,36`), és a `t52d` átló
regressziósan visszaadja a `t48b`/`t51` mindkét számát (22,36 / 36,56 vs
22,3 / 36,5).

**Két következmény:**
- Az `F01` állítás **átfogalmazva** a szorzat-formára.
- A D kategória négy access-tétele valójában **két** azonosítható objektum
  (`λ_E·ω_E`, `λ_D·ω_D`) — új állítás: `A22`.

**Ami NEM oldódott meg:** a `λ_E:λ_D = 2,0:2,5` és `ω_E:ω_D = 0,35:0,45`
**arányok** továbbra is átvettek, és ezeket a scan nem mozgatja.

### 2. `ACCSCALE`: horgonyzatlan

Ismert, dokumentált (`A06`). A 2021–24-es magyar epizód programvezérelt volt,
tehát ebből elvileg sem azonosítható. Küszöbformában közölve.

### 3. `eps_ces`: horgonyzatlan, és az `y_E` ELŐJELE fordul rajta

`~2,3`-nál fordul. Az alapérték `6,0` egy irodalmi konvenció
(Laxton–Pesenti 2003 → GEM → EAGLE → mi). A Szabó Bakos-disszertáció
ugyanezt a 20%-os markupot használja **ugyanabból a forrásból**, tehát nem
független megerősítés. Magyar markup-becslés kell. <span>`F02`</span>

⚠ És egy fogalmi csúszás, amit érdemes kimondani: nálunk az `eps_ces` a
**vállalattípusok** közti helyettesítés, az irodalmi 6,0 viszont
**termékváltozatok** közti. **Nem ugyanaz az objektum**, csak ugyanaz a
jelölés és érték.

### 4. `omega_acc_L = 0` — a nagyvállalatnak NINCS hozzáférési margója

Ez **nem kalibráció, hanem feltevés**, és **ez viszi a szektorális
átfordulást**. A saját adatunk csak félig támogatja: a nagyvállalati
hozzáférés 43,4%, ami *alacsonyabb* az export-KKV 61,9%-ánál (`A03`).
Valószínűbb, hogy a nagyvállalat nem is *kér* hitelt — de a „nagyvállalatnak
mindig van hitele" történet **nincs az adatban**.

**Teendő:** scan rá, ugyanúgy, mint az `ACCSCALE`-re. Fél nap.

#### Irodalmi első keresés — 2026-08-24, külső észrevétel nyomán

Egy artifact-komment vetette fel, hogy erre a feltevésre irodalmat kellene
keresni. Megtettük (**első keresés, nem szisztematikus review**), és
megváltoztatja, amit mondanunk kell:

**TÁMOGATJA — és jobb indoklást ad, mint amink volt.** Az ECB SAFE
(vállalati finanszírozási felmérés) szerint a nagyvállalatok **elutasítási
aránya 1–2%**, a KKV-ké 5%. Vagyis a nagyvállalatot gyakorlatilag **nem
adagolják**. Az `acc_L = 0` tehát nem azért védhető, mert „mindig van
hitele", hanem mert **ha kér, megkapja**. Ez erősebb érv.

**PONTOSÍTJA.** Ugyanez a felmérés: a nagyvállalatoknak csak **45–48%-a
folyamodik** egyáltalán bankhitelért. Ez feltűnően közel van a mi 43,4%-os
magyar adatunkhoz (`A03`) — és megerősíti a saját megjegyzésünket, hogy a
nagyvállalati alacsony hozzáférés **igényhiány, nem korlátozottság**.

**MEGKÉRDŐJELEZI — és ezt nem hallgathatjuk el.** Crouzet–Mehrotra
(*American Economic Review*, `10.1257/aer.20181499`) amerikai adaton azt
találja, hogy a méret szerinti ciklikusság-különbség **valószínűleg nem
pénzügyi eredetű**: (a) recesszióban nincs szignifikáns különbség a
termelési inputok vagy az adósság viselkedésében; (b) a méret-hatás túléli a
pénzügyi erő proxyinak kontrollálását; (c) egy egyszerű pénzügyi súrlódásos
modell épp azt jósolná, hogy a **nem korlátozott (nagy)** cégek esnek vissza
jobban. Sőt: a kis cégek nagyobb ciklikussága szerintük — a ferdeség miatt —
**elhanyagolhatóan** mozgatja az aggregátumot.

Ez **közvetlen kihívás a méret-alapú pénzügyi akcelerátor premisszájára**.
Két érv szól amellett, hogy nálunk mégis áll:
1. **Amerikai adat.** Ott a nagyvállalatnak mély kötvénypiaca van, a magyar
   KKV-nak gyakorlatilag csak bankhitele.
2. **A mi extenzív margónk sokkal szélsőségesebb**, mint bármi az USA-ban:
   13-szoros hozzáférési rés az exportáló és a hazai KKV között (`A02`).

**Teendő:** a Crouzet–Mehrotra-t **fel kell venni a szakirodalmi
adatbázisba, és a tanulmányban meg kell hivatkozni** — egy bíráló elő fogja
venni, és sokkal jobb, ha mi hozzuk elő. Plusz: a SAFE magyar bontása
(elutasítási arány és „nem folyamodott, mert…" méret szerint) **közvetlen
horgony lehet** az `omega_acc_L`-re, és eddig nem néztük meg.

> ⚠ **Pontosítás — 2026-08-24, a D-kategória keresés nyomán.** A
> *negyedéves* SAFE **euróövezeti**, Magyarország nincs benne. Amit
> keresünk, az a **Bizottsággal közös, évente futó kör**, ami minden
> EU-tagállamot lefed, és **mikrocégekre is** bont (1–9, 10–49, 50–249,
> 250+). A teendő tehát teljesíthető, de **nem abból a kiadványból, amit
> eddig néztünk** — és ugyanez a forrás oldja meg a 10. pont
> mikrokör-hiányát is, amiért az `-DOPTEN` alapértelmezése `0` maradt.
> Részletek: [`2026-08-24_D_kategoria_irodalmi_kereses.md`](2026-08-24_D_kategoria_irodalmi_kereses.md).

### 5. EGY pre-periódus — semmilyen cégszintű azonosítás nem validálható

Mérve: a programvezéreltség **2021 és 2022 között** tör meg (piaci árazású
ráták 100% → 26,3%, BUBOR 1,5% → 10,0%), a panel 2021-ben kezdődik.
**Egyetlen kezelés előtti év van.**

Következmény: **pre-trend teszt nem futtatható** — sem RD-hez, sem
hitelfüggőségi designhoz. Ez korlátozza az egész decemberi cégszintű
empirikus blokk ambícióját, nem a design-választás.

### 6. A `−200 bp` forráshiánya

A sokkpálya dokumentált (−200 bp szuverén / −45 bp banki, ötfázisú időzítés,
három érzékenységi pálya). **A −200 bp maga viszont hivatkozás nélkül áll** a
repóban. Ez a szám határozza meg a főeredmény nagyságrendjét.

**Teendő:** forrás vagy saját levezetés. Fél nap.

---

## 🟡 VÉDHETŐ, DE ÉRZÉKENYSÉGET IGÉNYEL

### 7. A technológiai heterogenitás ÁTVITEL, nem becslés

A `.mod` maga kimondja: *„Ez ATVITEL, nem becsles."*

| | `zeta_j` (tőkehányad) | `aa_j` (munka a munka+import kompozitban) |
|---|---|---|
| E | 0,14 ← a JV export-szektorából | 0,45 ← ugyanonnan |
| D | 0,17 ← a JV hazai szektorából | 0,80 ← ugyanonnan |
| L | 0,155 ← a kettő közötti | 0,60 ← a kettő közötti |

**A turpisság:** a három típus **eleve különböző technológiát kapott**, az
exportorientációjuk alapján. Ha az E és a D máshogy reagál, abban benne van
az is, hogy mi adtunk nekik más termelési paramétert.

**Ez a legfontosabb hiányzó érzékenységvizsgálat.** Egy bíráló első kérdése
ez lesz: *„Show me that your main conclusion is not an artifact of the E/D/L
calibration."*

**Teendő — négy ág, ez a második legnagyobb hozamú tétel:**

| Ág | Mi különbözik csak | Mit mutat meg |
|---|---|---|
| A | csak `phi_j` (exportarány) | a piaci orientáció önmagában |
| B | csak a pénzügyi paraméterek (`chi`, `lev`, `psi`, access) | a **finanszírozási** heterogenitás önmagában |
| C | csak `aa_j` (import-intenzitás) | a magyar duális szerkezet önmagában |
| D | minden technológiai paraméter AZONOS | a maradék: tisztán finanszírozási |

Ha a KKV-eredmény a **B** és **D** ágon is megvan, akkor tényleg
finanszírozási heterogenitásról szól. Ha csak az **A**/**C** ágon, akkor
technológiai műtermék. **Egy nap, makró-kapcsolóval.**

#### ✅ ELVÉGEZVE — 2026-08-24

Kapcsoló: `-DDECOMP=0|1|2|3|4` (+ `-DDECOMPW=0|1` a súlyozási
ellenpróbához). Kód: `dekomp_edl_v09.m`. Eredménydoc:
[`../eredmenyek/2026-08-24_edl_dekompozicio.md`](../eredmenyek/2026-08-24_edl_dekompozicio.md).
Új állítás: `A23`.

**A válasz egyértelmű — és a jó irányba:**

| ág | küszöb (OPTEN=1) | a 0-ághoz képest |
|---|---:|---:|
| 0 alap | 22,36 | 1,00× |
| **B — csak pénzügyi** | **22,62** | **1,01×** |
| **D — technológia azonos** | **22,95** | **1,03×** |
| A — csak `phi_j` | 4,48 | 0,20× |
| C — csak `aa_j` | 1,61 | 0,07× |

A teljes technológiai heterogenitás kivétele a küszöböt **3%-kal**
mozdítja el; csak a pénzügyi heterogenitást meghagyva **1%-kal**. Az
eredmény tehát finanszírozási eredetű. A `t53b` 10/10 küszöbpontja
BK-valid. A `t53c` pontértékrács ugyan 45/45 esetben solver-sikeres, de
0/45 esetben terminálisan BK-valid, ezért abból KKV-előjelet és GDP-sávot
nem közlünk.

**Két dolgot ki kell mondani, mert a bíráló elő fogja venni:**
1. Az **A** és a **C** ág nem „csak technológia" — a pénzügyi blokkot is
   kiegyenlíti, ami mechanikusan felviszi az E típus access-rugalmasságát.
   A tiszta összevetés a `0 ↔ D` és a `0 ↔ B`.
2. Az `ACCSCALE=100` dekompozíciós GDP-sávok mind BK-invalid pontokra
   épültek, ezért visszavontuk őket. A technológiai-robosztussági állítás
   kizárólag a BK-valid küszöbök összevetésére támaszkodik.

**Amit a scan NEM válaszol meg:** az `omega_acc_L = 0` feltevést nem tudja
semlegesíteni (a nagyvállalatnak definíció szerint nincs `acc`-egyenlete).
Az továbbra is a 4. teendő, és továbbra is a legnagyobb egyetlen feltevés.

### 7b. Az alapértelmezett ág (`OPTEN=0`) NEM MÉRT exportarányokon fut

**Külső észrevétel (2026-08-24) tárta fel, egy bemutatóra adott kommentből:
„ezeket az arányokat honnan tudjuk?”** Ellenőrizve, és a válasz kellemetlen:

| | modell-alapérték | saját panel, tág def. | saját panel, 25%-os def. | státusz |
|---|---:|---:|---:|---|
| `phi_E` | 0,56 | 0,3757 | 0,6911 | 🔴 **átvett, nem mért** |
| `phi_D` | 0,05 | 0,0000 | 0,0227 | 🔴 **átvett, nem mért** |
| `phi_L` | 0,365 | 0,3649 | 0,3649 | ✅ mért, négy tizedesig |

A `0,56` és a `0,05` a csapattárs `kkv_dsge_v07_access`-éből átvett
**kiindulóérték** — a forrásfájl maga is így jelöli (*„Ezek indulok:
empirikus ujrakalibracio kell”*) —, és a **saját panelünk egyik definíció
mellett sem adja vissza őket**.

**Mit érint és mit nem:**

- **Az `A01` GDP-sávot NEM érinti**, mert a sáv az `OPTEN=0,1,2,3` ágakon
  együtt van kiszámolva, tehát a mért értékek is benne vannak.
- **Bármely EGYETLEN számot érint, amit az `OPTEN=0` ágról idézünk** — és
  ilyen a `t44`, valamint a `t47`/`t48b` „átvett" oszlopa.
- És érinti a **kommunikációt**: eddig ezt a három számot egyforma
  státusszal közöltük, holott csak az egyik mért.

**Teendő:** minden helyen, ahol a `phi_j` szerepel, jelölni kell, melyik
mért és melyik átvett. A bemutató artifact már javítva. **A `.mod`
alapértelmezését NEM változtatjuk** — az `OPTEN` váltása csapatdöntés, és
a `phi` külön nem cserélhető, mert a `wd_j`/`wx_j` súlyok belőle
származnak.

⚠ **Ez ugyanaz a hibatípus, ami ellen a 13. szakasz figyelmeztet
(„a precizitás csábít") — és a saját bemutatómban követtem el.** A
tanulság: **egy prezentációba menő szám ugyanúgy átmenjen az
állítás-regiszteren, mint egy állítás.** A regiszter elfogta volna;
a bemutatót nem futtattam át rajta.

### 8. Az E/D/L szegmentáció küszöbe kutatói döntés

Az `OPTEN=2` ág az `export_arány ≥ 25%` küszöbbel definiálja az E típust.
A 25% nem természeti törvény — lehetne 10% vagy 50%, és az eredmény
változna. Az `OPTEN=1` ág (bármilyen pozitív export) eltérő szegmentálást ad,
és ott `phi_D = 0` **definíció szerint**.

**Ez normális egy DSGE-ben**, de a helyes állítás: *a típusok kalibrációja
adatból származtatott, de a szegmentáció definíciója kutatói döntés.*

**Teendő:** a küszöb scanelése (10 / 25 / 40%). Fél nap.

### 9. `rho_acc`: objektum-eltérés — ÉS EGY SÚLYOSABB PROBLÉMA (2026-08-24)

⚠ **Ez a tétel a mai méréssel felkerülne a 🔴 listára is.** Külső komment
kérdezte, hogyan lehetne a perzisztencia megbízhatóságán javítani —
utánaszámoltunk, és a válasz átrendezi a képet.

**A MÉRÉS.** A 4 teljes évvel rendelkező 35 982 cégből:

| | db | arány |
|---|---:|---:|
| **soha** nem volt hitele | 29 954 | **83,2%** |
| **mindig** volt hitele | 3 294 | **9,2%** |
| legalább egyszer változott | 2 734 | **7,6%** |

**A cégek 92,4%-a EGYSZER SEM váltott státuszt négy év alatt.** A
státuszváltások eloszlása: 33 248 cégnél nulla váltás, 2 172-nél egy,
522-nél kettő, 40-nél három.

**MIÉRT SÚLYOS EZ.** A `rho_acc = 0,9673` a `p11 − p01` képletből jön, ami
ezt a magas perzisztenciát méri — **de a perzisztencia forrása nem az, amit a
modell feltételez.** A modellben

```
acc_j = rho_acc·acc_j(−1) − lambda·efp_j
```

egy **dinamikus állapotegyenlet**: a `rho` azt mondja meg, milyen lassan
alkalmazkodik a szegmens hozzáférési állapota **egy sokkra**. Amit viszont
mértünk, az túlnyomórészt **állandó cég-heterogenitás**: a legtöbb cég
tartósan az egyik vagy a másik vödörben ül.

**Vagyis a 0,967 nagyrészt azt méri, hogy a populáció STATIKUS, nem azt, hogy
a hozzáférés LASSAN alkalmazkodik.** A kettő nem ugyanaz, és a modell
szempontjából a második számítana.

⚠ **Ez cáfolja az `A11` korábbi „alsó korlát" érvét.** A share-folyamat
lehet perzisztens (a Granger-aggregáció áll), de ebből nem következik a
modell sokk utáni szegmens-alkalmazkodásának `rho_acc` paramétere. És a
modell `acc_j`-je épp azokról a cégekről szól, amelyek
mozognak: a **7,6%-os margóról**.

**Teendők — az 1. a legfontosabb, és ma már tudjuk, hogy kötő:**

1. **Az állapotfüggőség és a heterogenitás szétválasztása.** Dinamikus panel
   probit cég-szintű véletlen hatással (Wooldridge/Heckman kezdeti-feltétel
   kezeléssel), vagy minimum: a `p11`/`p01` külön a valaha váltó almintán.
   **Ez dönti el, hogy a `rho_acc` egyáltalán a helyes objektumot méri-e.**
2. **Kalibráció a marginális populációra.** A modell margója a be- és
   kilépőkről szól; a `p11`/`p01` a 7,6%-os „mozgó" körön egészen más értéket
   adna — és arguably relevánsabbat.
3. **Közvetlen szegmens-szintű becslés több cellával.** 4 év × 3 szegmens
   túl kevés egy AR(1)-hez, de ágazat × méret cellákra bontva (kb. 20 × 3 × 4)
   már becsülhető — és ez a **helyes objektum**, nem a cég-szintű.
4. **Az éves → negyedéves lépés ellenőrzése.** A `rho_q = rho_a^(1/4)` a
   sajátérték gyöke, ami kétállapotú láncnál elvileg helyes — de ellenőrizni
   kell, hogy az implikált negyedéves átmenetmátrix **érvényes
   valószínűségeket** ad-e (beágyazhatóság).
5. **Definíció-robusztusság.** A `van_hitel` öt hitelmező összegén alapul;
   más definíciók (minimális méret, szállítói hitel kizárása) más
   perzisztenciát adnak. Olcsó ellenőrzés.
6. **Több év** — a 2021 előtti panel (2.2) megduplázná a megfigyeléseket.

*Az eredeti objektum-eltérési észrevétel változatlanul áll:*

### 9b. Az eredeti objektum-eltérés (2026-08-21)

Amit mértünk: **cég-szintű bináris** státusz-perzisztencia. Amit a modell
használ: **szegmens-szintű folytonos** állapot. Két különböző objektum.

**De a különbség IRÁNYA ismert** — két független ok szerint a szegmens-szint
perzisztensebb: (a) saját mérés (`t37`): a szegmens-arányok 4 év alatt
0,59–2,20 pontot mozdultak, a BUBOR 12,83-at; (b) Granger-aggregáció:
heterogén AR(1)-ek aggregálása lassabban lecsengő autokorrelációt ad.
Ezért a 0,9673 **sem pontbecslés, sem alsó korlát**: csak leíró,
cégszintű érzékenységi pont. Az `A11` állítást visszavontuk.

### 10. Az `om_j`/`shl_j` súlyok csak a 10+ fős körre

A panel nem tartalmazza a mikrocégeket, tehát a súlyok a 10+ populáción
*belüli* részesedések. Az `shl_L = 0,466` vs a modell jelenlegi `0,30`
különbségét jórészt ez magyarázza. **Ezért maradt az `-DOPTEN`
alapértelmezése `0`.** KSH/Eurostat SBS bontás kell. <span>`F03`</span>

### 10b. A JV-paraméterek 2008-asok — és a minta időszaka nincs rögzítve

**Külső észrevétel (2026-08-24, artifact-komment), és jogos.** A 91-ből
**28 paraméter** a Jakab–Világi tanulmányból jön (MNB WP **2008/9**) — és épp
ez volt a fő érv a mag választása mellett: „magyar adaton becsült". Ez igaz,
de a minta a 2008-as válság *előtt* zárul.

Amit ez érint: bérragadósság (0,657), árragadósság (0,921), szokásformálás
(0,646), a korlátozott háztartások aránya (0,25), és a sokk-perzisztenciák.
Mind egy **másik monetáris és pénzügyi rezsimből**.

⚠ **És egy önálló hiányosság:** a **JV-minta pontos időszaka a projekt
dokumentációjában nincs rögzítve** — vagyis jelenleg meg sem tudjuk mondani,
mennyire régiek az értékek. Ez fél óra munka, és nélküle a „becsült magyar
adaton" érv nem ellenőrizhető.

**Miért NEM a megoldás az egyes értékek cserélgetése:** a 28 érték
**együttesen becsült poszterior**. Ha egyet kiveszünk és beemelünk helyette
egy újabb, független becslést, elrontjuk a készlet belső konzisztenciáját —
és a modell megoldása olyan paraméter-kombinációra fut, amit soha senki nem
becsült együtt.

**A védhető út, két lépésben:**

1. **Direkt mérés ott, ahol létezik.** A korlátozott (likviditáskorlátos)
   háztartások arányára ez a helyzet: a **háztartási vagyonfelmérés (HFCS)**
   közvetlenül méri, magyar hullámokkal. Egy direkt mérés **jobb**, mint
   bármelyik DSGE-becslés — és ez a paraméter amúgy sem becsült poszterior a
   JV-ben, hanem strukturális/survey feltevés. **Ellenőrizendő, mit ad.**
2. **A vintage explicit kimondása mindenhol máshol.** Nem cseréljük, hanem
   megnevezzük: „2008 előtti magyar mintán becsült". Ez a tanulmányban egy
   lábjegyzet, és elveszi a kritika élét.

*A teljes újrabecslés (28 paraméter, mai magyar adaton) önálló kutatási
projekt — a decemberi leadás keretében nem reális, és a `2.7`-hez hasonlóan
opcióként tartjuk nyilván.*

### 11. A háztartási blokk minimális

**Nem hiányzik** — van optimalizáló (75%) és korlátozott (25%) háztartás,
Euler-egyenlettel, munkakínálattal, és a GDP kiadási oldalon áll össze
(`C + I + G + X − M`). De nincs benne: heterogén likviditási korlát,
háztartási hitelpiac, munkapiaci extenzív margó, életciklus, részletes
adózás.

**Ez tudatos és védhető:** a kutatási kérdés a **vállalati** finanszírozási
heterogenitás, nem a háztartási. Egy HANK-blokk más projektté tenné.
**Nem teendő** — de a leadásban ki kell mondani, hogy a jóléti és
elosztási kérdésekre a modell nem alkalmas.

### 12. A Phillips-aszimmetria — inert csapda

A `pi_E`/`pi_D` **nyers** sokkot kap (`eps_md`), a `pi_L`
**AR-folyamatot** (`e_mx_ar`, `rho_mx = 0,318`). Jelenleg egyetlen eredményt
sem érint, mert egyik sokk sincs hajtva egyetlen szcenárióban sem — de egy
későbbi ár-markup sokk **némán** eltolná a KKV/nagyvállalat összevetést.
Füstteszt-őr fogja el.

---

## 🟢 ELLENŐRIZVE — NEM PROBLÉMA

Ezek felvethető kritikák, amiket **megnéztünk és nem állnak**. Érdemes
tudni, hogy miért, mert újra elő fognak jönni.

| Felvetés | Miért nem probléma |
|---|---|
| „A termelési egyenletek csak összeadások — túl bugyuta" | A modell **log-linearizált**. Egy `Y = A·K^α·L^(1−α)` függvényből logaritmus után `y = a + α·k + (1−α)·l` lesz. Az additív alak a linearizálás következménye, nem a modell primitívsége. |
| „Miért **kivonjuk** a termelékenységet a határköltségből?" | Mert közgazdaságilag helyes: ha `A` nő, ugyanannyi inputból több output jön, tehát **egy egység output előállítása olcsóbb**. `mc = ζ·rk + (1−ζ)·wz − a`. A mínusz kötelező. |
| „Hol vannak a háztartások?" | Benne vannak (11. pont). A GDP `C + I + G + X − M` alakban áll össze, nem vállalati kibocsátás összegeként. |
| „Nem aggregálódik a szegmens-kibocsátás a GDP-be" | **Nem is lehet:** a `y_j` bruttó kibocsátás importált köztes inputtal, a `y` kiadási oldali GDP. Ami teljesül — `Σom_j·y_j = w_d·y_d + w_x·y_x` — most tesztelt (4,34e−19). <span>`A14`</span> |
| „Az exportáló KKV eleve rosszul jár az euróval" | **Nem következik.** Van negatív csatornája (reálfelértékelődés → versenyképesség) és pozitív is (felár ↓ → hozzáférés ↑ → beruházás ↑). A nettó hatást a modell számolja ki, nem mi tesszük fel. |

---

## A teendők sorrendje — mit érdemes tényleg megtenni

**A rendezőelv:** ne új egyenleteket írjunk, hanem **mutassuk meg, hogy a
meglévő eredmény nem a nem azonosított paraméterek műterméke.** A bíráló
első kérdése ez lesz, és jelenleg nincs rá válaszunk.

| # | Teendő | Ráfordítás | Miért |
|---|---|---|---|
| ~~**1**~~ | ~~**`ACCSCALE` szétbontása**~~ ✅ **KÉSZ 2026-08-24** — és többet hozott: a modell csak a `λ·ω` szorzatot azonosítja (`A22`), a küszöb izo-szorzat görbe | fél nap | ~~a küszöb két rugalmasság szorzatán van~~ |
| ~~**2**~~ | ~~**E/D/L dekompozíciós scan**~~ ✅ **KÉSZ 2026-08-24** — a technológia teljes kiegyenlítése a küszöböt 3%-kal mozdítja (`A23`) | 1 nap | ~~ez válaszolja meg a fő referee-kérdést~~ |
| **1★** | **`psi_j` scan a fordított méret-sorrenddel is** | fél nap | **ÚJ, 2026-08-24:** a lumpy-investment irodalom a jelenlegi `psi_S < psi_L` ellenkezőjét sugallja — ez a hetedik gyanús paraméter lehet |
| **2★** | **`zsov` saját becslés két nyilvános idősorból** | fél nap | **ÚJ:** a húszból a legolcsóbb horgony, és tisztán makró idősorból megy |
| **3** | **MNB new-business kamat bekérése** — cellaszinten (méret × összeg × fixálás × futamidő + volumenek, 2015–24) | levél + várakozás | az egyetlen tétel, ami **időbeli aggregátum**, tehát nem szenved a pre-periódus problémától |
| **4** | **`omega_acc_L` scan** | fél nap | ez a legnagyobb egyetlen feltevés |
| **5** | A `−200 bp` forrása | fél nap | ez viszi a főeredmény nagyságrendjét |
| **6** | A 25%-os szegmentálási küszöb scanelése | fél nap | kutatói döntés, mérni kell a hatását |
| **7** | KSH/Eurostat SBS mikrokör-bontás → `om_j`/`shl_j` | fél nap | ez oldja fel az `-DOPTEN` alapértelmezését |
| **8** | `eps_ces` magyar horgony | 1–2 nap | a szektorális eredmény másik fele |

~~**Az 1. és 2. tétel együtt másfél nap, és többet ér, mint bármi más ezen a
listán**~~ — **2026-08-24: mindkettő megvan.** Beváltak: nem új eredményt
gyártottak, hanem a meglévőt tették védhetővé, és mindkettő **többet
hozott, mint amit a teendő megfogalmazása várt** (a szorzat-azonosítás,
illetve az, hogy a technológiai hozzájárulás 3%).

A lánc `kalibráció → azonosítás → érzékenység → validáció` szerint a
projekt a **harmadik lépésnél** tart. A `psi_j` (1★) az egyetlen újonnan
felmerült kockázat.

**Kapcsolódó új doksik:**
[λ/ω szétbontás](../eredmenyek/2026-08-24_lambda_omega_szetbontas.md) ·
[E/D/L dekompozíció](../eredmenyek/2026-08-24_edl_dekompozicio.md) ·
[D-kategória irodalmi keresés](2026-08-24_D_kategoria_irodalmi_kereses.md)

---

## Egy mondat, amit érdemes fejben tartani

> Ha van egy nem azonosított paraméter, és úgy választod meg, hogy a
> kívánt eredmény jöjjön ki, akkor a modell **mechanikusan képes
> előállítani a hipotézisedet.**

Ez nem szándékos manipulációt jelent — hanem azt, hogy a
`kalibráció → azonosítás → érzékenység → validáció` láncban a projekt
~~jelenleg a **második lépésnél** áll~~ **2026-08-24 óta a harmadiknál
tart**: az 1. és 2. teendő pontosan az érzékenységi lépést vitte be.

*Kapcsolódó: [`kalibracio_teendok_csapatnak.md`](kalibracio_teendok_csapatnak.md)
· [`../../ALLAPOT.md`](../../ALLAPOT.md) ·
[`../figyelmeztetesek/`](../figyelmeztetesek/)*
