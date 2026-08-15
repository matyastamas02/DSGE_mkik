# CLAUDE.md

Projekt-instrukció a Claude Code számára. Ez a fájl minden munkamenet elején betöltődik.

## A projekt

New Keynesian DSGE modell magyar adatokra, egy Chamber of Commerce megbízásra.
Deadline: 2026. december. Három kollaborátor dolgozik rajta, mind a `main`-en.
A modell kiindulópontja a `docs/modell_vazlat/`-ban lévő összefoglaló —
ez még ötletelés fázisú vitaanyag, a végleges forrás később kerül be ide.

---

## ⚠ ÁLLAPOT — 2026-08-12. EZT OLVASD EL ELŐSZÖR

### A fő modell: `src/model/jv_dsge_v09_access.mod` (Jakab–Világi mag). NEM az EAGLE.

A repóban **két modellvonal** él. A `kkv_dsge_*` az EAGLE-vonal
(referencia/robusztusság), a `jv_dsge_*` a Jakab–Világi vonal (**fő**).
2026-08-12-ig a legfejlettebb modell az EAGLE-magon volt — miközben a
csapat 2026-07-13-án azzal az érvvel döntött a JV mellett, hogy annak
paraméterei magyar adaton **becsültek**. Ez azóta rendben van: a JV-vonal
négy lépcsőben utolérte (`v06` → `v07_3type` → `v08_3type_arak` →
`v09_access`), mind 18/18 BK-stabil.

### A projekt visszatérő hibamintázata — EZT MUSZÁJ TUDNI

**Hatszor fordult már elő, hogy egy horgonyzatlan paraméter vitte a fő
szektorális eredményt, miközben az aggregált eredmény stabil volt:**
`t_S > t_L` · `chi`-aszimmetria · `ACCSCALE` · IO-alapú `s_kkv` ·
`psi_i` · `eps_ces`.

Ezért a szabály: **minden KKV/nagyvállalat aszimmetriát, aminek nincs
hivatkozott forrása, gyanúsnak kell tekinteni**, és a szektorális
eredményt **küszöbformában** kell közölni (nem pontbecslésként).

### Amit NEM szabad közölni

- **Szegmens-szintű kibocsátást pontbecslésként** — két horgonyzatlan
  paraméter (`eps_ces`, `ACCSCALE`) viszi, mindkettőn fordul az előjel.
- **A `t24`/`s_kkv` IO-számokat** („autóipar 6% hazai köztes input") — a
  mérés hibás, a gyökérok még nyitott: `docs/FIGYELMEZTETES_io_tabla_gyanus.md`.
- **A `t_S > t_L` feltevést** eredményként — nem azonosítható:
  `docs/FIGYELMEZTETES_fo_allitas.md`.
- **Szegmens-tőkét/beruházást a v05-ből** — reallokációs maradék.

**Ami robusztus:** az aggregált GDP-hatás, +0,27% … +1,04% minden
lépcsőn és paraméterezésen.

### Munkamódszer, ami bevált — tartsd meg

1. **Füstteszt push előtt**: `matlab -batch "cd('src'); smoke_test"` —
   jelenleg **57 ellenőrzés**, köztük replikációs és regressziós őrök.
   Ha egy állítást közlünk, tegyünk rá őrt.
2. **BK-teszt nem elég.** Egy elgépelt index mellett is lehet 18/18
   konvergencia. Kell **független verifikáció**: szimmetria-teszt
   (`-DSYM=1`), aggregációs azonosságok, nulla-sokk kontroll
   (`-DSCENARIO=4`), egymásba ágyazás. Lásd `src/model/ellenorzes_3type.m`.
3. **Nagy átalakítás rövid életű branchen**, aznap vissza a main-re.
4. **Kalibrációs változtatás makró-kapcsolóval** (`-DTSCEN`, `-DACCSCALE`,
   `-DCALIB`, `-DEPSCES`, `-DSYM`), ne felülírással — így minden variáns
   futtatható és összevethető marad.

### Hol tart a munka

- **Modellépítés: kész.** Innentől **horgonyzás** van hátra.
- **Teendőlista a csapatnak:** `docs/kalibracio_teendok_csapatnak.md`
- **Teljes paramétertábla (91 db):** `docs/kalibracio_tabla.md`
- **Részletes átadás:** `docs/ATADAS_2026-08-12.md`

---

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
