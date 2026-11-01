# Kiadásoldali megszorítás a v11 fiskális blokkjában

*2026-10-29, Samunak. A kérésed az volt, hogy a fiskális blokkba kerüljön bele a megszorítás: az euró
előtt a hiányt 3% alá kell vinni, és az árstabilitás miatt a kormánynak óvatosan kell költenie. Ez a
jegyzet leírja, hogyan építettem be, mi jött ki, és hogyan érdemes értelmezni.*

*A hivatalos számok a regiszterben vannak: `A35`, `F15`, `F16` (`ALLAPOT.md`, füstteszt-őr mindháromra).
Ahol egy szám ezeken kívül esik, mellette jelzem: „t67c, őr nélkül”.*

*Javítva 2026-10-31: a 4. szakasz K6-sora, valamint a 6.2 és a 6.3 pont. Az első változat azt írta,
hogy minden előre rögzített várakozás teljesült, és a tartós GDP-csökkenést a kormányzati fogyasztás
kiesésével magyarázta. Mindkettő hibás volt; a 6.2 és a 6.3 új számai egy utólagos felbontásból
jönnek (t67b, őr alatt).*

*Javítva 2026-11-01, egy külső (ChatGPT) review után
([`docs/terv/2026-11-01_fiskalis_blokk_review.md`](../terv/2026-11-01_fiskalis_blokk_review.md)):*

- *a `PHIB = 0,02` nem „nincs adócsökkentés”, hanem lassabb adóvisszaadás (1. és 6.4 pont);*
- *a „3. évre 3% alá” állítást visszavontam (5.3, 6.4);*
- *az euró hatása feltételes rezsimhatás, 0,517–0,519 pp, nem pontosan „+0,52 változatlan” (6.1);*
- *a megszorítás GDP-, foglalkoztatási és inflációs számai belső diagnosztikák, nem közölhetők (7.).*

---

## Röviden

- **A félelmed részben jogos.** Az euró és a megszorítás együtt, 20 éves távon (a 16–20. év átlaga):
  - 1,7 pp-es megszorítással a GDP-hatás **+0,21%**;
  - 3,0 pp-essel **−0,02%**;
  - 4,5 pp-essel **−0,29%**.
- **Az euró saját hatása viszont alig változik:** azonos megszorítás mellett mindhárom esetben
  **0,517–0,519 pp** (megszorítás nélkül 0,520). A megszorítás euróval és nélküle gyakorlatilag
  ugyanannyiba kerül (−0,30 / −0,54 / −0,80%).
- **A megszorítás az euró nélkül is kell**, mert Magyarország 2024 óta túlzotthiány-eljárásban van. Ezért
  az euró hatása a két futás különbsége, nem az együttes szám. Ez **feltételes** hatás: azonos fiskális
  pályát feltételez euróval és nélküle (lásd 6.1).
- **A megszorítás saját GDP-, foglalkoztatási és inflációs számai belső diagnosztikák**, nem közölhetők
  (lásd 7.).
- **A tartós GDP-csökkenés nagyrészt a modell feltevéseiből jön** (egyösszegű adó, haszon nélküli
  kormányzati fogyasztás, erős vagyonhatás, a munka kis költségsúlya). Nem a kormányzati fogyasztás
  kiesése viszi, hanem a nettó export (lásd 6.2). Szja- vagy járulékcsökkentéssel a GDP-előjel
  megfordulhat.

---

## 1. Mit csináltam a kérésből

A kérést így fordítottam modellre:

| A kérés | A modellben |
|---|---|
| „le kell vinni 3% alá a hiányt” | a kormányzati fogyasztás tartósan a GDP `KONSZD` százalékával csökken, a bejelentéstől 8 negyedév alatt felfutva |
| „óvatosan kell költekeznie” | a megtakarítást nem költik vissza: a `g` nem nő vissza, és egy változatban az adósságszabály lassabban ad vissza adócsökkentést (`PHIB = 0,02`; ez sem „nincs adócsökkentés”, lásd 6.4) |

