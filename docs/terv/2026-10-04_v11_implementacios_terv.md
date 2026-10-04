# v11 — specifikációs javítások a kontraintuitív eredmények nyomán — implementációs terv

*2026-10-04 · Tomi. Állapot: **2. VÁLTOZAT, az 1. review-kör után.** Nem része a
2026-10-05-i workshopnak: a workshop a v09/v10 jelenlegi állapotát mutatja be, a
v11 külön munkafolyamat.*

*Előzmény: a v10 validálása (`t56`, A24) és a szimmetrikus-χ küszöbmérés (`t58`,
A25) négy kontraintuitív eredményt hozott. Ez a terv rögzíti, melyikből lesz
modellmódosítás, melyikből audit, és milyen előre rögzített szabályok mellett.*

> **1. review-kör (2026-10-04, adversarial; a válasz:
> [`2026-10-04_v11_terv_review_1kor.md`](2026-10-04_v11_terv_review_1kor.md)).**
> Verdikt: az első változat „jelen formájában nem implementálható”. Mind az 5
> súlyos, a 10 közepes és a 4 apró pontot ellenőriztük (kettőt közvetlenül a
> kódon: S4 és K1), és mindet elfogadtuk. A legfontosabb változások:
>
> 1. **A K-1 „nem módosítjuk” döntését visszanyitottuk.** Az algebra helyes,
>    de a „standard BGG-tulajdonság” indoklás nem volt igazolva. A K-1 most
>    audit (W0), és addig a jelenség a **jelenlegi redukált log-lineáris
>    specifikáció tulajdonsága**, nem strukturális következtetés (S1).
> 2. **Új általános korlát:** minden „tartós” eredmény a log-lineáris rendszer
>    permanens forcing melletti fixpontja, nem egy nemlineáris modell új
>    steady state-je. Ez a projekt összes tartós állítására vonatkozik (S3).
> 3. **Az `ACCSPEC=1` csak szintbeli aggregációból levezetve fogadható el** (S2),
>    az `ACCSPEC=2` csak feltáró ág (K5).
> 4. **A W1 automatikus „40 negyedéves győztes” szabályát elhagytuk** (K2).
> 5. **A W3 nettó, fedezetlen devizakitettségre épül, és két lépcsős** (K6, K7);
>    elfogadása nem függ a GDP-válasz előjelétől (K8).
> 6. **A horizont a spektrális felezési időhöz kötve** (S5); a szimmetria- és a
>    beágyazási teszt újradefiniálva (S4, K10).
> 7. **Új sorrend:** W0 → W2a a változatlan v10-en → W1 → W2a ismét → W2 → W3 (K3).

---

## 0. A legfontosabb szabály: ez nem eredmény-javítás

A v11 célja **nem** az, hogy a kontraintuitív eredmények eltűnjenek, vagy hogy a
KKV-előny „szebb” legyen. A cél azoknak a specifikációs hiányosságoknak a
javítása, amelyek **elméleti vagy adatbeli okból** hibásak, attól függetlenül,
merre viszik az eredményt. Négy szabály:

1. **Előzetes rögzítés.** Minden változtatás indoklása, specifikációja és
   elfogadási feltétele ebben a dokumentumban van, *mielőtt* a v11-et
   lefuttatjuk. Ha futtatás után specifikációt kell váltani, az új verziót
   indoklással ide kell felvezetni, és a régi eredményét is közölni kell.
2. **Kapcsoló, nem felülírás.** Minden változás makró-kapcsoló mögé kerül.
   Alapértelmezésben mind KI, és ekkor a v11 bitre a v10. Az új alapértelmezés
   csapatdöntés, külön lépésben.
3. **A technikai elfogadási feltételek nem tartalmazzák az eredmény irányát.**
   BK-stabilitás, regresszió, beágyazás, nulla-sokk: igen. „A KKV nyerjen”,
   „az EKB-átgyűrűzés legyen 1”, „a GDP-válasz legyen negatív”: **nem**. A
   plauzibilitási mérőszámokat (7.2) mindig közöljük, de nem célozzuk őket.
4. **Kedvezőtlen eredményt is közlünk.** Ha egy indokolt javítás csökkenti
   vagy eltünteti a KKV-előnyt, az ugyanúgy regiszter-sor és őr lesz.

