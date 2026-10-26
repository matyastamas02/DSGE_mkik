# Implementációs brief — fiskális blokk, 1. lépés: államadósság, kamatkiadás, szabály, tulajdonosi zárás

*2026-10-25. Egy kódoló munkamenetnek (Claude Code vagy kolléga) szól. A háttér és a levezetés:
`fiskalis_blokk_levezetes_2026-10-25.docx` (2. változat), az 1. blokk és a „Tulajdonosi zárás” fejezet.
A review (2026-10-25) döntése szerint ez a fiskális blokk **első és egyetlen** most kódolandó része.*

## 0. Hatókör

**Benne van:**
- államadósság és kamatkiadás;
- egyösszegű adó adósságszabállyal;
- lejárati szerkezet (kapcsolóval);
- a külföldiek által tartott adósság kamatának bekötése a külső pozícióba (tulajdonosi zárás).

**Nincs benne, külön feladatok:**
- a 2. blokk (nyugdíjasok), mert újra le kell vezetni;
- a 3. blokk (szocho), mert előbb az `α_j`-t kell javítani;
- a 4–6. blokk;
- a v12 egyszerűsítés;
- a devizaadósság átértékelése.

**Alapelv:** ez a lépés a hazai rész miatt nyilvántartás. A gazdaságra csak a külföldi tulajdonú rész hat (`THETAF > 0`).

## 1. Hova

- **Fájl:** `src/modell/1_fo_vonal_jv/jv_dsge_v11.mod`, új makró-kapcsoló mögött. A v09/v10 nem változik.
- **Kapcsoló:** `-DFISCAL=0|1`, alap **0**. `FISCAL=0` mellett a fájl bitre ugyanaz, mint most: az új változók és egyenletek fordítási időben ki sem kerülnek (`@#if FISCAL >= 1`).
- **További kapcsolók**, csak `FISCAL >= 1` mellett hatnak:

| Kapcsoló | Paraméter | Alap | Jelentés |
|---|---|---|---|
| `THETAF` | `theta_f` | 0 | a külföldiek által tartott államadósság aránya. Az alap 0, amíg nincs ÁKK/MNB-adat; a valódi értéket a csapat adja |
| `PHIB` | `phi_b` | 0.05 | az adósságszabály erőssége (feltétel: `phi_b > rgbar − 1`) |
| `BBARG` | `bbar_g` | 2.96 | adósság a negyedéves GDP egységében (74% éves GDP × 4), ellenőrizendő |
| `RGBAR` | `rgbar` | 1.015 | az államadósság egyensúlyi bruttó negyedéves kamata |
| `RHOM` | `rho_m` | 0 | lejárati szerkezet: 0 = egynegyedéves adósság; kb. 0,95 = kb. 5 év átlagos lejárat |

## 2. Új változók

| Dynare-név | Jelentés | Egység |
|---|---|---|
| `rg` | állampapír-hozam | negyedéves ráta eltérése |
| `rge` | effektív átlagkamat az állományon (lejárati szerkezet) | negyedéves ráta eltérése |
| `bg` | államadósság | a negyedéves GDP egységében mért abszolút eltérés (mint a `bstar`) |
| `tls` | egyösszegű adó | negyedéves GDP egység |
| `pb` | elsődleges egyenleg (riport) | negyedéves GDP egység |
| `intexp` | kamatkiadás eltérése (riport) | negyedéves GDP egység |

## 3. Egyenletek (`model` blokk, `@#if FISCAL >= 1` alatt)

```
// F1: allampapir-hozam = iranyado kamat + szuveren felar
rg  = r + sov;
// F1': lejarati szerkezet (rho_m = 0 -> rge = rg)
rge = rho_m*rge(-1) + (1-rho_m)*rg;
// F2: adossag (ado- es transzfertag ebben a lepesben 0)
bg  = rgbar*bg(-1) + bbar_g*rgbar*(rge(-1) - infl) + sg*g - tls;
// F3: adossagszabaly (egyosszegu ado, csak az optimalizalokon -> ricardoi)
tls = phi_b*bg(-1);
// riport
pb     = tls - sg*g;
intexp = bbar_g*rgbar*(rge(-1) - infl) + (rgbar-1)*bg(-1);
```

