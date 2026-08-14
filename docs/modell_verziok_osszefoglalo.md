# Modellverziók összefoglalója

> ## ⚠ 2026-08-12: az IO-alapú számok (s_kkv, 6% hazai input, 42%→4,4%) NEM állnak
>
> Ez a dokumentum több helyen hivatkozik az input-output táblából számolt `t24`
> eredményre — az **autóipar 6,0% hazai köztes input** számra, az ebből kalibrált
> **`s_kkv` = 0,05** értékre, és az ezen alapuló **„a vertikális link a hatás 42%-a
> helyett csak 4,4%-a”** korrekcióra. **A mérés hibás:** a döntő azonosság-teszt
> (`dom + imp = P2`) szerint az összegzett köztes felhasználás a nemzeti számlák
> P2-jének csak **1,8–8,6%-a**; a szűrt változat **negatív** hazai arányt ad; és a
> `TOTAL × CPA_TOTAL` sarok 0, pedig annak kellene a legnagyobbnak lennie.
>
> **A gyökérok még nyitott, és azt sem tudjuk, melyik irányba téves** — tehát sem a
> 6%, sem az ellenkezője nem állítható. Amit ez **nem** érint: az aggregált
> GDP-hatás (robusztus a link ki-be kapcsolására), és a `v06_3type`/`v07_access`
> vonal, amely nem használ `s_kkv`-t. Részletek és teendők:
> `docs/FIGYELMEZTETES_io_tabla_gyanus.md`.



> **FRISSÍTÉS (2026-07-13): alapcikk-váltás.** Csapatdöntés: az alap a
> **Jakab–Világi (MNB WP 2008/9)** — magyar adaton becsült DSGE —, nem az
> EAGLE-HU. A lenti v0.1–v0.5 (EAGLE-alapú) sor referencia/robusztussági
> vonalként marad; a fő vonal a `jv_dsge_v01–v06` — **a teljes JV-narratíva
> ebben a fájlban, az EAGLE-szakasz után** (technikai per-verzió log:
> `src/model/README.md`). **Korrekció:** a korábbi szövegek „a DSGE
> ~0,3–0,7%-ot ad, a többi a 2–3. réteg terepe" megfogalmazása az
> EAGLE-vonal konkrét számaira vonatkozott, és félreérthetően a DSGE
> szerepének leértékeléseként olvasható — ez hibás keret. **A DSGE a
> projekt gerince és kötelező leadandó**; a red flag-vizsgálat a
> tanulmány keretezését módosította (támogatásfüggés + hozzáférés),
> nem a DSGE súlyát. A JV-alapon a tartós GDP-hatás egyébként
> +0,78…+1,41% — közel a vázlat 1,5–2%-os sávjához.

# EAGLE-vonal (referencia): v0.1 → v0.3

*2026-07-08 · a `src/model/` Dynare-implementáció fejlődése, érveléssel,
eredményekkel és következtetésekkel. Kapcsolódik: `docs/modell_vazlat/`
(koncepció), Notion döntésnapló (döntések), `output/figures/f04–f06` (ábrák).*

## Kiindulópont

Az átveendő alapmodell a **Békési–Kaszab–Szentmihályi: The EAGLE model for
Hungary (MNB WP 2017/7)**. Kiderítettük: a paperhez **publikus MATLAB/Dynare
kód nincs** (az EAGLE az ESCB-munkacsoporton belül él), viszont a WP
26–43. oldala **teljes egyenlet-appendixet és kalibrációs táblákat** ad.
Ezért az újraimplementálás útját választottuk — de nem a teljes 4-blokkos
EAGLE-t, hanem a pitch (2026-07-06) szerinti **szűk magot**: kétszektoros
kis nyitott gazdaság, méretfüggő BGG-akcelerátorral, a bankblokk helyett
két exogén hitelköltség-sokkal. Az érv ugyanaz, mint a modellválasztásnál:
minden állítás abban a rétegben éljen, ahol bizonyítható, és a modell csak
akkora legyen, amekkorát az adat elbír.

---

## v0.1 — A futó váz (sztochasztikus, IRF-ek)

**Fájl:** `kkv_dsge_v01.mod` · **ábra:** `f04` · **kimenet:** `irf_v01.csv`

### Lépések és érvelés

