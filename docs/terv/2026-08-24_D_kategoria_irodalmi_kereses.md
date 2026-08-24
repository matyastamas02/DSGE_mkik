# A D kategória 20 tétele — van rá nyilvános felmérés vagy irodalom?

*2026-08-24 · első keresés, **nem szisztematikus review***
*Kiváltó ok: az `omega_acc_L`-nél ugyanez a kérdés hozott találatot (ECB SAFE),
és a tanulság az volt, hogy a „nem azonosítható" minősítést nem szabad
irodalmi keresés nélkül kimondani.*

---

## Hogyan olvasd ezt a doksit

**Ez a doksi NEM változtat meg egyetlen paraméterértéket sem.** Minden
találat egy *jelölt*, aminek még át kell mennie az állítás-regiszteren és
kapnia kell őrt. A `.mod` alapértelmezései változatlanok.

Három minősítés:

| jel | jelentés |
|---|---|
| 🟢 **van horgony** | konkrét, hivatkozható forrás létezik, és a mi objektumunkra vonatkozik |
| 🟡 **részleges** | van forrás, de más objektumra / más országra / csak az irányra |
| 🔴 **nincs** | kerestünk, és nem találtunk használhatót |

⚠ **A visszatérő csapda, amibe itt is bele lehet esni:** egy irodalmi
szám ATTÓL, hogy létezik, még nem a mi paraméterünk. Az `eps_ces` (lásd
lent) pont ilyen. Minden találatnál kiírjuk, hogy **ugyanaz-e az
objektum.**

---

## Összefoglaló tábla

| # | paraméter | minősítés | forrásjelölt |
|---|---|---|---|
| 1–2 | `chi_E`, `chi_D` | 🟡 részleges | *Loan spreads over the credit cycle* (2025): KKV-felár tágabban nő szigorú időszakban — **csak az irány** |
| 3 | `chi_L` | 🟡 részleges | Levin–Natalucci–Zakrajšek (2004): ~900 US **kötvénykibocsátó** cég — ez definíció szerint a nagyvállalati kör |
| 4–6 | `psi_E`, `psi_D`, `psi_L` | 🟡 részleges | Khan–Thomas (2008), Bachmann–Caballero–Engel (2013) — **és az irány ellentmond a jelenlegi kalibrációnak** |
| 7–9 | `tsov_E/D/L` | 🟡 részleges | Bottero–Lenzu–Mezzanotti (JIE 2018): a szuverén sokk **csak a kis cégek** beruházását fogta vissza |
| 10–12 | `tbank_E/D/L` | 🟢 **van horgony** | **Horváth–Kotlebová–Širaňová (JFS 2018): a transzmisszió CSAK a kisvállalati hitelekre teljes** |
| 13 | `s_kkv` | 🟢 **van horgony** | OECD TiVA + OECD *Economic Surveys: Hungary 2026* KKV-fejezet — **megkerüli a hibás IO-számítást** |
| 14 | `mu_vert` | 🔴 nincs | nem találtunk a beszállítói ár-átgyűrűzés rugalmasságára becslést |
| 15 | `zsov` | 🟢 **van horgony** | Vonnák (MNB WP 2010/1) + **közvetlenül mérhető** két nyilvános idősorból |
| 16 | `eps_ces` | 🟡 részleges | Dobrinsky–Kőrösi–Markov–Halpern (JCE 2006): magyar markup — **de MÁS OBJEKTUM** |
| 17–20 | `lambda_acc_E/D`, `omega_acc_E/D` | 🟡 részleges | EIBIS + EC/ECB SAFE + BIS WP 984 — **és a négyből csak KETTŐ azonosítható objektum** |

**Mérleg: 3 zöld, 16 sárga, 1 piros.** Vagyis a 20-ból **egy** olyan van,
amiről a keresés után is azt mondjuk, hogy nincs mit megnézni.

---

## 1. Ami tényleg új: `tbank_j` — van rá irodalom, és ellentmond a saját mérésünknek

**Horváth, R., Kotlebová, J., Širaňová, M. (2018): „Interest rate
pass-through in the euro area: Financial fragmentation, balance sheet
policies and negative rates", *Journal of Financial Stability* 36, 12–21.
DOI 10.1016/j.jfs.2018.02.003.**

Heterogén panel-kointegráció, euróövezet, 2008–2016, négy hitelkategória.
Eredmény: **a transzmisszió csak a kisvállalati hitelekre teljes, minden
más kategóriára (nagyvállalati, háztartási, fogyasztási) hiányos.**