**Miért csak a kiadási oldalon?** Az adó a modellben egyösszegű, és csak a ricardói optimalizálókat
terheli. Egy adóemelés ezért semmilyen reálváltozót nem mozdítana: a megszorításnak csak a
kiadáscsökkentésen keresztül van reálhatása. Torzító adók (szja, járulékok) a 6. blokkban lesznek.

## 2. Mekkora megszorítás kell

| | Hiány (% GDP) | Forrás |
|---|---|---|
| 2025, tény | 4,7 | KSH / Eurostat (2026. április és október) |
| 2026, várható | kb. 7,2–7,5 | az új kormány költségvetés-felülvizsgálata utáni EDP-notifikáció, Standard Chartered |

Ebből három esetet futtattam:

- **1,7 pp:** a 2025-ös szintről 3%-ra;
- **4,5 pp:** a 2026-os szintről 3%-ra;
- **3,0 pp:** a középső eset.

A modell lineáris, ezért bármely más méret arányosan számolható (lásd 6.5).

## 3. Hogyan van beépítve

Minden a `jv_dsge_v11.mod`-ban van, kapcsoló mögött. **Az alapértelmezés `KONSZ=0`, így minden eddigi
szám változatlan.**

| Kapcsoló | Alap | Mit csinál |
|---|---|---|
| `-DKONSZ=0\|1` | 0 | bekapcsolja a megszorítást (csak `-DFISCAL=1` mellett) |
| `-DKONSZD=<x>` | 3.0 | a tartós kiadáscsökkentés a GDP %-ában |
| `-DKONSZN=<n>` | 8 | a felfutás hossza negyedévben |
| `-DSCENARIO=6` | — | nincs euró, csak a megszorítás (a hatások szétválasztásához) |

**Az egyetlen módosított egyenlet** a kormányzati fogyasztás folyamata:

```
g = rho_g*g(-1) + eps_g - (kons - rho_g*kons(-1))/sg
```

Itt `kons` egy új exogén pálya: a megszorítás nagysága a GDP arányában. A ciklikus rész (`g + kons/sg`)
a régi AR(1), így `eps_g = 0` mellett **`sg·g = −kons` minden negyedévben pontosan**. A `kons` az 1.
negyedévtől (bejelentés) lineárisan fut fel, és a 8. negyedévtől a teljes `KONSZD/100`. Az euró
időzítése a megszokott: bejelentés az 1. negyedévben, belépés a 13.-ban.

**A hiány**, amit a 3%-hoz mérni kell, a nominális (maastrichti) hiány változása a GDP arányában:

```
hiány = −pb + intexp + bbar_g·infl
```

- `pb = tls − sg·g` az elsődleges egyenleg;
- `intexp` a reál kamatkiadás;
- a `bbar_g·infl` tag az infláció értékvesztését adja vissza, ettől lesz a hiány nominális.

Negyedéves áram osztva negyedéves GDP-vel, ami ugyanaz, mint az éves %. Ez nem új modellváltozó: a
futtató utólag számolja a meglévőkből.

**Az adósságszabály** a régi: `tls = phi_b·bg(−1)`, alapból `phi_b = 0,05`. A ricardói háztartások miatt
a `PHIB` és a lejárat (`RHOM`) csak a hiány- és adósságpályát változtatja, a GDP-t, a fogyasztást
és az inflációt nem. Ezt a futtató ellenőrzi is (K3).

## 4. Ellenőrzések

A várakozásokat a futtató fejlécébe a futás előtt írtam le. Az öt technikai (K1–K5) teljesült, a
hatodik, előjelre vonatkozó (K6) csak részben *(javítva 2026-10-31: a jegyzet első változata a K6-ot
kihagyta, és azt írta, hogy minden várakozás teljesült)*:

