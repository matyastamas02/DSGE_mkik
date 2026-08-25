# A főmodell paraméterei — független modellből történő audit

*Dátum: 2026-08-25 · elsődleges forrás: `src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod`*

## Rövid válasz

A főmodell `parameters ... ;` blokkja **91 egyedi paramétert** deklarál.
Mind a 91 kap numerikus értéket, tehát olyan nincs, hogy a modellben egy
paraméter „üres”. Ettől azonban még nem mindegyik empirikusan azonosított:

| Bizonyítéki státusz | db | Mit jelent? |
|---|---:|---|
| Saját adatból erősen horgonyzott | 5 | `delta`, `phi_L`, `lev_E/D/L`; az empirikus érték nem minden esetben az alapértelmezett ág aktív értéke |
| Saját adatból feltételes | 8 | `om_E/D/L`, `phi_E/D`, `shl_E/D/L`; definíció- vagy mintafedettség-függő |
| JV/MNB-becslés, strukturális forrás vagy BGG-konvenció | 28 | 21 JV-poszterior, 5 JV-strukturális/survey, 2 BGG-konvenció; ebből 2 deklarált input jelenleg halott |
| Nyilvános magyar makroadatból pótolható | 11 | jelenleg átvett érték; a pontos E/D/L-leképezés egy részénél külön módszertan kell |
| Nem azonosított / több adat kell | 21 | ezek között vannak a fő KKV–nagyvállalat eredményt hordozó paraméterek |
| Származtatott vagy technikai | 18 | nem önállóan becsülendő; bizonytalanságuk az inputjaikból öröklődik; egy közülük halott |
| **Összesen** | **91** |  |

Fontos különbség: **„van szám a kódban” nem ugyanaz, mint „megvan a
paraméter”.** Szám mind a 91-hez van, de csak 33-at nevez a regiszter
horgonyzottnak, és ezen belül is külön kell választani a saját adatot, a
JV-poszteriort, a strukturális/survey értéket és a puszta BGG-konvenciót.

## Hogyan ellenőriztem Claude-ot?

1. A neveket közvetlenül a `.mod` `parameters` blokkjából nyertem ki.
2. A kommenteket eltávolítva 91 token és 91 egyedi név adódott.
3. Függetlenül kiértékeltem az alap makróágat:
   `OPTEN=0`, `TSCEN=3`, `NOVERT=0`, `ACCSCALE=100`, `DECOMP=0`,
   `SYM=0`, explicit `RHOACC` nélkül.
4. A névhalmazt összevetettem a `docs/regiszter/parameterek.csv`-vel, az
   értékeket pedig a modellből generált `_params_dump.csv` és az
   `ALLAPOT.md` táblájával.
5. A `model; ... end;` blokk és az algebrai paraméter-hozzárendelések
   tokenhasználatát külön átvizsgáltam, így a közvetett és a halott
   paraméterek is látszanak.

Eredmény:

- deklaráció ↔ regiszter: **91/91 pontos névegyezés**;
- nincs hiányzó, extra vagy duplikált paraméter;
- modell alapérték ↔ generált állapotlap: **91/91 egyezés**, legfeljebb
  kijelzési kerekítéssel;
- a regiszter CSV-je nem tárol értékoszlopot, ezért abban csak a
  név- és metaadat-audit végezhető el.

## KKV–nagyvállalat jelölések

- **🔴 közvetlen/kritikus:** közvetlenül eltér E/D/L között, vagy egy
  teljes csatorna hiányzik L-ből; a KKV–L eredmény fő hordozója lehet.
- **🟠 közvetlen:** típusonként eltér, de a jelenlegi vizsgálatok szerint
  nem feltétlenül domináns.
- **🟡 közös erősítő:** azonos minden típusra, de meglévő típuseltéréseket
  erősít vagy gyengít.
- **🔵 aggregáció/összetétel:** főleg súlyokat vagy a riportált aggregátumot
  mozgatja; az egyedi `y_j`-t nem közvetlenül.
- **⚪ nincs önálló mérethatás:** közös makrodinamikai paraméter.
- **⚫ halott:** deklarált/értékelt, de a jelenlegi v09 gazdasági
  egyenleteire sem közvetlenül, sem aktív származtatott paraméteren át nem hat.