Ez pontosan a `tbank_S > tbank_L` feltevés, amit a projekt
[`FIGYELMEZTETES_fo_allitas.md`](../figyelmeztetesek/) szerint „nem
azonosítottnak" nyilvánított, és `V03`-ként **vissza is vont**.

> ### ⚠ És itt jön a kellemetlen rész, amit nem hallgathatunk el
>
> **A saját mérésünk az ELLENKEZŐJÉT mutatja.** Az `A16` állítás szerint a
> magyar kamattranszmisszió pontbecslése **mind a négy** specifikációban a
> **nagyvállalatnál** magasabb (`t25`) — igaz, egyik különbség sem
> szignifikáns 5%-on, mind a négy CI tartalmazza a nullát (`t25b`).
>
> Tehát: **euróövezeti irodalom `t_S > t_L`, magyar saját adat (nem
> szignifikánsan) `t_L > t_S`.** Ez nem oldja fel a `V03` visszavonását —
> **megerősíti**, hogy a `TSCEN=3` (semleges) alapértelmezés volt a helyes
> döntés, és most már **két oldalról** tudjuk indokolni, nem csak
> adathiánnyal.
>
> A tanulmányban ezt így kell írni: *„a méret szerinti transzmissziós
> különbség iránya az irodalom és a magyar adat között ellentétes, ezért a
> modell semleges transzmissziót használ, és a `-DTSCEN=1|2` ágakon
> mindkét irányt megmutatja."* Ez erősebb, mint a jelenlegi
> megfogalmazás.

**Teendő:** a hivatkozás felvétele a szakirodalmi adatbázisba, és a
`FIGYELMEZTETES_fo_allitas.md` kiegészítése. Ez fél óra.

---

## 2. `tsov_j` — az irány támogatott, méghozzá a beruházási oldalon

**Bottero, Lenzu, Mezzanotti (2018): „Sovereign debt exposure and the bank
lending channel", *Journal of International Economics*.**

Olasz hitelregiszter, a 2010-es görög mentőcsomag mint sokk a bankok
szuverén portfóliójára. Eredmény: a hitelszűkülés **hasonló volt kis és
nagy cégeknél**, de **csak a kis cégek beruházási és foglalkoztatási
döntéseit** fogta vissza.

**Miért érdekes ez nekünk:** a modellben a `tsov_j` a szuverén felár
átgyűrűzése a cég forrásköltségébe, az `omega_acc_j` pedig az, hogy ez
mennyi beruházássá válik. Ez a tanulmány pont azt mondja, hogy a
**mennyiségi** átgyűrűzés méret-semleges, a **reálhatás** viszont nem.
Vagyis a méret-aszimmetriát nem a `tsov_j`-be, hanem az `omega_acc_j`-be
kell tenni — ami **pontosan a jelenlegi modellszerkezet** (`tsov` semleges
a TSCEN=3 alapértelmezésen, `omega_acc_L = 0`).

Ez a projekt eddigi legjobb **szerkezeti** igazolása, és eddig nem volt meg.

---

## 3. `s_kkv` — megkerülhető a hibás IO-számítás

Az `s_kkv` (a KKV-k részesedése az exportszektor hazai köztes inputjában)
azért horgonyzatlan, mert az IO-alapú számítás
[hibásnak bizonyult](../figyelmeztetesek/FIGYELMEZTETES_io_tabla_gyanus.md),
és a gyökérok nyitott.

**A keresés azt hozta, hogy nem is kell az IO-táblát megjavítani.** Két
független, publikált forrás létezik ugyanerre:

1. **OECD TiVA / ICIO Hungary country note** — a magyar exportba beépült
   hazai hozzáadott érték, és az importált köztes inputok exportba beépült
   aránya (2022-re 67,9%, az OECD-átlag 49,2% helyett).
2. **OECD *Economic Surveys: Hungary 2026*, „Enhancing opportunities for
   SMEs" fejezet** — a KKV-k a vállalatok 99,9%-át, de a hozzáadott érték
   **54%-át** adják.

⚠ A második szám a **teljes** gazdaságra vonatkozik, nem az exportszektor
köztes inputjára — tehát nem közvetlenül `s_kkv`, hanem **felső korlát**
jellegű információ. A jelenlegi `s_kkv = 0,05` ehhez képest nagyon alacsony,
és ezt meg kell tudni indokolni.

**Teendő:** a TiVA country note letöltése és az `s_kkv` újraszámolása
belőle, az IO-tábla megkerülésével. Fél nap, és megszünteti egy nyitott
figyelmeztetés hatását.

