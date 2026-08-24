# 4. fejezet — Hasznos-e a DSGE modell az állami segítségnyújtás értékelésében?

*Szabó Bakos (2006), 85–149. o. (PDF 90–154). **Ez a disszertáció saját
hozzájárulása**, és a mi szempontunkból az egyetlen igazán fontos fejezet.*

---

## Vezetői összefoglaló

Az EU Bizottsága a nehéz helyzetben lévő vállalatoknak nyújtott mentési és
szerkezetátalakítási támogatásokat esetről esetre bírálja el. A szerző azt
kérdezi: **tud-e ehhez a DSGE-eszköztár számszerű döntéstámogatást adni?**

Az érvelés magja egy csere. Ha az állam **nem** avatkozik be, a bajba jutott
vállalatok kilépnek a piacról, a maradók piaci ereje nő, a termékek egymás
távolabbi helyettesítőivé válnak — vagyis **tartósan emelkedik a
haszonkulcs**, ami jóléti veszteség. Ha viszont **beavatkozik**, a fiskális
kiadás maga is jóléti veszteséget okoz. A döntés tehát két kár
összevetése.

A szerző mindkét kárt **ugyanabban a jóléti egységben** méri egy kis nyitott
gazdaság új-keynesi modellben, majd megadja azt a **haszonkulcs-küszöböt**,
amely fölött a beavatkozás indokolt. Négy periódusnyi, GDP 1%-ának megfelelő
támogatásnál ez a küszöb **0,202% tartós haszonkulcs-emelkedés**.

Nekünk nem az eredmény érdekes (más ország, más eszköz, 2006), hanem a
**forma**: egy nem azonosítható paraméter melletti policy-kérdést
küszöbként közöl, és ezt explicit módszertani állásfoglalásként teszi.

---

## 4.1. Tények az állami segítségnyújtásról (89–91. o. / PDF 94–96)

Eurostat *State Aid Scoreboard (2005)* alapján, **2004-es adatok**:

| Tétel | Érték |
|---|---|
| EU-25 összes állami támogatás | **~62 Mrd EUR** |
| ez az aggregált EU-GDP arányában | **~0,6%** |
| ebből feldolgozóipar + szolgáltatások | ~40 Mrd EUR |
| agrárium | ~15 Mrd EUR |
| bányászat | ~5,5 Mrd EUR |
| szállítmányozás | ~1 Mrd EUR |
| feldolgozóipar+szolgáltatások, 2000 óta | stabilan a GDP **0,44–0,48%-a** |

A 90-es évek elején megfigyelhető csökkenés **2000-re megállt**, a tagállamok
korábbi elvi kiállása ellenére.

### Miért érdekel ez minket

Ez az **első külső viszonyítási pont az `A20`-hoz**. A mi implicit
támogatási ékünk 2023-ban 557 Mrd Ft (BUBOR-referencia), ami a magyar GDP
nagyságrendileg **0,8%-a** — vagyis ugyanabban a tartományban, mint az
EU-átlagos állami támogatás, kicsit felette.

⚠ **De az összevetés nem egy az egyben érvényes:**
- Az `A20` **implicit** ék: egy részét a bankok és a fix kamatozású régi
  állomány (vintage-hatás) viselik, nem a költségvetés. A Scoreboard
  viszont **tényleges állami kiadás**.
- Az `A20` **csak a KKV-hitelezésre** vonatkozik, a Scoreboard az összes
  szektorra.
- 2004 vs 2023.

Tehát: **nagyságrendi benchmark igen, számszerű összevetés nem.**

---

## 4.2. A támogatási keret (92–94. o. / PDF 97–99)

Az Alapszerződés 87. cikk (1) szerint tilos minden olyan segély, amely
(1) állami forrásból magánszektorbeli kedvezményezettnek jut, és
(2) torzítja a versenyt vagy ezzel fenyeget, érintve a tagállamok közti
kereskedelmet.

