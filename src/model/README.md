# DSGE-modell (Dynare)

> ## ✅ 2026-08-12: A FŐ VONAL A `jv_dsge_v09_access` (Jakab–Világi mag)
> A JV-vonal négy lépcsőben utolérte és meghaladta az EAGLE-vonalat:
> `v06` (szegmens-tőkehozam) → `v07_3type` (három típus) →
> `v08_3type_arak` (típusonkénti ár) → **`v09_access`** (hozzáférési margó).
> Mind a négy lépcső **18/18 BK-stabil**, és lefutott a független
> verifikáció is (szimmetria 1e−16, aggregáció 1e−19, nulla-sokk pontosan 0,
> `ACCSCALE=0` → **pontosan** a v08). A `kkv_dsge_*` sor referencia-vonal.
> Részletek a gyökér `README.md`-ben és `docs/kalibracio_teendok_csapatnak.md`-ben.

## ⚠ ALAPCIKK-VÁLTÁS (2026-07-13): Jakab–Világi a fő vonal

Csapatdöntés szerint az alapmodell a **Jakab–Világi: An estimated DSGE
model of the Hungarian economy (MNB WP 2008/9)** — magyar adaton BECSÜLT
(Bayes-i) paraméterekkel —, nem az EAGLE-HU. A korábbi `kkv_dsge_v0x`
sor (EAGLE-alap) referencia/robusztussági vonalként marad meg.
A DSGE a projekt gerince és kötelező leadandó; a red flag-vizsgálat a
tanulmány KERETEZÉSÉT módosította, nem a DSGE szerepét.

> ## ⚠ 2026-08-12: az `s_kkv` / `t24` IO-mérés NEM használható
> A `t24_io_hazai_input.csv` (és vele az `s_kkv = 0,05`, a „42% → 4,4%"
> link-korrekció, és a „duális gazdaság: autóipar 6% hazai köztes input"
> eredmény) **hibás mérésen áll**: a döntő azonosság-teszt szerint az
> összegzett köztes felhasználás a nemzeti számlák P2-jének csak **1,8–8,6%-a**.
> A gyökérok még nyitott, és **az sem tudjuk, melyik irányba téves**.
> Részletek és teendők: `docs/FIGYELMEZTETES_io_tabla_gyanus.md`.
> **Amit nem érint:** az aggregált GDP-hatás (robusztus a link ki-be
> kapcsolására), és a `v06_3type`/`v07_access` vonal (nem használ `s_kkv`-t).

### EAGLE-vonal, ÚJ háromtípusos ág (Samu, 2026-08-10; átvéve 2026-08-12):

- **`kkv_dsge_v07_access.mod`** — a 3type váz + **hitelhozzáférési (extenzív)
  margó** a KKV-knál: `acc_j = rho_acc·acc_j(-1) − lambda_acc_j·efp_j`, és a
  jobb hozzáférés extra beruházási keresletet enged be a Tobin-Q-n keresztül.
  A nagyvállalatnak **nincs** access-margója (`acc_L` nem létezik) — ez a
  feltevés viszi a szektorális átfordulást. 64 egyenlet, BK teljesül.
  Futtatás: `run_v07_access`, `run_v07_access_tscen_sens`,
  `run_v07_access_scale_sens`, `run_v07_access_threshold` →
  `t29`–`t33`, `f24`. **Replikálva (2026-08-12): minden közölt szám
  pontosan kijött** (alap: y +0,764% / E +0,525% / D +0,870% / L +0,772%;
  küszöbök: D≥L 93,6 · KKV≥L **101,0** · E≥L 118,3).
  **⚠ BOROTVAÉL:** a küszöb 101,0, az alapkalibráció 100 — a súlyozott
  KKV-blokk a baseline-on még **−0,015 pp-tal az L alatt van**. A `D`
  szegmens önmagában viszont megelőzi (küszöbe 93,6). Füstteszt-őr rögzíti.
  Az `ACCSCALE` **magyar adatból nem horgonyozható** (lásd
  `docs/2026-08-12_access_horgonyzas_eredmeny.md`) → küszöbként közölni.

- **`kkv_dsge_v06_3type.mod`** — az első explicit háromtípusos váz:
  `E` = export-orientált KKV, `D` = hazai orientációjú KKV, `L` = aggregált
  nagyvállalat. **Szándékosan nem a `jv_dsge_v05.mod` átírása:** a JV-vonalban
  a méretdimenzió és a hazai/export dimenzió összecsúszik, itt viszont
  típusonként külön termelés, ár, tőke, beruházás, nettó vagyon és BGG-lite
  felárblokk van — és a szektorok **külön `x_E`/`x_D`/`x_L` exportkeresletet**
  kapnak, nem közös shiftert. 62 egyenlet, BK teljesül.
  Futtatás: `run_v06_3type`, `run_v06_3type_tscen_sens` → `t27`, `t28`, `f23`.
  **Replikálva (2026-08-12):** semleges transzmisszió mellett a nagyvállalat
  egyértelműen nyer (y_L +1,143% vs. E +0,047% / D +0,144%) — vagyis a
  KKV-előny **nem** a szerkezetből jön. Ez a `v07_access` diagnosztikai
  baseline-ja; azonos számokat ad, mint a `v07_access` `ACCSCALE=0`-nál.

