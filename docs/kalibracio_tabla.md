# Kalibrációs tábla — `kkv_dsge_v07_access` (a legbővebb modell)

*2026-08-12 · a `src/model/kkv_dsge_v07_access.mod` mind a **60** deklarált
paramétere, forrás szerint osztályozva. A cél: eldönteni, mi kalibrálható a
saját adatunkból, mihez kell szakirodalom, és mi az, ami jelenleg
horgonyzatlan.*

> **Ez lookup-tábla, nem döntésnapló.** Az *érvelés* egy érték mellett a
> Notion döntésnaplóba tartozik (lásd `CLAUDE.md`); itt csak érték + forrás +
> nyomonkövethetőség van. A Notion-kereszthivatkozás **még jár** — ebben a
> munkamenetben nem volt Notion-hozzáférés.

---

## ⚠ Két dolog, ami a kigyűjtés közben derült ki

### 1. A legbővebb modell az EAGLE-vonal *kalibrált* értékeit használja, nem a JV *becsült* értékeit

A csapat 2026-07-13-án azzal az érvvel döntött a Jakab–Világi alapmodell
mellett, hogy annak paraméterei **magyar adaton Bayes-i módszerrel
becsültek**, nem kalibráltak. A `v07_access` viszont az EAGLE-vonalon
(`kkv_dsge_*`) épült, és **legalább nyolc alapparaméternél a kalibrált
EAGLE-értéket viszi**, miközben ugyanarra a fogalomra a JV-vonalon becsült
érték áll rendelkezésre:

| Paraméter | v07 (EAGLE, kalibrált) | JV-vonal (becsült) | Eltérés |
|---|---:|---:|---|
| `om_nr` / `om_no` — nem-Ricardiánus háztartás aránya | **0,75** | **0,25** | **3-szoros** |
| `sigma` — intertemporális helyettesítés | 0,4 | 1,814 | 4,5-szeres |
| `rho_a` — technológiai sokk perzisztencia | 0,90 | 0,552 | nagy |
| `eta_x` — export ár-rugalmasság | 1,0 | 0,534 (`mu_x`) | ~2-szeres |
| `phi_pi` — Taylor inflációs súly | 1,70 | 1,379 | mérsékelt |
| `rho_r` — Taylor simítás | 0,87 | 0,761 | mérsékelt |
| `habit` — fogyasztási szokás | 0,7 | 0,646 | kicsi |
| `rho_g` — fiskális sokk perzisztencia | 0,85 | 0,80 | kicsi |

**A legsúlyosabb az `om_nr`.** A JV-vonalon a 25%-ot *survey-alapúnak*
dokumentáltuk; a v07-ben 75% van. Ez nem részletkérdés: a nem-Ricardiánus
arány határozza meg, mennyire követi a fogyasztás a folyó jövedelmet, és a
korábbi EAGLE-tanulság szerint önmagában **másfélszeresére emelte** a tartós
hatást (v0.3 +0,49% → v0.4 +0,73%).

**Csapatdöntés kell:** vagy (a) a v07-et átkalibráljuk a JV becsült
értékeire, vagy (b) explicit kimondjuk, hogy a v07 EAGLE-kalibráción fut és
a JV csak aggregált benchmark. A mostani állapot — hogy a fő vonal érve a
becsült paraméterekre hivatkozik, de a legbővebb modell kalibrált értékeken
fut — **nem védhető bírálóval szemben.**

### 2. Amit a saját adatunkból *azonnal* meg lehetne csinálni, de még nem tettük

**Kilenc szegmens-súly** (`sy_*`, `sn_*`, `si_*`) és **hat exportkitettségi
paraméter** (`phi_*`, `sx_*`) az Opten-panelből **közvetlenül számolható** —
a `.mod` maga is ezt írja: *„Ezek indulok: empirikus ujrakalibracio kell."*
Ez 15 paraméter, és fél napos munka. Lásd a lenti **A** kategóriát.

---

## A. Saját adatunkból kalibrálható — MOST megcsinálható

*Opten-panel (148 225 cég-év, 37 805 cég, 2021–2024). Ez a legnagyobb
azonnali hozam: 17 paraméter horgonyzatlanból adatoltba.*

