# v11 — specifikációs javítások a kontraintuitív eredmények nyomán — implementációs terv

*2026-10-04 · Tomi. Állapot: **TERVEZET, review előtt.** Nem része a 2026-10-05-i
workshopnak: a workshop a v09/v10 jelenlegi állapotát mutatja be, a v11 külön
munkafolyamat.*

*Előzmény: a v10 validálása (`t56`, A24) és a szimmetrikus-χ küszöbmérés (`t58`,
A25) négy kontraintuitív eredményt hozott. Ez a terv rögzíti, melyikből lesz
modellmódosítás és melyikből NEM, és milyen előre rögzített szabályok mellett.*

---

## 0. A legfontosabb szabály: ez nem eredmény-javítás

A v11 célja **nem** az, hogy a kontraintuitív eredmények eltűnjenek, vagy hogy a
KKV-előny „szebb” legyen. A cél azoknak a specifikációs hiányosságoknak a
javítása, amelyek **elméleti vagy adatbeli okból** hibásak, attól függetlenül,
merre viszik az eredményt. A határ a „javítás” és a „fabrikálás” között ezen a
négy szabályon múlik:

1. **Előzetes rögzítés.** Minden változtatás indoklása, specifikációja és
   elfogadási feltétele ebben a dokumentumban van, *mielőtt* a v11-et
   lefuttatjuk. Ha futtatás után specifikációt kell váltani, az új verziót
   indoklással ide kell felvezetni, és a régi eredményét is közölni kell.
2. **Kapcsoló, nem felülírás.** Minden változás makró-kapcsoló mögé kerül.
   Alapértelmezésben mind KI, és ekkor a v11 bitre a v10. Az új alapértelmezés
   csapatdöntés, külön lépésben.
3. **A technikai elfogadási feltételek nem tartalmazzák az eredmény irányát.**
   BK-stabilitás, regresszió, beágyazás, nulla-sokk: igen. „A KKV nyerjen”,
   „az EKB-átgyűrűzés legyen 1”: **nem**. A közgazdasági plauzibilitási
   mérőszámokat (7. szakasz) mindig közöljük, v10 és v11 egymás mellett, de
   nem célozzuk őket.
4. **Kedvezőtlen eredményt is közlünk.** Ha egy indokolt javítás csökkenti
   vagy eltünteti a KKV-előnyt, az ugyanúgy regiszter-sor és őr lesz, mint
   ha növelné. Ha csak a kedvező irányú javításokat fogadnánk el, az maga a
   fabrikálás.

---

## 1. Kiinduló diagnózis: a négy kontraintuitív eredmény

| # | Eredmény | Forrás | Mi okozza |
|---|---|---|---|
| K-1 | Hosszú távon a pénzügyi gyorsító **fékez**: tartós felárcsökkenésnél a saját tőke csökken, a tőkeáttétel nő; a nagyobb χ a KKV-t bünteti. Szimmetrikus χ mellett nincs KKV-küszöb. | A25, `t58` | A 713. sor tartós egyensúlya: `nw = omega_nw·lev·efp/(1−omega_nw)`. |
| K-2 | Euróban az EKB-kamat becsapódáskor csak 0,69–0,73-szorosan gyűrűzik át. | F07, `t56` | A 838. sor `nu_uni·bstar` tagja, a 829. sor *aznapi* `bstar`-jával, `nu_uni = 0,25` mellett. |
| K-3 | Forintban egy külföldi kamatemelés becsapódáskor **növeli** a GDP-t (+0,19%). | `t56` (info-sor) | Leértékelődés → export; a modellből hiányzik a devizaadósság mérleghatása. |
| K-4 | A GDP-pálya évtizedekig alig csillapodó, kb. 28 negyedéves ciklusokban leng (|z| = 0,994). Ezzel együtt: jobb hozzáférés mellett a tartós Tobin-q **csökken** (−2,6% / −2,9%). | diagnosztika, 2026-10-04 | Csak bekapcsolt hozzáférési csatornával (`ACCSCALE=0` mellett |z| = 0,92). Valószínű ok: az `omega_acc·acc` tag a JV-féle beruházási egyenletben (723. sor), ahol a beruházás saját együtthatóinak összege 1, ezért a tartós forcingot hosszú távon a q-nak kell ellensúlyoznia. |

### 1.1 Mi lesz ezekből