1. **Log-linearizált, kompakt forma.** A teljes nemlineáris EAGLE-blokk
   helyett 44 log-lineáris egyenlet. Érv: hetek helyett napok alatt van
   futó modell; a mechanizmusok (akcelerátor, transzmisszió) ellenőrizhetők,
   mielőtt a részletgazdagságba fektetnénk.
2. **Két szektor CES-aggregálással.** KKV (S) és nagyvállalat (L) szektor
   közös munkapiaccal, szektorális árakkal és Phillips-görbékkel. Technikai
   tanulság: a relatívár-identitások naiv felírása **egységgyököt** hagy a
   rendszerben — a súlyozott relatívár-összeg nullára kötésével javítottuk.
3. **BGG-lite pénzügyi blokk szektoronként.** EFP, Tobin-q, nettó vagyon;
   a méretfüggés két csatornán: érzékenyebb akcelerátor a KKV-nál
   (χ_S=0,06 > χ_L=0,02) és eltérő tőkeáttétel — ez utóbbi **a saját
   Opten-panelünk mediánjaiból** (lev_S=1,6, lev_L=1,85).
4. **A két hitelköltség-sokk** (szuverén, banki) exogén AR(1)-folyamatként,
   a pitch transzmissziós súlyaival (szuverén ~25%, banki ~60% a KKV-EFP-be).

### Eredmények

- A modell **megoldódik** (Blanchard–Kahn rendben), a momentumok stacionáriusak.
- Egy banki forrásköltség-sokkra a KKV-EFP ~28 évesített bázisponttal mozdul
  a nagyvállalati ~13-mal szemben; a KKV-beruházás válasza **közel kétszeres**.

### Következtetés

A méretfüggő akcelerátor **endogén módon** előállítja a várt aszimmetriát —
a projekt fő mechanizmusa működik, a váz alkalmas arra, hogy szcenáriót
építsünk rá. A kalibráció ekkor még nagyságrendi.

---

## v0.2 — Az euró-belépési szcenárió (perfect foresight)

**Fájl:** `kkv_dsge_v02.mod` · **ábra:** `f05` · **kimenet:** `szcenario_v02.csv`

### Lépések és érvelés

1. **A prémiumok sokkból pályává válnak.** Az euróbevezetés nem sztochasztikus
   zaj, hanem **anticipált, permanens** prémium-csökkenés → a sov/bank változó
   exogén determinisztikus pálya, perfect foresight megoldással.
2. **Időzítés a vázlat 5 szakasza szerint:** bejelentés (q1, innen hat az
   anticipáció) → ERM-II konvergencia (a szuverén prémium a végső csökkenés
   60%-áig süllyed q12-re) → belépés (q13, itt nyílik a banki swap-bázis
   csatorna) → normalizálódás (q16-ra teljes hatás) → tartós szakasz (endval).
3. **Három pálya** a vázlat érzékenységi logikája szerint: alap
   (−200 bp szuverén / −45 bp banki, 60% transzmisszió), optimista
   (−250/−60/70%), pesszimista (−150/−30/40%). A transzmisszió-eltérést a
   pálya skálázásába olvasztottuk — a paraméterek fixek, nincs kettős
   számbavétel.

### Eredmények

- A kibocsátás már a bejelentéstől emelkedik; a KKV-beruházás az alappályán
  +0,65%-on tetőzik (nagyvállalati: +0,46%).
- **10 éves GDP-hatás: +0,08% / +0,125% / +0,17%** (pessz/alap/opt).

### Következtetés — és a kritikus kérdés

Az aszimmetria a szcenárióban is él, de az aggregált hatás **nagyságrenddel
kisebb** a vázlatban várt 1,5–2%-nál. Diagnózis: a szuverén konvergencia a
v0.2-ben kizárólag a vállalati hitelfeláron keresztül hat, miközben a
gazdaság kockázatmentes hozamgörbéje érintetlen marad. Ez jelölte ki a
v0.3 feladatát.

---

## v0.3 — WP-kalibráció + UIP-országprémium csatorna

**Fájl:** `kkv_dsge_v03.mod` · **ábra:** `f06` · **kimenet:**
`szcenario_v03.csv` + `szcenario_v03_hosszutav.csv`

### Lépések és érvelés

