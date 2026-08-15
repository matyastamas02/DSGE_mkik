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
között marad. A szektorális eredményt viszont **két horgonyzatlan paraméter**
viszi (`eps_ces` és `ACCSCALE`), és mindkettőn **fordul az előjel**. Amíg
ezek nincsenek lehorgonyozva, a KKV/nagyvállalat állítást csak
**küszöbformában** szabad közölni.

Ez a **hatodik** eset a projektben ugyanezzel a mintázattal (`t_S>t_L`,
`chi`-aszimmetria, `ACCSCALE`, IO-alapú `s_kkv`, `eps_ces`, és most a
kettő együtt). Ezért a lista élén nem paraméterek állnak, hanem **adatkérések**.

---

## 1. PRIORITÁS — amit MI tudunk kiszámolni, adatkérés nélkül

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

| Feltétel | Küszöb |
|---|---:|
| hazai KKV ≥ nagyvállalat | **22,6** |
| súlyozott KKV-blokk ≥ nagyvállalat | **36,3** |
| export-KKV ≥ nagyvállalat | **61,9** |

⚠ **Ne hasonlítsuk össze az EAGLE-vonal küszöbeivel** (94–101). A két
magon az access-specifikáció eltér (ott Tobin-Q-n át, itt a beruházási
Euler-egyenletben), tehát **az `ACCSCALE` skálája nem ugyanaz**. Amit a
két szám együtt mutat: **mindkét magon létezik véges küszöb** — a szintjük
nem összevethető.

---

## Összefoglaló táblázat — mit kell tenni

| Sorrend | Feladat | Ki | Ráfordítás |
|---|---|---|---|
| **1** | Opten-panelből a 6 tétel újrakalibrálása (1. prioritás) | belső | fél–egy nap |
| **2** | MNB méret szerinti kamatstatisztika **bekérése** | levél | + várakozás |
| **3** | 2021 előtti cégpanel felkutatása | belső | fél nap |
| **4** | KSH nemzeti számlák súlyai | belső | fél nap |
| **5** | `eps_ces` magyar horgony (irodalom vagy saját becslés) | belső | 1–2 nap |
| **6** | `omega_acc_L` scan (mint az `ACCSCALE`) | belső | fél nap |
| **7** | IO-mérés javítása (`t24`) — a gyökérok még nyitott | belső | 1 nap |

*Kapcsolódó: `docs/kalibracio_tabla.md` (a teljes paramétertábla forrás
szerint) · `docs/FIGYELMEZTETES_fo_allitas.md` · `docs/FIGYELMEZTETES_io_tabla_gyanus.md` ·
`docs/2026-08-12_access_horgonyzas_eredmeny.md`*
