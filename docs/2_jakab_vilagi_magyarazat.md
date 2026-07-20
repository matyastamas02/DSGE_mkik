# 2. A Jakab–Világi modell — a script értelmezése és fő egyenletei

*Jakab M. Zoltán – Világi Balázs: "An estimated DSGE model of the
Hungarian economy" (MNB WP 2008/9). A `src/model/jv_dsge_v01.mod`
alapján (a cikk Appendix A.4–A.9 log-linearizált rendszere, az
inflációs-célkövetéses rezsim becsült paramétereivel). Mit csinál minden
fő egyenlet, miért, és mi lesz belőle.*

---

## 0. Mi ez a modell egy mondatban

Egy **magyar adaton, Bayes-i módszerrel BECSÜLT** kis nyitott gazdaság
új-keynesi DSGE-modellje — az egyik első becsült magyar DSGE, az MNB-ben
készült. Két termelő szektor (hazai és export), optimalizáló + kézről
szájra élő háztartások, ragadós ár ÉS ragadós bér (indexálással), és egy
külön érdekessége: **explicit kezeli a monetáris rezsimváltást** (csúszó-
leértékelésről inflációs célkövetésre) és a jegybanki inflációra vonatkozó
adaptív tanulást.

Az EAGLE-hez képest **karcsúbb és becsült**: nem egy nagy többországos
modell redukciója, hanem eleve egyblokkos, magyar idősorokra illesztve.

---

## 1. A háztartások

### 1.1 Optimalizáló háztartás — az Euler-egyenlet (JV eq. 73)

```
c̃_o = h/(1+h)·c̃_o(-1) + 1/(1+h)·E[c̃_o(+1)]
       − (1−h)/((1+h)σ)·E[ î − π(+1) + dq̄(+1) ] + ε_c
```
*Mit mond:* a mai fogyasztás a tegnapi (szokás, `h`) és a várt holnapi
fogyasztás súlyozott átlaga, korrigálva a reálkamattal. Az `î` a
csúszó-leértékeléssel korrigált kamat, a `dq̄` a bejelentett trend-
reálleértékelődés. *Miért van ott a `dq̄`:* mert a modell a csúszó-peg
rezsimet is le tudja írni — inflációs célkövetésben ez a tag nulla.
*Mi lesz belőle:* fogyasztás-simítás + kamatérzékenység, **magyar adaton
becsült** habit-tal (h=0,65) és IES-sel (1/σ, σ=1,81).

### 1.2 Kézről szájra élő háztartás — 25%

A JV Table 1 szerint a háztartások **25%-a** nem-optimalizáló (survey-
alapon: ennyi magyar háztartásnak nincs banki kapcsolata). Ő a folyó
bérjövedelmét költi: `c_no = w + n`. *Miért fontos nekünk:* ez a
likviditáskorlátos szereplő — a KKV-alkalmazottak proxy-ja. (Figyeld:
itt 25% a becsült arány, míg az EAGLE-HU 75%-ot tesz fel — a JV-é
adatból/felmérésből jön.)

---

## 2. A termelés — hazai és export szektor, munka+import kompozit

A JV egyik jellegzetessége: a termelés inputja nem egyszerűen tőke+munka,
hanem **tőke + egy "munka+import" kompozit (z)**:
```
wz_s = a_s·w + (1−a_s)·(q + P_m*)      (a z-kompozit ára, s = d, x)
mc_s = ζ_s·rk + (1−ζ_s)·wz_s − a
```
*Mit mond:* a szektor határköltsége a tőke bérleti díja és a munka+import
kompozit árának súlyozott átlaga (mínusz termelékenység). *Miért van ott
az import az inputban:* mert a magyar termelés (főleg az export) erősen
import-igényes — a `(1−a_x)` súly az export inputban magas. *Mi lesz
belőle:* az árfolyam a **költségoldalon** hat a termelésre — egy
leértékelődés drágítja az importált inputot.

---

## 3. Az árazás — hibrid, indexált Phillips-görbék (JV eq. 86–88)

**Belföldi ár-Phillips-görbe (hibrid, indexálással):**
```
π = β/(1+βϑ)·E[π(+1)] + ϑ/(1+βϑ)·π(-1) + λ_p/(1+βϑ)·mc_d + ε_p
```
*Mit mond:* a mai infláció előretekintő (`E[π(+1)]`) ÉS hátratekintő
(`π(-1)`, az indexálás `ϑ` miatt) is. *Miért van ott az indexálás:* mert
a magyar adat ezt támasztja alá — a cégek részben a múltbeli inflációhoz
igazítanak. *Mi lesz belőle:* **perzisztensebb, realistább infláció-
dinamika**, mint tiszta előretekintő görbével.

**Export-ár Phillips-görbe (eq. 87):** ugyanilyen szerkezet, de a
határköltségben ott az árfolyam és az importált input ára — így az
exportárak külön dinamikát követnek.

**Bér-Phillips-görbe (eq. 88) — ez a JV natív erőssége:**
```
π_w = β/(1+βϑ_w)·E[π_w(+1)] + ϑ_w/(1+βϑ_w)·π_w(-1)
      + λ_w/(1+βϑ_w)·[ σ/(1−h)·(c − h·c(-1)) + φ·l − w ] + ε_w
```
*Mit mond:* a bérinfláció ugyanolyan ragadós, mint az árak — a bérek
Calvo-módra, indexálással igazodnak. A hajtóerő a munkakínálat határ-
áldozata (`σ/(1−h)·(c−hc(-1)) + φ·l`) és a reálbér különbsége. *Miért
fontos:* **a bér-ragadósság becsült** (Calvo bér ≈ 0,70, indexálás ≈ 0,17)
— ez az EAGLE-vonalban külön hozzáépítendő volt (v0.5), a JV-ben natív.
*Mi lesz belőle:* a reálbér nem ugrál, a munkapiaci alkalmazkodás lassú —
az euró utáni (árfolyam nélküli) alkalmazkodás szempontjából (OCA) ez a
kulcsmechanizmus.