1. **Kalibráció a WP 2017/7 appendixének HU oszlopából** (kiolvasva a
   PDF-ből): β=0,99, σ=0,4, α=0,30, habit 0,7, Calvo-ár 0,92 → κ≈0,01
   (nagyon ragadós magyar árak), beruházási kiigazítás 6,0, Taylor
   0,87/1,70/0,10, C/Y=0,61, I/Y=0,19, G/Y=0,20, X/Y=M/Y=0,75.
   A pénzügyi blokk marad az Opten-panelből — a makro-mag a paperé,
   a mikro-pénzügyi réteg a miénk.
2. **UIP-országprémium csatorna** zsov=0,5 súllyal, explicit
   dekompozícióval: UIP = kockázatmentes görbe / árfolyam- és NFA-dinamika;
   EFP = vállalati hitelfelár (a tsov/tbank súlyok változatlanok).
3. **Hosszú távú (endval) steady state-ek exportja** — kiderült, hogy a
   10 éves pont önmagában félrevezet.

### Eredmények

| Pálya | GDP 10 év | GDP hosszú táv | KKV / nagyváll. kibocsátás (h.táv) |
|---|---|---|---|
| pesszimista | +0,08% | **+0,32%** | |
| alap | +0,11% | **+0,49%** | +0,56% / +0,41% |
| optimista | +0,15% | **+0,67%** | |

- A KKV-többlet **tartós** (nem csak átmeneti felpattanás).
- A felépülés lassú: 10 évnél a hosszú távú szint ~22%-a, 30 évnél ~fele —
  a szűk keresztmetszet a tőkefelhalmozás (magas beruházási kiigazítási
  költség a WP-ben).
- **Belépés előtti átmeneti visszaesés (~−0,2%):** az anticipált konvergencia
  reálfelértékelődése előbb fékezi az exportot, mint hogy a beruházási
  csatorna beindulna — a klasszikus konvergenciás felértékelődési dilemma,
  endogén módon.

### Két strukturális tanulság

1. **A reprezentatív háztartás Euler-egyenlete hosszú távon β-hoz köti a
   reálkamatot** → az UIP-prémium csökkenése főleg az NFA/árfolyam-oldalt
   mozgatja, a tartós kibocsátási hatást az EFP-ék (tőkeköltség-csatorna)
   hordozza. Aki a teljes hozamgörbe-konvergenciából akar nagy aggregált
   hatást, annak nem-Ricardiánus háztartások / OLG kell — az EAGLE-ben a
   HU-blokk 75%-a nem-Ricardiánus! Ez a v0.4+ egyik iránya.
2. **A rétegek munkamegosztása számszerűen igazolódott:** a DSGE-réteg a
   hitelcsatornából ~0,3–0,7% tartós GDP-t ad; a vázlat 1,5–2%-a a
   kereskedelmi/tranzakciós csatornákat és az extenzív margót is
   tartalmazza — ezek tudatosan a 2. rétegben és a 3. blokkban élnek.

---

## Össz-összefoglaló: mit tudtunk meg *(az EAGLE-vonalról, 2026-07-08 állapot)*

