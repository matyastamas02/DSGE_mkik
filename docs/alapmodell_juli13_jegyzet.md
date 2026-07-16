# Jegyzet és bírálat — `DSGE_alapmodell_juli13.mod` (Evelin EAGLE-HU magja)

*Blokkonkénti jelmagyarázat + ellenőrzött kritika. A modellt le is
futtattam (Dynare 6.5): a steady state konvergál, a Blanchard–Kahn
teljesül (13 instabil gyök = 13 előretekintő változó), a momentumok
számolódnak. Technikailag működő, gondosan dokumentált munka — a
bírálat ezt figyelembe véve készült.*

## 0. Összkép — mi ez, és hová illik

Az EAGLE-HU (Békési–Kaszab–Szentmihályi 2017) **egyblokkos (csak
magyar), nemlineáris** redukciója: 91 endogén változó, 91 egyenlet,
17 sokk, kézzel levezetett steady state-tel. Célja a fájl szerint:
működő alap, amire a KKV/nagyvállalat bontás és az euró-szcenáriók
épülnek.

**A legfontosabb, kódon kívüli kérdés:** a csapat 2026-07-13-i döntése
szerint az alapcikk a **Jakab–Világi (2008/9)**, nem az EAGLE — ez a
fájl tehát (bármilyen igényes) a **másik** alapra épült. Tisztázandó
Evelinnel: a fájl a döntés előtt készült-e, és mi a sorsa (referencia
vs. kukázás vs. blokk-donor — javaslat a 4. pontban).

## 1. Jelmagyarázat blokkonként

A kód 14 szakaszból áll; a kommentjei jók, ez a jegyzet a "miért így"
szintet adja hozzá.

**(1) Ricardián háztartás (25%, `_I` index).** Ő az, aki megtakarít:
tőkét, hazai és külföldi kötvényt, pénzt tart. Kulcs-egyenletei:
- *Kötvény-Euler* (`beta*R*(lambda(+1)/lambda)/pi_C(+1)=1`): ez köti
  össze a jegybanki kamatot a fogyasztási döntéssel — a monetáris
  transzmisszió gerince.