**A review tanulsága ehhez:** az előzetes rögzítés szükséges, de nem elégséges.
Egy előre rögzített, de önkényes szabály (például egy numerikus célból választott
küszöb) ugyanúgy lehetővé teszi az eredményhangolást. Ezért minden választási
szabálynak közgazdasági vagy adatbeli indoklás kell, nem numerikus kényelem.

---

## 1. Kiinduló diagnózis: a négy kontraintuitív eredmény

| # | Eredmény | Forrás | Ami bizonyított | Ami nem |
|---|---|---|---|---|
| K-1 | Tartós felárcsökkenésnél a saját tőke csökken, a tőkeáttétel nő, és a χ-tag visszaveszi a felárcsökkenés egy részét. A nagyobb χ a KKV-t bünteti; szimmetrikus χ mellett nincs KKV-küszöb. | A25, `t58` | Az algebra: a redukált nw-egyenlet tartós fixpontja `nw = omega_nw·lev·efp/(1−omega_nw)`, és a mért számok ezt visszaadják. | Hogy ez a teljes (nemlineáris) BGG-modell tulajdonsága is: a redukált egyenletből hiányzik a vállalkozói munkajövedelem / belépő transzfer és a túlélők–belépők aggregálása (review S1). |
| K-2 | Euróban az EKB-kamat becsapódáskor csak 0,69–0,73-szorosan gyűrűzik át (+25 bp negyedéves ≈ +100 bp évesített sokk). | F07, `t56` | A 838. sor `nu_uni·bstar` tagja viszi, az aznapi `bstar`-ral. | – |
| K-3 | Forintban egy +25 bp negyedéves (≈ +100 bp évesített) külföldi kamatemelés becsapódáskor növeli a GDP-t (+0,19%). | `t56` | Leértékelődés → export, a Taylor-szabály nem követi az `r_for`-t. | Hogy ez hiba-e: **önmagában nem az** (review K8). A devizaadósság hiányzó csatorna, de a helyes összhatás előjele nem adott előre. |
| K-4 | A GDP-pálya évtizedekig alig csillapodó, kb. 28 negyedéves ciklusban leng (|z| = 0,9941, amplitúdó-felezési idő kb. 117 negyedév). Jobb hozzáférés mellett a tartós Tobin-q negatív. | diagnosztika | A q-hatás pontosan következik a beruházási egyenletből (D.2 az adatcsomagban). `ACCSCALE=0` mellett |z| = 0,92, tehát a hozzáférési hurok fontos. | Hogy kizárólag az additív hozzáférési tag okozza a ciklust: lehet benne a `rho_acc`, az `omega_nw`, a beruházás lead–lag szerkezete, a ψ, a BGG-visszacsatolás és a külső zárás is (review K4). |

### 1.1 Mi lesz ezekből

| # | Döntés | Indoklás |
|---|---|---|
| K-1 | **W0: strukturális audit, a v11 kapuja.** Addig: nem módosítjuk, és nem is állítjuk, hogy helyes. | A review S1 szerint a „nem módosítjuk, mert standard BGG” indoklás elégtelen volt. A χ alapértelmezése (K01) ettől függetlenül csapatdöntés; minden v11-eredményt mindkét χ-változattal közlünk. |
| K-2 | **W1.** | Technikai zárás, amelynek értékét részben a v03 GDP-hatásának visszaadására választották (`diag_nuuni_v05.m`), és amely az EKB-átgyűrűzés 30%-át viszi. |
| K-3 | **W3**, de nem a GDP-előjel miatt. | A devizaadósság mérlegcsatornája hiányzik, és magyar adattal kalibrálható. A W3 elfogadása a nettó kitettség adatán és a mérlegazonosság helyességén múlik, nem azon, hogy a GDP-válasz előjele megfordul-e. |
| K-4 | **W2a diagnosztika, utána W2.** | A q-hatás funkcionális forma, nem mechanizmus; a ciklus okát előbb mérni kell. |

### 1.2 Ami kifejezetten NEM a v11 része

- **A χ és a tőkeáttétel alapértelmezése** (K01, K02): kalibrációs csapatdöntés.
- **Az `aa_j` / `zeta_j` KSH-pótlása:** adatmunka. A 2026-10-04-i diagnosztika
  szerint szimmetrikus χ és `ACCSCALE=0` mellett a maradék KKV-előny főleg az
  `aa_j`-ből jön, ezért ez fontosabb lett.
- **Az 50%-os E/D szegmentáció szerinti újrakalibrálás.**
- **Az `e_x` és az `ystar` szétválasztása, sztochasztikus becslés.**

