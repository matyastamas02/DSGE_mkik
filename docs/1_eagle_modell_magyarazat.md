# 1. Az EAGLE-modell — a script értelmezése és fő egyenletei

*Az EAGLE-HU (Békési–Kaszab–Szentmihályi, MNB WP 2017/7) magyar,
egyblokkos változata — a `DSGE_alapmodell_juli13.mod` (Evelin) alapján,
ami ezt 91 egyenletes, nemlineáris, reál formában valósítja meg. Ez a
dokumentum nem bírálat (az a `alapmodell_juli13_jegyzet.md`), hanem
magyarázat: mit csinál minden fő egyenlet, miért, és mi lesz belőle.*

---

## 0. Mi ez a modell egy mondatban

Egy **kis nyitott gazdaság új-keynesi DSGE-modellje**, amelyben kétféle
háztartás, két termelő szektor (külkereskedelmezhető és nem), egy külön
export-összeszerelő, teljes fiskális blokk és egy jegybank él együtt.
A gazdaság reál egyensúlyi pályáját írja le, és megmondja, hogy egy sokk
(pl. kamatváltozás, árfolyam, adó) hogyan gyűrűzik végig a fogyasztáson,
beruházáson, inflación és a külkereskedelmi mérlegen.

A modell **reál formájú**: minden árat a fogyasztói árszinthez (CPI)
viszonyítunk, a nominális mennyiségeket deflálva. Ennek az az előnye,
hogy nincs benne árszint-egységgyök (nem "szökik el" a nominális szint).

---

## 1. A háztartások — kik döntenek, és miről

A modell két háztartástípust különböztet meg. Ez a megkülönböztetés a
projekt szempontjából kulcs: a likviditáskorlátos KKV-alkalmazottak
proxy-ja a második típus.

### 1.1 Ricardián (megtakarító) háztartás — a lakosság 25%-a

Ő a "gazdag", előretekintő szereplő: tőkét birtokol, kötvényt vásárol
(hazait és külföldit), pénzt tart. A viselkedését néhány elsőrendű
feltétel (FOC) írja le.

**A kötvény-Euler egyenlet (a modell szíve):**
```
β · R · E[λ(+1)/λ] / π_C(+1) = 1
```
*Mit mond:* egy elköltetlen forint holnapi hozama (a kamat `R`, reálértékre
váltva az inflációval `π_C`) épp annyit kell érjen, mint a ma feláldozott
fogyasztás határhaszna. *Miért van ott:* **ez köti össze a jegybanki
kamatot a reálgazdasággal** — ha a jegybank emel, a háztartás ma kevesebbet
fogyaszt (megtakarít), és ez a csatorna viszi a monetáris politika egész
hatását. *Mi lesz belőle:* a fogyasztás-simítás és a kamatérzékenység.

**A tőke-Euler (Tobin-Q) egyenlet:**
```
q = β·E[λ(+1)/λ]·[ (1−δ)·q(+1) + (1−τ_K)·r_K·u  + adó-pajzs − kihasználási ktsg ]
```
*Mit mond:* egy egységnyi ma megvett tőke értéke (`q`, a Tobin-féle Q) =
a holnapi eladási értéke + a bérleti díja + az amortizáció adó-pajzsa.
*Miért van ott:* ez a beruházási döntés motorja. *Mi lesz belőle:* a
beruházás akkor nő, ha a tőke értéke (q) a beszerzési ára fölé megy.

**A munkakínálat:**
```
n_I^χ = λ_I · (1 − τ_N − τ_Wh) · wr
```
*Mit mond:* a munka határ-áldozata = az adózott reálbér fogyasztás-értéke.
Itt **rugalmas a bér** (a modell egyszerűsítése — nincs bér-Calvo).

### 1.2 Nem-Ricardián (kézről szájra élő) háztartás — 75%