E = exportorientált KKV, D = belföldi/nem exportorientált KKV, L =
nagyvállalat. Emiatt az E/D/L eltérés **nem tiszta mérethatás**: méretet,
piaci orientációt, importintenzitást, technológiát és finanszírozást kever.

---

## 1. Saját adatból horgonyzott vagy feltételes — 13 paraméter

| Paraméter | Aktív alapérték (`OPTEN=0`) | Modellbeli szerep | KKV–L | Státusz és fontos megjegyzés |
|---|---:|---|---|---|
| `delta` | 0,025 | Negyedéves amortizáció; `k_j=(1-delta)k_j(-1)+delta i_j`. | 🟡 | Saját panel: 0,0242 (`OPTEN=1/2`), közel az alaphoz. Közös paraméter, főleg a tőkedinamika sebességét változtatja. |
| `om_E`, `om_D`, `om_L` | 0,18; 0,37; 0,45 | Típusméret: aggregált `k`, `ii`, valamint `wd`, `wx`, `shm` és a dekompozíciós átlagok alapja. | 🔵/🟡 | Opten csak a 10+ fős körön belüli súlyt adja. `OPTEN=1`: 0,2555; 0,1844; 0,5601. A mikrocégek hiánya miatt feltételes. |
| `phi_E`, `phi_D`, `phi_L` | 0,56; 0,05; 0,365 | Exportarány: `y_j=(1-phi_j)d_j+phi_j x_j`; a `wd` és `wx` súlyokat is meghatározza. | 🔴 | Közvetlen piaci-orientációs driver. `OPTEN=1`: 0,3757; 0; 0,3649. `phi_D=0` itt definícióból következik, nem mérési eredmény. `phi_L` erősen horgonyzott. |
| `lev_E`, `lev_D`, `lev_L` | 1,60; 1,60; 1,85 | Tőkeáttétel a nettóvagyon-egyenletben; a hozamrés hatását skálázza. | 🔴 | Saját paneles alternatíva: 1,9385; 1,7185; 2,3374. Az E=D kényszer megdőlt; a szint könyv szerinti és mérőfüggő. |
| `shl_E`, `shl_D`, `shl_L` | 0,20; 0,50; 0,30 | Az aggregált munkakereslet `ll` súlyai; bér–fogyasztás visszacsatolás. | 🔵/🟡 | `OPTEN=1`: 0,1566; 0,3775; 0,4659, de csak a 10+ fős körön belül. Az egyedi `l_j`-t nem közvetlenül hajtják. |

**Aktív ág figyelmeztetés:** a „saját adatból megvan” nem jelenti azt,
hogy az alapmodell ezt használja. `OPTEN=0` az átvett induló értékeken fut.
Az `OPTEN=1/2` beviszi az Opten-értékeket, de egyidejűleg
`rho_acc=0,9673`-ra vált, és `ACCSCALE=100` mellett terminálisan BK-invalid.
Ezért az empirikus paraméterek hatását olyan új ágban kellene mérni, amely
a `rho_acc`-ot külön kezeli.

---

## 2. Nyilvános magyar adatokból pótolható — 11 paraméter

| Paraméter | Aktív alapérték | Modellbeli szerep | KKV–L | Mi kell hozzá? |
|---|---:|---|---|---|
| `zeta_E`, `zeta_D`, `zeta_L` | 0,14; 0,17; 0,155 | Tőkerészesedés a határköltségben és a tőke–kompozit tényezőkeresletben. | 🟠 | Jelenleg JV szektorértékek vállalattípusokra átvive. KSH-forrás elérhető, de az E/D/L méret–export kategóriákra leképezés nem puszta adatletöltés. |
| `aa_E`, `aa_D`, `aa_L` | 0,45; 0,80; 0,60 | Munka súlya a munka–import kompozitban; `1-aa_j` az import-/árfolyamkitettség. | 🟠 | Jelenleg E a legimportintenzívebb. KSH/ágazati adatokból pótolható, de vállalattípusos leképezés kell. |
| `sc`, `si`, `sg` | 0,54; 0,23; 0,10 | Fogyasztás, beruházás és kormányzat súlya a riportált GDP-ben. | 🔵 | KSH nemzeti számlákból közvetlenül frissíthető. Főleg az aggregált `y` mérését változtatják. |
| `sx`, `sm` | 0,60; 0,47 | Export/import súlya a GDP-ben és a nettó külső pozícióban. | 🔵/🟡 | KSH nemzeti számlákból pótolható. A `bstar`-on és a monetáris záráson át vissza is csatolnak. |

