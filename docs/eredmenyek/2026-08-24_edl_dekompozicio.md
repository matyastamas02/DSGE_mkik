# E/D/L dekompozíció: a KKV-eredmény nem technológiai műtermék

*2026-08-24 · a [korlátok-riport](../terv/2026-08-21_korlatok_es_teendok.md) 2. teendője (7. szakasz)*
*Kód: `src/modell/1_fo_vonal_jv/futtato/dekomp_edl_v09.m` · kapcsoló: `-DDECOMP=0..4`, `-DDECOMPW=0|1`*
*Táblák: `t53` (ágak), `t53b` (küszöb), `t53c` (BK-stressz), `t53d` (regresszió)*

> **KORREKCIÓ — 2026-08-24 (valódi Blanchard–Kahn-audit).** A történeti
> `konvergalt` mező csak a perfect-foresight solver státusza volt. A `t53`
> `ACCSCALE=100` rácsa PF/check szerint 45/45 esetben lefut, de a
> **terminális lokális BK-feltétel 0/45 esetben teljesül**. Emiatt a lent
> közölt `ACCSCALE=100` GDP- és szegmensszintek, továbbá az „öt ágon
> pozitív” pontbecsléses állítás nem interpretálható modell-eredményként.
> A döntő küszöbvizsgálat viszont fennmarad: a `t53b` mind a 10/10
> küszöbpontja BK-valid, ezért a **22,36 / 22,62 / 22,95** összevetés és az
> ebből levont, küszöbformájú technológiai-robosztussági következtetés
> érvényes. Az alábbi eredeti szöveget történeti nyomként meghagyjuk; a
> korrekció minden 45/45-ös BK- és `ACCSCALE=100`-as szintállítást felülír.

---

## A referee-kérdés, amire ez válaszol

A három típus **eleve különböző technológiát kapott** — a `.mod` maga
mondja ki: *„Ez ATVITEL, nem becsles."*

| | `zeta_j` (tőkehányad) | `aa_j` (munka a munka+import kompozitban) |
|---|---:|---:|
| E | 0,14 | 0,45 |
| D | 0,17 | 0,80 |
| L | 0,155 | 0,60 |

Ha az E és a D máshogy reagál, abban benne van az is, hogy **mi adtunk
nekik más termelési paramétert**. A bíráló első kérdése ez lesz:

> *„Show me that your main conclusion is not an artifact of the E/D/L
> calibration."*

---

## A módszer

`-DDECOMP` egyszerre **egy** heterogenitás-dimenziót hagy meg, a többit
közös értékre állítja. A közös érték alapértelmezésben a **méretsúlyozott
(`om_j`) átlag** — az hagyja változatlanul az aggregált technológiát, tehát
a scan tisztán az *átrendeződést* méri, nem egy szint-eltolódást.
A `-DDECOMPW=0` (egyszerű számtani átlag) ellenpróba.

| ág | mi marad heterogén |
|---|---|
| **A** (`=1`) | csak `phi_j` (piaci orientáció) |
| **B** (`=2`) | csak a pénzügyi paraméterek (`chi`, `lev`, `psi`, E–D access) |
| **C** (`=3`) | csak `aa_j` (import-intenzitás, duális szerkezet) |
| **D** (`=4`) | minden **technológiai** paraméter azonos (`zeta_j`, `aa_j`) |

