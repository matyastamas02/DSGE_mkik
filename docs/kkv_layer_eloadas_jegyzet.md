# Előadói jegyzet — a KKV/nagyvállalat szegmentálási layer

*Csapat-prezentációhoz, hétfőre. Alapoktól, lépésről lépésre — úgy
felépítve, hogy alapképzéses közgazdász-háttérrel is követhető legyen.
Minden lépésnél: mi a cél, miért így csináljuk, mi az intuíció.
A végén Q&A-felkészülés és egy javasolt ~15 perces előadás-váz.*

---

## 0. Hogyan használd ezt a jegyzetet

Ez nem a modell technikai leírása (az a `kkv_szegmentalas_layer.html` és a
`.mod` fájlok), hanem **előadói vezérfonal**: a gondolatmenetet építi fel,
hogy magabiztosan el tudd mondani és megválaszold a kérdéseket. A **12.
pontban** van egy kész előadás-váz időzítéssel, a **11.-ben** a várható
kérdések. Ha kevés az időd, olvasd a **félkövér** mondatokat — azok a
gerinc.

---

## 1. A nagy kép — milyen problémát oldunk meg, és miért érdekes

**A projekt kérdése:** hogyan változik a magyar KKV-k hitelkörnyezete, ha
bevezetjük az eurót, és ennek milyen reálgazdasági hatásai vannak?