| | Mit néz | Eredmény |
|---|---|---|
| K1 | `KONSZD = 0` mellett minden pálya azonos a kapcsoló nélkülivel; nulla sokkra minden nulla | eltérés 0 / 0 |
| K2 | `sg·g = −kons` pontosan; euró nélkül a tartós adósság az analitikus `−kons/(phi_b − (rgbar − 1))` | 2e−17; 3,0 pp-nél pontosan −21,43% éves GDP |
| K3 | a `PHIB` és a `RHOM` nem mozgat reálváltozót | eltérés 0 |
| K4 | a hatás a megszorítás méretével lineáris | 1e−15 |
| K5 | BK mindkét rezsimben | 13/13 futás, 13 instabil gyök / 13 előretekintő |
| K6 | csak előjel: euró nélkül a megszorítás az első 2 évben csökkenti a GDP-t és az inflációt; tartósan a GDP kevésbé csökken, mint a kiadás; a magánfogyasztás nő | **részben nem teljesült.** Az 1. évben a GDP nő (+0,10%), csak a 2. évben csökken (−0,27%). Az infláció az 1. évben −0,02 pp, a 2. évben +0,0003 pp, tehát nem csökken: gyakorlatilag nem mozdul. A futtató ezt 2026-11-01 óta évenként kiértékeli, és egy őr rögzíti (t67b K6). A tartós rész teljesült: a GDP −0,53% a GDP 3%-ának megfelelő kiadáscsökkentés mellett, a magánfogyasztás +6,38%. |

## 5. Eredmények

**Elnevezések:**

- **E** = csak euró;
- **K** = csak megszorítás (euró nélkül);
- **EK** = euró + megszorítás.

Aktív v11-ág (`KALIB=1, EXTCLOSE=1, SOVCSAT=1`, `ACCSCALE = 100`, `ϑ = 0`, `PENS = 0`).

### 5.1 GDP, 20 éves táv (16–20. év átlaga) — `F15`

| Megszorítás | EK | K | Az euró feltételes hatása (EK − K) |
|---|---|---|---|
| 0 | +0,52% | – | +0,520 pp |
| 1,7 pp | +0,21% | −0,30% | +0,519 pp |
| 3,0 pp | −0,02% | −0,54% | +0,518 pp |
| 4,5 pp | −0,29% | −0,80% | +0,517 pp |

A tartós (fixpont) értékek gyakorlatilag ugyanezek (+0,22 / −0,01 / −0,28% az EK-ra).

### 5.2 Rövid táv, 3,0 pp-es eset (éves átlagok)

| GDP, % | 1. év | 2. év | 3. év | 5. év | 10. év |
|---|---|---|---|---|---|
| E | −0,72 | −0,71 | −0,22 | +0,98 | +0,20 |
| K | +0,10 | −0,27 | −0,49 | −0,53 | −0,54 |
| EK | −0,62 | −0,97 | −0,70 | +0,45 | −0,34 |

*A 2. évi EK- és E-érték és a K 1. évi értéke a regiszterben van, a többi „t67c, őr nélkül”.* Az E-pálya az
5. év körüli beruházási csúcs után visszaesik, ezért egy-egy év értékét nem érdemes közölni, csak a
16–20. év átlagát.

**Infláció**, évesítve, az 1–3. év átlaga (`F16`):

- E: −0,60 pp;
- K: −0,004 pp;
- EK: −0,60 pp.

### 5.3 A hiány változása, 3,0 pp-es eset (százalékpont) — `F16`

| | 1. év | 2. év | 3. év | 5. év | 10. év | 20. év |
|---|---|---|---|---|---|---|
| E, egynegyedéves adósság | −0,33 | −0,98 | −1,19 | −1,19 | −0,63 | −0,16 |
| E, 5 éves lejárat | −0,04 | −0,24 | −0,45 | −0,70 | −0,76 | −0,30 |
| EK, alapszabály (`PHIB 0,05`, `RHOM 0`) | −1,24 | −3,19 | −3,62 | −3,01 | −1,53 | −0,37 |
| EK, 5 éves lejárat, alapszabály | −0,95 | −2,45 | −2,88 | −2,53 | −1,65 | −0,51 |
| **EK, 5 éves lejárat, `PHIB 0,02`** | −0,96 | **−2,58** | **−3,28** | −3,50 | −3,66 | −3,22 |

