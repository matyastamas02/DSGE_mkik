# 3. Miért a Jakab–Világi kell nekünk — érvek és tények

*Döntési háttéranyag. A csapat 2026-07-13-i döntése szerint a
projekt DSGE-magja a Jakab–Világi (MNB WP 2008/9), nem az EAGLE-HU
(Békési–Kaszab–Szentmihályi 2017). Ez a dokumentum összeszedi, miért —
tényekkel, és őszintén a kompromisszumokkal együtt.*

---

## A döntés egy mondatban

A hitelkörnyezeti euró-elemzéshez egy **magyar adaton becsült, karcsú,
rezsimváltásra és ragadós bérre eleve képes** mag a jobb alap — és ez a
Jakab–Világi. Az EAGLE gazdag, de kalibrált, nehezebb, és a fő
mechanizmusunkat (hitel) egyik sem tartalmazza natívan.

---

## 1. A tények — a két modell egymás mellett

| Szempont | EAGLE-HU (2017) | Jakab–Világi (2008) |
|---|---|---|
| Paraméterek | **kalibrált** (kézzel, EAGLE-táblákból) | **magyar adaton becsült** (Bayes) |
| Eredet | többországos ECB-modell HU-redukciója | eleve egyblokkos, magyar |
| Bér | rugalmas (Calvo külön építendő) | **ragadós, becsült** (natív) |
| Export-kereslet | (colleague-változatban) exogén, rugalmatlan | **becsült árrugalmassággal** |
| Rezsimváltás | külön hozzáépítendő (dummy) | **natívan kezeli** (peg → IT) |
| Kézről-szájra arány | 75% (feltevés) | 25% (becsült/felmérés) |
| Pénzügyi szektor (BGG) | nincs (ráépítendő) | nincs (ráépítendő) |
| Fiskális blokk | **gazdag** (6 adónem) | egyszerűbb |
| Méret | 91 egyenlet, nemlineáris | ~40 log-lineáris egyenlet |
| Determináltság | több paramétert el kellett hangolni | becsléskor stabil volt |

---

## 2. Az érvek — miért a JV

### (1) Adatfegyelem — a projekt egész ethosza ez
A tanulmány alaptézise: "az adat fegyelmezze a modellt" (ezért is a
hitelcsatorna, nem az árfolyam-fókusz). Egy **becsült** mag ehhez
konzisztens: a paraméterek nem feltevések, hanem magyar idősorok
poszterior-értékei. Kalibrált modellnél egy MNB/PM-bíráló joggal kérdezi,
honnan jön minden szám — a JV-nél a válasz: "a magyar adatból, Bayes-i
becsléssel".

### (2) A rezsimváltás natív — pont a mi kulcsmechanizmusunk
Az euró-bevezetés **monetáris rezsimváltás** (önálló jegybanktól a közös
kamatig, árfolyam nélkül). A JV modellje eleve tud rezsimet váltani
(csúszó-peg → inflációs célkövetés, strukturális töréssel). Az EAGLE-nél
ezt mi ragasztottuk rá egy dummyval (v0.4) — a JV-nél ez a képesség
beépített és becsült. Fejlődési előny ott, ahol a legfontosabb.

### (3) Ragadós bér natívan — az OCA-kérdéshez elengedhetetlen
Valutaunióban az árfolyam mint alkalmazkodási eszköz megszűnik; egy
aszimmetrikus sokkot a béreknek kell elnyelniük. A bérrugalmasság tehát
**az euró-elemzés magja**, nem lábjegyzet. A JV becsült ragadós bért
(Calvo ≈ 0,70, indexálás) tartalmaz — az EAGLE-vonalban ezt külön kellett
felépíteni (v0.5), és ott a magyar mikro-evidenciából (Kézdi–Kónya) kellett
kalibrálni, amit a JV már becsléssel megtett.

