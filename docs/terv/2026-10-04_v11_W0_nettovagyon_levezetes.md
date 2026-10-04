# v11 / W0 — a nettóvagyon-egyenlet levezetése és a K-1 auditja

*2026-10-04 · Tomi. A [v11-terv](2026-10-04_v11_implementacios_terv.md) 3. szakaszának
végrehajtása. Kérdés: a „hosszú távon fékező gyorsító” (K-1, A25) a teljes BGG-modell
tulajdonsága, vagy a modellben használt redukált nettóvagyon-egyenlet műterméke?*

> **⚠ FRISSÍTVE a W0b újrafuttatása után (10. szakasz):** az A25 a teljes egyenlettel is
> fennáll; a műtermék-gyanú csak a hazai KKV tartós nettó vagyonára igazolódott. Új,
> kontraintuitív eredmény: a közölt GDP-sáv az `omega_nw`-tól függ (F08).
>
> **Eredmény röviden (W0, behelyettesítés alapján).** A redukált egyenletből **egy nem elhanyagolható tag hiányzik**:
> a vállalkozói jövedelem / belépő transzfer. A BGG-ben ez azért hagyható el, mert
> kicsi; ebben a modellben az `omega_nw = 0,95` miatt az állandósult azonosság
> negyedévente a nettó vagyon kb. **4%-ának** megfelelő transzfert követel, a BGG-kalibráció
> kb. 1%-a helyett. Ha a tagot visszatesszük, a tartós nettó vagyon az alapágban az export-KKV-nál
> kb. **felére** csökken, a hazai KKV-nál **előjelet vált** (−0,75% → +0,57%).
> A terv előre rögzített döntési szabálya (3.2/4. pont) szerint ez **W0b-t indít**:
> a nettóvagyon-egyenletet a levezetett alakra kell cserélni (`-DNWSPEC=1`), és az A25-öt
> azon újra kell mérni. **Ez a dokumentum nem futtat újra modellt**: a lenti számok a
> jelenlegi modell tartós értékeinek behelyettesítései, nem egy újraoldott modell
> eredményei (lásd 6. szakasz).

---

## 1. Honnan jön a jelenlegi egyenlet

```
nw_j = omega_nw*(nw_j(-1) + lev_j*(ret_j - (r(-1) - infl)));
```

- Nem a Jakab–Világi-forrásból (MNB WP 2008/9) származik: a JV-magban nincs BGG-blokk.
  A projekt saját „BGG-lite” blokkja, először az EAGLE-vonal `kkv_dsge_v01.mod`-jában
  (160. sor, „nettó vagyon perzisztencia (túlélési ráta)” kommenttel), onnan került át.
- A kalibrációs dokumentum ([`kalibracio_bgg_blokk.md`](../eredmenyek/kalibracio_bgg_blokk.md))
  a `lev`-et Christensen–Dib (2008) 1. táblázatához köti (`k/n = 2`), és 2026-08-16-án
  már jelezte: a C–D/BGG túlélési ráta 0,9728, a modellé 0,95, „ez külön megnézendő”.
  Ez a W0 ezt a nyitott pontot is lezárja.

## 2. A nemlineáris azonosság

A BGG (1999) nettóvagyon-dinamikája a használt jelölésekkel:

$$V_t = R^k_t\,Q_{t-1}K_t - R^b_t\,\big(Q_{t-1}K_t - N_{t-1}\big), \qquad
N_t = \gamma\,V_t + W^e_t$$

ahol $V_t$ a túlélő vállalkozók saját tőkéje a hozamok realizálása után, $R^k$ a tőke
bruttó hozama, $R^b$ a hitel bruttó költsége, $\gamma$ a túlélési ráta, $W^e$ pedig a
vállalkozói munkajövedelem vagy a belépők induló transzfere. A modell konvenciója
szerint a hitel költsége a biztonságos reálkamat (`r(-1) - infl`), ezért $R^b = R$.

**Állandósult állapot** ($L = QK/N$ tőkeáttétel, $\pi = R^k - R^b$ prémium):

$$\frac{W^e}{N} = 1 - \gamma\big[R^k L - R^b(L-1)\big] = 1 - \gamma R^b - \gamma\,\pi\,L$$

## 3. Log-linearizálás

$Q K - N$ log-eltérése $\big(L(q+k) - n\big)/(L-1)$, ezért

