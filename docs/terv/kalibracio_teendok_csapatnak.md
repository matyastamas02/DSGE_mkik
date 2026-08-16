# Kalibrációs teendők — mit kell megszerezni és kiszámolni

*2026-08-12 · a fő modell (`src/model/jv_dsge_v09_access.mod`, Jakab–Világi
mag) **91 paramétere** alapján. Ez a csapatnak szóló munkalista: mit tudunk
magunk kiszámolni, mihez kell külső adat, és mihez kell szakirodalom.*

> **A 91 paraméterből 28 MÁR HORGONYZOTT** — ezek a Jakab–Világi magyar
> adaton becsült poszterior átlagai, tehát velük nem kell tenni semmit. Ez
> konkrétan a 2026-07-13-i alapcikk-döntés hozadéka. A teljes bontás:
> [`kalibracio_tabla.md`](kalibracio_tabla.md).
>
> **Miért most:** a modell technikai része kész. A JV-mag háromtípusos
> változata mindent tud, amit az EAGLE-vonal (három típus, típusonkénti ár
> és kereslet, hitelhozzáférési margó), és minden lépcső átment a
> Blanchard–Kahn teszten és a független verifikáción. **Innentől nem
> modellépítés van hátra, hanem horgonyzás.**

---

## A lényeg egy bekezdésben

**Az aggregált eredmény robusztus, a szegmens-szintű nem.** Az euró tartós
GDP-hatása minden lépcsőn és minden paraméterezésen **+0,27% … +1,04%**
között marad. ⚠ **Pontosítás (2026-08-16):** ez a sáv az *átvett* `rho_acc`
= 0,85 mellett érvényes. Az Opten-panelből horgonyzott `rho_acc` = 0,9673
mellett a felső vég **+2,03%-ra** tolódik (`-DOPTEN=1`), a `rho_acc`-ot
önmagában cserélve +2,89%-ig (`-DOPTEN=3`) — mert a hosszú távú
access-szorzó `1/(1−ρ)`. **A sáv iránya nem változott, a szélessége igen.** A szektorális eredményt viszont **két horgonyzatlan paraméter**
viszi (`eps_ces` és `ACCSCALE`), és mindkettőn **fordul az előjel**. Amíg
ezek nincsenek lehorgonyozva, a KKV/nagyvállalat állítást csak
**küszöbformában** szabad közölni.

Ez a **hatodik** eset a projektben ugyanezzel a mintázattal (`t_S>t_L`,
`chi`-aszimmetria, `ACCSCALE`, IO-alapú `s_kkv`, `eps_ces`, és most a
kettő együtt). Ezért a lista élén nem paraméterek állnak, hanem **adatkérések**.

---

## 1. PRIORITÁS — amit MI tudunk kiszámolni, adatkérés nélkül

> ## ✅ 2026-08-16: EZ A BLOKK LEFUTOTT
> Számoló: `src/s15_opten_kalibracio.m` → `t46`/`t46b`/`t46c`.
> Modellhatás: `src/model/stress_opten_v09.m` → `t47`/`t48`/`t48b`/`t49`/`t49b`.
> Modellbe kötve `-DOPTEN=0|1|2|3` makró-kapcsolóval (alapértelmezés `0`).
> Részletes eredmény: [`2026-08-16_opten_kalibracio_eredmeny.md`](2026-08-16_opten_kalibracio_eredmeny.md).
>
> **Négy mondatban:** (1) a `phi_L` és a `delta` átvett értéke **helyes volt**
> — a panel független próbán ugyanazt adja. (2) A `lev_E = lev_D`
> kényszerített egyenlőség **megdőlt**: 1,939 vs. 1,719, az exportáló KKV
> tőkeáttételesebb. (3) A `rho_acc` 0,85 → **0,9673**, ami a hosszú távú
> access-szorzót 6,7×-ről 30,6×-re emeli, és a súlyozott KKV-küszöböt
> **36,5-ről 22,3-ra** viszi le. (4) Az `om_j`/`shl_j` súlyok **nem
> cserélhetők le** a mikrokör hiánya miatt — ez maradt nyitva (lásd 2.5).

*Opten-panel, 148 225 cég-év, 37 805 cég, 2021–2024. Már megvan, csak le
kell futtatni. **14 paraméter**, becsült ráfordítás: **fél–egy nap az egész
blokk.***

