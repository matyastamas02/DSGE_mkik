# Data Index

A nyers és tisztított adatfájlok NEM a repóban vannak (méret miatt), hanem Google Drive-on.
Ez a fájl a hivatkozási pont: minden adathoz link + leírás + elvárt lokális útvonal.

Letöltés után a fájlokat a lent megadott `Lokális útvonal`-ra tedd, hogy a `src/` scriptek megtalálják.

## Nyers adat (`data/raw/`)

| Fájl | Leírás | Forrás | Drive link | Lokális útvonal |
|------|--------|--------|------------|-----------------|
| [pl. macro_raw.csv] | [KSH negyedéves GDP, infláció, ...] | [KSH / MNB] | [link] | `data/raw/macro_raw.csv` |
| | | | | |

## Tisztított / modellbe menő adat (`data/processed/`)

| Fájl | Leírás | Előállító script | Drive link | Lokális útvonal |
|------|--------|------------------|------------|-----------------|
| [pl. model_input.csv] | [detrendelt, transzformált sorok] | `src/[prep_script]` | [link] | `data/processed/model_input.csv` |
| | | | | |

## Megjegyzések

- Ha egy tisztított fájl script-ből reprodukálható, elég a nyerset letölteni + a scriptet futtatni.
- Új adat felvételekor: töltsd fel Drive-ra, majd vedd fel ide egy sorral.