A szerző kiemeli: ez a technikát nem teszi sem feleslegessé, sem tiltottá —
az ügyek jelentős részében **mérlegelés** történik. A Bizottság amúgy is
vizsgálja, hogy (135. o.):

- mi a beavatkozás célja,
- meddig kívánja fenntartani a tagállam,
- mekkora összeget szán rá,
- mekkora a kedvezményezett piaci részesedése,
- mekkora súlyt képvisel az érintett piac a nemzetgazdaságban.

**A szerző pontosan ezt használja ki:** ezek ugyanazok az inputok, amiket egy
kalibrált DSGE igényel. Ez az érvelés szerkezete — *a szabályozó már úgyis
gyűjti az adatot, csak nem tesz vele számítást* — nálunk is használható a
programkivezetési kérdésnél.

---

## 4.3. A modell (95–117. o. / PDF 100–122)

Kis nyitott gazdaság, **rögzített árfolyammal**, új-keynesi maggal.

**Vállalati szektor (4.3.1):** három termelői kör — hazai piacra termelő,
**exportra termelő**, és importcikket forgalmazó vállalatok —, mindegyik
monopolisztikus versenyben, Calvo-árazással, **külön árdinamikával** (a
levezetések a 4.9.1–4.9.3 függelékekben).

> **Ez szerkezetileg a JV-magunkhoz áll közel**, nem az EAGLE-hez: a
> hazai/export szétválasztás külön árazási döntéssel ugyanaz a logika, amit
> mi a `v08_3type_arak`-ban vezettünk be. A különbség: nála ez **termék**
> szerinti bontás, nálunk **vállalattípus** szerinti.

**Fogyasztó (4.3.2):** monopolisztikus munkakínálat, Calvo-bérezés,
fogyasztói szokások. **Fiskális és monetáris politika (4.3.4):** rögzített
árfolyam mellett a monetáris politika passzív.

**Megoldás:** 20 loglinearizált egyenlet + 4 infláció-definíció, Uhlig (1999)
algoritmussal (116–117. o.).

### Kalibráció (115–116. o. / PDF 120–121)

A teljes lista a [`00_attekintes.md`](00_attekintes.md) 2/a pontjában.
A kiemelendők:

- **amortizáció 10%/év → 2,5%/negyedév** — pontosan a mi `delta`-nk, és
  egybevág az Opten-panelből számolt 0,0242-vel (`A09`).
- **haszonkulcs 20% (θ = 6), Laxton–Pesenti (2003) alapján** — ugyanaz a
  konvenció, mint a mi `eps_ces` = 6,0-unk. **Nem független horgony.**
- **árragadósság ω = 0,5**, amit a szerző maga jelöl alacsonyabbnak a
  szokásosnál. A JV magyar becslése 0,921 — nagyon messze van.
- **tőke-alkalmazkodási költség φ = 15**, kifejezetten magas.

**Állandósult állapot (131. o.):** a jóléti mérőszám (hasznosság) SS-szintje
**1,0414 egység**, amit C = 3,5703 és L = 1,1154 biztosít. Ezekre a
számokra épül minden jóléti összevetés.

---

## 4.4. Hosszú táv (118–119. o. / PDF 123–124)

A logika kimondása: **kétféle sokk jóléti hatását** hasonlítja össze —
(i) a fiskális lépését, amely elnyomja a piacszerkezet-változást, és
(ii) az elmaradó beavatkozás miatt bekövetkező piacszerkezet-változásét.

> „Az állami segítségnyújtás csak abban az esetben indokolható, ha a vele
> kapcsolatos károk mértéke nem haladja meg az elmaradásából származó károk
> mértékét." (118. o.)

Feltevés: mivel a tagállamnak részletes, hiteles tervet kell benyújtania,
és azt a Bizottság átvizsgálja, **a beavatkozás sikeresnek tekinthető** —
azaz a piacszerkezet-változás elmarad.

⚠ Ez erős feltevés, és a szerző nem is teszteli. A mi kontextusunkban a
megfelelője az lenne, hogy az NHP/Széchenyi valóban elérte a célját —
amit az `A18`/`A19` alapján **nem tudunk állítani**, csak azt, hogy az
árazást leszakította a piacitól.

