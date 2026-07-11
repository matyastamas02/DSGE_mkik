# Munkanapló — 2026. július 8. (teljes munkamenet)

*Mit csináltunk, miért, hogyan, és mire jöttünk rá — lépésről lépésre.
A nap végi állapot: 15 commit, futó v0.1–v0.4 modellsor, kész adatpipeline,
16 ábra, 16 tábla, és egy érdemben újrakeretezett tanulmány-üzenet.*

---

## 1. Rendrakás: repo, adat, dokumentáció

**Mit:** duplikált repo-klón törlése (Lomtárba, tartalom-ellenőrzés után);
CLAUDE.md pontosítás; a Drive feltérképezése (adat / alapok / irodalom);
az `opten.xlsx` a helyére, a `data-index.md` kitöltve linkekkel; az
`alapok/` modell-vázlat a `docs/`-ba (ötletelés-státusszal jelölve).
**Miért:** hárman dolgozunk a repón — a "mi honnan jön" kérdésnek
egyértelműnek kell lennie. **Tanulság:** a Drive-on már élt egy kész
irodalmi jegyzet-készlet és Notion-adatbázis (11 feldolgozott tanulmány)
— a szakirodalmi alap készen állt.

## 2. Adatpipeline: nyers xlsx → tisztított cég-év panel

**Mit:** `01_opten_panel_tisztitas.py` — a 6 lapos Opten-fájlból egységes
panel (150 982 cég-év × 69 oszlop): kulcs pénzügyi mezők, kockázati
idősor, EU/közbeszerzés-jelzők, származtatott változók (implicit
kamatráta, van_hitel, exportarány, tőkeáttétel), NUTS-2.
**Hogyan ellenőriztük:** az adathelyzet-jelentés számaival szemben —
szinte minden pontosan egyezett (150 982 / 37 805 / 16,4% kamatfizető /
13,6% exportőr). **Tanulság:** az adat konzisztens és reprodukálhatóan
építhető; a forrásfájlban egy elírás volt ("ADÓZÓTT"), lekezelve.

## 3. Leíró statisztika — az első tartalmi jelek

**Mit:** `02_leiro_stat.py` + t01–t06 + f01–f03. **Mire jöttünk rá:**
(1) a kamatkörnyezet átment az adaton (medián implicit ráta 2,3%→5,3%);
(2) **a hitelkorlát az extenzív margón látszik, nem az árban** — A: 18,3%
vs. C: 4,1% hitel-incidencia, miközben a ráta-különbség mérsékelt;
(3) méret-dimenzió éles (6,7% vs. 41,6%); (4) a cégek 50,3%-ának
változott a besorolása → idősoros azonosítás lehetséges.

## 4. Modellválasztás lehorgonyzása

**Mit:** a pitch feldolgozása; az alapmodell azonosítása
(Békési–Kaszab–Szentmihályi, MNB WP 2017/7); utánajárás: **publikus
kód nincs** (ESCB-n belüli EAGLE), de a WP 26–43. oldala **teljes
egyenlet-appendix + kalibrációs táblák** → újraimplementálási döntés.
Notion döntésnapló létrehozva, az architektúra-döntések rögzítve.

## 5. v0.1 — a futó váz

**Mit:** 44 egyenletes, log-lineáris kétszektoros SOE-mag Dynare-ben,
szektoronkénti BGG-lite blokkal (χ_S=0,06 > χ_L=0,02; tőkeáttétel az
Opten-mediánokból). **Hogyan:** szűk mag a teljes EAGLE helyett —
adatfegyelem + sebesség. Egy relatívár-egységgyököt menet közben
javítottunk. **Eredmény:** BK teljesül; a méretfüggő akcelerátor
endogén aszimmetriát ad (banki sokkra KKV-EFP −28 vs. −13 bp, beruházási
válasz ~2×).

## 6. v0.2 — az euró-szcenárió

**Mit:** a prémiumok anticipált, permanens pályává váltak (perfect
foresight), 5-fázisú időzítéssel, 3 forgatókönyvvel. **Eredmény:** 10 éves
GDP +0,08–0,17% — **nagyságrenddel kisebb a vázlat 1,5–2%-ánál.**
**Tanulság (ez hajtotta a v0.3-at):** a szuverén konvergencia csak a
vállalati hitelfeláron hatott, a kockázatmentes görbe hiányzott.

## 7. v0.3 — WP-kalibráció + UIP-csatorna

**Mit:** kalibráció a WP appendix HU-oszlopából (β=0,99, Calvo 0,92,
Taylor 0,87/1,70/0,10 stb.) + zsov=0,5 UIP-országprémium csatorna, tiszta
dekompozícióval. **Eredmény:** hosszú táv **+0,32/+0,49/+0,67%**
(pessz/alap/opt), tartós KKV-többlettel; a felépülés lassú (10 évnél a
végső szint ~22%-a). **Két strukturális felismerés:** (1) a reprezentatív
háztartás Euler-egyenlete β-hoz köti a hosszú távú reálkamatot — az
UIP-csatorna ezért NFA/árfolyam-oldalra fut ki, a tartós hatást az
EFP-ék viszi; (2) **belépés előtti konvergenciás felértékelődési dip**
(~−0,2%) endogén módon adódik.

