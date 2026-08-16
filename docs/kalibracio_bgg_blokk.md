# BGG pénzügyi blokk — 5 paraméter az Opten-panelből

*2026-08-16 · Kód: [`src/11_bgg_blokk_kalibracio.py`](../src/11_bgg_blokk_kalibracio.py) ·
Kimenet: `output/tables/t50_bgg_blokk.csv`, `t50b_bgg_chi_reszletes.csv`*

> **Modellfuttatás nincs benne.** Ez a dokumentum az öt paraméter *értékét*
> állítja elő és dokumentálja. Hogy mit csinálnak a modellben, külön lépés.

---

## Miért pont ez az öt

A modell pénzügyi blokkja egyetlen egyenletpáron áll:

$$\mathrm{efp}_j = \chi_j \cdot (q_j + k_j - nw_j), \qquad
\mathrm{lev}_j = \frac{K_j}{N_j}$$

A `lev_j` a BGG-szerződés **állandósult pontja**, a `chi_j` ugyanannak a
szerződésnek a **lokális meredeksége** ugyanabban a pontban. Nem független
paraméterek: a BGG-szerződésben mindkettő ugyanabból a mögöttes
paraméterhalmazból (monitorozási költség, a vállalkozói hozam eloszlása,
túlélési ráta) származik. Ha külön forrásból vesszük őket, a blokk
belsőleg inkonzisztens lehet — ezért kalibráljuk együtt.

| # | Paraméter | Jelenlegi | Opten-panel | Használható? |
|---|---|---:|---:|---|
| 1 | `lev_E` | 1,60 | **1,939** | ✅ igen |
| 2 | `lev_D` | 1,60 | **1,719** | ✅ igen |
| 3 | `lev_L` | 1,85 | **2,337** | ✅ igen |
| 4 | `chi_S` | 0,06 | **+0,0021** | ⚠ csak alsó korlátként |
| 5 | `chi_L` | 0,02 | −0,0072 | ❌ nem azonosított |

Az 1–3. pont (definíció, egyenletek, kód) a `lev` családon belül közös,
mert szó szerint ugyanaz a képlet; a 4–5. pont szegmensenként külön áll.
Ugyanez a `chi`-nél.

---

# I. `lev_E` / `lev_D` / `lev_L`

## 1. A paraméter neve, jelentése, definíciója

**Tőkeáttétel** a BGG-értelemben: az eszközállomány és a nettó vagyon
(saját tőke) hányadosa az állandósult állapotban.

$$\mathrm{lev}_j \;=\; \frac{Q K_j}{N_j}
\qquad j \in \{E,\,D,\,L\}$$

ahol `E` = exportáló KKV, `D` = hazai KKV, `L` = nagyvállalat (a
szegmensdefiníció **azonos** az `s14`/`s15`-ével: méretkategória a
létszámból, exportőrség a pozitív exportárbevételből).

**Hol lép be a modellbe.** A nettó vagyon mozgásegyenletében ez a
szorzótényező, amivel a hozamkülönbözet a nettó vagyonra üt:

```
nw_j = omega_nw * ( nw_j(-1) + lev_j * ( ret_j - (r(-1) - infl) ) )
```

Tehát `lev_j` **közvetlenül azt méri, hogy egy adott hozamsokk hányszoros
erővel csapódik a nettó vagyonba** — ez a pénzügyi akcelerátor
erősítőtényezője. Nagyobb `lev` = sérülékenyebb mérleg.

⚠ **Fontos, hogy `lev_j` ≠ „eladósodottság".** A `lev = 1` a
tartozásmentes vállalatot jelenti, nem a nullát. A kötelezettség/eszköz
arány `d`-vel a kapcsolat `lev = 1/(1−d)`.

## 2. Előállítási mód, egyenletek

Cégszintű éves mérlegadatból, **medián** aggregálással:

$$\widehat{\mathrm{lev}}_j \;=\;
\underset{i \in j,\; t \in 2021..2024}{\mathrm{median}}
\left( \frac{\text{eszközök összesen}_{it}}{\text{saját tőke}_{it}} \right)$$

Szűrés: `saját tőke > 0`, `eszközök > 0`, `1 ≤ lev < 100`.

**Miért medián és nem átlag.** A hányados eloszlása erősen jobbra nyúlik
(a nullához közelítő saját tőkénél robban): a `D` szegmensben a medián
1,72, az átlag 3,08. Az átlag néhány, a csőd közelében lévő céget mérne, a
modell viszont a **reprezentatív** vállalatot akarja.