| Paraméter | Jelenlegi érték | Forrás jelenleg | Miből számolható | Panel-oszlop |
|---|---:|---|---|---|
| `sy_E` / `sy_D` / `sy_L` | 0,18 / 0,37 / 0,45 | **induló, jelölve** | kibocsátás-részesedés szegmensenként | `netto_arbevetel` |
| `sn_E` / `sn_D` / `sn_L` | 0,20 / 0,50 / 0,30 | **induló, jelölve** | foglalkoztatás-részesedés | `letszam` |
| `si_E` / `si_D` / `si_L` | 0,15 / 0,35 / 0,50 | **induló, jelölve** | beruházás-részesedés | `beruhazasok_felujitasok` |
| `phi_E` / `phi_D` / `phi_L` | 0,56 / 0,05 / 0,365 | **induló** | átlagos exportárbevétel-arány szegmensenként | `export_arany`, `export_arbevetel` |
| `sx_E` / `sx_D` / `sx_L` | 0,356 / 0,065 / 0,579 | **induló** | az összexport szegmens-megoszlása | `export_arbevetel` |
| `lev_E` / `lev_D` / `lev_L` | 1,6 / 1,6 / 1,85 | **Opten medián ✔** | már adatolt, de `lev_E = lev_D` **kényszerítve** — szét kell számolni | `tokeattetel` |
| `delta` | 0,025 | konvenció (10%/év) | értékcsökkenés / tárgyi eszközök | `ertekcsokkenes`, `targyi_eszkozok` |