A modellünk (Jakab–Világi magyar DSGE-je) alapból egyetlen „átlagos"
vállalatot ismer. De ha a kérdésünk KKV-król szól, akkor **a modellben is
külön kell tudni kezelni a kis- és a nagyvállalatot** — különben nincs
mit mondanunk a KKV-król. Ezt a szétválasztást csináljuk meg ebben a
rétegben (angolul „layer", mert a meglévő modellre ráépülő önálló egység).

**Miért nem triviális?** Mert a kérdés nem az, *hogy* kettévágjuk a
vállalatokat (az könnyű: méret szerint), hanem **hogyan viszonyulnak
egymáshoz** — és ez dönti el, mit „csinál" velük az euró-sokk.

> Egy mondatban a csapatnak: *„A layer célja, hogy a modell külön lássa a
> KKV-t és a nagyvállalatot, és — ami a lényeg — lássa, hogyan hatnak
> egymásra."*

---

## 2. Mit jelent az, hogy „szegmentálás a modellben"? (alapoktól)

Egy DSGE-modellben („dinamikus sztochasztikus általános egyensúlyi") a
gazdaság szereplőit egyenletekkel írjuk le: hogyan dönt a háztartás a
fogyasztásról, a vállalat a termelésről és a beruházásról, a jegybank a
kamatról. A modell megoldása megmondja, hogy egy **sokk** (pl. kamat-
változás) hogyan gyűrűzik végig a gazdaságon időben — ezt hívjuk
**impulzusválasznak**.

Alapesetben egy **reprezentatív vállalat** van: minden cég egyforma. Ez
kényelmes, de ha KKV-król akarunk beszélni, hasznavehetetlen — nincs
„kicsi" és „nagy". A **szegmentálás** azt jelenti, hogy a reprezentatív
vállalatot **két típusra bontjuk**, amelyek másban különböznek (méret,
finanszírozás, piac), és így a modell külön impulzusválaszt tud adni a
KKV-ra és a nagyvállalatra.

> Analógia a csapatnak: *„Eddig a modell egy átlagpolgárt ismert. Most
> kettéválasztjuk »kisvállalkozóra« és »nagyvállalatra«, és megnézzük,
> ugyanaz a sokk másképp hat-e rájuk — és hatnak-e egymásra."*

---

## 3. A központi kérdés: versenytárs vagy partner?

Ez a jegyzet legfontosabb gondolata. Amikor kettéválasztunk, el kell
dönteni, **milyen a viszony** a KKV és a nagyvállalat között:

- **Horizontális (versenytárs):** ugyanazt a piacot szolgálják, ugyanazért
  a vevőért versenyeznek. Ekkor egy sokk *átrendezi* köztük a piaci
  részesedést — az egyik nyer, a másik veszít.
- **Vertikális (partner):** a KKV *beszállít* a nagyvállalatnak — a KKV
  köztes terméket gyárt, amit a nagyvállalat felhasznál a végtermékéhez.
  Ekkor egy sokk *együtt* mozgatja őket a láncon keresztül.

**Miért létszükséglet ezt eldönteni?** Mert a kettő teljesen más
eredményt ad. Ha horizontálisnak vesszük, és a KKV kevésbé produktív,
akkor a modell mechanikusan azt fogja mondani, hogy **„az euró leszorítja
a kevésbé produktívat, az meghal"** — és ez az eredmény *előre el van
döntve* a feltevéssel, nem a modell fedezi fel. Ez tudományosan gyenge,
és politikailag is rossz üzenet egy kamarának.

**Az „Audi-kérdés".** Miért van az Audinak beszállítója, miért nem csinál
mindent maga? Mert a kis beszállító **rugalmasabb, specializáltabb**, és
ő nyeli el a keresleti ingadozást. Ez a vertikális viszony létének oka —
és egyben azt sugallja, hogy a magyar valóság inkább vertikális.

> A csapatnak: *„A kulcskérdés: a KKV az Audival versenyez, vagy az
> Audinak szállít? Mert ez dönti el, mit mond a modell."*

---

## 4. A mi válaszunk — és miért (az adat dönt)

**A vertikálist választottuk, és nem hasraütésből: a saját adatunk
mutat rá.** Az Opten-panelból (t02): a **250+ fős cégek 70%-a exportőr,
a 10–49 fősöknek csak 6%-a**. Ez egy **kétszintű, FDI-vezérelt gazdaságot**
ír le: a nagyvállalatok az exportkapuk (jellemzően autó-, akkumulátor-
ipari multik), a KKV-k pedig hazai piacra termelnek — és sok esetben
ezeknek a multiknak szállítanak be. Ez a magyar „duális gazdaság", amit a
szakirodalom is dokumentál.

Ezért a **leképezésünk:**
- **KKV = hazai szektor** (a JV-modell „domestic" szektora),
- **nagyvállalat = export szektor** (a JV „export" szektora).

Ez nemcsak adat-alapú, hanem elegáns is: a JV-modellben **már létezik** a
hazai és az export szektor, tehát nem nulláról építünk — a meglévő
szerkezetre ültetjük a KKV/nagyvállalat értelmezést.

---

## 5. A három megkülönböztetés — egyesével, intuícióval

A KKV és a nagyvállalat háromban tér el a modellben. Mindhárom mögött
adat vagy közgazdasági logika áll.

### 5.1 Pénzügyi: a KKV nehezebben és drágábban jut hitelhez

**Fogalom (alapoktól): pénzügyi akcelerátor (Bernanke–Gertler–Gilchrist,
1999).** A gondolat: egy cég külső finanszírozása (hitel) *drágább*, mint
a belső (saját tőke), és a különbség — a **külső finanszírozási prémium
(EFP)** — annál nagyobb, minél gyengébb a cég mérlege (minél kisebb a
saját tőke a hitelhez képest). Rossz időkben a cégek vagyona esik → a
prémium nő → még nehezebb hitelezni → mélyül a visszaesés. Ez az
„akcelerátor": felerősíti a sokkokat.

**Nálunk:** a KKV érzékenyebb akcelerátorral (`χ_S = 0,06`), a
nagyvállalat tompítottal (`χ_L = 0,02`) — vagyis ugyanaz a mérlegromlás a
KKV-nál nagyobb prémium-emelkedést okoz. Emellett a tőkeáttételük is
eltér (az Opten-mediánokból: KKV 1,6, nagyvállalat 1,85). **Innen jön a
méret-aszimmetria — nem feltételezzük, hanem a paraméterekből endogén
módon adódik.**

> Intuíció: *„A kis cégnek a bank magasabb kockázati felárat számol.
> Ugyanaz a kamatemelés jobban fáj neki."*

### 5.2 Rugalmasság: a KKV könnyebben alkalmazkodik

**Fogalom: beruházási kiigazítási költség.** A modellben a cégek nem
tudják azonnal, ingyen változtatni a beruházásukat — van egy „súrlódás".
Minél nagyobb ez a paraméter (ψ), annál merevebb a cég.

**Nálunk:** a KKV rugalmasabb (`ψ_S = 8`), a nagyvállalat merevebb
(`ψ_L = 13`). Ez az „Audi-logika" a modellben: a kis cég azért jó
beszállító, mert könnyebben alkalmazkodik. **De van egy csavar:** ezt a
rugalmassági előnyt ma a hitelkorlát fojtja (5.1). Az euró oldja a
hitelkorlátot → **felszabadítja a KKV rugalmasságát.** Ez teszi az
eredményt érdekessé és nem-triviálissá.

> Intuíció: *„A kicsi fürgébb, de gúzsba köti a hitelhiány. Az euró
> eloldja a gúzst."*

### 5.3 Vertikális link: a KKV beszállít az exportőrnek

Ez a **fő újítás**. A KKV kibocsátása **input** a nagyvállalat (exportőr)
termeléséhez. Két csatornán működik:

- **Költség-csatorna:** az exportőr határköltségébe beépül a KKV-input
  ára. Ha a KKV olcsóbban termel (mert olcsóbb hitelhez jut), **olcsóbb
  lesz az input az exportőrnek is.**
- **Mennyiségi csatorna:** az exportőr KKV-inputot vásárol, ezért a
  KKV-kibocsátás keresletének része az exportőr rendelése. Ha az export
  fellendül, **több KKV-inputot kér → felhúzza a KKV-t is.**

A kettő együtt teszi a kapcsolatot **pozitív összegűvé:** a KKV egészsége
segíti az exportőrt, és fordítva. Nincs „győztes-vesztes".

> Intuíció: *„Ha a magyar beszállító olcsóbban és többet tud szállítani,
> az Audi is jobban jár. Ez nem nulla összegű játék."*

---

## 6. A mechanizmus lépésről lépésre — mi történik az euróval?

Kövessük végig, mit indít el egy euró-belépéssel járó hitelköltség-
csökkenés (ezt magyarázd el lassan, ez a „sztori"):

1. **Az euró csökkenti a hitelfelárat** (a szuverén és a banki prémium
   esik). Ez a KKV-t jobban érinti, mert neki magasabb volt az EFP-je.
2. **A KKV több beruházást tud finanszírozni** — és mivel rugalmas,
   gyorsan reagál. Nő a KKV-tőke és -kibocsátás.
3. **A KKV határköltsége esik** (olcsóbb tőke) → a KKV-input ára is esik.
4. **Az exportőr olcsóbb inputot kap** (költség-csatorna) → az exportja
   versenyképesebb lesz.
5. **Ha nő az export**, az exportőr több KKV-inputot rendel (mennyiségi
   csatorna) → tovább húzza a KKV-t.
6. **Egyensúly, nem sors:** a végeredmény ezeknek a versengő erőknek a
   kimenete, nem egy előre bedrótozott „a gyengébb meghal". A KKV és az
   exportőr *együtt* nyer.

> A csapatnak ezt a hat lépést mondd el történetként — ez a prezentáció
> szíve.

---

## 7. Az egyenletek — de emberi nyelven

Nem kell levezetni, elég elmondani, mit *mondanak*. (A pontos alakok a
HTML-doksiban és a `.mod`-ban.)

- **Akcelerátor:** `efp = χ·(tőkeáttétel)` — a prémium a mérleg
  gyengeségével nő; a KKV-nál nagyobb χ.
- **Beruházás:** a q (a tőke értéke) hajtja; kisebb ψ-vel a KKV
  gyorsabban reagál.
- **Vertikális költség-link:** `export határköltség = (1−s)·(saját
  költség) + s·(KKV határköltség)` — a KKV ára beépül az exportéba,
  `s = 0,20` súllyal.
- **Vertikális mennyiségi-link:** `KKV-input-kereslet ~ export`, és ez a
  `KKV-kibocsátás keresletének` része.

A `s = 0,20` (a KKV-input aránya az exportban) most **irodalmi/becsült
induló érték**, amit érzékenységként kezelünk — a pontosat a KSH ágazati
kapcsolatok mérlegéből (input-output tábla) fogjuk pótolni. Ezt fontos
kimondani: **nem hasraütés, hanem tudatosan érzékenységi paraméter.**

---

## 8. Honnan tudjuk, hogy működik? (az eredmények)

Két szinten van eredményünk. **Ezt a sorrendet tartsd meg:** először a
mechanizmus-teszt („működik-e egyáltalán"), aztán a tényleges
euró-szcenárió („mit mond a projekt kérdésére").

### 8.1 A mechanizmus működik (v04, tesztsokkok — `f19` ábra)

1. **A lánc együtt mozog.** Monetáris lazításra az export (+2,8%) és a
   KKV-input az exportőrhöz (+3,0%) **együtt** nő — a beszállítói
   kapcsolat közösen reagál. Ez a vertikális link bizonyítéka.
2. **A KKV érzékenyebb.** Ugyanarra a sokkra a KKV-beruházás (+2,9%)
   erősebben és gyorsabban reagál, mint a nagyvállalati (+2,1%).

**Két árnyalat, amit érdemes PROAKTÍVAN elmondani** (ha valaki alaposan
megnézi az ábrát, ő is észreveszi — jobb, ha te magyarázod el elsőként):
- A KKV **teljes** kibocsátása csak az első ~3 negyedévben tart a másik
  kettővel; utána a reálárfolyam-csatorna dominál (lásd 10. pont). A
  beszállítói csatorna (`h_dx`) viszont **a teljes horizonton erős marad**.
- A beruházási sorrend hosszabb távon **megfordul**: a rugalmas KKV
  gyorsan reagál, de gyorsan vissza is áll; a merev nagyvállalat lassan
  indul, de tovább tartja a hatást. Ez a ψ-paraméter konzisztens
  működése, nem hiba.

### 8.2 A tényleges euró-szcenárió (v05) — EZ A FŐ EREDMÉNY (`f21` ábra)

A v04 még csak tesztsokkokra futott. A v05 a szegmentálást **a valós
euró-belépési pályára** teszi (prémium-csökkenés + kamatunió-rezsimváltás,
három forgatókönyv). Az alappálya csúcshatásán (13. negyedév = a belépés):

| Szcenárió | KKV-felár | Nagyvállalat | KKV-többlet | GDP (h.táv) |
|---|---|---|---|---|
| alap | **−43,6 bp** | −27,5 bp | 16,1 bp | +0,69% |
| optimista | **−62,7 bp** | −39,1 bp | 23,6 bp | +0,93% |
| pesszimista | **−24,4 bp** | −15,8 bp | 8,6 bp | +0,46% |

**A mondat, amit érdemes kétszer is elmondani:** *„A KKV hitelfelára
másfélszer annyit javul, mint a nagyvállalaté — és ez már nem
feltételezés, hanem a modell eredménye."*

Továbbá: a **méret-aszimmetria mindhárom szcenárióban** fennáll (a
KKV-beruházás tartósan a nagyvállalati fölött: alap +1,51% vs. +1,11%),
és a **vertikális link a hatás 42%-át adja** (GDP +0,405% link nélkül →
+0,694% linkkel — érzékenységi protokollal mérve).

> **Ha valaki korábbi számokat látott:** egy előző futásban nagyobb
> értékek szerepeltek (KKV −100 bp). Az érzékenységi teszt kiderítette,
> hogy azok súly-inkonzisztenciából jöttek; a fenti értékek a helyesek.
> A KKV-előny *ténye és iránya* nem változott, csak a nagysága.

**Módszertani előrelépés, amit érdemes kiemelni:** korábban a teljes
KKV-hatást utólagos „kalibrált leképezéssel" állítottuk elő. Most a
KKV/nagyvállalat különbség **modell-eredmény**, és csak a besoroláson
*belüli* szóródás marad leképezés. Vagyis a „puha" réteg zsugorodott, a
„kemény" (modell) réteg nőtt — pontosan az, amit egy bíráló szeret.

### 8.3 Technikai, de fontos pontok

**A modell megoldódik** (Blanchard–Kahn teljesül — ez a DSGE „létezik és
egyértelmű megoldása van" tesztje), és a teljes reprodukciós lánc
**19/19 automatikus ellenőrzésen** átmegy. Ez nem magától értetődő, lásd
a 9.2 alternatívát.

**Ha kérdezik, miért a csúcshatásra hivatkozunk (és nem a hosszú távra):**
a BGG-akcelerátor **átmeneti** mechanizmus — a nettó vagyon hosszú távon
visszaáll, ezért steady state-ben a KKV és a nagyvállalat prémiuma
matematikailag azonos szintre konvergál. A szegmens-különbség tehát
természeténél fogva az átmeneti szakaszban él — és ott is a
legfontosabb: ez a belépés körüli 3–5 év, amikor a szakpolitikai
döntések születnek.

**KÉT hibát is elkaptunk, és ezt vállalni kell** (ez erősíti a
hitelességet — a modellezés minősége nem azon áll, hogy elsőre minden jó,
hanem hogy megtaláljuk és dokumentáljuk a hibákat):

1. **A külső egyensúly zárása** túl gyenge volt: a v05 első futása
   implauzibilis eredményt adott (export +12,9%, reálárfolyam +34,7%,
   külső pozíció −25% GDP). Diagnosztikával újrakalibráltuk (a
   reálárfolyam így +4,1%), és **validáltuk**: a linket kikapcsolva a GDP
   +1,07%, ami egyezik a szegmentálás nélküli korábbi modell +1,09%-ával.

2. **Súly-inkonzisztencia** (ezt az érzékenységi teszt fogta meg): két
   paraméter ugyanazt a kereskedelmi kapcsolatot írta le — az egyik azt,
   hogy az export költségének mekkora része KKV-input, a másik azt, hogy
   a KKV-kibocsátás mekkora része megy az exportőrhöz —, mégis
   függetlenül voltak megadva. Emiatt a KKV-kibocsátás 115%-át adta az
   export-input tag, ami lehetetlen. Javítva: a második paraméter most
   **származtatott** az elsőből. Ezért mérséklődtek a számok
   (KKV-felár −100 → −44 bp), de az irány és a mechanizmus változatlan.

**És egy fontos korlát, amit ki kell mondani:** a modellnek
**szingularitása van** a beszállítói arány ≈0,25-ös értékénél (a 0,24-nél
a felár már +501 bp-ra ugrik, a 0,26-nál a GDP −4,2%). Az alapkalibráció
(0,20) érvényes, de a pólus vonzásában van — ezért a **KSH input-output
tábla ellenőrzése prioritás**. A füstteszt mostantól regressziós
védőhálót tartalmaz mindkét javításra.

---

## 9. Amit mérlegeltünk — és miért nem azt (az alternatívák)

Ez a rész mutatja, hogy a döntés átgondolt. Öt utat vetettünk el.

### 9.1 Horizontális verseny (helyettesítő termékek)
**Mi ez:** a KKV és a nagyvállalat versenytárs, egy CES-aggregátorban
helyettesítik egymást. **Miért csábító:** egyszerű, standard.
**Miért nem:** ha a KKV kevésbé produktív, az eredmény *mechanikus* — „az
olcsóbb nyer, a gyengébb meghal" —, tehát a feltevés eldönti a végeredményt.
És nem a magyar szerkezet (a KKV nem az Audival versenyez). *Másodlagos
elemként* megtartható, de nem fő szerkezetnek.

### 9.2 Szektor-specifikus tőke + CPI-szétválasztás
**Mi ez:** az első, ambiciózusabb változatunk — mindkét szektor saját
tőkével, saját bérleti rátával, külön fogyasztói-ár blokkal. **Miért
csábító:** gazdagabb, realistább. **Miért nem:** **ténylegesen
megcsináltuk, és megbukott a stabilitási teszten** — a Blanchard–Kahn
feltétel sérült („nincs stabil egyensúly"). Ez őszinte, erős pont az
előadásban: *kipróbáltuk a szebb utat, az adat/modell nem engedte, és a
robusztus verziót választottuk.* A közös tőke-bérleti rátás szerkezet a
stabilitás ára.

### 9.3 Két vállalattípus minden szektoron belül
**Mi ez:** KKV és nagyvállalat a hazai ÉS az export szektorban is,
egymással versenyezve. **Miért nem:** nehezebb, sok új paraméter, nincs
rá adat-támogatás, és nem a vertikális tézist szolgálja.

### 9.4 Teljes endogén bankblokk (Gerali / EAGLE-FLI)
**Mi ez:** a hitel-transzmisszió egy explicit, monopolisztikus
bankszektorból jönne. **Miért csábító:** a hitel a projekt fő témája.
**Miért nem:** tucatnyi olyan paramétert hozna be, amit az 5 éves,
sokk-terhelt panelen nem tudunk fegyelmezni — a modell fele feketedoboz
lenne. A Gerali-féle ~60%-os átgyűrűzést kalibrációs horgonyként
használjuk, nem futó kódként.

### 9.5 Feltételezett produktivitás-küszöb
**Mi ez:** egy exogén szabály, ami kiszelektálja a gyenge cégeket.
**Miért nem:** ez a végeredményt *feltételezi*, nem levezeti — körkörös.
Nálunk a cégek ki-/belépése az extenzív margón (hitelHOZZÁFÉRÉS) endogén,
és empirikusan is ezt találtuk: a heterogenitás a hozzáférésben van, nem
egy produktivitási küszöbben.

---

## 10. Őszinte korlátok (mondd ki ezeket is)

- **A kulcsparaméterek érzékenységi jellegűek** (s=0,20, ψ=8/13,
  μ_vert=0,50) — a KSH IO-tábla pótolja a pontosat.
- **Közös tőke-bérleti ráta** (a stabilitás ára, 9.2).
- **Volatilis reálárfolyam** (a JV kis prémium-rugalmassága miatt) — ezért
  a tisztább monetáris sokkot használtuk a lánc bemutatására.
- **Következő lépés:** az s „be/ki" érzékenységi futás, ami tisztán
  megmutatja a vertikális csatorna hozzájárulását (a Streamlit-appban
  csúszkaként).

A korlátok kimondása **erősít**: azt mutatja, tudjuk, hol tartunk.

---

## 11. Várható kérdések — és a válaszok (Q&A-felkészülés)

**„Miért nem versenyeznek egymással a cégek?”**
Versenyeznek is, de Magyarországon a *domináns* viszony vertikális (70/6
export-adat). A horizontális versenyt másodlagos elemként meg lehet
tartani; a fő szerkezet a beszállítói lánc, mert azt mutatja az adat.

**„Honnan a 0,20-as beszállítói arány?”**
Irodalmi/becsült induló érték, és **végigmértük érzékenységi
protokollal**. Két dolgot tudunk: (a) a link a hatás 42%-át adja
(0-tól 0,20-ig monoton nő a hatás), és (b) a modellnek **pólusa van
0,25-nél**, ezért a 0,20 érvényes, de a pólus vonzásában van. Emiatt a
KSH input-output tábla ellenőrzése **prioritás**: ha a valódi arány 0,20
fölött van, a modellt át kell strukturálni. Ezt nyíltan vállaljuk.

**„Mi történik, ha a link nélkül futtatod?”**
GDP +0,405% a +0,694% helyett — vagyis a beszállítói kapcsolat nélkül a
becsült hatás bő harmadával kisebb. Ez az `s_kkv=0` ellenpróba, amit
külön lefuttattunk (a mennyiségi csatornát is kikapcsolva).

**„Nem manipuláltátok, hogy pozitív jöjjön ki?”**
Nem — épp azért választottuk ezt a szerkezetet, hogy az eredmény
*egyensúly* legyen, ne előre eldöntött. A produktivitás-küszöbös verzió
(9.5) lett volna a „bedrótozott" út, azt tudatosan elvetettük.

**„Miért a Jakab–Világi az alap, nem az EAGLE?”**
Mert magyar adaton becsült, karcsú, natívan kezel rezsimváltást (=az euró)
és ragadós bért (=az euró utáni alkalmazkodás). Az EAGLE referencia marad.
(Külön doksi: `3_miert_jakab_vilagi.md`.)

**„Mi az a Blanchard–Kahn, amit említesz?”**
A DSGE megoldhatóságának feltétele — hogy létezik egyértelmű, stabil
pálya. Az első, gazdagabb modellváltozatunk ezen bukott meg, ezért
egyszerűsítettünk a robusztus verzióra.

**„Mit ad ez hozzá a tanulmányhoz?”**
A KKV-fókuszt teszi modellezhetővé, és egy pozitív összegű, szakpolitikai-
lag használható üzenetet ad: az egészséges KKV-finanszírozás az egész
exportláncot versenyképesebbé teszi. Számszerűen: a KKV hitelfelára
44 bp-tal javul a nagyvállalat 28 bp-jával szemben (alappálya, csúcs).

**„Miért a csúcshatás, miért nem a hosszú táv?”**
Mert a BGG-akcelerátor átmeneti mechanizmus: a nettó vagyon visszaáll,
így steady state-ben a két szegmens prémiuma azonos szintre konvergál. A
különbség az átmenetben él — ami épp a szakpolitikailag releváns 3–5 év
a belépés körül. (Lásd 8.3.)

**„Nem túl nagy ez a hatás?”**
Épp az ellenkezőjét tapasztaltuk: az első futás **túl nagy** volt
(export +12,9%), és nem fogadtuk el — kiderült, hogy a külső-egyensúlyi
zárás volt hibás. A javítás után az aggregált GDP-hatás +0,80%, ami
konzisztens a szegmentálás nélküli modell +1,09%-ával, és a
paraméter-választás a „plató" elején van (nem érzékeny a pontos értékre).

---

## 12. Javasolt előadás-váz (~15 perc)

1. **(2 perc) A probléma.** „A modellünknek külön kell látnia a KKV-t és
   a nagyvállalatot — különben nincs mit mondanunk a KKV-hitelről." (1. pont)
2. **(3 perc) A központi kérdés.** Versenytárs vagy partner? Az Audi-
   kérdés. Miért dönti el az eredményt. (3. pont)
3. **(2 perc) A válaszunk és az adat.** 70/6 → vertikális, kétszintű
   gazdaság. KKV=hazai, nagyvállalat=export. (4. pont)
4. **(3 perc) A három megkülönböztetés.** Pénzügyi, rugalmasság,
   vertikális link — intuícióval, az egyenletek nélkül. (5. pont)
5. **(2 perc) A mechanizmus.** A hat lépés az euró-sokktól a pozitív
   összegű eredményig. (6. pont)
6. **(3 perc) Az eredmények.** Először az `f19` (mechanizmus működik:
   együttmozgás + aszimmetria), aztán az `f21` és a táblázat: **a KKV
   hitelfelára −44 bp vs. a nagyvállalat −28 bp** a tényleges
   euró-szcenárióban, és a **link a hatás 42%-át adja** (`f22`).
   Említsd a két árnyalatot proaktívan. (8.1–8.2)
7. **(2 perc) Az alternatívák.** Röviden az öt elvetett út — főleg a
   9.2 (kipróbáltuk, BK-n bukott) és a 9.5 (körkörös). Ez mutatja, hogy
   átgondolt a döntés. (9. pont)
8. **Zárás + Q&A.** A korlátok kimondása (10.), és a következő lépés
   (IO-tábla, érzékenységi futás).

**A prezentáció egy mondatos üzenete, amit érdemes kétszer is elmondani:**
*„A KKV a nagyvállalat beszállítója, nem versenytársa — ezért az euró nem
győztest és vesztest csinál, hanem az egész exportláncot erősíti, ha a
KKV olcsóbb hitelhez jut."*

**És a számszerű alátámasztás egy mondatban:**
*„A modell szerint a KKV hitelfelára 44 bázisponttal javul a
nagyvállalat 28 bázispontjával szemben — másfélszeres nyereség —, és a
beszállítói lánc a teljes hatás 42%-át adja."*