*Javítva 2026-11-01: itt korábban egy táblázat állt arról, hogy egy 6%-os kiinduló hiány a 3. évre 2,7%-ra
megy. Ezt visszavontam. A modellbeli hiány változás egy növekedés nélküli modellben, nem
Maastricht-előrejelzés (lásd 6.4), és a „3% alá megy” a megszorítás méretének választásából következik.*

### 5.4 Ki mit nyer a megszorításon, tartósan (K, 3,0 pp)

| Változó | Tartós eltérés |
|---|---|
| Kormányzati fogyasztás | −14,8% (a GDP 3%-a, `sg = 0,203`) |
| Magánfogyasztás | +6,38% |
| optimalizálók | +7,67% |
| likviditáskorlátos háztartások | +2,51% |
| Foglalkoztatás | −3,02% |
| Reálbér | +5,53% |
| Beruházás | −0,05% |
| Reálárfolyam | −0,91% (felértékelődés) |
| Export | −0,46% |
| Import (köztes input) | +0,38% |
| Adósság | −21,4% éves GDP (euróval együtt −32,2%) |

*A regiszterben ebből a foglalkoztatás, a reálárfolyam, az export, az import és a 16–20. évi fogyasztás
van, a többi „t67b, őr nélkül”.*

## 6. Hogyan kell értelmezni

### 6.1 Az euró hatása és az együttes hatás nem ugyanaz

A megszorítást az EU fiskális szabályai miatt euró nélkül is meg kell csinálni. Az euróhoz rendelhető
hatás ezért azonos megszorítás mellett az EK − K különbség, ez **0,517–0,519 pp** (megszorítás nélkül
0,520). Az EK szám (például −0,02%) azt mutatja, mi történik összesen, ha a két dolog egyszerre jön.

*Pontosítás 2026-11-01:* az EK − K **feltételes rezsimhatás**: az euró monetáris-pénzügyi hatása azonos
fiskális pálya mellett. Ha euró nélkül lassabb volna a konszolidáció, a csatlakozás teljes hatásához egy
második szám is kell: a gyors eurós és a lassabb nem-eurós pálya különbsége (EK_gyors − K_lassú). A
kettőt külön kell közölni; a másodikat még nem futtattam.

**A megszorítás költsége nem függ attól, hogy van-e euró.** A megszorítás az első két évben, még lebegő
árfolyam és saját monetáris politika mellett fut le. Tartósan pedig a monetáris rezsim a reálgazdaságot
nem befolyásolja. Ha a megszorítás a belépés *után* jönne, ez más lehetne.

Amit az euró tényleg megváltoztathat, az a **megszorítás üteme**. Euró nélkül a túlzotthiány-eljárás
lassabb pályát engedhet (a Standard Chartered 2029–30-ra várja a 3% alá kerülést), euróhoz viszont a
konvergenciajelentés előtt kell teljesíteni. Ezt a különbséget még nem futtattam (lásd 9.).

### 6.2 Miért csökken a GDP tartósan?

*Javítva 2026-10-31. Az első változat szerint a GDP azért csökken, mert a kormányzati fogyasztás a GDP
része, és a magánfogyasztás ezt nem pótolja teljesen. Ez nem igaz: a magánfogyasztás a kieső állami
fogyasztást több mint pótolja.*

A tartós GDP-változás felbontása, euró nélkül, 3,0 pp-es megszorítással
(`y = sc·c + si·ii + sg·g + sx·xx − sm·im`), százalékpontban:

| | Magánfogyasztás | Kormányzati fogyasztás | Beruházás | Export | Import | **GDP** |
|---|---|---|---|---|---|---|
| Hozzájárulás, pp | +3,17 | −3,00 | −0,01 | −0,38 | −0,30 | **−0,53** |

