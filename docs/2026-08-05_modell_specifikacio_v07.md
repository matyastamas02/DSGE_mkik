# Modellspecifikáció — háromtípusos SOE-DSGE euróbevezetési szcenárióhoz

*2026-08-05 · a `v07` tervezett szerkezete: blokkok, egyenletek,
paraméterek, becslési stratégia. Minden tervezési döntés mellett szerepel,
hogy a 2026-08-02-i hibafeltárási napló melyik aggodalmára válaszol.
Kapcsolódik: `docs/2026-08-02_hibafeltaras_naplo.html`,
`docs/2026-08-05_valaszok_a_hibafeltarasra.md`,
`docs/2026-08-05_phi_kalibracio_es_tulajdon.md`.*

> **Státusz: specifikáció, nem implementáció.** Az egyenletek log-linearizált
> alakban, a `.mod` konvenciója szerint (kisbetű = steady state-től vett
> eltérés). Egyetlen blokk sincs lefuttatva. Ahol analitikus állítást teszek
> a modell viselkedéséről, ott jelölöm, hogy sejtés, és mivel ellenőrizhető.

---

## 0. Tervezési elvek

A napló három betegséget diagnosztizált: nem azonosított paraméterek a fő
állítás lábában, szerkezeti degeneráció (reallokációs maradék, `efp_S ≡ efp_L`),
és a mechanizmus utólagos kitalálása. A specifikáció ezekre három elvvel
válaszol.

**(E1) Minden paraméter ahhoz a dimenzióhoz kötődik, ahol az adat azonosítja.**
Aggregált/nominális paraméterek makro-idősorból, bayesi becsléssel. Keresztmetszeti
(típus-) paraméterek az Opten-panelből, kalibrálva. Ami egyikből sem jön,
az **küszöbformában** szerepel, nem pontbecslésként.

**(E2) Egyetlen csatorna sem privilegizált.** Minden csatorna ki-be kapcsolható
makróval, és a dekompozíció **kimenet**, nem bemenet.

**(E3) Ami degenerált, azt szerkezetileg kell javítani, nem kalibrációval.**
A típus-specifikus termelés nem kényelmi kérdés: enélkül a szegmens-tőke
reallokációs maradék marad.

---

## 1. Architektúra

Három termelőtípus, két piac, **teljes (nem háromszög) input-output háló**.

```
        ┌──────────────────────────────────────────────┐
        │            Γ  (3x3 köztes input)             │
        │   minden típus vásárol minden típustól       │
        └───┬──────────────┬──────────────┬────────────┘
            │              │              │
     ┌──────▼─────┐  ┌─────▼──────┐  ┌───▼────────┐
     │  Sd        │  │  Sx        │  │  L         │
     │  φ = 0     │  │  φ = 0,376 │  │  φ = 0,625 │
     │  hazai KKV │  │  exp. KKV  │  │  nagyváll. │
     └──────┬─────┘  └──┬──────┬──┘  └──┬──────┬──┘
            │           │      │        │      │
            ▼           ▼      ▼        ▼      ▼
        hazai végső  hazai   EXPORT  hazai  EXPORT
```

- **Sd** és **Sx** az elemzés tárgya; **L** általános egyensúlyi háttér
  (tényezőpiaci verseny) és a hálózat nagy vevője.
- **A kapcsolat méret szerinti, nem ágazati** — ez javítja a napló által
  kifogásolt `hazai → export` ágazati linket.
- **Az `Sd ↔ Sx` közötti átjárás endogén** (exportba lépés és kilépés).
  Ez az extenzív margó, amit a napló hiányol a modellből.

> **Miért nem háromszög-szerkezet.** A specifikáció első változatában csak
> `Sd → {Sx, L}` élek szerepeltek. Ez a mért `φ_Sx = 0,376`-tal közvetlenül
> inkonzisztens: **az exportáló KKV kibocsátásának 62,4%-a a hazai piacra
> megy**, és egy feldolgozóipari KKV ezt döntően más cégeknek adja el, nem
> háztartásoknak. A háromszög-szerkezet ezt a 62%-ot mind a végső keresletbe
> küldte volna. Hasonlóképp az `L → S` áramlás (energia, telekom,
> nagykereskedelem, banki szolgáltatás) nem elhanyagolható.

## 2. Háztartások

Változatlanul a JV-szerkezet, mert ez a becsült rész, és a napló nem
kifogásolta.

Ricardiánus ág (habit-tal):

```
c_o = h/(1+h)·c_o(-1) + 1/(1+h)·E[c_o(+1)]
      − (1−h)/((1+h)·σ)·(r − E[π(+1)]) + ε_c
```

Nem-Ricardiánus ág és aggregáció (`ω_nr` = 0,25, survey-alapú):

```
c_nr = w + l
c    = (1−ω_nr)·c_o + ω_nr·c_nr
```

Calvo-bérek EHL bér-Phillips-görbével — a `v0.5` null-eredménye szerint a
belépési pályára nem érzékeny, **de a sztochasztikus rétegben ez a fő
alkalmazkodási eszköz**, tehát bent marad.

> **Napló-válasz (jólét):** a 09. szakasz figyelmeztetése szerint a POC-ban a
> jóléti metrika fordítva működött, mert a munka-disutility tag dominált, és
> 25% nem-Ricardiánus mellett az aggregált jólét nem jól definiált. Ezért a
> specifikáció **nem tartalmaz aggregált jóléti célfüggvényt**. Az elsődleges
> kimenet típusonkénti volatilitás; jólét legfeljebb típusonként, másodlagos
> eredményként.

---

## 3. Termelés — a lényegi átépítés

### 3.1 Típus-specifikus termelési függvény

Minden `j ∈ {Sd, Sx, L}` típus saját technológiával termel, tőkéből, munkából
és köztes inputból:

```
y_j = a + ζ_j·k_j(-1) + (1−ζ_j−γ_j)·n_j + γ_j·m_j
```

Ahol `m_j` a köztes input kompozit: mindhárom hazai típus outputja és az
import CES-aggregátuma. Az árindexét a `Γ` mátrix adja (részletesen a 4.
szakaszban):

```
pm_j = Σ_k γ_jk·p_k + (1 − Σ_k γ_jk)·rer      // k ∈ {Sd, Sx, L}
```

Az `α_j` importintenzitás ennek a maradéktagja: `1 − Σ_k γ_jk` a `j` típus
köztes inputjának importhányada.

A **tényezőárak** típusonként külön határköltséget adnak:

```
rk_j = p_j + mc_j + y_j − k_j(-1)           // típus-specifikus MRPK
w_j  = p_j + mc_j + y_j − n_j
mc_j = ζ_j·rk_j + (1−ζ_j−γ_j)·w + γ_j·pm_j − a
```

> **Ez a kulcs. A napló (B) pontja — „a szegmens-tőke reallokációs maradék" —
> abból ered, hogy a `v05`-ben `ret_S` és `ret_L` ugyanazt a `rk`-t használja,
> miközben az aggregált tőkét a 299. sor lekötözi. Típus-specifikus `rk_j`
> mellett minden típusnak saját tőkekereslete van, és nincs zéró-összegű
> megkötés.**

**A `v04` Blanchard–Kahn-sértéséről.** A `src/model/README.md` szerint a
szektor-specifikus tőkével bővített első változat BK-t sértett. A diagnózisom:
ez **túlhatározottság** volt, mert a JV `d/x` blokk aggregált tőkepiaci
egyenlete (`k(-1) = sh_kd·(...) + (1−sh_kd)·(...)`) megmaradt a típus-szintű
tőkekereslet mellett. A `kkv_dsge_v03–v05` vonalon ugyanez a szerkezet fut,
mert ott nincs versengő aggregált feltétel. **A `v07`-ben az aggregált
tőkepiaci egyenlet helyébe típusonkénti tőkekereslet lép — nem mellé.**

### 3.2 A dinamika típusszinten, az allokáció statikusan

Tervezési szabály, ami megakadályozza a túlhatározottság visszatérését:

| szint | mi van ott |
|---|---|
| **típus (dinamikus)** | `k_j`, `i_j`, `q_j`, `nw_j` — Euler + akkumuláció |
| **típus × piac (statikus)** | értékesítés megosztása hazai és export között |

A piaci allokáció **nem** kap saját Euler-egyenletet. Így nem jön létre újabb,
az elsővel versengő tőkekereslet-meghatározás.

### 3.3 Importintenzitás: hogyan kalibráljuk, amikor nincs rá adat

A JV-ben az importtartalom **piac szerint** van indexelve (`a_d = 0,80` →
20% importsúly; `a_x = 0,45` → 55%). Az új szerkezetben a típus termel egy
jószágot, tehát az importintenzitás **típus-paraméter** kell legyen.

Cégszintű import-adat nincs az Opten-panelben (`anyagkoltseg` van, hazai/import
bontás nélkül). Az ÁKM viszont ágazati. **Imputáció:**

```
α_j = Σ_s ω_js · α_s
```

ahol `ω_js` a `j` típus árbevétel-megoszlása az `s` ágazatok között
(Opten, mérhető), `α_s` pedig az ágazati hazai köztes input arány (ÁKM,
`t24`: autóipar 6,0%, elektronika 4,2%, vegyipar 27,1%, teljes gazdaság 10,1%).

> **Ez imputáció, nem mérés, és így is kell közölni.** De reprodukálható,
> mindkét bemenete adatolt, és nincs benne szabad paraméter — szemben a
> `t`-súlyokkal, ahol a napló azonosítási kudarcot állapított meg.

---

## 4. Termelési háló: a `Γ` mátrix

### 4.1 Szerkezet

Minden típus köztes input kompozitja CES-aggregátum mindhárom hazai típus
outputja és az import felett:

```
pm_j = Σ_k γ_jk·p_k + (1 − Σ_k γ_jk)·rer
m_jk = m_j − ρ_m·(p_k − pm_j)              // kereslet a k-típus outputjára
```

A `k` típus iránti teljes kereslet a végső kereslet és az összes köztes
felhasználás összege:

```
y_k = s_c,k·c + s_i,k·ii + s_g,k·g + φ_k·x_k + Σ_j s_v,jk·m_jk
```

### 4.2 Kalibráció extra adatigény nélkül

A típus×típus mátrix nem mérhető közvetlenül, de imputálható ugyanazzal az
eszközzel, amit a 3.3 pont az importintenzitásra használ:

```
Γ_jk = Σ_s Σ_r ω_js · a_sr · ω_kr
```

ahol `a_sr` az ágazati ÁKM-együttható (`t24` inputja), `ω_js` pedig a `j`
típus árbevétel-megoszlása az ágazatok között (Opten, mérhető). **Nincs benne
szabad paraméter, és reprodukálható.**

> **A torzítás iránya ismert, és jelölni kell.** Az imputáció feltételezi,
> hogy egy ágazaton belül a típusok az ágazati átlagnak megfelelő arányban
> vásárolnak egymástól. A valóságban a nagy vevők aránytalanul nagy eladóktól
> vásárolnak (kapacitás, minősítés, koncentrált beszállítói bázis), tehát az
> imputáció **valószínűleg felülbecsli az `L ← S` áramlást**. Konzervatív a
> rossz irányba: a beszállítói linket nagyobbnak mutatja, mint amekkora.

### 4.3 Nagyságrendi horgony