$$n_t = \gamma\Big[R^k L\,r^k_t - R^b(L-1)\,r^b_t + (R^k - R^b)\,L\,(q_{t-1} + k_t) + R^b\,n_{t-1}\Big] + \frac{W^e}{N}\,w^e_t$$

$\omega \equiv \gamma R^b$ jelöléssel és átrendezve:

$$n_t = \underbrace{\omega\big[n_{t-1} + L\,(r^k_t - r^b_t)\big]}_{\text{a modell mostani alakja}}
\;+\; \underbrace{\omega\,r^b_t}_{\text{(A)}}
\;+\; \underbrace{\gamma\,\pi\,L\,(r^k_t + q_{t-1} + k_t)}_{\text{(B)}}
\;+\; \underbrace{\frac{W^e}{N}\,w^e_t}_{\text{(C)}}$$

A modell tehát három tagot hagy el:

| Tag | Tartalom | Tartós fixpontban |
|---|---|---|
| (A) | a saját tőke biztonságos hozama | **0**: a háztartási Euler-egyenlet tartósan nulla reálkamat-eltérést ad (változatlan β mellett) |
| (B) | a prémium az egész eszközállományon keresztül: nagyobb tőkeállomány nagyobb prémiumjövedelmet hoz | kicsi–közepes, a prémiumszinttől ($\pi$) függ |
| (C) | vállalkozói jövedelem / belépő transzfer | **nagy**, lásd 4. szakasz |

## 4. Miért nem hagyható el a (C) tag ebben a modellben

A (C) súlya, $W^e/N$, nem szabad paraméter: a 2. szakasz azonossága rögzíti.

| | $\gamma$ | $W^e/N$ ($\pi$ = 0,5% negyedévente, $L$ = 1,6) |
|---|---|---|
| BGG / Christensen–Dib | 0,9728 | kb. 0,0096 |
| **ez a modell** (`omega_nw = 0,95`) | 0,9405 | **kb. 0,0425** |

A tartós fixpontban, **rögzített felár mellett**, a tag $1/(1-\omega) = 20$-szoros szorzót kap (felső korlát: ha a felár χ-n át visszahat a nettó vagyonra, a szorzó kb. 7), tehát a (C)
hozzájárulása kb. $0{,}85 \cdot w^e$. Ha a vállalkozói jövedelem a típus kibocsátásával
arányos ($w^e_j = y_j$, a BGG-féle vállalkozói munkajövedelem), akkor egy 1%-os tartós
kibocsátás-növekedés kb. 0,85%-kal emeli a tartós nettó vagyont. Ez ugyanakkora
nagyságrend, mint a felárcsökkenés közvetlen hatása (kb. −1%).

**A lényeg:** a 0,95-ös túlélési ráta csak akkor konzisztens egy állandósult
állapottal, ha a vállalkozók negyedévente a nettó vagyon kb. 4%-át kapják kívülről.
Ezt a beáramlást a redukált egyenlet elhagyja, és ezzel a tartós viselkedést is
megváltoztatja.

## 5. Számszerű összevetés

Tartós fixpont (`n = n(-1)`, $r^b = 0$, $r^k = efp$):

$$n^{\text{red}} = \frac{\omega L\,efp}{1-\omega}, \qquad
n^{\text{teljes}} = n^{\text{red}} + \frac{\gamma\pi L\,(efp + q + k) + (W^e/N)\,w^e}{1-\omega}$$

A jobb oldalra a jelenlegi modell tartós értékeit tesszük (2026-10-04-i diagnosztika
és `t58`; OPTEN=0, SC=1, TSCEN=3), $w^e_j = y_j$, $\pi$ = 0,5% negyedévente.
**Ellenőrzés:** a redukált képlet mind a 12 esetben 0,02 pp-n belül visszaadja a
modell mért tartós nettó vagyonát.

