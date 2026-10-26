# Implementációs brief — fiskális blokk, 2. lépés: nyugdíjasok és transzfer

*2026-10-26. Egy kódoló munkamenetnek (Claude Code vagy kolléga) szól. A levezetés három lépésben, MPT
jóváhagyásával készült; a háttér a `fiskalis_blokk_levezetes_2026-10-25.docx` 6. fejezete, a review
alapján újravezetve. Előfeltétel: az 1. lépés (`-DFISCAL=1`, `c6bbb74`). A döntési lista 1. pontja
(adósságszabály) az E2b eredményét érinti, de a kódolást nem blokkolja.*

## 0. Hatókör és alapelv

**Benne van:**
- harmadik háztartástípus, a nyugdíjas;
- fogyasztási kiadási súlyok a JV szerint;
- a bérképzés a munkapiacon aktív háztartások fogyasztásából;
- a nyugdíj a költségvetésben;
- két finanszírozási szabály.

**Nincs benne:**
- a szja és a járulékok (6. blokk);
- a szocho (3. blokk, az `α_j` után);
- a nyugdíjprémium és a 13. havi nyugdíj külön szabálya;
- a v12 egyszerűsítés.

**Alapelv:** a blokk a súlyok átrendezése miatt **nyugdíjemelés nélkül is megváltoztatja** a mostani
eredményeket. Ezért kapcsoló mögé kerül, alapértelmezése 0, és az alapértelmezésről a csapat dönt
(döntési lista, 5. pont).

## 1. A levezetés röviden (JV 2008/9, 2.2.2 fejezet és A függelék)

- **Az aggregálás** a JV (76) egyenlete: `ĉ = ω_o·ĉ_o + ω_no·ĉ_no + ω_p·ĉ_p`, ahol `ω_j = ω̄_j·c_j/c`.
  Ezek fogyasztási kiadási súlyok, nem népességarányok. A JV-ben ω_o = 0,75, a maradék 0,25 az aktív
  likviditáskorlátos háztartások és a nyugdíjasok között oszlik meg.
- **A modellünkből a nyugdíjasok kimaradtak:** a teljes 0,25 a `c_no = w + ll` típusra került.
- **A bérképzés:** a szakszervezet csak a munkapiacon aktív háztartások jólétét súlyozza, ezért a
  bér-Phillips-görbébe `c^l` kerül, nem `c`. Egyensúlyban azonos fejenkénti fogyasztás mellett (a
  Galí–López-Salido–Vallés-feltevés) `c^l = (ω_o·c_o + ω_r·c_r)/(ω_o + ω_r)`.
- **A nyugdíjas típus:** kézből-szájba él, `c_p = κ_w·w + trp`. 2010 óta árindexálás van, ezért `κ_w = 0`;
  a JV-ben a svájci indexálás miatt 0,5 volt.
- **A költségvetés:** a nyugdíjkiadás a GDP-ben `s_tr = ω_p·sc`. Ez nem önálló paraméter, így a súly és a
  költségvetés nem jöhet két különböző számból.
- **Kalibráció, (a) változat, MPT jóváhagyta:**
  - `om_p = 0,15`: nyugdíjkiadás / háztartási fogyasztás ≈ 7,5% / 49,7%;
  - `om_r = om_no − om_p = 0,10`;
  - az optimalizálók súlya `1 − om_no = 0,75` marad;
  - `s_tr ≈ 0,0746`.

## 2. Hova

- **Fájl:** `src/modell/1_fo_vonal_jv/jv_dsge_v11.mod`.
- **Kapcsoló:** `-DPENS=0|1`, alapértelmezés **0**. `PENS=1` csak `FISCAL=1` mellett értelmes: ha
  `PENS=1` és `FISCAL=0`, a fájl álljon meg `@#error`-ral.
- **További kapcsolók:**