- **`jv_dsge_v06_stoch.mod`** — a v05 **sztochasztikus ikerfájlja** (Samu,
  2026-08-05): az `uni` fordítási idejű makró (`-DUNI=0|1`), így mindkét
  rezsim külön lineáris modell, amin megy a `stoch_simul`. Célja a
  **stabilizációs költség** mérése (OCA-kérdés: mennyit ér az önálló
  monetáris politika elvesztése) — ez a v05-ből elvileg sem jöhet ki, mert
  ott az `uni` endogén változókkal szorzódik. A fájl fejléce két kötelező
  ellenőrzést ír elő: (1) **közös zárás** mindkét rezsimben (`nu_fx`), mert
  eltérő `nu` mellett a mért volatilitás-különbség a záró eszköz műterméke
  lenne; (2) **`check;` előbb**, mert az `UNI=1` ágon nincs Taylor-szabály,
  tehát nominális határozatlanság kockázata áll fenn.
  ⚠ **Futtató még nincs hozzá**, és a JV-vonalon a „v06" szám foglalt
  (`jv_dsge_v06.mod`) — a névtér tisztázása csapatdöntés.

### JV-vonal (fő):

- **`jv_dsge_v09_access.mod`** — 🟢 **A FŐ MODELL.** Háromtípusos JV-mag +
  **hitelhozzáférési (extenzív) margó**. Ezzel a JV-vonal mindent tud, amit
  a `kkv_dsge_v07_access`, de becsült paramétereken és gazdagabb termelési
  oldalon. **A fordítás nem másolás volt:** az EAGLE-ben az `acc` a
  Tobin-Q-n át hat (`q = phi_i·(i − k − ω·acc)`), a JV-ben viszont a
  beruházás kiigazítási-költséges **Euler-egyenletből** jön — ezért az `acc`
  additív forcing tagként lép be oda. **Következmény: az `ACCSCALE` skálája
  a két magon NEM összevethető.** Futtatás: `stress_jv_access_v09` →
  `t44`, `t45`, `t45b`. **Eredmény:** BK 18/18 · nesting `ACCSCALE=0` →
  **pontosan** a v08 (0,0e+00) · előjel helyes · küszöbök a JV-magon:
  `y_D≥y_L` **22,6** · súlyozott KKV **36,3** · `y_E≥y_L` **61,9**.

- **`-DOPTEN` / `-DRHOACC` a `jv_dsge_v09_access.mod`-ban** (2026-08-16) —
  nem új modellverzió, hanem a fő modell **empirikus horgonyzása**: a
  `docs/kalibracio_teendok_csapatnak.md` 1. prioritása lefutott. A 14
  „átvett induló" típus-paraméter (`om_j`, `shl_j`, `phi_j`, `lev_j`,
  `delta`, `rho_acc`) most az **Opten-panelből** (148 225 cég-év, 37 805 cég,
  2021–2024, 10+ fő) van kiszámolva. Futtatás: `s15_opten_kalibracio` →
  `t46`, `t46b`, `t46c`; `stress_opten_v09` → `t47`, `t48`, `t48b`, `t49`,
  `t49b`. **Felülírás helyett makró-kapcsoló**, a repo szabálya szerint:
  `-DOPTEN=0` (átvett induló, **alapértelmezés**) · `1` (Opten, ALAP
  szegmensdefiníció) · `2` (Opten, `export_arany ≥ 25%`) · `3` (**csak** a
  `rho_acc` horgony — dekompozíciós ág) · `-DRHOACC=<x>` (közvetlen scan).
  - **Amit az adat megerősít:** `phi_L` = 0,3649 vs. az átvett 0,365 és
    `delta` = 0,0242 vs. 0,0250 — vagyis ez a két érték **már ebből a
    panelből származhatott**, független próbán kijön.
  - **Amit az adat megcáfol:** a `lev_E = lev_D = 1,6` **kényszerített
    egyenlőség nem áll** — 1,939 vs. 1,719, azaz az exportáló KKV
    tőkeáttételesebb. Az irányt a másik mérték (kötelezettségek/eszközök →
    1,684 vs. 1,579) is megerősíti, a **szint viszont mérőfüggő**, ezért
    csak az irányra szabad hivatkozni. Ez volt a teendőlista nevesített
    részfeladata.
  - **A legnagyobb hatású tétel:** `rho_acc` = **0,9673** (van_hitel
    átmenet-mátrix, kétállapotú Markov, ρ_éves = p11 − p01 = 0,8754,
    n = 110 350 cég-év pár) a korábbi 0,85 helyett. A hosszú távú
    access-szorzó `1/(1−ρ)` révén **6,7× → 30,6×**, és ettől a küszöb a
    súlyozott KKV-blokkra **36,5 → 22,3** (csak a `rho_acc`-tól: 17,0).
  - ⚠ **A korábbi „+0,27…+1,04% robusztus GDP-sáv" a horgonyzott `rho_acc`
    mellett NEM tartható:** `-DOPTEN=1` mellett +0,76…+2,03%, `-DOPTEN=3`
    mellett +0,92…+2,89%. Füstteszt-őr rögzíti, hogy ez tudatos.
  - ⚠ **Az `om_j`/`shl_j` súlyok NEM cserélhetők le vita nélkül:** a panel
    a 10+ fős kört fedi, a mikrocégek hiányoznak, tehát ezek a 10+
    populáción *belüli* részesedések (`shl_L` 0,466 vs. a jelenlegi 0,30 —
    a különbség jórészt a hiányzó mikrokör). KSH/Eurostat SBS méret-bontás
    kell hozzá; addig az alapértelmezés marad `-DOPTEN=0`.
  - **BK-tanulság:** `-DOPTEN=1` mellett `phi_D = 0` **pontosan** (a D
    szegmens épp a nem-exportáló cégeké), így `wx_D = 0`. Ez **nem** töri el
    a modellt — az `x_D`-t a saját exportkereslet-egyenlete továbbra is
    meghatározza, csak az aggregátumokba nem számít bele. 36/36 BK-stabil.
  - **Kódtakarítás:** a `-DSYM=1` ág `shl_* = 1/3` sora **holt kód** volt
    (egy későbbi sor felülírta). Az eredményt nem érintette (a három súly
    összege mindkét esetben 1, szimmetriában `l_E==l_D==l_L`), de az
    értékadás felkerült a típus-súlyokhoz. Regressziós őr: `-DOPTEN=0` a
    `t44` tárolt eredményét bitre adja (eltérés 0,0e+00).
  - *Notion döntésnapló-hivatkozás még jár ehhez* (ebben a munkamenetben
    nem volt Notion-hozzáférés).