| # | Döntés | Indoklás |
|---|---|---|
| K-1 | **NEM modellmódosítás.** | A BGG-logika következménye: tartósan kisebb kockázati prémium mellett a vállalkozók kevesebb többlethozamot halmoznak fel. Kontraintuitív, de közgazdaságilag konzisztens. Átírni csak azért lehetne, mert nem tetszik az eredmény. Ami K-1-ből teendő: a **χ alapértelmezése** (K01) csapatdöntés, a v11-től függetlenül. A v11 minden eredményét mindkét χ-változattal közöljük (aszimmetrikus és `-DCHISYM=0.04`). |
| K-2 | **v11, W1 munkacsomag.** | Technikai zárás, amelynek az értékét részben a v03 GDP-hatásának visszaadására választották (`diag_nuuni_v05.m` fejléce: „konzisztens legyen a v03-mal, y ~ +1.09%”). Ez célzott kalibráció, és egy technikai paraméter viszi az EKB-átgyűrűzés 30%-át. |
| K-3 | **v11, W3 munkacsomag.** | Hiányzó, jól dokumentált csatorna, magyar adattal kalibrálható, és az euró szempontjából érdemi (az euróval megszűnik az árfolyamkockázat). |
| K-4 | **v11, W2 munkacsomag, diagnosztikával kezdve.** | A q-csökkenés a funkcionális formából következik, nem közgazdasági mechanizmusból. Előbb meg kell mérni, hogy tényleg ez okozza-e a lassú ciklust is. |

### 1.2 Ami kifejezetten NEM a v11 része

- **A χ alapértelmezése** (K01) és a **tőkeáttétel alapértelmezése** (K02):
  kalibrációs csapatdöntés, nem modellmódosítás.
- **Az `aa_j` / `zeta_j` KSH-pótlása:** adatmunka, a v11-től függetlenül futhat.
  Megjegyzés: a 2026-10-04-i diagnosztika szerint szimmetrikus χ és
  `ACCSCALE=0` mellett a maradék KKV-előny főleg az `aa_j`-ből jön, tehát ez a
  pótlás fontosabb lett.
- **Az 50%-os E/D szegmentáció szerinti újrakalibrálás:** külön munka (a
  2026-09-28-i adatrendezési irányelv szerint).
- **Az `e_x` és az `ystar` szétválasztása, sztochasztikus becslés:** marad a
  v10-terv 9. szakaszában rögzített korlátként.

---

## 2. Tervezési döntések

| # | Kérdés | Döntés | Miért |
|---|---|---|---|
| D1 | Fájl | `jv_dsge_v11.mod` = a v10 másolata, a W1–W3 kapcsolókkal. A v09/v10 érintetlen marad. | A v10 validált (A24); a v11-et hozzá kell tudni mérni. |
| D2 | Alapértelmezés | `-DNUCLOSE=0`, `-DACCSPEC=0`, `-DFXDEBT=0`: mindhárom ki, ekkor a v11 **bitre a v10**. | 0. szakasz, 2. szabály; a regresszió (7.1) ezt méri. |
| D3 | Sorrend | W1 → W2a (diagnosztika) → W2 → W3. | A W1 a legolcsóbb, és a W2 diagnosztikáját is érintheti (a `bstar` dinamikája benne lehet a lassú ciklusban). |
| D4 | χ-változatok | Minden v11-eredményt két χ-változattal futtatunk: aszimmetrikus alapág és `CHISYM=0.04`. | K-1 / A25: az eredmény a K01-től függ, ezt nem szabad elrejteni. |
| D5 | Kombinációk | Minden munkacsomagot külön is, és mindhármat együtt is mérünk. | A hatásokat szét kell tudni választani; egy „minden egyszerre” változat elfedné, melyik mit csinál. |
| D6 | Ki dönt az alapértelmezésről | A csapat, a v11 eredményeinek ismeretében, külön commitban. | `CLAUDE.md`, munkamódszer 4. pont. |

---

## 3. W1 — a valutaunió külső zárása (`-DNUCLOSE`)

### 3.1 Probléma

A 838. sor euró-ága: `r = r_for + zsov·sov − nu_uni·bstar`, a 829. sor *aznapi*
`bstar`-jával. Egy EKB-kamatemelés még abban a negyedévben javítja a
külkereskedelmi mérleget, a `bstar` nő, és a zárási tag azonnal visszahúzza a
hazai kamatot. A `nu_uni = 0,25` a regiszter szerint „technikai uniózárás, nem
strukturális becslés”, és 250-szer akkora, mint a lebegő ági `nu_b = 0,001`.