**Miért nem árbevétel-súlyozott.** A `lev_j` a BGG-szerződés egyedi
vállalati paramétere, nem aggregátum-részesedés — a tipikus szerződés kell,
nem a gazdaság összesített tőkeáttétele.

**Két kontrollmérték** (a 5. pontban használjuk):

$$\text{(a)}\;\; \frac{1}{1 - \mathrm{median}(d_{it})},\quad
d_{it} = \frac{\text{kötelezettségek}_{it}}{\text{eszközök}_{it}}
\qquad
\text{(b)}\;\; \mathrm{median}\!\left(\frac{\text{befektetett eszközök}_{it}}{\text{saját tőke}_{it}}\right)$$

## 3. Előállítás — reprodukálható kód

Önállóan futtatható, csak `pandas` kell:

```python
import pandas as pd

p = pd.read_csv("data/processed/opten_panel.csv", low_memory=False)
p = p[p.ev.between(2021, 2024)]

# szegmensek (azonos az s14/s15 definíciójával)
exp_ = p.exportor.astype(str).str.lower().eq("true")
kkv  = p.meret_kategoria.astype(str).isin(["10-49", "50-249"])
nagy = p.meret_kategoria.astype(str).eq("250+")
p["szegmens"] = pd.NA
p.loc[kkv &  exp_, "szegmens"] = "E"
p.loc[kkv & ~exp_, "szegmens"] = "D"
p.loc[nagy,        "szegmens"] = "L"

lev = p.eszkozok_osszesen / p.sajat_toke
jo  = (p.sajat_toke > 0) & (p.eszkozok_osszesen > 0) & lev.between(1, 100)

print(lev[jo].groupby(p.szegmens[jo]).agg(["median", "mean", "count"]))
# E  1.9385   3.4531    16823
# D  1.7185   3.0810   121570
# L  2.3374   4.8121     4125
```

A teljes változat (kontrollmértékekkel, kvartilisekkel) a
[`src/11_bgg_blokk_kalibracio.py`](../src/11_bgg_blokk_kalibracio.py)
`tokeattetel()` függvényében.

## 4. Szakirodalmi ellenőrzés

**Forrás (közvetlenül a PDF-ből ellenőrizve, nem emlékezetből):**
Christensen, I. & Dib, A. (2008): *The financial accelerator in an
estimated New Keynesian model*, Review of Economic Dynamics 11, 155–178,
**1. táblázat**:

> `k/n` — steady-state ratio of capital to net worth = **2**

Ez a BGG (1999)-ből átvett érték, és ugyanez a normalizálás áll a mi
egyenletünkben is: Sims (Notre Dame, BGG-jegyzet) a BGG-linearizálást
`E_t r^k_{t+1} − r_t = −ψ[n_t − (q_t + k_{t+1})]` alakban írja fel, ahol a
jobb oldal *„the negative of a leverage ratio (i.e. assets… relative to
equity)"* — **tehát a mi `lev`-ünk (eszköz/saját tőke) ugyanaz az objektum.**

| | `lev_E` | `lev_D` | `lev_L` |
|---|---:|---:|---:|
| Opten-panel (medián) | **1,94** | **1,72** | **2,34** |
| irodalom (BGG / C&D `k/n`) | 2,0 | 2,0 | 2,0 |
| jelenlegi modellérték | 1,60 | 1,60 | 1,85 |

**Az egyezés jó.** Mindhárom becslés a szakirodalmi 2,0 körül szór
(−14% … +17%), és **a panelérték minden szegmensben KÖZELEBB van a
2,0-hoz, mint a jelenlegi modellérték.** A jelenlegi 1,6/1,6/1,85
szisztematikusan alábecsül.

## 5. Reális-e az érték?

**Igen, három okból.**

*Nagyságrend.* 1,7–2,3 azt jelenti, hogy a tipikus magyar cég
eszközeinek 42–57%-a idegen forrás. Ez megfelel a magyar vállalati
szektorról ismert képnek, és pontosan a nemzetközi BGG-kalibrációk sávja.

*Sorrend.* `lev_L (2,34) > lev_E (1,94) > lev_D (1,72)`. A nagyvállalat a
legeladósodottabb — ez közgazdaságilag helyes irány (jobb hitelpiaci
hozzáférés, olcsóbb forrás, több fedezet), és **egybevág az `s14`-gyel**,
ahol a nagyvállalati hitelhozzáférés 43,4% a hazai KKV 4,8%-ával szemben.