| Kapcsoló | Paraméter | Alap | Jelentés |
|---|---|---|---|
| `OMP` | `om_p` | 0.15 | a nyugdíjból finanszírozott fogyasztás súlya |
| `OMPTOT` | `om_pt` | `= OMP` | a nyugdíjasok teljes fogyasztási súlya (robusztusság, pl. 0,22); a nem nyugdíjból fedezett rész reálértéken állandó |
| `KAPPAW` | `kappa_w` | 0 | bérindexálás (0 = árindexálás, 0,5 = svájci) |
| `PENSRULE` | — | 0 | 0 = T szabály: a `trp` kívülről adott, az egyösszegű adó fizeti; 1 = P szabály: az adó nem változik, a nyugdíj alkalmazkodik az adóssághoz |

- **Változók:** a meglévő `c_no` nevét **ne változtasd meg** (beágyazás, futtatók). Újak: `c_p`, `cl`, `trp`,
  és egy exogén `e_trp` (a nyugdíjpolitika pályája).

## 3. Egyenletek (`@#if PENS >= 1` alatt)

```
// N1: nyugdijas fogyasztas (keszbol-szajba)
c_p = kappa_w*w + trp;
// N2: aggregalas fogyasztasi kiadasi sulyokkal; om_pt > om_p eseten a nyugdijasok
//     nem nyugdijbol fedezett resze (om_pt - om_p) realerteken allando (0 elteres)
c  = (1 - om_no - (om_pt - om_p))*c_o + (om_no - om_p)*c_no + om_p*c_p;
// N3: a munkapiacon aktivak fogyasztasa -> a ber-Phillips-gorbe MRS-tagjaba (c helyett)
cl = ((1 - om_no - (om_pt - om_p))*c_o + (om_no - om_p)*c_no) / (1 - om_pt);
// ber-Phillips: sigma/(1-habit)*(cl - habit*cl(-1)) + fii*ll - w   (eddig c)
// N4: adossag a nyugdijkiadassal (az 1. lepes F2 egyenletenek bovitese)
bg = rgbar*bg(-1) + bbar_g*rgbar*(rge(-1) - infl) + sg*g + s_tr*c_p - tls;
// N5: finanszirozas
@#if PENSRULE == 0
tls = phi_b*bg(-1);                    // T: ricardoi, a nyugdijpalya kivulrol adott
trp = e_trp;
@#else
tls = 0;                               // P: a ber nem valtozik, a nyugdij alkalmazkodik
trp = -(phi_b/s_tr)*bg(-1) + e_trp;
@#endif
```

- **Paraméterek:**
  - `s_tr = om_p*sc;` a KALIB-blokk **után**, mert a `sc` ott kap végleges értéket;
  - az `om_no` a meglévő (0,25), a KALIB nem írja felül.
  - ⚠ A `-DCALIB26=1` az `om_no`-t 0,16-ra állítja, ilyenkor `om_no − om_p` ≈ 0,01. A futtató ellenőrizze,
    hogy `om_no − om_p > 0,05`, különben álljon meg.
- **A `pb`** (elsődleges egyenleg) riportja bővüljön: `pb = tls - sg*g - s_tr*c_p;`.

## 4. Elvárt tulajdonságok: ezekre kell őr