| # | Paraméter | Jelenlegi | Miből | Panel-oszlop | Ki? |
|---|---|---|---|---|---|
| 1 | `om_E` / `om_D` / `om_L` | 0,18 / 0,37 / 0,45 | kibocsátás-részesedés | `netto_arbevetel` | |
| 2 | `shl_E` / `shl_D` / `shl_L` | 0,20 / 0,50 / 0,30 | foglalkoztatás-részesedés | `letszam` | |
| 3 | `phi_E` / `phi_D` / `phi_L` | 0,56 / 0,05 / 0,365 | exportárbevétel-arány | `export_arany` | |
| 4 | `lev_E` / `lev_D` / `lev_L` | 1,6 / **1,6** / 1,85 | tőkeáttétel-medián | `tokeattetel` | |
| 5 | `delta` | 0,025 | écs / tárgyi eszközök | `ertekcsokkenes` | |
| 6 | `rho_acc` | 0,85 | hozzáférési státusz-átmenet | `van_hitel` átmenet-mátrix | |

**Fontos a 4-esnél:** a `lev_E = lev_D = 1,6` egy **kényszerített
egyenlőség** — a modell szándékosan azonos KKV-paramétert ad az export- és
a hazai KKV-nak. Az `s14` viszont kimutatta, hogy a két szegmens
**13-szorosan** eltér hitelhez jutásban (61,9% vs 4,8%), tehát
valószínűtlen, hogy a tőkeáttételük azonos. **Ezt szét kell számolni.**

**A `.mod` maga kéri:** *„Ezek indulok: empirikus ujrakalibracio kell."*

---

## 2. PRIORITÁS — külső adatkérés, ezek nélkül nem megyünk tovább

### 2.1 MNB: méret szerinti új-szerződéses vállalati kamatstatisztika

**Ez a legfontosabb hiányzó adat az egész projektben.** Három külön falat
bontana le egyszerre:

- a `t_sov` / `t_bank` transzmissziós súlyokat (jelenleg **nem azonosítottak**:
  a becsült arány 0,26 és 2,75 között szóródik, semmi sem szignifikáns);
- az `ACCSCALE`-t (a hozzáférési reakciót);
- és a `chi_E/D/L` BGG-érzékenységet.

**Miért nem elég a nyilvános ECB MIR:** ott csak összeg-kategória van
(≤1M EUR / >1M EUR), ami a méret **proxyja**, nem a méret. Ráadásul a
kategória kizárja a folyószámla- és rulírozó hitelt, tehát a Széchenyi
Kártya legnagyobb terméke eleve nincs benne.

**Amit kérni kell:** vállalati új-szerződéses hitelkamat **méretkategória
szerint** (mikro / kis / közép / nagy), lehetőleg **támogatott és piaci
bontásban**, havi vagy negyedéves gyakorisággal, minél hosszabb visszamenőleg.

### 2.2 2021 ELŐTTI cégpanel

Az `s14` kimutatta, hogy a 2021–24-es magyar epizód **nem azonosítja** a
hozzáférési rugalmasságot: a BUBOR 12,8 pontot mozgott, a hozzáférési
arányok kevesebb mint 2-t — mert a támogatott programok épp akkor bővültek,
amikor a piaci kamat tetőzött. A hazai KKV hozzáférése **monoton nőtt** a
kamatcsúcs felé (4,5% → 5,1%).

**A programvezéreltség az NHP/Széchenyi-bővítés előtt gyengébb volt.** Ha
van 2021 előtti Opten- (vagy más) cégpanel, ott a piaci variancia többet
azonosít. **Ez a második legfontosabb adatkérés.**

### 2.3 Mikrocégek (<10 fő)

A jelenlegi panel a 10+ fős kört fedi. A Széchenyi Kártya viszont a
mikrocégeknél koncentráltabb — tehát a hozzáférési reakciót
**valószínűleg alulbecsüljük**, és a `t12`/`t14` arányok sem
állomány-súlyozottak.

### 2.5 KSH / Eurostat SBS méretkategóriás bontás — ÚJ, 2026-08-16

**Ez blokkolja az `om_j`/`shl_j` súlyok lecserélését.** Az Opten-panel a
10+ fős kört fedi, tehát a belőle számolt súlyok a 10+ populáción *belüli*
részesedések: `shl_L = 0,466`, miközben a modell jelenlegi `shl_L = 0,30`
értéke vélhetően a **teljes** vállalati szektorra vonatkozik. A kettő nem
cserélhető fel közvetlenül — a különbség jórészt a hiányzó mikrokör.