**A külső pozíció egyenletének módosítása** (a mostani `bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im);` helyett, `@#if FISCAL >= 1` ágban):
```
bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im)
        - theta_f*( bbar_g*(rge(-1) [- r_for(-1), ha FOREIGN==1] - dep)
                    + (rgbar - 1/beta)*bg(-1) );
```
- Az első tag a külföldi tulajdonosoknak fizetett többlethozam a meglévő állományon. Forintban benne van az árfolyam is (`dep`): ha a forint leértékelődik, a külföldi veszít, az ország nyer. Euróban `dep = 0`.
- A második tag a növekvő adósság külföldi része után fizetett egyensúlyi felár. Kicsi, mert `rgbar − 1/beta ≈ 0,005`.
- `FOREIGN=0` mellett (ez az alap) az `r_for` tag kimarad.

**Paraméterértékek:** a `parameters` deklarációba az új nevek; az értékadás a fájl végén, a többi v11-kapcsoló után, hogy a `KALIB`/`EXTCLOSE` blokkok után álljon. A `sg` a meglévő GDP-súly (a KALIB-ban 0,203), ezt újra kell használni, nem új paramétert felvenni.

**Exogén változó nem kell új:** a `sov` már exogén, a `g` már AR(1).

## 4. Elvárt tulajdonságok: ezekre kell őr

| # | Teszt | Elvárt eredmény |
|---|---|---|
| T1a | `FISCAL=1 THETAF=0` vs. `FISCAL=0`, alapszcenárió | minden közös változó max. eltérése **0** (gépi pontosság). Ricardói teszt: a hazai rész nyilvántartás |
| T1b | `FISCAL=1 THETAF=0`, tartós `bg` | a záró egyensúly egyezik az analitikus képlettel: `bg = bbar_g*rgbar*Δrg/(phi_b − (rgbar−1))`, `tls = phi_b*bg`, ahol tartósan `Δrg = r + sov` (euróban `r = 0`, `sov = −0,005`) |
| T1c | `FISCAL=1 THETAF>0` (szemléltetésként 0,4) | a külső pozíció a csatlakozás után javul; tartósan több fogyasztás és import; a nagyságrend a „`theta_f` × kamatmegtakarítás” körül van. Forintos szakasz: a bejelentési felértékelődés miatt az ország veszít a külföldi tulajdonú részen |
| T1d | BK mindkét rezsimben | 13 instabil gyök / 13 előretekintő változó; az új állapotváltozók (`bg`, `rge`) stabil gyököt adnak (`rgbar − phi_b`, illetve `rho_m`). Az aktív alapértelmezésen és a régi beállításon (`-DKALIB=0 -DEXTCLOSE=0 -DSOVCSAT=0 -DHORIZON=120`) is |
| T1e | `RHOM=0.95` | a kamatmegtakarítás fokozatosan épül fel; a tartós érték azonos a `RHOM=0` esettel |

A **külső zárás érzékeny pont**: az A27 óta tudjuk, hogy a `bstar` körüli visszacsatolás destabilizálhat. Az új tag kicsi, de a T1d-t a teljes `ACCSCALE`-rácson (0–150) is le kell futtatni, a friss GDP-súlyokkal.

## 5. Futtató, regiszter, őrök

- **Futtató:** `src/modell/1_fo_vonal_jv/futtato/check_fiscal1_v11.m`, MATLAB, a meglévő futtatók mintájára:
  - a `regi_v11_` segédfüggvény csak a régi beállítású összevetéshez kell;
  - `bk_check_metrics` mindkét rezsimre;
  - 400 negyedéves számítási horizont;
  - riport 20 éves távon, a fő mutató a 16–20. év átlaga.
- **Kimenet:** `output/tables/t65_fiscal1_*.csv`.
- **Előre rögzített elvárások** a futtató fejlécében, futás előtt; a kedvezőtlen eredményt is közölni kell.
- **Regiszter:** minden közölt számhoz sor a `docs/regiszter/allitasok.csv`-ben és SZINT-őr a `src/4_infra/smoke_test.m`-ben. A T1a-ra (pontos beágyazás) és a T1b-re (analitikus egyezés) feltétlenül.
- **Füstteszt és állapotlap:** push előtt `smoke_test`, majd `13_allapotlap.py`.

## 6. Amit NE

- Ne változtass alapértelmezést (`FISCAL=0` marad); a v09/v10-hez ne nyúlj.
- Ne kösd be a 2–6. blokkot, és ne „használd fel” a fiskális mozgásteret: ebben a lépésben nincs szocho-, nyugdíj- vagy egyéb kísérlet.
- Ne kommunikáld a teljes, kb. 1,5%-nyi GDP kamatmegtakarítást nemzetgazdasági nyereségként. Csak a `theta_f`-es rész az; a hazai rész átcsoportosítás.
- Ne push-olj kérdés nélkül.

