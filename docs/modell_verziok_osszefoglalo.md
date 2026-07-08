# Modellverziók összefoglalója — v0.1 → v0.3

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

## Össz-összefoglaló: mit tudtunk meg

1. **A fő üzenet gépezete működik.** A méretfüggő akcelerátor minden
   verzióban, minden szcenárióban endogén KKV-többletet ad, ami tartós.
   Ez a tanulmány 1. számú állításának strukturális alapja.
2. **A hitelcsatorna önmagában ~0,3–0,7% tartós GDP.** Nem 1,5–2% — és ez
   így van jól: a különbség a másik két réteg (leképezés, extenzív margó)
   és a modellen kívüli csatornák (kereskedelem, tranzakciós költség)
   terepe. A tanulmány védhetőségének kulcsa, hogy ezt nyíltan így
   kommunikáljuk.
3. **Az időprofil legalább olyan fontos, mint a szint.** A hatás lassan
   épül fel (tőkefelhalmozás), és a belépés előtt átmeneti
   reálfelértékelődési visszaesés van. Szakpolitikai olvasat: az ERM-II
   szakasz kommunikációja és a fiskális hitelesség nem díszlet, hanem a
   pálya alakját meghatározó tényező — pont ahogy a vázlat pesszimista
   forgatókönyve sejtette.
4. **Az adat és a modell összeér.** A pénzügyi blokk kalibrációja
   (tőkeáttételek, EFP-szintek) a saját Opten-panelünkből jön; a makro-mag
   a magyar EAGLE-ből. A két forrás szerepe tisztán szétválasztott.

## Hogyan tovább — javasolt sorrend

1. **v0.4: kamatunió-rezsimváltás.** Belépés után Taylor-szabály → közös
   euró-kamat, rögzített árfolyam. Ez az euró-belépés tényleges monetáris
   tartalma, és várhatóan érdemben módosítja a rövid távú dinamikát.
   Megfontolandó ugyanitt: nem-Ricardiánus háztartások (EAGLE: 75% HU).
2. **2. réteg megírása:** script, ami a modell kamatpálya-kimenetét az
   Opten implicit ráta-eloszlására vetíti → szegmensenkénti (A–B/B–C/C–D)
   bp-értékek és reálhatások, „kalibrált leképezés" jelöléssel.
3. **3. blokk:** extenzív margó panel-ökonometria a 150 982 cég-évből
   (van_hitel valószínűségi modell) — a fő üzenet második, független lába.
4. **Érzékenységi futások:** zsov, χ_S, transzmissziós súlyok; a
   szektorális momentumok egyeztetése az Opten-eloszlásokkal.
5. **Párhuzamosan:** EAGLE-kód bekérése az MNB-től (Kaszab Lóránt) —
   validációként, nem függőségként; és az AVG-besorolás tisztázása a
   szállítóval (a 2. réteg szegmenshatárait érinti).
