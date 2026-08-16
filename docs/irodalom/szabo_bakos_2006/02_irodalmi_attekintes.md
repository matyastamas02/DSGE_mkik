# 2. fejezet — Irodalmi áttekintés

*Szabó Bakos (2006), 6–69. o. (PDF 11–74). A leghosszabb fejezet: az
új-keynesi alapmodell felépítése, majd öt bővítés, mindegyiknél azzal a
kérdéssel, hogy **mit tesz hozzá az empirikus illeszkedéshez**.*

**Relevancia: 🟡 közepes**, a 2.4 (ragadós bérek) 🟢. Ami itt van, azt a
JV-mag már tartalmazza — de a *miért* magyarázatok jók, és az `A21`-hez
(bérmerevség) van közvetlen kapcsolódás.

---

## Vezetői összefoglaló

A fejezet végigveszi, hogyan lesz az RBC-ből új-keynesi modell, és miért
kell a bővítések mindegyike. A közös szál: **az alapmodell reakciói túl
gyorsak és túl gyengék az adathoz képest**, és minden bővítés ezt tompítja
vagy perzisztensebbé teszi. A szerző nem új eredményt közöl, hanem a
mechanizmusokat vezeti le és értelmezi.

---

## 2.1. Az új keynesi alapstruktúra (10–29. o. / PDF 15–34)

Két módosítás az RBC-hez képest:

1. **Monopolisztikus verseny** a tökéletes helyett — inhomogén termékek,
   a fogyasztó ízlésvilágában nem tökéletes helyettesítők, tehát a termelő
   érdekelt a kibocsátás visszafogásában és az áremelésben.
2. **Nominális rigiditás** — mert az 1. önmagában nem elég: rugalmas árak
   mellett a gazdaság a monetáris sokkra azonnal reagál. A Calvo-féle
   aszinkron árazás azt jelenti, hogy adott periódusban a vállalatoknak csak
   egy része árazhat újra, és ez a kör sem tudja, mikor jut újra
   lehetőséghez.

Az RBC-től megtartott előny: **a fogyasztó hasznossági függvénye a
jólétmérés alapja**, tehát alternatív beavatkozások összehasonlíthatók. Ez
készíti elő a 4. fejezet egész érvelését.

Alszakaszok: állandósult állapot és loglinearizálás (15.), IRF technológiai
sokkra (18.), IRF monetáris sokkra (21.), inflációdinamika (23.), optimális
monetáris politika (25.).

> **Nekünk:** tankönyvi anyag, a JV/EAGLE-vonalunk mindezt tartalmazza.
> Átvenni nincs mit.

---

## 2.2. Inflációs perzisztencia (30–34. o. / PDF 35–39)

A Calvo-elv **ad hoc kiegészítése indexálással**: az a vállalat, amely az
adott periódusban nem optimalizálhat, hozzáfér egy indexálási
technológiához, és például az előző időszak inflációját figyelembe véve —
nem optimális módon, de — módosítja az árát.

> **Nekünk:** ez a mi `vth_p` / `vth_x` / `vth_w` indexálási paramétereink
> mechanizmusa. A JV ezeket magyar adaton becsülte (0,431 / 0,494 / 0,185),
> tehát nálunk **erősebb a horgony**, mint itt.

---

## 2.3. A tőkefelhalmozás szerepe (35–50. o. / PDF 40–55)

Az alapmodell bővítése tőkével, mert a beruházás ingadozása fontos szerepet
tölt be a GDP ingadozásának magyarázatában. Három kiegészítés, mindegyik
**reakció-tompító**:

**2.3.1. Változó tényezőkihasználás (38. o.).** Ha a tőke kihasználtsága
változtatható, a kibocsátás növekedése nem okoz akkora bérletidíj-emelkedést
→ kisebb határköltség-változás → konstans haszonkulcs mellett kisebb
áremelés.

**2.3.2. Alkalmazkodási költség (39. o.).** További tompítás a beruházás
oldaláról.

**2.3.3–2.3.5. Kalibrálás, loglinearizált rendszer, IRF-elemzés (40–47. o.).**

**2.3.6. Vállalatspecifikus tőketényezők (48–50. o.).** Az időszak elején
rendelkezésre álló egyik input szintjét rögzítve **módosul a határköltség
alakja**, ami visszafogja az árváltoztatásra ösztönző tényezőket.

> **Nekünk:** a 2.3.6 közvetve érdekes. A `v06`-lépcsőnk pont azt oldotta
> meg, hogy a szegmens-tőke ne reallokációs maradék legyen, hanem a saját
> szegmens termelését hajtsa (`rk_j`). A vállalatspecifikus tőke logikája
> ugyanez, csak vállalati szinten. A `psi_j` (beruházási kiigazítási
> költség) paramétereink a 2.3.2-höz kötődnek — nála φ = 15, ami nagyon
> magas, de más normalizálásban.