### 3.2 Javasolt specifikáció

Az adósság-rugalmas prémium szokásos formája (Schmitt-Grohé–Uribe 2003,
„Closing small open economy models”) **kicsi** rugalmasságot használ. Emellett
**saját döntésként** javasoljuk, hogy a zárás az *előző* időszaki külső
pozícióra vonatkozzon, hogy az aznapi kereskedelmi mérleg ne hasson vissza
ugyanabban a negyedévben a kamatra. (Hogy az irodalmi forma aznapi vagy
előző időszaki pozíciót használ, ellenőrizendő; lásd a 8. szakasz
review-kérdéseit.)

```
@#if NUCLOSE == 1
    + uni*(r - r_for - zsov*sov + nu_uni*bstar(-1)) = 0;
@#else
    + uni*(r - r_for - zsov*sov + nu_uni*bstar) = 0;
@#endif
```

A lebegő ágat (839. sor, `nu_b`) **nem** módosítjuk: ott az árfolyam is
stabilizál, és a `nu_b` a JV-től átvett érték.

### 3.3 A `nu_uni` értéke — előre rögzített szabály

- Scan: `nu_uni ∈ {0.001, 0.005, 0.01, 0.05, 0.25}`, mindkét `NUCLOSE`-változattal.
- **Az alapértelmezési javaslat szabálya, előre rögzítve:** a legkisebb érték,
  amely mellett (a) mindkét rezsimben BK-stabil, és (b) a `bstar`
  eltérésének felezési ideje az euró-rezsimben 40 negyedévnél rövidebb. A
  40 negyedév azért, mert ennél lassabb külsőpozíció-alkalmazkodás már a
  szimulációs horizont (120) harmadát elfoglalja.
- A GDP-hatás és az átgyűrűzés **nem** szempont a választásnál; mindkettőt
  közöljük a teljes rácson.

### 3.4 Munka

Kb. fél nap: kapcsoló, scan-script (`sens_nuclose_v11.m`), regiszter-sor.

---

## 4. W2 — hol lép be a hitelhozzáférés (`-DACCSPEC`)

### 4.1 Probléma

A 723. sor körüli beruházási egyenlet a JV/CEE-alak, amelyben a beruházás saját
együtthatóinak összege 1 (`1/(1+β) + β/(1+β)`). Egy tartós `omega_acc·acc`
forcing-tagot ezért hosszú távon csak a `q/((1+β)ψ)` tag tud ellensúlyozni:
tartósan jobb hozzáférés mellett a tőke értéke **csökken**. Ez a funkcionális
forma következménye, nem közgazdasági mechanizmus. Valószínűleg ugyanez a
forrása a K-4 lassú ciklusnak is, de ezt előbb mérni kell (W2a).

### 4.2 W2a — diagnosztika a módosítás ELŐTT

1. A |z| = 0,994-es komplex gyök sajátvektorának felbontása: mely változók
   (acc, i, k, q, nw, bstar) dominálják.
2. Ugyanez `ACCSCALE ∈ {0, 25, 50, 100}` mellett: mikor lép át a gyök a 0,95-ös
   modulusz fölé.
3. Ugyanez W1 után (`NUCLOSE=1`): a külső zárás benne van-e a ciklusban.

Kimenet: `t59_ciklus_diagnosztika.csv`. **Ha a diagnosztika szerint a ciklust
nem a hozzáférési tag okozza, a W2 specifikációs indoklása ettől nem dől el**
(a q-csökkenés önmagában is indok), de a „W2 megszünteti a ciklust”
várakozást elvetjük, és ezt ide felvezetjük.

### 4.3 Javasolt specifikáció — előre rögzítve

**Elsődleges: összetételi (aggregációs) forma, `ACCSPEC=1`.** Az extenzív margó
közgazdasági tartalma összetételi: a típus beruházása = a hitelezett cégek
aránya × egy hitelezett cég beruházása. Log-linearizálva:

```
i_tilde_E = 1/(1+beta)*i_tilde_E(-1) + beta/(1+beta)*i_tilde_E(+1)
            + 1/((1+beta)*psi_E)*q_E + e_i_ar;
i_E = i_tilde_E + omega_acc_E*acc_E;
```

