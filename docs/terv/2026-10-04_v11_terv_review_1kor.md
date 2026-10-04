# Adversarial review a v11 implementációs tervéről

**Dátum:** 2026-10-04  
**Átnézett anyagok:** `00_PROMPT_CHATGPT-NEK.md`, `01_OSSZEFOGLALO_ADATCSOMAG.md`, `02_v11_implementacios_terv.md`  
**Hatókör:** logikai, közgazdasági és implementációs kontroll; a közölt futások újrafuttatása nélkül.

## Súlyos problémák

### S1. A K-1 algebrailag helyes, de a „standard BGG-tulajdonság” következtetés nem igazolt

**Hivatkozás:** adatcsomag D.1; terv 1.1, K-1; terv 8.1.

**Indoklás:** A közölt négy egyenletből, tartós egyensúlyban és nulla `eps_q` mellett valóban következik

`nw = omega_nw * lev * efp / (1 - omega_nw)`.

Ezért a levezetés matematikailag helyes. Ebből azonban nem következik, hogy a negatív hosszú távú `nw`-reakció a standard BGG közgazdasági tulajdonsága. A megadott nettóvagyon-egyenlet egy lokális, redukált alak: nem látszik benne külön az új vállalkozók induló transzfere vagy vállalkozói munkajövedelme, illetve a túlélő és új belépő vállalkozók aggregálása. Ezek a teljes BGG-rendszerben a nettó vagyon állandósult szintjének lezárásához tartoznak. A jelenlegi képlet permanens `endval`-változásra alkalmazva mechanikusan egy új, negatív `nw`-eltérést állít elő, miközben a koefficiensek és a lineárizáció kiinduló steady state-je változatlan marad.

A Bernanke–Gertler–Gilchrist-modell pénzügyi gyorsítója a hitelfelvevő nettó vagyonának és a külső finanszírozási prémiumnak az endogén kapcsolatára épül, de a csomagban idézett egyenletből önmagában nem bizonyítható, hogy egy permanens prémiumcsökkenésnek csökkentenie kell a hosszú távú nettó vagyont. A terv mondata – „kevesebb többlethozamot halmoznak fel, ezért ez BGG-logika” – túl erős.

**Javaslat:** A K-1-et ne zárjátok le „nem modellmódosításként”. Implementáció előtt:

1. vezessétek le a `nw`-egyenletet a használt JV/BGG nemlineáris modellből;
2. azonosítsátok, hol szerepel a túlélési arány, a vállalkozói fogyasztás/transzfer és az új belépők saját tőkéje;
3. ellenőrizzétek, hogy a permanens euró-szcenárió új steady state-je mellett jogos-e a régi steady state körüli lineáris egyenlet használata;
4. addig az A25 eredményt csak a jelenlegi redukált specifikáció tulajdonságaként, ne strukturális BGG-következtetésként kommunikáljátok.

Ez nem jelenti automatikusan azt, hogy át kell írni az egyenletet. Azt jelenti, hogy a „nem módosítjuk” döntés jelenlegi indoklása elégtelen.

### S2. Az `ACCSPEC=1` nem általánosan helyes loglinearizálása az extenzív hitelmargónak

**Hivatkozás:** terv 4.3–4.4.

**Indoklás:** Ha az aggregált beruházás szintben például

`I = A * I_credit + (1-A) * I_nocredit`,

akkor ennek elsőrendű loglinearizálása nem automatikusan

`i = i_tilde + omega_acc * acc`.

Az `acc` együtthatója függ a steady-state hozzáférési aránytól, a két csoport steady-state beruházásától, valamint attól, hogy `acc` logeltérés, százalékpontos eltérés vagy szinteltérés. Ha a nem hitelezett cégek beruházása nulla, akkor egy speciális esetben adódhat egyszerű összeg, de ekkor az együtthatót sem lehet szabadon „a belépők relatív beruházásaként” értelmezni. A mostani `omega_acc` horgonyzatlan, így az új alak ugyan megszünteti a negatív tartós q-t, de új strukturális levezetés nélkül csak áthelyezi az önkényes forcingot.