A technológiai paraméterek közvetlenül eltérnek a típusok között, de a
BK-valid `t53b` dekompozícióban a teljes technológiai heterogenitás
eltávolítása a KKV-küszöböt csak kb. **3%-kal** mozdította. Ez arra utal,
hogy a jelenlegi fő eredményt inkább a pénzügyi blokk viszi, nem `zeta/aa`.

---

## 3. Szakirodalmi/JV-értékek — 28 paraméter

### 3.1 JV-poszterior vagy JV-strukturális/survey — 26

| Paraméter | Érték | Modellbeli szerep | KKV–L | Megjegyzés |
|---|---:|---|---|---|
| `sigma`, `habit` | 1,814; 0,646 | Intertemporális helyettesítés/fogyasztási kamatérzékenység és fogyasztási szokás. | ⚪/🟡 | Közös aggregált transzmisszió; a már meglévő vállalati különbségeket közvetve skálázza. |
| `fii` | 2 | Munkakínálati görbület a bér-Phillips-görbében. | ⚪ | JV-strukturális/survey érték. |
| `rho_kz`, `rho_z` | 0,80; 0,50 | Tőke–kompozit és munka–import helyettesítés a tényezőkeresletben. | 🟡 | Közösek, de a típusonként eltérő `zeta_j` és `aa_j` hatását alakítják. |
| `xi_p`, `vth_p` | 0,921; 0,431 | `xi_p` a származtatott `lam_p`-n át az ár-Phillips-görbe meredeksége; `vth_p` az árindexálás/inercia. | 🟡 | Mindhárom típus ugyanazt kapja, de eltérő `mc_j` mellett relatívár-különbséget formál. |
| `xi_x`, `vth_x` | 0,810; 0,494 | Örökölt export-Phillips paraméterek. | ⚫ | **A jelenlegi v09-ben nem hatnak semmire.** `xi_x` csak a szintén halott `lam_x`-et számolja; `vth_x` sehol nem szerepel. |
| `xi_w`, `vth_w`, `theta_w` | 0,657; 0,185; 3 | Bérmerevség, bérindexálás és bérmarkup-rugalmasság; `xi_w` és `theta_w` a `lam_w` inputjai. | ⚪/🟡 | Közös bércsatorna. |
| `hx`, `mu_x` | 0,507; 0,534 | Exportkereslet perzisztenciája és relatívár-rugalmassága. | 🟡 | Közösek, de az eltérő `phi_j`, `p_j` és exportkitettség miatt a típuseltérést erősíthetik. |
| `gam_i`, `phi_pi` | 0,761; 1,379 | Kamatperzisztencia és inflációs reakció a lebegő rezsim Taylor-szabályában. | ⚪/🟡 | Közös makrotranszmisszió. |
| `nu_b` | 0,001 | Nettó külső pozíciót stabilizáló UIP-/kamatprémium-zárás a lebegő rezsimben. | ⚪ | A regiszter JV-poszteriorként horgonyzottnak nevezi, más projektanyag technikai zárásként kezeli; ezt forrásoldallal tisztázni kell. |
| `om_no` | 0,25 | Nem-Ricardiánus háztartások súlya a fogyasztásban. | ⚪ | JV survey/strukturális érték; a pontos survey-hivatkozás még hasznos lenne. |
| `rho_a`, `rho_x`, `rho_c`, `rho_w`, `rho_i`, `rho_pr`, `rho_mx`, `rho_g` | 0,552; 0,625; 0,767; 0,661; 0,488; 0,820; 0,318; 0,80 | Technológiai, exportkeresleti, fogyasztási, bér-, beruházási, prémium-, exportár/markup- és kormányzati sokkok AR(1)-perzisztenciái. | többnyire ⚪ | Közösek és a determinisztikus eurószcenárióban nem mind aktiválódnak. Kivétel: `rho_mx` az L-típus ár-Phillips-sokkjának tartósságát szabja, ezért sztochasztikus futásban KKV–L eltérést is okozhat. |

### 3.2 BGG-konvenció — 2

