# BK-hiba: diagnózis, javítási infrastruktúra és modelljelölt

*Dátum: 2026-08-24 · helyi Codex-munka · GitHub-írás nélkül*

## Vezetői összefoglaló

A korábbi `konvergalt` mező nem Blanchard–Kahn-teszt volt, hanem kizárólag
a perfect-foresight solver numerikus státusza. A fő `t47` rács ezért
36/36 esetben megoldódik, miközben a terminális `uni=1` lokális rezsimben
csak 9/36 eset BK-valid. Az `OPTEN=0` ág 9/9 pontján 13 instabil gyök jut
13 előretekintő változóra; az `OPTEN=1/2/3` ágak 27/27 pontján 15 jut
13-ra. Az inicialis `uni=0` rezsim mindegyik vizsgált ágban BK-valid.

A biztosan elfogadható javítás elkészült: a futtatók most külön tárolják a
PF-solver és a valódi Dynare `check` eredményét, a táblák és ábrák csak
BK-valid pontokat közölnek, a füstteszt pedig pontos gyökszámokat őriz. A
fő modell gazdasági egyenletei nem változtak.

Egy elkülönített szerkezeti jelölt is elkészült. Az `(1-rho_acc)`
normalizálás stabilizálja a magas-rho terminális rezsimet, de **nem semleges
javítás**: `rho_acc=0,9673` mellett ugyanazt adja, mint a régi modell
`LAMSCALE=3,27` értéken, vagyis 96,73%-kal gyengíti az access-hurkot. A
lambda visszaskálázása visszahozza az eredeti dinamikát és a BK-hibát.
Ezért ezt csak újrabecslendő szerkezeti érzékenységi változatként javaslom,
nem új alapmodellként.

## Bizonyított diagnózis

- A perfect-foresight státusz és a BK-feltétel két külön fogalom.
- A hiba a terminális eurórezsimhez kötődik; a kezdeti rezsimben nincs jelen.
- A kritikus mechanizmus az E/D access–beruházás–EFP visszacsatolás.
- `ACCSCALE=100` mellett a BK-határ `rho_acc ≈ 0,928226`.
- `rho_acc=0,9673` mellett a közös access-skála határa
  `ACCSCALE ≈ 79,5075`, az ennek megfelelő skálaszorzat kb. `6321,44`.
- A `rho_acc=0,9673` nem empirikus dinamikus szegmens-rho és nem alsó
  korlát. A négy teljes évvel rendelkező cégek 92,4%-a egyszer sem váltott
  hitelstátuszt, ezért a mutató főként fix cégek közötti heterogenitást mér.

## Elkészült helyi módosítások

### BK-infrastruktúra

- `src/4_infra/bk_check_metrics.m`: új, újrahasználható Dynare `check`
  helper.
- `src/4_infra/bk_diagnosztika_v09.m`: külön diagnosztika rezsim-, hurok-
  és stabilitási határvizsgálattal.
- A `stress_jv_access_v09.m`, `stress_opten_v09.m`,
  `sens_lam_om_v09.m` és `dekomp_edl_v09.m` új mezői:
  `solver_ok`, `bk_check_ok`, `bk_ok`, `ervenyes`, `n_forward`,
  `n_unstable`, `bk_qz_criterium`, `bk_info_code`,
  `nearest_unit_complex`.
- A legacy `konvergalt` mező megmaradt kompatibilitásra, de már mindenhol
  PF-solver státuszként van dokumentálva.
- A régi `t40`/`t41` futtatók és őrök félrevezető „BK 18/18” címkéje
  PF-solver 18/18-ra lett javítva; ezekhez valódi történeti BK-audit még
  nem készült.

### Kimenetek és állítások

- `t47`: PF 36/36, terminális BK 9/36.
- `t49/t51`: minden közölt küszöb BK-valid; `ACCSCALE=100` GDP csak
  `rho_acc=0,85` és `0,90` mellett közölhető.