A belföldi fogyasztás (C+G) együtt tehát **nő** (+0,17 pp). A GDP a **nettó export** miatt csökken
(−0,69 pp). A lánc:

1. **A háztartások kevesebbet dolgoznak.** A kisebb állami fogyasztás kisebb jövőbeli adóterhet jelent.
   A ricardói háztartások ettől gazdagabbak: többet fogyasztanak, és a modell erős vagyonhatása miatt
   (`sigma/(1−habit) ≈ 5,1` a bérigényben) kevesebbet akarnak dolgozni. A reálbér +5,5%-kal nő.
2. **A cégek a drágább munkát import inputra cserélik.** A foglalkoztatás −3,0%, az import (a modellben
   csak köztes input) +0,38%.
3. **A reálárfolyam felértékelődik** (−0,91%), ezért az export külföldön drágább, és −0,46%-kal csökken.

Ez a felbontás utólagos, nem a futtatás előtt rögzített várakozás.

Mindez feltevésfüggő:

- a modellben a kormányzati fogyasztásnak nincs haszna;
- az adó egyösszegű;
- a munka súlya a nem-tőke inputban kicsi (`aa_j ≈ 0,12–0,14`), ezért a cégek könnyen cserélik importra.
  Ennek az Opten-mérését egy külső review fogalmilag vitatta. Ezen és a `rho_z`-n a foglalkoztatási
  szám (−3,0%) is múlik.

**Ha a megtakarítást szja- vagy járulékcsökkentésként adnánk vissza (6. blokk), a munkakínálat nőne, és
a GDP-hatás előjele megfordulhatna.** Ezért a GDP-előjelet nem érdemes robusztus eredményként közölni,
a fogyasztási számokat pedig egyáltalán nem.

### 6.3 Miért nem segít a megszorítás az inflációnak?

*Javítva 2026-10-31: az első változat csak a keresleti oldalt írta le.*

A „költsön óvatosan az árstabilitás miatt” érv a modellben a `g`-n keresztül nem működik: az 1–3. évi
inflációt a megszorítás −0,004 pp-tel változtatja. Az infláció a határköltséget követi, és az is alig
mozdul (1–3. év átlaga: −0,24% az exportorientált KKV-knál, −0,04% a hazai KKV-knál, −0,12% a
nagyvállalatoknál). Két ok van:

1. **Kereslet:** a ricardói háztartások a kieső állami keresletet előre, már a felfutás alatt saját
   fogyasztással pótolják. A hazai termékekre jutó kereslet az 1. évben még nő is (+1,08%), és a GDP is
   (+0,10%).
2. **Költség:** a reálbér nő, de a felértékelődés miatt az import input olcsóbb. Mivel a munka súlya a
   nem-tőke inputban kicsi (`aa_j ≈ 0,12–0,14`), a kettő nagyjából kiegyenlíti egymást.

Ez tehát az `aa_j`-n és a teljes hitelességen (a háztartások azonnal elhiszik a tartós megszorítást) is
múlik. A dezinflációt az euró bejelentése adja (−0,60 pp). Ha a megszorítás a likviditáskorlátos
háztartásokat érintené (transzfer- vagy nyugdíjcsökkentés), az dezinflációs lehetne. Ezt a nyugdíjblokkal
(`PENS=1`) ki lehetne próbálni.

### 6.4 A hiánykritérium az adószabályon múlik

*Javítva 2026-11-01. Az első változat azt írta, hogy `PHIB = 0,02` mellett „nincs adócsökkentés”, és hogy
a hiány egy 6%-os kiindulásból a 3. évre 3% alá megy. Mindkettőt visszavontam.*

A mostani adósságszabály (`PHIB = 0,05`) a csökkenő adósság után automatikusan egyösszegű
adócsökkentést ad. Ez pont az ellentéte az „óvatos költésnek”, és a hiánycsökkenést a 10. évre
1,65 pp-re olvasztja.

