# Ábraterv — euró/KKV DSGE tanulmány

*Mit kell ábrázolni egy ilyen modellnél; az irodalmunk konvenciói + a
háromrétegű architektúra alapján. Jelölve, mi van már meg (f01–f06) és mi
hiányzik. Minden ábra scriptből készül (`src/`), a repo-szabály szerint.*

## A) Modell-validáció és mechanizmus (DSGE-standard)

*Minta: BGG 1999, Gerali et al. 2010, MNB WP 2017/7, Jakab–Világi 2008.*

| # | Ábra | Minta az irodalomból | Állapot |
|---|---|---|---|
| A1 | **IRF-panelek sokkonként** (y, c, i, π, r, rer, EFP, nw — 3×3 rács), KKV/nagyvállalat overlay-jel | MNB WP 2017/7 a 4 globális sokkra; BGG; Gerali | részben: f04 (csak banki sokk, 2 változó) → **kell a teljes panel** min. 4 sokkra |
| A2 | **Akcelerátor ki/be** összehasonlítás: ugyanaz a sokk χ=0 (akcelerátor nélkül) vs. kalibrált χ mellett | BGG 1999 klasszikus ábrája — a mechanizmus létjogosultságának bizonyítéka | hiányzik |
| A3 | **EFP–nettó vagyon–tőkeáttétel dinamika** egy sokk után (a pénzügyi blokk „belseje") | BGG, Gerali | hiányzik |
| A4 | **Momentum-egyeztetés**: modell- vs. Opten-momentumok (szórások, korrelációk; EFP-szintek szektoronként) | estimált papereknél prior–posterior; nálunk kalibráció-védés | hiányzik |
| A5 | **Érzékenységi pókháló/tornado**: hosszú távú GDP a kulcsparaméterek (zsov, χ_S, transzmissziók) variálására | MT24 érzékenységi táblái | hiányzik |

## B) Szcenárió-eredmények (euró-irodalom konvenciói)

*Minta: MT24 (Csajbók–Csermely), Kunovac–Pavić 2017, Žúdel–Melioris 2016.*

| # | Ábra | Minta | Állapot |
|---|---|---|---|
| B1 | **Három pálya (alap/opt/pessz)** a fő makrováltozókra — GDP megvan, kell: beruházás, fogyasztás, infláció, kamat, reálárfolyam panel | MT24 szcenáriói | részben: f05/f06 (GDP + szektorális) |
| B2 | **Fázis-annotált idővonal**: az 5 szakasz (bejelentés → ERM-II → belépés → normalizálódás → tartós) függőleges sávokkal, a belépés előtti dip kiemelésével | saját (a v0.3 fő időprofil-eredménye) | hiányzik — kommunikációs kulcsábra |
| B3 | **Csatorna-dekompozíció**: a GDP- és kamatpálya felbontása szuverén / banki / UIP komponensre (a linearitás miatt additív) — halmozott terület | Gerali/EAGLE historikus dekompozíció analógja | hiányzik |
| B4 | **Modell vs. horvát ex-post**: a modell-implikált vállalatikamat-konvergencia a HNB tényadataira vetítve — az empirikus horgony vizualizálása | Kunovac–Pavić; Žúdel–Melioris counterfactual-gap stílus | hiányzik — a védhetőség kulcsa |

## C) 2. réteg — szegmens-leképezés (saját, adathoz kötött)

*Minden ábrán kötelező „kalibrált leképezés — nem DSGE-predikció" jelölés (pitch 3. védendő pont).*

| # | Ábra | Állapot |
|---|---|---|
| C1 | **Szegmens-oszlopok**: kamatcsökkenés (bp) kockázati kategóriánként (A–B / B–C / C–D) a három szcenárióban | hiányzik (a pitch segs-sávjainak számolt változata) |
| C2 | **Implicit kamatráta-eloszlás eltolása**: Opten-eloszlás ma vs. euró után (density overlay) | hiányzik |
| C3 | **Szegmens-hőtérkép**: méret × besorolás (és régió × ágazat) → reálhatás | hiányzik |
| C4 | **NUTS-2 térkép** a régiós hatásokról — a felzárkózási üzenethez | hiányzik |

## D) 3. blokk — extenzív margó (empirikus kísérőblokk)

| # | Ábra | Állapot |
|---|---|---|
| D1 | Hitelhozzáférés besorolásonként (leíró) | megvan: f03 |
| D2 | **Becsült hitelhozzáférés-valószínűség** kamatszint függvényében, szegmensenként (a „C–D felszabadulás" számszerűsítve) | hiányzik (előbb a becslés kell) |
| D3 | **Besorolás-átmenetek** vizualizálása (t06 mátrix → hőtérkép) | tábla megvan (t06), ábra hiányzik |

## E) Döntéshozói / kamarai kommunikáció

| # | Ábra | Állapot |
|---|---|---|
| E1 | **Headline-ábra**: 3 kulcsszám (tartós GDP-szint; KKV-kamatcsökkenés sávja; a C–D szegmens nyeresége) stat-tile formában | hiányzik |
| E2 | **Háromrétegű architektúra-diagram** (mi fut modellként / mi leképezés / mi empíria) — a módszertani őszinteség vizuális védjegye | pitch-ben létezik HTML-ben → tanulmány-verzió kell |
| E3 | Meglévő leíró ábrák (f01: EFP besorolásonként, f02: kamatkörnyezet idősor) a motivációs fejezetbe | megvan |

## Prioritási javaslat

1. **A1 + A2** (IRF-panelek, akcelerátor ki/be) — a modellfejezet gerince,
   már most elkészíthetők a v0.3-ból.
2. **B2 + B3** (fázis-idővonal, csatorna-dekompozíció) — a szcenáriófejezet
   kulcsábrái, szintén elkészíthetők.
3. **B4** (horvát validáció) — HNB-adat beszerzését igényli.
4. **C1–C3** — a 2. réteg scriptje után; **D2** — az ökonometriai becslés után.
5. **E1–E2** — a tanulmány-szöveg véglegesítésekor.
