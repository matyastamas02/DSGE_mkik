# A 2026-08-26-i parameter-review átvezetése — mit okoz, mi jó, mi nem

*Forrás: `parameter_review_excel51_jv_uj_v2.md` (kolléga)*
*Kód: `-DCALIB26=0|1|2|3` a `jv_dsge_v09_access.mod`-ban ·
futtató: `src/modell/1_fo_vonal_jv/futtato/stress_calib26_v09.m`*
*Tábla: `t55_calib26.csv`*

---

## A döntő tény, elöl

**A makrosúly-blokk önmagában BK-invalid.** Ha csak a friss, „záródó"
GDP-felhasználási súlyokat vezetjük át (`sx` 0,60 → 0,829, `sm` 0,47 →
0,796, `s_kkv` 0,05 → 0,363), a modell mind a 9 szcenárió-kombinációban
elveszti a Blanchard–Kahn-determinációt: 15 instabil gyök jut 13
előretekintő változóra.

| ág | PF-solver | terminális BK | gyök / előretekintő |
|---|---|---|---|
| **0** jelenlegi kalibráció | 9/9 | **9/9** | 13/13 |
| **1** teljes javaslat | 9/9 | **9/9** | 13/13 |
| **2** javaslat a makrosúlyok nélkül | 9/9 | **9/9** | 13/13 |
| **3** csak a makrosúlyok | 9/9 | **0/9** | **15/13** |

A teljes javaslat (1) tehát **véletlenül** visszakerül a stabil
tartományba: a makrosúlyok kilökik, a többi változás visszahúzza. Ez nem
robusztusság, hanem **két nagy, ellentétes irányú hatás kioltása**. Egy
ilyen egyensúlyra nem szabad fő kalibrációt építeni anélkül, hogy tudnánk,
melyik komponens mit csinál.

---

## Mit mozgat a javaslat

| Blokk | Régi | Új | Nagyságrend |
|---|---|---|---|
| Nyitottság (`sx`/`sm`) | 0,60 / 0,47 | 0,829 / 0,796 | **+38% / +69%** |
| Vertikális súly (`s_kkv` → `shd_v`) | 0,05 → 0,030 | 0,363 → 0,218 | **7,3×** |
| Import-intenzitás (`1−aa_D`) | 0,20 | 0,69 | **3,5×** |
| Nagyvállalati tőkeáttétel (`lev_L`) | 1,85 | 2,882 | +56% |
| Banki átgyűrűzés (`tbank_L`) | 0,45 | 1,05 | **2,3×** |
| Szuverén átgyűrűzés (`tsov`) | 0,175 | 0,025 | **−86%** |

Ez nem paraméterfinomítás. A gazdaság nyitottsága, a vertikális blokk
súlya és a transzmissziós szerkezet is megváltozik.

## Mi lesz az eredményből (csak a BK-valid ágakon)

| ág | GDP-sáv | KKV−L sáv |
|---|---|---|
| 0 jelenlegi | +0,52 … +1,18% | +0,21 … +3,37 pp |
| 1 teljes javaslat | **+0,21 … +0,68%** | +0,66 … +2,05 pp |
| 2 makrosúlyok nélkül | +0,22 … +0,71% | +0,58 … +1,81 pp |

**A GDP-hatás nagyjából felére esik**, a KKV-előny viszont **pozitív
marad, sőt a sávja szűkül** (az alsó vég 0,21 → 0,66 pp-re emelkedik).
Vagyis a projekt szektorális állítása a friss kalibráción **erősebb**, az
aggregált szám viszont **gyengébb**.

---

## Mi jó benne

**Teljes és ellenőrizhető.** A 91 paraméterből 91-et lefed, és a
névhalmaz **pontosan** egyezik a saját regiszterünkkel — nulla hiány,
nulla extra. Ezt külön leellenőriztem.

**A záródó azonosság tényleg záródik.** `sc+si+sg+sx−sm = 1,000` mind a
JV-vintage, mind a friss ablakon. A fogalmi diagnózis is helyes: a szűk
mérés azért nem záródott, mert `sg = P32_S13` kihagyja a kormányzati
egyéni fogyasztást, `si = P51G` pedig a készletváltozást.

**Elkapott egy valós következményt, amit könnyű elnézni.** Ha a
makrosúlyok frissülnek, a `shd_c/i/g` képlet nem maradhat a régi
`0,55/0,15/0,12/0,82` arányokon — különben a hazai kereslet összetétele és
a GDP-azonosság két különböző forrásból jönne. Ez jogos, és be is
építettem.

**Két helyen kimondja a saját eredménye korlátját.** A `phi_E` körkörös
voltát és a `tbank_L > tbank_E` narratíva-ellentmondást maga jelzi. Az
utóbbi egybevág a saját `A16`/`F06` mérésünkkel.

---

## Mi nem jó

### 1. `lev` — belső ellentmondás, és megdönt egy álló állítást