**A `PHIB = 0,02` ezen nem segít, csak lassít.** A szabály (`tls = phi_b·bg(−1)`) ugyanúgy adót csökkent,
ha az adósság csökken, csak lassabban. Az adósságdinamika gyöke `rgbar − PHIB = 0,995`: technikailag
stabil, de a végállapot gazdaságilag értelmetlen. Az adósság tartósan −225% GDP, és ehhez tartósan a GDP
kb. 18%-ának megfelelő egyösszegű adócsökkentés tartozik. Ezt nem lehet „óvatos fiskális pályának”
nevezni. Ahhoz egy véges ideig tartó, hiány- vagy adósságcélos szabály kellene, explicit terminális
adósságcéllal; ilyen a modellben nincs.

**A 3%-os kritériumról a modell nem tud mondani semmit.** Az 5.3 hiányszámai egy növekedés nélküli modell
hiányváltozásai, nem Maastricht-előrejelzés. Nincs bennük:

- kiinduló ESA-hiányszint;
- nominális növekedési pálya;
- stock-flow korrekció;
- intézményi költségvetési bázis.

Ráadásul a 3. évi csökkenés közel mechanikus: a megszorítás mérete, plusz az euró kamatmegtakarítása,
mínusz az adóvisszaadás. Mivel a megszorítás méretét a kiinduló hiányból választottuk (kiinduló hiány −
3%), a „3% alá megy” a választásból következik, nem a modellből.

Az euró kamatmegtakarítása 5 éves lejárattal lassan épül fel: a 3. évben csak 0,45 pp. Egynegyedéves
adóssággal 1,19 pp lenne, de ez túl optimista.

Két korlát:

- A modellben **nincs növekedés**. A tartósan kisebb adósság ezért a hiányt hosszú távon itt nem
  csökkenti; a valóságban a nominális GDP-növekedés miatt igen. A 10. év utáni hiányszámok tehát
  alulbecsülik a csökkenést; az 1–5. évre a két fogalom közel azonos.
- A `PHIB = 0,02` tartós adósságértéke (−225% GDP) értelmetlen, abból csak a 20 éven belüli pálya
  használható.

### 6.5 Más méretű megszorítás

A modell lineáris (K4), és az adószabály a reálváltozókat nem érinti (K3). Bármely `D` méretre
(százalékpont) ezért:

```
GDP(EK, D) = GDP(E) + (D/3)·[GDP(EK, 3) − GDP(E)]
GDP(K, D)  = (D/3)·GDP(K, 3)
```

Tehát a 16–20. évben a megszorítás GDP-költsége **kb. 0,18% minden 1 pp után** (0,54/3), az EK
GDP-hatása pedig kb. `0,52 − 0,18·D`. Az EK hatás `D ≈ 2,9 pp`-nél megy át nullán.

*Ez a modell mostani mechanikája, nem szakpolitikai eredmény: a torzító adókon, az `aa_j`-n és a teljes
hitelességen múlik (lásd 6.2, 6.3 és 7.).*

## 7. Mit lehet közölni, mit nem

*Javítva 2026-11-01 a külső review után: az első változat a pp-enkénti GDP-költséget és a „3. évre 3%
alá” állítást is közölhetőnek mondta.*

**Közölhető (feltételesen, a feltételekkel együtt):**

- az euró feltételes rezsimhatása azonos fiskális pálya mellett: 0,517–0,519 pp a 16–20. évben, alig
  tér el a megszorítás nélküli 0,520-tól. Nem a csatlakozás teljes hatása (lásd 6.1).

**Belső diagnosztika, nem közölhető**, amíg nincs torzító munkapiaci adóék (6. blokk),
`aa_j`-érzékenység és nem teljesen hiteles (nem teljes előrelátású) futás:

- a megszorítás saját GDP-költsége (K és EK), a pp-enkénti kb. 0,18% is;
- a foglalkoztatási és reálbér-számok;
- az, hogy a megszorítás „nem segít az inflációnak”.

**Nem közölhető:**