| Paraméter | Érték | Modellbeli szerep | KKV–L | Megjegyzés |
|---|---:|---|---|---|
| `eps_qw` | 0,96 | A vállalati saját tőkehozamban a `q` és a tőkehozam időzítési/tartóssági súlya. | 🟡 | Mindhárom típusra közös, de a BGG-aszimmetriákat skálázza. Nem magyar becslés. |
| `omega_nw` | 0,95 | Vállalati nettó vagyon perzisztenciája/túlélési súlya. | 🟡 | A `lev_j` különbségekkel együtt hat. Nem magyar becslés. |

---

## 4. Nem azonosított — 21 paraméter

| Paraméter | Aktív alapérték | Modellbeli szerep | KKV–L | Azonosítás / kockázat |
|---|---:|---|---|---|
| `chi_E`, `chi_D`, `chi_L` | 0,06; 0,06; 0,02 | Az EFP érzékenysége a `q+k-nw` finanszírozási résre. | 🔴 | Az egyik legerősebb BGG-driver. Méret szerinti magyar szintbecslés nincs; a korábbi „Opten-medián” hivatkozás téves. A korábbi scanben a sorrend fordítása megfordította a szegmenssorrendet. |
| `psi_E`, `psi_D`, `psi_L` | 8; 8; 13 | Beruházási kiigazítási költség: a `q_j` hatása `1/psi_j`-vel arányos. | 🔴 | A jelenlegi sorrend a KKV beruházását érzékenyebbé teszi. A lumpy-investment irodalom inkább az ellenkező méretsorrendet sugallja; kötelező scan. |
| `tsov_E`, `tsov_D`, `tsov_L` | 0,175; 0,175; 0,175 | Szuverén sokk közvetlen átadása az EFP-be. | 🔴 csak differenciált ágban | `TSCEN=3` alapágban azonos, tehát nem épít be méretkülönbséget. `TSCEN=1/2` exogén módon KKV- vagy L-előnyt ad. |
| `tbank_E`, `tbank_D`, `tbank_L` | 0,45; 0,45; 0,45 | Banki sokk átadása az EFP-be. | 🔴 csak differenciált ágban | Az alapág méretsemleges. A differenciált ágak nem azonosítottak; a saját magyar mérés és a szakirodalmi irány ellentmond. |
| `s_kkv` | 0,05 | A hazai határköltség súlya az exportoldali vertikális kapcsolatban; a `shd_v` inputja. | 🟡 | A név félrevezető: nem egyszerű KKV GDP-súly. A korábbi IO-horgony hibás; OECD/ICIO csak új módszertannal használható. |
| `mu_vert` | 0,50 | Hazai–export vertikális ár-/mennyiségi átgyűrűzés rugalmassága. | 🟡 | Közvetlen becslést a projekt nem talált; érzékenységi paraméter. |
| `zsov` | 0,50 | A szuverén felár súlya a kamat-/UIP-zárásban. | 🟡 | Közös makrohatás. Nyilvános idősorokból viszonylag olcsón becsülhető: szuverén felár és BUBOR–EURIBOR/UIP-reziduum. |
| `eps_ces` | 6 | Hazai keresleti helyettesítés az E/D/L típusok relatív árai között. | 🔴 | Formálisan közös, de az eltérő `p_j` miatt kritikus szegmensdriver; az `y_E` előjele kb. 2,3 körül fordul. A markup-irodalom más objektumot mér, legfeljebb plauzibilitási sáv. |
| `rho_acc` | 0,85 | Az E/D hitelhozzáférési állapot perzisztenciája. | 🔴 | Csak KKV-kra hat, mert L-access állapot nincs. A 0,9673 nem horgony és nem alsó korlát; magas-rho érzékenységi pont, amely `ACCSCALE=100` mellett BK-hibát okoz. |
| `lambda_acc_E`, `lambda_acc_D` | 2,0; 2,5 | EFP → hitelhozzáférési állapot. | 🔴 | L-változat nincs. Külön nem azonosítható az `omega_acc`-tól. |
| `omega_acc_E`, `omega_acc_D` | 0,35; 0,45 | Hitelhozzáférés → beruházás additív hatása. | 🔴 | L-változat implicit nulla. Csak a `lambda_acc_j*omega_acc_j` szorzat azonosítható. |

Az access-blokk aktív alapági szorzatai:

- E: `lambda_E*omega_E = 2,0*0,35 = 0,70`;
- D: `lambda_D*omega_D = 2,5*0,45 = 1,125`;
- L: **implicit 0**, mert nincs `acc_L`, `lambda_acc_L` vagy `omega_acc_L`.

Ez az utolsó nem paraméterérték, hanem **rejtett szerkezeti feltevés**.
Nincs benne a 91-es regiszterben, mégis a KKV–nagyvállalat különbség egyik
legerősebb forrása. Az adatban az exportáló KKV hitelhozzáférése nem
rosszabb a nagyvállalaténál, ezért külön L-access érzékenységi ág indokolt.

---

## 5. Származtatott vagy technikai — 18 paraméter

| Paraméter | Aktív alapérték | Modellbeli szerep | KKV–L | Auditmegjegyzés |
|---|---:|---|---|---|
| `beta` | 0,99 | Diszkontfaktor az Euler- és Phillips-egyenletekben, valamint az NFA-dinamikában. | 🟡/⚪ | A regiszter „származtatottnak” nevezi, de a `.mod` **fixen beállítja**; ez valójában standard kalibrációs konvenció. |
| `lam_p` | 0,00756633 | Típusár-Phillips-görbék meredeksége, `beta` és `xi_p` függvénye. | 🟡 | Aktív és valóban származtatott. |
| `lam_x` | 0,0464679 | Eredetileg exportár-Phillips meredekség, `beta` és `xi_x` függvénye. | ⚫ | **Halott paraméter:** kiszámolódik, de a v09 `model` blokkban nem szerepel. |
| `lam_w` | 0,0260714 | Bér-Phillips-görbe meredeksége; `beta`, `xi_w`, `theta_w`, `fii` függvénye. | ⚪/🟡 | Aktív és származtatott. |
| `nu_uni` | 0,25 | Technikai NFA-/uniózárás a monetáris uniós rezsim kamategyenletében. | 🟡 | Nem strukturális becslés; érzékenységi őrrel kezelendő. |
| `wd_E`, `wd_D`, `wd_L` | 0,110545; 0,490613; 0,398842 | Belföldi határköltség és relatívár-normalizálás súlyai; `om` és `phi` függvényei. | 🔵/🟡 | Nem önállóan horgonyzottak: öröklik az `om/phi` definíciós és mintafedettségi bizonytalanságát. |
| `wx_E`, `wx_D`, `wx_L` | 0,355493; 0,065244; 0,579263 | Exportár és exportmennyiség aggregációs súlyai; `om*phi` alapján. | 🔵/🟡 | Ugyanazt a bizonytalanságot öröklik; az exportoldali KKV–L összetételt érdemben mozgatják. |
| `shm_E`, `shm_D`, `shm_L` | 0,280453; 0,209632; 0,509915 | Aggregált importkereslet súlyai; `om` és `aa` függvényei. | 🔵/🟡 | Öröklik az `om` feltételességét és az `aa` átvett státuszát. |
| `shd_c`, `shd_i`, `shd_g`, `shd_v` | 0,650610; 0,177439; 0,141951; 0,03 | A hazai kereslet fogyasztási, beruházási, kormányzati és vertikális komponenssúlyai. | 🔵/🟡 | `shd_v=s_kkv*0,60`; a többi erre normalizálódik. Matematikailag származtatottak, de öröklik a horgonyzatlan `s_kkv` bizonytalanságát. |

---

## Claude-regiszter audit: mi helyes, és mit kellene pontosítani?

### Ami helyes

- A 91 paraméternév teljes és pontos; nincs hiány vagy extra.
- Az alapági modellértékek 91/91 megegyeznek a generált állapotlappal.
- A `rho_acc` már helyesen horgonyzatlan, és a 0,9673 nincs horgonyként
  vagy alsó korlátként kezelve.
- A saját adatos, nyilvános adatos, JV-/irodalmi, horgonyzatlan és
  származtatott főcsoportok számai összeadódnak 91-re.

### Amit pontosítani kellene

1. **Három halott paraméter:** `xi_x`, `vth_x`, `lam_x`. A regiszter
   forrást és státuszt ad nekik, de nem jelzi, hogy a v09 eredményeire
   jelenleg nincs hatásuk.