- *Pénz-Euler + pénzsebesség* (`v_I`, `gamma_v_*`): NAWM-típusú
  tranzakciós költség — a pénztartás azért hasznos, mert csökkenti a
  fogyasztás "effektív árát". Taylor-szabály mellett kvázi díszlet
  (lásd kritika #10).
- *Tobin-Q blokk* (`q_I`, `gamma_I_*`, `u_I`, `gamma_u_*`): beruházási
  kiigazítási költség (a beruházás NÖVEKEDÉSÉT bünteti) + változtatható
  tőkekihasználtság (gu2=2000 miatt gyakorlatilag fix).
- *Munkakínálat* (`n_I^chi = lambda_I*(1-tau_N-tau_Wh)*wr`): rugalmas
  bér — a bér-Calvo tudatosan kimaradt (lásd kritika #3).

**(2) Nem-Ricardián háztartás (75%, `_J`).** Nincs tőke- és
kötvénypiaci hozzáférése; egyetlen eszköze a készpénz. A fogyasztását
a KÖLTSÉGVETÉSI KORLÁT határozza meg (adózott bér + transzfer − adó ±
pénzállomány-változás; az inflació erodálja a tavalyi pénzt — ez az
inflációs adó csatorna). Saját munkakínálati FOC-cal (szegényebb →
többet dolgozik: n_J > n_I az SS-ben).

**(3) Aggregáció.** Minden aggregátum ω-súlyos átlag; tőkét és
beruházást csak a Ricardiánok tartanak (k = (1−ω)·k_I).

**(4) Termelés.** Két szektor, Cobb–Douglas (tőke + munka),
költségminimalizálással. A határköltség (rmc) NEM külön képletből,
hanem a termelési függvény + két FOC együtteséből adódik implicit
módon (a szerző jelzi: a zárt képlet redundáns volt és szingularitást
okozott — korrekt megoldás). A munka-FOC-ban ott a munkáltatói
járulék (1+tau_Wf) — SZOCHO-elemzésre kész.

**(5) Árazás.** Szektoronként hibrid NKPC eltérés-formában; a hajtóerő
`rmc/rp − 1/markup` (a markup itt SOKK-FOLYAMAT — költségsokk így
modellezhető). A Calvo ár-diszperzió (`s_T`, `s_NT`) formálisan bent
van, első rendben irreleváns. FONTOS: ξ=0,75 és indexálás=0 — ez NEM
a tanulmány (0,92 / 0,5), determináltsági okból tért el (kritika #3).

**(6) Export szektor.** A tanulmány jó ötlete megvan: az export jószág
hazai tradable + IMPORT input CES-e (az import-input ára
`pimx_scale·rer` = 0,55·rer) — a leértékelődés az export KÖLTSÉGÉT is
emeli. VISZONT az export-KERESLET tisztán exogén AR(1) — nincs
árrugalmasság (kritika #2).

**(7–8) Fogyasztási és beruházási végső jószág.** Kétszintű CES:
(tradable-köteg vs. non-tradable), a tradable-en belül (hazai vs.
import). A CPI-identitás (`1 = CES-árindex`) a numeraire-megkötés —
implicit módon ez határozza meg pi_C-t. Az import fogyasztási súlya
magas (v_TC=0,2 → 80% import a tradable-fogyasztásban, EAGLE-ből).

**(9) Piactisztulás.** Fogyasztási jószág = c + tranzakciós költség;
beruházási jószág = i + kihasználtsági költség; hazai tradable kereslet
= fogyasztás + beruházás + export-input; non-tradable = fogyasztás +
beruházás + KORMÁNYZAT (a kormány csak non-tradable-t vesz, EAGLE
szerint); munkapiaci tisztulás → implicit bérmeghatározás.

**(10) Külkereskedelem, NFA.** tb = export-érték − import-érték;
`b_star = R*·(b_star(−1) + tb(−1)/(300·rer(−1)))` — a 300-as szorzó
egy örökölt árfolyamszint-normalizálás (kritika #7). Az SGU-típusú
adósság-rugalmas prémium (γB*=0,1 — a tanulmány 0,01-e helyett,
kritika #3d) stabilizálja.

**(11) GDP és profit.** GDP kiadási oldalról; a profit a három szektor
operatív eredménye + az export-összeszerelő marzsa, osztalékként a
Ricardiánoké (tau_D adóval).

**(12) Monetáris politika.** Taylor-szabály évesített kamatokkal
(R⁴-formában), a JELENLEGI évesített inflációra (nem 4 negyedéves
átlagra — determináltsági okból, dokumentálva). φR=0,87, φπ=1,7,
φY=0,1 (de lásd kritika #5).

**(13) Fiskális politika.** Teljes költségvetési korlát HAT adónemmel
(τ_C, τ_D, τ_K, τ_N, τ_Wf, τ_Wh), seigniorage-dzsal, adósság-
stabilizáló lump-sum szabállyal (φB=0,1, cél 60% GDP). Ez a fájl
legértékesebb blokkja a projektnek (lásd 5. pont).

**(14) Sokk-folyamatok.** 17 sokk AR(1) log-formában; a szórások
bevallottan nyersek ("a kalibrációs fázisban becsülendők").

## 2. Változó-jelmagyarázat (csoportosítva)

| Csoport | Változók | Mi ez |
|---|---|---|
| Ricardián hh. | `c_I k_I i_I rm_I q_I u_I lambda_I v_I` + 6 költségfüggvény-segéd | fogyasztás, tőke, beruházás, reálpénz, Tobin-Q, kihasználtság, határhaszon, pénzsebesség |
| Nem-Ricardián hh. | `c_J rm_J lambda_J v_J` + 2 segéd | ugyanaz, tőke nélkül |
| Aggregátumok | `c rm k i n n_I_agg n_J_agg b b_star wr` | ω-súlyos átlagok; b=államadósság, b_star=NFA, wr=reálbér |
| Tradable szektor | `y_T k_d_T n_d_T rmc_T rp_T pi_T s_T` | kibocsátás, tényezőkereslet, határköltség, relatív ár, infláció, ár-diszperzió |
| Non-tradable | `y_NT k_d_NT n_d_NT rmc_NT rp_NT pi_NT s_NT` | ugyanaz |
| Export | `rmc_X rp_X pi_X q_X_final h_T_X im_X` | határköltség, ár, infláció, volumen (exogén!), hazai/import input |
| Fogyasztási köteg | `q_C tt_c h_T_c n_T_c im_c rp_TTC` | kétszintű CES komponensei + árindexe |
| Beruházási köteg | `q_I_final tt_i h_T_i n_T_i im_i rp_I rp_TTI` | ugyanaz |
| Makro/pénzügy | `y div tb r_K R pi_C pi_C_4 rer nfa_ratio gamma_B_adj h_T_t n_T_t` | GDP, profit, kereskedelmi mérleg, kamatok, inflációk, reálárfolyam, NFA-prémium |
| Fiskális | `g tr T` | kormányzati vásárlás, transzfer, lump-sum adó |
| Sokk-állapotok | `a_T a_NT markup_* chi_pref rp_shock tau_*` | AR(1) folyamatok |

## 3. Paraméter-jelmagyarázat — honnan jön mi

| Forrás | Paraméterek |
|---|---|
| EAGLE Table 1 (hűen) | β=0,99; σ=0,4; χ=2; habit=0,7; ω=0,75; δ=0,025; α=0,3; CES-súlyok/rugalmasságok (μ_C…v_X) |
| EAGLE Table 2–3, 5 (hűen) | γI=6; γu2=2000; γv1/γv2; Taylor (0,87/1,7/0,1); φB=0,1; B/Y=2,4; hat adókulcs; markupok (1,2/1,5/1,2); θ=6, θw=3 |
| **ELTÉRÉSEK a tanulmánytól** (dokumentálva) | ξ=0,75 (nem 0,92); indexálás=0 (nem 0,5); Taylor jelenlegi évesített inflációra; π̄=1 (nem 3%); γB*=0,1 (nem 0,01); α_NT=0,377 (nem 0,3) |
| Saját SS-levezetés | pimx_scale=0,5533; g_ss; tr_ss; qX_ss; gu1=r_K_ss |
| Nyers (becsülendő) | mind a 17 sokk-szórás és a ρ=0,95 perzisztenciák |

## 4. Mibe lehet belekötni — ellenőrzött kritika

### Súlyos (érdemi következménnyel)

1. **Alapcikk-eltérés.** A csapatdöntés a Jakab–Világi; ez a fájl
   EAGLE-alapú. Bármilyen jó, a fő vonalba így nem illeszthető be
   változtatás nélkül — egyeztetendő.
2. **Az export-kereslet tisztán exogén** — `q_X_final` AR(1),
   ár-/árfolyamrugalmasság NÉLKÜL. A leértékelődés így csak a
   költségoldalon hat, a keresleti expenditure-switching csatorna
   hiányzik. Euró-elemzésnél (ahol a reálárfolyam-pálya központi) ez
   torzít: a konvergenciás felértékelődés export-fékező hatása nem
   jelenik meg. Olcsó javítás: JV-típusú keresleti egyenlet
   (simítás + becsült μx≈0,53) — nálunk a jv-vonalban már így van.
3. **Determináltsági paraméter-műtétek halmozása.** Négy beavatkozás
   ugyanarra a tünetre: (a) ξ 0,92→0,75; (b) indexálás 0,5→0;
   (c) Taylor-argumentum csere (4 negyedéves átlag → jelenlegi);
   (d) γB* 0,01→0,1 (tízszerezés!). Együtt azt jelentik, hogy a modell
   szerkezete EAGLE-HU, de a **nominális és nyitott gazdasági
   dinamikája már nem az** — az "EAGLE-kalibrált" címke így
   félrevezető lehet bírálói szemmel. Gyanú: a gyökér-ok nem az
   "indeterminációt okozó lapos Phillips-görbe", hanem a **rugalmas
   bér + 75% kézről-szájra kombináció** (Galí–López-Salido–Vallés:
   magas kézről-szájra arány mellett a determináltsághoz bér-
   ragadósság/másmilyen szabály kell). Tünetet kezeltek paraméterrel,
   ok helyett — a bér-Calvo visszaépítése valszeg többet oldana meg
   egyszerre (az ő "finomítási pontjai" közt szerepel is).

### Közepes

4. **α_NT=0,377 SS-kényszerből** (nem a tanulmány 0,3-ja): a közös
   (r_K, w) + eltérő markupok + rp=1 normalizálás ellentmondását úgy
   oldja, hogy megváltoztatja a non-tradable szektor tőkeintenzitását
   — ez a DINAMIKÁT is érinti (a NT szektor tőkésebb lett, mint a
   valóságban). Tisztább megoldás: szektorális TFP-szint vagy
   rp_NT_ss ≠ 1 normalizálás. (A szerző jelzi is finomítandóként.)
5. **A Taylor-szabály vegyes skálázása.** Az egyenlet évesített
   kamat-KÜLÖNBSÉGEKBEN él (~4× szorzó mindkét oldalon), de a
   kibocsátási tag (φY·negyedéves növekedés) nincs évesítve → a
   tényleges kibocsátási válasz ~φY/4 ≈ 0,024, negyede a szándékoltnak.
   Apró képlet-javítás (φY·4· vagy növekedés évesítése).
6. **Nincs pénzügyi blokk / KKV-bontás** — a projekt fő csatornája
   (EFP, akcelerátor, hitelprémiumok) még hiányzik. Alapmodellnél ez
   rendben van, de a "erre épül majd" ígéretből még semmi nem látszik
   — a mi kész blokkjaink (jv_dsge_v02) átemelhetők.
7. **A 300-as mágikus skálázás az NFA-blokkban** (két helyen) — belső
   konzisztens, de átláthatatlan; egy elírás (csak az egyik helyen
   módosítva) csendben elrontaná. Paraméterként kellene (`e_scale`)
   egyetlen definícióval.

### Apróság

8. Az NKPC-meredekség effektíve κ/markup-pal skálázódik (az eltérés-
   forma miatt): a non-tradable görbe ~33%-kal laposabb, mint a
   tradable, azonos ξ mellett — nem hiba, de tudni kell róla
   kalibráláskor.
9. A nemlineáris ár-diszperziós blokk (s_T, s_NT) + linearizált NKPC
   keveréke rendben van order=1-en, de **order=2-n inkonzisztens
   lenne** — érdemes kommentben jelezni, nehogy valaki magasabb rendben
   futtassa.
10. A pénzblokk (tranzakciós költség, 10+ változó) Taylor-szabály
    mellett kvázi díszlet — hűség-érv szól mellette, egyszerűség-érv
    ellene.
11. A hat adósokk-folyamat bloat, amíg nincs fiskális kísérlet — de
    olcsó bloat.
12. Sokk-szórások nyersek (ρ=0,95 mindenhol) — ő is jelzi; a JV becsült
    értékei (nálunk már bent) jobbak.

### Ami kifejezetten JÓ benne (mondjuk ki ezt is)

- **A steady state kézi levezetése hibátlan** — szúrópróbaszerűen
  ellenőriztem (az rmc_X = 1/markup_X kalibráció kézi számolással
  pontosan kijön), és a `steady;` azonnal konvergál.
- **Őszinte, gazdag dokumentáció**: minden eltérés a tanulmánytól
  indokolva és listázva; a saját gyengeségek ("finomítási pontok")
  bevallva.
- **Walras-tudatosság, redundancia-kezelés** (implicit rmc, CES-
  dualitás) — tapasztalt kézre vall.
- **A fiskális blokk teljes** (hat adónem, seigniorage, adósságszabály)
  — a kamarai SZOCHO/adó-szcenáriókhoz ez arany, és a mi JV-vonalunkból
  most hiányzik.

## 5. Javaslat — mi legyen a sorsa

1. **Egyeztetés Evelinnel az alapcikk-döntésről** (JV vs. EAGLE) — a
   fájl fejlécdöntése ezen áll.
2. **Blokk-donorként hasznosítani**: a fiskális blokk (hat adónem) és
   a tradable/non-tradable szerkezet átemelhető a JV-vonalba, ha a
   tanulmányhoz kell (SZOCHO-szcenárió, szektorális bontás).
3. Ha EAGLE-referenciaként marad: (a) export-árrugalmasság pótlása
   (#2), (b) bér-Calvo visszaépítése és a determináltsági műtétek
   visszapróbálása (#3), (c) φY-skálázás javítása (#5), (d) fájl
   áthelyezése a `src/model/`-be és bekötése a füsttesztbe.