### 1.3 Általános korlát, amely a v11-től függetlenül érvényes (review S3)

A modell egyetlen, a kiinduló steady state körül log-linearizált rendszer, és
nemlineáris változata nincs a repóban. A perfect-foresight futás „záró
egyensúlya” (`endval`) ezért **a log-lineáris rendszer permanens forcing melletti
fixpontja**, nem egy nemlineáris modell új steady state-je. Nagy, permanens
változásnál (felár, rezsim, kamat) ez közelítés, amelynek a pontosságát nem
mértük. Ez nem csak a v11-re, hanem a projekt minden „tartós” állítására
vonatkozik, a +0,52…+1,18%-os GDP-sávra (A01) is. Javasolt teendő a regiszterben:
korlátként rögzíteni, és a „tartós hatás” helyett a pontosabb megnevezést
használni, ahol ez számít.

---

## 2. Tervezési döntések

| # | Kérdés | Döntés | Miért |
|---|---|---|---|
| D1 | Fájl | `jv_dsge_v11.mod` = a v10 másolata, kapcsolókkal. A v09/v10 érintetlen. | A v10 validált (A24). |
| D2 | Alapértelmezés | `-DNUCLOSE=0`, `-DACCSPEC=0`, `-DFXDEBT=0`: mind ki, ekkor a v11 **bitre a v10**. | 0. szakasz, 2. szabály. |
| D3 | Sorrend | **W0 → W2a(v10) → W1 → W2a(W1) → W2 → W3a → W3b** | Review K3: a ciklus-diagnosztika először a változatlan v10-en fusson, hogy tiszta kiinduló mérés legyen. |
| D4 | χ-változatok | Minden v11-eredmény két χ-változattal: aszimmetrikus és `CHISYM=0.04`. | A25: az eredmény a K01-től függ. |
| D5 | Kombinációk | Minden csomag külön, páronként és mind együtt. | A hatások szétválaszthatósága. |
| D6 | Alapértelmezésről | A csapat dönt, a v11 eredményeinek ismeretében. | `CLAUDE.md`, munkamódszer 4. |
| D7 | Horizont | A szimulációs horizont a leglassabb releváns gyök amplitúdó-felezési idejének legalább négyszerese, de legalább 120 negyedév. A v10 alapágában (|z| = 0,9941, felezési idő ≈ 117) ez ≈ 470 negyedév. | Review S5: a horizontot kell a perzisztenciához igazítani, nem fordítva. A négyszeres szorzó mellett a maradék amplitúdó ≤ 1/16. |

---

## 3. W0 — a K-1 strukturális és steady-state auditja (a v11 kapuja)

### 3.1 Kérdés

A redukált nw-egyenlet (713. sor):
`nw_E = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl)))`
tartós fixpontja `nw = omega_nw·lev·efp/(1−omega_nw)`. A kérdés: **a teljes BGG
nemlineáris nettóvagyon-egyenletéből levezetve is ezt kapjuk-e**, vagy a redukált
alakból hiányzó elemek (vállalkozói munkajövedelem vagy belépő transzfer, a
túlélők és a belépők aggregálása, a tőkeállomány skálázódása) megváltoztatják a
tartós viselkedést?

### 3.2 Lépések

1. A BGG (1999) nemlineáris nettóvagyon-egyenletének felírása az itt használt
   jelölésekkel, a JV-forrás (MNB WP 2008/9) megfelelő egyenletével összevetve:
   honnan jön a redukált alak, mit hagytak el, és milyen feltevéssel.
2. A túlélési arány (`omega_nw`), a vállalkozói jövedelem / transzfer és a
   belépők saját tőkéjének azonosítása a levezetésben.
3. A tartós egyensúly kiszámolása a nemlineáris egyenletből, permanens
   prémiumcsökkenésre: mi történik a `N/K`-val? Iránya és nagyságrendje
   összevetve a redukált fixponttal.
4. Döntés, előre rögzített szabállyal:
   - ha a nemlineáris levezetés **ugyanazt az irányt** adja, és a nagyságrend a
     redukált fixpont ±50%-án belül van: a K-1 a modell tulajdonsága, nem
     módosítjuk, és a levezetést a regiszterbe tesszük;
   - ha **ellentétes irányt** ad, vagy a nagyságrend ennél jobban eltér: a
     nw-egyenletet a levezetett alakra cseréljük (`-DNWSPEC=1` kapcsoló), és ez
     W0b munkacsomag lesz.

   A ±50% azért ilyen tág, mert a kérdés minőségi (irány és nagyságrend), nem
   a pontos szám; ezt a futtatás előtt rögzítjük.