**Fontos részlet:** a `lev_E = lev_D = 1,6` egy *kényszerített egyenlőség*
(a `.mod` kommentje szerint szándékos: „E es D egyelore azonos
KKV-parametereket kapnak"). Az `s14` viszont kimutatta, hogy az E és D
szegmens **13-szorosan** eltér hitelhez jutásban (61,9% vs 4,8%) — ezért
valószínűtlen, hogy a tőkeáttételük azonos. Ez szétszámolható.

---

## B. Nyilvános magyar makroadatból kalibrálható — könnyű, de nem a mi panelünk

| Paraméter | Jelenlegi érték | Forrás jelenleg | Honnan pótolható |
|---|---:|---|---|
| `c_y` / `i_y` / `g_y` / `x_y` / `m_y` | 0,61 / 0,19 / 0,20 / 0,75 / 0,75 | EAGLE-HU WP 2017/7 | **KSH nemzeti számlák**, közvetlenül; 2021–2024 átlag |
| `alpha` — tőkehányad | 0,30 | konvenció / WP | KSH: tőkerészesedés a bruttó hozzáadott értékben |
| `om_m` — import a kompozit inputban | 0,30 | WP | KSH nemzeti számlák (import/köztes felhasználás) |
| `rho_r` / `phi_pi` / `phi_y` — Taylor | 0,87 / 1,70 / 0,10 | WP 2017/7 | **becsülhető**: MNB alapkamat + infláció + kibocsátási rés, 2001–2024 |
| `rho_a` / `rho_g` / `rho_ystar` / `rho_rstar` | 0,90 / 0,85 / 0,85 / 0,85 | WP / konvenció | AR(1) becslés: KSH TFP, kormányzati kiadás, euróövezeti GDP, EKB-kamat |
| `theta_w` — Calvo-bér | 0,75 | EAGLE + **Kézdi–Kónya (MNB OP 103)** ✔ | van magyar mikro-evidencia; Kátay (MNB WP 2011/9) is |

---

## C. Szakirodalom kell — nem a mi adatunkból jön

| Paraméter | Jelenlegi érték | Forrás jelenleg | Mi kellene |
|---|---:|---|---|
| `sigma` — intertemporális helyettesítés | 0,4 | WP 2017/7 | **KONFLIKTUS a JV 1,814-tel** (lásd fent) |
| `habit` | 0,7 | WP 2017/7 | JV becsült: 0,646 |
| `sigma_n` — Frisch-rugalmasság inverze | 2,0 | konvenció | magyar munkakínálati becslés (Benczúr et al. típusú) |
| `phi_i` — beruházási kiigazítási költség | 6,0 | WP 2017/7 | JV-vonalon `psi_i` = 8–13 (más normalizálás!) |
| `kappa` — Phillips-meredekség | 0,01 | Calvo 0,92-ből, WP | magyar ár-ragadósság mikro-evidencia |
| `eps_ces` — CES helyettesítés (markup 20%) | 6,0 | konvenció | magyar markup-becslés |
| `eta_x` / `eta_m` — kereskedelmi ár-rugalmasság | 1,0 / 1,0 | konvenció | **KONFLIKTUS**: JV becsült `mu_x` = 0,534 |
| `chiw` — bér CPI-indexálás | 0,75 | EAGLE | JV becsült `vth_w` = 0,185 — nagy eltérés |
| `eta_w` — bér-markup rugalmasság | 4,33 | EAGLE appendix | — |
| `eps_q` / `omega_nw` — BGG-lite tartósság | 0,96 / 0,95 | BGG (1999) konvenció | — |
| `om_nr` — nem-Ricardiánus arány | 0,75 | EAGLE HU | **KONFLIKTUS a JV 0,25-tel (3×)** |

---

## D. Nem azonosított / több adat kell — itt áll a projekt fő kérdése

*Ez a kategória a legfontosabb: ezek hordozzák a fő eredményt, és
egyikükre sincs elfogadható horgony.*

| Paraméter | Jelenlegi érték | Státusz | Mi kellene hozzá |
|---|---:|---|---|
| `lambda_acc_E` / `lambda_acc_D` | 2,0 / 2,5 (`ACCSCALE=100`) | **horgonyzatlan; a szerzők maguk jelezték** | Az `s14` szerint **magyar 2021–24 adatból NEM horgonyozható** (programvezérelt piac). Kell: MNB méret szerinti új-szerződéses kamatstatisztika, vagy 2021 előtti minta. |
| `omega_acc_E` / `omega_acc_D` | 0,35 / 0,45 | **horgonyzatlan; korábban NEM volt jelezve** | ugyanaz |
| *`omega_acc_L` (nem létezik)* | implicit **0** | **a legnagyobb egyetlen feltevés** — ez viszi a szektorális átfordulást | Az `s14` szerint az L hozzáférése 43,4%, ami *alacsonyabb* az export-KKV 61,9%-ánál → a „nagyvállalat nincs korlátozva" történet **nincs az adatban**. Scan kell rá, mint az `ACCSCALE`-re. |
| `rho_acc` | 0,85 | horgonyzatlan | hozzáférési státusz-átmenet a panelből (`van_hitel` átmenet-mátrix) — **ez számolható!** |
| `tsov_E/D/L`, `tbank_E/D/L` | TSCEN=3: 0,175 / 0,45 | **nem azonosított** (becsült arány 0,26–2,75, semmi sem szignifikáns) | A `.mod` korrektül a semleges alapot használja. Feloldás: MNB részletes bontás. |
| `chi_E` / `chi_D` / `chi_L` | 0,06 / 0,06 / 0,02 | **„Opten-panel medián"-ként hivatkoztuk, de nem az** | A tőkeáttétel-adat (`lev_S` 1,6 < `lev_L` 1,85) **nem támogatja** a magasabb KKV-χ-t. Emellett `∂i/∂F = −1/χ` miatt a nagyvállalatnak dolgozik. Kell: EFP-érzékenység becslése, vagy szimmetrikus alap + scan. |
| `zsov` — UIP-országprémium súly | 0,5 | forrás nincs | becsülhető: magyar UIP-reziduum vs. CDS-felár |

---

## E. Konvenció vagy származtatott — nem szabad paraméter

| Paraméter | Érték | Miért nem szabad |
|---|---:|---|
| `beta` | 0,99 | negyedéves 4%/év reálkamat — standard |
| `kap_w` | származtatott | `(1−θw)(1−βθw)/(θw(1+σn·ηw))` |
| `phi_b` | 0,01 | **technikai** NFA-zárás, nem strukturális |
| `nu_uni` | 0,25 | **technikai** unió-ági zárás; `diag_nuuni_v05` platója alapján, nem becslés. Érzékenységgel kísérendő. |

---

## Összegzés számokban

| Kategória | Paraméterek száma | Megjegyzés |
|---|---:|---|
| **A.** saját adatunkból kalibrálható | **17** | fél–egy napos munka, azonnali hozam |
| **B.** nyilvános magyar makroadatból | 14 | könnyű, de külső adatgyűjtés |
| **C.** szakirodalom kell | 12 | ebből **4 konfliktus** a JV-vonallal |
| **D.** nem azonosított / több adat | 13 | **ezek hordozzák a fő eredményt** |
| **E.** konvenció / származtatott | 4 | — |
| **Összesen** | **60** | |

## Javasolt sorrend

1. **Az A-kategória lefuttatása** (17 paraméter az Opten-panelből). Ez a
   legnagyobb hozam a legkisebb ráfordítással, és a `.mod` maga kéri.
   Ide tartozik a `rho_acc` is a `van_hitel` átmenet-mátrixból.
2. **Csapatdöntés az EAGLE/JV kalibrációs konfliktusról** (különösen az
   `om_nr` 0,75 vs 0,25). Ez elvi kérdés, nem technikai.
3. **A B-kategória** KSH/MNB-adatból — ezen belül a Taylor-szabály
   újrabecslése magyar adaton a legvédhetőbb önálló lépés.
4. **A D-kategória kezelése küszöbformában**, nem pontbecsléssel — ahogy a
   `v07`-specifikáció már javasolja. Az `omega_acc_L`-re scan kell.
5. A C-kategória a legkevésbé sürgős: ott az érték *van*, csak külső
   forrásból; a kockázat a konfliktusokban van, nem a hiányban.

---

*Kapcsolódó: `docs/FIGYELMEZTETES_io_tabla_gyanus.md` (az `s_kkv` nem
szerepel ebben a modellben, tehát a v07-et az IO-hiba nem érinti) ·
`docs/2026-08-12_access_horgonyzas_eredmeny.md` (miért nem horgonyozható az
`ACCSCALE`) · `docs/FIGYELMEZTETES_fo_allitas.md` (a `t`-súlyok) ·
`src/model/README.md` (verzió-changelog)*
