# Hungarian DSGE Model — [Chamber of Commerce Project]

New Keynesian DSGE modell magyar adatokra.
**Deadline: 2026. december.**
Kollaborátorok: [Név1], [Név2], [Név3].

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
> matlab -batch "cd('src'); smoke_test"
> python src/13_allapotlap.py
> ```
>
> *Korábban kilenc különböző fájl állította magáról, hogy leírja a
> jelenlegi állapotot. Ez a lap váltja ki őket.*

## Mi hol van

| Tartalom             | Hely                                 |
|----------------------|--------------------------------------|
| Kód (Dynare/R)       | `src/` — ebben a repóban            |
| Nyers adat           | Google Drive → `data-index.md`      |
| Tisztított adat      | Google Drive → `data-index.md`      |
| Ábrák, táblák        | `output/` — kódból reprodukálva     |
| Döntésnapló, jegyzet | Notion → [link]                     |
| Napi kommunikáció    | Slack #[csatorna]                   |

---

## ⚠ MELYIK MODELLEL MEGYÜNK TOVÁBB — olvasd el, mielőtt bármit futtatsz

**A fő vonal: `src/model/jv_dsge_v09_access.mod` (Jakab–Világi mag).**
**NEM az EAGLE.**

Ez azért kell ide kiírni, mert a repóban **két modellvonal** él, és
2026-08-12-ig a legfejlettebb modell az EAGLE-vonalon volt — miközben a
csapat 2026-07-13-án azzal az érvvel döntött a Jakab–Világi alapmodell
mellett, hogy annak paraméterei **magyar adaton Bayes-i módszerrel
becsültek**, nem kalibráltak. A döntés és a kód nem ért össze. **Most már
összeér:** a JV-vonal mindent tud, amit az EAGLE-vonal.

| Vonal | Fájlok | Szerep |
|---|---|---|
| **JV — FŐ VONAL** | `jv_dsge_v01` … **`jv_dsge_v09_access`** | **ezzel megyünk tovább** |
| EAGLE — referencia | `kkv_dsge_v01` … `kkv_dsge_v07_access` | robusztussági/összevetési vonal |

### Miért a JV-mag, és nem az EAGLE

1. **Becsült, nem kalibrált paraméterek** — ez volt az eredeti csapatdöntés érve.
2. **Gazdagabb termelési oldal.** A JV három inputot ismer (tőke, munka,
   **import**), explicit helyettesítési rugalmasságokkal, és típusonként
   eltérő import-intenzitással (`aa_E`=0,45 vs `aa_D`=0,80). Az EAGLE
   kétinputos Cobb–Douglas-a (`y = a + α·k + (1−α)·n`) ezt **nem tudja
   kifejezni** — pedig az exportszektor import-intenzitása a magyar duális
   gazdaság központi ténye, tehát épp a projekt fő kérdéséhez tartozik.
3. **Ugyanazt tudja:** háromtípusos szerkezet (E/D/L), típusonkénti ár és
   kereslet, hitelhozzáférési (extenzív) margó — mind megvan.

### Hogyan jutottunk ide (négy lépcső, mind tesztelve)

| Lépcső | Fájl | Mit ad hozzá | BK |
|---|---|---|---|
| 1 | `jv_dsge_v06` | szegmens-specifikus tőkehozam | 18/18 |
| 2 | `jv_dsge_v07_3type` | három típus, közös ár | 18/18 |
| 3 | `jv_dsge_v08_3type_arak` | típusonkénti ár és kereslet | 18/18 |
| 4 | **`jv_dsge_v09_access`** | **hitelhozzáférési margó** | **18/18** |

A BK-teszten túl **független verifikáció** is lefutott (`t43`): szimmetria
(azonos paraméterek → azonos típusok, 1e−16), aggregációs azonosságok
(1e−19), nulla-sokk kontroll (pontosan 0), és egymásba ágyazás
(`ACCSCALE=0` → **pontosan** a v08). Részletek: `src/model/ellenorzes_3type.m`.

### ⚠ Amit NEM szabad közölni a modellből

- **Szegmens-szintű kibocsátást pontbecslésként.** Két horgonyzatlan
  paraméter (`eps_ces`, `ACCSCALE`) viszi a szektorális eredményt, és
  mindkettőn fordul az előjel. **Kettős küszöbformában** kell közölni.
- **A `t24`/`s_kkv` IO-alapú számokat** (autóipar „6% hazai köztes input")
  — a mérés hibás, lásd `docs/FIGYELMEZTETES_io_tabla_gyanus.md`.
- **A `t_S > t_L` transzmissziós feltevést** eredményként — nem
  azonosítható, lásd `docs/FIGYELMEZTETES_fo_allitas.md`.

**Ami robusztus:** az aggregált GDP-hatás. Minden lépcsőn és minden
paraméterezésen +0,27% … +1,04% között marad.

### Mit kell még kalibrálni

`docs/kalibracio_tabla.md` — mind a 66 paraméter, forrás szerint osztályozva.
A csapatnak szóló teendőlista: `docs/kalibracio_teendok_csapatnak.md`.

---

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