---

## 4.5. A kormányzati kiadás hatása (120–126. o. / PDF 125–131)

Lassan lecsengő (autoregresszív) fiskális sokk. A mechanizmus végigvezetve:

1. A fogyasztó a **vagyoncsökkenéstől tartva** visszafogja a fogyasztást és
   a beruházást, **és növeli a munkakínálatát**.
2. A kereslet emelkedése hazai és import termékek felé is irányul → a hazai
   kibocsátás és az import is nő.
3. A megnövekedett inputkereslet emeli a bért és a tőkebérleti díjat → nő a
   határköltség → az árat igazítani képes vállalatok **felfelé** módosítanak.
4. Rögzített árfolyam mellett a hazai árszínvonal emelkedése **csökkenti a
   reálárfolyamot** → a hazai piacra árazó külföldi vállalatok is
   csökkentik áraikat → az import még akkor is a SS fölött marad, amikor a
   kiadások már alulmúlják az átlagot.
5. A reálbér/reálbérleti díj arány **nő** → a tőke-munka arány csökken.

**Jóléti eredmény:** a társadalmi jólét jelenértéke **0,0552 egységgel**
kevesebb, mint fiskális sokk és haszonkulcs-változás nélkül (127. o.).

> **Nekünk:** a 4. lépés a magyar euró-kérdés szempontjából érdekes — ez
> pontosan a rögzített árfolyam melletti reálárfolyam-alkalmazkodás, amit a
> mi `rer`/`uni`-blokkunk is visz. A mechanizmus leírása jó ellenőrzés
> arra, hogy a mi IRF-jeink közgazdaságilag értelmes irányba mennek.

---

## 4.6. A haszonkulcs változásának hatása (127–130. o. / PDF 132–135)

**A forgatókönyv:** állami segítségnyújtás hiányában cégek lépnek ki, a
termékek egymás távolabbi helyettesítőivé válnak, **az egyedi vállalat
haszonkulcsa nő**. Ezt a szerző haszonkulcs-sokként engedi a modellre.

Ez a fejezet közgazdasági tartalma egyszerű, de a **modellezési fogás** a
lényeg: a piacszerkezet-változást nem külön mechanizmusként modellezi,
hanem **a meglévő markup-paraméter sokkjaként**. Így a két forgatókönyv
(beavatkozás / nem-beavatkozás) ugyanabban a modellben, ugyanazon a jóléti
metrikán mérhető.

> **Nekünk ez a legátvehetőbb gondolat.** Az `eps_ces` nálunk horgonyzatlan,
> és a szektorális eredmény felét viszi (`F02`). Ha nem tudjuk megmondani az
> értékét, akkor — ezt a fogást követve — azt mondhatjuk meg, **mekkora
> markup-elmozdulás ér fel** egy adott hatással. Ez ugyanaz a küszöbforma,
> amit az `ACCSCALE`-nél már alkalmazunk.

---

## 4.7. A küszöb (131–135. o. / PDF 136–140) — **a fejezet csúcspontja**

**A kísérlet:** a kormányzat 1, 2, 3 vagy 4 perióduson át nyújt támogatást.
A támogatás **egyszeri kifizetés** (a sokk nem autoregresszív), nagysága a
GDP **1%-a**.

### Eredmény 1 — a beavatkozás jóléti költsége

| Beavatkozás hossza | Jóléti veszteség (jelenérték, egység) |
|---|---:|
| 1 periódus | 0,0192 |
| 2 periódus | 0,0354 |
| 3 periódus | 0,0515 |
| 4 periódus | **0,0675** |

*(A viszonyítási alap az a forgatókönyv, ahol nincs kiadásnövekedés, mert a
társadalomnak nem kell piacszerkezet-változástól tartania.)*

### Eredmény 2 — az ezzel egyenértékű haszonkulcs-emelkedés

