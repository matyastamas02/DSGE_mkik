# Az Opten-panel alapú újrakalibráció eredménye — 2026-08-16

*A [`kalibracio_teendok_csapatnak.md`](kalibracio_teendok_csapatnak.md) 1.
prioritása. 14 paraméter átkerült „átvett induló"-ból „saját adatból
kalibrált"-ba. Kód: `src/s15_opten_kalibracio.m` (számolás) és
`src/model/stress_opten_v09.m` (modellhatás). Táblák: `t46`–`t49b`.*

---

## 1. Mi történt, egy bekezdésben

A fő modell (`jv_dsge_v09_access`) 14 típus-paramétere a csapattárs
`kkv_dsge_v07_access`-éből átvett **induló** érték volt — a saját `.mod`-juk
is így jelölte: *„Ezek indulok: empirikus ujrakalibracio kell."* Mind a 14
kiszámolható volt a már meglévő Opten-panelből (148 225 cég-év, 37 805 cég,
2021–2024, 10+ fős cégek), külső adatkérés nélkül. **Két érték
megerősítést nyert, egy feltevés megdőlt, egy paraméter pedig a vártnál
jóval nagyobbat mozdít a modelleredményen.**

A repo szabálya szerint (`CLAUDE.md`, munkamódszer 4.) az új értékek
**makró-kapcsolóval** kerültek be, nem felülírással:

| Kapcsoló | Mit csinál |
|---|---|
| `-DOPTEN=0` | átvett induló értékek — **alapértelmezés**, minden korábbi eredmény változatlanul reprodukálható |
| `-DOPTEN=1` | Opten-panel, ALAP szegmensdefiníció (`E` = bármilyen pozitív export; azonos az `s14`-gyel) |
| `-DOPTEN=2` | Opten-panel, `export_arany ≥ 25%` definíció |
| `-DOPTEN=3` | **csak** a `rho_acc` horgony — dekompozíciós ág |
| `-DRHOACC=<x>` | a `rho_acc` közvetlen scanelése |

---

## 2. Amit az adat MEGERŐSÍT

| Paraméter | Átvett érték | Opten-panel | Eltérés |
|---|---:|---:|---:|
| `phi_L` (nagyvállalati exportárbevétel-arány) | 0,365 | **0,3649** | 0,04% |
| `delta` (negyedéves értékcsökkenés) | 0,0250 | **0,0242** | 3,3% |

A `phi_L` egyezése négy tizedesig azt jelenti, hogy **az átvett érték
nagy valószínűséggel már ebből a panelből származott** — vagyis független
próbán visszajött. A `delta` esetében a panel éves aggregált rátája 9,33%
(értékcsökkenés / nyitó tárgyi eszközök), ami negyedévesre 0,0242.

*Ez a két sor önmagában is hozadék: eddig nem tudtuk, hogy ezek a számok
honnan jöttek.*

---

## 3. Amit az adat MEGCÁFOL — `lev_E ≠ lev_D`

A teendőlista külön nevesítette: a `lev_E = lev_D = 1,6` **kényszerített
egyenlőség**, és 13-szoros hitelhozzáférési különbség mellett (61,9% vs
4,8%, `s14`) valószínűtlen, hogy a tőkeáttételük azonos legyen.

| Mérték | `lev_E` | `lev_D` | `lev_L` |
|---|---:|---:|---:|
| eszközök / saját tőke (BGG-fogalom, medián) | **1,939** | **1,719** | **2,337** |
| 1 / (1 − medián(kötelezettségek/eszközök)) | 1,684 | 1,579 | 1,812 |
| jelenlegi modellérték | 1,6 | 1,6 | 1,85 |

**Az IRÁNY mérőfüggetlen:** mindkét mérték szerint `lev_E > lev_D`, és
mindkettő szerint `lev_L` a legnagyobb. **A SZINT viszont mérőfüggő** — a
két mérték azért tér el, mert a `kötelezettségek` oszlop nem tartalmazza a
passzív időbeli elhatárolásokat és a céltartalékot, a saját tőke viszont
ezekkel is szemben áll. **Ezért csak az irányra szabad hivatkozni**, a
szintre sávot kell adni: `lev_E ∈ [1,68; 1,94]`, `lev_D ∈ [1,58; 1,72]`.

---

## 4. A legnagyobb hatású tétel — `rho_acc`

A hozzáférési állapot perzisztenciája a `van_hitel` átmenet-mátrixból,
kétállapotú Markov-láncként (`t46c`):

- `p11` = P(van hitel *t*-ben | volt hitel *t−1*-ben) = **0,8955**
- `p01` = P(van hitel *t*-ben | nem volt *t−1*-ben) = **0,0202**
- ρ_éves = `p11 − p01` = **0,8754** (n = 110 350 cég-év pár)
- ρ_negyedéves = 0,8754^(1/4) = **0,9673** — a korábbi 0,85 helyett