5. Addig az A25 kommunikációja: „a jelenlegi redukált specifikáció
   tulajdonsága”, strukturális BGG-következtetésként nem.

### 3.3 Munka

Kb. 1–2 nap (levezetés, a JV-forrás összevetése). Ha W0b kell: +2 nap.

---

## 4. W1 — a valutaunió külső zárása (`-DNUCLOSE`)

### 4.1 Probléma és definíciók

A 829. sor: `bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im)`. A
kereskedelmi többlet növeli, tehát a `bstar` **nettó külföldi eszközállomány
(NFA), időszak végi állomány**, a GDP-hez normalizálva, és az előző időszaki
állományt `1/beta` hozam terheli. (Az első változat „adósság-rugalmas prémiumról”
beszélt, ez pontatlan volt: review K1.)

A 838. sor euró-ága: `r = r_for + zsov·sov − nu_uni·bstar`, az *aznapi*
`bstar`-ral. Magasabb NFA alacsonyabb hazai kamatot jelent, ez az előjel
helyes. A gond az időzítés és a nagyság: egy EKB-kamatemelés még abban a
negyedévben javítja a mérleget, és a zárás azonnal visszahúzza a kamatot.

### 4.2 Specifikáció

```
@#if NUCLOSE == 1
    + uni*(r - r_for - zsov*sov + nu_uni*bstar(-1)) = 0;
@#else
    + uni*(r - r_for - zsov*sov + nu_uni*bstar) = 0;
@#endif
```

A `bstar(-1)` **saját modellválasztás**: Schmitt-Grohé–Uribe (2003) 2. modelljében
a kamat az aktuális aggregált adósság függvénye, tehát a cikk ezt az időzítést
nem támasztja alá közvetlenül (review K1). Indoklásunk: a zárás a már
felhalmozott pozícióra reagáljon, ne az aznapi kereskedelmi mérleg algebrai
visszacsatolására. Mindkét időzítést közöljük.

### 4.3 A `nu_uni` értéke — automatikus választás nélkül

- Teljes rács: `nu_uni ∈ {0.001, 0.005, 0.01, 0.05, 0.10, 0.25}`, mindkét
  `NUCLOSE`-időzítéssel, mindkét χ-változattal.
- Minden rácspontra közöljük: BK mindkét rezsimben; a `bstar` felezési ideje;
  **az implikált kamatváltozás 1 GDP-százalékpontos NFA-változásra** (review A1);
  EKB-átgyűrűzés; tartós GDP; KKV−L.
- **Nincs automatikus győztes** (review K2). Az alapértelmezési javaslat két
  forrás egyikéből jöhet, ebben a sorrendben:
  1. külső becslés a magyar (vagy régiós) szuverén felár és az NFA/külső adósság
     kapcsolatára, a mi normalizálásunkra átszámolva;
  2. ha ilyen nincs: kifejezetten „csak stacionaritást biztosító, kis technikai
     normalizáció”, a lebegő ági `nu_b = 0,001`-gyel azonos érték, hogy a két
     rezsim zárása ne térjen el 250-szeresen.
- A felezési idő csak diagnosztikai jelző, nem választási szabály.
- **Közös zárási benchmark** (review hiányzó ellenőrzés 9.): legalább egy futás,
  amelyben a két rezsim zárása azonos kis `nu`-val megy, hogy az unió–lebegő
  különbséget ne a technikai zárás vezesse.

### 4.4 Munka

Kb. 1 nap.

---

## 5. W2 — hol lép be a hitelhozzáférés

### 5.1 Probléma

A 723. sor körüli beruházási egyenlet a JV/CEE-alak, amelyben a beruházás saját
együtthatóinak összege 1. Egy tartós `omega_acc·acc` forcing-tagot ezért
hosszú távon csak a q-tag tud ellensúlyozni: jobb hozzáférés mellett a tartós
Tobin-q negatív. Ez a funkcionális forma következménye.

### 5.2 W2a — ciklus-diagnosztika (kétszer: a változatlan v10-en, majd W1 után)

