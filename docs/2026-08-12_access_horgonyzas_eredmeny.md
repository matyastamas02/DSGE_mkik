# Az access-paraméterek horgonyzása — nem sikerült, és ez maga is eredmény

*2026-08-12 · `src/s14_access_horgonyzas.m` → `t36`, `t37`, `f26`.
Válasz Samu `v07_access` összefoglalójának 7. pontjára („Mi a következő
empirikus feladat?").*

## Miért ez volt a következő lépés

A `v07_access` a projekt eddigi legjobban megalapozott iránya: a KKV-előnyt
nem egy feltevésből (`t_S > t_L` vagy `chi_S > chi_L`) hozza ki, hanem egy
külön **hitelhozzáférési (extenzív) margóból** — és ez az egyetlen
aszimmetria a projektben, amire **van saját adatunk**.

Két dolog tette sürgőssé:

1. Samu doksija maga nevezte meg következő feladatként: *„Meg kell becsülni
   vagy legalább sávosan kalibrálni, hogy egy 100 bp-os felárcsökkenés
   mekkora változást okoz a KKV-k hitelhozzáférési arányában."*
2. **A küszöb a baseline-on ül.** A `t33` szerint a súlyozott KKV-blokk
   `ACCSCALE = 101,0`-nél előzi meg a nagyvállalatot, a baseline pedig
   `ACCSCALE = 100`. Vagyis a kvalitatív válasz („nyer-e a KKV?") pontosan
   a választott kalibrációs pontban fordul át. Amíg az `ACCSCALE`
   horgonyzatlan, a tanulmány nem állíthatja, hogy „a KKV nyer".

## Amit az adat mond

Opten-panel, 148 225 cég-év, 37 805 cég, 2021–2024. Szegmensek Samu
bontása szerint: **E** = export-KKV, **D** = hazai KKV, **L** = nagyvállalat.

| Szegmens | n/év | 2021 | 2022 | 2023 | 2024 | sávszélesség |
|---|---:|---:|---:|---:|---:|---:|
| E export-KKV | ~4 300 | 61,7% | 63,0% | 62,2% | 60,8% | **2,2 pp** |
| D hazai KKV | ~31 700 | 4,5% | 4,7% | 5,1% | 5,1% | **0,6 pp** |
| L nagyvállalat | ~1 070 | 44,1% | 43,8% | 43,0% | 43,4% | **1,1 pp** |
| *BUBOR (éves átlag)* | | *1,46%* | *9,97%* | *14,30%* | *7,30%* | ***12,8 pp*** |

> **A BUBOR 12,8 százalékpontot mozgott. A hozzáférési arányok kevesebb mint
> 1–2 pontot. A hozzáférés gyakorlatilag mozdulatlan.**

Modell-egységre váltva ez `ACCSCALE ≈ 0–16`-ot adna a szükséges **101**
helyett — az export-KKV-nál ráadásul **rossz előjellel**.

## De ez NEM azt jelenti, hogy az access-csatorna halott

Két olvasat van, és **a második a valószínűbb**:

**(A)** A hozzáférés valóban érzéketlen a kamatra → az access-csatorna nem
tudja hozni, amit a modell igényel, tehát a `v07` fő eredménye nem áll.

**(B)** A 2021–24-es magyar epizód **nem azonosítja** ezt. A támogatott
programok épp akkor bővültek, amikor a piaci kamat tetőzött. Ennek a
legtisztább bizonyítéka, hogy a **D-szegmens hozzáférése monoton NŐ a
kamatcsúcs felé** (4,5% → 5,1%), miközben a BUBOR 1,5%-ról 14,3%-ra ment.
Amit mérünk, az a **politikával stabilizált** hozzáférés, nem a piaci reakció.

**Ez ugyanaz a betegség, ami a `t_S`/`t_L` tesztet is érvénytelenítette**
(lásd `FIGYELMEZTETES_fo_allitas.md`): a magyar KKV-hitelpiac ebben az
időszakban programvezérelt volt, ezért a **piaci** kamat varianciája nem
azonosítja a **piaci** kamatra vett rugalmasságot.

## Következmény a modellre

1. **Az `ACCSCALE` ebből az adatból nem horgonyozható.** A `v07` eredményét
   továbbra is **küszöbként** kell közölni — és a küszöb mellé oda kell írni,
   hogy a küszöbértéket jelenleg **nem tudjuk magyar adatból megmondani**.
   Ez nem gyengíti a modellt: a küszöbforma épp arra való, hogy a
   döntéshozó a saját becslését behelyettesíthesse.
2. **Amit viszont megerősít:** ha a programok a kamatciklus ellenére is
   tartják a KKV-hozzáférést, akkor a releváns kérdés nem az, hogy az euró
   mennyivel viszi lejjebb a piaci kamatot, hanem hogy **mi történik a
   programok kifutásakor** — azaz a támogatás-kivezetési irány.
3. **A modellezés melléktermékeként egy erős leíró tény:** az export-KKV-k
   hozzáférése **13-szorosa** a hazai KKV-kénak (61,9% vs 4,8%), és
   magasabb, mint a nagyvállalatoké (43,4%). Ez önmagában alátámasztja Samu
   E/D szétválasztását — a „KKV" mint egyetlen blokk félrevezető.

## Mit lehetne még megpróbálni (nem kizárt, hogy megy)

- **2021 előtti minta.** A programvezéreltség az NHP/Széchenyi-bővítés
  előtt gyengébb volt; ha van korábbi panel, ott a piaci variancia többet
  azonosít.
- **Keresztmetszeti azonosítás** időbeli helyett — de az implicit kamat csak
  a hitellel rendelkezőkre figyelhető meg, tehát szelekciós problémába fut.
- **Nemzetközi becslés** átvétele explicit külső horgonyként, jelölve, hogy
  nem magyar adat.
- **MNB méret szerinti új-szerződéses statisztika** (a `FIGYELMEZTETES`
  8/5. teendője) — ez továbbra is a legígéretesebb hiányzó adat.

## Korlátok

- 4 év, egyetlen kamatciklus; a szint-együttható konfundált (COVID-kilábalás,
  háború, programindulás és -kifutás). A védhető objektum a **különbség**
  (interakció), nem a szint.
- **A mikrocégek (<10 fő) nincsenek a panelben**, pedig ott koncentráltabb a
  Széchenyi Kártya → a hozzáférési reakció valószínűleg **alulbecsült**.
- A BUBOR nem azonos a vállalati felárral; a modell `efp`-je felár, nem
  alapkamat. Az átváltás ezt 1:1-nek veszi — ez **felső korlát** jellegű.