- **`jv_dsge_v08_3type_arak.mod`** — 3. lépcső: **típusonkénti ár és
  kereslet**, ez oldja fel a v07_3type mechanikus-kibocsátás korlátját.
  A **v01-es egységgyök-csapdát** (*„a relatívár-identitások naiv felírása
  egységgyököt hagy"*) a súlyozott relatívár-összeg explicit nullára kötése
  kerüli ki. **Eredmény:** BK 18/18 — tehát a v04-es kudarc **nem volt
  elkerülhetetlen**, ott a *kombináció* volt a baj; a korlát feloldva
  (0,4455 pp eltérés a mechanikus jóslattól).
  ⚠ **Új horgonyzatlan paraméter:** `eps_ces` (a JV-ben nincs ilyen), és az
  `y_E` **előjele ezen fordul** ~2,3-nál. Az aggregált GDP érzéketlen rá
  (0,008 pp sáv).

- **`jv_dsge_v07_3type.mod`** — 2. lépcső: **három típus** (E/D/L) a
  JV-magon, közös árszinttel. Minden típus mindkét piacon értékesít, tehát
  a méret/piac szétválasztás követelménye már itt teljesül. BK 18/18.
  ⚠ **Dokumentált korlát:** közös ár mellett a típus-kibocsátás
  **mechanikus** (`y_j = (1−phi_j)·y_d + phi_j·y_x`, bitre) — szegmens-szintű
  kibocsátást ebből a lépcsőből **nem szabad közölni**. Ugyanaz a hibatípus,
  mint a v05-ben a „szegmens-tőke reallokációs maradék".

- **Független verifikáció** (`ellenorzes_3type.m` → `t43`): a BK-teszten túl
  **17 azonosság-ellenőrzés**, mind átment — szimmetria (1e−16), aggregációs
  azonosságok (1e−19), nulla-sokk kontroll (`-DSCENARIO=4`, pontosan 0),
  egymásba ágyazás (`eps_ces`→0 monoton). Ezek olyan hibát fognak el
  (elgépelt index, felcserélt súly), amit a BK-teszt nem.


- **`jv_dsge_v06.mod`** — ⚠ **ÁTCÍMKÉZVE (2026-08-11):** a v05 **BELSŐ
  javítása**, NEM a méret/piac szétválasztása. Eredetileg "a termelési
  oldal szegmentálása" néven készült, de a fix úgy működik, hogy
  **azonosítja** a hazai/export (d/x) felbontást a KKV/nagyvállalat (S/L)
  felbontással — márpedig **pontosan ez az összecsúsztatás a szerkezeti
  alapprobléma**. A `jv_v05_szerkezeti_tanulsagok` jegyzet (Samu; lokális
  repo, GitHubra nem volt feltöltve, ezért nem ismertük) explicit kimondja:
  *„nem ez lenne a leképezés: KKV = hazai, nagyvállalat = export — hanem
  ez: KKV: hazai + export értékesítés, nagyvállalat: hazai + export
  értékesítés"*. Ebben a fájlban tehát minden „méret"-eredmény valójában
  „piaci orientáció"-eredmény; az összecsúsztatás nem szűnt meg, csak
  implicitből **strukturálissá** vált. **A helyes irány:**
  a JV-vonal háromtípusos ága (`jv_dsge_v07_3type` → `v08_3type_arak` →
  `v09_access`), lásd lentebb. *(Ez eredetileg a `kkv_dsge_v06_3type`/
  `v07_access`-re mutatott — akkor az volt az egyetlen helyes
  architektúra; 2026-08-12 óta a JV-magon is megvan.)*
  *Amit viszont valóban megold és megmarad:* a szegmens-tőke nem
  reallokációs maradék többé, megszűnik a „közös rk ⇒ efp_S ≡ efp_L"
  patológia, és az aggregált GDP nem mozdul (+0,426% → +0,428%).
  **⊕ ÉS AMIT AZ ELSŐ ÁTCÍMKÉZÉS ALÁBECSÜLT (2026-08-12):** a v07-specifikáció
  (Samu, 2026-08-05, 6.3 szakasz) nyitva hagyott egy tételt — *„Analitikus
  sejtés (ellenőrizendő): ez… nagyrészt a KÖZÖS `rk` következménye"* —, és
  **ez a fájl pontosan azt a sejtést igazolta**: `rk_S`/`rk_L` mellett
  `efp_S ≠ efp_L` már steady state-ben is (−1,01 bp), 18/18 kombinációban
  stabilan. A v06 tehát nem puszta karbantartás, hanem egy nyitott
  analitikus sejtés kísérleti eldöntése. Lásd
  `docs/2026-08-12_zip_osszevetes_hibanaploval.md`.
  *(Az alábbi eredeti leírás ezzel a korlátozással olvasandó.)*
  A v01–v05-ben a KKV/nagyvállalat szétválasztás
  **kizárólag a pénzügyi blokkban élt** (chi, efp, k_S/L a BGG-ben); a
  termelés a hazai/export (d/x) felbontást használta, ami **független volt
  a szegmenstől**. Bizonyíték a v05-ből, szó szerint: `k = om_S*k_S +
  (1-om_S)*k_L` (om_S=0.50) **VS** `k(-1) = sh_kd*(...) + (1-sh_kd)*(...)`
  (sh_kd=0.65) — két különböző szám ugyanarra a felosztásra, és semmi nem
  kötötte össze őket. Fix: (1) közös `rk` → `rk_S`/`rk_L`; (2) d/x
  átnevezés S/L-re (azonos Cobb–Douglas-paraméterek); (3) a régi,
  sh_kd-súlyozott aggregált tőkepiaci azonosítás **törölve**, helyette
  `k_S(-1) = z_S - ...` és `k_L(-1) = z_L - ...` — a BGG-ben felhalmozott
  szegmens-tőke **közvetlenül a saját termelését hajtja**; (4) `sh_kd`
  paraméter törölve, `om_S` az egyetlen partíciós súly. Futtatás:
  `check_v06_ss`, `stress_v06`.
  **Eredmény:** a v05 két dokumentált patológiája EGYSZERRE oldódott meg —
  ugyanaz volt a gyökerük. (a) a szegmens-tőke **többé nem reallokációs
  maradék**; (b) `efp_S ≠ efp_L` **már steady state-ben is** (TSCEN=3:
  0.0247 pp, `rk_S`=−0.84% vs `rk_L`=−1.46% valódi eltéréséből), tehát
  megszűnt a "közös rk ⇒ nincs hosszú távú szegmens-prémium-differencia"
  probléma. Aggregált GDP a v05-tel azonos nagyságrendben (TSCEN=1:
  +0.428% vs. v05 +0.426%; szcenárió-sáv +0.275%…+0.581%) — az átalakítás
  tehát **nem mozdította el az aggregált eredményt**, csak a szegmens-
  szintű állítások alapját tette legitimmé.
  **BK-tanulság — a v04-es lecke PONTOSÍTÁSA (fontos, újrahasznosítható):**
  a v04 fejléce azt rögzítette, hogy „a szektor-specifikus tőke (külön
  rk_S/rk_L) + CPI-szétválasztás megbontotta a Blanchard–Kahn feltételt".
  A v06 megmutatja, hogy **nem a szegmens-specifikus tőkehozam volt a
  hibás, hanem a KOMBINÁCIÓ a CPI/árszint-szétválasztással**: `rk_S`/`rk_L`
  önmagában, változatlan `px`/CPI-blokk mellett, **18 kombinációban
  (3 SCENARIO × 3 TSCEN × 2 NOVERT) mind konvergál, BK sehol nem sérül**
  (`stress_v06.m`). A jövőbeli bővítéseknél tehát a tiltás nem a szektor-
  specifikus tőkére, hanem az egyszerre végzett árszint-szétválasztásra áll.
  **Nyitott, mielőtt eredménynek számít:** teljes euró-szcenárió tábla
  (t21-ekvivalens) v06-ra; dedikált füstteszt; és a `psi_i_S=8 < psi_i_L=13`
  dokumentálatlan/torzító kalibráció újragondolása — ennek most már
  **valódi termelési hatása** van, nem csak pénzügyi maradéka.

- **`jv_dsge_v05.mod`** — szegmentált euró-szcenárió: a v04 vertikális
  szegmentálása RÁFUTTATVA a v03 valós euró-belépési pályájára (UIP-
  országprémium + kamatunió-rezsimváltás + 3 anticipált forgatókönyv,
  perfect foresight). Futtatás: `run_jv_v05` → `t21`, `s13_szegmens_
  lekepezes_v05` → `t22`, ábrák `f20`/`f21`. Érzékenység: `sens_skkv_v05`,
  `sens_tsuly_v05`, `diag_nuuni_v05`.
  **Három kalibrációs javítás, mindegyik lefelé:** (1) `nu_uni` 0.01→0.25
  (a v03-ból örökölt zárás a vertikális link önerősítő köre mellett túl
  gyenge horgony volt: export +12.9%, rer +34.7% — implauzibilis; a 0.25 a
  plató elején van, tehát az eredmény nem érzékeny a pontos értékre);
  (2) `shd_v` mostantól **`s_kkv`-ból származtatott** (a független megadás
  ugyanazt a kereskedelmi kapcsolatot írta le két oldalról, és az
  alapkalibrációnál a KKV-kibocsátás 115%-át adta az export-input tag);
  (3) **`s_kkv` 0.20→0.05 az Eurostat IO-táblából** (`t24`) — a korábbi
  érték **4-szeresen túlkalibrált** volt, és a modell 0.25-nél lévő
  pólusának vonzásában állt.
  **Eredmények:** hosszú távú GDP alap **+0.426%** (opt +0.578 / pessz
  +0.274); felár alap KKV −37.2 bp vs. nagyvállalat −24.7 bp. A vertikális
  link hozzájárulása **4.4%** (+0.407% link nélkül → +0.426%) — **nem a
  korábban közölt 42%**, az a túlkalibrált s_kkv-val készült. Ez maga is
  eredmény: a magyar FDI-vezérelt exportszektor hazai beszállítói
  integrációja gyenge (autóipar 6.0%, elektronika 4.2% hazai köztes input)
  — a "duális gazdaság" kvantifikálása.
  **⚠ Három strukturális figyelmeztetés (2026-08-i felülvizsgálat, a .mod
  fejlécében részletesen):** (A) a szegmens-tőke **reallokációs maradék**
  (az aggregált beruházás 1.09–1.29% között mozog, a szegmens-rés
  +0.53→−5.80 pp-ot ugrál) ⇒ **szegmens-szintű beruházást ebből a modellből
  nem szabad közölni**; (B) `∂i_ss/∂F = −1/chi`, azaz 1/chi_S=16.7 vs.
  1/chi_L=50 ⇒ a **chi_S>chi_L aszimmetria a hosszú távon a KKV ELLEN
  dolgozik**, és steady state-ben `efp_S ≡ efp_L` (közös rk miatt);
  (C) a modell **exaktul lineáris** a tsov/tbank paraméterekben, ezért a
  TSCEN=3 a TSCEN=1 és 2 exakt átlaga (1e-15) — **nem önálló teszt**.
  Az (A) és (B) pont gyökere ugyanaz, és a **v06 mindkettőt megoldja**.
  Emellett a `t_S > t_L` feltevés **nem azonosítható** az adatból (a becsült
  arány 0.26–2.75 között szóródik, semmi sem szignifikáns) — lásd
  `docs/FIGYELMEZTETES_fo_allitas.md` és `docs/2026-08-02_hibafeltaras_
  naplo.html`.

- **`jv_dsge_v04.mod`** — KÖZGAZDASÁGILAG TARTALMAS KKV/nagyvállalat
  szegmentálás (csapatdöntés 2026-07): **KKV=hazai szektor** (magas EFP,
  rugalmas), **nagyvállalat=export szektor** (alacsony EFP, merev), és a
  fő újítás a **VERTIKÁLIS beszállítói link** — a KKV kibocsátása input
  az exportőrnek (költség-oldal: mcx tartalmazza s_kkv·mc_d-t; mennyiség-
  oldal: h_dx a KKV-keresletben). Így az euró-hitelsokk pozitív összegű:
  a KKV egészsége az exportőrt is segíti, nem "a gyengébb meghal".
  Futtatás: `run_jv_v04` → `t20`, `src/06_jv_v04_abra.py` → `f19`.
  Eredmény: BK teljesül; a lánc együtt mozog (monetáris lazításra export,
  h_dx és KKV együtt +), és a méret-aszimmetria él (KKV-beruházás 2,9% vs
  nagyvállalati 2,1%). **BK-tanulság (dokumentálva a .mod-ban):** a
  szektor-specifikus tőke (külön rk_S/rk_L) + CPI-szétválasztásos első
  változat MEGBONTOTTA a Blanchard–Kahn feltételt; a robusztus verzió a
  v02 közös-rk szerkezetére épít, a KKV-input árát a KKV határköltsége
  (mc_d) adja. **→ PONTOSÍTVA a v06-ban (2026-08): nem az `rk_S`/`rk_L`
  volt a hibás, hanem a KOMBINÁCIÓ a CPI-szétválasztással** — a
  szegmens-specifikus tőkehozam önmagában, változatlan CPI-blokk mellett
  18 kombinációban stabil. Lásd a v06 bejegyzést.
  Kalibráció (2-es döntés): s_kkv=0.20, mu_vert=0.50,
  psi_i_S=8/psi_i_L=13 IRODALMI/ÉRZÉKENYSÉGI induló — a pontos KKV-input
  arány a KSH IO-táblából pótolandó. **→ s_kkv PÓTOLVA a v05-ben** (IO-adat,
  `t24`): a valós érték 0.05, a 0.20 négyszeres túlkalibrálás volt.
  A `psi_i_S=8 < psi_i_L=13` viszont **továbbra is dokumentálatlan és a
  KKV-előny irányába torzít** — a v06 után ez sürgetőbb, mert már valódi
  termelési hatása van.

- **`jv_dsge_v01.mod`** — a JV log-linearizált magja (Appendix A.4–A.9)
  az IT-rezsim poszterior-átlag paramétereivel: hazai+export szektor
  munka+import kompozit inputtal, 25% kézről-szájra háztartás (survey-
  alapú!), hibrid ár/exportár/BÉR Phillips-görbék indexálással, Tobin-Q
  (Φ″=13), UIP (becsült ν=0.001), Taylor (0.761/1.379). Egyszerűsítések
  a fájl fejlécében (nincs csúszó-leértékelés blokk, nincs adaptív
  tanulás, "KOZELITES"-sel jelölt SS-arányok). Fut, BK rendben.
- **`jv_dsge_v02.mod`** — + kétszektoros (KKV/nagyvállalat) BGG-blokk a
  FINANSZÍROZÁSI oldalon (a JV termelési szerkezete érintetlen):
  k = om_S·k_S + (1−om_S)·k_L, típusonkénti Tobin-Q, nettó vagyon, EFP
  (chi_S=0.06 > chi_L=0.02; lev az Opten-panelből). Monetáris sokkra a
  KKV-beruházási válasz ~1,5×, EFP-aszimmetria 2,4× — az akcelerátor a
  JV-magon is él.
- **`jv_dsge_v03.mod`** — euró-szcenárió (run_jv_v03): prémium-pályák +
  zsov=0.5 UIP-csatorna + kamatunió-rezsimváltás. **Eredmény (alap):
  hosszú táv +1,09% GDP** (opt +1,41 / pessz +0,78), 10 év +0,44%,
  bejelentési dip −0,99%. Fontos zárási tanulság: az unió-ágon a JV
  apró becsült ν-je helyett külön technikai horgony kell (nu_uni=0.01),
  különben bstar −250%-nál állna be (a fájlban dokumentálva).

A JV-vonal az EAGLE-vonalnál **magasabb tartós hatást, gyorsabb
felépülést és mélyebb bejelentési visszaesést** ad (f18 összevetés) —
a becsült magyar paraméterek (lapos ár-NKPC, becsült UIP-dinamika,
import-intenzív exportszektor) élesebb dinamikát hordoznak.

## EAGLE-vonal (referencia): v0.1 → v0.5 (Calvo-bérek)

## v0.5 — `kkv_dsge_v05.mod`: Calvo-bérek (EHL bér-Phillips-görbe)

A v0.4 + ragadós bérek: θw = 0.75 (EAGLE; Kézdi–Kónya WDN: a cégek
~évente igazítanak alapbért), CPI-indexálás 0.75, bér-markup elaszticitás
4.33. Érzékenység: `-DTHETAW=60|75|85`. Futtatás: `run_v05` →
`t18_v05_berragadossag.csv`, `f17`.

**Eredmény — robusztussági "null-eredmény", és ez jó hír:** az euró-
belépési pálya gyakorlatilag érzéketlen a bér-ragadósságra (hosszú táv
azonos +0,725%; dip −0,373…−0,383% vs. rugalmas −0,38%). Ok: a szcenárió
lassú, anticipált, fokozatos — a bér-NKPC-nek van ideje alkalmazkodni,
és az ár-ragadósság (Calvo 0,92) amúgy is dominálja a nominális
súrlódásokat. **A bérrugalmasság igazi tétje nem a belépési pálya, hanem
a belépés UTÁNI aszimmetrikus sokk-elnyelés** (önálló monetáris politika
nélkül a bér az alkalmazkodási eszköz — klasszikus OCA-kérdés): ennek
vizsgálata a v0.6 feladata (sztochasztikus szimuláció az unió-rezsimben,
θw-érzékenységgel). Mikro-evidencia a kalibrációhoz: Kézdi–Kónya (MNB OP
103), Kátay (MNB WP 2011/9), saját panel-lenyomat: t17.

## v0.4 — `kkv_dsge_v04.mod`: rezsimváltás + nem-Ricardiánus háztartások

## v0.4 — `kkv_dsge_v04.mod`: rezsimváltás + nem-Ricardiánus háztartások

Két bővítés a v0.3-hoz képest (futtatás: `run_v04`, kimenet:
`t16_v04_osszevetes.csv`, ábra: `f16`):

1. **Kamatunió-rezsimváltás a belépéskor (q13)**: az `uni` determinisztikus
   dummy kapcsolja a monetáris blokkot — előtte Taylor + UIP, utána
   r = euró-kamat (+ kis NFA-rugalmas felár) és dep = 0. A dummy-szorzatok
   miatt a modell formálisan nemlineáris; perfect foresight oldja meg.
2. **Nem-Ricardiánus háztartások** (om_nr = 0.75, az EAGLE HU-értéke;
   `-DOMNR=0|75` kapcsoló): c_N = w + nn, a Ricardiánus ág viszi az
   Euler-egyenletet — ez oldja a v0.3-ban dokumentált Euler-rögzítést.

**Eredmények (alappálya, hosszú távú GDP):** v0.3 +0,49% → csak unió
+0,54% → **unió + 75% NR: +0,73%**. A rezsimváltás önmagában keveset
változtat; a nem-Ricardiánus blokk viszont (a) másfélszeresére emeli a
tartós hatást (a hozamgörbe-csatorna végre aggregáltan is él), és (b)
**mélyíti a belépés előtti visszaesést** (−0,38%): a likviditáskorlátos
háztartások fogyasztása a folyó jövedelmet követi, az ERM-II szakasz
fájdalmasabb. Szakpolitikai olvasat: az átmenet kezelése (kommunikáció,
programok időzítése) a nem-Ricardiánus népességarány miatt még fontosabb.

Nyitott (v0.5): Calvo-bérek (a 75%-os NR-arány bér-ragadóssággal áll
igazán stabilan); a szcenárió-készlet (opt/pessz) átfuttatása v0.4-en.

## v0.1–v0.3 (korábbi verziók)

## v0.3 — `kkv_dsge_v03.mod`: WP 2017/7 kalibráció + UIP-országprémium

Két változás a v0.2-höz képest (futtatás: `run_v03`, kimenet:
`szcenario_v03.csv` + `szcenario_v03_hosszutav.csv`, ábra:
`src/05_szcenario_abrak_v03.py`):

1. **Kalibráció a WP 2017/7 appendix HU oszlopából**: β=0.99, σ=0.4,
   α=0.30, Calvo-ár 0.92 → κ≈0.01, beruh. kiig. 6.0, Taylor 0.87/1.70/0.10,
   C/Y 0.61, I/Y 0.19, G/Y 0.20, X/Y=M/Y 0.75. A pénzügyi blokk (chi, lev)
   továbbra is az Opten-panelből.
2. **UIP-országprémium csatorna**: a szuverén konvergencia zsov=0.5 súllyal
   az UIP-be is belép. Dekompozíció: UIP = kockázatmentes görbe / árfolyam-
   és NFA-dinamika; EFP = vállalati hitelfelár (tsov/tbank, változatlan).

**Fő eredmények (alappálya):** hosszú távú GDP-szint **+0,49%**
(optimista +0,67%, pesszimista +0,32%), KKV-kibocsátás +0,56% vs.
nagyvállalati +0,41% — a KKV-többlet tartós. A felépülés lassú (10 évnél
+0,11%, 30 évnél +0,25%): a szűk keresztmetszet a tőkefelhalmozás
sebessége (WP-beli beruházási kiigazítási költség 6.0).

**Az akcelerátor két arca (s10 ki/be teszt, f13):** a méretfüggő
akcelerátor a monetáris sokkot a nettóvagyon-csatornán ERŐSÍTI (a
KKV-beruházási válasz ~2,4-szeres a χ=0-hoz képest — klasszikus BGG),
az exogén prémium-sokkokat viszont részben TOMPÍTJA: a fellendülésben a
cégek eladósodnak (q+k gyorsabban nő, mint nw), és a prémium endogén
módon visszapattan. Ez magyarázza a szcenáriók mérsékelt hosszú távú
hatását is, és a tanulmányban mindkét irányt együtt kell kommunikálni.

**Két strukturális tanulság:**
- A reprezentatív háztartás Euler-egyenlete hosszú távon βhoz köti a
  belföldi reálkamatot, ezért az UIP-prémium csökkenése főleg az
  NFA/árfolyam-oldalt mozgatja — a tartós kibocsátási hatást az
  EFP-ék (tőkeköltség-csatorna) adja. A vázlatbeli 1,5–2% a kereskedelmi/
  tranzakciós csatornákat és az extenzív margót is tartalmazza, amelyek
  tudatosan nem ebben a rétegben élnek.
- A belépés előtti szakaszban átmeneti kibocsátás-visszaesés jelenik meg
  (~−0,2%): az anticipált konvergencia reálfelértékelődése fékezi az
  exportot, mielőtt a beruházási csatorna beindul — a klasszikus
  konvergenciás felértékelődési dilemma, endogén módon.

## v0.2 — `kkv_dsge_v02.mod`: euró-belépési szcenárió

A v0.1 modellmag változatlan egyenletekkel, de a sov/bank prémium itt
**exogén determinisztikus pálya** (anticipált, permanens csökkenés),
perfect foresight szimulációval. Három szcenárió (`-DSCENARIO=1|2|3`):
alap (−200 bp szuverén, −45 bp banki, 60% transzmisszió), optimista
(−250/−60/70%), pesszimista (−150/−30/40%). Időzítés: bejelentés q1,
belépés q13, normalizálódás q16-ig. Futtatás:

```
matlab -batch "cd('src/model'); run_v02"
```

Kimenet: `output/tables/szcenario_v02.csv`, ábra: `src/04_szcenario_abrak.py`.

**Fontos kalibrációs tanulság (v0.2):** a 10 éves GDP-hatás így
+0,08–0,17% — nagyságrenddel kisebb a vázlatban várt 1,5–2%-nál. Az ok:
a v0.1/v0.2-ben a szuverén prémium **csak a vállalati EFP-n** keresztül
hat (25%-os transzmisszióval), miközben a vázlat logikájában a szuverén
konvergencia az egész gazdaság kockázatmentes hozamgörbéjét is lehúzza
(UIP-országprémium, háztartási és állami finanszírozás). Ennek a
csatornának a beépítése (sov → UIP-prémium) a v0.3 fő feladata — várhatóan
ez adja az aggregált hatás nagyját, míg a KKV/nagyvállalat aszimmetriát
továbbra is az EFP-csatorna hordozza.

## v0.1 — `kkv_dsge_v01.mod`: futó váz

`kkv_dsge_v01.mod`: kétszektoros (KKV / nagyvállalat) kis nyitott gazdaság
új-keynesi modell, szektoronként eltérő (méretfüggő) BGG-típusú pénzügyi
akcelerátorral. A két hitelköltség-csatorna (szuverén prémium, banki
forrásköltség) exogén EFP-sokként lép be — a modellválasztási döntés
szerint (Notion döntésnapló 2026-07-06; `docs/modell_vazlat/`).

Log-linearizált; Dynare 6.5 + MATLAB alatt fut, Blanchard–Kahn teljesül,
elméleti momentumok stacionáriusak.

## Futtatás

```
matlab -batch "cd('src/model'); run_v01"
```

(Dynare útvonal: `DYNARE_PATH` env változó, alapértelmezés `C:\dynare\6.5\matlab`.)
A futás az `output/tables/irf_v01.csv`-be exportálja az IRF-eket; az ábrát a
`src/03_irf_abrak.py` készíti belőle.

## Mi van benne / mi nincs (v0.1)

| Benne | Nincs benne (következő verziók) |
|---|---|
| kétszektoros mag, CES-aggregálás szektor-relatívárakkal | Calvo-bérek (EAGLE-ben van) |
| BGG-lite akcelerátor: EFP, Tobin-q, nettó vagyon szektoronként | teljes EAGLE kereskedelmi mátrix (EA/US/RW) |
| szuverén + banki forrásköltség sokk transzmissziós súlyokkal | import-árazási ragadósság (LCP) |
| SOE-zárás: UIP adósság-rugalmas prémiummal | részletes fiskális blokk |
| Taylor-szabály | euró-belépés rezsimváltása (kamatunió) — v0.2 determinisztikus szcenárió |

## Kalibráció fő forrásai

- Békési–Kaszab–Szentmihályi (MNB WP 2017/7) appendix-táblák
- Opten-panel: tőkeáttétel medián → lev_S=1.6, lev_L=1.85; EFP-szintek
- pitch (2026-07-06): sokk-transzmissziós súlyok (szuverén ~25%, banki ~60% a KKV-ra)
- Jakab–Világi (2008): habit, ár-ragadósság nagyságrendek

## Ismert továbbfejlesztési pontok

1. Euró-szcenárió determinisztikus szimulációként (150–250 bp szuverén +
   30–60 bp banki prémium-csökkenés, anticipációval) — v0.2 fő feladata.
2. A nettó vagyon egyenlet BGG-lite közelítés — teljes BGG-linearizáció
   ellenőrzendő az appendix alapján.
3. Kalibráció finomítása a WP 2017/7 táblákból (most nagyságrendi értékek).
4. A 2. réteg (szegmens-leképezés) kötése az IRF-kimenethez.