2. **Aktív érték kontra rendelkezésre álló horgony:** `delta` és
   `lev_E/D/L` saját adatból horgonyzott, de az alapértelmezett `OPTEN=0`
   még a régi értékeket használja. `phi_L` esetében a régi és az új érték
   szinte azonos.
3. **`beta` nem származtatott:** a modellben hard-coded 0,99; helyesebb
   „standard konvenció” címke.
4. **`nu_b` szerepe kétértelmű:** a regiszter JV-poszteriorként horgonyzott,
   a modellben és a csapatdoksiban viszont technikai NFA-zárásként működik.
   A pontos JV-forrás és a becslési státusz ellenőrzendő.
5. **A „pótolható KSH-ból” túl optimista `zeta_j/aa_j` esetén:** az
   aggregált adat elérhető, de E/D/L vállalattípusokra való leképezéshez
   külön módszertan szükséges.
6. **A származtatott nem jelent horgonyzottat:** `wd/wx` a feltételes
   `om/phi`, `shm` a feltételes/átvett `om/aa`, `shd_*` pedig a
   horgonyzatlan `s_kkv` bizonytalanságát örökli.
7. **A legfontosabb feltevés nincs a 91 között:** az L-access csatorna
   hiánya (`acc_L`, `lambda_acc_L`, `omega_acc_L` implicit nulla).
8. **A 28 „horgonyzott” irodalmi/JV-paraméter nem homogén:** 21
   poszterior, 5 strukturális/survey és 2 puszta BGG-konvenció. A pontos
   JV-tábla-, oldal- és mintaperiódus-hivatkozások még erősítenék az auditot.

---

## Mely paraméterek drive-olhatják leginkább a KKV–nagyvállalat eltérést?

### Első prioritás — a fő állítás magja

1. **Az L-access csatorna implicit nullája**, majd
   `lambda_acc_E/D*omega_acc_E/D` és `rho_acc`.
2. **`chi_E/D/L`** — közvetlen BGG-aszimmetria, horgonyzatlan; korábbi
   vizsgálatban a sorrend fordítása megfordította a szegmenssorrendet.
3. **`eps_ces`** — közösnek látszik, de a relatív árakon keresztül képes
   megfordítani az export-KKV kibocsátási előjelét.
4. **`psi_E/D/L`** — közvetlen beruházási aszimmetria, ráadásul az
   irodalom a jelenlegi méretsorrendet megkérdőjelezi.

### Második prioritás — erős összetételi és pénzügyi hatások

5. **`phi_E/D/L`**, valamint a belőlük és `om_j`-ből származó `wd/wx`.
6. **`lev_E/D/L`** — már van saját adat, de a könyv szerinti szint és az
   aktív alapág külön kezelendő.
7. **`tsov_j/tbank_j`** — az alapágban semlegesek, az alternatív
   transzmissziós ágakban viszont közvetlenül beépítik az előnyt.
8. **`om_j/shl_j`** — nem tiszta viselkedési paraméterek, de a KKV-blokk
   összetételét és az aggregált visszacsatolást erősen befolyásolják.

### Harmadik prioritás — közvetett vagy a tesztekben kisebb driver

9. **`zeta_j/aa_j`** — közvetlen technológiai eltérés, de a BK-valid
   dekompozícióban csak kb. 3%-os küszöbelmozdulást okozott.
10. **`hx/mu_x`, `rho_kz/rho_z`, `eps_qw/omega_nw`** — közös erősítők;
    meglévő heterogenitás nélkül önmagukban nem hoznak létre méretkülönbséget.
11. **`s_kkv/mu_vert`, `sx/sm`, `zsov`, `nu_uni/nu_b`** — főleg az
    aggregált és külső zárási visszacsatolást mozgatják.

---

## Mit lehet még adatból előbányászni?

### A meglévő projektadatból

- A 13 Opten-paramétert már kiszámoltuk, de az `om/shl` a 10+ fős kör
  miatt csak feltételes.
- A pooled `rho_acc=0,9673`, a paneles `chi`-regresszió és a programhatás
  **diagnosztika**, nem érvényes strukturális horgony. Ugyanabból az
  adatból több regresszió nem oldja meg a fix heterogenitást és a
  programvezérelt kamatvarianciát.
- Hasznos következő belső lépés lehet a `rho_acc` váltó/marginális
  almintája és a `psi_j` beruházási dinamikájának leíró scan-je, de ezeket
  előre nem szabad becslésnek nevezni.