- a fogyasztási számok (a feltevések termékei);
- a GDP-előjel mint robusztus eredmény (a 6. blokkon múlik);
- a „3. évre 3% alá megy” (visszavonva, lásd 6.4);
- a 10. év utáni hiányszámok (nincs növekedés);
- a `PHIB = 0,02` futás mint „óvatos fiskális pálya”, és a tartós adóssága.

## 8. Eltérés a te Python-vonaladtól

Ezek a számok az **aktív v11**-ágon készültek. Ennek beállítása: `KALIB=1, EXTCLOSE=1, SOVCSAT=1`.
A te vonalad a régi zárást reprodukálja (`-DKALIB=0 -DEXTCLOSE=0 -DSOVCSAT=0`), ott az euró hatása is
más. Ha nálad is be akarod tenni, az átvétel egyszerű:

- egyetlen egyenlet módosul (a `g`, lásd 3.);
- jön egy exogén pálya (`kons`);
- a hiányt utólag kell számolni a meglévő változókból.

Ha a két vonal számait össze akarjuk vetni, a v11-et a régi beállítással is le tudom futtatni.

## 9. Ami még nincs benne

1. **Torzító adók (6. blokk):** ezen múlik a GDP-előjel.
2. **Transzfer- vagy nyugdíjalapú megszorítás** (`PENS=1`): a likviditáskorlátos háztartásokon keresztül
   erősebb rövid távú és inflációs hatás.
3. **Ütemezés:** euróval gyors (8 negyedév), euró nélkül lassabb (kb. 4 év) megszorítás. Ez mérné azt,
   ami ténylegesen az euróhoz köthető: a konszolidáció gyorsítását.
4. **Növekedéssel konzisztens hiánymutató** a hosszú távú hiánypályához, és egy dokumentált kiinduló
   ESA-hiányból induló híd.
5. **Hiány- vagy adósságcélos fiskális szabály** a `PHIB`-szabály helyett (lásd 6.4).
6. **Érzékenységi rács** az `aa_j`-re, a `rho_z`-re, a hitelességre és a közkiadás hasznára.

Hogy ezekből mi készüljön el, csapatdöntés: a review azt javasolja, hogy a fiskális blokk ne bővüljön
tovább (lásd a döntési lista 6. pontját).

Az alapértelmezés (`KONSZ=0`) megváltoztatása, és hogy melyik méret legyen a központi eset, csapatdöntés.

## 10. Futtatás

```
matlab -batch "cd('src/modell/1_fo_vonal_jv/futtato'); check_konsz_v11"
```

A 13 futás néhány másodperc alatt lefut. Kimenet:

- `output/tables/t67_konsz_racs.csv`: futásonként BK és fő mutatók;
- `output/tables/t67b_konsz_osszegzes.csv`: K1–K5 és a közölt számok;
- `output/tables/t67c_konsz_palyak.csv`: negyedéves pályák a 80. negyedévig, 3,0 pp-es eset.

Egy futás kézzel, például euró + 3 pp megszorítás, 5 éves lejárattal és visszafogott adószabállyal:

```
dynare jv_dsge_v11 -DFISCAL=1 -DKONSZ=1 -DKONSZD=3 -DRHOM=0.95 -DPHIB=0.02
```

---

**Források a hiányadatokhoz:**

- [KSH: a GDP-arányos hiány 4,7% volt 2025-ben](https://www.ksh.hu/gyorstajekoztatok/krm/krm2512.html)
- [Economx: Eurostat-rangsor, 2026. október](https://www.economx.hu/gazdasag/2026/10/21/eurostat-europai-unio-gdp-allamadossag-hiany/)
- [FXStreet / Standard Chartered: a magyar euróbevezetés a fiskális pályán múlik](https://fxstreet.com/news/hungary-euro-adoption-plans-hinge-on-fiscal-path-standard-chartered-202610141347)
- [Intellinews: a Költségvetési Tanács szerint komoly kiigazítás kell](https://www.intellinews.com/hungary-s-fiscal-council-warns-severe-austerity-needed-after-election-year-spending-binge-418136/)
