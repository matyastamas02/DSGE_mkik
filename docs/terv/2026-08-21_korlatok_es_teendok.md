# Korlátok, turpisságok és teendők — 2026-08-21

*Három külső bírálati kör (ChatGPT Codex) + saját ellenőrzés. Minden állítás
mellett ott van, hogy **mértük-e** vagy elvi érv. A sorrend súlyosság szerint,
nem témakör szerint — mert a leadásig nem mindenre lesz idő.*

---

## 🔴 SÚLYOS — a fő eredményt érinti

### 1. Az `ACCSCALE` KÉT mechanizmust skáláz egyszerre — és a hatás KVADRATIKUS

**Ez a legélesebb technikai kritika, és mértük.** A kódban:

```
lambda_acc_E = 2.0*(ACCSCALE/100);   lambda_acc_D = 2.5*(ACCSCALE/100);
omega_acc_E  = 0.35*(ACCSCALE/100);  omega_acc_D  = 0.45*(ACCSCALE/100);
```

Vagyis **ugyanaz az egyetlen szám** szabályozza:

| | mechanizmus | paraméter |
|---|---|---|
| 1. lépcső | felár → hozzáférés | `λ_acc` |
| 2. lépcső | hozzáférés → beruházás | `ω_acc` |

A hosszú távú beruházási hatás `−ω·λ/(1−ρ)·efp`, tehát **az `ACCSCALE`
NÉGYZETÉVEL** arányos, nem a szintjével.

**Lemérve a `t49`-en (`rho_acc = 0,9673`, bázis `ACCSCALE = 0`-nál
`KKV−L = −0,412 pp`):**

| `ACCSCALE` | KKV−L | hatás | hatás/ACC | hatás/ACC² ×10⁴ |
|---:|---:|---:|---:|---:|
| 4 | −0,398 | +0,014 | 0,0035 | **8,77** |
| 10 | −0,326 | +0,087 | 0,0087 | **8,67** |
| 20 | −0,078 | +0,334 | 0,0167 | **8,35** |
| 40 | +0,758 | +1,170 | 0,0293 | 7,31 |
| 100 | +3,892 | +4,305 | 0,0431 | 4,30 |
| 140 | +5,728 | +6,140 | 0,0439 | 3,13 |

A `hatás/ACC` oszlop **12-szeresére nő**, a `hatás/ACC²` viszont kis
értékeknél **konstans** — a hatás tehát az origó közelében kvadratikus, nagy
értékeknél az általános egyensúlyi visszacsatolás tompítja.

**Miért turpisság ez:**

1. Aki azt gondolja, hogy „`ACCSCALE` 22,3 a 100 helyett ⇒ 4,5-szer gyengébb
   csatorna", **téved**: az origó közelében ~20-szoros a különbség.
2. A **22,3-as küszöb nem egy rugalmasságon van, hanem KETTŐ SZORZATÁN** — és
   előre rögzített `λ:ω` arány mellett. Vagyis a küszöb valójában azt mondja:
   *„mekkora közös skálázás mellett fordul meg az eredmény, ha az első és a
   második lépcső erősségét fix arányban EGYÜTT változtatjuk"*. Ez lényegesen
   gyengébb állítás, mint amit a szám sugall.
3. A `2,0 : 2,5` és `0,35 : 0,45` arányok maguk is átvett értékek — a
   csapattárs `v07_access`-éből —, tehát **az arány sincs horgonyozva**.

**Teendő:** az `ACCSCALE`-t **szét kell bontani** két külön kapcsolóra
(`-DLAMSCALE`, `-DOMSCALE`), és a küszöböt **kétdimenziós felületként**
közölni a `(λ, ω)` síkon — ahogy a `(ρ, ACCSCALE)` felületet már megtettük.
Fél nap, és utána a küszöb interpretálható. **Ez a legnagyobb hozamú
modellezési teendő.**

### 2. `ACCSCALE`: horgonyzatlan

Ismert, dokumentált (`A06`). A 2021–24-es magyar epizód programvezérelt volt,
tehát ebből elvileg sem azonosítható. Küszöbformában közölve.

### 3. `eps_ces`: horgonyzatlan, és az `y_E` ELŐJELE fordul rajta

`~2,3`-nál fordul. Az alapérték `6,0` egy irodalmi konvenció
(Laxton–Pesenti 2003 → GEM → EAGLE → mi). A Szabó Bakos-disszertáció
ugyanezt a 20%-os markupot használja **ugyanabból a forrásból**, tehát nem
független megerősítés. Magyar markup-becslés kell. <span>`F02`</span>

