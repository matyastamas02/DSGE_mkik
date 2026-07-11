# DSGE-modell (Dynare)

## Állapot: v0.1 → v0.5 (Calvo-bérek)

## v0.5 — `kkv_dsge_v05.mod`: Calvo-bérek (EHL bér-Phillips-görbe)

A v0.4 + ragadós bérek: θw = 0.75 (EAGLE; Kézdi–Kónya WDN: a cégek
~évente igazítanak alapbért), CPI-indexálás 0.75, bér-markup elaszticitás
4.33. Érzékenység: `-DTHETAW=60|75|85`. Futtatás: `run_v05` →
`t18_v05_berragadossag.csv`, `f17`.

**Eredmény — robusztussági "null-eredmény", és ez jó hír:** az euró-
belépési pálya gyakorlatilag érzéketlen a bér-ragadósságra (hosszú táv
azonos +0,725%; dip −0,373…−0,383% vs. rugalmas −0,38%). Ok: a szcenárió
lassú, anticipált, fokozatos — a bér-NKPC-nek van ideje alkalmazkodni,
és az ár-ragadósság (Calvo 0,92) amúgy is dominálja a nominális
súrlódásokat. **A bérrugalmasság igazi tétje nem a belépési pálya, hanem
a belépés UTÁNI aszimmetrikus sokk-elnyelés** (önálló monetáris politika
nélkül a bér az alkalmazkodási eszköz — klasszikus OCA-kérdés): ennek
vizsgálata a v0.6 feladata (sztochasztikus szimuláció az unió-rezsimben,
θw-érzékenységgel). Mikro-evidencia a kalibrációhoz: Kézdi–Kónya (MNB OP
103), Kátay (MNB WP 2011/9), saját panel-lenyomat: t17.

## v0.4 — `kkv_dsge_v04.mod`: rezsimváltás + nem-Ricardiánus háztartások

## v0.4 — `kkv_dsge_v04.mod`: rezsimváltás + nem-Ricardiánus háztartások

Két bővítés a v0.3-hoz képest (futtatás: `run_v04`, kimenet:
`t16_v04_osszevetes.csv`, ábra: `f16`):

1. **Kamatunió-rezsimváltás a belépéskor (q13)**: az `uni` determinisztikus
   dummy kapcsolja a monetáris blokkot — előtte Taylor + UIP, utána
   r = euró-kamat (+ kis NFA-rugalmas felár) és dep = 0. A dummy-szorzatok
   miatt a modell formálisan nemlineáris; perfect foresight oldja meg.
2. **Nem-Ricardiánus háztartások** (om_nr = 0.75, az EAGLE HU-értéke;
   `-DOMNR=0|75` kapcsoló): c_N = w + nn, a Ricardiánus ág viszi az
   Euler-egyenletet — ez oldja a v0.3-ban dokumentált Euler-rögzítést.

**Eredmények (alappálya, hosszú távú GDP):** v0.3 +0,49% → csak unió
+0,54% → **unió + 75% NR: +0,73%**. A rezsimváltás önmagában keveset
változtat; a nem-Ricardiánus blokk viszont (a) másfélszeresére emeli a
tartós hatást (a hozamgörbe-csatorna végre aggregáltan is él), és (b)
**mélyíti a belépés előtti visszaesést** (−0,38%): a likviditáskorlátos
háztartások fogyasztása a folyó jövedelmet követi, az ERM-II szakasz
fájdalmasabb. Szakpolitikai olvasat: az átmenet kezelése (kommunikáció,
programok időzítése) a nem-Ricardiánus népességarány miatt még fontosabb.

Nyitott (v0.5): Calvo-bérek (a 75%-os NR-arány bér-ragadóssággal áll
igazán stabilan); a szcenárió-készlet (opt/pessz) átfuttatása v0.4-en.

## v0.1–v0.3 (korábbi verziók)

## v0.3 — `kkv_dsge_v03.mod`: WP 2017/7 kalibráció + UIP-országprémium

Két változás a v0.2-höz képest (futtatás: `run_v03`, kimenet:
`szcenario_v03.csv` + `szcenario_v03_hosszutav.csv`, ábra:
`src/05_szcenario_abrak_v03.py`):

1. **Kalibráció a WP 2017/7 appendix HU oszlopából**: β=0.99, σ=0.4,
   α=0.30, Calvo-ár 0.92 → κ≈0.01, beruh. kiig. 6.0, Taylor 0.87/1.70/0.10,
   C/Y 0.61, I/Y 0.19, G/Y 0.20, X/Y=M/Y 0.75. A pénzügyi blokk (chi, lev)
   továbbra is az Opten-panelből.
2. **UIP-országprémium csatorna**: a szuverén konvergencia zsov=0.5 súllyal
   az UIP-be is belép. Dekompozíció: UIP = kockázatmentes görbe / árfolyam-
   és NFA-dinamika; EFP = vállalati hitelfelár (tsov/tbank, változatlan).

**Fő eredmények (alappálya):** hosszú távú GDP-szint **+0,49%**
(optimista +0,67%, pesszimista +0,32%), KKV-kibocsátás +0,56% vs.
nagyvállalati +0,41% — a KKV-többlet tartós. A felépülés lassú (10 évnél
+0,11%, 30 évnél +0,25%): a szűk keresztmetszet a tőkefelhalmozás
sebessége (WP-beli beruházási kiigazítási költség 6.0).