---

## 4. `zsov` — ez a legolcsóbb a húszból

A `zsov = 0,5` azt mondja, hogy a szuverén felár fele csapódik le a hazai
kockázatmentes kamatban (`r − zsov*sov` az UIP-ben és a
kamatszabályban). Ez **nem irodalmi kérdés, hanem mérési** — két nyilvános
idősorból közvetlenül becsülhető (magyar szuverén felár vs. a BUBOR–EURIBOR
különbözet / határidős prémium).

Irodalmi támpont: **Vonnák Balázs (MNB WP 2010/1): „Risk premium shocks,
monetary policy and exchange rate pass-through in the Czech Republic,
Hungary and Poland."** Ugyanabból a műhelyből, mint a JV-mag.

**Teendő:** saját becslés. Fél nap, és a 20-ból ez az egyetlen, ami
**tisztán makró idősorból** megy, tehát nem szenved sem a
programvezéreltségtől, sem az egy pre-periódustól.

---

## 5. `psi_j` — a találat KELLEMETLEN: az irány ellentmond a kalibrációnak

Jelenlegi értékek: `psi_E = psi_D = 8,0`, `psi_L = 13,0` — vagyis a modell
szerint a **KKV igazít könnyebben** (alacsonyabb kiigazítási költség).

A beruházási rögösség (*lumpy investment*) irodalma — **Khan–Thomas (2008)**,
**Bachmann–Caballero–Engel (2013)** — azt találja, hogy a **kis** cégek
beruházása **rögösebb**, tehát nem-konvex kiigazítási költségekkel terhelt.
Egy konvex-költségű modellbe fordítva ez inkább `psi_S > psi_L`-t sugallna
— **a jelenlegi kalibráció fordítottját.**

Egy második, szintén kellemetlen találat: Khan–Thomas szerint a
kiigazítási-költség paraméterek a preferált kalibrációjukban **alig
befolyásolják az aggregált eredményt** — mikroadat kell hozzájuk.

**Ebből két dolog következik:**
- az aggregált `A01` sáv szempontjából a `psi_j` **alacsony prioritás**;
- a **szektorális** eredmény szempontjából viszont **scan kell rá**, és
  külön meg kell nézni, hogy az előjel megfordítása (`psi_S > psi_L`)
  megfordítja-e a KKV-eredményt. Ha igen, az egy hetedik tétel a projekt
  „horgonyzatlan paraméter viszi a szektorális eredményt" listáján.

⚠ **Ezt nem szabad elfelejteni.** Ez a keresés legfontosabb *negatív*
találata.

---

## 6. `eps_ces` — van magyar markup-becslés, de MÁS OBJEKTUMRA

**Dobrinsky, R., Kőrösi, G., Markov, N., Halpern, L. (2006): „Price markups
and returns to scale in imperfect markets: Bulgaria and Hungary",
*Journal of Comparative Economics* 34(1), 92–110.**

Magyar cégszintű markup-becslés, magyar szerzőkkel (Halpern, Kőrösi az MTA
KTI-ből). Ez a legjobb magyar jelölt.

⚠ **De a korlátok-riport 3. pontjában leírt fogalmi csúszás megmarad:**
nálunk az `eps_ces` a **vállalattípusok** (E/D/L) közti helyettesítés, egy
markup-becslés viszont a **termékváltozatok** közti helyettesítést adja.
**Nem ugyanaz az objektum**, csak ugyanaz a jelölés. Egy magyar markup
tehát *plauzibilitási sávot* ad, nem horgonyt.

Erre a különbségtételre a tanulmányban külön mondat kell.

---

## 7. Az access-négyes — és egy szerkezeti felismerés, ami csökkenti a listát

**A [`λ`/`ω` szétbontás](../eredmenyek/2026-08-24_lambda_omega_szetbontas.md)
mellékeredménye: a modell a `lambda_acc`-ot és az `omega_acc`-ot
külön-külön NEM azonosítja — csak a szorzatukat.** Ellenőrizve `t52e`-ben:
azonos szorzatú, nagyon különböző párok számjegyre azonos eredményt adnak.

**Következmény a regiszterre:** a D kategória négy access-tétele valójában
**két** azonosítható objektum, `λ_E·ω_E` és `λ_D·ω_D`. Aki a négyet külön
akarja horgonyozni, olyan adatot keres, ami a modellen keresztül nem
létezik.

Forrásjelöltek a **szorzatra**:

- **EIB Investment Survey (EIBIS)** — évente ~12 000 EU-cég, magyar
  országjelentéssel 2021 óta minden évben. Közvetlenül méri a pénzügyileg
  korlátozott cégek arányát **és** a beruházást. A KKV kétszer akkora
  eséllyel korlátozott, mint a nagyvállalat (6% vs 3%).
- **EC/ECB SAFE — a Bizottság éves köre.** ⚠ **Fontos pontosítás a
  korábbi teendőhöz:** a *negyedéves* SAFE **euróövezeti**, Magyarország
  nincs benne. A Bizottsággal közös, évente futó kör viszont **minden EU-
  tagállamot** lefed, és **mikrocégekre is** bont (1–9, 10–49, 50–249,
  250+). Vagyis a „SAFE magyar bontása" teendő **teljesíthető, de nem
  abból a kiadványból, amit eddig néztünk** — és ráadásul ugyanez a forrás
  oldja meg a `om_j`/`shl_j` mikrokör-hiányt is (7. teendő), amiért az
  `-DOPTEN` alapértelmezése `0` maradt.
- **Irodalom a hozzáférés → beruházás lépcsőre:** a pénzügyileg nem
  korlátozott cégek nettó beruházási rátája **7,8 százalékponttal**
  magasabb, és a hatás **kisebb a nagyvállalatoknál** — ez egyszerre
  támogatja az `omega_acc > 0`-t és az `omega_acc_L < omega_acc_S`-t.

> ### ⚠ A csapda, amit a CLAUDE.md külön kimond, és itt is áll
>
> **BIS Working Paper 984** („Credit constrained firms and government
> subsidies: evidence from a European Union program") **magyar**
> hitelregiszter-adaton méri, hogy a támogatás mennyivel emeli a
> korlátozott cégek eszköznövekedését. Csábító ezt `omega_acc`-nak
> nevezni. **Nem szabad.** Ez a *program* teljes finanszírozási hatását
> viszi, nem a hozzáférési csatorna strukturális rugalmasságát — pontosan
> az a hiba, amitől a CLAUDE.md óv. Legfeljebb **plauzibilitási felső
> korlátként** használható, és akkor is ki kell írni, hogy az.

---

## Amit ez a keresés megváltoztat

1. **`tbank_j`**: kétoldalú bizonyíték (irodalom `t_S > t_L`, magyar adat
   nem szignifikánsan fordítva) → a `TSCEN=3` semleges alapértelmezés
   indoklása erősebb lett. `V03` visszavonva marad.
2. **`tsov_j`**: a jelenlegi **modellszerkezet** (méret-semleges felár-
   átgyűrűzés + méret-függő beruházási reakció) irodalmi támogatást kapott.
3. **`s_kkv`**: az IO-tábla megkerülhető, TiVA-ból újraszámolható.
4. **`zsov`**: saját idősoros becsléssel horgonyozható, fél nap.
5. **`psi_j`**: **új kockázat** — az irodalom a jelenlegi méret-sorrend
   ellenkezőjét sugallja. Scan kell rá.
6. **Access-négyes**: 4 paraméter → **2 azonosítható objektum**.
7. **SAFE**: a magyar bontás létezik, de a Bizottság éves köréből.
   Ugyanez oldja fel az `-DOPTEN` alapértelmezés kérdését is.

## Sorrend, amit ebből javaslunk

| # | teendő | ráfordítás | miért |
|---|---|---|---|
| 1 | `psi_j` scan (a fordított sorrenddel is) | fél nap | **új kockázat**, és ugyanaz a hibamintázat, ami hatszor előfordult |
| 2 | `zsov` saját becslés két idősorból | fél nap | a legolcsóbb horgony a húszból |
| 3 | EC/ECB SAFE magyar + mikro bontás | fél nap | egyszerre viszi az access-t és az `om_j`/`shl_j`-t |
| 4 | `s_kkv` TiVA-ból | fél nap | megszünteti egy nyitott figyelmeztetés hatását |
| 5 | Horváth et al. + Bottero et al. + Crouzet–Mehrotra felvétele az irodalmi bázisba | fél óra | a bíráló elő fogja venni őket |

---

*Kapcsolódó: [korlátok-riport](2026-08-21_korlatok_es_teendok.md) ·
[λ/ω szétbontás](../eredmenyek/2026-08-24_lambda_omega_szetbontas.md) ·
[E/D/L dekompozíció](../eredmenyek/2026-08-24_edl_dekompozicio.md) ·
[BGG-blokk kalibráció](../eredmenyek/kalibracio_bgg_blokk.md)*