⚠ És egy fogalmi csúszás, amit érdemes kimondani: nálunk az `eps_ces` a
**vállalattípusok** közti helyettesítés, az irodalmi 6,0 viszont
**termékváltozatok** közti. **Nem ugyanaz az objektum**, csak ugyanaz a
jelölés és érték.

### 4. `omega_acc_L = 0` — a nagyvállalatnak NINCS hozzáférési margója

Ez **nem kalibráció, hanem feltevés**, és **ez viszi a szektorális
átfordulást**. A saját adatunk csak félig támogatja: a nagyvállalati
hozzáférés 43,4%, ami *alacsonyabb* az export-KKV 61,9%-ánál (`A03`).
Valószínűbb, hogy a nagyvállalat nem is *kér* hitelt — de a „nagyvállalatnak
mindig van hitele" történet **nincs az adatban**.

**Teendő:** scan rá, ugyanúgy, mint az `ACCSCALE`-re. Fél nap.

### 5. EGY pre-periódus — semmilyen cégszintű azonosítás nem validálható

Mérve: a programvezéreltség **2021 és 2022 között** tör meg (piaci árazású
ráták 100% → 26,3%, BUBOR 1,5% → 10,0%), a panel 2021-ben kezdődik.
**Egyetlen kezelés előtti év van.**

Következmény: **pre-trend teszt nem futtatható** — sem RD-hez, sem
hitelfüggőségi designhoz. Ez korlátozza az egész decemberi cégszintű
empirikus blokk ambícióját, nem a design-választás.

### 6. A `−200 bp` forráshiánya

A sokkpálya dokumentált (−200 bp szuverén / −45 bp banki, ötfázisú időzítés,
három érzékenységi pálya). **A −200 bp maga viszont hivatkozás nélkül áll** a
repóban. Ez a szám határozza meg a főeredmény nagyságrendjét.

**Teendő:** forrás vagy saját levezetés. Fél nap.

---

## 🟡 VÉDHETŐ, DE ÉRZÉKENYSÉGET IGÉNYEL

### 7. A technológiai heterogenitás ÁTVITEL, nem becslés

A `.mod` maga kimondja: *„Ez ATVITEL, nem becsles."*

| | `zeta_j` (tőkehányad) | `aa_j` (munka a munka+import kompozitban) |
|---|---|---|
| E | 0,14 ← a JV export-szektorából | 0,45 ← ugyanonnan |
| D | 0,17 ← a JV hazai szektorából | 0,80 ← ugyanonnan |
| L | 0,155 ← a kettő közötti | 0,60 ← a kettő közötti |

**A turpisság:** a három típus **eleve különböző technológiát kapott**, az
exportorientációjuk alapján. Ha az E és a D máshogy reagál, abban benne van
az is, hogy mi adtunk nekik más termelési paramétert.

**Ez a legfontosabb hiányzó érzékenységvizsgálat.** Egy bíráló első kérdése
ez lesz: *„Show me that your main conclusion is not an artifact of the E/D/L
calibration."*

**Teendő — négy ág, ez a második legnagyobb hozamú tétel:**

| Ág | Mi különbözik csak | Mit mutat meg |
|---|---|---|
| A | csak `phi_j` (exportarány) | a piaci orientáció önmagában |
| B | csak a pénzügyi paraméterek (`chi`, `lev`, `psi`, access) | a **finanszírozási** heterogenitás önmagában |
| C | csak `aa_j` (import-intenzitás) | a magyar duális szerkezet önmagában |
| D | minden technológiai paraméter AZONOS | a maradék: tisztán finanszírozási |