| # | Teszt | Elvárt eredmény |
|---|---|---|
| T2a | `PENS=1 OMP=0` vs `PENS=0` (`FISCAL=1`) | minden közös változó max. eltérése **0** (`om_p = 0` mellett `cl = c`, `s_tr = 0`) |
| T2b | `PENS=1`, `e_trp = 0`, euró-szcenárió | a súlyok átrendezésének hatása önmagában: GDP, fogyasztás, reálbér a `PENS=0`-hoz képest. Elvárás csak az irányra: a fogyasztás kevésbé reagál a foglalkoztatásra. A számot közölni kell, bármi jön ki |
| T2c | E2a: új `-DSCENARIO=5` (nincs euró, `sov = bank = uni = 0`, csak a nyugdíjpálya): tartós `e_trp`, 16 negyedév alatt felfutva; nagysága akkora, amekkora az euró közvetlen megtakarítása (1,50/7,46 ≈ +20%) | `c_p` = `trp`; az aggregált fogyasztás kb. `om_p·trp`-vel nő, az optimalizálóké csökken; az adósság átmenetileg nő, majd a szabály visszahúzza |
| T2d | E2b: `PENSRULE=1`, euró-szcenárió | tartósan analitikusan `bg = bbar_g·rgbar·Δrg/(phi_b − (rgbar−1))` (ugyanaz, mint az A32-ben), `trp = −(phi_b/s_tr)·bg` ≈ **+28,8%** a mostani adósságszabállyal. Az első években kis átmeneti csökkenés lehet (A33) |
| T2e | BK mindkét rezsimben, a teljes ACCSCALE-rácson, T és P szabállyal, `OMPTOT = 0,15` és 0,22 | 13 instabil gyök / 13 előretekintő változó. A P szabály új visszacsatolást ad (`bg → trp → c → y → infl → bg`), ezért ez nem formalitás |
| T2f | `s_tr = om_p·sc` | gépi pontossággal; `s_tr ≈ 0,0746` (KALIB) |

## 5. Futtató, regiszter, őrök

- **Futtató:** `src/modell/1_fo_vonal_jv/futtato/check_pens_v11.m`, a `check_fiscal1_v11.m` mintájára:
  - az elvárások előre rögzítve a fejlécben;
  - 400 negyedéves számítási horizont, riport 20 éves távon, a fő mutató a 16–20. év átlaga.
- **Kimenet:** `output/tables/t66_pens_*.csv`.
- **Regiszter:** minden közölt számhoz sor a `docs/regiszter/allitasok.csv`-ben és SZINT-őr a `smoke_test.m`-ben.
  A T2a-ra és a T2d-re (analitikus egyezés) feltétlenül.
- **Push előtt:** füstteszt, majd `13_allapotlap.py`.

## 6. Amit NE

- Ne változtass alapértelmezést (`PENS=0` marad).
- Ne nevezd át a `c_no`-t, és ne nyúlj a v09/v10-hez.
- Ne kösd be a szocho-, szja- és járulékblokkot.
- **Ne közöld a T2b-t „a nyugdíjasok hatásaként”.** Az a súlyok javításának hatása, vagyis a mostani modell
  hibájának mérete, nem egy szakpolitikai eredmény.
- Az E2b-t ne közöld a döntési lista 1. és 2. pontjának eldöntése előtt. A +28,8% a mostani
  adósságszabályon és a teljes −200 bp-n áll; adósságstabil szabállyal kb. +20%, forint- és devizaadósság
  szétbontásával inkább +16–17%.
- Ne push-olj kérdés nélkül.

## 7. Adatkérések

| Adat | Mire kell | Forrás |
|---|---|---|
| Nyugdíjkiadás / háztartási fogyasztás, 2015–2024 átlag | `om_p` (most 0,15) | KSH nemzeti számlák, NyA-zárszámadás |
| A nyugdíjas háztartások részesedése a teljes háztartási fogyasztásból | `OMPTOT` (most 0,22, feltevés) | KSH háztartási költségvetési felvétel |
| Az aktív likviditáskorlátos háztartások aránya ma (a 0,25 a 2000-es évek felméréséből jön) | `om_no` | MNB/HFCS (a CALIB26 0,16-os proxyja) |
| Az indexálás tényleges szabálya (tervezett infláció + korrekció) | `kappa_w`, későbbi bővítés | Nyugdíjtörvény |

Nyugdíjasok száma, tájékoztatásul: 2025 januárjában kb. 2,27 millió saját jogú ellátott (a népesség kb.
24%-a, a felnőttek kb. 29%-a), az átlagos öregségi nyugdíj 242 ezer Ft.
