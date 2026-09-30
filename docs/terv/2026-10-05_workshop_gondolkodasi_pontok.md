# Workshop 2026-10-05 — gondolkodási pontok blokkonként

*Mit kérdezünk a résztvevőktől? A modellbemutató
([`docs/eredmenyek/2026-10-05_workshop_bemutato.html`](../eredmenyek/2026-10-05_workshop_bemutato.html))
szinte minden egyenletblokkjában van egy piros vagy figyelmeztető doboz. Ez a
fájl ezeket gyűjti össze, kontextusba teszi, és a teremnek szóló kérdéssé
fogalmazza. A számok az állítás-regiszterből (`docs/regiszter/allitasok.csv`)
és a paraméterregiszterből (`docs/regiszter/parameterek.csv`) jönnek, az
azonosítók zárójelben.*

## Hogyan használjuk

- Minden pontnál négy rész van: **kontextus** (mit csinál a modell), **nehézség**
  (mit találtunk), **miért számít** (a központi kérdés szempontjából) és
  **kérdés a teremnek**.
- A központi kérdés végig ugyanaz: *milyen feltételek mellett állíthatjuk, hogy az
  euró eltérően érinti az exportáló KKV-kat, a hazai KKV-kat és a
  nagyvállalatokat?*
- A `[hallgatók]` jelölésű kérdések a mechanizmus megértését kérdezik, ezekre
  először a hallgatók válaszoljanak. A `[szakértők]` jelölésűek forrást, adatot
  vagy ítéletet kérnek.
- A workshop-blokkokhoz rendelés a fájl végén van.

---

## 2. blokk — Pénzügyi gyorsító (BGG)

### 2.1 A `chi`-aszimmetria: visszavontuk, mégis ez fut

- **Kontextus:** a `chi_j` azt méri, mennyire nő egy típus hitelfelára, ha nő a
  tőkeáttétele. Ez a gyorsító ereje típusonként.
- **Nehézség:** az alapág `chi` = 0,06 / 0,06 / 0,02-t futtat (a KKV-k 3×
  érzékenyebbek). Ezt az állítást visszavontuk (V04), mert nincs forrása. A saját
  panelünk alsó korlátja +0,002, az irodalom 0,042–0,067 (F04). Méret szerinti
  szintbecslés nincs.
- **Miért számít:** a `chi`-sorrend megfordítása **megfordítja a
  szegmenssorrendet** (−1,22 pp → +0,74 pp, `t35`). Vagyis ma egy visszavont
  állítás számai viszik az egyik legerősebb aszimmetriát (alapértelmezés-konfliktus
  K01).
- **Kérdés a teremnek:**
  - `[hallgatók]` Miért lenne egy kisvállalat felára érzékenyebb a tőkeáttételre?
    Milyen közgazdasági érv szól mellette, és mi ellene?
  - `[szakértők]` Ha nincs méret szerinti becslés, a szimmetrikus `chi` a
    védhetőbb alapértelmezés, vagy az irodalmi érv a KKV-k nagyobb
    érzékenységére elég egy aszimmetrikus alapághoz?

### 2.2 A tőkeáttétel: az adat mást mond, mint az alapág

- **Kontextus:** a `lev_j` azt adja meg, mennyire mozdul a saját tőke a hozam
  változására.
- **Nehézség:** az Opten-panel szerint 1,94 / 1,72 / 2,34, és a sorrend
  mérőfüggetlen (A07). Az alapág mégis `lev_E = lev_D = 1,6`-ot futtat, pedig ezt
  az egyenlőséget az adat megcáfolta (A08, alapértelmezés-konfliktus K02).
- **Miért számít:** az A23 szerint a KKV-eredményt a pénzügyi heterogenitás
  hajtja, ezért a tőkeáttétel kalibrációja közvetlenül az eredmény forrásához
  tartozik.
- **Kérdés a teremnek:**
  - `[szakértők]` Elég bizonyíték-e egy mérőfüggetlen sorrend az alapértelmezés
    cseréjéhez, ha a szint mérőfüggő (sáv: E 1,68–1,94, D 1,58–1,72, L 1,81–2,34)?
    Melyik szintet válasszuk a sávból?