**A döntési szabályt előre kimondtuk** (hogy ne utólag válogassunk):
ha a KKV-eredmény a **B** és a **D** ágon is megvan, akkor finanszírozási
heterogenitásról szól; ha csak az **A**/**C** ágon, akkor technológiai
műtermék.

---

## Az eredmény

### Küszöbformában — ez a döntő tábla (`t53b`, OPTEN=1)

| ág | küszöb | a 0-ághoz képest |
|---|---:|---:|
| **0 alap** (minden heterogén) | **22,36** | 1,00× |
| **B — csak pénzügyi** | **22,62** | **1,01×** |
| **D — technológia azonos** | **22,95** | **1,03×** |
| A — csak `phi_j` | 4,48 | 0,20× |
| C — csak `aa_j` | 1,61 | 0,07× |

> **A teljes technológiai heterogenitás kivétele a küszöböt 3%-kal mozdítja
> el. Csak a pénzügyi heterogenitást meghagyva 1%-kal.** A KKV-eredmény
> tehát gyakorlatilag teljes egészében **finanszírozási** eredetű.

### `ACCSCALE=100` pontdiagnosztika (`t53`) — nem közölhető modell-eredmény

A rács minden pontján lefut a perfect-foresight solver, de az
`OPTEN=1`, `rho_acc=0,9673` terminális rezsimben mind a 45 kombináció
BK-hibás: 15 instabil gyök jut 13 előretekintő változóra. Emiatt a régi
GDP-, `y_E`, `y_D`, `y_L` és „KKV−L” pontértékeket visszavontuk.

A súlyozási implementáció ellenpróbája BK-valid `OPTEN=0` ágon fut: a D
ág súlyozott és számtani átlagos változata rendre 1,4144709 és 1,4153392
százalékpontos KKV−L eltérést ad (kb. 0,061% relatív különbség). Ez
implementációs őr, nem az `OPTEN=1`, `ACCSCALE=100` pont igazolása.

### BK-audit (`t53c`)

**45/45 solver-sikeres, 0/45 terminálisan BK-valid** (5 ág × 3 SCENARIO ×
3 TSCEN). Minden pontban `n_forward=13`, `n_unstable=15`.

---

## Két értelmezési óvatosság, amit nem hallgatunk el

### 1. Az A és a C ág NEM „csak technológia" — mechanikusan erősebbek

Az A és a C ág a *pénzügyi* blokkot is közös értékre állítja, és ez az
átlagolás **felviszi** az E típus access-rugalmasságát (`omega_acc_E`
0,350 → 0,392, `lev_E` 1,94 → 2,12). Az alacsonyabb küszöbük tehát részben
mechanikus, nem tiszta „a technológia önmagában" hatás.

Ezért a **tiszta összevetés a 0 ↔ D és a 0 ↔ B**, és a következtetést is
csak ezekre alapozzuk.

### 2. Az `ACCSCALE=100` GDP-sáv nem vethető össze az `A01` állítással

A dekompozíciós rács 45 pontja terminálisan BK-invalid, ezért az ezekből
képzett GDP-sávokat sem az `A01` állítással, sem egymással nem hasonlítjuk
össze. A dekompozíció érvényes következtetése kizárólag a `t53b` tíz,
egyenként BK-valid küszöbpontjára épül.

### 3. Amit a scan NEM válaszol meg

A B ág az `omega_acc_L = 0` feltevést **nem** tudja semlegesíteni — a
nagyvállalatnak definíció szerint nincs `acc`-egyenlete. Az továbbra is
külön teendő (korlátok-riport 4. pont), és továbbra is **ez a legnagyobb
egyetlen feltevés**.

---

## A közlendő mondat

> A KKV-előny nem a technológiai kalibráció műterméke. Ha a három típus
> **minden technológiai paraméterét azonosra** állítjuk (`zeta_j`, `aa_j`
> méretsúlyozott átlagra), az eredmény küszöbe 22,36-ról 22,95-re
> mozdul — 3%-os elmozdulás. Ha **csak a pénzügyi heterogenitást**
> hagyjuk meg, 22,62 — 1%. Az eredményt tehát a finanszírozási
> heterogenitás viszi, nem a termelési oldal. A következtetés a tíz
> BK-valid küszöbponton áll; az `ACCSCALE=100` melletti 45 pontból álló
> szintrács terminálisan BK-invalid, ezért abból pontértéket nem közlünk.

---

## Regressziós őr

A `-DDECOMP=0` ág (OPTEN=0, SCENARIO=1, TSCEN=3) a tárolt `t44`
baseline-t adja vissza, eltérés < 1e−9 (`t53d`). Az őr a füsttesztben fut.

*(Az első írásban ez az ellenőrzés OPTEN=1-gyel futott, és „eltört"
üzenetet adott — a különbség pont az OPTEN 0→1 lépés volt, nem a
`DECOMP` kapcsoló. Javítva.)*
