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