### 2.3 A banki átgyűrűzés iránya: az irodalom és a saját mérésünk ellentmond

- **Kontextus:** a `tbank_j` megadja, a banki forrásköltség csökkenése milyen
  mértékben jut el az egyes típusokhoz. Az alapág semleges (TSCEN=3).
- **Nehézség:** Horváth–Kotlebová–Širaňová (JFS 2018) szerint az euróövezetben a
  transzmisszió csak a kisvállalati hitelekre teljes. A magyar panelen viszont a
  pontbecslés mind a négy specifikációban a nagyvállalatnál magasabb (F06, A16),
  csak a különbség nem szignifikáns (t = 1,17…1,85).
- **Miért számít:** ha az euróövezeti mintázat érvényes Magyarországra a
  csatlakozás után, akkor a banki csatorna a KKV-k felé billentené az eredményt. Ha
  a magyar mérés, akkor a nagyvállalat felé.
- **Kérdés a teremnek:**
  - `[szakértők]` Melyik mintázatot higgyük el egy csatlakozás utáni Magyarországra:
    a jelenlegi magyarot vagy az euróövezetit? Mi magyarázhatja az eltérést
    (programhitelek, bankszerkezet, devizahitelezés)?

### 2.4 A szuverén átgyűrűzés típusonként

- **Kontextus:** a `tsov_j` azt adja meg, a szuverén felár csökkenése mennyire ér
  el az egyes típusok hitelfeláráig. Az alapág semleges.
- **Nehézség:** szintbecslés nincs. Bottero–Lenzu–Mezzanotti (JIE 2018) szerint a
  szuverén sokk mennyiségi átgyűrűzése méret-semleges, a reálhatás viszont nem. Ez
  pont a mostani szerkezetet támogatja: semleges `tsov` és méretfüggő hozzáférés.
- **Kérdés a teremnek:**
  - `[hallgatók]` Mi a különbség aközött, hogy egy sokk „mennyiségben” semleges, és
    hogy a „reálhatása” semleges? Hol jelenik meg ez a modellben?

---

## 3. blokk — Hitelhozzáférési (extenzív) margó

### 3.1 Programvezérelt hitelpiac: miért nem mérhető a csatorna?

- **Kontextus:** az `acc_j` azt méri, hány cég jut egyáltalán hitelhez. A javulása
  adott tőkeár mellett is több beruházást enged be.
- **Nehézség:** 2021–24-ben a BUBOR 12,8 pontot mozgott, a hozzáférési arányok
  legfeljebb 2,2-t (A04). A hazai KKV hozzáférése a kamatcsúcs felé még nőtt is
  (4,5% → 5,1%, A05), mert épp akkor bővültek a támogatott programok. Az
  `ACCSCALE` ebből nem horgonyozható (A06).
- **Miért számít:** a KKV-előny léte ezen a csatornán múlik, és a csatorna ereje
  nem mérhető abból az időszakból, amiről adatunk van.
- **Kérdés a teremnek:**
  - `[szakértők]` Van-e olyan időszak, régió vagy cégcsoport, ahol a hozzáférés a
    piaci kamatra reagált, nem a programokra? Például a programokból kizárt ágazatok,
    a jogosultsági küszöb körüli cégek, vagy a 2021 előtti időszak.
  - `[szakértők]` Egy IV-ből kapott „Δberuházás / Δhozzáférés” hányados a program
    teljes finanszírozási hatását méri, nem a csatorna strukturális rugalmasságát.
    Hogyan lehetne a kettőt szétválasztani?

### 3.2 Csak a szorzat azonosítható

- **Kontextus:** a csatorna két lépcsős. A felár a `λ` rugalmassággal javítja a
  hozzáférést, a hozzáférés az `ω` rugalmassággal a beruházást.
- **Nehézség:** a modell a kettőt külön nem azonosítja, csak a szorzatukat. A
  küszöb egy pontos izo-szorzat görbe: `λ·ω = 500 ± 0,08%` (A22, F01).