**Miért számít ennyire:** a modellben a hosszú távú hozzáférési hatás
`acc_LR = −λ_acc/(1−ρ_acc)·efp`, tehát `1/(1−ρ)`-val arányos. Ez
**6,67-ről 30,6-ra** nő, azaz **4,6×**.

### A dekompozíció (`t48b`)

| Ág | `y_D ≥ y_L` | súlyozott KKV `≥ y_L` | `y_E ≥ y_L` |
|---|---:|---:|---:|
| `-DOPTEN=0` (átvett) | 22,9 | **36,5** | 61,7 |
| `-DOPTEN=3` (csak `rho_acc`) | 10,7 | **17,0** | 28,9 |
| `-DOPTEN=1` (teljes Opten) | 10,3 | **22,3** | 31,0 |

A `0 → 3` lépés tisztán a perzisztencia-horgony hatása: **a küszöb
felezőnél is jobban esik.** A `3 → 1` lépés (17,0 → 22,3) a súlyok
átrendeződése: az ALAP definícióban az `E` szegmens a KKV-blokk 58%-a lesz
a korábbi 33% helyett, és az `E`-nek magasabb a küszöbe — tehát a
súlyozott blokk küszöbe visszamászik.

### És amiért ezt scannel kell közölni, nem pontbecslésként (`t49`)

`1/(1−ρ)` a ρ → 1 határon robban. Egy ilyen paraméterre egyetlen szám nem
elég — pláne, hogy a mi horgonyunk **alsó korlát** (lásd 6.4):

| `rho_acc` | 0,85 | 0,90 | 0,93 | 0,95 | **0,9673** | 0,98 |
|---|---:|---:|---:|---:|---:|---:|
| `1/(1−ρ)` | 6,7 | 10,0 | 14,3 | 20,0 | **30,6** | 50,0 |
| küszöb (súlyozott KKV ≥ L) | 47,8 | 39,1 | 32,6 | 27,6 | **22,3** | 17,5 |
| GDP @ `ACCSCALE=100` | 0,66% | 0,77% | 0,91% | 1,07% | **1,34%** | 1,75% |

Monoton, meredek, és a horgonyunk a tábla jobb oldalán van.

---

## 5. ⚠ Amit ezzel vissza kell vonni: a „+0,27…+1,04%" sáv

A projekt eddig azt közölte, hogy az aggregált GDP-hatás **minden lépcsőn
és minden paraméterezésen** +0,27% és +1,04% közé esik, és hogy ez a
robusztus eredmény, szemben a szegmens-szintűvel.

**Ez a horgonyzott `rho_acc` mellett nem tartható** (`t47`):

| Ág | aggregált GDP-sáv (SCENARIO 1–3 × TSCEN 1–3) |
|---|---|
| `-DOPTEN=0` (átvett) | +0,52% … +1,18% |
| `-DOPTEN=3` (csak `rho_acc`) | +0,92% … **+2,89%** |
| `-DOPTEN=1` (teljes Opten) | +0,76% … **+2,03%** |
| `-DOPTEN=2` (küszöb-25% def.) | +0,77% … +2,29% |

**Az irány nem változott, a szélesség igen.** A helyes megfogalmazás
mostantól: *az aggregált hatás előjele és nagyságrendje robusztus
(+0,3 … +2,9%), de a felső vég a hozzáférési csatorna perzisztenciáján
múlik.* Füstteszt-őr rögzíti, hogy ez tudatos változtatás, nem elcsúszás.

---

## 6. Korlátok — ezek nélkül a számokra ne hivatkozzunk

### 6.1 A mikrocégek hiánya blokkolja az `om_j`/`shl_j` átvételét

A panel a **10+ fős** kört fedi. Az ebből számolt súlyok tehát a 10+
populáción *belüli* részesedések:

| | `om_E` | `om_D` | `om_L` | `shl_E` | `shl_D` | `shl_L` |
|---|---:|---:|---:|---:|---:|---:|
| jelenlegi | 0,18 | 0,37 | 0,45 | 0,20 | 0,50 | 0,30 |
| Opten (10+) | 0,256 | 0,184 | 0,560 | 0,157 | 0,378 | **0,466** |

A `shl_L` 0,30 → 0,466 ugrás nagy részét vélhetően **a hiányzó mikrokör
magyarázza**, nem mérési hiba: ha a jelenlegi 0,30 a teljes gazdaságra
vonatkozik, akkor a két szám **nem ugyanazt méri**, tehát nem cserélhető
fel. **Ezért az `-DOPTEN` alapértelmezése `0` maradt.** Feloldás: KSH /
Eurostat SBS méretkategóriás bontás (új 2.5-ös tétel a teendőlistán,
fél nap).