## 7. Nyitott adatkérdések (a csapattól)

| Adat | Mire kell | Forrás |
|---|---|---|
| A nem rezidensek által tartott államadósság aránya | `theta_f` | ÁKK, MNB |
| Adósság/GDP | `bbar_g` | Eurostat, MNB |
| Implicit átlagkamat, vagy döntés a modellkonzisztens értékről | `rgbar` | ÁKK, Eurostat |
| Átlagos hátralévő lejárat | `rho_m` | ÁKK |
| A devizaadósság aránya (a később bevezetendő átértékeléshez) | — | ÁKK |

### 7a. Első adatkeresés (2026-10-26, nyilvános forrásokból; a modell alapértelmezésén nem változtat)

| Adat | Talált érték | Forrás | Mit jelent a modellnek |
|---|---|---|---|
| Adósság/GDP | 73,5% (2024 vége), 74,6% (2025 vége) | KSH EDP-jelentés, KSH 2026-04-01 | `bbar_g` = 2,94–2,98; a 2,96 rendben |
| Devizaadósság aránya | 28,3% (ÁKK, a legutóbbi féléves értékelés), kb. 30% (2024 vége) | Portfolio 2026-07-01 (ÁKK); OeNB CESEE 2026 | a teljes adósság kb. 28%-a nem forint |
| Devizakülföldiek aránya az intézményi forint-állampapírokban | 19,6% (2025. jún. vége), 17,6% (2024 vége), nem repószűrt | ÁKK, economx 2025-07-02 | a forint-állampapírok intézményi része (28 365 Mrd Ft) a teljes adósság kb. 46%-a, tehát a **külföldi kézben lévő forintadósság a teljes adósság kb. 9%-a** |
| Lakossági állampapírok aránya | 20,2% (2025. jún.) | ÁKK, economx 2025-07-02 | hazai tulajdon |
| Átlagos hátralévő futamidő | 5,6 év összesen, **forint 4,1 év**, deviza 9 év (2025 I. félév); 5,5 év (legutóbbi) | ÁKK, economx 2025-07-02; Portfolio 2026-07-01 | a forintrészre `rho_m ≈ 1 − 1/16,4 ≈ 0,94`; a változó kamatozású lakossági papírok miatt a tényleges átárazódás ennél gyorsabb |
| Kamatkiadás | 2025-ben 16,6%-kal csökkent | KSH 2026-04-01 | az implicit névleges kamat kb. 5–6,5% (saját közelítés), de a modellben nincs infláció és növekedés: a `rgbar`-hoz a reálkamat mínusz növekedés a releváns, ez csapatdöntés |

**A legfontosabb következmény.** Az 1. lépés az egész adósságra ugyanazt az `rg = r + sov` hozamot
alkalmazza, de a teljes adósság kb. 28%-a devizában van. Annál az euró nem a teljes −200 bp-s felárat
tünteti el, csak a hitelkockázati részt. Ezért:

- a **közvetlen állami kamatmegtakarítás** a modellbeli 1,50% GDP helyett inkább kb. 1,1% + a devizarész
  hitelfelár-szűkülése (ha az 0,5–1 százalékpont: összesen kb. 1,2–1,3% GDP);
- a **nemzetgazdasági nyereség** a teljes −200 bp-vel csak a külföldi kézben lévő forintrészen keletkezik
  (kb. 9% → kb. 0,13% GDP/év). Ehhez jön a külföldiek kezében lévő devizaadósság hitelfelár-szűkülése:
  ha a devizaadósság nagy része külföldi kézben van, és a szűkülés 0,5–1 százalékpont, kb. 0,1–0,2% GDP.
  Összesen nagyságrendileg **0,2–0,3% GDP/év**, nem az F12 szemléltető 0,67%-a (ϑ = 0,4, teljes −200 bp).

Ezek hátraboríték-számok. A devizaadósság tulajdonosi megoszlását és a hitelfelár-szűkülést külön
kell igazolni. A modellben a pontos kezeléshez az adósságot **forint- és devizarészre** kellene bontani,
külön hozammal. Ez az 1. lépés kis bővítése lenne, de modellváltoztatás, ezért csapatdöntés.