**Javaslat:** Előbb írjátok fel a szintbeli aggregációs azonosságot, definiáljátok `acc` mértékegységét, majd abból vezessétek le az együtthatót. Legalább három steady-state adat kell: hozzáférési arány, hitelezett cégek átlagos beruházása és nem hitelezett cégek átlagos beruházása. Ha ezek nem állnak rendelkezésre, az `ACCSPEC=1` csak dokumentált redukált forma lehet, érzékenységi sávval; ne nevezzétek levezetett összetételi egyenletnek.

### S3. A K-1-et érintő permanens szcenáriókhoz hiányzik a nemlineáris steady-state audit

**Hivatkozás:** adatcsomag 8–10. sor, C.2, D.1; terv 7.

**Indoklás:** A „tartós” eredmény egy perfect-foresight `endval` egyensúly, miközben az egész modell a kiinduló steady state körüli loglineáris eltérésekben van felírva. Egy permanens pénzügyi ék-, árfolyamrezsim- és kamatváltozásnál nem elég az új lineáris fixpont matematikai létezése: ellenőrizni kell, hogy az megfelel-e a mögöttes nemlineáris egyensúly elsőrendű közelítésének. Ez különösen kritikus, amikor éppen a hosszú távú `nw`, `q`, tőkeáttétel és KKV–L különbség a fő eredmény.

**Javaslat:** Tegyetek a v11 elé külön steady-state validációs kaput. Ha nincs rendelkezésre álló nemlineáris modell, ezt korlátként kell kimondani, és a tartós eredményeket „a loglineáris rendszer permanens forcing melletti fixpontjaként” kell nevezni, nem új strukturális steady state-ként.

### S4. A 7.1 szerinti kötelező szimmetriateszt több kapcsoló-kombinációban definíció szerint nem teljesülhet

**Hivatkozás:** terv 2.4, 5.3, 7.1/4.

**Indoklás:** Az L-típusnak nincs `acc_L` extenzív margója, ezért bekapcsolt hozzáférési csatorna mellett a három típus azonos paraméterezése sem teszi azonossá az E/D/L egyenletrendszert. Ugyanez igaz W3-ra, ha `fx_E`, `fx_D`, `fx_L` eltér. A „minden kapcsoló-kombinációra SYM=1 mellett a három típus azonos” feltétel tehát vagy hamisan bukik, vagy a tesztmakró valójában további csatornákat is kikapcsol, amit a terv nem mond ki.

**Javaslat:** Bontsátok ketté:

- teljes E=D=L szimmetria csak `ACCSCALE=0` és közös `fx` mellett;
- bekapcsolt hozzáférésnél E=D szimmetria, L-re pedig külön, előre definiált eltérés.

### S5. A horizontteszt túl gyenge a mért 0,9941-es gyök mellett

**Hivatkozás:** adatcsomag C.4; terv 7.1/6.

**Indoklás:** A `|z|=0,9941` gyök amplitúdó-felezési ideje hozzávetőleg

`ln(0,5) / ln(0,9941) ≈ 117` negyedév.

A 120 negyedéves futás tehát csak körülbelül egy felezési időt fed le. A közölt adatok szerint a 120 és 400 negyedéves megoldás a 120. negyedévben 0,737 százalékponttal tér el, és még a 400. negyedévben sincs teljes konvergencia. Az „első 60 negyedév eltérése <0,05 pp” feltétel ezt elfedi: a jelenlegi hibásan rövid horizont már majdnem teljesíti ezt, miközben a későbbi pálya lényegesen eltér.

**Javaslat:** A horizontot a spektrális felezési időhöz és a tényleges riportálási ablakhoz kössétek. Követeljétek meg a célváltozók pályájának stabilitását a teljes közölt időablakon, a terminális reziduumok kicsiségét, valamint azt, hogy a horizont végi állapot kellően közel legyen az `endval`-hoz. A 120 negyedévet a jelenlegi specifikáció mellett ne tekintsétek elfogadható referenciahorizontnak.

## Közepes problémák

### K1. A `bstar(-1)` védhető timing-döntés, de nem a Schmitt-Grohé–Uribe-forma pontos átvétele

**Hivatkozás:** terv 3.2; adatcsomag E/1.