Az ÁKM szerint az **export-mag** hazai köztes input aránya 5,4% (`t24`), a
teljes gazdaságé 10,1%. A napló dokumentálja, hogy a `v04`-ben használt
`s_kkv = 0,20` **négyszeres túlkalibrálás** volt, és a link hozzájárulása
42% helyett 4,4%. **A `v07`-ben a `Γ` sorösszegei ezekre az ÁKM-értékekre
kell hogy illeszkedjenek** — ez az imputáció beépített ellenőrzése.

### 4.4 Közvetett exportkitettség: mennyit visz a háló

Ez a blokk azért kritikus, mert az `Sd` típus egy része **közvetett
exportőr**: aki az Audi Győrnek szállít, annak terméke autóba építve hagyja
el az országot, de az Opten-adatban nincs exportárbevétele.

Az `Sd` típus ágazati összetétele (2021–24, árbevétel-arányos):

| ágazat | `Sd` részesedés | ágazati exportintenzitás |
|---|---|---|
| Kereskedelem | 31,7% | 7,8% |
| Feldolgozóipar | 12,4% | 66,4% |
| Mezőgazdaság | 4,4% | 9,5% |
| Adminisztratív szolgáltatás | 4,0% | 10,8% |
| Ingatlanügyletek | 2,4% | 3,0% |

Összesen az `Sd`-árbevétel **32,3%-a** olyan ágazatban van, ahol az
exportintenzitás legalább 20%; további 6,0% a 10–20%-os sávban.

> **Ez korlátozza, de nem érvényteleníti a fő állítást.** A közvetett
> kitettség valós — nagyjából az `Sd` nyolcada klasszikus tier-2 beszállítói
> profil —, de a domináns tömeg (kereskedelem, ingatlan, mezőgazdaság,
> egészségügy) valóban hazai. A `Γ`-blokk feladata, hogy ezt a ~12–32%-ot
> **mennyiségileg** vigye át, ne feltevésként.

### 4.5 Spektrálsugár: a napló szingularitása előre ellenőrizhetővé válik

A napló strukturális pólust talált `s_kkv ≈ 0,25` körül (a megoldó reziduuma
1e-17 volt, tehát nem numerikus hiba).

A `Γ`-formalizmusban ez ugyanabba a családba tartozik, mint a Leontief-inverz
konvergenciafeltétele: `[I − Γ]⁻¹` létezése, azaz a rugalmasságokkal súlyozott
`Γ` spektrálsugara egynél kisebb. Su (2024) erre zárt alakot ad
(`v = [I − Γ]⁻¹β`), `N = 3`-ra triviálisan kiszámolható.

**Ettől a pólus numerikus meglepetésből futtatás előtt ellenőrizhető
feltétellé válik.**

> Nem állítom, hogy pontosan `ρ(Γ) = 1` adja a 0,25-ös pólust — abba a
> `mu_vert = 0,5` és más rugalmasságok is beleszámítanak. A **családot**
> állítom, nem az azonosságot.

### 4.6 Ára és kockázata

A körkörösség visszahozhatja a Blanchard–Kahn-problémákat, és 2 helyett 9
imputált paramétert jelent. Cserébe megjelenik a **hálózati felnagyítás**,
ami Su szerint az aggregált TFP-re 1,58–1,7-szeres, és amely a jelenlegi
modellből teljesen hiányzik.

## 5. Árazás

Típusonként és piaconként külön Calvo, hibrid (indexált) alakban:

```
π_j   = β/(1+βϑ_p)·E[π_j(+1)] + ϑ_p/(1+βϑ_p)·π_j(-1) + λ_p/(1+βϑ_p)·mc_j + ε_p
π_jx  = β/(1+βϑ_x)·E[π_jx(+1)] + ϑ_x/(1+βϑ_x)·π_jx(-1) + λ_x/(1+βϑ_x)·mcx_j + ε_x
mcx_j = mc_j − px_j                        // export-határköltség (LCP)
px_j  = px_j(-1) + π_jx − π                // relatív exportár
```

A Calvo-paraméterek (`ξ_p`, `ξ_x`, `ϑ_p`, `ϑ_x`) **közösek a típusok között**,
mert a típusonkénti árragadósság magyar adaton nem azonosítható. Ez explicit
megszorítás, nem hallgatólagos feltevés.

> **Direkt sablon: Adolfson, Laséen, Lindé & Villani (2007), JIE — teljes
> szöveggel ellenőrizve.** Ugyanezt a szerkezetet — külön Calvo-blokk hazai,
> import-fogyasztási, import-beruházási és export szegmensre — Bayesi
> becsléssel illesztik euróövezeti adatra. Két átvehető eredmény:
>
> 1. **Az import/export árragadósság 2–3 negyedév, a hazai 8.** Ez
>    számszerűsíti a fenti állítást, hogy a piac dimenzió technológiai és
>    árazási paraméterei eltérnek a méret dimenzióétól — a mi közös
>    Calvo-megszorításunk a *típusok* között áll, nem a *piacok* között, és
>    ez utóbbi különbség empirikusan jelentős kell legyen.
> 2. **A perzisztens (autokorrelált) import/export markup-sokkok
>    nélkülözhetetlenek a reálárfolyam volatilitásának és perzisztenciájának
>    illesztéséhez.** Fehér zajos markup-sokkokkal a modellezett reálárfolyam
>    szórása 7,85-ről 5,99-re esik, autokorrelációja 0,93-ról 0,86-ra
>    (Adolfson et al., 6. tábla). **Következmény a `v06`-ra:** az
>    `eps_md`/`eps_mx` sokkokat nem szabad fehér zajként hagyni a
>    sokk-szórás-gyűjtés után — `ρ_md`, `ρ_mx` explicit, magas (0,9 fölötti)
>    autokorrelációs paramétert igényel, különben a rezsimváltás
>    volatilitás-hatását alulbecsüljük.
>
> **Egy megoldatlan feszültség, amire számítani kell.** Adolfson et al. a
> hazai/import helyettesítési rugalmasságot (`η_c`) nem tudta becsülni: a
> becslés implauzibilisan magasra (~11) futott, mert a modellnek fel kellett
> oldania a feszültséget az importvolatilitás (3–4-szerese a fogyasztásénak)
> és a sima fogyasztási pálya között. Végül kalibrálták, `η_c = 5`-re
> rögzítve. **Ha a magyar becslésben hasonló feszültség lép fel `im` és `c`
> között, ne meglepetésként kezeljük — a B-terv ugyanez: kalibráció becslés
> helyett.**