- **Miért számít:** egy empirikus horgonynak a szorzatra kell vonatkoznia. Egy
  kutatás, amely csak az egyik lépcsőt méri, önmagában nem elég.
- **Kérdés a teremnek:**
  - `[hallgatók]` Miért nem tudja a modell szétválasztani a két rugalmasságot? Mit
    kellene megfigyelnünk ahhoz, hogy külön-külön is azonosítható legyen?
  - `[szakértők]` Az EIBIS vagy a SAFE éves körének magyar mikrobontása a szorzatot
    méri, vagy csak az egyik lépcsőt?

### 3.3 A perzisztencia: leíró statisztika, nem horgony

- **Kontextus:** a `rho_acc` azt adja meg, mennyire tartós egy hozzáférési javulás.
  `1/(1−ρ)` alakban hat, ezért kis változása nagy hatású.
- **Nehézség:** a 0,9673 a cég-szintű „van hitele” státusz perzisztenciája, és a
  cégek 92,4%-a négy év alatt egyszer sem váltott. Ez főleg állandó heterogenitást
  mér, nem a modell dinamikus szegmensállapotát. A 0,85 → 0,9673 váltás a hosszú
  távú szorzót 4,6-szorosára viszi, a küszöböt 36,5-ről 22,3-ra.
- **Miért számít:** a küszöb szintje, vagyis az, hogy „mennyire erős csatorna kell”,
  közvetlenül ettől a paramétertől függ.
- **Kérdés a teremnek:**
  - `[szakértők]` Milyen almintából lehetne a szegmens dinamikus perzisztenciáját
    mérni? Például csak a státuszt váltó cégekből, vagy bank–cég kapcsolatok
    megszűnéséből.

### 3.4 A beruházási kiigazítási költség sorrendje valószínűleg fordított

- **Kontextus:** a `psi_j` azt adja meg, mennyire drága egy típusnak gyorsan
  változtatni a beruházásán.
- **Nehézség:** nincs közvetlen becslés, és a lumpy-investment irodalom
  (Khan–Thomas 2008; Bachmann–Caballero–Engel 2013) szerint a kis cégek beruházása
  rögösebb, vagyis `psi_S > psi_L`. Ez ellentétes a mostani feltevéssel. A `psi`
  a hat visszatérő hibaminta egyike.
- **Kérdés a teremnek:**
  - `[hallgatók]` Mi a különbség a „rögös” beruházás és a magas kiigazítási
    költség között? Lehet-e egy lineáris modellben rögösséget ábrázolni?
  - `[szakértők]` Érdemes-e a scant a fordított sorrenddel lefuttatni a workshop
    után, vagy ennek a paraméternek a kis modellben nincs is értelmezhető
    megfelelője?

### 3.5 A nagyvállalatnak nincs hozzáférési margója, de ez a feltevés gyenge

- **Kontextus:** a modellben csak a két KKV-típusnak van `acc` változója, a
  nagyvállalatnak nincs (`omega_acc_L = 0`).
- **Nehézség:** a nagyvállalatok hitelhozzáférése 43,4%, alacsonyabb, mint az
  exportáló KKV-ké (61,9%, A03).
- **Miért számít:** ha a nagyvállalatnak is van hozzáférési margója, a KKV-előny egy
  része eltűnhet, mert a csatorna mindenkire hat.
- **Kérdés a teremnek:**
  - `[szakértők]` A nagyvállalatok alacsonyabb hitelaránya hozzáférési korlátot
    jelez, vagy azt, hogy nincs rá szükségük (belső forrás, anyavállalati hitel)?
    Melyik esetben kell a nagyvállalatnak is margó?

---

## 4. blokk — Termelés

### 4.1 Mi számít exportáló KKV-nak?

- **Kontextus:** a `phi_j` a típus exportárbevétel-aránya. Ettől függ, a típus
  mennyire érzi a hazai és mennyire a külföldi keresletet.
- **Nehézség:** a nagyvállalatnál 0,365, négy tizedesig egyezik az átvett értékkel
  (A10). Az export-KKV-nál viszont definíciófüggő: 0,376 (ALAP) vagy 0,691
  (KÜSZÖB25).
