# Tanulmány-váz — Az euróbevezetés hatása a magyar KKV-szektor hitelkörnyezetére

*Fejezetszintű outline; minden fejezetnél a kész (✔) és tervezett (○)
ábrák/táblák, a kapcsolódó scriptek és jegyzetek. A keretezés a
2026-07-08-i red flag-vizsgálat utáni állapotot tükrözi
(`docs/red_flag_vizsgalat.md`).*

## Vezetői összefoglaló (2 oldal)

A három üzenet: (1) a mai KKV-hitelpiac állami kamattámogatáson él — az
euró az egyetlen pálya, ahol ennek kivezetése nem sokk; (2) a hatás
heterogén: a nyertesek a hitelhez most nem jutó kis cégek (extenzív
margó), nem a már bent lévők; (3) a hatás feltételes: fiskális
hitelesség + banki transzmisszió + fokozatos programkivezetés.
○ E1 headline stat-tile (támogatási ék 2023: ~520–630 Mrd Ft/év; tartós
GDP +0,3–0,7%; hozzáférési szakadék).

## 1. Motiváció és kutatási kérdés

Miért a hitelcsatorna (és nem az árfolyam): mérhető, tartós, és a horvát
ex-post tapasztalat is ezt igazolja. A három alkérdés (mennyi, kinek,
milyen reálhatással). ✔ f02 (kamatkörnyezet 2021–25), ✔ f09 (a piac
kettészakadt: támogatott vs. piaci árazás), ✔ t14 (a támogatási ék).
*Jegyzet: a megrendelői pozíció ("C–D a fő nyertes") finomítva — lásd
red_flag_vizsgalat.md.*

## 2. Adat: az Opten vállalati panel

37 805 cég, 150 982 cég-év, 2021–2025; építés: `01_opten_panel_tisztitas.py`;
minőség: adathelyzet-jelentés. Szegmentáció: méret / ágazat / NUTS-2
(hivatalos IrszHnk-térkép) / kockázati besorolás. Korlátok nyíltan: AVG
tisztázás alatt, implicit ráta = állomány-alapú (az új hitelek árazását
nem méri), 2025 részleges. ✔ t01–t06 leíró táblák, ✔ f01, f03.

## 3. Stilizált tények — a piac diagnózisa

3.1 A hozzáférés a fő heterogenitás, nem az ár: ✔ f03 (nyers), ✔ f08
(kiigazított — az összetétel-hatás), ✔ t13 (a piaci almintában is lapos
árazás). 3.2 A támogatott árazás dominanciája: ✔ f09, ✔ t12 (2023:
medián 4,5% vs. BUBOR 13,6%). 3.3 A támogatási ék: ✔ t14.
○ D3: besorolás-átmenetek hőtérképe (t06-ból).

## 4. A modell

Háromrétegű architektúra (○ E2 diagram a pitch-ből). DSGE-mag
(2026-07-13-i alapcikk-váltás után): **Jakab–Világi (MNB WP 2008/9)**,
magyar adaton becsült paraméterekkel, méretfüggő BGG-akcelerátorral a
finanszírozási oldalon; két hitelköltség-csatorna exogén pályaként;
UIP-csatorna + kamatunió-rezsimváltás. Kód: `src/model/jv_dsge_v03.mod`;
az EAGLE-vonal (kkv_dsge_v0x) robusztussági referencia. Kalibráció:
JV-poszteriorok + Opten pénzügyi blokk (t02, t03).
✔ f10–f12 IRF-panelek, ✔ f13 (az akcelerátor két arca: monetáris sokknál
erősít, prémium-sokknál az endogén tőkeáttétel tompít), ✔ f04.
○ A4 momentum-egyeztetési tábla.

## 5. Az euró-szcenárió eredményei

Időzítés és fázisok: ✔ f14 (a konvergenciás felértékelődési dip-pel).
Három pálya: ✔ f06, ✔ szcenario_v03 táblák (tartós GDP: +0,32/+0,49/+0,67%;
a 10 éves pont a tartós szint ~22%-a — mindkettő riportálandó).
Csatorna-dekompozíció: ✔ f15 (a szuverén csatorna dominál). 2. réteg
(kalibrált leképezés, nyíltan jelölve): ✔ f07, ✔ t09 — a szegmensek közti
különbség mérsékelt (−41…−55 bp alap), a fő üzenet nem itt él.
○ B4 horvát validációs overlay (HNB-adat kell), ○ A5 érzékenységi tornado.

## 6. Az extenzív margó — a fő üzenet második lába

✔ t10–t11, ✔ f08. A kamat→hozzáférés rugalmasság azonosítási korlátja
nyíltan (M2 konjunktúra-torzított) → irodalmi érték / horvát ex-post
használata. ○ D2 becsült hozzáférési görbék a jobb azonosítás után.

## 7. Szakpolitikai következtetések

(1) Az euró mint kivezetési stratégia az állami kamattámogatásból — az
ék (t14) fiskális megtakarítás-potenciálja. (2) Fokozatos programkivezetés
a belépés körül (szakadék helyett lejtő). (3) Banki verseny-monitoring
(transzmisszió). (4) Extenzív margó támogatása: hitelinformációs
infrastruktúra a most kiszoruló kis cégeknek. (5) ERM-II kommunikáció:
a dip kezelése (f14).

## 8. Korlátok és érzékenység

Deviza-dimenzió proxy-k; 5 éves sokk-terhelt panel; reprezentatív
háztartás (Euler-pinning — a hozamgörbe-csatorna alsó becslés);
rezsimváltás (kamatunió) v0.4-ben; AVG-kérdés. Három pálya = explicit
bizonytalansági sáv.

## Appendix

A. Modellegyenletek. B. Kalibrációs táblák. C. Adatépítés és
reprodukció (`run_all.m`, füstteszt). D. Leképezési szabály és
érzékenysége. E. Irodalom (Notion-adatbázisból generálva).