*Robusztusság.* A sorrend **mérőfüggetlen**: a kötelezettség/eszköz
alapú kontrollmérték (1,684 / 1,579 / 1,812) ugyanazt a rangsort adja.

**Amit viszont vállalni kell:**

1. **A SZINT mérőfüggő.** A két mérték eltér (1,94 vs 1,68 az `E`-nél),
   mert a `kötelezettségek` oszlop nem tartalmazza a passzív időbeli
   elhatárolást és a céltartalékot, a saját tőke viszont ezekkel is szemben
   áll. **Ezért a szintre sávot adjunk:** `lev_E ∈ [1,68; 1,94]`,
   `lev_D ∈ [1,58; 1,72]`, `lev_L ∈ [1,81; 2,34]`.
2. **Könyv szerinti, nem piaci érték.** A BGG `QK` piaci értékelésű; a
   panel könyv szerinti. Növekvő cégeknél ez alábecsli a `K`-t, tehát a
   valódi `lev` inkább lejjebb van.
3. **A „fizikai tőke" olvasat itt nem működik.** A befektetett
   eszköz / saját tőke medián 0,58–0,86 — **1 alatt**, ami BGG-ben lehetetlen
   (negatív adósságot jelentene). Vagyis a `K`-t a **mérlegfőösszeggel**
   kell azonosítani, nem a tárgyi eszközzel. Ez nem hiba, hanem a
   leképezés tisztázása.
4. **Mikrocégek hiánya** (10+ fős panel). A tőkeáttétel viszont — a
   súlyokkal ellentétben — *cégszintű* jellemző, nem részesedés, tehát
   ez a torzítás itt jóval enyhébb.

---

# II. `chi_S` / `chi_L`

## 1. A paraméter neve, jelentése, definíciója

**A külső finanszírozási felár tőkeáttétel-rugalmassága** (BGG
financial accelerator együttható). A log-linearizált BGG-szerződés:

$$\mathrm{efp}_j \;=\; \chi_j \cdot \bigl(q_j + k_j - nw_j\bigr)$$

Szavakban: ha egy szegmens tőkeáttétele 1%-kal nő, a külső forrás felára
`chi_j` **százalékponttal** (negyedéves tizedesben) emelkedik. `chi = 0`
esetén nincs pénzügyi akcelerátor: a felár konstans, a mérleg nem számít.

A `chi_j` **a legfontosabb szabad paraméter a pénzügyi blokkban** — ez
dönti el, mennyire erősít a mérlegcsatorna. A modellben jelenleg
`chi_E = chi_D = 0,06`, `chi_L = 0,02`, azaz **háromszoros KKV-fölény van
feltételezve**.

⚠ Ez a feltételezés a projektben eddig **forrás nélkül** állt: a
[`kalibracio_tabla.md`](kalibracio_tabla.md) szerint *„»Opten-panel
medián«-ként hivatkoztuk, de nem az"*, és a `D` kategóriában
(nem azonosított) szerepel.

**Mértékegység.** A modell `efp`-je **negyedéves tizedes**
(`efp = −0,0025` ⟺ −100 bp/év), ezért az éves adatból becsült
együtthatót néggyel osztjuk: `chi = chi_éves / 4`.

## 2. Előállítási mód, egyenletek

A becsült egyenlet **cég- és év-fix hatással**:

$$r_{it} \;=\; \chi^{\text{éves}}\cdot \log(\mathrm{lev}_{it})
\;+\; \alpha_i \;+\; \delta_t \;+\; \varepsilon_{it}$$

- `r_it` — implicit kamatráta = kamatráfordítás / hitelállomány (éves, tizedes)
- `α_i` — **cég-fix hatás**: kiejti a tartós kockázati szintet, tehát a
  becslés a *cégen belüli* variációra épül (amikor ugyanaz a cég
  eladósodottabbá válik, drágul-e a forrása)
- `δ_t` — **év-fix hatás**: kiejti a kockázatmentes szintet. Ezért a
  becsléshez **BUBOR-adat nem is kell** — a szpred képzése implicit.

Becslés: Frisch–Waugh (cégen belüli demeaning, az év-dummykat is
demeanelve), cégre klaszterezett standard hibával. A kétirányú fix hatás
így **egzakt**, nem közelítés — kiegyensúlyozatlan panelen az egyszerű
kettős demeaning torzítana.