> **⚠ EZ A SZAKASZ TÖRTÉNETI, ÉS AZ EAGLE-VONALRA VONATKOZIK.** A fő vonal
> (JV) saját összefoglalója lentebb, a JV-szakasz végén van. Két pontja
> azóta megdőlt: az **1. pont** („a méretfüggő akcelerátor minden
> szcenárióban endogén KKV-többletet ad") a JV-vonalon **nem áll** — a
> `chi_S > chi_L` aszimmetria a hosszú távon a KKV ELLEN dolgozik
> (`∂i_ss/∂F = −1/chi`), lásd a JV v05/v06 bejegyzést; a **2. pont**
> megfogalmazása pedig pontosan az, amit a fájl fejléce már hibás keretnek
> minősített (a DSGE nem alárendelt réteg, hanem a projekt gerince).

1. **A fő üzenet gépezete működik.** A méretfüggő akcelerátor minden
   verzióban, minden szcenárióban endogén KKV-többletet ad, ami tartós.
   Ez a tanulmány 1. számú állításának strukturális alapja.
   **→ MEGDŐLT a JV-vonalon (2026-08), lásd fent.**
2. **A hitelcsatorna önmagában ~0,3–0,7% tartós GDP.** Nem 1,5–2% — és ez
   így van jól: a különbség a másik két réteg (leképezés, extenzív margó)
   és a modellen kívüli csatornák (kereskedelem, tranzakciós költség)
   terepe. A tanulmány védhetőségének kulcsa, hogy ezt nyíltan így
   kommunikáljuk. **→ A KERETEZÉS HIBÁS, lásd a fájl fejlécét.**
3. **Az időprofil legalább olyan fontos, mint a szint.** A hatás lassan
   épül fel (tőkefelhalmozás), és a belépés előtt átmeneti
   reálfelértékelődési visszaesés van. Szakpolitikai olvasat: az ERM-II
   szakasz kommunikációja és a fiskális hitelesség nem díszlet, hanem a
   pálya alakját meghatározó tényező — pont ahogy a vázlat pesszimista
   forgatókönyve sejtette.
4. **Az adat és a modell összeér.** A pénzügyi blokk kalibrációja
   (tőkeáttételek, EFP-szintek) a saját Opten-panelünkből jön; a makro-mag
   a magyar EAGLE-ből. A két forrás szerepe tisztán szétválasztott.

## Hogyan tovább *(2026-07-08-i terv, TELJESÍTVE — történeti)*

1. **v0.4: kamatunió-rezsimváltás.** ✔ kész (`kkv_dsge_v04`).
2. **2. réteg megírása:** ✔ kész (`s06`, majd `s13` a v05-re).
3. **3. blokk:** extenzív margó panel-ökonometria ✔ kész (`t10`/`t11`).
4. **Érzékenységi futások:** ✔ részben (`sens_skkv_v05`, `sens_tsuly_v05`,
   `diag_nuuni_v05`, `stress_v06`).
5. **Párhuzamosan:** EAGLE-kód bekérése (Kaszab Lóránt) — **még nyitott**;
   AVG-besorolás a szállítóval — **még nyitott**.

*Az aktuális teendőlista a JV-szakasz végén van.*

---

# JV-vonal (fő): v01 → v06

*2026-08-02 · a `jv_dsge_v0N.mod` sor fejlődése, érveléssel, eredményekkel
és következtetésekkel. Ez a projekt fő leadandója. Kapcsolódik:
`src/model/README.md` (technikai, per-verzió log), `output/figures/f19–f21`,
`output/tables/t20–t26`, `docs/FIGYELMEZTETES_fo_allitas.md`,
`docs/2026-08-02_hibafeltaras_naplo.html`.*

> **Notion-kereszthivatkozás: MÉG JÁR.** A JV-vonal modellezési döntései
> (alapcikk-váltás, `nu_uni` zárás, `s_kkv` IO-kalibráció, `TSCEN`
> alapérték, és a v06 termelési szegmentálása) még nincsenek felvezetve a
> Notion döntésnaplóba — ebben a munkamenetben nem volt Notion-hozzáférés
> (a connector hitelesítést kér). Aki hozzáér, pótolja, és innen csak
> hivatkozzunk rá, ne ismételjük meg az érvelést.

## Kiindulópont

Csapatdöntés (2026-07-13): az alapmodell a **Jakab–Világi: An estimated
DSGE model of the Hungarian economy (MNB WP 2008/9)**. A döntő érv az
EAGLE-HU-val szemben: a JV paraméterei **magyar adaton Bayes-i módszerrel
becsültek**, nem kalibráltak — egy magyar szakpolitikai megbízásnál ez
védhetőbb. A WP appendixe teljes log-linearizált egyenletrendszert ad,
tehát az újraimplementálás járható. Az EAGLE-vonal referencia/robusztussági
szerepbe került.

---

## v01 — A JV-mag újraimplementálása

### Lépések és érvelés
1. **Az Appendix A.4–A.9 log-linearizált rendszere**, az IT-rezsim
   poszterior-átlag paramétereivel. Az érv: ne mi kalibráljunk, ha van
   magyar adaton becsült paraméterkészlet.
2. **Kétszektoros termelés (hazai + export)**, munka+import kompozit
   inputtal. Ez a JV saját szerkezete — *és itt érdemes megjegyezni, hogy
   ez a felbontás HAZAI/EXPORT, nem KKV/nagyvállalat.* A kettő
   összekeverése lett a vonal legnagyobb szerkezeti hibája, amit csak a
   v06-ban javítottunk.
3. **25% kézről-szájra háztartás** — survey-alapú, nem szabad paraméter.
4. Hibrid ár / exportár / **bér** Phillips-görbék indexálással, Tobin-Q
   (Φ″=13), UIP (becsült ν=0,001), Taylor (0,761/1,379).

### Eredmények
Fut, Blanchard–Kahn rendben, momentumok stacionáriusak. Az egyszerűsítések
(nincs csúszó-leértékelés blokk, nincs adaptív tanulás, „KOZELITES"-sel
jelölt SS-arányok) a `.mod` fejlécében dokumentálva.

### Következtetés
A becsült magyar mag működik és élesebb dinamikát hordoz, mint az EAGLE
(lapos ár-NKPC, becsült UIP-dinamika, import-intenzív exportszektor).
Ez lett a vonal alapja.

---

## v02 — Kétszektoros BGG a finanszírozási oldalon

### Lépések és érvelés
1. **Méretfüggő BGG-akcelerátor**: `k = om_S·k_S + (1−om_S)·k_L`,
   típusonkénti Tobin-Q, nettó vagyon, EFP `chi_S=0,06 > chi_L=0,02`.
   A tőkeáttételek (`lev_S=1,6`, `lev_L=1,85`) a **saját Opten-panelünkből**.
2. **A JV termelési szerkezete szándékosan érintetlen** — a minimális
   beavatkozás elve: csak a finanszírozást szegmentáljuk.

### Eredmények
Monetáris sokkra a KKV-beruházási válasz ~1,5×, az EFP-aszimmetria 2,4×.
Az akcelerátor a JV-magon is él.

### Következtetés — és a vonal legdrágább tanulsága, utólag
A „termelési szerkezet érintetlen" döntés akkor helyesnek tűnt, és a `.mod`
is így dokumentálta. **Négy verzión át senki nem vette észre, hogy ezzel a
KKV/nagyvállalat szétválasztás PUSZTÁN PÉNZÜGYI maradt** — a termelés
oldalán a modell továbbra is csak hazai/export bontást ismert. Innen jön a
v05-ben feltárt két patológia (reallokációs maradék, `efp_S ≡ efp_L`), és
ezt javítja a v06. **Tanulság a jövőre: ha egy dimenziót bevezetünk, meg
kell nézni, hogy a modell MELYIK blokkjai tudnak róla — nem elég, hogy
konzisztens és lefut.**

---

## v03 — Euró-szcenárió: UIP-országprémium + kamatunió-rezsimváltás

### Lépések és érvelés
1. **Anticipált, determinisztikus prémium-pályák** (perfect foresight):
   szuverén és banki felár csökkenése, bejelentés q1, belépés q13.
2. **`zsov=0,5` UIP-csatorna** — a szuverén konvergencia nem csak a
   vállalati EFP-n hat, hanem az egész kockázatmentes hozamgörbén. Ez a
   v0.2-es EAGLE-tanulság átvitele: nélküle a hatás nagyságrenddel kisebb.
3. **Kamatunió-rezsimváltás** (`uni` dummy): belépés előtt Taylor+UIP,
   utána közös euró-kamat, nincs önálló árfolyam.

### Eredmények
Alappálya hosszú táv **+1,09% GDP** (opt +1,41 / pessz +0,78), 10 évnél
+0,44%, bejelentési dip −0,99%.

### Zárási tanulság (fontos, visszatérő)
Az unió-ágon a JV **becsült** `nu_b=0,001` adósság-rugalmassága **túl
gyenge horgony**: az NFA −250% GDP-nél állt volna be. Külön technikai
zárás kell (`nu_uni`). Ez a v05-ben újra előjött, erősebb formában.

---

## v04 — Vertikális szegmentálás: a KKV mint beszállító

### Lépések és érvelés
1. **Csapatdöntés (2026-07):** a KKV **nem versenytársa**, hanem
   **beszállítója** a nagyvállalatnak. Ez a projekt „Audi-kérdése": miért
   van egy exportőrnek hazai beszállítója. A modellben: KKV = hazai
   szektor (magas EFP, rugalmas), nagyvállalat = export szektor.
2. **Vertikális link két oldalon:** költség-oldal (az exportőr
   határköltsége tartalmazza `s_kkv·mc_d`-t) és mennyiség-oldal (`h_dx` a
   KKV-keresletben).
3. Az érv, amiért ez fontos: így az euró-hitelsokk **pozitív összegű** — a
   KKV egészsége az exportőrt is segíti, nem „a gyengébb meghal".

### Eredmények
BK teljesül; a lánc együtt mozog (monetáris lazításra export, `h_dx` és
KKV együtt +); a méret-aszimmetria él (KKV-beruházás 2,9% vs. 2,1%).

### BK-tanulság *(a projekt egyik újrahasznosítható tudása)*
Az **első** változat — szektor-specifikus tőke (`rk_S`/`rk_L`) **+
CPI-szétválasztás** — megbontotta a Blanchard–Kahn feltételt. A robusztus
verzió a v02 közös-`rk` szerkezetére épült. **→ EZT A LECKÉT A v06
PONTOSÍTOTTA:** nem az `rk_S`/`rk_L` volt a hibás, hanem a KOMBINÁCIÓ.

---

## v05 — Szegmentált euró-szcenárió (a v04 és v03 összevonása)

### Lépések és érvelés
A v04 szegmentálása addig csak *általános* sztochasztikus sokkokra futott,
a v03 euró-pályája pedig szegmentálás *nélkül*. A v05 a hiányzó láncszem:
szegmensenkénti kimenet a **valós** euró-belépési pályán.

### Három kalibrációs javítás — mind lefelé
1. **`nu_uni` 0,01 → 0,25.** Az első futás implauzibilis volt (export
   +12,9%, rer +34,7%): a vertikális link önerősítő kört hoz létre, amihez
   a v03-ból örökölt zárás túl gyenge. A 0,25 a plató elején van, tehát az
   eredmény nem érzékeny a pontos értékre.
2. **`shd_v` mostantól `s_kkv`-ból származtatott.** A független megadás
   ugyanazt a kereskedelmi kapcsolatot írta le két oldalról — az
   alapkalibrációnál az export-input tag a KKV-kibocsátás **115%-át** adta.
3. **`s_kkv` 0,20 → 0,05, Eurostat IO-táblából** (`t24`). A korábbi érték
   **négyszeres túlkalibrálás** volt, és a modell 0,25-nél lévő pólusának
   vonzásában állt.

### Eredmények
Hosszú távú GDP alap **+0,426%** (opt +0,578 / pessz +0,274). Felár alap
KKV −37,2 bp vs. nagyvállalat −24,7 bp. A vertikális link hozzájárulása
**4,4%** (+0,407% link nélkül → +0,426%) — **nem a korábban közölt 42%**,
az a túlkalibrált `s_kkv`-val készült.

### Következtetés — és három strukturális figyelmeztetés
A link-hozzájárulás összeomlása 42%-ról 4,4%-ra **önmagában eredmény**: a
magyar FDI-vezérelt exportszektor hazai beszállítói integrációja gyenge
(autóipar **6,0%**, elektronika **4,2%** hazai köztes input) — a „duális
gazdaság" kvantitatív megjelenése. Az „Audi-narratíva" mechanizmusa
létezik, de vékony.

A 2026-08-i kritikai felülvizsgálat három strukturális problémát tárt fel
(részletesen a `.mod` fejlécében és a hibafeltárási naplóban):
- **(A)** a szegmens-tőke **reallokációs maradék** ⇒ szegmens-szintű
  beruházást ebből a modellből nem szabad közölni;
- **(B)** `∂i_ss/∂F = −1/chi` ⇒ a `chi_S > chi_L` a hosszú távon **a KKV
  ELLEN dolgozik**, és steady state-ben `efp_S ≡ efp_L`;
- **(C)** a modell **exaktul lineáris** a `tsov`/`tbank`-ban ⇒ a `TSCEN=3`
  a `TSCEN=1` és `2` exakt átlaga, nem önálló teszt.

Emellett a `t_S > t_L` feltevés **nem azonosítható** az adatból (a becsült
arány 0,26 és 2,75 között szóródik, egyetlen különbség sem szignifikáns) —
ez **azonosítási kudarc, nem cáfolat**.

---

## v06 — A v05 belső javítása *(átcímkézve 2026-08-11)*

> **⚠ EZ A SZAKASZ EREDETILEG „A termelési oldal szegmentálása" CÍMEN
> KÉSZÜLT, ÉS A CÍM FÉLREVEZETŐ VOLT.** A v06 fixe úgy működik, hogy
> **azonosítja** a hazai/export (`d`/`x`) felbontást a KKV/nagyvállalat
> (`S`/`L`) felbontással — márpedig pontosan ez az összecsúsztatás a
> szerkezeti alapprobléma, amit a kritika felvetett. A `jv_v05_szerkezeti_
> tanulsagok` jegyzet (Samu; lokális repóban volt, GitHubra nem került fel,
> ezért a v06 írásakor nem ismertük) explicit kimondja: *„nem ez lenne a
> leképezés: KKV = hazai, nagyvállalat = export — hanem ez: KKV: hazai +
> export értékesítés, nagyvállalat: hazai + export értékesítés"*.
>
> **Következmény:** ebben a verzióban minden „méret"-eredmény valójában
> „piaci orientáció"-eredmény. Az összecsúsztatás nem szűnt meg, csak
> implicitből **strukturálissá** vált. A méret/piac szétválasztás valódi
> megoldása a `kkv_dsge_v06_3type` / `kkv_dsge_v07_access` vonal (E = export-
> KKV, D = hazai KKV, L = nagyvállalat; a KKV is exportál, a nagyvállalat is
> értékesít itthon).
>
> **Amit a v06 valóban megold, és ami megmarad:** a szegmens-tőke nem
> reallokációs maradék többé, megszűnik a „közös rk ⇒ `efp_S ≡ efp_L`"
> patológia, és az aggregált eredmény nem mozdul. Ezért a v06 a **v05
> karbantartott, javított változata** — nem a szegmentálási kérdés válasza.

### Lépések és érvelés
A kiinduló észrevétel (csapattag, 2026-08): a szétválasztás eddig csak a
pénzügyi blokkban élt, ezért **a feltevések hajtják a modellt**, nem a
szerkezet. A bizonyíték a v05-ből, szó szerint két sor:

```
k     = om_S*k_S + (1-om_S)*k_L;         // om_S  = 0,50  (pénzügyi súly)
k(-1) = sh_kd*(...) + (1-sh_kd)*(...);   // sh_kd = 0,65  (termelési súly)
```

**Két különböző szám ugyanarra a felosztásra, és semmi nem kötötte össze
őket.** A fix négy lépésben: (1) közös `rk` → `rk_S`/`rk_L`; (2) a `d`/`x`
címkék átnevezése `S`/`L`-re, azonos Cobb–Douglas-paraméterekkel; (3) a
régi, `sh_kd`-súlyozott aggregált tőkepiaci azonosítás **törölve**, helyette
két külön egyenlet — a BGG-ben felhalmozott szegmens-tőke **közvetlenül a
saját termelését hajtja**; (4) `sh_kd` törölve, `om_S` az egyetlen
partíciós súly.

A megfontolás, amiért ez és nem egy harmadik dimenzió: nem új szegmens-
struktúrát építettünk a meglévő `d`/`x` mellé, hanem **azonosítottuk a
kettőt** — ami egyébként is a v04-es csapatdöntés tartalma volt (KKV =
hazai, nagyvállalat = export). Így a változtatás minimális, és a `px`/CPI-
blokk érintetlen marad.

### Eredmények
- **A v05 (A) és (B) patológiája EGYSZERRE oldódott meg** — ugyanaz volt a
  gyökerük, két tünettel. A szegmens-tőke többé nem maradék, és
  `efp_S ≠ efp_L` **már steady state-ben is** (TSCEN=3: 0,0247 pp,
  `rk_S`=−0,84% vs. `rk_L`=−1,46% valódi eltéréséből).
- **Aggregált GDP változatlan nagyságrendben:** TSCEN=1 +0,428% (v05:
  +0,426%), szcenárió-sáv +0,275%…+0,581%. Az átalakítás tehát **nem
  mozdította el az aggregált eredményt** — csak a szegmens-szintű
  állítások alapját tette legitimmé.

### BK-tanulság — a v04-es lecke pontosítása
A v04 azt rögzítette, hogy „`rk_S`/`rk_L` + CPI-szétválasztás megbontotta a
BK-t". A v06 megmutatja: **nem a szegmens-specifikus tőkehozam volt a
hibás, hanem a KOMBINÁCIÓ.** `rk_S`/`rk_L` önmagában, változatlan CPI-blokk
mellett **18 kombinációban (3 SCENARIO × 3 TSCEN × 2 NOVERT) mind
konvergál, BK sehol nem sérül** (`stress_v06.m`). A jövőbeli bővítéseknél a
tiltás tehát **nem** a szektor-specifikus tőkére áll, hanem az egyszerre
végzett árszint-szétválasztásra.

### Következtetés
Ez a verzió **nem új eredményt hozott, hanem a meglévők érvényességét**.
Amíg a szegmentálás pusztán pénzügyi volt, a szegmens-szintű állítások
műtermékek voltak; most van mögöttük termelési szerkezet. **De ez még nem
„kész":** nincs teljes euró-szcenárió tábla v06-ra, nincs dedikált
füstteszt, és a `psi_i_S=8 < psi_i_L=13` dokumentálatlan, empirikusan
visszafelé lévő kalibráció most **sürgetőbb**, mert már valódi termelési
hatása van, nem csak pénzügyi maradéka.

---

## Össz-összefoglaló: mit tudtunk meg a JV-vonalon

1. **Az aggregált eredmény robusztus, a szegmens-szintű nem volt.** A
   tartós GDP-hatás **+0,27%…+0,58%** (szcenárió-sáv) átment minden
   ellenőrzésen: a `t`-súlyok megválasztására, a vertikális link ki-be
   kapcsolására, a `y_d` javításra és a v06-os termelési átépítésre is.
   Ez a vonal közölhető magja.
2. **A „KKV többet nyer" állítás a kalibrációnkon állt, nem a
   szerkezeten.** A `t_S > t_L` súlyokat mi tettük be, az adat nem
   azonosítja őket (0,26–2,75 sáv), és a `chi_S > chi_L` a hosszú távon
   éppen fordítva hat. A v06 után a szegmens-állításoknak **van** végre
   szerkezeti alapja — de a `t`-súlyok kérdése ettől nem oldódott meg.
3. **A duális gazdaság a legerősebb saját eredményünk.** Az autóipar
   hazai köztes-input aránya 6,0%, az elektronikáé 4,2%. Ez adatolt,
   önálló, publikálható — és megmagyarázza, miért vékony a beszállítói
   csatorna a modellben (4,4%).
4. **Módszertani tanulság, amit érdemes vinni:** a **linearitás-ellenőrzés
   mint hibadetektor.** Mivel a modell exaktul lineáris a `t`-ben, minden
   kimenetnek teljesítenie kell az átlagolási tulajdonságot — a
   felár-oszlopok ezt megsértették, és így derült ki egy kódhiba, mielőtt
   bárki a számokat kifogásolta volna.
5. **És a legdrágább tanulság:** egy új dimenzió bevezetésénél nem elég,
   hogy a modell konzisztens és lefut — meg kell nézni, hogy **melyik
   blokkok tudnak róla.** A v02-ben szándékosan érintetlenül hagyott
   termelési szerkezet négy verzión át tette műtermékké a szegmens-szintű
   eredményeket.

## Hogyan tovább — aktuális teendők (2026-08-02)

1. **v06 körbejárása:** teljes euró-szcenárió tábla (t21-ekvivalens),
   dedikált füstteszt, és a `psi_i_S`/`psi_i_L` kalibráció újragondolása.
2. **Állomány-súlyozott támogatott arány** az Opten-panelből — a jelenlegi
   `t12`/`t14` cég-év arány, a mikrocégek hiányoznak. Fél nap, és minden
   további irányt szolgál.
3. **A 08-as transzmisszió-script javítása:** szint-regressziók kivétele,
   `"F"` fixálási sorozat, együttes regresszió, HAC, ECM.
4. **Csapatdöntés a fő szálról:** DSGE-központú (támogatás-kivezetés,
   küszöbformában) vagy extenzív-margó-központú történet.
5. **MNB méret szerinti új-szerződéses kamatstatisztika** bekérése — ez
   dönti el, van-e egyáltalán szegmens-különbség a transzmisszióban.
6. **Notion döntésnapló pótlása** (lásd a szakasz elején).
7. **Örökölt nyitott tételek:** EAGLE-kód bekérése (Kaszab Lóránt),
   AVG-besorolás tisztázása a szállítóval.