**Indoklás:** Schmitt-Grohé és Uribe (2003) 2. modelljében a periódus `t` kamata az aktuális aggregált adósság `d_t` függvénye, miközben az adósság költségvetési egyenlete külön rögzíti az időzítést. Tehát a cikk nem támasztja alá közvetlenül a `bstar(-1)` használatát. A lagelt külső pozíció ettől még lehet jobb saját specifikáció, ha `bstar_t` nálatok a periódus végi állomány és el akarjátok kerülni az aznapi kereskedelmi mérleg algebrai visszacsatolását.

További probléma, hogy a változó a kódban előjel alapján inkább nettó külföldi eszköznek tűnik, miközben a terv adósságként beszél róla. A timing és az előjel csak a stock-flow definícióból dönthető el.

**Javaslat:** Definiáljátok explicit módon: `bstar` NFA vagy adósság, időszak eleji vagy végi állomány, és melyik kamat vonatkozik rá. A `bstar(-1)`-et saját modellválasztásként, ne irodalmi azonosságként dokumentáljátok.

### K2. A „felezési idő < 40 negyedév; legkisebb megfelelő nu” szabály önkényes és eredményhangolásra alkalmas

**Hivatkozás:** terv 3.3.

**Indoklás:** A 40 negyedév a választott 120-as numerikus horizontból származik, nem gazdasági adatból. A numerikus horizontot kell a gazdasági perzisztenciához igazítani, nem a perzisztenciát a horizonthoz. A „legkisebb átmenő érték” diszkrét rácson ráadásul erősen rácsfüggő. A Schmitt-Grohé–Uribe-paraméter számszerű értéke nem vihető át közvetlenül, mert az adósság skálája és az egyenlet normalizálása eltérhet.

**Javaslat:** A 40 negyedév legfeljebb diagnosztikai jelző legyen. Az alapértéket külső spread–NFA/adósság rugalmasságból, vagy kifejezetten „kis, csak stationaritást biztosító” technikai normalizációból válasszátok. Közöljétek a teljes rácsot, és ne automatikus győztesként kezeljétek az első átmenő pontot.

### K3. A W2a sorrendje elveszíti a tiszta v10-es oksági diagnózist

**Hivatkozás:** terv 2/D3; 4.2.

**Indoklás:** Ha előbb módosítjátok W1-et, majd azon mértek sajátvektort, nem lesz tiszta kiinduló mérés arról, mi hajtja a v10 `|z|=0,9941` gyökét. A terv említi a W1 előtti és utáni összevetést, de a munkasorrend ezt nem rögzíti elég világosan.

**Javaslat:** Sorrend: `W2a-v10 baseline → W1 → W2a-W1 → W2 → W3`. A baseline diagnosztika fusson a teljesen érintetlen v10-en.

### K4. A K-4 q-diagnózisa bizonyított, a ciklus oksági diagnózisa még nem

**Hivatkozás:** adatcsomag D.2 és C.4; terv 1/K-4, 4.2.

**Indoklás:** A negatív tartós q az adott beruházási egyenletből pontosan következik; az aritmetika helyes. Az, hogy `ACCSCALE=0` mellett a domináns gyök 0,9234-re esik, erős bizonyíték arra, hogy a hozzáférési hurok fontos. Nem bizonyítja azonban, hogy kizárólag az additív tag okozza. A ciklust együtt alakíthatja `rho_acc`, `omega_nw`, a beruházás lead–lag szerkezete, `psi`, a BGG-visszacsatolás és a külsőpozíció-zárás.

**Javaslat:** Az ACCSCALE-rács mellett külön nullázzátok vagy rácsozzátok `rho_acc`, `omega_nw`, `lambda_acc`, `omega_acc` és `psi` értékét; a `lambda*omega` szorzatot tartó skálázást is futtassátok. A sajátvektorokat normalizált részvételi mutatóval közöljétek, mert a nyers sajátvektor-komponensek skálafüggők.

### K5. Az `ACCSPEC=2` nem tiszta extenzív margó és könnyen kettős beszámítás

**Hivatkozás:** terv 4.3.