---

## 6. Pénzügyi blokk

### 6.1 BGG típusonként

```
ret_j     = (1−ε_q)·rk_j + ε_q·q_j − q_j(-1)
E[ret_j(+1)] = r − E[π(+1)] + efp_j
efp_j     = χ_j·(q_j + k_j − nw_j) + F_j
F_j       = t_sov,j·sov + t_bank,j·bank
```

> **Ez redukált forma — a teljes szerződés Christiano, Motto & Rostagno
> (2014, AER) "Risk Shocks" cikkében, teljes szöveggel ellenőrizve.** A
> log-linearizált `efp_j = χ_j·(...)` mögött a nem-linearizált modellben a
> teljes BGG-szerződés áll: idioszinkratikus `ω` sokk log-normális
> eloszlással, csőd-küszöb `ω̄_{t+1}`, és a zárófeltétel
> `Γ(ω̄) − μ·G(ω̄) = (L−1)/L · R/R^k`. Ha a redukált formát valaha védeni kell,
> ez a hivatkozás — CMR ugyanezt a lineáris közelítést vezeti le a teljes
> szerződésből.
>
> **Sokkal fontosabb egy módszertani figyelmeztetés, ami közvetlenül minket
> érint.** CMR megmutatja: ha a becsült modellből kihagyják a pénzügyi
> megfigyelt változókat (hitelállomány, felár, tőzsdei érték, hozamgörbe
> meredeksége), **a pénzügyi sokk fontossága eltűnik**, és helyette egy másik
> sokk (beruházási hatékonyság) lép elő dominánsként — ráadásul hamis,
> countercyclicus tőzsdei implikációval. Amikor a pénzügyi változókat
> visszateszik, a kockázati sokk lesz a domináns, és a modell helyesen
> procyclicus tőzsdét ad.
>
> **Következmény a `v07` becslési tervére (9.1 szakasz).** Ha a `χ_j` és a
> devizacsatorna fontosságát hitelesen akarjuk azonosítani, **a megfigyelt
> változók közé típusonkénti pénzügyi változó kell**, nem csak aggregált
> makroadat. Enélkül fennáll a kockázat, hogy egy nem pénzügyi sokk veszi át
> a magyarázó szerepet, és a devizakitettségi eredmény (6.2 szakasz)
> alulbecsült vagy tévesen tulajdonított lesz.

**A `t_j` súlyokról.** A napló verdiktje: azonosítási kudarc (arány 0,26–2,75,
semmi sem szignifikáns 5%-on). Következésképp:

- **alapkalibráció: `t_sov,Sd = t_sov,Sx = t_sov,L`** és ugyanígy `t_bank`
  (a napló TSCEN=3 javaslata);
- az aszimmetrikus párok **érzékenységi sávként**, nem „feltevés vs. adat"
  szembeállításként;
- a modell **exaktul lineáris `t`-ben** (a napló 1e-15 pontossággal
  ellenőrizte), tehát a sáv szélei elegendőek, közbenső futás nem kell.

### 6.2 Nettó vagyon devizakitettséggel