### (4) Karcsúbb → könnyebb ráépíteni, kevesebb támadási felület
A JV ~40 log-lineáris egyenlet, egyblokkos. A pénzügyi blokk (BGG),
amit a projekt megkövetel, tisztábban ráültethető, és kevesebb
"fegyelmezetlen" paramétert hoz be az 5 éves Opten-panelre. Ugyanaz az
érv, amivel a pitch az EAGLE-FLI teljes bankblokkját elvetette —
csak most a karcsú alap MELLETT szól.

### (5) Valódi export-árrugalmasság
Az euró-átmenetben a reálárfolyam-pálya központi (a belépés előtti
konvergenciás felértékelődés fékezi az exportot). A JV becsült
export-keresleti egyenlete ezt megjeleníti; a colleague EAGLE-változatban
az export-kereslet rugalmatlan volt, tehát ez a csatorna hiányzott.

### (6) Az eredmény is jobb — közelebb a vázlat sávjához
A JV-alapon (jv_dsge_v03) a tartós GDP-hatás **+0,78 / +1,09 / +1,41%**
(pessz/alap/opt) — közel a modell-vázlat 1,5–2%-os sávjához. Az
EAGLE-vonal ugyanezt +0,32…+0,73%-nak adta. A különbséget a becsült
magyar paraméterek (lapos ár-görbe, becsült UIP-dinamika, import-intenzív
export) viszik — vagyis nem "csaltunk nagyobbra", hanem a magyar adatra
illesztett modell strukturálisan élesebb dinamikát ad.

---

## 3. Az őszinte kompromisszumok — amit a JV NEM old meg

Fontos, hogy ezeket is kimondjuk, különben a döntés féloldalas:

- **A hitel-oldalon döntetlen.** Sem az EAGLE-nek, sem a JV-nek nincs
  natív pénzügyi akcelerátora / bankblokkja. A BGG-t, a prémium-
  csatornákat mindkét alapra mi építjük rá — ez a valódi modellezési
  munka, és **base-független**. A JV tehát nem azért jobb, mert "van benne
  hitel" (nincs), hanem a fenti hat okból.
- **Egyszerűbb fiskális blokk.** Az EAGLE hat adóneme (SZOCHO-,
  ÁFA-szcenáriókhoz) gazdagabb. Megoldás: ha a tanulmányhoz kell, ezt a
  blokkot az EAGLE-modellből **átemeljük** a JV-vonalba — a kettő nem
  kizárja, hanem kiegészíti egymást.
- **Néhány SS-arány pótlandó.** A JV cikkből nem minden steady-state-arány
  olvasható ki egyértelműen; a v01-ben ezek "KOZELITES" jelölést kaptak,
  és a szerzői kóddal / adattal ellenőrizendők (Jakab Zoltán, Világi Balázs
  elérhető az MNB-nél).

---

## 4. Mi lesz az EAGLE-munkával — nem vész kárba

- A colleague EAGLE-modellje és a mi kkv_dsge_v0x sorunk **robusztussági
  referenciaként** marad: két, eltérő alapon kapott hasonló üzenet
  erősebb, mint egy.
- Az EAGLE **gazdag fiskális blokkja** blokk-donor a JV-vonalhoz.
- Az EAGLE-vonalon kifejlesztett **moduláris rétegek** (BGG-logika,
  prémium-dekompozíció, rezsim-gépezet, szcenárió-időzítés) közvetlenül
  átemelhetők — a jv_dsge_v02/v03 már ezt teszi.

---

## 5. Összegzés — a döntés indoklása egy bekezdésben

A projekt egy **becsült, magyar, hitel- és euró-fókuszú** DSGE-t igényel.
A Jakab–Világi hat konkrét ponton illeszkedik jobban (becslés, natív
rezsimváltás, natív ragadós bér, karcsúság, export-rugalmasság, és a
vázlathoz közelebbi eredmény), miközben a hitel-dimenzión (ahol a valódi
munka van) egyik alap sem ad natív megoldást — azt mi építjük, base-
függetlenül. Az EAGLE gazdagsága nem vész el: referenciaként és
blokk-donorként szolgál. **Ezért a JV a fő vonal, az EAGLE a kontroll.**