**Indoklás:** Az `acc` a felárból képződik, majd ugyanabba a megkövetelt hozam egyenletbe negatív tagként visszakerül. Ez egy új pénzügyi visszacsatolás, nem egyszerű alternatív elhelyezése ugyanannak az extenzív margónak. Külön mikroökonómiai levezetés nélkül az `efp - omega_acc*acc` az ár- és mennyiségi hitelkorlátot összemossa, és részben kétszer számolhatja ugyanazt a könnyítést.

**Javaslat:** Az `ACCSPEC=2` maradjon exploratory robustness, ne az `ACCSPEC=1` azonos rangú strukturális versenytársa. Ha megtartjátok, külön néven és külön paraméterrel szerepeljen.

### K6. A W3 átértékelési tag előjele és alapkoefficiense védhető, de az `fx_j` definíciója túl laza

**Hivatkozás:** terv 5.2–5.3.

**Indoklás:** Ha `lev = eszköz/saját tőke`, akkor az adósság/saját tőke arány `lev-1`; pozitív `dep` leértékelődés, a devizaadósság pedig fedezetlen, akkor a `-(lev-1)*fx*dep` előjel és elsőrendű skála helyes. Az MNB „devizahitelek aránya” azonban nem feltétlenül a szükséges változó. A modellhez a nettó, fedezetlen devizapozíció kell: devizakötelezettség mínusz devizaeszközök, derivatív fedezet és természetes exportbevétel-fedezet releváns része.

**Javaslat:** `fx_j`-t effektív, fedezetlen nettó devizakitettségként definiáljátok. Ha csak bruttó devizahitel-részarány van, azt felső korlátként vagy külön bruttó-expozíciós forgatókönyvként használjátok, ne pontbecslésként.

### K7. A W3 „csak átértékelés” első köre részmodellként elfogadható, teljes specifikációként nem

**Hivatkozás:** terv 5.2, nyitott kérdés.

**Indoklás:** A devizaadósság törlesztési költsége a külföldi kamattól, a hitelfelártól és az árfolyamváltozástól függ. A jelenlegi `nw`-egyenlet az összes adósság finanszírozási költségét a hazai reálkamathoz köti. Az átértékelési tag felvétele, miközben az adósság kamatoldala változatlan marad, dokumentált részleges kísérletként hasznos, de nem teljes devizaadósság-blokk. Perfect foresight alatt a várt leértékelődés és az UIP miatt különösen gondosan kell kerülni az árfolyamhatás kettős beszámítását.

**Javaslat:** Két lépcső legyen: W3a revaluation-only, világosan „partial” címkével; W3b levezetett, súlyozott finanszírozási költséggel. A teljes változatban ellenőrizzétek az UIP-vel való konzisztenciát és a dupla `dep`-hatást.

### K8. A K-3 pozitív GDP-hatás önmagában nem modellhiba

**Hivatkozás:** terv 1/K-3 és 5.1.

**Indoklás:** Egy külföldi kamatemelés okozta leértékelődés exporton keresztül növelheti a rövid távú kibocsátást. A devizaadósság mérleghatása legitim hiányzó csatorna lehet, de nem következik belőle, hogy a helyes összhatásnak negatívnak kell lennie. Maga a Céspedes–Chang–Velasco-logika is két ellentétes csatornát hangsúlyoz: a leértékelődés rontja a devizában eladósodott vállalat mérlegét, de javíthatja az eszközoldali hozamot és a versenyképességet.

**Javaslat:** W3 elfogadása ne függjön attól, megfordul-e a GDP előjele. A csatornát az adatolt nettó kitettség és a helyes mérlegazonosság igazolja; az előjel eredmény.

### K9. A csatlakozáskor nem szükségszerű külön mérlegugrás, de az ezt kizáró feltevést le kell írni

**Hivatkozás:** terv 5.2.

**Indoklás:** Ha az euróbevezetéskor az eszközök és kötelezettségek ugyanazon, várt piaci átváltási árfolyamon redenominálódnak, nincs önálló számviteli vagyonhatás; a belépés után `dep=0`, tehát a folyamatos átértékelési kockázat megszűnik. Ugrás csak eltérő konverziós ráta, nyitott pozíció vagy szerződéses aszimmetria esetén szükséges.

