# A 2026-08-10-i csomag összevetése a hibanaplóval

*2026-08-12 · Samu `dsge_haladasi_jelentes_forrasanyag_2026-08-10` csomagjának
szisztematikus átvizsgálása a `docs/2026-08-02_hibafeltaras_naplo.html` és a
`docs/FIGYELMEZTETES_fo_allitas.md` minden megállapítása ellen. 44 fájl
(HTML-ből szöveg kinyerve), 14 célzott keresés.*

## A verdikt: nem ismételték meg a hibáinkat — beépítették a naplót

Ez az első átvizsgálás, ami **jó hírrel** tér vissza. Egyik dokumentált hiba
sem élt tovább:

| Hibanapló-megállapítás | Előfordul a csomagban? |
|---|---|
| Hibás felár-számok (−39,1 / −25,6 bp) | **nem** — egyetlen találat sem |
| Nem közölhető szegmens-beruházás (1,35% / 0,82% / 1,64×) | **nem** (csak CSV-adatban véletlen számegyezés) |
| Régi pass-through számok (0,299 / 0,652) | **nem** (csak a mi saját `FIGYELMEZTETES`-ünkben) |
| „az adat az ellenkezőjét mutatja" (túl erős verdikt) | **nem** — helyesen „0,26–2,75, semmi sem szignifikáns" |
| Téves magyarázat (támogatott/fix hitel nem követi a piacot) | **nem** |
| `TSCEN=3` mint önálló harmadik teszt | **nem** |
| Link-hozzájárulás 42% | **csak korrekcióként** („42% helyett 4,4%") |
| `s_kkv = 0,20` | **csak korrekcióként** („négyszeres túlkalibrálás") |
| 557–665 Mrd Ft költségvetési számként | **nem** |

## Amit ezen túl tettek: a napló beépült a v07 specifikációba

A `2026-08-05_modell_specifikacio_v07.md` gyakorlatilag **válasz a
hibanaplóra**, három konkrét ponton:

**1. Nem azonosított paraméterek táblája, közlési szabállyal.** Külön
táblázat arról, melyik paraméter miért nem azonosított és hogyan közöljük:
`t_sov`/`t_bank` → *„becsült arány 0,26–2,75, semmi sem szignifikáns →
szimmetrikus alap + sáv"*; `χ_j` aszimmetria → *„szimmetrikus alap + scan"*.

**2. A küszöbforma átvéve, és a naplónak attribuálva:**

> *„**A küszöbforma a napló saját megoldása** (2. opció, »Achilles-sarok«): a
> nem azonosított paraméter a **bemenetből a kimenetbe** kerül, és a kritika
> (»ezt beírtad, nem levezetted«) értelmét veszti."*

**3. A `s_kkv`/IO-korrekció beépített ellenőrzésként.** A 4.3 szakasz a
42% → 4,4% javítást és a négyszeres túlkalibrálást **a v07 `Γ`-blokk
korlátjaként** használja: *„a `Γ` sorösszegei ezekre az ÁKM-értékekre kell
hogy illeszkedjenek — ez az imputáció beépített ellenőrzése."*

A fő haladási jelentés pedig mindhárom strukturális figyelmeztetést szó
szerint idézi (χ-aszimmetria, reallokációs maradék, `psi_i` torzítás), és
korrektül hozzáteszi, hogy ezek nem vihetők át közvetlenül az új
`v06_3type`/`v07_access` vonalra.

## AMIT ALÁBECSÜLTEM: a v06 az ő analitikus sejtésüket igazolta

A v07-specifikáció 6.3 szakasza a `χ`-előjel problémára ezt írja
**2026-08-05-én**:

> *„**Analitikus sejtés (ellenőrizendő):** ez a keresztmetszeti összehasonlítás
> nagyrészt a **közös `rk`** következménye. Ha `rk` közös, akkor steady
> state-ben `efp_j` mindenkire azonos (a napló t21 táblája ezt 15 értékes
> jegyig mutatja)…"*

**A `jv_dsge_v06.mod` (2026-08-11) pontosan ezt a sejtést igazolta
empirikusan.** `rk_S`/`rk_L` bevezetésével `efp_S ≠ efp_L` már steady
state-ben is (−1,01 bp), és 18/18 kombinációban stabil marad. A v06-ot
átcímkéztem „a v05 belső javítására", és az akkori megfogalmazásom
alábecsülte: **nem csak karbantartás, hanem egy nyitva hagyott analitikus
sejtés kísérleti eldöntése** — és a válasz igen, a `χ`-patológia nagyrészt a
közös `rk` következménye volt. Ez a v06 fejlécében és a changelogban most
javítva.

Ami a v06-ról továbbra is áll: a méret/piac összecsúsztatást **nem** oldja
meg (azonosítással működik), tehát a szegmentálási kérdés válasza továbbra is
a `v06_3type`/`v07_access` vonal.

## Amit ŐK találtak, és amit én nem jeleztem

A jelentésük 3.2 szakasza a saját új modelljükben szúrja ki ugyanazt a
mintázatot:

> *„A hozzáférési paraméterek (`lambda_acc_D=2,5` vs. `lambda_acc_E=2,0`) a
> hazai KKV-t erősebben kedvezményezik — ez jelenleg kalibrált feltevés,
> nincs mögötte közvetlen empirikus forrás, miközben pont ez adja a fő
> eredményt."*

És általános szabályt javasolnak belőle: minden olyan paraméter, ahol
KKV/nagyvállalat aszimmetria van kalibrálva hivatkozott források nélkül,
gyanúsnak tekintendő. **Ez helyes, és pontosan a `psi_i_S < psi_i_L` és a
`t_S > t_L` betegségének a felismerése a saját munkájukban.**

### Két további aszimmetria, amit ehhez hozzá kell tenni

A szabályt végigvezetve a `v07_access`-ben **három** horgonyzatlan,
KKV-t kedvezményező aszimmetria van, nem egy:

1. `lambda_acc_D = 2,5 > lambda_acc_E = 2,0` — ők jelezték;
2. `omega_acc_D = 0,45 > omega_acc_E = 0,35` — **ugyanaz a mintázat, nem jelezve**;
3. **`acc_L` egyáltalán nem létezik** a modellben (`grep`: 0 előfordulás) — a
   nagyvállalatnak nincs access-margója. Ez a legnagyobb egyetlen feltevés,
   mert ez viszi a teljes szektorális átfordulást.

A 3-as szokásos indoklása, hogy a nagyvállalat nincs hitelkorlátozva. **A
saját adatunk ezt csak részben támogatja:** az `s14` szerint a nagyvállalati
hozzáférés **43,4%**, ami *alacsonyabb*, mint az export-KKV-k 61,9%-a. Ez nem
bizonyítja, hogy a nagyvállalat korlátozott (valószínűbb, hogy nem is
*kér* hitelt), de azt jelenti, hogy a „nagyvállalatnak mindig van hitele"
egyszerű történet **nincs benne az adatban**. Amit az adat erősen támogat, az
az **E/D szétválasztás** (61,9% vs 4,8%, 13-szoros), nem a méret szerinti
access-dichotómia.

## Összegzés a további munkához

1. **A hibanapló-fegyelem átment a másik vonalra is** — ez a legfontosabb.
   Nem kell újra végigvinni a korrekciókat.
2. **Az `omega_acc` aszimmetria és az `acc_L` hiánya** ugyanúgy jelölendő,
   mint a `lambda_acc` — a saját szabályuk szerint.
3. **A v06 értéke javítva** a changelogban: az ő sejtésük igazolása.
4. Az `s14` eredménye (az `ACCSCALE` magyar adatból nem horgonyozható)
   közvetlenül a v07 4.3/6.3-as logikájába illeszkedik: a küszöbforma mellé
   oda kell írni, hogy a küszöbértéket **jelenleg nem tudjuk megmondani**.
