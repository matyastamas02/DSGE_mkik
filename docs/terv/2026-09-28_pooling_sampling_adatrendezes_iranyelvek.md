# Pooling, sampling, adatrendezés — quidelines

## 1. Mintaválasztás — kit veszünk be egyáltalán

### 1.1 Export-küszöb (E/D határ)

- **Javasolt default: export-arány ≥ 50% → E (export-KKV)**, egyébként D.

### 1.2 Méretküszöb (KKV/nagyvállalat határ)

- Jelenlegi konvenció: 10–249 fő = KKV (E vagy D), ≥250 fő = L.
- Nincs jelzett probléma vele eddig, de mivel most úgyis felül-
  vizsgáljuk a küszöbök kezelését, érdemes megerősíteni.
  - Másik alternatíva lenne eu-s policy alapján 

### 1.3 Pénzügyi + közigazgatás kizárás

- **Javaslat: igen, zárjuk ki**
  (`__opten_20260903_tisztitva0917.xlsx`, "Alap lista" lap) tartalmazza
  a `Nemzetgazdasági ág` + `Nemzetgazdasági ág szövegesen` mezőket,
  Adószám/Opten azonosító kulccsal. 
- ⚠ **Fontos csapda:** ebben a konkrét Opten-kivonatban a betűkódok
  **nem** a szokásos NACE Rev.2 betűzést követik (pl. `K` itt nem
  pénzügy, hanem távközlés/IT; `O` nem közigazgatás, hanem adminisztratív
  szolgáltatás). **Szöveg alapján kell szűrni** (`Nemzetgazdasági ág
  szövegesen` tartalmazza-e "PÉNZÜGYI"-t vagy "KÖZIGAZGATÁS"-t), nem a
  betűkód alapján. Ellenőrzött eredmény: 374 pénzügyi + 33 közigazgatási
  cég (betűkód ebben a fájlban `L` ill. `P`), a Beszámolók-panelben
  ~371 cég-év/év
- **Teendő:** a join implementálása (Adószám/Opten azonosító alapján)
  egy közös, mindenki által importált előkészítő lépésbe, nem
  paraméterenként újra levezetve.

### 1.4 Fióktelep-kizárás

- Jelenleg **nem** aktív, tudatosan írt szűrés — a jelenség valószínűleg
  a panel-kivonat építésének mellékterméke (fióktelepek nem önálló jogi
  személyek).
- **Teendő:** a "Székhely,Telephely,Fióktelep" lapból egyértelműen
  eldönthető, hogy ténylegesen mi történik — ezt még nem futtattuk le.
  
---

## 2. Osztályozás — cég-év vagy cégszintű

Ez a **legélesebb nyitott kérdés**, mert a válasz attól függően, hogy
melyiket választjuk, **átosztályozhat cégeket évek között** (cég-év
esetén) vagy **rögzíti egy cég kategóriáját a teljes panelra** (cégszintű
átlag esetén) — ez nem kozmetikai különbség, hanem torzíthatja a
DTS-differenciákat és a within-panel varianciát.

| | Cég-év (éves érték alapján osztályoz) | Cégszintű (panel-átlag alapján osztályoz) |
|---|---|---|
| **Előny** | Reagál valós állapotváltozásra (pl. egy cég átlép 250 fő fölé) | Egy cég egy szegmensben marad — stabilabb szegmens-kompozíció, egyszerűbb interpretáció |
| **Hátrány** | Egy határon lévő cég évente ugrálhat E/D/L között — zaj a szegmens-szintű aggregátumokban | Elmaszkolja a valós állapotváltozást; egy cég "korai" éveit is a "későbbi" kategóriájába sorolja |
| **Hol számít igazán** | `om_j`, `shl_j` (VA-súlyozott szegmensátlagok) — ha a compozíció évente mozog, a pooled év-FE torzul | `psi_j` robusztussági scan (2026-09-22-i munka jelenleg **cég-év** alapon fut) |

- **Javaslat megvitatásra:** cégszintű (panel-átlag) osztályozás,
  **kivéve** ha egy cég a panelban ténylegesen és tartósan (nem
  egy-egy határeset-éven) vált méretkategóriát — ez utóbbi esetben
  cég-év indokolt lehet. Ez döntést igényel, nem tudunk defaultot
  írni helyette.
- **Ugyanez export-arányra**: éves export-arány (volatilis lehet
  egy-egy nagy exportszerződés miatt) vs. panel-átlag export-arány.
  Ugyanaz az érv érvényes, mint a létszámnál.
- **Teendő:** amíg nincs döntés, minden kimeneti táblán/READMÉ-n fel
  kell tüntetni melyiket használtuk
---

## 3. Pooling / fixhatás-struktúra a becsléskor

- **Jelenlegi, kidolgozott módszertan** (`psi_j` robusztussági
  vizsgálatból): kiegyenlítetlen panelnál **iteratív two-way
  (alternáló projekció) demeaning** — szegmensenkénti saját év-FE vagy
  pooled év-FE, a kettő eltérését (`om_j`, `shl_j`, `aa_j` pooled vs.
  egyszerű átlag) eddig **<2%**-nak mértük, tehát a kettő között nem
  volt érdemi különbség — de ez paraméterenként újra-ellenőrizendő,
  nem általánosítható automatikusan minden jövőbeli paraméterre.
- **Nyitott kérdés, amit meg kell beszélni:** ez a módszertan **legyen
  elvárás** minden Opten-alapú paraméterre (nem csak `psi_j`-re), vagy
  paraméterenként külön kell mérlegelni, hogy a pooled/szegmens-saját
  FE-különbség számít-e?
- **Teendő, ha elfogadjuk mint sztenderdet:** a demeaning-függvény
  kerüljön egy közös segédmodulba (jelenleg script-specifikusan van
  megírva `calc_psi_robustness_full.py`-ban), amit minden paraméter-
  számoló script importál, ne mindenki írja meg újra.

---

## 4. Alapadat-tisztítás paraméterezés előtt



- **Kiugró értékek kezelése**: winsorizing (hányadik percentilen?),
  vagy egyszerű kizárás egy küszöb fölött/alatt? Melyik változóra
  (tőkeáttétel, om/shl arányok, létszám-változás)?
- **Minimum panel-hossz egy cégre**: kell-e legalább N év adat ahhoz,
  hogy egy cég bekerüljön egy időbeli (pl. `psi_j`, `rho_acc`)
  becslésbe?
- **Értelmezhetetlen mérlegadatok**: negatív saját tőke (→ végtelen
  vagy negatív tőkeáttétel), nulla vagy negatív árbevétel/eszközérték —
  kizárjuk, vagy külön flag-eljük?
- **Duplikált/jogutódlási esetek**: van-e a panelban cégösszeolvadás
  vagy jogutódlás, ami mesterséges ugrást okozhat egy cég idősorában?

---

## Javasolt következő lépés

1. Ezt a dokumentumot végigmenni 
2. A döntéseket felvinni a Notion döntésnaplóba (`docs/terv/` nem
   döntésnapló, csak vitaanyag).
3. A lezárt döntéseket egy közös, mindenki által importált
   `00_panel_epites`-szerű modulba kódolni (export-küszöb, mérethatár,
   pénzügyi/közigazgatás-szűrő, osztályozási szint, pooling-függvény),
   hogy paraméterenkénti újraírás helyett egy helyen éljen.
4. A már elkészült Opten-alapú számításokat (`om_j`, `shl_j`, `aa_j`,
   `psi_j` és a `lev_j`) a lezárt döntések fényében **egy körben**
   újrafuttatni, nem paraméterenként elszórtan.