**Javaslat:** Írjátok be explicit feltevésként: nincs konverziós meglepetés és egységes redenomináció. Enélkül a „tag kikapcsol” túl automatikusnak tűnik.

### K10. Az `ACCSCALE=0 → v08 pontosan` állítást közös változókra kell korlátozni

**Hivatkozás:** terv 4.4 és 7.1/5.

**Indoklás:** `ACCSPEC=1` két új `i_tilde` változót és két új egyenletet vezet be. `ACCSCALE=0` mellett a régi változók pályája elvileg reprodukálható, de a modell dimenziója és sajátérték-reprezentációja nem azonos a v08-cal. A teljes rendszer „bitazonossága” ezért félrevezető követelmény.

**Javaslat:** A nesting-teszt a v08 közös endogén változóira, reziduumaira és riportált eredményeire vonatkozzon; az új segédváltozókat külön ellenőrizzétek. A BK előretekintő változók számát ne keménykódoljátok a régi modellből.

## Apróbb, de javítandó pontok

### A1. A `nu_uni=0,25` és `nu_b=0,001` 250-szeres különbsége csak modellen belül értelmezhető

**Hivatkozás:** terv 3.1.

Az összevetés ugyanabban a modellben informatív, de a Schmitt-Grohé–Uribe-féle számmal nem vethető össze közvetlenül a `bstar` eltérő normalizálása miatt. Minden `nu` mellett közöljétek a `bstar` mértékegységét és az implikált kamatváltozást egy 1 GDP-százalékpontos pozícióváltozásra.

### A2. A +25 bp negyedéves sokk évesített méretét is közölni kell

**Hivatkozás:** adatcsomag A.2/K-3.

Ha a kamat loglinearizált negyedéves ráta, +25 bp negyedéves változás közel +100 bp évesített sokk. Ez lényeges a +0,68%-os leértékelődés és a +0,19%-os GDP-hatás értelmezéséhez.

### A3. A `lambda*omega` azonosítás csak a jelenlegi megfigyelési struktúrában igaz

**Hivatkozás:** adatcsomag D.3; terv 4.4.

Az algebra a jelenlegi lineáris modellben helyes, ha `acc` máshol nem szerepel és nincs önálló `acc`-megfigyelési egyenlet. Ha később hitelhozzáférési adatot illesztetek vagy az `acc` több egyenletbe kerül, az azonosítási állítás megváltozik. Ezt feltételes állításként írjátok a regiszterbe.

### A4. Az aritmetikai ellenőrzések rendben vannak

**Hivatkozás:** adatcsomag C.2, D.1–D.2.

A közölt `efp_E`-felbontás, a nettóvagyon-képlet és a tartós q közelítő újraszámítása belsőleg konzisztens. A kerekítési eltérések nagyságrendje hihető. Ez az algebrai helyességet igazolja, nem a mögöttes specifikáció strukturális helyességét.

## Hiányzó ellenőrzések és javasolt sorrend

### Kötelezően hozzáadandó ellenőrzések

1. **Nemlineáris steady-state/relinearizációs audit** a permanens szcenáriókhoz, különösen `nw`, `q`, leverage és `efp` esetén.
2. **Stock-flow és előjel audit** a `bstar` változóra: NFA vagy adósság, periódus eleji vagy végi állomány, GDP- vagy szintnormalizálás.
3. **Szintbeli aggregációs azonosság** az `ACCSPEC=1` mögé, az `acc` pontos mértékegységével.
4. **Root tracking és részvételi tényezők**, nem csak skálafüggő nyers sajátvektorok.
5. **Horizon- és terminálisreziduum-teszt** a spektrális felezési idő alapján.
6. **W3 nesting:** `fx=0` pontosan adja vissza a W3 nélküli közös változókat; `dep=0` mellett a revaluation tag nulla; nincs kétszeres árfolyamhatás.
7. **Nettó FX-kitettségi érzékenység:** nulla, közös aggregált, méret szerinti, valamint bruttó felső korlát.
8. **Izolált sokkteszt:** `r_for`-sokk mellett `ystar`, `sov`, `bank` és egyéb külső sokkok nullán; a sokk negyedéves/évesített egysége dokumentálva.
9. **Rezsimenként azonos zárási benchmark:** legalább egy teszt azonos kis `nu` mellett, hogy az unió–lebegő különbséget ne a 250-szer eltérő technikai lezárás vezesse.
10. **Szimmetriateszt újradefiniálása** az S4 szerint.

