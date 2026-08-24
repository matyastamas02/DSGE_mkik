# A BK-hiba független ellenőrzése (MPT-oldal)

*Dátum: 2026-08-24 · saját script, nyers Dynare `check`, a Codex helperje nélkül*

## Miért készült

A Codex-vonal jelentése (`2026-08-24_bk_hiba_javitas_es_jelolt.md`) egy súlyos
hibát állít: a `konvergalt` mező sosem volt Blanchard–Kahn-teszt, csak a
perfect-foresight solver numerikus státusza, és a terminális euró-rezsimben a
kalibrált `rho_acc = 0,9673` mellett a modellnek **nincs stabil megoldása**.

Ez átírja a fő számot, ezért **nem fogadtuk el ellenőrzés nélkül.** Külön
script készült (`scratchpad/bkchk/mpt_bk_*.m`), amely a `.mod` fájl model- +
`initval`/`endval`/`steady` részét változatlanul átemeli, és **saját `check;`**
hívást tesz a végére. Semmit nem használ a Codex infrastruktúrájából.

## 1. Az alapállítás: MEGERŐSÍTVE

| konfiguráció | instabil gyök | előretekintő | BK |
|---|---:|---:|---|
| kezdeti (`uni=0`), `rho=0,8500` | 13 | 13 | ✅ |
| kezdeti (`uni=0`), `rho=0,9673` | 13 | 13 | ✅ |
| **terminális (`uni=1`), `rho=0,8500`** | **13** | **13** | ✅ |
| **terminális (`uni=1`), `rho=0,9673`** | **15** | **13** | ❌ |

Dynare szó szerint: *"There are 15 eigenvalue(s) larger than 1 in modulus for
13 forward-looking variable(s) — The rank condition ISN'T verified!"*

**A hiba valós.** A perfect-foresight solver numerikus konvergenciája nem
bizonyítja, hogy a modellnek van érvényes racionális-várakozási megoldása.

## 2. Egy látszólagos ellentmondás, ami feloldódott

Az első biszekcióm a BK-határra **0,867027**-et adott, a Codex **0,928226**-ot
állít. Az eltérés oka nem hiba egyik oldalon sem: a `.mod` 459. sora szerint

```
@#if OPTEN >= 1
rho_acc = 0.9673;
@#endif
```

vagyis **az `OPTEN` ág maga állítja a `rho_acc`-ot**, a `-DRHOACC` pedig
felülírja. A saját szkennem `-DRHOACC`-kal kényszerítette az értéket, ezért
más ágon mértem, mint ők.

## 3. ÚJ TÉNY: a BK-határ ÁGFÜGGŐ

Ágankénti biszekció (ACCSCALE = 100, terminális rezsim):

| ág | BK-határ `rho_acc` |
|---|---:|
| `OPTEN=0` (JV-alap pénzügyi blokk) | **0,867027** |
| `OPTEN=1` | **0,928224** |
| `OPTEN=2` | 0,906174 |
| `OPTEN=3` | 0,867027 |

A Codex 0,928226-os száma az `OPTEN=1` ágra igaz — **2·10⁻⁶-on belül egyezik**
a saját mérésemmel (a biszekció tűrése). A jelentésük viszont **nem jelöli meg
az ágat**, és így félreérthető: az `OPTEN=0` alapág lényegesen **kevésbé
tűri** a hozzáférési perzisztenciát (0,867), mint amit a szám sugall.

⚠ **Dokumentációs teendő:** ahol a 0,928226 szerepel, oda ki kell írni, hogy
`OPTEN=1`. A SZINT-ŐR szabály szerint ehhez a négy számhoz őr is kell.

## 4. Mi következik ebből

1. A `rho_acc = 0,9673` **egyik ágon sem** használható a terminális
   rezsimben — mind a négy ág 15/13-at ad. Ez összhangban van azzal, hogy a
   0,9673 amúgy sem a modell dinamikus paraméterének becslése (lásd a
   korlátok-riport 9. pontját: a cégek 92,4%-a egyszer sem vált státuszt).
2. Az `A01` mostani szövege (`OPTEN=0` ág, +0,52%…+1,18%) **BK-érvényes
   tartományon áll** — a `rho_acc = 0,85` ott 13/13.
3. A hosszú távú access-hatás `1/(1−rho_acc)`-kal arányos, és a BK-határ épp
   ott van, ahol ez a hurokerősítés túl nagyra nő. A stabilitási határ tehát
   **nem numerikus műtermék, hanem a mechanizmus közgazdasági korlátja.**

## 5. Füstteszt

`148 rendben, 0 hiba` — a Codex jelentette értékkel egyezően, saját futtatásból.
