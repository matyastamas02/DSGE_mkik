# ⚠ FIGYELMEZTETÉS: az IO-alapú `t24` / `s_kkv` NEM használható

*2026-08-12 · Samu `10b_io_diagnosztika.py` szkriptje nyomán, saját
ellenőrzéssel megerősítve. **A gyökérokot még nem izoláltam** — de annyi
bizonyított, hogy a szám nem közölhető.*

## Mit érint

A `07_io_hazai_input_arany.py` → `t24_io_hazai_input.csv` mérés adja:

- az **`s_kkv = 0,05`** kalibrációt (`jv_dsge_v04/v05/v06`),
- a **„42% → 4,4%"** korrekciót a vertikális link hozzájárulására,
- és a **„duális gazdaság: autóipar 6,0% hazai köztes input"** eredményt,
  amit eddig a projekt legerősebb önálló empirikus megállapításának
  nevezünk (többek között a hibafeltárási naplóban és a v05-doksiban).

**Mindhárom ezen az egy mérésen áll, és a mérés nem áll.**

## A bizonyíték

Samu diagnosztikája (`10b_io_diagnosztika.py`) egy döntő tesztet javasol:
a köztes felhasználás hazai és import része össze kell adódjon a nemzeti
számlák P2-jére. Lefuttatva (Eurostat `naio_10_cp1620` / `cp1630` /
`nama_10_a64`, HU 2021):

| Ágazat | P2 (nemzeti számlák) | naiv dom+imp | arány |
|---|---:|---:|---:|
| C29 autóipar | 21 842,8 | 392,6 | **0,018** |
| C26 elektronika | 11 023,3 | 182,8 | **0,017** |
| C20 vegyipar | 5 300,5 | 162,5 | **0,031** |
| TOTAL | 175 719,9 | 15 043,1 | **0,086** |

Az arány ~1,00 lenne a helyes mérésnél. **Itt 1,8–8,6%** — vagyis a
mérésünk a tényleges köztes felhasználás alig pár százalékát fogja meg.

A szkript „szűrt" változata (hozzáadott-érték és aggregátum sorok nélkül)
**még rosszabb**: a hazai arány 0,0002-re, elektronikánál és vegyiparnál
pedig **negatívra** esik. Negatív hazai arány nem létezik → a szűrő sem jó.

### Saját, független ellenőrzés

A nyers JSON dimenziói: `['freq','unit','stk_flow','ind_use','cpa2_1','geo','time']`,
és a **`stk_flow` egyetlen kategóriája `TOTAL`** — tehát a `cp1620` tábla nem
„hazai", hanem *teljes* felhasználás. Ha így van, a hazai rész
`1620 − 1630`, nem `1620`. Ezt kipróbálva viszont **negatív** hazai értéket
kapunk (C29: 23,4 − 189,6 = −166,2), és a `TOTAL × CPA_TOTAL` sarok **0**-t
ad, pedig annak a legnagyobb számnak kellene lennie a táblában.

**Következtetés:** a hiba nem (csak) a hazai/teljes tábla felcserélése.
Vagy a JSON-stat lapos index dekódolása rossz (a `ind_use` és `cpa2_1`
tengely összekeveredhet), vagy nem a megfelelő táblát/dimenzió-szeletet
kérdezzük le. **A pontos ok még nyitott.**

## Amit ebből ÁLLÍTANI lehet, és amit nem

**Bizonyított:** a `t24` mérés hibás, tehát az `s_kkv = 0,05`, a
„42% → 4,4%" korrekció és a „6% hazai köztes input" **nem megalapozott**.

**NEM bizonyított**, melyik irányba téves. A naiv szám (0,0596) 1,8%-os
lefedettségen áll; a szűrt (0,0002) negatív értékeket ad. **Nem tudjuk,
hogy a valódi hazai arány magasabb vagy alacsonyabb.** Aki azt állítja,
hogy „akkor tehát erősebb a beszállítói link", ugyanazt a hibát követi el,
csak visszafelé.

## Ami ettől NEM változik

- Az **aggregált GDP-hatás** (+0,43% … +1,04%) robusztus az `s_kkv`
  ki-be kapcsolására is (a `-DNOVERT=1` ellenpróba régóta megvan).
- A `v06_3type` / `v07_access` vonal **nem használ `s_kkv`-t** — ott a
  szektorok közti kapcsolat nem ezen a paraméteren fut. Ez a jelenlegi fő
  vonal, tehát az érdemi eredményeket ez nem érinti.
- Az **E/D hozzáférési különbség** (61,9% vs 4,8%) az Opten-panelből jön,
  nem az IO-táblából — érintetlen.

## Teendő (sürgősségi sorrendben)

1. **Vissza kell vonni a „6% hazai köztes input" állítást** minden
   doksiból, amíg nincs javított mérés. Érintett:
   `2026-08-02_hibafeltaras_naplo.html`, `v05_szcenario_bovites.html`,
   `kkv_szegmentalas_layer.html`, `kkv_layer_eloadas_jegyzet.md`,
   `modell_verziok_osszefoglalo.md`, `src/model/README.md`,
   `jv_dsge_v05.mod` és `v06.mod` fejléc, `2026-08-12_haladas_a_zip_ota.html`.
   *(Ez a jelen dokumentum megírásakor MÉG NEM történt meg.)*
2. **A JSON-stat dekódolás ellenőrzése** egy ismert értékkel (pl. a
   `TOTAL × CPA_TOTAL` cellának a legnagyobbnak kell lennie). Ez fél óra,
   és eldönti, hogy dekódolási vagy táblaválasztási hiba.
3. **A KSH ÁKM használata az Eurostat helyett** — a magyar közzététel
   ágazati bontása és kódrendszere illeszkedik a nemzeti számlákhoz, ami
   pont a most bukó illesztési tesztet oldaná meg (119 ágazatból csak
   47-hez találunk kibocsátást).
4. Ha a javított arány érdemben más, **az `s_kkv` és a link-hozzájárulás
   újraszámolandó**, és a v05/v06 eredményei ennek megfelelően frissülnek.

## Módszertani tanulság

Ez a negyedik eset a projektben, ahol egy „adatolt" számról kiderült, hogy
nem áll (`t_S>t_L`, a támogatási ék, az access-margó, most az IO-arány).
A mintázat közös: **egyetlen mérésre épült egy erős állítás, keresztellenőrzés
nélkül.** Amit ebből szabályként érdemes bevezetni: minden kalibrációs
számhoz kell egy **független ellenőrző azonosság** (itt: `dom + imp = P2`),
és azt a scriptbe kell beépíteni, nem utólag elvégezni. Samu `10b`-je
pontosan ezt teszi — ezért találta meg.
