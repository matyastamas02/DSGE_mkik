# DSGE-modell (Dynare)

## Állapot: v0.1 — futó váz

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