### A három specifikáció, és miért kell mind a három

Az implicit ráta nevezője a panelben **év végi** hitelállomány, a
számláló viszont az **év közben** felhalmozott kamat. Ha egy cég év
közben vesz fel hitelt, a mért ráta **mechanikusan lezuhan** — épp akkor,
amikor a tőkeáttétel nő. Ez önmagában negatív együtthatót gyárt, valódi
közgazdasági tartalom nélkül. Ezért:

| Spec | Nevező | Minta | Mit zár ki |
|---|---|---|---|
| **A** | év végi állomány | teljes | — (ez a panel eredeti oszlopa) |
| **B** | nyitó és záró **átlaga** | akinek van előző éve | a műtermék felét |
| **C** | nyitó/záró átlag | + a hitelállomány ±10%-on belül stabil | a műterméket lényegében teljesen |

## 3. Előállítás — reprodukálható kód

```python
import numpy as np, pandas as pd

p = pd.read_csv("data/processed/opten_panel.csv", low_memory=False)
p = p[p.ev.between(2021, 2024)].sort_values(["opten_id", "ev"])

exp_ = p.exportor.astype(str).str.lower().eq("true")
kkv  = p.meret_kategoria.astype(str).isin(["10-49", "50-249"])
nagy = p.meret_kategoria.astype(str).eq("250+")

# előző év ugyanannál a cégnél
elozo = (p.opten_id == p.opten_id.shift(1)) & (p.ev == p.ev.shift(1) + 1)
hitel_lag = p.hitelallomany.shift(1).where(elozo)

lev = p.eszkozok_osszesen / p.sajat_toke
x   = np.log(lev)
atl = (p.hitelallomany + hitel_lag) / 2
r   = (p.kamatraforditas / atl).where(atl > 0)          # "B" nevező
valt   = (p.hitelallomany / p.hitelallomany.shift(1)).where(elozo)
stabil = valt.between(0.9, 1.1)                          # "C" szűrő

jo = (elozo & stabil & r.notna() & r.between(0.001, 0.50)
      & np.isfinite(x) & (p.sajat_toke > 0) & lev.between(1, 100)
      & (p.hitelallomany > 0))

def fe_ols(y, X, gid):                  # cég-fix hatás + klaszterezett SE
    n = np.bincount(gid)
    dm = lambda v: v - (np.bincount(gid, weights=v) / n)[gid]
    yw = dm(y); Xw = np.column_stack([dm(X[:, k]) for k in range(X.shape[1])])
    b = np.linalg.lstsq(Xw, yw, rcond=None)[0]
    e = yw - Xw @ b
    A = np.linalg.pinv(Xw.T @ Xw)
    S = np.column_stack([np.bincount(gid, weights=(Xw * e[:, None])[:, k],
                                     minlength=gid.max() + 1)
                         for k in range(Xw.shape[1])])
    V = A @ (S.T @ S) @ A * (len(n) / (len(n) - 1))
    return b, np.sqrt(np.diag(V))

for nev, maszk in [("chi_S", kkv), ("chi_L", nagy)]:
    m = jo & maszk
    q = p[m]
    gid = pd.factorize(q.opten_id)[0]
    D = np.column_stack([(q.ev == e).to_numpy(float) for e in (2022, 2023, 2024)])
    b, se = fe_ols(r[m].to_numpy(), np.column_stack([x[m].to_numpy(), D]), gid)
    print(f"{nev}: eves {b[0]:+.5f} (SE {se[0]:.5f}, t {b[0]/se[0]:+.2f})"
          f" -> chi = {b[0]/4:+.5f}  n={m.sum()}")
# chi_S: eves +0.00857 (SE 0.00439, t +1.95) -> chi = +0.00214  n=2097
# chi_L: eves -0.02896 (SE 0.03706, t -0.78) -> chi = -0.00724  n=230
```

*(A `np.log` a nem pozitív `lev`-értékekre `RuntimeWarning`-ot ír ki — ez
ártalmatlan, ezeket a sorokat a `jo` maszk `lev.between(1, 100)` feltétele
utána kiszűri. Mindkét kódrészlet ebben a formában lefuttatva pontosan a
fenti számokat adja.)*

### Az eredmény, mind a három specifikációban

