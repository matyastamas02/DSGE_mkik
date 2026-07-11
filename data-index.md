# Data Index

A nyers és tisztított adatfájlok NEM a repóban vannak (méret miatt), hanem Google Drive-on.
Ez a fájl a hivatkozási pont: minden adathoz link + leírás + elvárt lokális útvonal.

Letöltés után a fájlokat a lent megadott `Lokális útvonal`-ra tedd, hogy a `src/` scriptek megtalálják.

Drive-mappa (minden adat itt): https://drive.google.com/drive/folders/1L7rlzdq3izqFV1d6lPS5Du1auA0ADqXx

## Nyers adat (`data/raw/`)

| Fájl | Leírás | Forrás | Drive link | Lokális útvonal |
|------|--------|--------|------------|-----------------|
| opten.xlsx | Opten vállalati panel 2021–2025: 37 805 cég (10+ fő), 150 982 cég-év megfigyelés, 162 pénzügyi mező (teljes mérleg + eredménykimutatás); szegmentáció: méret, ágazat (TEÁOR), régió (NUTS-2), kockázati besorolás; plusz közbeszerzés- és EU-támogatás-jelzők. ~80 MB. | MKIK (Opten) | [link](https://drive.google.com/file/d/1nDEhfF7zp1Lo5mi1ClzBZegcUMfAe-4A/view) | `data/raw/opten.xlsx` |

## Makró-idősorok (`data/raw/makro/`)

| Fájl | Leírás | Forrás | Link | Lokális útvonal | Állapot |
|------|--------|--------|------|-----------------|---------|
| bubor_tortenet.xls | Napi BUBOR-fixingek (1h–12h) évenkénti lapokon, 1996-tól | MNB | [stabil URL](https://www.mnb.hu/letoltes/bubor2.xls) — Drive nem kell | `data/raw/makro/bubor_tortenet.xls` | **letöltve** (2026-07-08) — az s08/s09 közelítő éves átlagai ebből cserélendők |
| mnb_vallalati_kamatok | Vállalati új-szerződéses kamatok (méret/összeg szerint) — a piaci árazás mérése, a red flag-vizsgálat kulcsadata | MNB kamatstatisztika | [statisztika.mnb.hu](https://statisztika.mnb.hu/) → Hitelintézeti kamatok | `data/raw/makro/mnb_vallalati_kamatok.xlsx` | letöltendő |
| ksh_gdp | Negyedéves GDP és felhasználási tételek, 2010-től (hosszú makropálya) | KSH stadat | [gdp0001](https://www.ksh.hu/stadat_files/gdp/hu/gdp0001.html) | `data/raw/makro/ksh_gdp.csv` | letöltendő |
| hnb_kamatok | Horvát vállalati kamatstatisztika — az euró-átállás ex-post validációja (B4 ábra) | HNB | [hnb.hr statisztika](https://www.hnb.hr/en/statistics) | `data/raw/makro/hnb_kamatok.xlsx` | letöltendő |

## Tisztított / modellbe menő adat (`data/processed/`)

| Fájl | Leírás | Előállító script | Drive link | Lokális útvonal |
|------|--------|------------------|------------|-----------------|
| opten_panel.csv | Egységes, tisztított cég-év panel (150 982 sor × 69 oszlop, 2021–2025): kulcs mérleg- és eredménymezők ezer Ft-ban + kockázati besorolás évenként + méret/ágazat/régió (NUTS-2, irsz-alapú közelítés) + EU-támogatás- és közbeszerzés-jelzők + származtatott változók (implicit kamatráta, van_hitel, exportarány, tőkeáttétel) | `src/01_opten_panel_tisztitas.py` | [link](https://drive.google.com/file/d/1SB_eEYCrB8RQoGElIkeFUYH1EIHae0Q-/view) *(scriptből is reprodukálható)* | `data/processed/opten_panel.csv` |

## Kapcsolódó dokumentumok

- `adat_helyzet.html` — belső adathelyzet-jelentés az Opten-panelről (lefedettség, korlátok,
  módszertani teendők): [link](https://drive.google.com/file/d/1dssEbTAUCSUfj0gJdkwZ244Ej-bL9CO5/view).
  Nem adat, nem kell letölteni a `data/`-ba.
- Drive `DSGE/alapok/` — az alapul szolgáló modell-tanulmány (összefoglaló docx + ábrák):
  [mappa](https://drive.google.com/drive/folders/1ukagKIuzFk6mqrN-ne_gpZQpUlCS1SRV).
  Repo-beli másolat: `docs/`.
- Drive `DSGE/irodalom/` — szakirodalmi PDF-ek (BGG 1999, Gerali és tsai., MNB EAGLE,
  euró-bevezetési tanulmányok) + `claude-notion_skill/` feldolgozott jegyzetek:
  [mappa](https://drive.google.com/drive/folders/1o_cRtlURj-OW5LyPQ5e-p96mOPet_dRO).
  Szerzői jogos anyagok — a repóba NEM kerülnek, a tudásbázis helye a Notion.

## Megjegyzések

- Ha egy tisztított fájl script-ből reprodukálható, elég a nyerset letölteni + a scriptet futtatni.
- Új adat felvételekor: töltsd fel Drive-ra, majd vedd fel ide egy sorral.
- Nyitott kérdések az adathoz (részletek az adathelyzet-jelentésben): az „AVG" kockázati besorolás
  jelentése (szállítónál tisztázandó); a részleges 2025-ös év csak ellenőrzésre javasolt.