| Beavatkozás hossza | Azonos jóléti veszteséget okozó **tartós** haszonkulcs-emelkedés |
|---|---:|
| 1 periódus | **0,051%** |
| 2 periódus | **0,102%** |
| 3 periódus | **0,152%** |
| 4 periódus | **0,202%** |

**A döntési szabály:** ha a beavatkozás elmaradásából fakadó
haszonkulcs-emelkedés **meghaladja** a táblázat értékét, a beavatkozás
indokolt.

### Eredmény 3 — és itt jön a perzisztencia

A szerző lefuttat egy kétdimenziós scant a **sokk nagysága × autoregresszív
paraméter** síkon (134. o. ábra). A kulcsmegállapítás:

- **13%-os haszonkulcs-sokk `AR = 0,5`-tel** nagyjából ugyanakkora jóléti
  veszteséget okoz, mint egy **négy periódusos** fiskális sokk.
- **Ugyanaz a 13%-os sokk `AR = 0,06`-tal** már csak egy **két periódusos**
  beavatkozás küszöbeként szolgál.

> ⭐ **Ez a mi `rho_acc`-érzékenységünk szerkezeti analógiája.** Nálunk a
> feltételes magas-perzisztenciájú ág (0,85 → 0,9673) a KKV-küszöböt
> 36,5-ről 22,3-ra vitte le,
> mert a hosszú távú hatás `1/(1−ρ)`-val arányos. Itt ugyanez: **a küszöb a
> sokk perzisztenciáján múlik, nem csak a nagyságán.** Két, egymástól
> független modellben ugyanaz a szerkezeti tanulság. A 0,9673 azonban nem
> empirikus szegmens-rho-horgony: a panelbeli hitelstátusz főként tartós
> cégek közötti heterogenitást mér, ezért ez csak érzékenységi pont.

### A szerző saját fenntartása — ezt érdemes szó szerint észben tartani

> A dolgozat célja **nem konkrét küszöbértékek meghatározása** volt, hanem
> egy elemzési technika hasznának bemutatása. (135. o.)

És kifejti: az eredmény nem az, hogy „a beavatkozás 13%-os haszonkulcs-
növekedés fölött indokolt", hanem az, hogy **ha a döntéshozó úgyis
összegyűjti a szükséges információt** (cél, időtartam, összeg, piaci
részesedés, a piac súlya), akkor egy kalibrált DSGE ezekből **számszerű
összevetést** tud adni.

---

## 4.8–4.9. Összefoglalás és függelékek (136–149. o. / PDF 141–154)

A 4.9.1–4.9.5 függelékek az árdinamika (hazai / exportra termelő /
importcikket előállító vállalatok), a bérdinamika és a fogyasztói probléma
levezetései. Standard Calvo-levezetések; nálunk a JV-mag ezeket már
tartalmazza, tehát **átvenni nincs mit**, de ellenőrzésre használhatók, ha
a `v08` típusonkénti árdinamikájában kétség merül fel.

---

## Mit viszünk el ebből a fejezetből

| # | Tanulság | Hova köt |
|---|---|---|
| 1 | **A küszöbforma magyar DSGE-precedens.** Egy nem azonosított paraméter melletti policy-kérdés küszöbként közölhető — és ezt egy magyar PhD már megtette. | `A06`, `F01`, `F02` közlési formája |
| 2 | **A küszöb a perzisztencián múlik, nem csak a sokk nagyságán.** | `A11` / `rho_acc`-scan — független megerősítés |
| 3 | **A markup-változás sokként kezelhető és jóléti egységre váltható.** | `F02` / `eps_ces` — ha nem horgonyozható, küszöbösíthető |
| 4 | **EU állami támogatás ≈ GDP 0,6% (2004).** | `A20` nagyságrendi benchmark |
| 5 | **A „sikeres a beavatkozás" feltevés kimondatlanul erős.** | figyelmeztetés: mi ezt az `A18`/`A19` alapján nem tehetjük fel |
| 6 | δ = 2,5%/negyedév ugyanaz a konvenció | `A09` harmadik független megerősítése |