**Amit kérni/letölteni kell:** KSH vagy Eurostat SBS (`sbs_sc_ovw` jellegű)
magyar vállalati bontás **méretkategóriánként** (0–9 / 10–49 / 50–249 / 250+),
foglalkoztatás és hozzáadott érték szerint, 2021–2024. Ebből a 10+ súlyok
átskálázhatók teljes gazdaságra. **Fél nap**, és utána az `-DOPTEN=1`
alapértelmezéssé tehető.

*(Kapcsolódik a 2.3-hoz — a mikrocégek hiánya ott a hozzáférési reakciót
torzítja, itt a súlyokat.)*

### 2.4 KSH nemzeti számlák (könnyű, de meg kell csinálni)

| Paraméter | Jelenlegi forrás | Honnan pótolható |
|---|---|---|
| `sc` / `si` / `sg` / `sx` / `sm` | JV-becslés | KSH, 2021–2024 átlag |
| `alpha`-jellegű tőkehányad (`zeta_j`) | JV kétszektoros érték átvitele | KSH ágazati tőkerészesedés |
| `aa_E` / `aa_D` / `aa_L` (import-intenzitás) | JV `a_d`/`a_x` átvitele | KSH / ÁKM ágazati import-hányad |

---

## 3. PRIORITÁS — szakirodalmi horgony

### 3.1 `eps_ces` — EZ VISZI A SZEKTORÁLIS EREDMÉNY EGYIK FELÉT

CES-helyettesítés a vállalattípusok között. **A JV-ben nincs ilyen
paraméter** (ott két jószág van, nem differenciált típusok), az érték az
EAGLE-vonalból átvett irodalmi szám (6,0 = 20% markup).

**Az export-KKV kibocsátásának előjele ezen fordul, ~2,3-nál:**

| `eps_ces` | 2 | 3 | **6** (jelenlegi) | 11 |
|---|---:|---:|---:|---:|
| `y_E` | **+0,022%** | −0,047% | **−0,221%** | −0,447% |
| aggregált GDP | +0,467% | +0,466% | +0,467% | +0,474% |

**Amit kellene:** magyar markup- vagy helyettesítésirugalmasság-becslés
(vállalati panelből is becsülhető lenne). Amíg nincs: **küszöbforma**.

---

## 3.b AMIVEL NEM KELL TENNI SEMMIT — 28 paraméter, már horgonyzott

**Ez a lista azért van itt, hogy senki ne kezdje el keresni hozzájuk a
forrást.** `sigma`, `habit`, `xi_p`/`vth_p`, `xi_x`/`vth_x`, `xi_w`/`vth_w`,
`mu_x`, `hx`, `gam_i`, `phi_pi`, `nu_b`, `rho_a`/`rho_x`/`rho_c`/`rho_w`/
`rho_i`/`rho_pr`/`rho_mx`/`rho_g` — **a Jakab–Világi magyar adaton becsült
poszterior átlagai** (MNB WP 2008/9). Plusz `fii`, `theta_w`, `rho_kz`,
`rho_z`, `om_no` (JV-strukturális/survey), és `eps_qw`, `omega_nw`
(BGG 1999 konvenció).

**Ez a 2026-07-13-i alapcikk-döntés konkrét hozadéka: a modell közel
harmada készen van.** Az EAGLE-magon ugyanezekhez irodalmi hivatkozás
kellett volna, és öt közülük konfliktusban is állt a JV-értékekkel.

⚠ **Kivétel, amit nem szabad elfelejteni:** ha valaki EAGLE-értékeket lát
valahol (`sigma`=0,4, `om_nr`=0,75, `rho_a`=0,90), az **a referencia-vonal**,
nem a fő vonal. A kettő között `om_nr`-nél **háromszoros** az eltérés.

---

## 4. Amit NEM lehet lehorgonyozni, és ezt vállalni kell

| Paraméter | Miért | Hogyan közöljük |
|---|---|---|
| `ACCSCALE` (a hozzáférési margó ereje) | magyar 2021–24 adatból nem azonosítható (programvezérelt piac) | **küszöbforma** |
| `omega_acc_L` (nem létezik: a nagyvállalatnak nincs margója) | ez a legnagyobb egyetlen feltevés, és ez viszi a szektorális átfordulást | scan kell rá, mint az `ACCSCALE`-re |
| `nu_uni`, `nu_b` | **technikai** külső zárás, nem strukturális | érzékenységgel kísérve |
| `s_kkv` / `mu_vert` | az IO-mérés hibás (`FIGYELMEZTETES_io_tabla_gyanus.md`) | amíg nincs javított IO: **ne közöljük** |

