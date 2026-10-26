# Döntési lista a csapatmeetingre — fiskális blokk és kalibráció

*2026-10-26. A fiskális blokk 1. lépéséből (A32, A33, F12), az adatkeresésből (brief 7a) és a 2. blokk
levezetésének első lépéséből kijött kérdések. Ezeket a modell nem tudja eldönteni: mindegyik vagy
közlési, vagy kalibrációs csapatdöntés. Mindegyiknél ott a javaslat, de az csak javaslat.*

---

## 1. Az adósságszabály: hova menjen az euró kamatmegtakarítása az alapesetben?

**Mi a helyzet:** a mostani szabály (`tls = phi_b·bg(−1)`) mellett az adó csak az adósságra reagál. Ezért a
megtakarítás egy része adósságcsökkentésre megy: az euró után az adósság tartósan **10,7 GDP-százalékponttal**
csökken, az egyösszegű adó tartósan a GDP 2,15%-ával (A32).

**Miért számít, és miért nem:** amíg csak egyösszegű adó van, a választás a reálgazdaságot gyakorlatilag nem
érinti (ricardói). **A 2. blokktól (nyugdíj, transzfer) viszont nagyon is számít**, mert akkor a szabály dönti
el, hogy a megtakarítás adósságcsökkentés vagy több nyugdíj.

| Opció | Mit jelent |
|---|---|
| (a) marad | az alapeset egy fokozatos adósságcsökkentést is tartalmaz |
| (b) az adósságráta tartósan ne változzon | a teljes megtakarítás visszamegy (adón vagy transzferen át); kis szabálymódosítás |
| (c) mindkettő | (b) az alapeset, az adósságcsökkentés külön kísérlet (E3) |

**Javaslat:** (c). Így az alapeset tisztán az euróhatás, és nem keveredik bele egy konszolidációs döntés.

## 2. A forint- és devizaadósság szétbontása

**Mi a helyzet:** a modell az egész adósságra a teljes −200 bp-s felárcsökkenést alkalmazza. A teljes adósság
kb. 28%-a viszont devizában van, és ott az euró csak a hitelkockázati részt tünteti el. A külföldi kézben lévő
forintadósság a teljes adósság csak kb. 9%-a (brief 7a).

**Miért számít:** hátraboríték-szám szerint az állam közvetlen megtakarítása 1,5% helyett inkább
**1,2–1,3% GDP**, a nemzetgazdasági nyereség 0,67% helyett inkább **0,2–0,3% GDP/év**.

| Opció | Mit jelent |
|---|---|
| (a) egy hozam marad, `theta_f` „effektív” értékkel (kb. 0,1–0,15) | olcsó, de a közvetlen megtakarítást továbbra is túlbecsüli |
| (b) az adósság forint- és devizarészre bontva, külön hozammal | kis modellbővítés, a v11-ben kapcsoló mögött |

**Javaslat:** (b). Hozzá kell: (i) a devizaadósság tulajdonosi megoszlása (ÁKK/MNB), (ii) egy feltevés arról,
mennyit szűkül euróban a deviza-hitelfelár (scanben, pl. 0,5–1 százalékpont).

## 3. Az `rgbar`: milyen kamattal számoljuk az adósság dinamikáját?

**Mi a helyzet:** a modellben nincs infláció és növekedés, ezért itt a **reálkamat mínusz növekedés** a releváns,
nem a névleges implicit kamat (az kb. 5–6,5%). A mostani `rgbar = 1,015` = `1/β` + kb. 2%/év felár, ami
modellen belül konzisztens: pont ezt a felárat tünteti el az euró. A magyar adatokban az r − g az utóbbi
években nulla körüli vagy negatív.

| `rgbar` | Tartós adósságváltozás (éves GDP %) |
|---|---|
| 1,015 (mostani) | −10,7 |
| 1/β = 1,0101 | −9,4 |
| 1,000 (r − g ≈ 0) | −7,4 |

**Javaslat:** maradjon az 1,015, és a másik kettőt robusztusságként közöljük. Csak az adósság- és adópályát
érinti, a reálváltozókat nem.

## 4. Közlés: mivel mérjük az euró fiskális nyereségét?

**Mi a helyzet:** a külföldi tulajdonú részből jövő nyereség főleg fogyasztásban jelenik meg (+2,2 pp a
16–20. évben). A GDP-hatás kicsi, és előjele a nyitottságon múlik: a régi beállításon −1,0 pp a
reálfelértékelődés (transzferprobléma) miatt (F12).

**Javaslat:** ezt a csatornát fogyasztásban (vagy jólétben) közöljük, ne GDP-ben.

## 5. A háztartási súlyok a nyugdíjasblokkhoz (2. blokk)

**Mi a helyzet:** a JV-modell három háztartástípust aggregál **fogyasztási kiadási súlyokkal**: optimalizálók
0,75, a maradék 0,25 a munkapiacon aktív likviditáskorlátos háztartások és a nyugdíjasok között oszlik meg.
A mi modellünkből a nyugdíjasok kimaradtak: a teljes 0,25 a bérből és foglalkoztatásból élő típusra került. A
költségvetéssel konzisztens nyugdíjas-súly a nyugdíjkiadás / háztartási fogyasztás ≈ **0,15–0,16** (a
nyugdíjkiadás kb. 7–8% GDP).

| Opció | ω_o / ω_r / ω_p |
|---|---|
| (a) JV-szerkezet, költségvetéssel konzisztens nyugdíjas-súly | 0,75 / 0,09–0,10 / 0,15–0,16 |
| (b) JV-szerkezet, a JV saját nyugdíjas-aránya (0,35 a nem optimalizálókon belül) | 0,75 / 0,16 / 0,09 |
| (c) arányos: a nyugdíjasok mindkét típusból „jönnek” | 0,63–0,64 / 0,21 / 0,15–0,16 |

**Javaslat:** (a), `kappa_w = 0`-val (árindexálás). MPT 2026-10-26-án jóváhagyta; a csapat elé kerül.
Mivel a súlyok átrendeződnek, a blokk nyugdíjemelés nélkül is megváltoztatja a mostani eredményeket, ezért
kapcsoló mögé kerül, és az alapértelmezésről a csapat dönt.

## 6. Ami nem a meetingen dől el, de jó tudni

- **α_j:** Tomi méri (`docs/terv/2026-10-26_aa_j_meresi_specifikacio.md`). Hogy az új érték legyen-e az
  alapértelmezés (`KALIB`), az a mérés és a modellfutás után csapatdöntés.
- **`theta_f` alapértéke:** 0 marad, amíg a 2. kérdés el nem dől.