Ez az új blokk, a napló 4. opciója („tiszta, kidolgozatlan"). Formális
szerkezet: **GGN (2007) 4.3. szakasza**, foreign-denominated debt.

```
nw_j = κ_j·(ret_j − r(-1) + π) + r(-1) − π + nw_j(-1)
       − ψ_j·(κ_j − 1)·Δrer                        // ÚJ: FX-átértékelés
```

ahol `κ_j = (q·k/nw)_j` a tőkeáttétel és `ψ_j` a devizaadósság aránya.
Az euró bevezetésekor `Δrer` volatilitása megszűnik, tehát ez a tag kiesik —
**ez a csatorna nem szintet, hanem varianciát mozgat**, és ezért csak a
sztochasztikus rétegben (`v06`) látszik.

> **Ellenőrizni kell, mielőtt bekerül.** A napló azt feltételezi, hogy a
> nagyvállalat természetes EUR-fedezettel bír, a KKV fedezetlen. A magyar
> vállalati devizahitel-állomány zöme viszont épp a nagy exportőröknél van.
> `ψ_j` = **nettó** nyitott pozíció, méret szerint (MNB). Amíg nincs meg,
> a csatorna `NOFX` makróval kikapcsolva marad.

### 6.3 A `χ`-előjel kérdése — pontosított diagnózis

A napló 04(A) pontja levezeti, hogy `∂i_ss/∂F = −1/χ`, tehát a
nagyvállalati beruházás háromszor érzékenyebb, és a `χ_S > χ_L` feltevés
a KKV ellen dolgozik.

**Analitikus sejtés (ellenőrizendő):** ez a *keresztmetszeti* összehasonlítás
nagyrészt a **közös `rk`** következménye. Ha `rk` közös, akkor steady state-ben
`efp_j` mindenkire azonos (a napló t21 táblája ezt 15 értékes jegyig mutatja),
tehát `χ_j·lev_j + F_j = const`, ahonnan `lev_j = (const − F_j)/χ_j` — és innen
jön a `−1/χ` skálázás.

Típus-specifikus `rk_j` mellett `efp_j` steady state-ben **eltérhet**, és a
tőkekereslet
```
∂k_j/∂F_j = −1 / (|f''_j| + χ_j·∂lev_j/∂k_j)
```
alakot ölt: a `χ_j` fékező hatása megmarad, de kiegészül a termelési függvény
görbületével, és a két típus között **nincs zéró-összegű megkötés**.

> **Ez nem menti meg az eredeti narratívát, és nem is kell, hogy megmentse.**
> A `v07`-ben a KKV/nagyvállalat különbség a mért `φ_j`-ből, a mért
> hitelhozzáférésből és a devizacsatornából jön. A `χ`-eredményt így
> **eredményként ki lehet mondani** (a napló 5. opciója), mert semmilyen fő
> következtetés nem áll rajta. Az állítás iránya a `v07` futásából derül ki,
> nem előre eldöntött.

### 6.4 Beruházási alkalmazkodási költség

```
i_j = 1/(1+β)·i_j(-1) + β/(1+β)·E[i_j(+1)] + 1/(ψ_i·(1+β))·q_j + ε_i
```

**`ψ_i` közös a típusok között az alapkalibrációban.** A napló 04(D) pontja
dokumentálja, hogy a `ψ_i,S = 8 < ψ_i,L = 13` választás dokumentálatlan volt,
empirikusan visszafelé áll, és a KKV-előny irányába torzít. Szimmetria +
érzékenység a helyes válasz, amíg nincs magyar mikro-becslés.

---

## 7. Export: intenzív és extenzív margó

### 7.1 Intenzív margó

Típusonkénti exportkereslet:

```
x_j = h_x·x_j(-1) + (1−h_x)·(y* − μ_x·(px_j − rer)) + ε_x
```

Az `Sd` típusra `x_Sd ≡ 0`.

### 7.2 Extenzív margó — az exportba lépés

A típusok tömege endogén. `n_Sx` = exportáló KKV-k árbevétel-részesedése:

```
n_Sx = (1−δ_x)·n_Sx(-1) + entry
entry = ε_entry·(E[Π_x] − f_x)
```

ahol `Π_x` a várható exportprofit-előny, `f_x` a fix exportköltség.

**Az euró két csatornán hat `f_x`-re:** a tranzakciós költség és az
árfolyamkockázati prémium megszűnik. Az utóbbi a **hiszterézis** csatorna
(Baldwin–Krugman-féle beachhead-logika): elsüllyedt belépési költség és
volatilis árfolyam mellett a várakozásnak opciós értéke van.

> **Technikai korlát, amit nem lehet elfedni.** Elsőrendű közelítésben érvényes
> a bizonyossági ekvivalencia: a volatilitás megszűnése nem hat a döntésre.
> A hiszterézis-hatást ezért **külön, parciális egyensúlyi modulban** kell
> kiszámolni, és `f_x` eltolásaként bevezetni. A két blokkot egyetlen
> paraméter köti össze. Ez nem elegáns, de védhető és decemberig kész.
>
> **Egy elegánsabb — de drágább — alternatíva, ha az idő engedi.**
> Christiano, Motto & Rostagno (2014) a BGG-blokkban a kockázatot (`σ_t`,
> az idioszinkratikus szórás) **közvetlenül állapotváltozóként, sztochasztikus
> folyamatként** kezeli, nem külön parciális egyensúlyi modulban. Ez fogalmilag
> rokon a mi árfolyam-volatilitás → belépési költség csatornánkkal — csak ők
> ezt be tudják kötni közvetlenül a fő modellbe, mert `σ_t` maga is
> autoregresszív állapotváltozó, amit a szokásos módon linearizálnak. A mi
> esetünkben ez azt jelentené, hogy az árfolyam feltételes volatilitása (pl.
> egy GARCH-szerű vagy sztochasztikus volatilitású folyamat `rer`-re) belép
> állapotváltozóként, és az `entry` egyenlet erre reagál, nem egy külső
> `f_x`-tolásra. **Ez a lemondási listán marad** (11. szakasz) — nagyobb
> becslési komplexitást igényel (a volatilitás maga is állapotváltozó,
> amit azonosítani kell), de ha a `v06` simán megy, érdemes megfontolni
> a hiszterézis-modul helyett.

### 7.3 Kalibráció és a nem azonosított rugalmasság

| mennyiség | érték | forrás |
|---|---|---|
| kilépési ráta `δ_x` | 6,91%/év | Opten-panel, 2022–24 átmenetek |
| belépési ráta (megfigyelt) | 1,52%/év | ugyanaz |
| belépők induló `φ` | 0,027 (medián) | ugyanaz |
| `ε_entry` (rugalmasság) | **nem azonosított** | → küszöbforma |

**Steady state-inkonzisztencia, amit jelölni kell:** a megfigyelt áramlások
nincsenek egyensúlyban (a kilépés négyszerese a belépésnek, az exportáló
KKV-populáció zsugorodik — ezzel konzisztensen a `φ_S` 2021 és 2024 között
0,268-ról 0,204-re esett). A kalibráció `δ_x`-et rögzíti, és a steady state-i
belépést a stacionárius exportőr-arányra illeszti; a megfigyelt nettó csökkenés
átmeneti/sokk-hatásként kezelendő, nem steady state-ként.

**A külső horgony `ε_entry`-hez:** Lalinsky–Meriküll (2021), a szlovák eset —
lebegő árfolyamról érkező, egyedül belépő ország, tehát a magyar helyzet
közeli párja. Az euró 1,8%-kal növelte az euróövezeti célpiacra exportálás
valószínűségét; a státuszváltókra futtatott logitban 11,3%. A teljes
exporthatás +18%, ebből az intenzív margó ~80%.

**Skálázás magyar mértékre:** a szlovák átállás előtti árfolyam-volatilitás
(éven belüli CV átlaga 2006–08-ra) 2,63%; a magyar 2022–24-re 3,06%,
2023–25-re 2,06%. Trendtelenítve 1,58% vs. 1,60%; havi log-hozam szórásban
1,24% vs. 1,86%. **A skálázó nagyjából 1, tehát a szlovák becslés nem igényel
volatilitási haircutot.**

> **A sáv alsó szélének pontos forrása — Baldwin (2006), teljes szöveggel
> ellenőrizve, nem csak hivatkozásból.** Ez a *ugyanaz a Baldwin*, aki a
> Skudelny–Taglioni (2005) 70–140%-os pooled becslését adta — egy évvel
> később a saját módszertanát vizsgálja felül, és lebontja, miért volt az
> a szám erős felülbecslés. Három ok: (i) hiányzó multilaterális
> ellenállás-tag, ami a valutaunió-dummyval korrelál; (ii) pár-specifikus
> fix hatásokkal a hatás **statisztikailag nem különbözik nullától**
> (Pakko–Wall 2001: −0,38, nem szignifikáns); (iii) a régi (euró előtti)
> valutaunió-párok szisztematikusan kicsi, szegény, extrém nyitott
> országok — Baldwin szerint ezeknek **„gyakorlatilag nulla informatív
> tartalmuk van az eurózónára"**. A saját végkövetkeztetése az
> eurózóna-specifikus irodalomra: **„az euró valószínűleg 5–10%-kal
> növelte az euróövezeten belüli kereskedelmet"**. Ez nem kerekítő
> óvatosság, hanem egy önkritikus szerző alaposan levezetett revíziója —
> a sáv alsó vége erre épül, nem általános bizonytalanságra.
>
> **Ez nem érvényteleníti a Lalinsky–Meriküll horgonyt, de kontextust ad
> neki.** Az ő cégszintű, panel fix hatásos, diff-in-diff szerkezetük
> kevésbé sújtott a Baldwin-kritika három pontjától (nincs pooled
> ország-dummy, van cég- és időfix hatás), tehát a +18% nem esik automatikusan
> egy kalapba a naiv gravitációs becslésekkel. De a `f_x`-sáv alsó végét
> mostantól explicit 5–10%-ra kell írni a modellbe, nem „valahol lejjebb"
> típusú kerekítésre.

---

## 8. Külkereskedelem, NFA, monetáris rezsim

```
y     = s_c·c + s_i·ii + s_g·g + s_x·x − s_m·im
bstar = (1/β)·bstar(-1) + s_x·(px + x) − s_m·(rer + im)
rer   = rer(-1) + dep − π
```

Rezsimfüggő monetáris blokk **fordítási idejű makróval** (nem exogén
dummyval — lásd `jv_dsge_v06_stoch.mod`):

```
@#if UNI == 0
r = γ_i·r(-1) + (1−γ_i)·φ_π·π + ε_r
r = E[dep(+1)] − ν_fx·bstar + z_sov·sov + ε_pr
@#else
r = z_sov·sov − ν_fx·bstar
dep = 0
@#endif
```

> **A záró paraméter mindkét rezsimben azonos (`ν_fx`).** A `v05`-ben a lebegő
> ág `ν_b = 0,001`-et, az unió ág `ν_uni = 0,25`-öt használ. Perfect
> foresight-ban ez rendben van; sztochasztikus futásban a feltétel nélküli
> varianciák rendkívül érzékenyek `ν`-re, tehát eltérő `ν` mellett **a mért
> volatilitás-különbség részben a záró eszköz műterméke** lenne. A
> `ν_fx`-érzékenység kötelező robusztussági blokk. Hivatkozás:
> Schmitt-Grohé–Uribe (2003).

---

## 9. Paraméterek: mi becsült, mi kalibrált, mi küszöbforma

### 9.1 Bayesi becslés (magyar makro-idősor, negyedéves)

**Megfigyelt változók (10 aggregált + 3 típusonkénti pénzügyi, lásd
alább):** GDP, fogyasztás, beruházás, export, import, CPI-infláció,
nominális bér, 3M BUBOR, HUF/EUR változás, euróövezeti GDP.

> **Miért kell típusonkénti pénzügyi változó is — Christiano, Motto &
> Rostagno (2014) tanulsága.** A "Risk Shocks" cikk (teljes szöveggel
> ellenőrizve) megmutatja: ha a becsült modellből kihagyják a pénzügyi
> megfigyelt változókat (hitel, felár, tőzsdei érték, hozamgörbe
> meredeksége), a pénzügyi sokk fontossága eltűnik, és egy másik — hamis,
> countercyclicus tőzsdei implikációjú — sokk veszi át a magyarázó szerepet.
> **A `χ_j`/devizacsatorna eredményünk (6. szakasz) csak akkor hihető, ha a
> megfigyelt változók közé típusonkénti hitelállomány vagy felár is bekerül**
> — legalább az `Sx`/`Sd` bontásban, az Opten-alapú kalibrált értékek
> negyedévesített proxyjaként, ha közvetlen negyedéves adat nincs.

| paraméter | prior | forrás/indok |
|---|---|---|
| `h` (habit) | Beta(0,65; 0,10) | JV-poszterior mint prior-közép |
| `σ` (kockázatkerülés) | Gamma(1,8; 0,35) | JV: 1,814 |
| `ξ_p`, `ξ_x` (Calvo) | Beta(0,85; 0,05) | JV; lapos NKPC |
| `ϑ_p`, `ϑ_x` (indexálás) | Beta(0,5; 0,15) | JV |
| `ξ_w`, `ϑ_w` (bér) | Beta(0,75; 0,05) | EAGLE-HU + Kézdi–Kónya |
| `ψ_i` (beruházás, **közös**) | Gamma(10; 3) | JV Φ″ = 13 |
| `γ_i`, `φ_π` (Taylor) | Beta / Gamma | JV: 0,761 / 1,379 |
| `μ_x` (exportár-rugalmasság) | Gamma(1,5; 0,5) | JV |
| `ν_fx` (NFA-zárás) | Gamma(0,25; 0,10) | **nem JV** — lásd 8. szakasz |
| `ρ_·`, `σ_·` (11 sokk) | Beta / InvGamma | JV-poszteriorok |

**Miért prior és nem átvett pontérték:** a JV-poszteriorok egy másik
szerkezetű modellből származnak. Priorként használva a magyar információ
megmarad, de az új szerkezet korrigálhat. Ez a standard eljárás
(Adolfson et al. 2007; Christiano–Motto–Rostagno 2014).

### 9.2 Kalibrált (Opten-panel és ÁKM — nem becsülhető makro-adatból)

| paraméter | érték | forrás |
|---|---|---|
| `φ_Sx` / `φ_L` / `φ_Sd` | 0,376 / 0,625 / 0 | `t27`, 2021–24 |
| árbevétel-súlyok (Sx/Sd/L) | 0,256 / 0,184 / 0,560 | `t27` |
| eszközsúly `ω_j` | 0,205 / 0,244 / 0,551 | `t27d` |
| tőkeáttétel `κ_j` | 0,417 / 0,381 / 0,450 | `t02`, `t27` |
| `Γ` (3x3 köztes input mátrix) | sorösszeg 0,05–0,10 | ÁKM `t24` + ágazati imputáció (4.2) |
| `δ_x` (exportkilépés) | 6,91%/év | átmeneti mátrix |
| `ψ_j` (devizaadósság) | **hiányzik** | MNB-kérés |

> **Miért nem becsüljük ezeket?** Az Opten-panel **éves** és **öt év** hosszú
> (2021–2025, a 2025 részleges). Negyedéves DSGE-becslésben megfigyelt
> változóként nem használható. A típus-blokk kalibrálása tehát nem
> kényelmi döntés, hanem adatkorlát — és ez a standard eljárás a
> heterogenitást modellező irodalomban is (Ottonello–Winberry 2020).

### 9.3 Küszöbformában (nem azonosított — a napló tanulsága)

| paraméter | miért nem azonosított | hogyan közöljük |
|---|---|---|
| `t_sov,j`, `t_bank,j` | becsült arány 0,26–2,75, semmi sem szignifikáns | szimmetrikus alap + sáv |
| `ε_entry` | 3 átmeneti év, közös árfolyammozgás | „a hatás > X, ha `ε_entry` > Y" |
| `χ_j` aszimmetria | az implicit kamat az ellenkezőjét mutatja | szimmetrikus alap + scan |

> **A küszöbforma a napló saját megoldása** (2. opció, „Achilles-sarok"): a
> nem azonosított paraméter a **bemenetből a kimenetbe** kerül, és a kritika
> („ezt beírtad, nem levezetted") értelmét veszti. Precedens a hivatkozott
> Szabó Bakos-disszertáció 4.7 alfejezete.

---

## 10. Irodalom blokkonként

**Verifikációs jelölés:** ✔ = teljes szöveg elolvasva, konkrét egyenlet/szám
átvéve. ○ = csak absztrakt/összefoglaló, nem teljes szöveg. Az összes forrás
verifikációs státusza és az odavezető keresési út a külön HTML-katalógusban:
`docs/2026-08-05_irodalom_katalogus.html`.

**SOE-váz, log-linearizált egyenletekkel**
- Galí & Monacelli (2005), *RES* — ○ — a kanonikus SOE NK; Dynare-implementáció
  a Pfeifer-repóban (`Gali_Monacelli_2005`), a repó tartalmát nem néztük át.
- **Adolfson, Laséen, Lindé & Villani (2007), *JIE*** — ✔ — becsült SOE
  tökéletlen árfolyam-átgyűrűzéssel; a négyszegmenses (hazai/import-c/
  import-i/export) árazási blokk direkt sablonja (5. szakasz). Két átvett
  szám: import/export árragadósság 2–3 negyedév a hazai 8-cal szemben;
  perzisztens markup-sokk nélkülözhetetlen a reálárfolyam-illesztéshez.
- Jakab & Világi (2008), MNB WP 2008/9 — a saját magyar becsült magotok
  (JV), a repóban implementálva, nem külön ellenőrizve.
- Justiniano & Preston (2010), *JIE* — nem ellenőrizve, csak névből
  hivatkozva.

**Pénzügyi akcelerátor és rezsim**
- Bernanke, Gertler & Gilchrist (1999) — nem ellenőrizve; az eredeti BGG,
  csak a származékain (GGN, CMR) keresztül ismert.
- **Gertler, Gilchrist & Natalucci (2007)**, NBER w10128 — ✔ — a modell
  gerince: SOE + akcelerátor + árfolyamrezsim; a 4.3. szakasza a
  devizaadósság (6.2), a fix/lebegő összevetés a sztochasztikus réteg mintája.
- Gilchrist, Hairault & Kempf (2002), Fed IFDP 750 — ✔ — akcelerátor
  valutaunióban, ország-heterogenitásra; a logika átvéve KKV/nagyváll.-ra.
- **Christiano, Motto & Rostagno (2014), *AER*** — ✔ — a teljes,
  nem-linearizált BGG-szerződés a 6.1 redukált formája mögött; és a
  módszertani figyelmeztetés, hogy pénzügyi megfigyelt változó nélkül a
  pénzügyi sokk fontossága eltűnik (9.1).
- Ottonello & Winberry (2020), *Econometrica* — ✔ (a szerző saját oldaláról,
  a hivatalos verzió fizetős) — vállalati pénzügyi heterogenitás és
  beruházás; a `χ_j`-differenciálás megalapozása.

**Export margó és heterogenitás**
- **Ghironi & Melitz (2005), *QJE*** — ✔ — két szimmetrikus ország, nincs
  méretaszimmetria, nincs pénzügyi súrlódás; csak *ihlet*, nem átvett
  szerkezet. Ténylegesen hasznos: a belépési/kilépési formalizmus
  (`N_{D,t}=(1-δ)(N_{D,t-1}+N_{E,t-1})`) mintája a 7.2 szakaszhoz.
- Manova (2013), *RES* / NBER w14531 — ✔ (a 2008/2011-es WP-verzió) —
  hitelkorlát és export; a frikció belépésen és volumenen keresztül hat.
- Baldwin, Skudelny & Taglioni (2005), ECB WP 446 — ✔ — az eredeti
  beachhead-modell és a 70–140%-os pooled becslés. **Ezt a szerző saját maga
  írta felül egy évvel később** — lásd a következő tétel.
- **Baldwin (2006), ECB WP 594** — ✔ — a Rose-hatás irodalmának
  módszertani kritikája, saját szerzőtől. Végkövetkeztetés az eurózónára:
  5–10%, nem 70–140%. Ez adja a `f_x`-sáv alsó szélének pontos forrását
  (7.3), nem általános kerekítést.
- **Lalinsky & Meriküll (2021)**, *IJCB* 17(3) — ✔ — Szlovákia vs. Észtország
  cégszinten, panel fix hatásokkal; a `f_x`-tárcsa fő horgonya. Kevésbé
  sújtott a Baldwin (2006) kritikáitól, mert nem pooled ország-dummy.

**Termelési hálózat**
- **Pasten, Schoenle & Weber (2020), *JME*** — ✔ (a végleges, megjelent
  verzió) — **NINCS TŐKE a termelési függvényben** (`Y=L^(1-δ)Z^δ`, csak
  munka és köztes input) — ez zárja le a spec korábbi nyitott kérdését: a
  tőke-köztesinput kölcsönhatást nekünk kell felírni, PSW csak az
  input-output árazási blokkhoz ad mintát.
- Altinoglu (2018/2021), Fed FEDS → *JME* — ○ — csak absztrakt és
  modell-vázlat több forrásból, a teljes egyenletrendszer nem ellenőrizve.
- Su (2019 WP → *AEJ:Macro* 2024) — ✔ (csak a WP-verzió, a megjelent cikk
  fizetős) — pénzügyi frikciók + input-output; az `N = 2` influence-vektor
  zárt alakja a `Γ`-kalibrációhoz (4. szakasz).

**Módszertan**
- **Schmitt-Grohé & Uribe (2003), NBER w9270** — ✔ — a SOE-zárás öt
  módszerének összevetése; megerősíti, hogy a mi `ν_fx`-lezárásunk az ő
  "Model 2"-jük (adósságfüggő kamatprémium), és hogy a lezárás módja
  önmagában nem számít a konjunktúraciklus-momentumokra — de a
  *konzisztenciája* igen (8. szakasz).
- Baldwin & Krugman (1989); Dixit (1989) — nem ellenőrizve, klasszikus
  hiszterézis-elmélet, csak Baldwin (2006) irodalomjegyzékéből ismert
  másodkézből.

---

## 11. Kockázatok és lemondási sorrend

Ha az idő szorít, ebben a sorrendben hagyandó el:

1. **Hiszterézis-modul** (akár a parciális egyensúlyi, akár a CMR-féle
   sztochasztikus-volatilitás változat) — a lineáris `f_x`-tárcsa működik
   nélküle, most már Baldwin (2006) explicit 5–10%-os alsó sávjával.
2. **Devizakitettségi blokk** — ha az MNB-adat nem érkezik meg, `NOFX=1`.
3. **Extenzív margó endogenizálása** — fix típus-tömegekkel a modell teljes,
   csak a belépési csatorna hiányzik; a megfigyelt 1,52%/6,91% alapján ez
   volumenben kicsi.
4. **Bayesi becslés** — végső esetben JV-poszteriorok átvétele kalibrációként,
   nyíltan jelölve.

**Amit nem szabad elhagyni:** a típus-specifikus termelést (enélkül visszatér
a reallokációs maradék) és a `ν_fx`-érzékenységet (enélkül a sztochasztikus
eredmény nem közölhető).

**A `Γ`-mátrix visszaegyszerűsítése háromszög-szerkezetre nem megengedett
lemondás:** a mért `φ_Sx = 0,376` közvetlenül ellentmond neki (1. szakasz).
Ha a teljes háló numerikusan nem tartható, a helyes visszalépés a `Γ`
*ritkítása* a legkisebb imputált együtthatók nullázásával, spektrálsugár-
ellenőrzés mellett — nem az `Sx` éleinek elhagyása.

---

## 12. Mit kell ellenőrizni, mielőtt bármi épül

1. **A `v06` determináltsági futása** — az unió-ág önmagában determinált-e,
   van-e egységgyök. Ez eldönti, hogy a sztochasztikus réteg egyáltalán
   járható-e.
2. **`ρ(Γ) < 1`** — a kalibrált köztesinput-mátrix spektrálsugara. Ez
   futtatás előtt eldönthető, és megelőzi a napló által talált
   szingularitás-típusú meglepetést (4.5).
3. **A PSW-blokk tőkéje** — van-e benne tőke; ha nincs, a beruházási/akcelerátor
   blokk nem illeszthető rá közvetlenül.
4. **`ψ_j`, a nettó devizapozíció méret szerint** (MNB) — ez dönti el a
   devizacsatorna irányát, amit a napló feltevésként kezel.
5. **MNB méret szerinti új-szerződéses kamatstatisztika** — a napló szerint is
   ez a legnagyobb hozamú nyitott tétel; a `t_j` kérdést is ez zárná le.