| Konfiguráció | Típus | nw (modell) | $n^{\text{red}}$ | $n^{\text{teljes}}$ | arány | (B) | (C) |
|---|---|---|---|---|---|---|---|
| aszimm. χ, ACC=100 | E | −1,08 | −1,06 | −0,57 | 0,53 | +0,09 | +0,41 |
| | D | −0,75 | −0,76 | **+0,57** | **−0,74** | +0,17 | +1,16 |
| | L | −2,37 | −2,39 | −2,49 | 1,04 | +0,19 | −0,29 |
| aszimm. χ, ACC=0 | E | −1,09 | −1,09 | −1,19 | 1,09 | +0,09 | −0,19 |
| | D | −0,95 | −0,94 | −0,64 | 0,67 | +0,12 | +0,19 |
| | L | −2,21 | −2,21 | −1,68 | 0,76 | +0,26 | +0,28 |
| χ=0,04, ACC=100 | E | −1,37 | −1,37 | −0,50 | **0,36** | +0,14 | +0,73 |
| | D | −1,01 | −1,00 | **+0,87** | **−0,86** | +0,24 | +1,63 |
| | L | −1,76 | −1,76 | −2,36 | 1,34 | +0,07 | −0,67 |
| χ=0,04, ACC=0 | E | −1,37 | −1,37 | −1,24 | 0,90 | +0,14 | −0,01 |
| | D | −1,26 | −1,25 | −0,77 | 0,61 | +0,17 | +0,31 |
| | L | −1,47 | −1,48 | −1,26 | 0,85 | +0,16 | +0,07 |

**Érzékenység a prémiumszintre** ($\pi$ = 0,25% / 0,5% / 0,75% negyedévente): a hazai
KKV előjelváltása az ACC=100 esetekben mindhárom értéknél megmarad (+0,58 / +0,57 /
+0,55, illetve +0,89 / +0,87 / +0,84). A $\pi$ a (B)-t mozgatja, a (C)-t alig.

**Érzékenység a (C) specifikációjára:** ha a vállalkozói jövedelem szintben állandó
($w^e = 0$), csak a (B) marad, és az arány minden esetben 0,76–0,96 között van, tehát
a ±50%-os sávon belül. **A döntés tehát a (C) tag specifikációján múlik.** A BGG-ben a
vállalkozói jövedelem munkajövedelem, a kibocsátással arányos; a Gertler–Karadi-típusú
belépő transzfer az eszközállománnyal arányos. Mindkét irodalmi forma a gazdaság
méretével együtt mozog; a szintben állandó transzfer a legkevésbé szokásos. Ezért a
$w^e_j = y_j$ a megalapozottabb választás, de ezt a 2. review-körnek ellenőriznie kell.

## 6. Korlátok — amit ez a levezetés NEM mond

1. **Nem újraoldott modell.** A számok a *jelenlegi* tartós értékek behelyettesítései.
   A valódi hatás más lesz, mert a nettó vagyon a χ-tagon keresztül visszahat a
   felárra, a felár a beruházásra és a kibocsátásra. Hogy az A25 (szimmetrikus χ
   mellett nincs küszöb) fennmarad-e, csak a W0b-ben, újrafuttatással derül ki.
2. **A $\pi$ szintje** a log-lineáris modellből nem olvasható ki; a 0,25–0,75%-os
   negyedéves sáv a BGG-féle kb. 2% évesített prémium körül van.
3. **A (C) specifikációja** (5. szakasz) a döntés kulcsa, és feltevés.
4. **Forrás-ellenőrzés:** a BGG (1999) és a Christensen–Dib (2008) pontos
   log-lineáris nettóvagyon-egyenletét nem vetettük össze tételesen a 3. szakasz
   levezetésével. A levezetés az alap-azonosságból indul, nem a cikkek végső alakjából.
5. **A permanens fixpont** továbbra is a log-lineáris rendszer fixpontja (v11-terv 1.3).

## 7. Döntés az előre rögzített szabály szerint

> *W0-állapot (behelyettesítés). A W0b újrafuttatása részben felülírta: lásd 10.3.*

A v11-terv 3.2/4. pontja: *„ha ellentétes irányt ad, vagy a nagyságrend [a ±50%-os
sávon túl] eltér: a nw-egyenletet a levezetett alakra cseréljük (`-DNWSPEC=1`), és ez
W0b munkacsomag lesz.”*

- A hazai KKV-nál az ACC=100 esetekben az irány **ellentétes**, mindhárom $\pi$ mellett.
- Az export-KKV-nál szimmetrikus χ és ACC=100 mellett az arány 0,36, a sávon kívül.

**→ W0b indul.** A K-1 a jelenlegi formájában **nem** tekinthető a modell
közgazdasági tulajdonságának. Valószínűbb, hogy annak a következménye, hogy a
redukált egyenlet egy, ebben a kalibrációban nagy tagot elhagy.

## 8. W0b — előre rögzítve, a futtatás előtt

