# CLAUDE.md

Projekt-instrukció a Claude Code számára. Ez a fájl minden munkamenet elején betöltődik.

## A projekt

New Keynesian DSGE modell magyar adatokra, egy Chamber of Commerce megbízásra.
Deadline: 2026. december. Három kollaborátor dolgozik rajta, mind a `main`-en.
A modell kiindulópontja a `docs/modell_vazlat/`-ban lévő összefoglaló —
ez még ötletelés fázisú vitaanyag, a végleges forrás később kerül be ide.

---

## 👉 ELŐSZÖR: `ALLAPOT.md` (generált)

**Az „mit állítunk ma / mi a státusza / mit vontunk vissza" kérdésre az
[`ALLAPOT.md`](ALLAPOT.md) a válasz**, nem ez a fájl és nem a `docs/`.
Generált, kézzel nem szerkeszthető:

```
matlab -batch "cd('src/4_infra'); smoke_test"      # az őrök futnak, t00_orok.csv
python src/4_infra/13_allapotlap.py                # ALLAPOT.md
```

Forrásai: `docs/regiszter/allitasok.csv` (mit állítunk) +
`docs/regiszter/parameterek.csv` (a 91 paraméter metaadata) + az őrök.
**Új eredmény = sor a megfelelő CSV-ben + őr a füsttesztben**, nem új
dátumozott doksi. A generátor kiabál, ha egy „áll" állításnak nincs őre,
ha egy őr megbukott, vagy ha egy állítás nem létező őrre hivatkozik.

> **SZINT-ŐR SZABÁLY:** ha egy állítás **számot mond**, az őrnek *arra a
> számra* kell mennie, nem csak a relációra. Egy „L > E > D" sorrend-őr
> mellett a „2,34 > 1,94 > 1,72" szintek némán elavulhatnak — a szöveg és
> az adat pont így csúszik szét. (Ez a rés 2026-08-16-án derült ki; azóta
> `t37`/`t47`/`t48b`/`t50` mind kapott SZINT-őrt.)

Az alábbi szakasz a **háttér és a munkamódszer** — az aktuális számokat az
`ALLAPOT.md` viszi.

---

## ⚠ ÁLLAPOT — 2026-08-12. EZT OLVASD EL ELŐSZÖR

### A fő modell: `src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod` (Jakab–Világi mag). NEM az EAGLE.

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
  mérés hibás, a gyökérok még nyitott: `docs/figyelmeztetesek/FIGYELMEZTETES_io_tabla_gyanus.md`.
- **A `t_S > t_L` feltevést** eredményként — nem azonosítható:
  `docs/figyelmeztetesek/FIGYELMEZTETES_fo_allitas.md`.
- **Szegmens-tőkét/beruházást a v05-ből** — reallokációs maradék.

**Ami robusztus:** az aggregált GDP-hatás **előjele és nagyságrendje**.
⚠ **A sáv 2026-08-16-én módosult:** a korábbi „+0,27% … +1,04%" az
*átvett* `rho_acc` = 0,85 mellett érvényes; az Opten-panelből horgonyzott
`rho_acc` = 0,9673 mellett a felső vég +2,03% (`-DOPTEN=1`), a `rho_acc`-ot
önmagában cserélve +2,89% (`-DOPTEN=3`). A helyes közlés: **+0,3 … +2,9%**,
azzal, hogy a felső vég a hozzáférési csatorna perzisztenciáján múlik.
Részletek: `docs/eredmenyek/2026-08-16_opten_kalibracio_eredmeny.md`.

### A projekt AZONOSÍTÁSI ÁLLÁSPONTJA — ezt kell tudni közölni

Három külső bírálati kör (2026-08-16, 08-21) után ez a védhető
megfogalmazás, és ezt érdemes szó szerint használni:

> **Az empirikus adatok az access-csatorna reduced-form hatásait
> azonosítják, de a strukturális `ACCSCALE` paramétert nem. Ezért a
> DSGE-ben az eredmény küszöbfüggő: a KKV-k relatív előnye akkor jelenik
> meg, ha az access-csatorna perzisztenciája és erőssége egy meghatározott
> tartomány fölött van.**