1. A domináns komplex gyök **követése** (root tracking) rácsokon:
   `ACCSCALE ∈ {0, 25, 50, 100}`; `rho_acc`, `omega_nw`, `psi_j` külön-külön
   rácsozva; `lambda_acc` és `omega_acc` külön, valamint **a λ·ω szorzatot tartó**
   skálázással (review K4).
2. **Normalizált részvételi tényezők** a domináns gyökre (participation
   factors), nem nyers sajátvektor-komponensek, mert azok skálafüggők.
3. Kimenet: `t59_ciklus_diagnosztika.csv`.

Ha a diagnosztika szerint a ciklust nem (elsősorban) a hozzáférési tag hajtja,
azt ide felvezetjük, és a „W2 megszünteti a ciklust” várakozást elvetjük. A W2
indoklása ettől nem dől el, mert a q-hatás önmagában is indok.

### 5.3 `ACCSPEC=1` — csak szintbeli levezetés után

A review S2 szerint a korábbi `i = i_tilde + omega_acc·acc` alak **nem**
általánosan helyes log-linearizálás. A helyes út:

1. **Szintbeli azonosság:** `I_j = A_j·I_j^c + (1 − A_j)·I_j^n`, ahol `A_j` a
   hitelezett cégek aránya, `I^c` egy hitelezett, `I^n` egy nem hitelezett cég
   átlagos beruházása.
2. **Az `acc` mértékegysége:** az `A_j` log-eltérése (`acc = Â/A`), vagy
   százalékpontos eltérése. Előre rögzítve: **log-eltérés**, mert a többi
   változó is az.
3. **Log-linearizálás:** `i_j = s_j·(i^c_j + acc_j) + (1 − s_j)·(i^n_j − A_j/(1−A_j)·acc_j)`,
   ahol `s_j = A_j·I^c/I` a hitelezett cégek beruházási részesedése a steady
   state-ben. Az `acc` együtthatója így `s_j − (1−s_j)·A_j/(1−A_j)`, ami a
   steady-state adatokból jön, nem szabad paraméter.
4. **Szükséges adatok típusonként** (Opten-panelből): a bankhitellel rendelkező
   cégek aránya (`A_j`), és a hitelezett, illetve nem hitelezett cégek átlagos
   beruházása. A `van_hitel` és a beruházás mezői a panelben megvannak; ezt az
   implementáció előtt ellenőrizni kell.
5. **Ha az adatok nem állnak elő:** az `ACCSPEC=1` csak „dokumentált redukált
   forma”, érzékenységi sávval, és nem nevezzük levezetett összetételi
   egyenletnek.

A levezetés és az adatellenőrzés **az implementáció előtt** kerül ebbe a
dokumentumba (5.3a alszakaszként).

### 5.4 `ACCSPEC=2` — csak feltáró ág

A hozam-forma (`ret(+1) = r − π(+1) + efp − omega2·acc`) a review K5 szerint
új pénzügyi visszacsatolás, nem az extenzív margó alternatív elhelyezése, és
kettős beszámításhoz vezethet. Ezért **külön paraméterrel** (`omega2_acc_j`),
„exploratory robustness” címkével, nem az 1-es egyenrangú versenytársaként.

### 5.5 Ami megmarad, és amit ellenőrizni kell

- **Beágyazás** (review K10): `ACCSCALE=0` mellett a v08 **közös endogén
  változóinak** pályája, reziduumai és riportált eredményei egyeznek. Az új
  segédváltozókat (`i^c`, `i^n`) külön ellenőrizzük. A BK előretekintő
  változóinak számát nem keménykódoljuk.
- A λ·ω-azonosítás az új formában is mérendő, és feltételes állításként
  rögzítendő: csak addig igaz, amíg az `acc` egyetlen helyen lép be, és nincs
  rá megfigyelési egyenlet (review A3).
- A KKV-küszöb újramérése mindkét formában és mindkét χ-változattal.

### 5.6 Munka

Kb. 3–4 nap (levezetés, adatellenőrzés, diagnosztika, két forma).

---

## 6. W3 — devizaadósság (`-DFXDEBT`), két lépcsőben

### 6.1 Probléma

A devizában eladósodott vállalatnál a leértékelődés a hazai pénzben mért
adósságot is növeli. Ez a csatorna hiányzik, magyar adaton releváns, és az
euró szempontjából érdemi. **A review K8 alapján:** a csatorna felvétele nem
azt jelenti, hogy a külföldi kamatemelés GDP-hatásának negatívnak kell lennie;
Céspedes–Chang–Velasco (2004) is két ellentétes csatornát hangsúlyoz.

