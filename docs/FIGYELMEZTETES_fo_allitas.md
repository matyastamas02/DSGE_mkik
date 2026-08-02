# ⚠ FIGYELMEZTETÉS: a projekt fő állítása empirikusan nem áll

*2026-07 · A KKV/nagyvállalat layer empirikus tesztelésének eredménye.
Ez a dokumentum szándékosan éles és nem szépít. Csapatdöntést igényel,
mielőtt a hétfői előadás vagy a tanulmány bármit állít a KKV-előnyről.*

---

## Az állítás, amit teszteltünk

> „Az euró-bevezetés a KKV-knak többet segít, mint a nagyvállalatoknak,
> mert a KKV-k hitelfelára érzékenyebben reagál a prémium-csökkenésre."

Ez a projekt fő hipotézise, a modellválasztási javaslat központi tézise,
és a HTML-dokumentációkban közölt eredmények alapja.

## Amit az adat mond

Magyar kamatstatisztika (ECB MIR + Eurostat, 2017–2026;
`src/08_mnb_transzmisszio.py` → `t25_transzmisszio.csv`). A vállalati új
hitelek kamatának kumulált pass-through-ja, összeg-kategória szerint
(≤1M EUR = KKV-proxy, >1M EUR = nagyvállalati proxy):

| Referencia | KKV-proxy | Nagyvállalati proxy | Különbség |
|---|---|---|---|
| Bankközi kamat (BUBOR) | **0,299** | **0,652** | −0,353 (t = −1,46) |
| 10 éves állampapírhozam | **0,206** | **0,800** | −0,594 (t = −1,27) |

Szint-becslésben ugyanez az irány (0,851 vs. 0,922 és 1,657 vs. 1,772).

**Két megállapítás:**
1. A különbség 5%-on **nem szignifikáns** (|t| = 1,2–1,9) — a nullhipotézist
   nem tudjuk elvetni.
2. **De a pontbecslés mind a NÉGY specifikációban fordított előjelű**: a
   nagyvállalati kamat reagál erősebben, nem a KKV-é. A modell feltevése
   (t_S > t_L) tehát nemcsak megalapozatlan, hanem az adat gyengén az
   **ellenkezőjét** támogatja.

**Közgazdasági magyarázat (és ez konzisztens a projekt korábbi
eredményével):** a nagyvállalati hitelek jellemzően változó, BUBOR-hoz
kötött kamatozásúak → azonnal követik a piacot. A KKV-hitelek nagy része
fix kamatozású vagy támogatott programban van (NHP, Széchenyi) → **nem
követik a piaci kamatot**. A projekt red flag-vizsgálata ezt már
kimutatta: a KKV-hitelállomány ~80%-a a piaci szint alatt árazódott.

## Mit jelent ez a modellre — a döntő teszt

`src/model/sens_tsuly_v05.m` → `t26_tsuly_teszt.csv`. Ugyanaz a modell,
három paraméterezéssel:

| Paraméterezés | KKV-felár | Nagyváll. | KKV-beruházás | Nagyváll. beruh. | Teljesül az állítás? |
|---|---|---|---|---|---|
| **Feltevés** (t_S > t_L) | −39,1 bp | −25,6 bp | **+1,35%** | +0,82% | ✔ igen |
| **Empirikus** (t_S < t_L) | −26,7 bp | −46,1 bp | **−1,61%** | +4,19% | ✘ **megfordul** |
| **Egyenlő** (t_S = t_L) | −31,2 bp | −38,2 bp | **−0,13%** | +2,51% | ✘ **nem** |

### A három következtetés, szépítés nélkül

1. **A „KKV többet nyer" eredmény kizárólag a t_S > t_L feltevésen áll.**
   Nem a modell strukturális következménye, nem az adat állítása — hanem
   annak a paraméterválasztásnak a következménye, amit mi tettünk bele.

2. **Az empirikus súlyokkal az eredmény megfordul:** a KKV-beruházás
   **negatívba** fordul (−1,61%), a nagyvállalati pedig +4,19%. Vagyis
   az adatot követve a modell azt mondja, hogy az euró-bevezetés
   **a nagyvállalatoknak kedvez, a KKV-knak nem.**

3. **Még a legsemlegesebb feltevéssel (egyenlő súlyok) sem áll az
   állítás.** A KKV-beruházás gyakorlatilag nulla (−0,13%), a
   nagyvállalati +2,51%. Ez azt jelenti, hogy **a BGG-akcelerátor
   (χ_S > χ_L) önmagában nem elég** a KKV-előny létrehozásához — amit
   pedig a layer fő mechanizmusaként mutattunk be.

## Amit ez NEM jelent

Nem jelenti, hogy az euró rossz a KKV-knak. Azt jelenti, hogy **a modell
jelenlegi mechanizmusa (piaci prémium-transzmisszió) nem tudja
alátámasztani a KKV-előnyt** — mert ez a mechanizmus épp azon a
csatornán működik, amelytől a magyar KKV-k jelenleg el vannak szigetelve
(támogatott, fix kamatok).

## Ahol a valódi történet lehet — de amit a modell MOST NEM tartalmaz

A projekt korábbi, empirikusan legerősebb eredménye az volt, hogy a
KKV-hitelállomány ~80%-a támogatott/fix árazású, és az implicit
támogatási ék 2023-ban 557–665 Mrd Ft/év volt. Ebből az következik,
hogy a KKV-k szempontjából a releváns kérdés **nem** az, hogy mennyivel
csökken a piaci kamat, hanem hogy **mi történik, ha a támogatási
programok kifutnak** — és ott az euró tényleg védelmet nyújt (a piaci
szint 13% helyett 5–7% lenne).

**De ez egy MÁS mechanizmus, mint amit a modell modellez.** A modellbe
ez nem prémium-transzmisszióként, hanem a támogatás-kivezetés
szcenáriójaként épülne be. Ez a modell következő fejlesztési iránya —
és amíg nincs benne, a KKV-előnyre vonatkozó modell-eredményeket nem
lehet közölni.

## Javasolt döntések (csapat)

1. **A hétfői előadásból ki kell venni a „KKV −44 bp vs. nagyvállalat
   −28 bp" típusú állításokat**, vagy explicit „ez a feltevésünk
   következménye, nem empirikus eredmény" jelöléssel kell közölni.
2. **Az alapkalibráció kérdése:** maradjon-e a t_S > t_L (átlátszóan
   feltevésként jelölve), vagy váltsunk az egyenlő súlyokra (semlegesebb,
   de akkor nincs KKV-előny)? Ez érdemi döntés, nem technikai.
3. **A modell következő iránya:** a támogatás-kivezetési szcenárió
   beépítése — ez az, ahol a KKV-történet empirikusan megalapozható.
4. **A transzmisszió jobb azonosítása:** az összeg-kategória csak proxy;
   az MNB-nek van részletesebb, méret szerinti bontása, amihez kérésre
   hozzá lehet jutni. Ez eldöntheti, hogy a fordított előjel valódi-e.

## Korlátok (hogy a figyelmeztetés is korrekt legyen)

- Az összeg-kategória a méret **proxyja**, nem maga a méret.
- A kamatszintet más tényezők is befolyásolják (fedezet, lejárat,
  programhitelek) — a becslés irányadó, nem strukturális azonosítás.
- A különbség statisztikailag **nem szignifikáns**, tehát az sem
  bizonyított, hogy a nagyvállalat érzékenyebb. A biztos állítás az,
  hogy **a KKV nagyobb érzékenységére nincs empirikus alap**.
