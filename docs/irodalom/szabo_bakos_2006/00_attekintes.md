# Szabó Bakos Eszter (2006) — áttekintés és kivonat

> **Speciális állami támogatások vizsgálata DSGE modell keretei között**
> PhD-értekezés · Budapesti Corvinus Egyetem, Közgazdaságtudományi Doktori
> Iskola · témavezető: Pete Péter · 160 oldal
>
> ⚠ **Oldalszám-eltolás:** a doksi saját oldalszámai **+5**-tel tolódnak a
> PDF-oldalakhoz (a „89. oldal" a PDF 94-e). A jegyzetekben a doksi
> oldalszáma szerepel, zárójelben a PDF-é.

---

## 1. réteg — besorolás

| Mező | Érték |
|---|---|
| **Cím** | Speciális állami támogatások vizsgálata DSGE modell keretei között |
| **Szerző** | Szabó Bakos Eszter |
| **Év** | 2006 |
| **Forrás** | PhD-értekezés, Budapesti Corvinus Egyetem |
| **Irodalmi áramlat** | háttér/módszertani · részben magyar DSGE (magyar szerző, de **nem** magyar adatra kalibrált) |
| **Modell-csatorna/réteg** | DSGE-keret/architektúra · **fiskális/támogatási beavatkozás jóléti értékelése** (nálunk eddig nem volt ilyen réteg) |

**Relevancia-tézis:** Ez az egyetlen magyar nyelvű DSGE-munka a kezünkben,
amely **egy támogatási beavatkozás jóléti értékelését küszöbformában** adja
meg — pontosan abban a formában, amiben mi az `ACCSCALE`-t és az
`eps_ces`-t kénytelenek vagyunk közölni. A módszertani precedens az értéke,
nem a paraméterei.

---

## 2. réteg — a konkrét haszon

### a) Konkrét paraméter / kalibrációs érték

Teljes kalibráció a 115–116. oldalon (PDF 120–121):

| Paraméter | Érték | Forrás a doksiban | Nálunk |
|---|---|---|---|
| β (időpreferencia) | **0,99** | ≈1% negyedéves hosszú távú kamat | azonos (`beta = 0.99`) |
| amortizáció | **10%/év → 2,5%/negyedév** | konvenció | **egyezik az `A09`-cel** (`delta` 0,0242–0,025) |
| relatív kockázatelutasítás | **1** (log-hasznosság) | — | JV becsült `sigma` = 1,814 — **eltér** |
| ψ | **2** | Erceg–Guerrieri–Gust (2005) | `fii` = 2,0 — azonos |
| **haszonkulcs** | **20% → θ = 6** | **Laxton–Pesenti (2003)** | `eps_ces` = 6,0 — **azonos, de lásd lentebb** |
| bér-helyettesítési rugalmasság (a′) | **10** (≈11% bér-markup) | — | `theta_w` = 3,0 — **eltér** |
| árragadósság ω | **0,5** | a szerző jelzi: *alacsonyabb a szokásosnál* | JV becsült `xi_p` = 0,921 — **jelentősen eltér** |
| bérragadósság ω_W | **0,75** | Laxton–Pesenti (2003) | JV becsült `xi_w` = 0,657 |
| G/Y | 20% | — | `sg` |
| C/Y | 60,36% | — | `sc` |
| I/Y | 19,64% | — | `si` |
| γ | 0,33 | — | tőkehányad |
| fogyasztói szokás b | **0,4** (alacsony) | — | JV becsült `habit` = 0,646 |
| tőke-alkalmazkodási költség φ | **15** (nagyon magas) | — | `psi_j` = 8–13 (más normalizálás) |

### b) Módszertani építőkocka

**A jóléti küszöb-számítás.** A szerző kiszámolja a beavatkozás jóléti
költségét, majd megkeresi azt a **tartós haszonkulcs-emelkedést**, amely
ugyanakkora jóléti veszteséget okozna — és a kettő összevetéséből ad
döntési szabályt. Ez formálisan **azonos** a mi `ACCSCALE`-küszöbünkkel
(„a KKV akkor nyer, ha a hozzáférési reakció eléri X-et").

### c) Melyik csatornánkhoz kötődik

**Egyikhez sem közvetlenül** (nincs benne pénzügyi akcelerátor, hitelfelár
vagy hozzáférési margó). A kötődés **módszertani**: a jóléti értékelés és a
küszöbforma.

### d) Felhasználás státusza

**Hivatkozzuk** — a küszöbforma módszertani precedenseként, és az `A20`
nagyságrendi viszonyításához. **Nem vesszük át** egyetlen paraméterét sem
(lásd f).

### e) Idézhető megállapítás

> A szerző kimondja, hogy a cél nem konkrét küszöbértékek meghatározása
> volt, hanem egy elemzési technika hasznának bemutatása (135. o. / PDF 140).

Ez pontosan a mi álláspontunk az `ACCSCALE`-lel — és jó, hogy van rá magyar
precedens.

### f) Hiányosság / korlát

1. **2006-os, pénzügyi akcelerátor nélkül.** Nincs BGG, nincs hitelfelár,
   nincs hozzáférési margó — a mi teljes 2. rétegünk hiányzik belőle.
2. **Nem magyar adatra kalibrált.** A paraméterek irodalmi konvenciók
   (Laxton–Pesenti, Erceg et al.), nem magyar becslések. A JV-vonalunk
   ebben **erősebb**.
3. **Más a támogatási eszköz:** EU-s mentési és szerkezetátalakítási
   támogatás, nem támogatott hitelprogram (NHP/Széchenyi).
4. Az árragadósság (0,5) messze van a magyar becsült értéktől (0,921).

### g) Prioritás

**Másodlagos.** Nem alap-tétel: nem ad paramétert és nem ad csatornát. De a
4. fejezet módszertani mintája miatt érdemes hivatkozni.

---

## ⭐ Az `eps_ces`-verdikt

**A kérdés az volt: ad-e ez a doksi független horgonyt az `eps_ces`-re?**

**Nem ad.** A 20%-os haszonkulcs (θ = 6) forrása **Laxton–Pesenti (2003)**,
azaz a GEM — ugyanaz az irodalmi vonal, ahonnan a mi `eps_ces` = 6,0-unk is
származik az EAGLE-on keresztül. **Ugyanaz a konvenció, nem független
megerősítés.**

Két további ok, amiért nem használható horgonyként:

- **Más az objektum.** Nála θ a szokásos **termékváltozat**-helyettesítési
  rugalmasság. Nálunk az `eps_ces` a **vállalattípusok** (E/D/L) közti
  helyettesítés — a JV-ben ilyen paraméter nincs is, mi vezettük be a
  v08-ban. A két szám azonos jelölést és értéket kapott, de nem ugyanazt
  méri.
- **Nem magyar adat.** Nem markup-becslés, hanem átvett konvenció.

**Amit viszont ad, és ez több a semminél:** a 4.6–4.7 megmutatja, hogy a
haszonkulcs-változást **sokként** lehet kezelni és **jóléti egységre**
átváltani. Ha az `eps_ces` nálunk nem horgonyozható (és nem az), ez a
technika azt kínálja, hogy ne a paramétert próbáljuk megmondani, hanem azt,
**mekkora markup-változás ér fel** a vizsgált hatással.

**Következmény a teendőlistára:** az `eps_ces` magyar horgonya (a
`kalibracio_teendok_csapatnak.md` 3.1 pontja) **továbbra is nyitott** — ez
a doksi nem zárja le. Magyar markup- vagy helyettesítésirugalmasság-becslés
kell, vállalati panelből.

---

## A fejezetenkénti jegyzetek

| Fájl | Fejezet | Doksi (PDF) | Relevancia |
|---|---|---|---|
| [`01_bevezetes.md`](01_bevezetes.md) | 1. Bevezetés | 1–5 (6–10) | ⚪ háttér |
| [`02_irodalmi_attekintes.md`](02_irodalmi_attekintes.md) | 2. Irodalmi áttekintés | 6–69 (11–74) | 🟡 (2.4 🟢) |
| [`03_dsge_alkalmazasok.md`](03_dsge_alkalmazasok.md) | 3. DSGE alkalmazások | 70–84 (75–89) | ⚪ háttér |
| [`04_allami_segitsegnyujtas.md`](04_allami_segitsegnyujtas.md) | 4. **A saját hozzájárulás** | 85–149 (90–154) | 🟢 **ez a lényeg** |
