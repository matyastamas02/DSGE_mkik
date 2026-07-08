# Data Index

A nyers és tisztított adatfájlok NEM a repóban vannak (méret miatt), hanem Google Drive-on.
Ez a fájl a hivatkozási pont: minden adathoz link + leírás + elvárt lokális útvonal.

Letöltés után a fájlokat a lent megadott `Lokális útvonal`-ra tedd, hogy a `src/` scriptek megtalálják.

Drive-mappa (minden adat itt): https://drive.google.com/drive/folders/1L7rlzdq3izqFV1d6lPS5Du1auA0ADqXx

## Nyers adat (`data/raw/`)

| Fájl | Leírás | Forrás | Drive link | Lokális útvonal |
|------|--------|--------|------------|-----------------|
| opten.xlsx | Opten vállalati panel 2021–2025: 37 805 cég (10+ fő), 150 982 cég-év megfigyelés, 162 pénzügyi mező (teljes mérleg + eredménykimutatás); szegmentáció: méret, ágazat (TEÁOR), régió (NUTS-2), kockázati besorolás; plusz közbeszerzés- és EU-támogatás-jelzők. ~80 MB. | MKIK (Opten) | [link](https://drive.google.com/file/d/1nDEhfF7zp1Lo5mi1ClzBZegcUMfAe-4A/view) | `data/raw/opten.xlsx` |

## Tisztított / modellbe menő adat (`data/processed/`)

| Fájl | Leírás | Előállító script | Drive link | Lokális útvonal |
|------|--------|------------------|------------|-----------------|
| opten_panel.csv | Egységes, tisztított cég-év panel (150 982 sor × 69 oszlop, 2021–2025): kulcs mérleg- és eredménymezők ezer Ft-ban + kockázati besorolás évenként + méret/ágazat/régió (NUTS-2, irsz-alapú közelítés) + EU-támogatás- és közbeszerzés-jelzők + származtatott változók (implicit kamatráta, van_hitel, exportarány, tőkeáttétel) | `src/01_opten_panel_tisztitas.py` | *(scriptből reprodukálható, nem kell Drive)* | `data/processed/opten_panel.csv` |

## Kapcsolódó dokumentumok

- `adat_helyzet.html` — belső adathelyzet-jelentés az Opten-panelről (lefedettség, korlátok,
  módszertani teendők): [link](https://drive.google.com/file/d/1dssEbTAUCSUfj0gJdkwZ244Ej-bL9CO5/view).
  Nem adat, nem kell letölteni a `data/`-ba.

## Megjegyzések

- Ha egy tisztított fájl script-ből reprodukálható, elég a nyerset letölteni + a scriptet futtatni.
- Új adat felvételekor: töltsd fel Drive-ra, majd vedd fel ide egy sorral.
- Nyitott kérdések az adathoz (részletek az adathelyzet-jelentésben): az „AVG" kockázati besorolás
  jelentése (szállítónál tisztázandó); a részleges 2025-ös év csak ellenőrzésre javasolt.