### 6.2 W3a — csak átértékelés, „részleges” címkével

```
@#if FXDEBT >= 1
nw_E = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl))
       - (lev_E - 1)*fx_E*dep);
@#else
nw_E = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl)));
@#endif
```

(D és L ugyanígy.) A review K6 szerint az előjel és az elsőrendű skála helyes,
ha `lev = eszköz/saját tőke`, `dep > 0` leértékelődés, és a kitettség fedezetlen.
**Címke:** „partial — csak átértékelés”; a devizaadósság kamatoldala nincs
benne, ezért ez nem teljes devizaadósság-blokk.

### 6.3 W3b — konzisztens finanszírozási költség (ha levezethető)

A devizaadósság törlesztési költsége a külföldi kamattól, a felártól és az
árfolyamváltozástól függ. A W3b a nw-egyenletben az adósság finanszírozási
költségét a forint- és a devizaadósság súlyozott költségére cseréli. Kötelező
ellenőrzés: perfect foresight alatt a várt leértékelődés és az UIP miatt **ne
legyen kettős `dep`-hatás** (review K7). Ha ez nem vezethető le tisztán, a W3b
elmarad, és ezt rögzítjük.

### 6.4 Az `fx_j` definíciója és adata (review K6)

- **Definíció:** effektív, **nettó, fedezetlen** devizakitettség a saját tőkéhez
  viszonyított adósságon belül: devizakötelezettség − devizaeszköz − derivatív
  fedezet − a természetes exportbevétel-fedezet releváns része.
- **Ha csak bruttó devizahitel-arány van** (pl. MNB-hitelstatisztika): az
  **felső korlát** vagy külön bruttó-expozíciós forgatókönyv, nem pontbecslés.
- **Érzékenységi rács:** `fx = 0`; közös aggregált érték; méret szerinti érték
  (ha van adat); bruttó felső korlát.
- Előre rögzítve: a legutóbbi rendelkezésre álló év adata, nem több év közül a
  legkedvezőbb.

### 6.5 Csatlakozás: nincs külön mérlegugrás — explicit feltevés (review K9)

**Feltevés:** az euró bevezetésekor az eszközök és a kötelezettségek ugyanazon,
előre várt átváltási árfolyamon redenominálódnak, nincs konverziós meglepetés és
nincs szerződéses aszimmetria. Ezért a belépéskor nincs önálló vagyonhatás, és a
`dep = 0` miatt utána a tag kikapcsol. Eltérő konverziós ráta vagy nyitott pozíció
esetén ez a feltevés nem áll.

### 6.6 Munka

W3a: kb. 2 nap + adat. W3b: +2–3 nap, ha levezethető.

---

## 7. Ellenőrzési terv és elfogadási feltételek

### 7.1 Technikai elfogadás — kötelező

1. **Regresszió:** minden kapcsoló KI → a v11 bitre a v10, SC=1..4.
2. **BK** a kezdeti (`uni=0`) és a záró (`uni=1`) rezsimben is; az előretekintő
   változók számát a modellből olvassuk, nem keménykódoljuk.
3. **Nulla-sokk** (`SCENARIO=4`): minden változó végig 0.
4. **Szimmetria, újradefiniálva** (review S4; a kódban ellenőrizve: a `SYM=1` a
   nagyvállalatnak nem ad `acc`-egyenletet):
   - teljes E=D=L szimmetria csak `ACCSCALE=0` és közös `fx` mellett;
   - bekapcsolt hozzáférésnél csak E=D szimmetria; az L-re előre definiált
     eltérés.
5. **Beágyazás:** `ACCSCALE=0` → v08, a közös változókon (5.5).
6. **W3-beágyazás:** `fx = 0` pontosan a W3 nélküli közös változókat adja;
   `dep = 0` mellett az átértékelési tag nulla; nincs kettős árfolyamhatás.
7. **Horizont és terminális reziduum** (review S5): a D7 szerinti horizonttal;
   a célváltozók pályája a teljes közölt ablakon stabil (a horizont duplázására
   < 0,01 pp eltérés); a horizont végén az állapot az `endval` közelében van; a
   terminális reziduumok kicsik. A 120 negyedév a jelenlegi specifikáció mellett
   **nem** referenciahorizont.