Ha a KKV-eredmény a **B** és **D** ágon is megvan, akkor tényleg
finanszírozási heterogenitásról szól. Ha csak az **A**/**C** ágon, akkor
technológiai műtermék. **Egy nap, makró-kapcsolóval.**

### 8. Az E/D/L szegmentáció küszöbe kutatói döntés

Az `OPTEN=2` ág az `export_arány ≥ 25%` küszöbbel definiálja az E típust.
A 25% nem természeti törvény — lehetne 10% vagy 50%, és az eredmény
változna. Az `OPTEN=1` ág (bármilyen pozitív export) eltérő szegmentálást ad,
és ott `phi_D = 0` **definíció szerint**.

**Ez normális egy DSGE-ben**, de a helyes állítás: *a típusok kalibrációja
adatból származtatott, de a szegmentáció definíciója kutatói döntés.*

**Teendő:** a küszöb scanelése (10 / 25 / 40%). Fél nap.

### 9. `rho_acc`: objektum-eltérés

Amit mértünk: **cég-szintű bináris** státusz-perzisztencia. Amit a modell
használ: **szegmens-szintű folytonos** állapot. Két különböző objektum.

**De a különbség IRÁNYA ismert** — két független ok szerint a szegmens-szint
perzisztensebb: (a) saját mérés (`t37`): a szegmens-arányok 4 év alatt
0,59–2,20 pontot mozdultak, a BUBOR 12,83-at; (b) Granger-aggregáció:
heterogén AR(1)-ek aggregálása lassabban lecsengő autokorrelációt ad.
Ezért **alsó korlát**, nem pontbecslés. <span>`A11`</span>

### 10. Az `om_j`/`shl_j` súlyok csak a 10+ fős körre

A panel nem tartalmazza a mikrocégeket, tehát a súlyok a 10+ populáción
*belüli* részesedések. Az `shl_L = 0,466` vs a modell jelenlegi `0,30`
különbségét jórészt ez magyarázza. **Ezért maradt az `-DOPTEN`
alapértelmezése `0`.** KSH/Eurostat SBS bontás kell. <span>`F03`</span>

### 10b. A JV-paraméterek 2008-asok — és a minta időszaka nincs rögzítve

**Külső észrevétel (2026-08-24, artifact-komment), és jogos.** A 91-ből
**28 paraméter** a Jakab–Világi tanulmányból jön (MNB WP **2008/9**) — és épp
ez volt a fő érv a mag választása mellett: „magyar adaton becsült". Ez igaz,
de a minta a 2008-as válság *előtt* zárul.

Amit ez érint: bérragadósság (0,657), árragadósság (0,921), szokásformálás
(0,646), a korlátozott háztartások aránya (0,25), és a sokk-perzisztenciák.
Mind egy **másik monetáris és pénzügyi rezsimből**.

⚠ **És egy önálló hiányosság:** a **JV-minta pontos időszaka a projekt
dokumentációjában nincs rögzítve** — vagyis jelenleg meg sem tudjuk mondani,
mennyire régiek az értékek. Ez fél óra munka, és nélküle a „becsült magyar
adaton" érv nem ellenőrizhető.

**Miért NEM a megoldás az egyes értékek cserélgetése:** a 28 érték
**együttesen becsült poszterior**. Ha egyet kiveszünk és beemelünk helyette
egy újabb, független becslést, elrontjuk a készlet belső konzisztenciáját —
és a modell megoldása olyan paraméter-kombinációra fut, amit soha senki nem
becsült együtt.

**A védhető út, két lépésben:**

1. **Direkt mérés ott, ahol létezik.** A korlátozott (likviditáskorlátos)
   háztartások arányára ez a helyzet: a **háztartási vagyonfelmérés (HFCS)**
   közvetlenül méri, magyar hullámokkal. Egy direkt mérés **jobb**, mint
   bármelyik DSGE-becslés — és ez a paraméter amúgy sem becsült poszterior a
   JV-ben, hanem strukturális/survey feltevés. **Ellenőrizendő, mit ad.**
2. **A vintage explicit kimondása mindenhol máshol.** Nem cseréljük, hanem
   megnevezzük: „2008 előtti magyar mintán becsült". Ez a tanulmányban egy
   lábjegyzet, és elveszi a kritika élét.

*A teljes újrabecslés (28 paraméter, mai magyar adaton) önálló kutatási
projekt — a decemberi leadás keretében nem reális, és a `2.7`-hez hasonlóan
opcióként tartjuk nyilván.*

### 11. A háztartási blokk minimális

**Nem hiányzik** — van optimalizáló (75%) és korlátozott (25%) háztartás,
Euler-egyenlettel, munkakínálattal, és a GDP kiadási oldalon áll össze
(`C + I + G + X − M`). De nincs benne: heterogén likviditási korlát,
háztartási hitelpiac, munkapiaci extenzív margó, életciklus, részletes
adózás.

**Ez tudatos és védhető:** a kutatási kérdés a **vállalati** finanszírozási
heterogenitás, nem a háztartási. Egy HANK-blokk más projektté tenné.
**Nem teendő** — de a leadásban ki kell mondani, hogy a jóléti és
elosztási kérdésekre a modell nem alkalmas.

### 12. A Phillips-aszimmetria — inert csapda

A `pi_E`/`pi_D` **nyers** sokkot kap (`eps_md`), a `pi_L`
**AR-folyamatot** (`e_mx_ar`, `rho_mx = 0,318`). Jelenleg egyetlen eredményt
sem érint, mert egyik sokk sincs hajtva egyetlen szcenárióban sem — de egy
későbbi ár-markup sokk **némán** eltolná a KKV/nagyvállalat összevetést.
Füstteszt-őr fogja el.

---

## 🟢 ELLENŐRIZVE — NEM PROBLÉMA

Ezek felvethető kritikák, amiket **megnéztünk és nem állnak**. Érdemes
tudni, hogy miért, mert újra elő fognak jönni.

| Felvetés | Miért nem probléma |
|---|---|
| „A termelési egyenletek csak összeadások — túl bugyuta" | A modell **log-linearizált**. Egy `Y = A·K^α·L^(1−α)` függvényből logaritmus után `y = a + α·k + (1−α)·l` lesz. Az additív alak a linearizálás következménye, nem a modell primitívsége. |
| „Miért **kivonjuk** a termelékenységet a határköltségből?" | Mert közgazdaságilag helyes: ha `A` nő, ugyanannyi inputból több output jön, tehát **egy egység output előállítása olcsóbb**. `mc = ζ·rk + (1−ζ)·wz − a`. A mínusz kötelező. |
| „Hol vannak a háztartások?" | Benne vannak (11. pont). A GDP `C + I + G + X − M` alakban áll össze, nem vállalati kibocsátás összegeként. |
| „Nem aggregálódik a szegmens-kibocsátás a GDP-be" | **Nem is lehet:** a `y_j` bruttó kibocsátás importált köztes inputtal, a `y` kiadási oldali GDP. Ami teljesül — `Σom_j·y_j = w_d·y_d + w_x·y_x` — most tesztelt (4,34e−19). <span>`A14`</span> |
| „Az exportáló KKV eleve rosszul jár az euróval" | **Nem következik.** Van negatív csatornája (reálfelértékelődés → versenyképesség) és pozitív is (felár ↓ → hozzáférés ↑ → beruházás ↑). A nettó hatást a modell számolja ki, nem mi tesszük fel. |

---

## A teendők sorrendje — mit érdemes tényleg megtenni

**A rendezőelv:** ne új egyenleteket írjunk, hanem **mutassuk meg, hogy a
meglévő eredmény nem a nem azonosított paraméterek műterméke.** A bíráló
első kérdése ez lesz, és jelenleg nincs rá válaszunk.

| # | Teendő | Ráfordítás | Miért |
|---|---|---|---|
| **1** | **`ACCSCALE` szétbontása** `λ` és `ω` külön kapcsolóra + kétdimenziós küszöbfelület | fél nap | a küszöb jelenleg két rugalmasság szorzatán van, kvadratikusan — így nem interpretálható |
| **2** | **E/D/L dekompozíciós scan** (4 ág: csak `phi` / csak pénzügyi / csak `aa` / minden technológia azonos) | 1 nap | ez válaszolja meg a fő referee-kérdést |
| **3** | **MNB new-business kamat bekérése** — cellaszinten (méret × összeg × fixálás × futamidő + volumenek, 2015–24) | levél + várakozás | az egyetlen tétel, ami **időbeli aggregátum**, tehát nem szenved a pre-periódus problémától |
| **4** | **`omega_acc_L` scan** | fél nap | ez a legnagyobb egyetlen feltevés |
| **5** | A `−200 bp` forrása | fél nap | ez viszi a főeredmény nagyságrendjét |
| **6** | A 25%-os szegmentálási küszöb scanelése | fél nap | kutatói döntés, mérni kell a hatását |
| **7** | KSH/Eurostat SBS mikrokör-bontás → `om_j`/`shl_j` | fél nap | ez oldja fel az `-DOPTEN` alapértelmezését |
| **8** | `eps_ces` magyar horgony | 1–2 nap | a szektorális eredmény másik fele |

**Az 1. és 2. tétel együtt másfél nap, és többet ér, mint bármi más ezen a
listán** — mert nem új eredményt gyártanak, hanem a meglévőt teszik
védhetővé.

---

## Egy mondat, amit érdemes fejben tartani

> Ha van egy nem azonosított paraméter, és úgy választod meg, hogy a
> kívánt eredmény jöjjön ki, akkor a modell **mechanikusan képes
> előállítani a hipotézisedet.**

Ez nem szándékos manipulációt jelent — hanem azt, hogy a
`kalibráció → azonosítás → érzékenység → validáció` láncban a projekt
jelenleg a **második lépésnél** áll. Az 1. és 2. teendő pontosan a
harmadikat viszi be.

*Kapcsolódó: [`kalibracio_teendok_csapatnak.md`](kalibracio_teendok_csapatnak.md)
· [`../../ALLAPOT.md`](../../ALLAPOT.md) ·
[`../figyelmeztetesek/`](../figyelmeztetesek/)*