- **Kérdés a teremnek:**
  - `[szakértők]` Melyik definíció illik a kérdésünkhöz? Az „exportál valamennyit”
    vagy az „árbevételének legalább negyede export”?

### 4.2 A technológiai paraméterek még nincsenek kitöltve

- **Kontextus:** a `zeta_j` (tőkeintenzitás) és az `aa_j` (munka–import arány)
  típusonként, valamint a GDP-arányok (`sc si sg sx sm`).
- **Nehézség:** mind a 11 B-kategóriás paraméter KSH-adatból pótolandó. Az A23
  szerint a technológia kiegyenlítése a küszöböt csak 3%-kal mozdítja, tehát ez nem
  az eredmény forrása.
- **Kérdés a teremnek:**
  - `[szakértők]` Melyik KSH vagy Eurostat SBS táblából lehet ezt a legtisztábban
    méret × exportstátusz bontásban kinyerni?

---

## 5. blokk — Árak és bérek

### 5.1 Ragadós bérek egy gyenge bérmerevségű gazdaságban

- **Kontextus:** a bérek a JV-ből átvett, becsült Calvo-merevséggel követnek egy
  Phillips-görbét.
- **Nehézség:** a saját panelünk szerint 2023–24-ben a nominális bérmerevség gyenge
  (A21). A cégek 10,1%-a nominálisan csökkentette az átlagbért, csak 2,8%
  fagyasztotta be, a medián emelés 11,6%. A csökkentés gyakorisága a mérettel
  csökken (13,9% / 7,6% / 5,8%).
- **Miért számít:** euróban nincs árfolyam, ami alkalmazkodna, ezért a bérek
  rugalmassága veszi át a szerepét. Ha a KKV-k bérei rugalmasabbak, ez újabb
  méretaszimmetria, amit a modell most nem ábrázol.
- **Kérdés a teremnek:**
  - `[hallgatók]` Miért fontosabb a bérrugalmasság egy valutaunióban, mint önálló
    árfolyam mellett?
  - `[szakértők]` Egy magas inflációs időszak (2023–24) bérmerevségi mérése
    mennyire vihető át egy euróövezeti alacsony inflációs környezetre?

---

## 6. blokk — Kereslet és export

### 6.1 A helyettesítési rugalmasság fordítja az előjelet

- **Kontextus:** az `eps_ces` megadja, mennyire helyettesítik a vevők egyik
  vállalattípus termékét a másikéval.
- **Nehézség:** az export-KKV kibocsátásának előjele kb. 2,3-nál megfordul (F02).
  Van magyar markup-becslés (Dobrinsky–Kőrösi–Markov–Halpern, JCE 2006), de az a
  termékváltozatok közti helyettesítést méri, nem a vállalattípusok közöttit. Ezért
  csak plauzibilitási sáv.
- **Miért számít:** ez a szegmens-szintű kibocsátás egyik előjel-fordítója. Emiatt
  nem közöljük pontbecslésként.
- **Kérdés a teremnek:**
  - `[hallgatók]` Mit jelent közgazdaságilag, hogy egy KKV terméke „helyettesíti” a
    nagyvállalatét? Mit vesz meg a háztartás a D típustól, és mit az L-től?
  - `[szakértők]` Létezik-e bármilyen becslés a vállalatméret-kategóriák közötti
    keresleti helyettesítésre? Ha nincs, mi lenne a legjobb közvetett támpont?

### 6.2 Beszállítói kapcsolat: hibás mérés, nincs irodalom

- **Kontextus:** az `s_kkv` a KKV-k súlya a nagyvállalatok beszállítói láncában,
  a `mu_vert` a beszállítói ár-átgyűrűzés rugalmassága.
- **Nehézség:** az IO-alapú `s_kkv` számítás hibás, a „6% hazai köztes input”
  állítást visszavontuk (V02). A `mu_vert`-re a keresés után sem találtunk becslést.
  Egy megkerülő forrás: OECD TiVA/ICIO és az OECD Economic Surveys: Hungary 2026
  KKV-fejezete.