Ez **nem gyengeség-beismerés**, hanem a modell és az empíria közötti
azonosítási határ korrekt kezelése. A küszöbforma legitim közlési forma —
van rá magyar DSGE-precedens (Szabó Bakos 2006, 4.7: a szerző explicit
kimondja, hogy nem küszöbértéket határoz meg, hanem elemzési technikát mutat).

⚠ **Amit soha ne csináljunk:** egy IV-ből kapott `Δberuházás / Δhozzáférés`
hányadost `ACCSCALE`-nak átnevezni. Az „indukált beruházási válasz egységnyi
indukált hozzáférésre" — a program teljes finanszírozási hatását viszi, nem
a hozzáférési csatorna strukturális rugalmasságát. Egy bíráló ezt azonnal
megtámadná, és joggal.

### Munkamódszer, ami bevált — tartsd meg

1. **Füstteszt push előtt**: `matlab -batch "cd('src/4_infra'); smoke_test"` —
   jelenleg **116 ellenőrzés**, köztük replikációs és regressziós őrök.
   Ha egy állítást közlünk, tegyünk rá őrt.
2. **BK-teszt nem elég.** Egy elgépelt index mellett is lehet 18/18
   konvergencia. Kell **független verifikáció**: szimmetria-teszt
   (`-DSYM=1`), aggregációs azonosságok, nulla-sokk kontroll
   (`-DSCENARIO=4`), egymásba ágyazás. Lásd `src/modell/1_fo_vonal_jv/futtato/ellenorzes_3type.m`.
3. **Nagy átalakítás rövid életű branchen**, aznap vissza a main-re.
4. **Kalibrációs változtatás makró-kapcsolóval** (`-DTSCEN`, `-DACCSCALE`,
   `-DCALIB`, `-DEPSCES`, `-DSYM`, `-DOPTEN`, `-DRHOACC`), ne felülírással —
   így minden variáns futtatható és összevethető marad. Ha egy kapcsoló új
   alapértelmezést kapna, az **csapatdöntés**, nem kódolási lépés.
5. **Ha egy paraméter `1/(1−ρ)` alakban hat, scan kell rá, nem pontbecslés.**
   A `rho_acc` 0,85 → 0,9673 horgonyzása a hosszú távú hatást 4,6×-re vitte;
   ilyen paraméternél egyetlen szám közlése félrevezető (`t49`).

### Hol tart a munka

- **Modellépítés: kész.** Innentől **horgonyzás** van hátra.
- **✅ 2026-08-16: az 1. prioritás lefutott** — 14 paraméter az
  Opten-panelből (`s15_opten_kalibracio` → `t46`; modellhatás:
  `stress_opten_v09` → `t47`–`t49b`). Makró-kapcsolóval kötve be:
  `-DOPTEN=0|1|2|3`, `-DRHOACC=<x>`; **az alapértelmezés `0` maradt**, mert
  az `om_j`/`shl_j` súlyokhoz még kell a KSH/Eurostat SBS mikrokör-bontás.
  Amit hozott: `phi_L` és `delta` **megerősítve**; a `lev_E = lev_D`
  kényszerített egyenlőség **megdőlt** (1,939 vs 1,719); a `rho_acc`
  0,85 → **0,9673**, amitől a KKV-küszöb 36,5 → 22,3.
  Eredménydoc: `docs/eredmenyek/2026-08-16_opten_kalibracio_eredmeny.md`.
- **Teendőlista a csapatnak:** `docs/terv/kalibracio_teendok_csapatnak.md`
- **Teljes paramétertábla (91 db):** `docs/modszertan/kalibracio_tabla.md`
- **Részletes átadás:** `docs/archiv/ATADAS_2026-08-12.md`

---

## Repo-struktúra

- `src/` — Dynare `.mod` fájlok és scriptek. Minden kód ide. A szerkezetet a `src/README.md` írja le (`1_adat` / `2_empirikus` / `3_abrak` / `4_infra` / `modell` / `app`). **Új script
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
