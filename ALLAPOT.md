<!-- GENERÁLT FÁJL — NE SZERKESZD. Forrás: docs/regiszter/*.csv +
     output/tables/t00_orok.csv. Újragenerálás:
       matlab -batch "cd('src/4_infra'); smoke_test"
       python src/4_infra/13_allapotlap.py                                -->

# DSGE_mkik — állapotlap

*Generálva a füstteszt 2026-08-21 16:50-kor futott eredményéből · commit `4ccfe34` · ág `main`*

**Fő modell:** `src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod` (Jakab–Világi mag). A `kkv_dsge_*` a referencia-vonal.

**Őrök:** 116 rendben, 0 hiba.

✅ **Minden „áll” állításnak van őre, és minden őr fut.**

---

## Mit állítunk ma

### 🟢 Ami ÁLL — 21 db

*Ezekre lehet építeni a tanulmányban.*

**A01.** A −200 bp szuverén és −45 bp banki felár-konvergenciát feltételező euró-szcenárióban a modell tartós GDP-hatása +0,3% … +2,9% — minden modellverzión, szcenárión (−150/−30 … −250/−60 bp) és kalibrációs ágon POZITÍV.

> bizonyíték: `t44, t47` — őr: ✅ `t47: mind a 36 kombinacio BK-stabil (az OPTEN=1 phi_D=0 is)`  
> *2026-08-16 · ÁTFOGALMAZVA 2026-08-21, majd 2026-08-21-én MÁSODSZOR is javítva. Az első átfogalmazás („A VIZSGÁLT euró-szcenáriókban…”) külső bírálat nyomán született, de TÚL MESSZE MENT: elhallgatta a nagyságrendet, így az olvasó nem tudta értékelni. A bíráló érve („honnan jön a kontrafaktuális sokkpálya?”) FÉLREVEZETŐ volt: a pálya nem önkényes — sov = −0,005 negyedéves = pontosan −200 bp/év, bank = −0,001125 = −45 bp/év, ötfázisú időzítéssel (bejelentés → ERM-II 60% → belépés → normalizálódás → tartós) és három érzékenységi pályával. Lásd docs/modszertan/modell_verziok_osszefoglalo.md. AMI VISZONT VALÓDI RÉS: a −200 bp MAGÁNAK nincs hivatkozott forrása a repóban — EZT támadná egy bíráló, nem azt, hogy van előírt pálya. Felvéve a teendőlistára. A DSGE továbbra sem AZONOSÍTJA az euró kontrafaktuálisát, hanem kvantifikál egy kalibrált konvergencia-szcenáriót — de a szcenárió nagyságrendje az állításban benne van.*

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

**A11.** A hitelhozzáférési állapot negyedéves perzisztenciája LEGALÁBB 0,967 (cég-szintű mérés: éves 0,875 = p11 − p01, n = 110 350 cég-év pár).

> bizonyíték: `t46c, t37` — őr: ✅ `t49b: a kuszob MONOTON csokken a rho_acc-ban (47.8 -> 17.5)`  
> *2026-08-16 · VISSZAÁLLÍTVA 2026-08-21: a „legalább” szót külső bírálat nyomán kivettük, majd ELLENŐRIZTÜK, és a bíráló érve gyengébbnek bizonyult, mint hangzott. Az érv az volt, hogy a cég-szintű BINÁRIS státusz és a szegmens-szintű FOLYTONOS állapot más objektum, tehát nem korlát. Két független ok szól amellett, hogy MÉGIS alsó korlát: (1) SAJÁT MÉRÉS (t37): a szegmens-arányok 4 év alatt 0,59–2,20 pontot mozdultak, miközben a BUBOR 12,83-at — az aggregált folyamat gyakorlatilag áll, tehát perzisztensebb a cég-szintűnél. (2) GRANGER-AGGREGÁCIÓ (1980): heterogén AR(1)-ek aggregálása lassabban lecsengő autokorrelációt ad, mint az átlagos rho — a szegmens-szint tehát elméletileg is perzisztensebb. A két objektum valóban különbözik, de a különbség IRÁNYA ismert, és a modellparaméterre alsó korlátot ad. A scan (t49/t51) ettől függetlenül kell, mert 1/(1−rho) robban.*

**A12.** A fő modell BK-stabil minden szcenárió × transzmisszió × kalibrációs ág kombinációban (36/36).

> bizonyíték: `t47` — őr: ✅ `t47: mind a 36 kombinacio BK-stabil (az OPTEN=1 phi_D=0 is)`  
> *2026-08-16 · Beleértve az OPTEN=1 ágat, ahol phi_D = 0 pontosan.*

**A13.** Az access-csatorna egzaktul beágyazott: ACCSCALE=0 mellett a v09 PONTOSAN a v08-at adja (eltérés 0,0e+00).

> bizonyíték: `t45b` — őr: ✅ `t45b NESTING: ACCSCALE=0 == v08 (elteres 0.0e+00)`  
> *2026-08-12 · Független verifikáció, nem BK-teszt.*

**A14.** A modell átment 18/18 független azonosság-ellenőrzésen (szimmetria 1e−16, aggregáció 1e−19, nulla-sokk pontosan 0, szegmens-kibocsátás → jószág-aggregáció 4,3e−19).

> bizonyíték: `t43` — őr: ✅ `t43: mind a 18 fuggetlen ellenorzes atment`  
> *2026-08-12 · Ezek olyan hibát fognak el (elgépelt index, felcserélt súly), amit a BK-teszt nem. BŐVÍTVE 2026-08-21, külső bírálat nyomán: a 18. ellenőrzés azt őrzi, hogy sum(om_j·y_j) = w_d·y_d + w_x·y_x. Ez azért kellett, mert a bíráló észrevette, hogy NINCS y = sum(om_j·y_j) azonosság a modellben. Nincs is, és NEM IS LEHET: a y_j bruttó kibocsátás importált köztes inputtal, a y kiadási oldali GDP. Ami viszont teljesül — a jószág-szintű aggregáció —, most tesztelt.*

**A15.** Az implicit_kamatrata oszlop TORZÍT minden olyan regresszióban, ahol a magyarázó változó együtt mozog a hitelállomány változásával.

> bizonyíték: `t50b` — őr: ✅ `t50b: a chi elojele atfordul a nevezo javitasaval (A: -0.01167 -> C: +0.00857) - a negativ eredmeny mutermek volt`  
> *2026-08-16 · Módszertani figyelmeztetés a panel egészére. A nevező év végi állomány, a számláló évközi kamat.*

**A16.** A magyar vállalati kamattranszmisszió pontbecslése MIND A NÉGY specifikációban magasabb a nagyvállalatnál, mint a KKV-nál — de a méret szerinti különbség statisztikailag NEM különböztethető meg nullától: mind a négy 95%-os konfidencia-intervallum tartalmazza a nullát (t = 1,17…1,85).

> bizonyíték: `t25, t25b` — őr: ✅ `t25: mind a 4 becslesben a NAGYVALLALATI atgyuruzes a magasabb`  
> *2026-08-16 · ÁTFOGALMAZVA 2026-08-21: a CI-k most számként is megvannak (t25b). Különbségek (L−S) és 95% CI: bankközi szint +0,071 [−0,004; +0,146]; állampapír szint +0,115 [−0,077; +0,307]; bankközi kumulált +0,353 [−0,120; +0,826]; állampapír kumulált +0,594 [−0,325; +1,512]. EZ A V03 VISSZAVONÁSÁNAK EMPIRIKUS ALAPJA: a t_S > t_L feltevés nemcsak nem azonosított — a pontbecslések következetesen az ELLENKEZŐ irányba mutatnak. LEÍRÓ regularitásként áll, strukturális pass-through paraméterként NEM. KORLÁTOK: az ECB MIR összeg-kategória a méret PROXYja; a szint-együtthatók 1 fölöttiek (közös trend); a se(d) korrelált hibák mellett konzervatív.*

**A17.** A kockázati besorolások közti nyers hitelhozzáférési szakadék nagyrészt ÖSSZETÉTEL-HATÁS: méretre, ágazatra, régióra és évre kiigazítva a 14,3 pontos rés (A 18,4% vs C 4,2%) 2,5 pontra zsugorodik (12,9% vs 10,4%).

> bizonyíték: `t10, t11` — őr: ✅ `t11: a hozzaferesi res OSSZETETEL-HATAS (nyers 14.3 pp -> kiigazitott 2.5 pp)`  
> *2026-08-16 · Vagyis nem a kockázati besorolás zárja ki a céget a hitelből, hanem a mérete és az ágazata. Ez a modell szempontjából lényeges: az access-margót MÉRET szerint kell specifikálni, nem kockázat szerint — ahogy a v09 teszi. A probit együtthatói (t10) ugyanezt mutatják: bes_C = -0,203 (t = -7,4).*

**A18.** A magyar KKV-hitelárazás 2021–24-ben LESZAKADT a piaci kamattól: a medián implicit ráta 2,3%-ról csak 4,5%-ra nőtt, miközben a BUBOR 1,5%-ról 14,3%-ra — és 2023-ban a ráták mindössze 18,7%-a volt piaci árazású.

> bizonyíték: `t12` — őr: ✅ `t12 LESZAKADAS: 2023-ban a BUBOR 14.3%, a median KKV-rata csak 4.5% (2021: 2.3%)`  
> *2026-08-16 · Ez a PROGRAMVEZÉRELTSÉG (A04) árazási megfelelője: az A04 a hozzáférésről szól, ez az árról. A kettő együtt magyarázza, miért nem azonosítható a 2021-24-es epizódból sem a chi (V04), sem az ACCSCALE (A06), sem a t_S/t_L (V03) — a piaci kamat varianciája nem ért el a KKV-hitelekig.*

**A19.** A piaci árazású alminta rátája a teljes minta 2,6–3,5-szerese (12,6–13,8% vs 3,7–4,9%), és ebben az almintában a kockázati besorolás szerinti sorrend ELTŰNIK: a legjobb besorolású cég (A: 12,92%) drágábban hitelez, mint a C (12,64%).

> bizonyíték: `t13` — őr: ✅ `t13: a piaci alminta rataja a teljes minta tobbszorose (A: 3.5x, B: 3.1x, C: 2.6x)`  
> *2026-08-16 · Következmény: a teljes mintában látszó „kockázati árazás” (A 3,68% < C 4,93%) NEM kockázati árazás, hanem PROGRAM-ÖSSZETÉTEL — a jobb besorolású cégek nagyobb arányban jutnak támogatott hitelhez. Óvatosan: a D osztály piaci almintája n=7, arra nem szabad hivatkozni.*

**A20.** A BENCHMARK-ALAPÚ IMPLICIT FINANSZÍROZÁSI ÁRAZÁSI RÉS a magyar KKV-hitelállományon 2023-ban 557 Mrd Ft (BUBOR-referenciával), illetve 665 Mrd Ft (BUBOR+200 bp) — az állomány 9,6%-a —, és a cégek 78,5%-a a BUBOR alatt volt árazva.

> bizonyíték: `t14` — őr: ✅ `t14: 2023-ban az implicit tamogatasi ek 557 Mrd Ft (az allomany 9.6%-a), a cegek 78.5%-a alularazott`  
> *2026-08-16 · ÁTNEVEZVE 2026-08-21, külső bírálat nyomán: a korábbi név („implicit támogatási ék”) TÚL ERŐS. A szám valójában állomány × (benchmark kamat − megfigyelt implicit kamat) alakú KONTRAFAKTUÁLIS RÉS. NEM azonos állami támogatással, fiskális kiadással, banki veszteséggel, vagy a kedvezményezettnél jelentkező transzfer jelenértékével — az ék egy részét a bankok és a fix kamatozású régi állomány (vintage) viselik. A név azért lényeges, mert a SZÁMOT a név kíséri a sajtóba: „600 milliárd állami támogatás” nem védhető a jelenlegi módszertannal. Ráadásul az implicit ráta maga is mérési konstrukció (lásd A15). Nagyságrendi viszonyítás: EU-25 állami támogatás 2004-ben a GDP ~0,6%-a; ez ~0,8%.*

**A21.** A nominális bérmerevség a magyar cégpanelen GYENGE 2023–24-ben: a cégek 10,1%-a nominálisan CSÖKKENTETTE az átlagbért és csak 2,8% fagyasztotta be, a medián béremelés 11,6% — és a csökkentés monoton csökken a mérettel (13,9% / 7,6% / 5,8%).

> bizonyíték: `t17` — őr: ✅ `t17: a nominalis bercsokkentes MONOTON csokken a merettel (13.9% > 7.6% > 5.8%)`  
> *2026-08-16 · KORLÁTOK: egyetlen év-pár (a létszám csak 2023-ra és 2024-re ismert); MAGAS INFLÁCIÓS környezet, ahol a lefelé-merevség kevésbé köt — tehát ez ALSÓ korlát a merevségre; az átlagbér (bérköltség/létszám) összetétel-hatást is visz. Nem cáfolja a JV becsült xi_w = 0,657-ét, de jelzi, hogy a magyar bérmerevség méretfüggő lehet.*

### 🟡 Ami FELTÉTELES — 5 db

*Csak a feltétellel együtt közölhető — küszöbformában, vagy az elfogadási feltétel kiírásával.*

**F01.** A KKV-blokk SZEGMENS-KIBOCSÁTÁSA akkor előzi meg a nagyvállalatit, ha ACCSCALE ≥ 22,3 | rho_acc = 0,9673 (átvett rho_acc = 0,85 mellett 36,5). A küszöb a két paraméter EGYÜTTES függvénye: a nulla-kontúr 47,8-tól (rho = 0,85) 17,5-ig (rho = 0,98) fut.

> bizonyíték: `t48, t48b, t49, t51` — őr: ✅ `t51 KONTUR: a kuszob MONOTON csokken a rho_acc-ban (47.8 -> 17.5)`  
> *2026-08-16 · KÜSZÖBFORMA, és 2026-08-21-től KÉTDIMENZIÓS (f27/t51): a 22,3 nem becsült küszöb, hanem MODELLBELI KÖZÖMBÖSSÉGI PONT egy adott rho_acc és kalibráció mellett. Mindkét tengely horgonyzatlan (A06, A11), ezért a kondicionálás mindig kiírandó. PONTOSÍTÁS: az összevetés SZEGMENS-KIBOCSÁTÁS (y_j = bruttó kibocsátás), NEM GDP-részesedés — a y_j importált köztes inputot használ, a modellben nincs és nem is lehet y = Σ om_j·y_j azonosság.*

**F02.** Az export-KKV kibocsátásának ELŐJELE az eps_ces-en fordul, ~2,3-nál.

> bizonyíték: `t42` — őr: ✅ `t42: az y_E ELOJELE eps_ces-fuggo (dokumentalt KORLAT, kuszobforma kell)`  
> *2026-08-12 · Az aggregált GDP érzéketlen rá (0,008 pp sáv) — csak a szektorális eredményt viszi.*

**F03.** Az om_j / shl_j súlyok az Opten-panelből: 0,256/0,184/0,560 és 0,157/0,378/0,466.

> bizonyíték: `t46` — őr: ✅ `t46: az om_j es az shl_j sulyok 1-re osszegzodnek`  
> *2026-08-16 · ELFOGADÁSI FELTÉTEL: ezek a 10+ fős populáción BELÜLI részesedések. Teljes gazdaságra KSH/Eurostat SBS mikrokör-bontás kell (teendők 2.5). Addig -DOPTEN alapértelmezése 0.*

**F04.** A chi (BGG felár-rugalmasság) alsó korlátja a magyar panelen +0,002 negyedéves; az irodalmi érték 0,042–0,067.

> bizonyíték: `t50b; Christensen–Dib (2008) 2. tábla` — *nincs őr*  
> *2026-08-16 · A becslés erősen attenuált (mérési hiba, átlagos vs határráta, programvezéreltség). NEM cáfolja az irodalmi értéket — alulazonosított.*

**F05.** Az euró-hatás gyakorlatilag TELJES EGÉSZÉBEN a szuverén csatornán megy: a banki csatorna hozzájárulása az első negyedévben a teljes hatás 0,22%-a (−0,0005 pp a −0,252 pp-ból).

> bizonyíték: `t15` — őr: ✅ `t15: a hatas gyakorlatilag teljesen a SZUVEREN csatornan megy (a banki resz 0.22%) — de a v03 ARCHIV modellen`  
> *2026-08-16 · ELFOGADÁSI FELTÉTEL: ez a jv_dsge_v03 ARCHÍV modellen készült (kétszektoros, háromtípusos szerkezet nélkül, access-margó nélkül). A fő modellen (v09) ÚJRA KELL FUTTATNI, mielőtt közöljük — a v09-ben a banki csatorna az access-margón át is hat, tehát a súlya vélhetően nagyobb. Amíg ez nincs meg, csak a v03-ra vonatkozó megállapításként idézhető.*

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

## Őrök (116 db)

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
- ✅ t43: mind a 18 fuggetlen ellenorzes atment
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
- ✅ t25 transzmisszio letezik
- ✅ t25: mind a 4 becslesben a NAGYVALLALATI atgyuruzes a magasabb
- ✅ t25: egyik meret szerinti kulonbseg sem szignifikans 5%-on
- ✅ t11 hozzaferes kiigazitott letezik
- ✅ t11: a hozzaferesi res OSSZETETEL-HATAS (nyers 14.3 pp -> kiigazitott 2.5 pp)
- ✅ t12 rata-eloszlas letezik
- ✅ t12 LESZAKADAS: 2023-ban a BUBOR 14.3%, a median KKV-rata csak 4.5% (2021: 2.3%)
- ✅ t12: 2023-ban a ratak mindossze 18.7%-a volt piaci arazasu
- ✅ t13 piaci alminta letezik
- ✅ t13: a piaci alminta rataja a teljes minta tobbszorose (A: 3.5x, B: 3.1x, C: 2.6x)
- ✅ t13: a piaci almintaban a kockazati sorrend ELTUNIK (A 12.92% > C 12.64%)
- ✅ t14 tamogatasi ek letezik
- ✅ t14: 2023-ban az implicit tamogatasi ek 557 Mrd Ft (az allomany 9.6%-a), a cegek 78.5%-a alularazott
- ✅ t15 csatorna-dekompozicio letezik
- ✅ t15: a hatas gyakorlatilag teljesen a SZUVEREN csatornan megy (a banki resz 0.22%) — de a v03 ARCHIV modellen
- ✅ t17 beralkalmazkodas letezik
- ✅ t17: a nominalis bercsokkentes MONOTON csokken a merettel (13.9% > 7.6% > 5.8%)
- ✅ t17: GYENGE nominalis merevseg 2023-24-ben (10.1% csokkentett, csak 2.8% fagyasztott)
- ✅ t25b transzmisszio-CI letezik
- ✅ t25b: mind a 4 becslesben L > S (egyiranyu pontbecslesek)
- ✅ t25b: mind a 4 CI TARTALMAZZA a nullat - a kulonbseg nem szignifikans
- ✅ t25b: 0 szignifikans kulonbseg (max |t| = 1.85)
- ✅ t51 kuszobfelulet-kontur letezik
- ✅ t51 KONTUR: a kuszob MONOTON csokken a rho_acc-ban (47.8 -> 17.5)
- ✅ t51 SZINT: a kontur vegpontjai az F01-ben kozolt szamokon (47.8 / 22.2)
- ✅ t00 PHILLIPS: az aszimmetrikus arsokkok (eps_md / eps_mx) egyik szcenarioban sincsenek hajtva
- ✅ t00 SZERKEZET: mind a 4 modell-vonal megvan, README-vel
- ✅ t00 SZERKEZET: a FO MODELL a helyen van (1_fo_vonal_jv)
- ✅ t00 SZERKEZET: minden futtato letezo .mod-ot hiv (29 futtato, 19 modell)

</details>
