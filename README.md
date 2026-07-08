# Hungarian DSGE Model — [Chamber of Commerce Project]

New Keynesian DSGE modell magyar adatokra. Deadline: 2026. december.
Kollaborátorok: [Név1], [Név2], [Név3].

## Mi hol van

| Tartalom            | Hely                                    |
|---------------------|-----------------------------------------|
| Kód (Dynare/R)      | `src/` — ebben a repóban               |
| Nyers adat          | Google Drive → `data-index.md`         |
| Tisztított adat     | Google Drive → `data-index.md`         |
| Ábrák, táblák       | `output/` — kódból reprodukálva        |
| Döntésnapló, jegyzet| Notion → [link]                        |
| Napi kommunikáció   | Slack #[csatorna]                      |

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