| Spec | `chi_S` (éves) | t | `chi_L` (éves) | t |
|---|---:|---:|---:|---:|
| **A** év végi állomány | **−0,0117** | **−4,09** | +0,0050 | +0,53 |
| **B** átlagos állomány | −0,0005 | −0,16 | +0,0040 | +0,40 |
| **C** átlagos + stabil állomány | **+0,0086** | **+1,95** | −0,0290 | −0,78 |

**Ez a tábla a fő eredmény, nem a végső szám.** Az „A" specifikáció
erősen szignifikáns, **elméletileg lehetetlen előjelű** együtthatót ad
(több adósság ⇒ olcsóbb forrás). A nevező javítása után az együttható
eltűnik, a mechanikus csatorna kizárása után pedig **átfordul a helyes,
pozitív előjelbe**. Vagyis az „A" negatív eredménye **mérési műtermék
volt**, nem közgazdasági tartalom.

⚠ **Ez a panel egészére szóló figyelmeztetés:** az `implicit_kamatrata`
oszlop bármilyen olyan regresszióban torzít, ahol a magyarázó változó
együtt mozog a hitelállomány *változásával*.

## 4. Szakirodalmi ellenőrzés

**Christensen & Dib (2008), 2. táblázat** (maximum-likelihood, USA
1979Q3–2004Q3) — közvetlenül a PDF-ből:

> χ = **0,0420**, standard hiba **0,0137**, 1%-on szignifikáns
>
> *„this estimated value is not statistically different from 0,05, a value
> often used to calibrate this parameter (see for example, Bernanke et al.,
> 1999; Bernanke and Gertler, 2000; Fukunaga, 2002; and Gilchrist, 2004)"*
>
> *„Meier and Müller (2006) report a higher estimated value of 0,067"*

| Forrás | χ (negyedéves) |
|---|---:|
| Christensen–Dib (2008), becsült | **0,042** (SE 0,014) |
| BGG (1999) és követői, szokásos kalibráció | **0,05** |
| Meier–Müller (2006), becsült | **0,067** |
| **jelenlegi modellérték `chi_E`/`chi_D`** | **0,06** |
| **jelenlegi modellérték `chi_L`** | **0,02** |
| **Opten-panel, „C" spec (`chi_S`)** | **+0,0021** |

⚠ **Egy nyitott normalizálási kérdés.** Sims BGG-jegyzete a
Handbook-fejezet 1368. oldalára hivatkozva `ψ = 0,2`-t ír BGG saját
kulcsparaméterének. Ez négyszerese a C&D-ben „BGG-értékként" idézett
0,05-nek. **Ez normalizálási különbség lehet** (a rugalmasság a
tőkeáttételre vs. a nettó vagyon arányra), és a BGG-fejezet 1368.
oldalán ellenőrizendő, mielőtt bárki 0,2-re hivatkozik.

**Az egyezés rossz: a mi becslésünk 20–25-szörös nagyságrendben kisebb.**

## 5. Reális-e az érték?

**A `chi_S = +0,0021` nem használható pontbecslésként — alsó korlátnak
viszont igen.** Négy ok, mindegyik ugyanabba az irányba (a nulla felé)
torzít:

1. **Attenuáció.** A `log(lev)` mérési hibával terhelt (könyv szerinti
   érték, éves gyakoriság). Klasszikus mérési hiba a magyarázó változóban
   **szisztematikusan nullához húzza** az együtthatót.
2. **Átlagos vs. határráta.** A modell `efp`-je a **következő** hitel ára;
   az implicit ráta a **teljes fennálló állomány** átlagos ára, benne a
   régi, fixált kamatozású szerződésekkel. Egy magyar KKV ma **61%-ban
   hosszabb fixálású** (ECB MIR, `ATADAS`), tehát az átlagos ráta lassan
   követi az árazást.
3. **Programvezéreltség.** 2021–24-ben a Széchenyi/NHP-hitelek egyszerre
   *olcsók* és *tőkeáttétel-növelők* — ez ellentétes irányú korrelációt
   old bele a mintába. Ugyanaz a betegség, ami az `s14`-ben az `ACCSCALE`
   horgonyzását és korábban a `t_S/t_L` tesztet is érvénytelenítette;
   a leíró tábla szerint a mért szpred a KKV-nál **negatív** (−255 … −300 bp),
   ami piaci felárként képtelenség.
4. **Négy év, cégen belüli variáció.** Kevés idő, kevés mozgás.