8. **Izolált sokkteszt:** `r_for`-sokk mellett minden más külső sokk nulla; a
   sokk negyedéves és évesített mérete dokumentálva (review A2).

### 7.2 Plauzibilitási mérőszámok — közöljük, NEM célozzuk

A v10 és a v11 minden változata egymás mellett, mindkét χ-változattal:

| Mérőszám | v10 érték (2026-10-04) |
|---|---|
| Domináns komplex gyök modulusa, periódusa, amplitúdó-felezési ideje | 0,9941; 28 n.év; ≈117 n.év |
| Tartós Tobin-q a hozzáférési csatornával (E / D) | −2,6% / −2,9% |
| EKB-átgyűrűzés euróban, becsapódáskor (+100 bp évesített sokk) | 0,69–0,73 |
| Külföldi kamatemelés GDP-hatása forintban, becsapódáskor (+100 bp évesített) | +0,19% |
| Implikált kamatváltozás 1 GDP-pp NFA-változásra, euróban | `nu_uni` = 0,25 mellett; W1-ben számolandó |
| Tartós GDP-hatás (SC=1, TSCEN=3) — a log-lineáris fixpont (1.3) | +0,84% |
| KKV−L tartós különbség és KKV-küszöb | t48b / t58b |

Ha egy csomag után valamelyik mérőszám rosszabb lesz, azt ugyanúgy közöljük, és
a csomag indoklását nézzük újra, nem az értékét hangoljuk.

---

## 8. Infra és regiszter

- **Most, a v11-től függetlenül:**
  - az A25 megjegyzésébe: a mechanizmus a jelenlegi redukált log-lineáris
    specifikáció tulajdonsága, strukturális BGG-tulajdonságként nem igazolt;
  - **javaslat a csapatnak:** új korlát-sor a regiszterbe az 1.3 szerint (a
    „tartós” állítások log-lineáris fixpontok). A regiszter státuszrendszerébe
    (áll / feltételes / visszavont) ez nem illik bele, ezért a formáját a
    csapat dönti el.
- `docs/regiszter/parameterek.csv`: az új paraméterek (`fx_j`, `omega2_acc_j`)
  és a `nu_uni` új státusza; a `t54` őr frissítése.
- Minden közölt v11-szám regiszter-sor + SZINT-őr, a v10-mintára.
- `check_v11.m` → `t60`: a 7.1 ellenőrzései.
- A v11 nem lesz operatív alapmodell, amíg a csapat nem dönt (D6).

---

## 9. Review-eljárás

1. **1. kör: kész** (2026-10-04), a fenti változások ennek nyomán.
2. **2. kör: ez a 2. változat**, a W0 levezetésével és az `ACCSPEC=1` szintbeli
   levezetésével (5.3a) együtt, *mielőtt* bármit implementálnánk. Kifejezett
   kérdések:
   - A W0 levezetése helyes-e, és a ±50%-os döntési szabály indokolt-e?
   - Az 5.3 log-linearizálása és az együttható helyes-e?
   - A D7 horizont-szabálya elég-e?
3. **Csapat-egyeztetés** (Samu, Évi).
4. **3. kör: a v11 eredményei**, a 7.2 táblával.

---

## 10. Ütemezés

| Időszak | Lépés |
|---|---|
| okt. 6–10. | W0 levezetés; az 5.3a levezetés és adatellenőrzés; 2. review-kör; csapat. |
| okt. 13–17. | W2a a változatlan v10-en; W1 teljes rács; W2a ismét. |
| okt. 20–31. | W2 (`ACCSPEC=1`, feltáró `ACCSPEC=2`); újramért küszöbök. W3 adatgyűjtés párhuzamosan. |
| nov. 3–14. | W3a, és ha levezethető, W3b; `check_v11`; regiszter és őrök. |
| nov. 17–28. | 3. review-kör, csapatdöntés az alapértelmezésről. |
| december | Beépítés a végső anyagba, a döntéstől függően. |

---

## 11. Ami ez a terv után is nyitva marad

- A χ szintje és méret szerinti különbsége: nincs magyar becslés (F04).
- A hozzáférési csatorna ereje (λ·ω): a v11 sem horgonyozza.
- A nemlineáris steady-state pontossága (1.3): nemlineáris modell nélkül csak
  korlátként kezelhető.
- Az `aa_j` / `zeta_j` KSH-pótlása; az 50%-os szegmentáció.