Nincs hozzáférése a tőke- és kötvénypiachoz; a folyó jövedelmét elkölti.
Egyetlen döntése, hogy mennyi készpénzt visz át a következő időszakra.
A fogyasztását **a költségvetési korlát határozza meg**:
```
(1+τ_C+Γ_v)·c_J + rm_J − rm_J(-1)/π_C = (1−τ_N−τ_Wh)·wr·n_J + tr − T
```
*Mit mond:* amit elkölt (fogyasztás adóval + pénztartás-változás) =
adózott bérjövedelem + transzfer − adó. *Miért fontos nekünk:* ez a
szereplő reagál azonnal a jövedelmére — ő adja a modell "kereslet-vezérelt"
oldalát, és az euró-átmenet fájdalmát (ha a bér esik, ő azonnal kevesebbet
fogyaszt). *Mi lesz belőle:* a nem-Ricardián arány (75%) miatt a modell
erősen reagál a jövedelmi sokkokra.

---

## 2. A termelés — két szektor

**Cobb–Douglas technológia** mindkét szektorban (tőke + munka):
```
y_T = a_T · k_d_T^α · n_d_T^(1−α)         (külkereskedelmezhető)
y_NT = a_NT · k_d_NT^α_NT · n_d_NT^(1−α_NT)  (nem külkereskedelmezhető)
```
A költségminimalizálásból két elsőrendű feltétel jön (tőke- és munka-FOC),
és ezek **együtt, implicit módon** adják a reál határköltséget (`rmc`) —
nem külön képletből (az redundáns lenne).

*Miért két szektor:* a külkereskedelmezhető javak ára az árfolyammal
mozog, a nem külkereskedelmezhetőké nem. Ez adja a **reálárfolyam belső
szerkezetét** — kulcs az euró-elemzéshez. A munka-FOC-ban ott a
munkáltatói járulék `(1+τ_Wf)`, ezért a modell **SZOCHO-elemzésre kész**.

---

## 3. Az árazás — új-keynesi Phillips-görbék

Szektoronként egy hibrid Phillips-görbe, eltérés-formában:
```
π_T − 1 = β·E[π_T(+1)−1] + κ_T·( rmc_T/rp_T − 1/markup_T )
```
*Mit mond:* a mai infláció a várt jövőbeli inflációtól és a reál
határköltség kívánt szinttől való eltérésétől függ. *Miért van ott:* a
Calvo-árazás miatt a cégek nem tudják azonnal átárazni a terméküket, így
a költség-sokkok fokozatosan gyűrűznek az árakba. *Mi lesz belőle:* a
sokkok **nem azonnal, hanem lassan** csapódnak le az inflációban — ez a
modell "nominális ragadóssága".

Fontos: itt a markup **sokk-folyamat** — így egy költség-sokk
(pl. olajár) modellezhető.

---

## 4. Az export szektor — az EAGLE kulcsújítása

Az export jószág **hazai tradable + importált input CES-keveréke**:
```
rmc_X = [ v_X·rp_T^(1−μ) + (1−v_X)·(pimx·rer)^(1−μ) ]^(1/(1−μ))
```
*Mit mond:* az export határköltsége a hazai input és az importált input
(aminek ára az árfolyammal, `rer`, mozog) kombinációja. *Miért fontos:*
a magyar export importtartalma ~55% — egy leértékelődés tehát **nemcsak
olcsóbbá teszi az exportot (kereslet), hanem drágítja is az inputját
(költség)**. Ez a két hatás küzd egymással. *Mi lesz belőle:* reálisabb
export-reakció az árfolyamra.

*(Korlát: a colleague-modellben az export-KERESLET tisztán exogén AR(1),
árrugalmasság nélkül — lásd a jegyzetet. A keresleti oldal így hiányos.)*

---

## 5. Végső javak — kétszintű CES-kosarak

A fogyasztás és a beruházás is kétszintű CES-aggregátor: külső szint
(tradable-köteg vs. non-tradable), belső szint (hazai tradable vs. import).
A **CPI-identitás** (`1 = CES-árindex`) a numeraire-megkötés — implicit
módon ez határozza meg a fogyasztói inflációt (`π_C`) a szektorális
inflációk konzisztens kombinációjaként.