ahol `i_tilde_j` a hitelezett cégek beruházása (a régi Euler-egyenlet,
forcing-tag nélkül), és `omega_acc_j` az, hogy a margón belépő cégek
beruházása mekkora a meglévőkéhez képest. A tőkeakkumuláció (`k_j`) az
aggregált `i_j`-t használja. Így a hozzáférés a beruházás *szintjét* emeli,
a q-t nem kényszeríti le.

**Másodlagos, összevetésre: hozam-forma, `ACCSPEC=2`.** A hozzáférés a
befektetői feltételben csökkenti a megkövetelt hozamot:
`ret_j(+1) = r − π(+1) + efp_j − omega_acc_j·acc_j + eps_q`.

**Miért az 1-es az elsődleges:** az extenzív margó definíció szerint
összetételi jelenség („hány cég jut hitelhez”), és az 1-es forma ezt
közvetlenül ábrázolja. A 2-es forma a hozzáférést árként kezeli, ami az
intenzív margóhoz közelebb áll. Mindkettőt futtatjuk és közöljük; **az 1-es
elsődlegességét a futás előtt rögzítjük, és nem változtatunk rajta azért,
mert a 2-es kedvezőbb eredményt ad.**

### 4.4 Ami megmarad, és amit ellenőrizni kell

- `ACCSCALE=0` mellett mindkét forma pontosan a v08-at adja (A13 beágyazás).
- A λ·ω-szorzat-azonosítás (A22) az 1-es formában is fennáll, mert az `acc`
  továbbra is csak egy helyen, `omega_acc`-kal szorozva lép be. Ezt nem
  feltételezzük, hanem mérjük (`t52e`-típusú teszt).
- A KKV-küszöböt (F01) mindkét formában, mindkét χ-változattal újramérjük.

### 4.5 Munka

Kb. 2–3 nap: W2a diagnosztika, két specifikáció, újramért küszöbök, regiszter.

---

## 5. W3 — a devizaadósság mérleghatása (`-DFXDEBT`)

### 5.1 Probléma

Lebegő árfolyam mellett egy külföldi kamatemelés leértékelődést okoz, és a
modellben ez csak az exporton át hat, ezért élénkít. Egy devizában eladósodott
vállalatnál a leértékelődés a hazai pénzben mért adósságot is növeli, és rontja
a mérleget (Céspedes–Chang–Velasco 2004; Gertler–Gilchrist–Natalucci 2007).
Ez a csatorna magyar vállalati adaton releváns, és az euró szempontjából
érdemi: az euróval az árfolyamkockázat megszűnik.

### 5.2 Javasolt specifikáció

A saját tőke egyenletében (713. sor) a devizaadósság átértékelődése: az
adósság a saját tőke `(lev_j − 1)`-szerese, ennek `fx_j` hányada devizában:

```
@#if FXDEBT == 1
nw_E = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl))
       - (lev_E - 1)*fx_E*dep);
@#else
nw_E = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl)));
@#endif
```

(D és L ugyanígy.) Euróban `dep = 0`, így a tag a csatlakozás után kikapcsol.

**Nyitott kérdés a review-nak:** a devizahitel kamata is eltér a forinthitelétől
(UIP-különbözet). Az első körben csak az átértékelődést vesszük fel, a
kamatkülönbözetet nem; ezt itt jelezzük, nem hallgatjuk el.

### 5.3 Kalibráció

- `fx_j`: a vállalati devizahitelek aránya méret szerint, MNB-hitelstatisztika.
  **Előre rögzítve:** a legutóbbi rendelkezésre álló év adata, nem több év
  közül a legkedvezőbb. Ha méret szerinti bontás nincs, közös `fx` az
  aggregátumból, és ezt horgonyzatlan aszimmetriaként **nem** pótoljuk becsléssel.
- Az Opten-panelben esetleg elérhető devizás kötelezettség-mezőt ellenőrizni
  kell; ha van, az a méret szerinti bontás forrása lehet.

### 5.4 Munka

Kb. 2 nap + az adatgyűjtés.

---

## 6. Infra és regiszter

- `docs/regiszter/parameterek.csv`: az új paraméterek (`fx_j`) és a `nu_uni`
  új státusza; a `t54` őr frissítése.
