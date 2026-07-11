# CLAUDE.md

Projekt-instrukció a Claude Code számára. Ez a fájl minden munkamenet elején betöltődik.

## A projekt

New Keynesian DSGE modell magyar adatokra, egy Chamber of Commerce megbízásra.
Deadline: 2026. december. Három kollaborátor dolgozik rajta, mind a `main`-en.
A modell kiindulópontja a `docs/modell_vazlat/`-ban lévő összefoglaló —
ez még ötletelés fázisú vitaanyag, a végleges forrás később kerül be ide.

## Repo-struktúra

- `src/` — Dynare `.mod` fájlok és scriptek. Minden kód ide. **Új script
  MATLAB-ban készüljön** (a korai 01–05 adat-előkészítő/ábra scriptek
  Pythonban vannak — működnek, nem kell átírni őket).
- `data/raw/`, `data/processed/` — adat, **git-ignored**. A tartalom Drive-on van, lásd `data-index.md`.
- `output/figures/`, `output/tables/` — ábrák és eredménytáblák, **kódból generálva**.
- `docs/` — LaTeX, levezetések.
- `notes/` — almappánkénti rövid README-k.

## Fontos szabályok

1. **Adatot soha ne commitolj.** A `data/` tartalma Drive-ról jön. Ha adat kell,
   a `data-index.md` alapján töltsd le a megadott lokális útvonalra.
2. **Az `output/` reprodukálható legyen.** Ábrát/táblát ne kézzel rakj be — mindig a
   `src/` scriptből generáld. Ha új ábra kell, a scriptet módosítsd.
3. **Git-fegyelem (mindenki main-en van):**
   - Munka előtt mindig `git pull --rebase`.
   - Kicsi, gyakori commitok, beszédes üzenettel (magyarul is jó): pl.
     `becslés: SZOCHO sokk kalibráció`, ne `update`.
   - Push előtt futtasd le a modellt, hogy ne törjön a `main`.
   - Nagy átalakításhoz rövid életű branch, aznap visszamerge.
4. **Egy `.mod` fájlon ne dolgozz, ha más is piszkálja** — a koordináció Slacken megy.

## Connectorok

- **GitHub**: a lokális klónon `git`/`gh` parancsokkal dolgozz (nem MCP-n át).
- **Google Drive**: nyers/tisztított adat forrása, `data-index.md` szerint.
- **Notion**: döntésnapló és szakirodalmi tudásbázis. Modellezési döntés után
  (pl. paraméterválasztás, sokk-specifikáció) írd fel a Notion döntésnaplóba, ha kérem.

## Tipikus munkafolyamatok

- „Húzd le X adatot Drive-ról, futtasd a becslést, az eredménytáblát tedd az `output/tables`-be."
- „Regeneráld az IRF ábrákat a `src/[script]`-ből."
- „A most választott indexációs paraméter döntését írd fel a Notion döntésnaplóba."