*Mi lesz belőle:* az árfolyam a fogyasztói kosáron át közvetlenül a
megélhetési költségbe csatornázódik (magas import-súly, ~80% a tradable
fogyasztásban).

---

## 6. Külföld, kamat, árfolyam

**Reál UIP (fedezetlen kamatparitás) SGU-zárással:**
```
β·R*·(1 − γ_B_adj)·E[λ(+1)/λ]·E[rer(+1)/rer] = 1
γ_B_adj = γ_B*·(exp(nfa_ratio) − 1) − rp_shock
```
*Mit mond:* a hazai és a külföldi megtakarítás várható hozama
kiegyenlítődik; ha az ország eladósodik a külföld felé, a külső
finanszírozás drágul (`γ_B_adj`) — ez stabilizálja a nettó külföldi
pozíciót. *Mi lesz belőle:* a reálárfolyam endogén pályája + a külső
egyensúly hosszú távú horgonya.

---

## 7. Monetáris és fiskális politika

**Taylor-szabály** (évesített kamatokban, simítással):
```
R^4 − R̄^4 = φ_R·(R(-1)^4 − R̄^4) + (1−φ_R)·(φ_π·(π_C^4−π̄) + φ_Y·(y/y(-1)−1)) + ε_R
```
*Mit mond:* a jegybank az inflációra (φ_π=1,7 > 1, tehát a Taylor-elv
teljesül) és a kibocsátás-növekedésre reagál, simítva. *Mi lesz belőle:*
a nominális horgony — ez határozza meg az inflációt és közvetve a
reálkamatot.

**Fiskális blokk:** teljes költségvetési korlát **hat adónemmel**
(τ_C, τ_D, τ_K, τ_N, τ_Wf, τ_Wh), seigniorage-dzsal, és adósság-stabilizáló
lump-sum szabállyal (`T = φ_B·(b/y − cél)·y`). *Mi lesz belőle:* a
fiskális fenntarthatóság biztosítása, és a **projekt szempontjából arany**:
adó- és járulék-szcenáriók (pl. SZOCHO-csökkentés) közvetlenül futtathatók.

---

## 8. Mi lesz az egész modellből — a kimenetek

1. **Steady state** (hosszú távú egyensúly), amiből az összes arány
   (C/Y, I/Y, kereskedelmi mérleg) kiadódik.
2. **Impulzusválaszok:** hogyan reagál minden változó egy adott sokkra
   (17 sokk van: TFP, markup, preferencia, monetáris, fiskális, prémium,
   export, hat adó).
3. **Szcenáriók:** az euró-bevezetés mint prémium-pálya + rezsimváltás
   végigfuttatható rajta.
4. **Variancia-dekompozíció:** melyik sokk mennyit magyaráz a GDP
   ingadozásából.

## 9. Erősségei és korlátai a projektünkhöz

**Erős:** gazdag szerkezet (tradable/non-tradable, export importtartalma,
teljes fiskális blokk); az EAGLE az MNB hivatalos kerete → hitelesség.

**Korlát:** (a) **kalibrált, nem becsült** — a paraméterek nem magyar
adatból jönnek; (b) nincs natív pénzügyi szektor (a BGG-t mi ragasztjuk rá);
(c) az export-kereslet ár-rugalmatlansága; (d) a determináltsághoz több
paramétert el kellett hangolni a tanulmánytól (Calvo 0,92→0,75, indexálás,
Taylor-argumentum, prémium-rugalmasság) — így a dinamika már nem tisztán
"EAGLE".

**Ezért:** a projektben az EAGLE-vonal **robusztussági referencia**, a fő
vonal a Jakab–Világi (lásd 3. dokumentum). A gazdag fiskális blokkját
viszont érdemes átemelni.