- `t52b/t52d`: a lambda–omega küszöbkontúr és mindkét diagonális küszöb
  BK-valid. A 2500-as szorzatkontroll mind az 5 pontja BK-valid.
- `t53b`: 10/10 dekompozíciós küszöbpont BK-valid.
- `t53c`: PF/check 45/45, terminális BK 0/45; ezért az `OPTEN=1`,
  `ACCSCALE=100` pontszintek visszavonva.
- A közölhető főmodellsáv az `OPTEN=0` ágon +0,52%…+1,18% (9/9 BK-valid).
- Az állítás- és paraméterregiszter, az `ALLAPOT.md`, az output-index,
  valamint a kapcsolódó eredmény- és módszertani dokumentumok frissültek.

## Elkülönített modelljelölt

Fájl: `src/4_infra/bk_candidate_compare_v09.m`. A script ideiglenes
modellmásolaton dolgozik; a fő `.mod` fájlt nem írja át.

Teljes eredmény:

| konfiguráció | PF | kezdeti BK | terminális BK | gyök/előretekintő |
|---|---:|---:|---:|---:|
| `rho=.85`, legacy | 9/9 | 9/9 | 9/9 | 13/13 |
| `rho=.9673`, legacy | 9/9 | 9/9 | 0/9 | 15/13 |
| `rho=.9673`, `(1-rho)` normalizált | 9/9 | 9/9 | 9/9 | 13/13 |

Mind a 36 jelölt PF-futás megoldódott. A regressziós őrök numerikus nullán
belül vannak; az explicit `RHOACC` értéket az `OPTEN=0/1/2` ágak nem írják
felül. A diagnosztikai CSV-k:

- `output/diagnostics/bk_candidate_v09/bk_candidate_matrix.csv`
- `output/diagnostics/bk_candidate_v09/bk_candidate_rho_regression.csv`
- `output/diagnostics/bk_candidate_v09/bk_candidate_tests.csv`

## Ajánlás Claude-nak

1. Fogadja el a BK-mérési infrastruktúrát, a runner-sémát, a BK-szűrt
   outputokat és a dokumentációs korrekciókat.
2. Ellenőrizze, hogy a fő `jv_dsge_v09_access.mod` nem-komment gazdasági
   tartalma változatlan; a mostani diffben csak kommentkorrekció van.
3. Az `(1-rho)` normalizálást **ne** tegye alapértelmezetté újrabecslés és
   gazdasági azonosítás nélkül. Ha megtartja, külön `ACCNORM` érzékenységi
   ágként tartsa.
4. A `rho_acc`-ot tartsa D kategóriás, horgonyzatlan paraméternek; a
   0,9673 csak magas-rho érzékenységi pont.
5. Commit előtt futtassa a teljes füsttesztet és ellenőrizze a három
   modelljelölt-CSV-t. A jelenlegi helyi eredmény: **148/148 rendben**.
6. Külön későbbi feladatként valódi Dynare `check` audit kell a v06–v08
   történeti 18/18 rácsokra; most csak a téves BK-címkéket vontuk vissza.

## Verifikáció és munkafolyamat

- Modelljelölt: minden beépített regressziós és BK-assert teljesült.
- Python-ábrák: teljes rács-, egyediség-, solver- és BK-sémaellenőrzéssel
  újragenerálva.
- MATLAB statikus ellenőrzés: lefutott; két meglévő globálisváltozó-
  figyelmeztetés, szintaktikai hiba nélkül.
- Teljes füstteszt: **148 rendben, 0 hiba**.
- Állapotlap: 37 állítás, 91 paraméter, 148 őr.
- Output-index: 76 tábla, 28 ábra, 0 árva, 0 néma, 0 hiányzó.
- A Codex nem commitolt, nem pusholt, nem hozott létre PR-t, és semmilyen
  GitHub-erőforrást nem módosított. A review, commit és push Claude feladata.