### Javasolt implementációs sorrend

1. K-1 strukturális és steady-state audit – ez a fő eredmény értelmezésének kapuja.
2. W2a az érintetlen v10-en.
3. W1 teljes rácsa, automatikus „40 negyedéves győztes” nélkül.
4. W2a ismét W1 mellett.
5. Az `ACCSPEC=1` szintbeli levezetése és csak utána implementáció; `ACCSPEC=2` exploratory ágként.
6. W3a átértékelési részmodell; majd W3b teljes finanszírozási költség, ha levezethető.
7. Egyedi csomagok, páronkénti kombinációk és a teljes W1+W2+W3 csomag.
8. Csak ezután csapatdöntés az alapértelmezésről.

## Fabrikálási kockázat értékelése

A terv anti-fabrikálási szabályai jók és lényegesen javítják az auditálhatóságot. A kapcsolók, a régi eredmények megőrzése, a kedvezőtlen eredmények kötelező közlése és az irányfüggetlen BK/nesting tesztek erős elemek.

A gyenge pontok azonban tartalmiak:

- a K-1 megtartását jelenleg egy nem igazolt „standard BGG” történet védi, miközben az eredmény a KKV-k számára kedvező;
- a W1 40 negyedéves szabálya numerikus célból választ strukturális paramétert;
- az `ACCSPEC=1` előzetes elsődlegessége nem véd a fabrikálástól, ha maga a formula és az `omega_acc` nincs levezetve vagy adatból horgonyozva;
- W3-at részben a pozitív GDP-válasz motiválja, pedig az előjel önmagában nem hiba.

Az előzetes rögzítés szükséges, de nem elégséges: egy előre rögzített, gyengén azonosított vagy önkényes szabály továbbra is eredményhangolást tehet lehetővé.

## Összegzés

A terv **jelen formájában nem implementálható változtatás nélkül**. A W1, W2 és W3 kutatási iránya mind védhető, de a K-1 „nem módosítjuk, mert standard BGG” döntést vissza kell nyitni; ez a legsúlyosabb pont, mert a projekt egyik fő hosszú távú eredményét érinti. Az `ACCSPEC=1` csak szintbeli aggregációból levezetve fogadható el, a W1 40 negyedéves automatikus választási szabályát el kell hagyni, a W3-at pedig nettó fedezetlen devizakitettségre és később konzisztens finanszírozási költségre kell építeni. Ezekkel a feltételekkel a terv implementálható és kifejezetten jól auditálhatóvá tehető.

## Ellenőrzött szakirodalmi pontok

- Schmitt-Grohé, S. – Uribe, M. (2003): *Closing Small Open Economy Models*. A debt-elastic prémium a cikk 2. modelljében az aktuális aggregált adósság `d_t` függvénye; a lagelt `bstar(-1)` tehát nem a cikk pontos timingjának másolata, hanem külön modellválasztás. A cikk kalibrációja nagyon kis stationaritási paramétert használ, de annak száma eltérő normalizálás mellett nem vihető át mechanikusan.
- Bernanke, B. – Gertler, M. – Gilchrist, S. (1998/1999): *The Financial Accelerator in a Quantitative Business Cycle Framework*. A csomag redukált `nw`-egyenletének permanens fixpontja nem azonosítható automatikusan a teljes BGG-rendszer strukturális hosszú távú tulajdonságaként.
- Céspedes, L. F. – Chang, R. – Velasco, A. (2004): *Balance Sheets and Exchange Rate Policy*, valamint Gertler, Gilchrist és Natalucci nyitott gazdasági pénzügyi gyorsítója alátámasztja a devizaadósság mérlegcsatornájának relevanciáját, de nem azt, hogy a teljes GDP-hatásnak szükségképpen negatívnak kell lennie.