**Az akcelerátor két arca (s10 ki/be teszt, f13):** a méretfüggő
akcelerátor a monetáris sokkot a nettóvagyon-csatornán ERŐSÍTI (a
KKV-beruházási válasz ~2,4-szeres a χ=0-hoz képest — klasszikus BGG),
az exogén prémium-sokkokat viszont részben TOMPÍTJA: a fellendülésben a
cégek eladósodnak (q+k gyorsabban nő, mint nw), és a prémium endogén
módon visszapattan. Ez magyarázza a szcenáriók mérsékelt hosszú távú
hatását is, és a tanulmányban mindkét irányt együtt kell kommunikálni.

**Két strukturális tanulság:**
- A reprezentatív háztartás Euler-egyenlete hosszú távon βhoz köti a
  belföldi reálkamatot, ezért az UIP-prémium csökkenése főleg az
  NFA/árfolyam-oldalt mozgatja — a tartós kibocsátási hatást az
  EFP-ék (tőkeköltség-csatorna) adja. A vázlatbeli 1,5–2% a kereskedelmi/
  tranzakciós csatornákat és az extenzív margót is tartalmazza, amelyek
  tudatosan nem ebben a rétegben élnek.
- A belépés előtti szakaszban átmeneti kibocsátás-visszaesés jelenik meg
  (~−0,2%): az anticipált konvergencia reálfelértékelődése fékezi az
  exportot, mielőtt a beruházási csatorna beindul — a klasszikus
  konvergenciás felértékelődési dilemma, endogén módon.

## v0.2 — `kkv_dsge_v02.mod`: euró-belépési szcenárió

A v0.1 modellmag változatlan egyenletekkel, de a sov/bank prémium itt
**exogén determinisztikus pálya** (anticipált, permanens csökkenés),
perfect foresight szimulációval. Három szcenárió (`-DSCENARIO=1|2|3`):
alap (−200 bp szuverén, −45 bp banki, 60% transzmisszió), optimista
(−250/−60/70%), pesszimista (−150/−30/40%). Időzítés: bejelentés q1,
belépés q13, normalizálódás q16-ig. Futtatás:

```
matlab -batch "cd('src/model'); run_v02"
```

Kimenet: `output/tables/szcenario_v02.csv`, ábra: `src/04_szcenario_abrak.py`.

**Fontos kalibrációs tanulság (v0.2):** a 10 éves GDP-hatás így
+0,08–0,17% — nagyságrenddel kisebb a vázlatban várt 1,5–2%-nál. Az ok:
a v0.1/v0.2-ben a szuverén prémium **csak a vállalati EFP-n** keresztül
hat (25%-os transzmisszióval), miközben a vázlat logikájában a szuverén
konvergencia az egész gazdaság kockázatmentes hozamgörbéjét is lehúzza
(UIP-országprémium, háztartási és állami finanszírozás). Ennek a
csatornának a beépítése (sov → UIP-prémium) a v0.3 fő feladata — várhatóan
ez adja az aggregált hatás nagyját, míg a KKV/nagyvállalat aszimmetriát
továbbra is az EFP-csatorna hordozza.

## v0.1 — `kkv_dsge_v01.mod`: futó váz

`kkv_dsge_v01.mod`: kétszektoros (KKV / nagyvállalat) kis nyitott gazdaság
új-keynesi modell, szektoronként eltérő (méretfüggő) BGG-típusú pénzügyi
akcelerátorral. A két hitelköltség-csatorna (szuverén prémium, banki
forrásköltség) exogén EFP-sokként lép be — a modellválasztási döntés
szerint (Notion döntésnapló 2026-07-06; `docs/modell_vazlat/`).

Log-linearizált; Dynare 6.5 + MATLAB alatt fut, Blanchard–Kahn teljesül,
elméleti momentumok stacionáriusak.

## Futtatás

```
matlab -batch "cd('src/model'); run_v01"
```

(Dynare útvonal: `DYNARE_PATH` env változó, alapértelmezés `C:\dynare\6.5\matlab`.)
A futás az `output/tables/irf_v01.csv`-be exportálja az IRF-eket; az ábrát a
`src/03_irf_abrak.py` készíti belőle.

## Mi van benne / mi nincs (v0.1)

| Benne | Nincs benne (következő verziók) |
|---|---|
| kétszektoros mag, CES-aggregálás szektor-relatívárakkal | Calvo-bérek (EAGLE-ben van) |
| BGG-lite akcelerátor: EFP, Tobin-q, nettó vagyon szektoronként | teljes EAGLE kereskedelmi mátrix (EA/US/RW) |
| szuverén + banki forrásköltség sokk transzmissziós súlyokkal | import-árazási ragadósság (LCP) |
| SOE-zárás: UIP adósság-rugalmas prémiummal | részletes fiskális blokk |
| Taylor-szabály | euró-belépés rezsimváltása (kamatunió) — v0.2 determinisztikus szcenárió |

## Kalibráció fő forrásai

- Békési–Kaszab–Szentmihályi (MNB WP 2017/7) appendix-táblák
- Opten-panel: tőkeáttétel medián → lev_S=1.6, lev_L=1.85; EFP-szintek
- pitch (2026-07-06): sokk-transzmissziós súlyok (szuverén ~25%, banki ~60% a KKV-ra)
- Jakab–Világi (2008): habit, ár-ragadósság nagyságrendek

## Ismert továbbfejlesztési pontok

1. Euró-szcenárió determinisztikus szimulációként (150–250 bp szuverén +
   30–60 bp banki prémium-csökkenés, anticipációval) — v0.2 fő feladata.
2. A nettó vagyon egyenlet BGG-lite közelítés — teljes BGG-linearizáció
   ellenőrzendő az appendix alapján.
3. Kalibráció finomítása a WP 2017/7 táblákból (most nagyságrendi értékek).
4. A 2. réteg (szegmens-leképezés) kötése az IRF-kimenethez.