- Minden közölt v11-szám regiszter-sor + SZINT-őr, a v10-mintára (A24/A25/F07).
- `check_v11.m` → `t60`: a 7. szakasz ellenőrzései.
- A v11 *nem* lesz az operatív alapmodell, amíg a csapat nem dönt (D6).

---

## 7. Ellenőrzési terv és elfogadási feltételek

### 7.1 Technikai elfogadás — kötelező, minden kapcsoló-kombinációra

1. **Regresszió:** minden kapcsoló KI → a v11 bitre a v10, mind a négy
   forgatókönyvben.
2. **BK** a kezdeti (`uni=0`) és a záró (`uni=1`) rezsimben is.
3. **Nulla-sokk** (`SCENARIO=4`): minden változó végig 0.
4. **Szimmetria** (`-DSYM=1`): a három típus azonosan viselkedik.
5. **Beágyazás:** `ACCSCALE=0` → v08 (A13), minden `ACCSPEC` mellett.
6. **Horizont-teszt:** 120 vs. 400 negyedév, az első 60 negyedévben az
   eltérés < 0,05 pp. (A 2026-10-04-i v09-mérés ennyit adott; a v11-nek nem
   szabad rosszabbnak lennie.)

### 7.2 Közgazdasági plauzibilitási mérőszámok — közöljük, NEM célozzuk

A v10 és a v11 minden változata egymás mellett, mindkét χ-változattal:

| Mérőszám | v10 érték (2026-10-04) |
|---|---|
| Legnagyobb komplex stabil gyök modulusa, periódusa | 0,994; 28 negyedév |
| Tartós Tobin-q a hozzáférési csatornával (E / D) | −2,6% / −2,9% |
| EKB-átgyűrűzés euróban, becsapódáskor | 0,69–0,73 |
| Külföldi kamatemelés GDP-hatása forintban, becsapódáskor | +0,19% |
| Tartós GDP-hatás (SC=1, TSCEN=3) | +0,84% |
| KKV−L tartós különbség és KKV-küszöb | t48b / t58b |

Ha egy W-csomag után valamelyik mérőszám **rosszabb** lesz (például
hosszabb ciklus), azt ugyanúgy közöljük, és a W-csomag indoklását újra kell
nézni, nem az értékét hangolni.

---

## 8. Review-eljárás

1. **Első kör: ez a terv**, adversarial review-ra (ChatGPT, a korábbi
   csomagok mintájára), a futtatás előtt. Kifejezett kérdések:
   - Megalapozott-e a K-1 „nem módosítjuk” döntése, vagy a log-lineáris BGG
     nettó vagyon-egyenletéből hiányzik valami, ami a tartós viselkedést
     megváltoztatná?
   - Az `ACCSPEC=1` összetételi forma helyes log-linearizálás-e?
   - A W1 előre rögzített választási szabálya (felezési idő < 40 negyedév)
     indokolt-e? És az előző időszaki `bstar(-1)` használata összhangban
     van-e az adósság-rugalmas prémium irodalmi formájával?
   - A W3-ban elég-e az átértékelődés, vagy a kamatkülönbözet is kell?
2. **Csapat-egyeztetés** (Samu, Évi) a review után.
3. **Második kör: a v11 eredményei**, a 7.2 táblával együtt.

---

## 9. Ütemezés

| Időszak | Lépés |
|---|---|
| 2026. okt. 6–10. | A terv review-ja, csapat-egyeztetés, javítások ebbe a dokumentumba. |
| okt. 13–17. | W1 (fél nap) és W2a diagnosztika. |
| okt. 20–31. | W2, újramért küszöbök. W3 adatgyűjtés párhuzamosan. |
| nov. 3–14. | W3, `check_v11`, regiszter és őrök. |
| nov. 17–28. | Második review-kör, csapatdöntés az alapértelmezésről. |
| december | Beépítés a végső anyagba, a döntéstől függően. |

---

## 10. Ami ez a terv után is nyitva marad

- A χ szintje és méret szerinti különbsége: nincs magyar becslés (F04).
- A hozzáférési csatorna ereje (λ·ω): a v11 sem horgonyozza, csak a
  specifikációját javítja. A küszöbforma és az azonosítási álláspont marad.
- Az `aa_j` / `zeta_j` KSH-pótlása.
- Az 50%-os szegmentáció szerinti újrakalibrálás.