### 6.2 A `phi_D` definíciófüggő

Az ALAP definícióban (`E` = bármilyen pozitív export) a `D` szegmens épp a
nem-exportáló cégeké, tehát `phi_D = 0` **definíció szerint**, nem mérésből.
A `KUSZOB25` variánsban (`E` = `export_arany ≥ 25%`) `phi_D = 0,0227` és
`phi_E = 0,691` — ez utóbbi közelebb áll a modell „export-orientált KKV"
fogalmához, mint az ALAP 0,376-ja.

**BK-következmény, amit külön ellenőriztünk:** `phi_D = 0` mellett `wx_D = 0`,
de ez **nem** töri el a modellt — az `x_D`-t a saját exportkereslet-egyenlete
továbbra is meghatározza, csak az aggregátumokba nem számít bele. 36/36
BK-stabil.

### 6.3 A `lev_j` könyv szerinti

A BGG `lev` piaci értékelésű `K/N`; a panelből könyv szerinti eszköz/saját
tőke jön. Ez a szokásos közelítés, de nem azonos a modell fogalmával. A
negatív saját tőkéjű cégek kiestek a mediánból.

### 6.4 A `rho_acc` cég-szintű, a modellé szegmens-szintű

Amit mértünk: mennyire perzisztens **egy cég** hitelhozzáférési státusza.
Amit a modell használ: mennyire perzisztens **a szegmens** hozzáférési
szintje. Az aggregált arány rendszerint perzisztensebb az egyedinél — az
`s14` szerint a szegmens-arányok 4 év alatt **1 pontnál kevesebbet**
mozdultak, ami közel egységgyökű aggregált folyamatra utal.
**Tehát a 0,9673 alsó korlát, nem pontbecslés** — és épp abba az irányba
mutat, ahol a modell a legérzékenyebb. Ezért a `t49` scan.

### 6.5 A `delta` könyv szerinti

Adótörvényi kulcsok szerinti értékcsökkenés, nem gazdasági amortizáció.
Hogy a kettő itt mégis 3%-on belül egyezik a konvencionális 10%/év
értékkel, inkább szerencse, mint módszertani érv.

---

## 7. Verifikáció

| Ellenőrzés | Eredmény |
|---|---|
| Regresszió: `-DOPTEN=0` == a tárolt `t44` baseline | eltérés **0,0e+00** |
| BK-stabilitás: 4 ág × 3 SCENARIO × 3 TSCEN | **36/36** |
| Küszöb-sorrend `D < súlyozott KKV < E` minden ágon | tart |
| Küszöb monotonitása a `rho_acc`-ban | monoton csökkenő |
| GDP-hatás monotonitása a `rho_acc`-ban | monoton növekvő |
| Súlyok 1-re összegződése (`om_j`, `shl_j`) | 1e−6 alatt |
| Füstteszt | **74 rendben, 0 hiba** (korábban 57) |

**Kódtakarítás közben:** a `-DSYM=1` szimmetria-teszt `shl_* = 1/3` sora
**holt kód** volt — egy későbbi értékadás felülírta. Az eredményt nem
érintette (a három súly összege mindkét esetben 1, és szimmetriában
`l_E == l_D == l_L`), de az értékadás felkerült a típus-súlyokhoz, hogy a
sorrend egyértelmű legyen. A regressziós őr bizonyítja, hogy ez semmit nem
mozdított.

---

## 8. Mit jelent ez a tanulmányra

1. **A `lev_E > lev_D` a projekt egyik kevés, saját adaton nyugvó,
   mérőfüggetlen szektorális megállapítása.** Nem feltevés, és nem is a
   hatos hibamintázat újabb esete — a *irány* két független mérték szerint
   ugyanaz.
2. **A KKV-küszöb feleződik**, de a küszöb**forma** marad: az `ACCSCALE`
   továbbra sem horgonyzott (`2026-08-12_access_horgonyzas_eredmeny.md`),
   tehát az állítás továbbra is feltételes. Ami változott: most már tudjuk,
   **mi viszi** a küszöb szintjét, és hogy a horgonyunk melyik irányba téved.
3. **Az aggregált sávot újra kell fogalmazni** (5. szakasz) — ez a
   legfontosabb szövegszerkesztési teendő.
4. **Az `om_j`/`shl_j` átvétele nyitva marad** a KSH/Eurostat SBS bontásig.

*Kapcsolódó: [`kalibracio_tabla.md`](kalibracio_tabla.md) ·
[`kalibracio_teendok_csapatnak.md`](kalibracio_teendok_csapatnak.md) ·
[`2026-08-12_access_horgonyzas_eredmeny.md`](2026-08-12_access_horgonyzas_eredmeny.md) ·
`src/model/README.md` (changelog)*
