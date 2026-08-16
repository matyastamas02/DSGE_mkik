# src

Dynare `.mod` fájlok és Python/MATLAB scriptek. A modell teljes kódja itt van.
Az `output/` minden eleme az itteni scriptekből reprodukálható legyen.

## Hol mi van

| Mappa | Mi van benne | Mikor nyúlsz hozzá |
|---|---|---|
| [`1_adat/`](1_adat/) | nyers → tisztított panel, leíró statisztika, BUBOR-segéd | ha új adat érkezik |
| [`2_empirikus/`](2_empirikus/) | becslés és **horgonyzás** a panelből (Opten, IO, MNB) | ha egy paramétert adatból akarsz megalapozni |
| [`3_abrak/`](3_abrak/) | ábra- és leképezés-generálók a modell kimenetéből | ha ábra kell a tanulmányba |
| [`4_infra/`](4_infra/) | füstteszt, regiszter-építő, **állapotlap-generátor** | push előtt, és minden eredmény után |
| [`modell/`](modell/) | a Dynare-modellek, **vonalanként** | modellezéskor |
| [`app/`](app/) | Streamlit-app | ha az app kell |

A `modell/` négy vonala: [fő](modell/1_fo_vonal_jv/) ·
[referencia](modell/2_referencia_eagle/) · [archív](modell/3_archiv_korai_jv/) ·
[app](modell/4_app/). Mindegyikben `README.md` + `.mod` fájlok + `futtato/`.

## Útvonal-konvenció (2026-08-16 óta)

**Minden script a saját helyéből számolja a repo gyökerét** — felfelé megy,
amíg meg nem találja a `CLAUDE.md`-t:

```matlab
repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
```

```python
REPO = next(p for p in Path(__file__).resolve().parents if (p / "CLAUDE.md").exists())
```

**Ne írj `fileparts(pwd)`-t vagy `parents[1]`-et** — az feltételezi, hogy a
script hány szint mélyen van, és a következő átrendezésnél elszáll. A
modell-futtatók emellett `cd`-znek a saját `.mod` mappájukba, mert a Dynare
a munkakönyvtárhoz képest keresi a modellt.

## Két belépési pont

```bash
matlab -batch "cd('src/4_infra'); smoke_test"     # 88 ellenőrzés, push előtt KÖTELEZŐ
python src/4_infra/13_allapotlap.py               # ALLAPOT.md újragenerálása
```

## Névadási szabályok

- **MATLAB-script nem kezdődhet számmal** (a `run()` a névvel hívja) → az
  `s` előtag a konvenció (`s06`…`s15`). A `01`–`14` számúak **Python**-scriptek.
- Ugyanezért **a `.mod` fájlok sem kaphatnak számelőtagot**: a Dynare a
  modellnévből MATLAB-csomagot generál. A sorrendet a mappanevek viszik.
- Lokális függvény a MATLAB-script **végén** legyen, ne középen.