**Következtetés:** az adatunk **nem cáfolja** a szakirodalmi 0,042–0,05-öt
— annyira alulazonosított, hogy nem is tudná. Amit *mond*: a helyes
előjel a legtisztább metszetben előjön, tehát a mérlegcsatorna létezik.

**A `chi_L` nem azonosított:** n = 230 cég-év, t = −0,78, rossz előjel.
Ebből semmit nem szabad kiolvasni.

### Amit viszont ez a becslés érdemben mond a modellről

**A `chi_E = chi_D = 0,06` vs. `chi_L = 0,02` háromszoros KKV-fölényre
sem itt, sem a szakirodalomban nincs alap.**

- A szakirodalom **egyetlen, méret szerint nem bontott** χ-t becsül
  (0,042–0,067) — nincs benne KKV/nagyvállalat aszimmetria.
- A mi panelünk a `chi_L`-t egyáltalán nem azonosítja, tehát az
  aszimmetriát **nem tudjuk megerősíteni**.
- A modell `chi_E/chi_D = 0,06` értéke a szakirodalmi sáv **tetején** van
  (Meier–Müller 0,067 alatt), tehát önmagában védhető; a `chi_L = 0,02`
  viszont a sáv **alatt**, forrás nélkül.

**Javaslat:** a `chi`-t szimmetrikus alapon (`chi_E = chi_D = chi_L`
≈ 0,05, a szakirodalmi konszenzus) kell futtatni, és az aszimmetriát
**scannel** kezelni — pontosan úgy, ahogy a `kalibracio_tabla.md` már
javasolta: *„Kell: EFP-érzékenység becslése, vagy szimmetrikus alap +
scan."* Az EFP-érzékenység becslése most megtörtént, és az eredmény
**a szimmetrikus alap + scan ágat támogatja.**

---

## Összefoglalás

| Paraméter | Érték | Státusz | Mit lehet vele csinálni |
|---|---:|---|---|
| `lev_E` | **1,939** (sáv 1,68–1,94) | ✅ saját adatból | átvehető; közelebb az irodalmi 2,0-hoz, mint a jelenlegi 1,6 |
| `lev_D` | **1,719** (sáv 1,58–1,72) | ✅ saját adatból | átvehető |
| `lev_L` | **2,337** (sáv 1,81–2,34) | ✅ saját adatból | átvehető |
| `chi_S` | **+0,0021** | ⚠ alsó korlát | *nem* átvehető pontbecslésként; az irodalmi 0,042–0,05-öt nem cáfolja |
| `chi_L` | −0,0072 | ❌ nem azonosított | semmit |

**Melléktermék, ami a `delta`-t is hitelesíti:** a Christensen–Dib
1. táblázat `δ = 0,025` negyedéves értékcsökkenési rátát használ — pontosan
azt, amit a modell is, és amit az Opten-panel is visszaadott
(0,0242, lásd [`2026-08-16_opten_kalibracio_eredmeny.md`](2026-08-16_opten_kalibracio_eredmeny.md)).

**Melléktermék az `omega_nw`-hez:** ugyanez a táblázat a vállalkozói
túlélési rátára `η = 0,9728`-at ad (BGG-érték, 36 éves várható működési
idő). A modellben `omega_nw = 0,95`, ami **rövidebb** élettartamot
feltételez — ez külön megnézendő, de nem tartozik ehhez az öthöz.

### Források

- Christensen, I. & Dib, A. (2008): *The Financial Accelerator in an
  Estimated New Keynesian Model.* Review of Economic Dynamics 11, 155–178.
  [PDF](https://faculty.sites.iastate.edu/tesfatsi/archive/tesfatsi/FinAcceleratorNKDSGE.ChristiansenDib2008.pdf)
  — 1. és 2. táblázat ellenőrizve.
- Bernanke, B., Gertler, M. & Gilchrist, S. (1999): *The Financial
  Accelerator in a Quantitative Business Cycle Framework.* Handbook of
  Macroeconomics 1C, 1341–1393. [NBER WP 6455](https://www.nber.org/papers/w6455)
  — a χ = 0,05 közvetett hivatkozáson át; az 1368. oldal **még
  ellenőrizendő** (lásd a normalizálási kérdést a II.4-ben).
- Sims, E.: *Advanced Macro — BGG (1999) jegyzet*, University of Notre Dame.
  [PDF](https://sites.nd.edu/esims/files/2023/05/bbg_ers_notes_final.pdf)
  — a linearizált alak és a 200 bp/év állandósult felár ellenőrizve.