**Az `omega_acc_L`-ről:** a szokásos indoklás, hogy a nagyvállalat nincs
hitelkorlátozva. A saját adatunk ezt **csak részben támogatja**: az `s14`
szerint a nagyvállalati hozzáférés 43,4%, ami *alacsonyabb*, mint az
export-KKV-k 61,9%-a. Valószínűbb, hogy a nagyvállalat nem is *kér* hitelt
— de a „nagyvállalatnak mindig van hitele" történet **nincs az adatban**.

---

## 5. A küszöbök, amiket jelenleg közölni tudunk

`ACCSCALE`, ami kell ahhoz, hogy a KKV megelőzze a nagyvállalatot
(fő modell, `TSCEN=3` semleges transzmisszió):

| Feltétel | `-DOPTEN=0` (átvett) | `-DOPTEN=3` (csak `rho_acc`) | `-DOPTEN=1` (teljes Opten) |
|---|---:|---:|---:|
| hazai KKV ≥ nagyvállalat | **22,6** | 10,7 | 10,3 |
| súlyozott KKV-blokk ≥ nagyvállalat | **36,3** | 17,0 | 22,3 |
| export-KKV ≥ nagyvállalat | **61,9** | 28,9 | 31,0 |

*(2026-08-16, `t48b`. A `-DOPTEN=0` oszlop a korábban közölt érték; a saját
rácsunkon 22,9 / 36,5 / 61,7 jön ki — a különbség interpolációs, nem
tartalmi.)*

**A küszöb ~felére esik, amint a `rho_acc` empirikusan horgonyzott** — és
mivel a 0,9673 **alsó korlát** (cég-szintű perzisztencia, a szegmens-szintű
ennél magasabb), a valódi küszöb ennél is lejjebb van. A `t49` scan a teljes
összefüggést mutatja:

| `rho_acc` | 0,85 | 0,90 | 0,93 | 0,95 | **0,9673** | 0,98 |
|---|---:|---:|---:|---:|---:|---:|
| `1/(1−ρ)` | 6,7 | 10,0 | 14,3 | 20,0 | **30,6** | 50,0 |
| küszöb (súlyozott KKV ≥ L) | 47,8 | 39,1 | 32,6 | 27,6 | **22,3** | 17,5 |
| GDP @ `ACCSCALE=100` | 0,66% | 0,77% | 0,91% | 1,07% | **1,34%** | 1,75% |

⚠ **Ezt a táblát kell közölni, nem a „küszöb = 22,3" számot.** Az `ACCSCALE`
továbbra sem horgonyzott, tehát az állítás továbbra is feltételes; ami
változott, az a küszöb **szintje**, és az, hogy immár tudjuk, mi viszi.

⚠ **Ne hasonlítsuk össze az EAGLE-vonal küszöbeivel** (94–101). A két
magon az access-specifikáció eltér (ott Tobin-Q-n át, itt a beruházási
Euler-egyenletben), tehát **az `ACCSCALE` skálája nem ugyanaz**. Amit a
két szám együtt mutat: **mindkét magon létezik véges küszöb** — a szintjük
nem összevethető.

---

## Összefoglaló táblázat — mit kell tenni

| Sorrend | Feladat | Ki | Ráfordítás |
|---|---|---|---|
| ~~**1**~~ | ~~Opten-panelből a 6 tétel újrakalibrálása (1. prioritás)~~ | ✅ **kész 2026-08-16** | — |
| **1a** | KSH/Eurostat SBS méretbontás → az `om_j`/`shl_j` átskálázása (2.5) | belső | fél nap |
| **1b** | A csatorna-dekompozíció (`t15`) újrafuttatása a FŐ modellen — jelenleg a `v03` archív modellen áll (`F05`) | belső | fél nap |
| **2** | MNB méret szerinti kamatstatisztika **bekérése** | levél | + várakozás |
| **3** | 2021 előtti cégpanel felkutatása | belső | fél nap |
| **4** | KSH nemzeti számlák súlyai | belső | fél nap |
| **5** | `eps_ces` magyar horgony (irodalom vagy saját becslés) | belső | 1–2 nap |
| **6** | `omega_acc_L` scan (mint az `ACCSCALE`) | belső | fél nap |
| **7** | IO-mérés javítása (`t24`) — a gyökérok még nyitott | belső | 1 nap |

*Kapcsolódó: `docs/kalibracio_tabla.md` (a teljes paramétertábla forrás
szerint) · `docs/FIGYELMEZTETES_fo_allitas.md` · `docs/FIGYELMEZTETES_io_tabla_gyanus.md` ·
`docs/2026-08-12_access_horgonyzas_eredmeny.md`*