- **Miért számít:** a magyar KKV-k egy része a nagyvállalatokon keresztül „exportál”.
  Ha ez a csatorna erős, az euró a nagyvállalaton át is eléri a KKV-t.
- **Kérdés a teremnek:**
  - `[szakértők]` Mennyire fontos ez a csatorna a központi kérdésünkhöz? Megéri-e
    a decemberi határidőig pótolni, vagy kimondhatjuk korlátként?

---

## 7. blokk — Monetáris rezsim

### 7.1 A szuverén felár átgyűrűzése a kamatba

- **Kontextus:** a `zsov` megadja, a szuverén felár mekkora része jelenik meg a
  hazai kamatban.
- **Nehézség:** horgonyzatlan, de a D kategóriában ez a legolcsóbb: két nyilvános
  idősorból mérhető (a szuverén felár és a BUBOR–EURIBOR különbözet). Irodalmi
  támpont: Vonnák (MNB WP 2010/1).
- **Kérdés a teremnek:**
  - `[szakértők]` A BUBOR–EURIBOR különbözet jó közelítése-e annak, ami euróban
    megmarad a szuverén felárból? Mit tanít erről a szlovák vagy a horvát
    csatlakozás?

### 7.2 Tényleg csak a szuverén csatorna számít?

- **Kontextus:** az F05 szerint a banki csatorna hozzájárulása az első negyedévben
  a teljes hatás 0,22%-a.
- **Nehézség:** ezt az összevetést az **első negyedévben** mérjük, amikor a banki
  felár a szcenárióban még el sem indult: az csak a 13. negyedévtől csökken. Az
  első negyedévben csak az előre látott jövőbeli csökkenés hat. A 0,22% ezért
  részben a forgatókönyv időzítéséből következik, nem a csatorna gyengeségéből.
- **Miért számít:** ha a banki csatornát a tartós hatáson mérnénk, más arányt
  kaphatnánk. Ez befolyásolja, hová fordítsuk a horgonyzási munkát.
- **Kérdés a teremnek:**
  - `[hallgatók]` Mit jelent tökéletes előrelátás mellett, hogy egy csak a 13.
    negyedévben induló sokk már az 1. negyedévben hat?
  - `[szakértők]` Melyik mérés a releváns a közléshez: az azonnali, a csatlakozás
    körüli vagy a tartós hozzájárulás?

> Belső teendő: az F05-öt újra kell mérni a tartós hatáson is, mielőtt a
> bemutatóban vagy a tanulmányban „a szuverén csatorna viszi” formában szerepel.

### 7.3 Mi a kamat euróban?

- **Kontextus:** euróban a hazai kamat a szuverén felárral együtt mozog, és a
  modellben nincs külön közös kamatpálya: a v09-ben az euróövezeti kamat
  implicit módon 0 eltérésű.
- **Nehézség:** a v10 `r_for` változója ezt pótolná, de csak az UIP- és az
  euróágon. A hazai Taylor-szabályba szándékosan nem kerül be, mert az EAGLE-ben
  sem oda kötődik.
- **Kérdés a teremnek:**
  - `[szakértők]` Befolyásolja-e érdemben az eredményt, hogy a csatlakozás idején
    az EKB éppen szigorít vagy lazít? Kellene-e ilyen szcenárió?

---

## 8. blokk — Külföldi kereslet és kamat (v10)

### 8.1 Két exportkeresleti csatorna, egy megfigyelés nélkül

- **Kontextus:** a v10 mindhárom típus exportegyenletébe beköti a külföldi
  keresletet (`ystar`). A v09-ben már van egy közös exportkeresleti sokk (`e_x_ar`).
- **Nehézség:** az `ystar` nem megfigyelt, ezért a két csatorna szétválasztását ma
  csak az előre rögzített perzisztenciák végzik, nem az adat. Determinisztikus
  forgatókönyvekhez jó, becsléshez még nem.
- **Kérdés a teremnek:**
  - `[szakértők]` Kell-e egyáltalán két külön csatorna, vagy elég egy, megfigyelt
    euróövezeti kereslettel kalibrálva?