---

## 2.4. Ragadós bérek (51–54. o. / PDF 56–59) — 🟢

A fejezet legrelevánsabb része. Az érvelés két hivatkozásra épül:

- **Erceg–Henderson–Levin (2000):** ahhoz, hogy a rendszer reális dinamikát
  mutasson, az árragadósság mellett a **nominális bérek ragadóssága is
  szükséges**, és ez nem triviálisan változtatja meg az optimális monetáris
  politikáról való gondolkodást.
- **Christiano–Eichenbaum–Evans (2001):** a bér- és áraggregátumok
  perzisztenciájának, volatilitásának és együttmozgásának jellemzésénél a
  **kulcstényező inkább a ragadós bérképzés, mint a ragadós árképzés.**
  Modelljük akkor is jól viselkedett volna, ha a **ragadós árazást teljesen
  elhagyják** — de ha a ragadós bérezést hagyják el, az eredmények már nem
  tükrözik hűen a valós folyamatokat.

Szerkezet: a munkapiacon is monopolisztikus verseny, a fogyasztók
különböző munkatípust kínálnak, a vállalatok munkaerő-aggregátumot
foglalkoztatnak, Calvo-bérezéssel.

Kalibráció: **ω_W = 0,75** (Laxton–Pesenti 2003 alapján, „összhangban a
szakirodalomban szokásosnak tartott szinttel"), bér-helyettesítési
rugalmasság **a′ = 10**.

> ⭐ **Nekünk ez két dolgot mond.**
>
> **(1) Az `A21`-hez.** Kimutattuk, hogy a magyar cégpanelen a nominális
> bérmerevség **gyenge** 2023–24-ben (10,1% csökkentett, 2,8% fagyasztott),
> és **méretfüggő** (13,9% / 7,6% / 5,8%). Ha CEE (2001) szerint a
> bérragadósság a fontosabb tényező, akkor a mi méretfüggő
> bérmerevség-eredményünk **nem apró részlet**: a KKV/nagyvállalat
> szétválasztásnak elvben a bérblokkban is meg kellene jelennie. A modellünk
> jelenleg **közös** `xi_w`-t használ minden típusra.
>
> **(2) Óvatosság.** A mi mérésünk egyetlen év-pár, magas inflációs
> környezetben — tehát alsó korlát. Ebből még nem következik, hogy
> típusonkénti `xi_w`-t kellene bevezetni; annak a BK-kockázata is
> jelentős lenne (lásd a v04-es lecke). **Ez felvethető tétel, nem
> teendő.**

---

## 2.5. Fogyasztói szokások (55–57. o. / PDF 60–62)

A szokások szintén a reakciók tompítását szolgálják. A szerző kiemel egy
**termékalapú** szokásváltozatot: ha a vállalat alacsonyabb árral növeli a
kereslet mennyiségét, később akkor is nagy eladást könyvelhet el, ha
relatív ára nő — mert a fogyasztó kötődik a termékhez.

Eredmény: **kontraciklikusan mozgó, időben változó haszonkulcs.** Keresleti
sokk okozta kibocsátás-emelkedésnél a haszonkulcs csökken, mert az árazó
vállalatok kisebb mértékben emelnek, hogy hosszabb távra magukhoz kössék a
fogyasztókat; a sokk lecsengésével a haszonkulcs nő.

> **Nekünk:** a JV becsült `habit` = 0,646, itt b = 0,4. A termékalapú
> szokásváltozat nálunk nincs, és **nem is javaslom bevezetni** — de a
> „endogén, kontraciklikus haszonkulcs" gondolat érdekes a `4.6`-os
> markup-sokk mellé: nálunk az `eps_ces` konstans, tehát a markup is az.

---

## 2.6–2.7. Összefoglalás és függelékek (58–69. o. / PDF 63–74)

Összefoglalás az RBC → új-keynesi átmenetről. A függelékek: a hasznossági
függvény másodfokú közelítése (64.), loglinearizált rendszer bérragadósság
mellett (67.), loglinearizált rendszer fogyasztói szokások mellett (68.).

> **Nekünk:** a 2.7.1 (másodfokú jóléti közelítés) módszertanilag érdekes
> lehet, ha valaha jóléti mérőszámot akarunk a tanulmányba — jelenleg
> nincs ilyenünk, csak GDP-hatást közlünk. **Nyitva hagyandó kérdés, hogy
> kell-e.**