1. **Kapcsoló:** `-DNWSPEC=1` a v11-ben. A nettóvagyon-egyenlet a 3. szakasz teljes
   alakja: az (A), (B) és (C) taggal, $w^e_j = y_j$ mellett.
2. **Paraméterek:** $\pi$ = 0,005 (alap), érzékenységként 0,0025 és 0,0075;
   $W^e/N$ és $\gamma$ az azonosságból, **nem szabad paraméterként**.
3. **Alternatív (C):** $w^e = 0$ (csak (A)+(B)), összevetésként, alacsonyabb rangon.
4. **Mérés:** a `t58` (szimmetrikus-χ küszöb) és a `t48b` újramérése `NWSPEC=1`
   mellett, mindkét χ-változattal; az A25 sorsa ettől függ, és **akármi lesz az
   eredmény, közöljük**.
5. **Technikai elfogadás:** a v11-terv 7.1 szerint (BK mindkét rezsimben, nulla-sokk,
   regresszió `NWSPEC=0` mellett a v10-re).
6. A 2. review-kör ezt a dokumentumot is megkapja, implementáció előtt.

## 9. Ami ebből most következik a már közölt anyagokra

> *W0-állapot. A W0b után: lásd 10.6.*

- **A25:** az állítás a *jelenlegi* modellben áll (az őre rendben van), de a mögötte
  lévő mechanizmus valószínűleg a redukált egyenlet műterméke. A regiszter
  megjegyzésébe ez bekerül; az állítás státuszáról a W0b után dönt a csapat.
- **A workshop-anyag:** az A25-öt jelenleg „új mérésként” mutatja. Ezt a W0 nyomán
  óvatosabban kellene keretezni, vagy elhagyni; ez a csapat döntése.

---

## 10. W0b — az újrafuttatás eredménye (2026-10-04)

Futtatók: `sens_nwspec_v11.m` (→ `t61`–`t61e`), `sens_omeganw_v11.m` (→ `t61f`, `t61g`).
Modell: `jv_dsge_v11.mod`, `-DNWSPEC=0|1|2`, `-DPINW`, `-DOMEGANW`.

### 10.1 Technikai
- `NWSPEC=0` mellett a v11 **bitre a v10**, SC=1..4 (az `OMEGANW` kapcsoló felvétele után is).
- `NWSPEC=1` (`PINW = 0,0025 / 0,005 / 0,0075`) és `NWSPEC=2` (`PINW = 0,005`), OPTEN=0, SC=1: BK a kezdeti és a záró rezsimben is 13/13, nulla-sokk pontosan 0. A rácsok, küszöbök és GDP-sávok BK-ellenőrzése csak a **záró** rezsimre vonatkozik.
- Az `OMEGANW` felvétele utáni regresszió kézi futtatás volt (eltérés 0), mentett kimenete nincs.

### 10.2 Mi lett a W0 jóslatából

| | W0 (behelyettesítés) | W0b (újraoldva) |
|---|---|---|
| hazai KKV tartós nw, aszimm. χ, ACC=100 | −0,76 → **+0,57** | −0,75 → **+1,51** |
| export-KKV, ugyanott | −1,06 → −0,57 | −1,08 → −0,64 |
| ACC=0 esetek | kis változás | kis változás (pl. E −1,09 → −1,19) |

Az irány stimmelt; a visszahatások a hazai KKV-nál felerősítették a változást.

### 10.3 Az A25 sorsa: **fennáll** (A26)

| | aszimm. χ küszöb (OPTEN=0 / 1) | szimm. χ küszöb |
|---|---|---|
| NWSPEC=0 (v10) | 36,50 / 22,25 | 0 / 0 |
| NWSPEC=1 (teljes) | 32,19 / 19,55 | 0 / 0 |
| NWSPEC=2 (csak A+B) | 35,78 / 21,94 | 0 / 0 |

Az `omega_nw = 0,9728` és `0,9826` mellett (NWSPEC=0/1) is ugyanez a minta: 8/8 + 8/8; a 0,95-tel együtt 12/12 + 12/12. **Korlát:** csak χ = 0,04-et teszteltük (az A25 0,02 / 0,04 / 0,06-ra szól), az `NWSPEC=2`-t csak ω = 0,95-ön, a π-t a küszöbökön nem variáltuk, és az általános egyensúlyi lezárás (adatcsomag F.1) nyitott.
**Ezek mellett a szimmetrikus-χ eredmény nem a redukált nettóvagyon-egyenlet műterméke.**
A korábbi „fékező gyorsító” mechanizmus-leírás viszont a teljes egyenlettel nem
igaz minden típusra: a hazai KKV tartós nettó vagyona erős hozzáférési csatornával nő.