### Nyilvános adatokból viszonylag gyorsan

- `sc/si/sg/sx/sm`: KSH nemzeti számlák.
- `zsov`: szuverén felár + BUBOR–EURIBOR/UIP idősor.
- `zeta_j/aa_j`: KSH/ágazati adatok, de E/D/L mapping szükséges.
- `s_kkv`: OECD TiVA/ICIO és KKV-hozzáadottérték-adatok csak új,
  fogalmilag megfelelő vertikális-link módszertannal.

### Új külső mikro- vagy surveyadat kell

- Az access-szorzatokhoz EIBIS/SAFE vagy granular MNB hitel- és
  beruházási adatok; a modell **külön** `lambda` és `omega` értéket ezekből
  sem képes azonosítani, csak a szorzatot.
- `tsov_j/tbank_j`: méret és exportorientáció szerinti új szerződéses
  vállalati kamat/transzmisszió.
- `chi_j`: EFP vagy hitelfelár reakciója a mérlegpozícióra, megfelelő
  nagyvállalati mintával.
- `psi_j`: vállalati beruházási mikrodinamika méret és exportstátusz szerint.
- `rho_acc`: közvetlen szegmensszintű dinamika vagy olyan panelmodell,
  amely a fix céghatást leválasztja az időbeli alkalmazkodásról.

## A 91 paraméteren kívüli, de eredményt mozgató kalibrációk

A `.mod`-audit azt is megmutatta, hogy a deklarált paraméterlista nem
tartalmaz minden számszerű kutatói döntést:

- `SCENARIO` választja a szuverén- és banki sokk nagyságát és időpályáját;
  maga a sokkpálya nem paraméter, mégis közvetlenül skálázza az eredményt.
- `OPTEN`, `TSCEN`, `DECOMP`, `DECOMPW`, `SYM` és `NOVERT` egyszerre
  egész paramétercsomagokat/szerkezeteket cserélő kapcsolók.
- `ACCSCALE` egyszerre skálázza a `lambda` és `omega` lépcsőt, ezért a
  csatorna erejét négyzetesen mozgatja. A `LAMSCALE` és `OMSCALE` külön
  választja a két lépcsőt, de a modellkimenet továbbra is csak a szorzatot
  azonosítja.
- `RHOACC`, `NUUNI`, `SKKV`, `MUVERT`, `EPSCES` makrók deklarált
  paramétereket írnak felül; a futtatási konfiguráció nélkül az „érték”
  nem egyértelmű.
- A `shd_*` képletekben rögzített 0,60; 0,55; 0,15; 0,12; 0,82 számok
  nincsenek paraméterként deklarálva, ezért a 91-es auditon kívül maradnak.
- `OPTEN=1` mellett `phi_D=0` a szegmensdefiníció következménye, nem
  nullára becsült viselkedési paraméter.
- A legfontosabb ilyen rejtett korlátozás továbbra is az L-access teljes
  hiánya.

Claude review-ján ezért a 91 paraméter mellett külön **konfigurációs és
implicit-feltevés regiszter** is indokolt; különben egy modellkapcsoló vagy
hard-coded konstans erősebben mozgathatja az eredményt, mint egy gondosan
dokumentált paraméter.

## Végső értékelés

A Claude-regiszter **teljességi és numerikus értelemben jó**: a 91 név és
az alapértékek pontosan egyeznek a modellel. A fontos korrekció nem egy
hiányzó név, hanem az értelmezés:

- három paraméter halott;
- több „saját adatból megvan” érték nem aktív az alapágon;
- több „származtatott” érték gyenge inputok bizonytalanságát örökli;
- a fő KKV–L eredmény legerősebb feltevése, az L-access teljes hiánya,
  nincs paraméterként regisztrálva;
- a fő eredmény legfontosabb aktív driverei éppen a horgonyzatlan D
  kategóriában vannak.

Ezért a következő modellfejlesztési sorrend nem a 91 szám további
finomhangolása, hanem: **L-access ellenpróba → access-szorzat/rho → chi →
eps_ces → psi → transzmissziós különbségek**, mindegyiknél valódi BK-checkkel.


---

## Mi lett az auditból — átvezetve 2026-08-25