## 8. Előkészítő réteg: leképezés, extenzív margó, infrastruktúra

**Mit (innentől MATLAB-ban — MPT kérése):** s06 szegmens-leképezés
(modell-kimenet × Opten ráta-eloszlás), s07 extenzív margó probit
(148e cég-év), `run_all` reprodukciós lánc + 12 pontos füstteszt.
**Mire jöttünk rá:** (1) a leképezett szegmens-különbségek laposak
(−41…−55 bp) — nem a pitch meredek sémája; (2) a nyers hozzáférési
szakadék nagyját az összetétel viszi (kiigazítva A 12,9% vs. C 10,4%);
(3) a kamat→hozzáférés rugalmasság aggregát azonosítása bukik (rossz
előjel, konjunktúra-torzítás) — nyitott feladat.

## 9. A nap fordulópontja: a red flag szembenézés

**Mit:** MPT kérdésére ("ezek nem inkább red flagek?") célzott teszt
(s08): éves ráta-eloszlások vs. BUBOR + piaci alminta. **Eredmény:**
(1) a szint-kompresszió valós — 2023-ban medián 4,5% vs. BUBOR ~14%, a
cég-évek ~80%-a támogatott/fix-vintage árazású (NHP/Széchenyi-csomósodás);
(2) **de a piaci almintában is lapos a besorolás-árazás** → a pitch
bp-táblája nem publikálható. **Az újrakeretezés (MPT meglátása nyomán):**
a KKV-hitelpiac állami kamattámogatáson él — **az euró pont ettől jó
lehetőség: kivezetési stratégia, amelynél a programkivonás nem szakadék,
hanem lejtő.** Számszerűsítve (s09): az implicit támogatási ék **2023-ban
557–665 Mrd Ft/év** (az állomány 9,6%-a) — csak a mintabeli, 10+ fős körben.

## 10. Kulcsábrák és további mechanizmus-felismerés

**Mit:** IRF-panelek (f10–f12), akcelerátor ki/be (f13), fázis-idővonal
(f14), csatorna-dekompozíció (f15, gépi nulla additivitás-ellenőrzéssel).
**Mire jöttünk rá:** **az akcelerátor két arca** — monetáris sokknál a
nettóvagyon-csatorna 2,4-szeresére erősíti a KKV-beruházási választ
(klasszikus BGG), az exogén prémium-sokkot viszont az endogén
tőkeáttétel-válasz részben tompítja. Ez magyarázza a szcenáriók mérsékelt
hosszú távú hatását is. A dekompozícióból: a szuverén csatorna dominál.

## 11. Adat-infrastruktúra megerősítése

**Mit:** BUBOR-történet letöltve az MNB-től (a valós éves átlagok:
1,46/9,97/**14,3**/7,3% — a 2023-as közelítésünk alulbecsült, az ék nőtt);
hivatalos NUTS-2 az IrszHnk-ból (37 764/37 805 cég lefedve); MNB/KSH/HNB
források regisztrálva a data-indexben; tanulmány-váz (`tanulmany_vazlat.md`);
két email-piszkozat (AVG-kérdés, EAGLE-kód bekérés).

## 12. v0.4 — kamatunió + nem-Ricardiánus háztartások

**Mit:** rezsimváltó dummy (belépés után r = euró-kamat, dep = 0) +
75% kézről-szájra háztartás (EAGLE HU-érték), kapcsolható változatokkal.
**Eredmény:** hosszú táv v0.3 +0,49% → csak unió +0,54% → **unió+NR
+0,73%**; a dip mélyebb (−0,38%). **Tanulság:** a nem-Ricardiánus blokk
oldja az Euler-rögzítést (a hozamgörbe-csatorna aggregáltan is él), de
az ERM-II szakasz fájdalmasabb — az átmenet-kezelés a magas kézről-szájra
arány miatt kritikus.

---

## A nap három legfontosabb felismerése

1. **Az üzenet átkeretezése:** nem "a C–D olcsóbb hitelt kap", hanem
   "a KKV-hitelpiac állami lélegeztetőgépen van, és az euró az egyetlen
   pálya, ahol a gép kikapcsolása nem sokk" — az 557–665 Mrd Ft/év ék a
   headline-szám, a hozzáférés (extenzív margó) a heterogenitás-üzenet.
2. **A modell időprofilja önálló üzenet:** lassú felépülés + belépés
   előtti dip, amit a nem-Ricardiánus népesség súlyosbít → a fiskális
   hitelesség és az átmenet-politika nem díszlet.
3. **A rétegek munkamegosztása számszerűen igazolódott:** a DSGE
   ~0,3–0,7% tartós GDP-t ad a hitelcsatornából; a többi a 2–3. réteg
   és a modellen kívüli csatornák terepe — és ezt nyíltan így mondjuk ki.

## Nyitva maradt

- MNB új-szerződéses kamatstatisztika (kézi export) — a piaci árazás mérése.
- Horvát HNB-adat a B4 validációs ábrához.
- Notion-connector újracsatlakoztatás → döntésnapló-szinkron (red flag +
  v0.4 bejegyzés vár).
- Emailek kiküldése (piszkozatban); megrendelői keretezés-egyeztetés.
- v0.5: Calvo-bérek; opt/pessz pályák v0.4-en; git identitás beállítása.
