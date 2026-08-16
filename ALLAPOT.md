<!-- GENERÁLT FÁJL — NE SZERKESZD. Forrás: docs/regiszter/*.csv +
     output/tables/t00_orok.csv. Újragenerálás:
       matlab -batch "cd('src/4_infra'); smoke_test"
       python src/4_infra/13_allapotlap.py                                -->

# DSGE_mkik — állapotlap

*Generálva a füstteszt 2026-08-16 15:37-kor futott eredményéből · commit `4dbcf1f` · ág `main`*

**Fő modell:** `src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod` (Jakab–Világi mag). A `kkv_dsge_*` a referencia-vonal.

**Őrök:** 90 rendben, 0 hiba.

✅ **Minden „áll” állításnak van őre, és minden őr fut.**

---

## Mit állítunk ma

### 🟢 Ami ÁLL — 15 db

*Ezekre lehet építeni a tanulmányban.*

**A01.** Az euró tartós aggregált GDP-hatása POZITÍV, +0,3% … +2,9% — minden modellverzión, szcenárión és kalibrációs ágon.

> bizonyíték: `t44, t47` — őr: ✅ `t47: mind a 36 kombinacio BK-stabil (az OPTEN=1 phi_D=0 is)`  
> *2026-08-16 · A SÁV 2026-08-16-án módosult: korábban +0,27…+1,04% volt (lásd V01). A felső vég a hozzáférési csatorna perzisztenciáján múlik.*

**A02.** Az exportáló KKV hitelhozzáférése 13-szorosa a hazai KKV-énak (61,9% vs 4,8%).

> bizonyíték: `t37 (s14)` — őr: ✅ `t37: az export-KKV hozzaferese 13x a hazaie (12.8x: 61.9% vs 4.8%)`  
> *2026-08-12 · Saját mérés az Opten-panelből; a projekt egyik legerősebb saját ténye.*

**A03.** A nagyvállalati hitelhozzáférés 43,4% — ALACSONYABB, mint az export-KKV-ké.

> bizonyíték: `t37 (s14)` — őr: ✅ `t37: a nagyvallalati hozzaferes ALACSONYABB az export-KKV-enal (43.5% < 61.9%)`  
> *2026-08-12 · Cáfolja a "nagyvállalatnak mindig van hitele" narratívát; az omega_acc_L=0 feltevést gyengíti.*

**A04.** A magyar KKV-hitelpiac 2021–24-ben PROGRAMVEZÉRELT volt: a BUBOR 12,8 pontot mozgott, a hozzáférési arányok legfeljebb 2,2-t (a hazai KKV-nál mindössze 0,6-ot).

> bizonyíték: `t37 (s14)` — őr: ✅ `t37 PROGRAMVEZERELTSEG: a BUBOR 12.8 pontot mozgott, a hozzaferes legfeljebb 2.2-et`  
> *2026-08-12 · Ez a projekt legfontosabb azonosítási korlátja — ebből következik V03, V04 és részben V06. JAVÍTVA 2026-08-16: a korábbi doksiszöveg „kevesebb mint 2 pontot” mondott, a tényleges maximum 2,2 pp (export-KKV). Az állapotlap konzisztencia-ellenőrzése fogta el.*

**A05.** A hazai KKV hozzáférése MONOTON NŐTT a kamatcsúcs felé (4,5% → 5,1%).

> bizonyíték: `t37 (s14)` — őr: ✅ `t37: a hazai KKV hozzaferese NOTT a kamatcsucs fele (4.5% -> 5.1%)`  
> *2026-08-12 · A támogatott programok épp akkor bővültek, amikor a piaci kamat tetőzött.*

**A06.** Az ACCSCALE magyar 2021–24-es adatból NEM horgonyozható. (Negatív eredmény, de eredmény.)

> bizonyíték: `t36, t37` — őr: ✅ `t45b: veges access-kuszob a JV-magon (ACCSCALE=36.3)`  
> *2026-08-12 · Következmény: a szektorális állítás küszöbformában közlendő. Doksi: 2026-08-12_access_horgonyzas_eredmeny.md*

**A07.** A tőkeáttétel sorrendje lev_L > lev_E > lev_D (2,34 > 1,94 > 1,72), és a SORREND mérőfüggetlen.

> bizonyíték: `t50` — őr: ✅ `t50: a tokeattetel-sorrend L > E > D (2.337 > 1.939 > 1.719)`  
> *2026-08-16 · A SZINT mérőfüggő, ezért sávban közlendő: lev_E 1,68–1,94 · lev_D 1,58–1,72 · lev_L 1,81–2,34.*

**A08.** A lev_E = lev_D kényszerített egyenlőség NEM ÁLL: az exportáló KKV tőkeáttételesebb.

> bizonyíték: `t46, t50` — őr: ✅ `t46: a lev_E = lev_D kenyszeritett egyenloseg NEM ALL (1.939 vs 1.719)`  
> *2026-08-16 · A teendőlista 1. prioritásának nevesített részfeladata volt.*

**A09.** A negyedéves értékcsökkenési ráta 0,024–0,025 — két független forrás egyezik.

> bizonyíték: `t46; Christensen–Dib (2008) 1. tábla` — őr: ✅ `t46: delta = 0.0242 megerositi az atvett 0.0250-et`  
> *2026-08-16 · Opten-panel 0,0242; C&D 0,025. Az átvett modellérték helyes volt.*

**A10.** A nagyvállalati exportárbevétel-arány phi_L ≈ 0,365.

> bizonyíték: `t46` — őr: ✅ `t46: phi_L = 0.3649 megerositi az atvett 0.365-ot`  
> *2026-08-16 · Négy tizedesig egyezik az átvett értékkel — az valószínűleg már ebből a panelből származott.*

**A11.** A hitelhozzáférési státusz negyedéves perzisztenciája legalább 0,967.

> bizonyíték: `t46c` — őr: ✅ `t49b: a kuszob MONOTON csokken a rho_acc-ban (47.8 -> 17.5)`  
> *2026-08-16 · ALSÓ KORLÁT: cég-szintű perzisztencia; a modell szegmens-szintű acc_j-je ennél perzisztensebb.*

**A12.** A fő modell BK-stabil minden szcenárió × transzmisszió × kalibrációs ág kombinációban (36/36).

> bizonyíték: `t47` — őr: ✅ `t47: mind a 36 kombinacio BK-stabil (az OPTEN=1 phi_D=0 is)`  
> *2026-08-16 · Beleértve az OPTEN=1 ágat, ahol phi_D = 0 pontosan.*

**A13.** Az access-csatorna egzaktul beágyazott: ACCSCALE=0 mellett a v09 PONTOSAN a v08-at adja (eltérés 0,0e+00).

> bizonyíték: `t45b` — őr: ✅ `t45b NESTING: ACCSCALE=0 == v08 (elteres 0.0e+00)`  
> *2026-08-12 · Független verifikáció, nem BK-teszt.*

**A14.** A modell átment 17/17 független azonosság-ellenőrzésen (szimmetria 1e−16, aggregáció 1e−19, nulla-sokk pontosan 0).

> bizonyíték: `t43` — őr: ✅ `t43: mind a 17 fuggetlen ellenorzes atment`  
> *2026-08-12 · Ezek olyan hibát fognak el (elgépelt index, felcserélt súly), amit a BK-teszt nem.*

**A15.** Az implicit_kamatrata oszlop TORZÍT minden olyan regresszióban, ahol a magyarázó változó együtt mozog a hitelállomány változásával.

> bizonyíték: `t50b` — őr: ✅ `t50b: a chi elojele atfordul a nevezo javitasaval (A: -0.01167 -> C: +0.00857) - a negativ eredmeny mutermek volt`  
> *2026-08-16 · Módszertani figyelmeztetés a panel egészére. A nevező év végi állomány, a számláló évközi kamat.*

### 🟡 Ami FELTÉTELES — 4 db

*Csak a feltétellel együtt közölhető — küszöbformában, vagy az elfogadási feltétel kiírásával.*

**F01.** A KKV-blokk akkor előzi meg a nagyvállalatot, ha az ACCSCALE eléri a 22,3-at (horgonyzott rho_acc mellett) — átvett rho_acc-cal 36,5-öt.

> bizonyíték: `t48, t48b` — őr: ✅ `t48b: az empirikus horgony LEVISZI a kuszobot (36.5 -> 22.3)`  
> *2026-08-16 · KÜSZÖBFORMA. Az ACCSCALE horgonyzatlan (A06), tehát ez feltételes állítás, nem eredmény.*

**F02.** Az export-KKV kibocsátásának ELŐJELE az eps_ces-en fordul, ~2,3-nál.

> bizonyíték: `t42` — őr: ✅ `t42: az y_E ELOJELE eps_ces-fuggo (dokumentalt KORLAT, kuszobforma kell)`  
> *2026-08-12 · Az aggregált GDP érzéketlen rá (0,008 pp sáv) — csak a szektorális eredményt viszi.*

**F03.** Az om_j / shl_j súlyok az Opten-panelből: 0,256/0,184/0,560 és 0,157/0,378/0,466.

> bizonyíték: `t46` — őr: ✅ `t46: az om_j es az shl_j sulyok 1-re osszegzodnek`  
> *2026-08-16 · ELFOGADÁSI FELTÉTEL: ezek a 10+ fős populáción BELÜLI részesedések. Teljes gazdaságra KSH/Eurostat SBS mikrokör-bontás kell (teendők 2.5). Addig -DOPTEN alapértelmezése 0.*

**F04.** A chi (BGG felár-rugalmasság) alsó korlátja a magyar panelen +0,002 negyedéves; az irodalmi érték 0,042–0,067.

> bizonyíték: `t50b; Christensen–Dib (2008) 2. tábla` — *nincs őr*  
> *2026-08-16 · A becslés erősen attenuált (mérési hiba, átlagos vs határráta, programvezéreltség). NEM cáfolja az irodalmi értéket — alulazonosított.*

### 🔴 Amit VISSZAVONTUNK — 8 db

*Ezek **nem** kerülhetnek vissza a szövegbe. A dátum és az ok azért van itt, hogy ne kelljen újra levezetni.*

**V01.** "Az aggregált GDP-hatás +0,27% … +1,04% minden lépcsőn és paraméterezésen."

> bizonyíték: `t47` — őr: ✅ `t49b KORLAT: a horgonyzott rho_acc mellett a GDP-hatas TULMEGY a korabbi savon (1.75% > 1.04%)`  
> *2026-08-16 · OK: a sáv az ÁTVETT rho_acc=0,85 mellett érvényes. Horgonyzott rho_acc mellett a felső vég +2,03% (OPTEN=1), illetve +2,89% (OPTEN=3). Helyette: A01.*

**V02.** "Duális gazdaság: a magyar autóipar mindössze 6% hazai köztes inputot használ."

> bizonyíték: `t24; P2-azonosságteszt`   
> *2026-08-12 · OK: az IO-mérés hibás — az összegzett köztes felhasználás a nemzeti számlák P2-jének csak 1,8–8,6%-a. A gyökérok MÉG NYITOTT, és az IRÁNYT SEM tudjuk. Doksi: FIGYELMEZTETES_io_tabla_gyanus.md*

**V03.** "A KKV erősebb kamattranszmissziót kap (t_S > t_L)."

> bizonyíték: `t26`   
> *2026-08-12 · OK: nem azonosítható — a becsült arány 0,26 és 2,75 között szóródik, semmi sem szignifikáns. Doksi: FIGYELMEZTETES_fo_allitas.md*

**V04.** "A KKV BGG-érzékenysége háromszorosa a nagyvállalatiénak (chi_S = 0,06 vs chi_L = 0,02)."

> bizonyíték: `t50b; Christensen–Dib (2008)`   
> *2026-08-16 · OK: a panel a chi_L-t egyáltalán nem azonosítja (n=230, t=-0,78), a szakirodalom pedig EGYETLEN, méret szerint nem bontott chi-t becsül. Javaslat: szimmetrikus alap + scan.*

**V05.** "A chi_j értékek az Opten-panel mediánjai."

>   
> *2026-08-12 · OK: soha nem voltak azok — a hivatkozás téves volt. A tőkeáttétel-adat (lev_S < lev_L) ráadásul nem is támogatja a magasabb KKV-chi-t.*

**V06.** "A KKV hitelhozzáférése erősen reagál a piaci kamatra (a chi/access becsülhető a 2021–24-es panelből)."

> bizonyíték: `t36, t37`   
> *2026-08-12 · OK: a 2021–24-es magyar epizód programvezérelt (A04), ezért a piaci kamat varianciája nem azonosítja a piaci kamatra vett rugalmasságot.*

**V07.** "Szegmens-szintű tőke és beruházás a v05-ből."

>   
> *2026-08-11 · OK: reallokációs maradék, nem szerkezeti eredmény. A v06 oldotta meg (szegmens-specifikus rk_j).*

**V08.** "A tőkeáttétel növekedése csökkenti a vállalati forrásköltséget (chi < 0, t = -4,09)."

> bizonyíték: `t50b` — őr: ✅ `t50b: a chi elojele atfordul a nevezo javitasaval (A: -0.01167 -> C: +0.00857) - a negativ eredmeny mutermek volt`  
> *2026-08-16 · OK: MÉRÉSI MŰTERMÉK. Az implicit ráta nevezője év végi állomány, a számlálója évközi kamat; a nevező javítása után az együttható eltűnik, a stabil állományú metszeten pedig pozitívra fordul. Lásd A15.*

---

## A 91 paraméter

| Státusz | db |
|---|---:|
| 🟢 horgonyzott | 34 |
| 🔴 horgonyzatlan | 20 |
| ⚪ származtatott | 18 |
| 🟡 pótolandó | 11 |
| 🟡 feltételes | 8 |

*Az **érték** oszlop a modellből jön futásidőben (`-DOPTEN=0` ág), nem a CSV-ből — kézzel átírt érték nem tud becsúszni.*

### A. saját adat (Opten-panel) — 14 db

| Paraméter | Érték | Státusz | Forrás | Kapcsoló | Doksi |
|---|---:|---|---|---|---|
| `delta` | 0.025 | 🟢 horgonyzott | Opten-panel 2021–24 (0,0242) ÉS Christensen–Dib (2008) 1. tábla (0,025) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `om_E` | 0.18 | 🟡 feltételes | Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS mikrokör-bontás kell az átskálázáshoz (teendők 2.5) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `om_D` | 0.37 | 🟡 feltételes | Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS mikrokör-bontás kell az átskálázáshoz (teendők 2.5) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `om_L` | 0.45 | 🟡 feltételes | Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS mikrokör-bontás kell az átskálázáshoz (teendők 2.5) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `phi_E` | 0.56 | 🟡 feltételes | Opten-panel; a definíciótól függ (ALAP 0,376 vs KÜSZÖB25 0,691) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `phi_D` | 0.05 | 🟡 feltételes | Opten-panel; az ALAP definícióban DEFINÍCIÓ SZERINT 0, nem mérés | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `phi_L` | 0.365 | 🟢 horgonyzott | Opten-panel 2021–24 (0,3649) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `lev_E` | 1.6 | 🟢 horgonyzott | Opten-panel medián 1,939 (sáv 1,68–1,94); irodalom k/n=2 (C&D 2008 1. tábla) | -DOPTEN | [kalibracio_bgg_blokk.md](docs/kalibracio_bgg_blokk.md) |
| `lev_D` | 1.6 | 🟢 horgonyzott | Opten-panel medián 1,719 (sáv 1,58–1,72) | -DOPTEN | [kalibracio_bgg_blokk.md](docs/kalibracio_bgg_blokk.md) |
| `lev_L` | 1.85 | 🟢 horgonyzott | Opten-panel medián 2,337 (sáv 1,81–2,34) | -DOPTEN | [kalibracio_bgg_blokk.md](docs/kalibracio_bgg_blokk.md) |
| `shl_E` | 0.2 | 🟡 feltételes | Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS mikrokör-bontás kell az átskálázáshoz (teendők 2.5) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `shl_D` | 0.5 | 🟡 feltételes | Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS mikrokör-bontás kell az átskálázáshoz (teendők 2.5) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `shl_L` | 0.3 | 🟡 feltételes | Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS mikrokör-bontás kell az átskálázáshoz (teendők 2.5) | -DOPTEN | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |
| `rho_acc` | 0.85 | 🟢 horgonyzott | Opten-panel van_hitel átmenet-mátrix (0,9673) — ALSÓ KORLÁT | -DOPTEN / -DRHOACC | [2026-08-16_opten_kalibracio_eredmeny.md](docs/2026-08-16_opten_kalibracio_eredmeny.md) |

### B. nyilvános magyar makroadat (KSH) — 11 db

| Paraméter | Érték | Státusz | Forrás | Kapcsoló | Doksi |
|---|---:|---|---|---|---|
| `zeta_E` | 0.14 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `zeta_D` | 0.17 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `zeta_L` | 0.155 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `aa_E` | 0.45 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `aa_D` | 0.8 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `aa_L` | 0.6 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `sc` | 0.54 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `si` | 0.23 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `sg` | 0.1 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `sx` | 0.6 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |
| `sm` | 0.47 | 🟡 pótolandó | jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4) |  |  |

### C. JV-becsült (MNB WP 2008/9 poszterior) — 28 db

| Paraméter | Érték | Státusz | Forrás | Kapcsoló | Doksi |
|---|---:|---|---|---|---|
| `sigma` | 1.814 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `habit` | 0.646 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `fii` | 2 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9 (strukturális/survey) |  |  |
| `rho_kz` | 0.8 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9 (strukturális/survey) |  |  |
| `rho_z` | 0.5 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9 (strukturális/survey) |  |  |
| `xi_p` | 0.921 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `vth_p` | 0.431 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `xi_x` | 0.81 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `vth_x` | 0.494 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `xi_w` | 0.657 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `vth_w` | 0.185 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `theta_w` | 3 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9 (strukturális/survey) |  |  |
| `hx` | 0.507 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `mu_x` | 0.534 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `gam_i` | 0.761 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `phi_pi` | 1.379 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `nu_b` | 0.001 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `om_no` | 0.25 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9 (strukturális/survey) |  |  |
| `eps_qw` | 0.96 | 🟢 horgonyzott | Bernanke–Gertler–Gilchrist (1999) konvenció |  |  |
| `omega_nw` | 0.95 | 🟢 horgonyzott | Bernanke–Gertler–Gilchrist (1999) konvenció |  |  |
| `rho_a` | 0.552 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_x` | 0.625 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_c` | 0.767 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_w` | 0.661 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_i` | 0.488 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_pr` | 0.82 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_mx` | 0.318 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |
| `rho_g` | 0.8 | 🟢 horgonyzott | Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag |  |  |

### D. nem azonosított / több adat kell — 20 db

| Paraméter | Érték | Státusz | Forrás | Kapcsoló | Doksi |
|---|---:|---|---|---|---|
| `chi_E` | 0.06 | 🔴 horgonyzatlan | Opten-panel: chi_S≈+0,002 (alsó korlát); irodalom 0,042–0,067 (C&D 2008; BGG-konvenció) — méret szerinti bontás NÉLKÜL |  | [kalibracio_bgg_blokk.md](docs/kalibracio_bgg_blokk.md) |
| `chi_D` | 0.06 | 🔴 horgonyzatlan | Opten-panel: chi_S≈+0,002 (alsó korlát); irodalom 0,042–0,067 |  | [kalibracio_bgg_blokk.md](docs/kalibracio_bgg_blokk.md) |
| `chi_L` | 0.02 | 🔴 horgonyzatlan | NEM AZONOSÍTOTT: n=230, t=-0,78, rossz előjel (kalibracio_bgg_blokk.md) |  | [kalibracio_bgg_blokk.md](docs/kalibracio_bgg_blokk.md) |
| `psi_E` | 8 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  |  |
| `psi_D` | 8 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  |  |
| `psi_L` | 13 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  |  |
| `tsov_E` | 0.175 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  | [FIGYELMEZTETES_fo_allitas.md](docs/FIGYELMEZTETES_fo_allitas.md) |
| `tsov_D` | 0.175 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  | [FIGYELMEZTETES_fo_allitas.md](docs/FIGYELMEZTETES_fo_allitas.md) |
| `tsov_L` | 0.175 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  | [FIGYELMEZTETES_fo_allitas.md](docs/FIGYELMEZTETES_fo_allitas.md) |
| `tbank_E` | 0.45 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  | [FIGYELMEZTETES_fo_allitas.md](docs/FIGYELMEZTETES_fo_allitas.md) |
| `tbank_D` | 0.45 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  | [FIGYELMEZTETES_fo_allitas.md](docs/FIGYELMEZTETES_fo_allitas.md) |
| `tbank_L` | 0.45 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  | [FIGYELMEZTETES_fo_allitas.md](docs/FIGYELMEZTETES_fo_allitas.md) |
| `s_kkv` | 0.05 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DSKKV | [FIGYELMEZTETES_io_tabla_gyanus.md](docs/FIGYELMEZTETES_io_tabla_gyanus.md) |
| `mu_vert` | 0.5 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DMUVERT | [FIGYELMEZTETES_io_tabla_gyanus.md](docs/FIGYELMEZTETES_io_tabla_gyanus.md) |
| `zsov` | 0.5 | 🔴 horgonyzatlan | nincs hivatkozható forrás |  |  |
| `eps_ces` | 6 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DEPSCES |  |
| `lambda_acc_E` | 2 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DACCSCALE | [2026-08-12_access_horgonyzas_eredmeny.md](docs/2026-08-12_access_horgonyzas_eredmeny.md) |
| `lambda_acc_D` | 2.5 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DACCSCALE | [2026-08-12_access_horgonyzas_eredmeny.md](docs/2026-08-12_access_horgonyzas_eredmeny.md) |
| `omega_acc_E` | 0.35 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DACCSCALE | [2026-08-12_access_horgonyzas_eredmeny.md](docs/2026-08-12_access_horgonyzas_eredmeny.md) |
| `omega_acc_D` | 0.45 | 🔴 horgonyzatlan | nincs hivatkozható forrás | -DACCSCALE | [2026-08-12_access_horgonyzas_eredmeny.md](docs/2026-08-12_access_horgonyzas_eredmeny.md) |

### E. származtatott vagy technikai — 18 db

| Paraméter | Érték | Státusz | Forrás | Kapcsoló | Doksi |
|---|---:|---|---|---|---|
| `beta` | 0.99 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `lam_p` | 0.00756633 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `lam_x` | 0.0464679 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `lam_w` | 0.0260714 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `nu_uni` | 0.25 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás | -DNUUNI |  |
| `wd_E` | 0.110545 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `wd_D` | 0.490613 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `wd_L` | 0.398842 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `wx_E` | 0.355493 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `wx_D` | 0.0652442 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `wx_L` | 0.579263 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shm_E` | 0.280453 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shm_D` | 0.209632 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shm_L` | 0.509915 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shd_c` | 0.65061 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shd_i` | 0.177439 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shd_g` | 0.141951 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |
| `shd_v` | 0.03 | ⚪ származtatott | más paraméterekből számolódik / technikai zárás |  |  |

---

## Őrök (90 db)

*A füstteszt minden ellenőrzése. Ez a projekt egyetlen olyan nyilvántartása, ami nem tud némán elcsúszni: ha egy állítás megdől, itt megbukik egy sor.*

<details><summary>Teljes lista</summary>

- ✅ opten_panel.csv letezik
- ✅ panel sorszam = 150982 (tenyleges: 150982)
- ✅ irf_v01.csv letezik
- ✅ aszimmetria: |i_S| > |i_L| banki sokkra
- ✅ aszimmetria: |efp_S| > |efp_L|
- ✅ szcenario_v03_hosszutav letezik
- ✅ alap hosszu tavu GDP plauzibilis (0.492%)
- ✅ KKV-tobblet minden szcenarioban (y_S > y_L)
- ✅ szcenario-sorrend: opt > alap > pessz
- ✅ t09 lekepezes letezik
- ✅ t09: 3 szcenario x 5 szegmens
- ✅ t09: minden szegmensben kamatCSOKKENES
- ✅ t21 jv_v05 hosszutav letezik
- ✅ v05 alap GDP plauzibilis (0.426%)
- ✅ v05 realarfolyam plauzibilis (0.8%) - unio-zaras OK
- ✅ v05: meret-aszimmetria minden szcenarioban (i_S > i_L)
- ✅ t22 v05-lekepezes letezik
- ✅ t22: 3 szcenario x 5 szegmens
- ✅ t22: a KKV hitelfelar-nyeresege > nagyvallalatie (modell-eredmeny)
- ✅ t34 jv_v06 hosszutav letezik
- ✅ v06 alap GDP plauzibilis (0.428%)
- ✅ v06: efp_S =/= efp_L a hosszu tavon (-1.01 bp) - a kozos-rk patologia megoldva
- ✅ v06: rk_S =/= rk_L (-0.25 pp) - szegmens-specifikus tokehozam
- ✅ v06 aggregalt GDP = v05 (0.428% vs 0.426%) - a termelesi atalakitas nem mozditotta el
- ✅ t35 v06 chi/psi dekompozicio letezik
- ✅ t35: mind a 7 eset konvergalt
- ✅ t35: a psi_i a steady state-et nem erinti (q=0) - Euler OK
- ✅ t35: chi forditasa MEGFORDITJA a szegmens-sorrendet
- ✅ t29 v07_access hosszutav letezik
- ✅ v07 alap GDP plauzibilis (0.764%)
- ✅ v07 replikacio: y_D=0.870% (kozolt 0.870), y_L=0.772% (kozolt 0.772)
- ✅ t33 v07 kuszob-osszefoglalo letezik
- ✅ t33 replikacio: a KKV>=L kuszob ~101 (a baseline 100 -- borotvael!)
- ✅ t39b calib-kuszob osszegzes letezik
- ✅ t39b: a CALIB=1 ag reprodukalja a kozolt kuszobet (101.0)
- ✅ t39b: JV-keszlettel a kuszob 100 ALATT (94.2) - a szektoralis sorrend megfordul
- ✅ t40 jv_3type stresszteszt letezik
- ✅ t40: mind a 18 kombinacio BK-stabil (2. lepcso ATMENT)
- ✅ t40: realarfolyam es NFA plauzibilis savban
- ✅ t40: a tipus-kibocsatas sorrendje a phi_j sorrendje (dokumentalt KORLAT, nem eredmeny)
- ✅ t41 jv_3type_arak stressz letezik
- ✅ t41: mind a 18 kombinacio BK-stabil (3. lepcso ATMENT - az arszint-szetvalasztas nem tori el a JV-magot)
- ✅ t41: relativar-normalizacio tart (max 6.9e-18) - v01 egyseggyok elkerulve
- ✅ t41: realarfolyam es NFA plauzibilis savban
- ✅ t42 eps_ces erzekenyseg letezik
- ✅ t42: az aggregalt GDP eps_ces-re ERZEKETLEN (sav 0.008 pp)
- ✅ t42: az y_E ELOJELE eps_ces-fuggo (dokumentalt KORLAT, kuszobforma kell)
- ✅ t43 fuggetlen ellenorzes letezik
- ✅ t43: mind a 17 fuggetlen ellenorzes atment
- ✅ t43 SZIMMETRIA: azonos parameterek -> azonos tipusok (max 4.4e-16)
- ✅ t43 NULLA-SOKK: sokk nelkul minden valtozo 0
- ✅ t44 jv_access stressz letezik
- ✅ t44: mind a 18 kombinacio BK-stabil (4. lepcso)
- ✅ t44: realarfolyam es NFA plauzibilis savban
- ✅ t45b jv_access kuszob letezik
- ✅ t45b NESTING: ACCSCALE=0 == v08 (elteres 0.0e+00)
- ✅ t45b: veges access-kuszob a JV-magon (ACCSCALE=36.3)
- ✅ t46 opten-kalibracio letezik
- ✅ t46: mind a 14 parameter megvan (14)
- ✅ t46: az om_j es az shl_j sulyok 1-re osszegzodnek
- ✅ t46: phi_L = 0.3649 megerositi az atvett 0.365-ot
- ✅ t46: delta = 0.0242 megerositi az atvett 0.0250-et
- ✅ t46: a lev_E = lev_D kenyszeritett egyenloseg NEM ALL (1.939 vs 1.719)
- ✅ t47 opten stressz letezik
- ✅ t47: mind a 36 kombinacio BK-stabil (az OPTEN=1 phi_D=0 is)
- ✅ t47 SZINT: az aggregalt GDP-sav az A01-ben kozolt +0,3...+2,9%-on belul (0.52% ... 2.89%)
- ✅ t47 REGRESSZIO: OPTEN=0 == t44 baseline (elteres 0.0e+00)
- ✅ t48b opten-kuszob letezik
- ✅ t48b: minden agon letezik veges kuszob
- ✅ t48b: a kuszob-sorrend D < sulyozott KKV < E minden agon
- ✅ t48b: az empirikus horgony LEVISZI a kuszobot (36.5 -> 22.3)
- ✅ t48b SZINT: a kuszobok az F01-ben kozolt szamokon (36.5 / 22.3)
- ✅ t49b rho_acc erzekenyseg letezik
- ✅ t49b: a kuszob MONOTON csokken a rho_acc-ban (47.8 -> 17.5)
- ✅ t49b: a GDP-hatas MONOTON no a rho_acc-ban
- ✅ t49b KORLAT: a horgonyzott rho_acc mellett a GDP-hatas TULMEGY a korabbi savon (1.75% > 1.04%)
- ✅ t37 access szegmens-evek letezik
- ✅ t37: az export-KKV hozzaferese 13x a hazaie (12.8x: 61.9% vs 4.8%)
- ✅ t37: a nagyvallalati hozzaferes ALACSONYABB az export-KKV-enal (43.5% < 61.9%)
- ✅ t37 PROGRAMVEZERELTSEG: a BUBOR 12.8 pontot mozgott, a hozzaferes legfeljebb 2.2-et
- ✅ t37: a hazai KKV hozzaferese NOTT a kamatcsucs fele (4.5% -> 5.1%)
- ✅ t50 bgg-blokk letezik
- ✅ t50: a tokeattetel-sorrend L > E > D (2.337 > 1.939 > 1.719)
- ✅ t50: mindharom lev az irodalmi k/n = 2 kornyeken (+-0.4)
- ✅ t50 SZINT: a lev_j ertekek az A07-ben kozolt szamokon (1.939 / 1.719 / 2.337)
- ✅ t50b chi-specifikaciok letezik
- ✅ t50b: a chi elojele atfordul a nevezo javitasaval (A: -0.01167 -> C: +0.00857) - a negativ eredmeny mutermek volt
- ✅ t00 SZERKEZET: mind a 4 modell-vonal megvan, README-vel
- ✅ t00 SZERKEZET: a FO MODELL a helyen van (1_fo_vonal_jv)
- ✅ t00 SZERKEZET: minden futtato letezo .mod-ot hiv (29 futtato, 19 modell)

</details>