---

## 4. Kereslet, külkereskedelem

**Exportkereslet (becsült, simítással):**
```
xx = h_x·xx(-1) + (1−h_x)·(−μ_x·(px − rer)) + ε_x
```
*Mit mond:* az exportkereslet a relatív exportár (`px−rer`) függvénye,
**becsült árrugalmassággal** (μ_x≈0,53) és simítással (h_x≈0,51). *Miért
jobb, mint az EAGLE colleague-változat:* ott az export tisztán exogén volt
— itt van valódi ár-/árfolyam-rugalmasság, ami az euró-elemzéshez (reál-
árfolyam-pálya) elengedhetetlen. *Mi lesz belőle:* a konvergenciás
felértékelődés export-fékező hatása endogén módon megjelenik.

**GDP és NFA:** GDP kiadási oldalról; a nettó külföldi pozíció a
kereskedelmi mérleg akkumulációjából.

---

## 5. Kamat, árfolyam, rezsim (JV A.9)

**UIP adósság-rugalmas prémiummal:**
```
r = E[dep(+1)] − ν·bstar + ε_pr
```
*Mit mond:* a hazai kamat = várt leértékelődés − országprémium
(+ pénzügyi prémium sokk). A ν=0,001 becsült érték nagyon kicsi — az NFA
lassan stabilizálódik.

**Taylor-szabály (IT-rezsim):**
```
r = γ_i·r(-1) + (1−γ_i)·φ_π·π + ε_r
```
becsült simítással (γ_i≈0,76) és inflációs válasszal (φ_π≈1,38).

**A rezsim-kettősség (a JV egyedi vonása):** a modell tartalmazza a
csúszó-leértékelés (crawling-peg) és az inflációs célkövetés rezsimet is,
strukturális töréssel. *Miért fontos nekünk:* **az euró-bevezetés maga is
rezsimváltás** — a JV eleve tud rezsimet váltani, ami fejlődési előny
pont a mi kulcsmechanizmusunkon.

---

## 6. Adaptív tanulás — az "észlelt alapinfláció" (JV eq. 72)

```
π̄ = (ρ_π−g)/(1−g)·π̄(-1) + g/(1−g)·π̂
```
*Mit mond:* a szereplők nem ismerik pontosan a jegybank inflációs célját,
hanem tanulják (`g` a tanulási ráta). *Miért van ott:* a vizsgált
időszakban Magyarországon dezinfláció zajlott, és a várakozások képződése
nem hagyható figyelmen kívül. *(A mi v01-ünkben ezt egyszerűsítjük:
konstans alapinfláció — a JV 7. fejezete maga is bemutat egy tanulás
nélküli változatot.)*

---

## 7. Hogyan becsülték — és miért számít

**Bayes-i becslés** magyar idősorokra (Kalman-szűrő + Metropolis–Hastings).
A paraméterek egy része rögzített (Table 1: tőke-részarányok, helyettesítési
rugalmasságok), a nagy része **becsült poszterior** (Table 2–3: σ, habit,
Calvo ár/bér, indexálás, export-rugalmasság, Taylor-paraméterek, sokk-
szórások és -perzisztenciák). *Mi lesz belőle:* a modell paraméterei
**nem feltevések, hanem a magyar adatból következnek** — ez a JV
legnagyobb előnye a kalibrált EAGLE-hez képest.

---

## 8. Mi lesz az egész modellből — a kimenetek

1. **Steady state** + a becsült paraméterkészlet.
2. **Impulzusválaszok** 11 sokkra (termelékenység, export, preferencia,
   ár/bér-markup, monetáris, beruházás, equity-prémium, pénzügyi prémium,
   fiskális).
3. **A projekt rétegei ráépülnek:** a `jv_dsge_v02` a kétszektoros BGG-t,
   a `jv_dsge_v03` az euró-szcenáriót (prémium-pályák + rezsimváltás) teszi
   hozzá — a JV-alapon a tartós GDP-hatás +0,78…+1,41%.
4. **Variancia-dekompozíció:** a JV szerint a GDP-t az export-kereslet és
   a markup-sokkok dominálják (kis nyitott gazdaságra reális).

## 9. Erősségei és korlátai a projektünkhöz

**Erős:** magyar adaton becsült; karcsú, egyblokkos; natív ragadós bér;
natív rezsimváltás-kezelés; valódi export-árrugalmasság; a kézről-szájra
arány is becsült.

**Korlát:** (a) nincs benne natív pénzügyi akcelerátor (BGG) — ezt mi
ragasztjuk rá (v02); (b) egyszerűbb fiskális blokk, mint az EAGLE-é
(nincs hat adónem) — ha SZOCHO-szcenárió kell, az EAGLE-blokkból emelünk
át; (c) néhány steady-state-arány a cikkből nem olvasható ki
egyértelműen (a v01-ben "KOZELITES" jelöléssel — ellenőrizendő a szerzői
kóddal).

**Ezért:** a JV a projekt **fő modellvonala** — az érveket a 3. dokumentum
foglalja össze.
