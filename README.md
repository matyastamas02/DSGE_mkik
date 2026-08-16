# Hungarian DSGE Model — [Chamber of Commerce Project]

New Keynesian DSGE modell magyar adatokra: **mit tesz az euró bevezetése a
magyar GDP-vel, és másképp érinti-e a KKV-kat, mint a nagyvállalatokat?**
**Deadline: 2026. december.** Kollaborátorok: [Név1], [Név2], [Név3].

> # 👉 [**ALLAPOT.md**](ALLAPOT.md) — itt kezdd
>
> Egy generált oldal: **mit állítunk ma**, mi a bizonyítéka, mi védi, és
> **mit vontunk már vissza** (dátummal és okkal). Plusz mind a 91 paraméter
> élő értékkel, forrással és státusszal.
>
> Kézzel nem szerkeszthető — a `docs/regiszter/*.csv`-ből és a füstteszt
> őreiből generálódik, tehát nem tud elcsúszni a kódtól:
>
> ```
> matlab -batch "cd('src/4_infra'); smoke_test"
> python src/4_infra/13_allapotlap.py
> ```
>
> *Korábban kilenc különböző fájl állította magáról, hogy leírja a
> jelenlegi állapotot. Ez a lap váltja ki őket.*

## A fő modell

**`src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod`** (Jakab–Világi mag).
**NEM az EAGLE** — az a referencia-vonal.

A repóban négy modell-mappa él, és a **mappa neve mondja meg a státuszt**:

| Mappa | Mi ez | Státusz |
|---|---|---|
| [`1_fo_vonal_jv/`](src/modell/1_fo_vonal_jv/) | Jakab–Világi mag, háromtípusos — **a leadandó** | 🟢 élő |
| [`2_referencia_eagle/`](src/modell/2_referencia_eagle/) | EAGLE-HU mag, robusztussági összevetés | 🟡 referencia |
| [`3_archiv_korai_jv/`](src/modell/3_archiv_korai_jv/) | meghaladott JV-lépcsők (v01–v05) | ⚪ archív |
| [`4_app/`](src/modell/4_app/) | a Streamlit-app futtató-modellje | 🟡 külön termék |

Mindegyikben ugyanaz a szerkezet: **`README.md` + `.mod` fájlok +
`futtato/`**. A mappa README-je mondja meg, mi van benne, mit bizonyít, és
hogyan kell futtatni. Miért a JV és nem az EAGLE:
[`src/modell/README.md`](src/modell/README.md).

## Repo-struktúra

```
ALLAPOT.md      ← a generált állapotlap (ITT KEZDD)
src/
  1_adat/       nyers -> tisztított panel, leíró statisztika
  2_empirikus/  becslés és horgonyzás a panelből (Opten, IO, MNB)
  3_abrak/      ábra- és leképezés-generálók a modell kimenetéből
  4_infra/      füstteszt, regiszter-építő, állapotlap-generátor
  modell/       a Dynare-modellek, vonalanként (fent)
  app/          Streamlit-app
data/           raw/ és processed/ — TARTALMA git-ignored, csak Drive-on
output/         figures/ + tables/ — kódból generálva, kézzel semmit bele
docs/
  regiszter/        az állítás- és paraméter-regiszter (CSV, ez a forrás)
  figyelmeztetesek/ amit NEM szabad közölni, és miért
  modszertan/       magyarázatok, paramétertábla, szerkezeti tanulságok
  eredmenyek/       dátumozott eredmény-doksik
  terv/             teendőlista, tanulmány-vázlat, ábraterv
  archiv/           meghaladott állapotleírások
```

## Setup

1. Dynare 6.5 + MATLAB. Ha nem a `C:\dynare\6.5\matlab` az útvonal, állítsd
   a `DYNARE_PATH` környezeti változót.
2. Adat: `data-index.md` szerint Drive-ról a `data/raw/`-ba (git-ignored).
3. Panel építése: `python src/1_adat/01_opten_panel_tisztitas.py`

## Futtatás

```bash
# A fő modell egy futása
matlab -batch "cd('src/modell/1_fo_vonal_jv'); addpath('C:\dynare\6.5\matlab'); dynare('jv_dsge_v09_access','-DSCENARIO=1','-DTSCEN=3','console')"

# A fő vonal tesztjei (a futtatók maguk lépnek a megfelelő mappába)
matlab -batch "cd('src/modell/1_fo_vonal_jv/futtato'); stress_jv_access_v09"
matlab -batch "cd('src/modell/1_fo_vonal_jv/futtato'); stress_opten_v09"
matlab -batch "cd('src/modell/1_fo_vonal_jv/futtato'); ellenorzes_3type"

# Füstteszt — PUSH ELŐTT KÖTELEZŐ
matlab -batch "cd('src/4_infra'); smoke_test"
```

Az `output/` teljes egésze reprodukálható a `src/`-ből. Kézzel semmit ne
rakj bele.

## Munkafolyamat (mindenki main-en dolgozik)

- **Pullolj minden munka ELŐTT:** `git pull --rebase`
- **Commitolj kicsit és gyakran,** beszédes üzenettel (`becslés: SZOCHO
  sokk kalibráció`, ne `update`).
- **Egy `.mod`-on ne dolgozzon egyszerre kettő** — szólj Slacken.
- **Push előtt futtasd le a füsttesztet,** hogy ne törjön a `main`.
- Nagy átalakításhoz rövid életű branch, aznap merge vissza.
- **Új eredmény = sor a `docs/regiszter/`-ben + őr a füsttesztben**, nem új
  dátumozott doksi. Ez tartja egyben az `ALLAPOT.md`-t.

## Adatkezelés

Nyers adat NEM kerül a repóba (méret). Minden adatfájl a Drive-on, a
`data-index.md` tartalmazza a linket, leírást, forrást és a `data/` mappán
belüli elvárt elérési utat.