### 10.4 Kontraintuitív: a GDP-sáv az `omega_nw`-tól függ (F08)

Utólagos, a W0b-ben nem előre rögzített scan, de a 4. szakaszból következik: a
vállalkozói jövedelem tag súlya és a tartós szorzó is az `omega_nw`-tól függ.

| `omega_nw` | GDP-sáv, redukált nw (NWSPEC=0) | GDP-sáv, teljes nw (NWSPEC=1) |
|---|---|---|
| 0,95 (v10 alapág) | +0,52 … +1,18% | +0,62 … +1,81% |
| 0,9728 (a BGG γ közvetlenül ω-ként; ebben a jelölésben nem BGG-konzisztens) | +0,39 … +0,89% | +0,45 … +1,17% |
| 0,9826 (BGG-konzisztens: 0,9728/β) | +0,30 … +0,68% | +0,34 … +0,83% |

A 9 konfiguráció mindenhol pozitív és BK-érvényes. **Kontraintuitív, hogy a
nagyobb perzisztencia kisebb GDP-hatást ad.** Hipotézisünk (nw és efp ω-nként nincs kiírva, tehát nem tesztelt): nagyobb `omega_nw` mellett a tartós
fixpontban nagyobb az `1/(1−omega_nw)` szorzó, a felárcsökkenés erősebben csökkenti
a nettó vagyont, és a χ-fék erősebb. A regiszter a 0,95-öt korábban „BGG-konvenció”
címkével horgonyzottnak jelölte; ez nem a BGG-érték (a paraméter-regiszterben javítva).

### 10.5 Kontraintuitív: pólus a teljes egyenlettel, magas `rho_acc` mellett

`NWSPEC=1` és `OPTEN=1` mellett a KKV−L tartós értéke felrobban és előjelet vált: ω = 0,95 mellett 60 és 80, ω = 0,9728 mellett 80/100 és 100/120, ω = 0,9826 mellett 120 és 140 közötti ACCSCALE-nél. Formálisan BK-érvényes pont az első előjelváltás után csak ω = 0,95-nél van (−87 pp); a +619 pp (ω = 0,9728) közvetlenül előtte. Az első váltás után a rácson több előjelváltás is van, tehát nem egyetlen egyszerű pólus.
**Hipotézis (nem tesztelt):** a teljes egyenlet önerősítő hurkot nyit (kibocsátás → vállalkozói jövedelem → nettó vagyon → felár → hozzáférés → kibocsátás). **Az `OPTEN=1` nem csak a `rho_acc`-ot emeli, hanem más típusparamétereket is újrakalibrál**, ezért a jelenséget a `rho_acc`-nak nem tulajdoníthatjuk (izoláló futás: `OPTEN=3` vagy `-DRHOACC`, még hátra). A küszöbök (19–41) az első váltás előtt vannak, de hogy a hurok a küszöböt már befolyásolja-e, nem mértük. `OPTEN=0` mellett a 0–140-es rácson nincs előjelváltás, de `NWSPEC=1` mellett a válasz szuperlineárisan nő (pólus a rácson kívül valószínű), tehát az ACC=100-as `NWSPEC=1` számok már erősítettek.

### 10.6 Ami ebből következik

- **A26 (áll):** az A25 robusztus a nw-specifikációra és az `omega_nw`-re.
- **F08 (feltételes):** az A01 GDP-sáv `omega_nw`-függő; elfogadási feltétel az
  `omega_nw` horgonyzása vagy sávként közlése. **Ez a projekt fő közölt számát érinti.**
- **Az `omega_nw` státusza** a paraméter-regiszterben „feltételes”.
- **A v11 alapértelmezéséről** (`NWSPEC`, `OMEGANW`) a csapat dönt; a W0b ehhez
  adja a számokat, nem dönt helyette.
- A 2. review-kör ezt a szakaszt is megkapja.
- **Eltérés az előzetes rögzítéstől:** a W0b-t a 8. pont 6. alpontja szerint a 2. review-kör után kellett volna implementálni; a 2. kör előtt implementáltuk és futtattuk, és a regiszterbe is bevezettük (A26, F08). A review ezt is megkapja.