Az audit nyolc pontosítási javaslatából **négy azonnal átvezetve**, a
maradék négy a teendőlistán. A cáfolható technikai állításokat előbb
függetlenül ellenőriztem (a `model; ... end;` blokk tokenizálásával), és
**mind kiállta a próbát**.

### Átvezetve

| # | Javaslat | Mi történt |
|---|---|---|
| 1 | Három halott paraméter | `xi_x`, `vth_x`, `lam_x` megjelölve az új **`hatas`** oszlopban; **`t54` őr** ellenőrzi, hogy tényleg nem szerepelnek a model blokkban (kétirányú: bekötésre is, jelölés-törlésre is elbukik) |
| 3 | `beta` nem származtatott | státusz `származtatott` → `horgonyzott`; forrás: „standard kalibrációs konvenció, a `.mod` fixen beállítja — ő az *inputja* a `lam_p`/`lam_w`-nek". Őr: a `.mod`-ban `beta = 0.99` |
| 4 | `nu_b` kétértelmű | státusz `horgonyzott` → `feltételes`, a forrásmező kimondja az ellentmondást (JV-poszterior vs technikai NFA-zárás) |
| 6 | Származtatott ≠ horgonyzott | 15 paraméter kapott **örökölt bizonytalanság** jelölést: `wd/wx` ← `om/phi` (feltételes), `shm` ← `om/aa` (átvett), `shd_*` ← `s_kkv` (**horgonyzatlan**) |

Státusz-eltolódás: `származtatott` 18 → 17, `feltételes` 8 → 9,
`horgonyzott` 33 (változatlan: `beta` +1, `nu_b` −1). Összesen továbbra is 91.

### Új: alapértelmezés-konfliktus regiszter

Az audit 2. pontja („aktív érték kontra rendelkezésre álló horgony")
általánosabb mintázatra mutatott, mint amit maga leír. **A `.mod`
alapértelmezése két olyan értéket futtat, amit a saját regiszterünk
visszavont vagy megcáfolt** — és ezt eddig semmi nem ellenőrizte:

- **`K01`** — a **visszavont `V04`** 3×-os `chi`-aszimmetriája (0,06/0,06/0,02)
  még mindig az alapértelmezés. A `t35` scan szerint a sorrend fordítása
  **megfordítja a szegmenssorrendet**, tehát ez érdemi konfliktus.
- **`K02`** — az **álló `A08`** szerint megdőlt `lev_E = lev_D` kényszer
  még mindig az `OPTEN=0` alapág (1,6 = 1,6).

Nyilvántartás: `docs/regiszter/alapertelmezes_konfliktusok.csv`. Egyik sem
javítandó hiba — az alapértelmezés cseréje **csapatdöntés** —, az őr a
*láthatóságot* védi.

### Nem vezettük át (indoklással)

| # | Javaslat | Miért nem most |
|---|---|---|
| 2 | Aktív érték vs horgony (`delta`, `lev_j`) | Ez a `K02` konfliktusként van nyilvántartva; a feloldás BK-valid ágat igényel, amely a `rho_acc`-ot külön kezeli — modellezési feladat, nem regiszter-javítás |
| 5 | `zeta_j/aa_j` „KSH-ból pótolható" túl optimista | Egyetértek, de a `B` kategória átcímkézése az egész kategória-narratívát érinti; külön kör |
| 7 | Az L-access hiánya nincs a 91 között | **Ez a legfontosabb pont**, és szerkezeti: nem paraméterérték, hanem hiányzó egyenlet. Külön `omega_acc_L`-scan a teendő (korlátok-riport 4.) |
| 8 | A 28 „horgonyzott" JV-paraméter nem homogén | A kategória_nev már megkülönbözteti (21 poszterior / 5 strukturális / 2 BGG); a tábla-, oldal- és mintaperiódus-hivatkozás a JV-vintage teendőhöz tartozik |

### Amit az audit nem tudott elkapni — és most már igen

Az őrök eddig három rétegben dolgoztak: **állítás** (van-e őre),
**tábla** (a szám a helyén van-e), **szerkezet** (a fájlok a helyükön
vannak-e). Hiányzott a negyedik: **paraméter** (amit a modell ténylegesen
futtat, konzisztens-e azzal, amit állítunk). A `t54` ezt a réteget hozza be.

Füstteszt az átvezetés után: **156 rendben, 0 hiba.**