### 8.2 A perzisztencia forrásai nincsenek ellenőrizve

- **Nehézség:** a `rho_ystar` és a `rho_rfor` 0,40 / 0,625 / 0,85 érzékenységi
  rácson fut. A három jelölt forrás (MNB WP 2008/9, ECB EAGLE WP1195, MNB WP 2013/1)
  még nincs ténylegesen ellenőrizve.
- **Kérdés a teremnek:**
  - `[szakértők]` Mi a magyar DSGE-gyakorlatban a standard érték a külföldi kereslet
    perzisztenciájára?

---

## Az euró-forgatókönyv

### F.1 A −200 bp honnan jön?

- **Kontextus:** az alap szcenárióban a szuverén felár −200 bp-tel, a banki −45
  bp-tel csökken, 16 negyedév alatt.
- **Nehézség:** ez hivatkozás nélküli, kalibrált kontrafaktuális, nem empirikusan
  azonosított euróhatás (A01 megjegyzése).
- **Miért számít:** az aggregált eredmény szinte teljes egészében ezen a számon
  múlik.
- **Kérdés a teremnek:**
  - `[szakértők]` Melyik csatlakozási tapasztalat és milyen módszer adná a legjobb
    horgonyt? Mekkora része a felárcsökkenésnek, ami már a bejelentéskor
    beárazódik?

### F.2 Hihető-e a tökéletes előrelátás?

- **Kontextus:** a szereplők a teljes pályát előre ismerik, a csatlakozás időpontját
  is.
- **Nehézség:** a valóságban a csatlakozás időpontja bizonytalan, és a bejelentés
  hitelessége maga is változó.
- **Kérdés a teremnek:**
  - `[hallgatók]` Hogyan változna az eredmény, ha a szereplők nem hinnének a
    bejelentésnek?
  - `[szakértők]` Érdemes-e egy „késleltetett hitelesség” szcenáriót futtatni,
    amelyben a felárcsökkenés csak a csatlakozás után indul?

---

## Eredmények és módszertan

### E.1 A magas perzisztenciájú ágak nem határozottak

- **Kontextus:** a fő `OPTEN=0` ág 9/9 BK-stabil (13 instabil gyök / 13
  előretekintő változó). Az `OPTEN=1/2/3` ágakon 15 jut 13-ra (A12).
- **Nehézség:** pont az Opten-kalibrált ágak indeterminátusak terminálisan, és ezek
  közölt küszöbpontjai csak külön ellenőrizve BK-érvényesek.
- **Kérdés a teremnek:**
  - `[szakértők]` Ez a modell specifikációs hibáját jelzi (a magas `rho_acc` és a
    rezsim együtt instabil), vagy egy közgazdaságilag értelmezhető jelenséget
    (többszörös egyensúly)?

### E.2 Elfogadható-e a küszöbforma?

- **Kontextus:** a KKV-eredményt küszöbként közöljük, nem pontbecslésként. Magyar
  precedens: Szabó Bakos (2006), 4.7.
- **Kérdés a teremnek:**
  - `[szakértők]` Egy MKIK-olvasónak és egy bírálónak is elég-e a küszöbforma?
    Hogyan kommunikáljuk úgy, hogy ne olvassák se „a KKV-k nyernek”, se „nem tudunk
    semmit” formában?

---

## Hozzárendelés a workshop-blokkokhoz

| Workshop-blokk | Idő | Pontok |
|---|---|---|
| A modell közös „boncolása” | 0:25–0:50 | 2.4, 3.2, 3.4, 5.1, 6.1 — a `[hallgatók]` kérdésekkel |
| Egy euró-forgatókönyv végigvezetése | 0:50–1:15 | F.1, F.2, 7.2, 7.3 |
| Mi hajtja a KKV-eredményt? (paraméter-tábla) | 1:25–1:50 | 2.1, 2.2, 3.1, 3.3, 3.5, 6.1, 4.1 |
| Bírálói kör | 1:50–2:05 | E.1, E.2, 2.3, 6.2 |
| Nincs rá idő, írásban kérdezzük | — | 4.2, 7.1, 8.1, 8.2 |