A `lev_D` sor indoklása azt írja: *„A panel szerint lev_E≠lev_D: 1.939 vs.
1.719"* — miközben ugyanannak a sornak az értékoszlopa **1,762 / 2,200**-at
ad. A két szám nem fér össze.

Súlyosabb: a sorrend **megfordul**.

| | E | D | L | sorrend |
|---|---|---|---|---|
| `A07`/`A08` (áll) | 1,939 | 1,719 | 2,337 | L > **E > D** |
| javaslat | 1,762 | 2,200 | 2,882 | L > **D > E** |

Az `A08` kifejezetten azt állítja, hogy **az exportáló KKV a
tőkeáttételesebb**. A javaslat ezt megfordítja. Vagy az `A08` dől meg, vagy
a mérés hibás — ezt el kell dönteni, nem átvezetni.

### 2. Alsó és felső korlátok pontértékként

A review maga írja: `zeta_j` és `aa_j` **alsó korlát** (halmozódási
torzítás), `s_kkv = 0,363` **felső korlát** (fordított halmozódás). A
`-DCALIB26` ágakban a sávok középértéke szerepel — ami **nem mérés**.

Ez pontosan az a hibaminta, amit a projekt hatszor dokumentált: egy nem
azonosított paraméter úgy megválasztva, hogy a kívánt eredmény jöjjön ki.

### 3. `tsov ≈ 0` — kollinearitási műtermék, nem nulla átgyűrűzés

Az indoklás: *„BUBOR-kontroll mellett a szuverén spread önálló hatása
eltűnik."* Ez **nem** bizonyítja, hogy a strukturális átgyűrűzés nulla — a
BUBOR maga is együtt mozog a szuverén kockázattal, tehát ha arra
kontrollálsz, épp az azonosító varianciát veszed ki a becslésből.

Tétje nagy: az `F05` szerint az euró-hatás gyakorlatilag **teljes
egészében** a szuverén csatornán megy. Ha `tsov` 0,175 → 0,025, a −200 bp
alig ér el a cégekhez — és ez magyarázza a GDP-sáv felezését.

### 4. `s_kkv` — 7,3× egy visszavont mérés utódján

`shd_v` 0,030 → 0,218. Az IO-alapú elődjét a **`V02` állításunk
visszavonta** („az irányt sem tudjuk"), és a TiVA-út a saját
munkalapunk szerint is „csak új módszertannal használható".

### 5. A duális szerkezet meggyengül

Az `aa` rés — a projekt központi strukturális állítása — összemegy:

| | E | D | rés |
|---|---|---|---|
| régi | 0,45 | 0,80 | **0,35** |
| új | ~0,20 | ~0,31 | **0,11** |

Plusz `phi_E = 0,821`, ami **körkörös**: a ≥50%-os exportküszöbű
definícióból következik, nem független bizonyíték. Ezt így nem szabad
használni.

### 6. A BK-kockázat nincs megemlítve

A review sehol nem hivatkozik Blanchard–Kahnra, pedig két javaslata pont a
határ felé tol (`tbank` 2,3×, `lev_L` +56% — mindkettő erősíti a pénzügyi
akcelerátort). A fenti tábla mutatja, hogy ez nem elméleti aggály.

---

## Ajánlás

**Ne alapértelmezésként.** A `-DCALIB26` kapcsolóként van bekötve, az
eredeti kalibráció érintetlen. Az alapértelmezés cseréje a `CLAUDE.md` 4.
pontja szerint **csapatdöntés**.

**Sorrend, ami védhető:**

1. **Döntsük el a `lev`-ellentmondást** — `A08` vagy a mérés. Ez egy álló
   állítás, nem hagyható lebegve.
2. **Vezessük át külön azt, ami tényleg mért és nem ellentmondásos:**
   `delta` (0,0242 — két forrás egyezik), `om_no` (0,160, HFCS), `psi_E/D`,
   `mu_x`, `rho_a`, `phi_D`/`phi_L`. Ezek egyike sem tol a BK-határ felé.
3. **A makrosúly-blokkot külön**, mert önmagában BK-invalid — előbb
   értenünk kell, miért.
4. **A sávos tételeket (`zeta`, `aa`, `s_kkv`) scanként**, nem
   pontértékként — a projekt saját küszöbforma-szabálya szerint.
5. **`tsov`-ot ne vigyük 0-ra** a jelenlegi indoklással; ehhez olyan
   becslés kell, amely nem kontrollál a BUBOR-ra.

**Amit viszont érdemes már most kimondani:** a friss kalibráción a
**KKV-előny nem tűnik el, hanem stabilabb lesz** (+0,66…+2,05 pp a
+0,21…+3,37 helyett). Az aggregált GDP-szám gyengül, a szektorális
állítás erősödik. Ez a projekt szempontjából nem rossz hír — a fő
mondanivaló mindig is a szektorális kérdés volt.
