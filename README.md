# Hungarian DSGE Model — [Chamber of Commerce Project]

New Keynesian DSGE modell magyar adatokra.
**Deadline: 2026. december.**
Kollaborátorok: [Név1], [Név2], [Név3].

## Mi hol van

| Tartalom             | Hely                                 |
|----------------------|--------------------------------------|
| Kód (Dynare/R)       | `src/` — ebben a repóban            |
| Nyers adat           | Google Drive → `data-index.md`      |
| Tisztított adat      | Google Drive → `data-index.md`      |
| Ábrák, táblák        | `output/` — kódból reprodukálva     |
| Döntésnapló, jegyzet | Notion → [link]                     |
| Napi kommunikáció    | Slack #[csatorna]                   |

## Setup

```bash
git clone [repo-url]
cd dsge-project
```

1. Dynare [verzió] telepítve, MATLAB [verzió] / Octave.
2. Adat letöltése: lásd `data-index.md`, tedd a `data/raw/` mappába (git-ignored).
3. Futtatás: lásd alább.

## Futtatás

```bash
# Fő modell becslése
dynare src/model_main.mod

# SMM estimation
[parancs]

# Ábrák regenerálása
[parancs]
```

Az `output/` teljes egésze reprodukálható a `src/`-ből. Kézzel semmit ne rakj bele.

## Repo-struktúra

```
src/          Dynare .mod fájlok, R/MATLAB scriptek
data/         raw/ és processed/ — TARTALMA git-ignored, csak Drive-on
output/       figures/ + tables/ — kódból generálva
docs/         LaTeX, thesis-alapú levezetések
notes/        almappánkénti rövid README-k
```

## Munkafolyamat (mindenki main-en dolgozik)

Mivel nincs feladat-felosztás, a konfliktus elkerülése a fő cél:

- **Pullolj minden munka ELŐTT:** `git pull --rebase`
- **Commitolj kicsit és gyakran,** beszédes üzenettel (`becslés: SZOCHO sokk kalibráció`, ne `update`).
- **Egy fájlon ne dolgozzon egyszerre kettő** — szólj Slacken, ha egy `.mod`-ot piszkálsz.
- **Push előtt futtasd le,** hogy ne törjön a `main`.
- Nagy kísérleti átalakításhoz: rövid életű branch, aznap merge-eld vissza.

## Adatkezelés

Nyers adat NEM kerül a repóba (méret). Minden adatfájl a Drive-on, a `data-index.md`
tartalmazza a linket, leírást, forrást és a `data/` mappán belüli elvárt elérési utat.
