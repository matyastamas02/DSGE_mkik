# Mérési specifikáció — `aa_j`: a munka aránya a munka+import kompozitban

*2026-10-26. Tominak (az `aa_j` felelőse), Evinek és Samunak tájékoztatásul, mert a `zeta_j`
ugyanebből a keretből jön. Ehhez a lépéshez modellfutás nem kell. A fiskális review sorrendje szerint
(`docs/terv/2026-10-25_fiskalis_blokk1_implementacios_brief.md`) a 3. blokk (szocho) erre a
mérésre vár: a szocho hatásának nagysága 3,5–6-szoros sávban az `aa_j`-n múlik.*

## 1. Mit jelent a paraméter a modellben

```
wz_j = aa_j*w + (1-aa_j)*rer                 // munka+import kompozit ára
mc_j = zeta_j*rk_j + (1-zeta_j)*wz_j - a     // határköltség
```

A modellben **nincs hazai köztes termék**: a cég költsége tőke, munka és import. A valóságban a cég
hazai beszállítótól is vesz, de annak az ára is bérből, tőkéből és importból áll össze. Ezért a modell
fogalmához a hazai beszerzést **szét kell bontani a saját munka-, tőke- és importtartalmára**, és
`(1 − aa_j)` a **teljes (közvetlen + közvetett) importtartalom** aránya a nem-tőke költségben:

```
aa_j = W_j^teljes / ( W_j^teljes + M_j^teljes )
```

## 2. Miért rossz a mostani szám (0,118 / 0,145 / 0,139)

A mostani képlet `Bérköltség / (Bérköltség + Anyagjellegű ráfordítások)`. Tomi saját dokumentuma is
jelzi, hogy ez fogalmilag nem import (2026-09-24, 3. pont). Két konkrét ok:

1. **Az összevont „anyagjellegű ráfordítások” sorban benne van az ELÁBÉ** (eladott áruk beszerzési értéke)
   és a közvetített szolgáltatások értéke. Ezek továbbeladott áruk, nem termelési inputok. Egy
   kereskedőcégnél ez a ráfordítás nagy része.
2. **Minden beszerzés importnak számít**, holott nagy része hazai.

**Plauzibilitás:** a teljes költségen belüli importarány `(1 − zeta_j)·(1 − aa_j)`. A mostani KALIB-értékekkel
ez E-nél 0,82, **D-nél (hazai KKV) 0,76**, L-nél 0,79. A JV kétszektoros értékeivel ugyanez az export
szektorban 0,47, a hazaiban 0,17. Hogy a hazai piacra termelő KKV-k költségének háromnegyede import
legyen, nem lehetséges. Ez a nagyságrend a mérési hibát mutatja, nem egy valódi jelenséget.

## 3. A javasolt mérés

Cégszinten (`f`, NACE-ágazata `i`), az Opten-panelből:

| Tétel | Opten-sor | Megjegyzés |
|---|---|---|
| `W_f` munkaköltség | személyi jellegű ráfordítások (bérköltség + egyéb személyi kifizetések + bérjárulékok) | **a járulékokkal együtt**, mert a 3. blokk munkaköltsége (`w^c`) a szochót tartalmazza |
| `P_f` termelési beszerzés | anyagköltség + igénybe vett szolgáltatások + egyéb szolgáltatások | **ELÁBÉ és közvetített szolgáltatások NÉLKÜL** |
| `K_f` tőkejövedelem (csak a `zeta_j`-hez) | üzemi eredmény + értékcsökkenés | Evi `zeta`-számlálója |

Az input–output táblából, ágazatonként (`i`):

- `m_i` = az importált köztes felhasználás aránya az ágazat teljes köztes felhasználásában;
- `ℓ_i^D`, `κ_i^D`, `μ_i^D` = egységnyi **hazai** beszerzés munka-, tőke- és importtartalma, a Leontief-inverzzel:
  ```
  [ℓ_i^D  κ_i^D  μ_i^D] = d_i' · (I − A_d)^(-1) · [λ  κ  μ]
  ```
  ahol `d_i` az `i` ágazat hazai köztes inputjainak összetétele (összege 1), `A_d` a hazai
  input-együtthatók mátrixa, `λ`, `κ`, `μ` pedig ágazatonként a munkavállalói jövedelem, a bruttó
  működési eredmény (vegyes jövedelemmel) és az importált köztes input aránya a kibocsátásban.

Ebből cégenként:

```
M_f = m_i*P_f                      // közvetlen import
D_f = (1 - m_i)*P_f                // hazai beszerzés
W_f^teljes = W_f + ℓ_i^D*D_f
M_f^teljes = M_f + μ_i^D*D_f
K_f^teljes = K_f + κ_i^D*D_f
```

Típusonként (`j` = E, D, L, az 50%-os exportküszöbbel, ugyanúgy, mint eddig):

```
aa_j   = Σ_f W_f^teljes / Σ_f ( W_f^teljes + M_f^teljes )
zeta_j = Σ_f K_f^teljes / Σ_f ( K_f^teljes + W_f^teljes + M_f^teljes )      // Evivel egyeztetve
```

A `zeta_j`-t ugyanezen a nevezőn kell számolni. Ha az `aa_j` új keretből jön, a `zeta_j` viszont a
régiből (nettó árbevétel a nevezőben, ELÁBÉ-val), a két hányad nem ugyanannak a költségnek a része.

**Közlendő változatok**, típusonként, a 2017–2025-ös összevont mintán, valamint 2017–2019-re és
2022–2025-re külön:

| | Változat | Mire jó |
|---|---|---|
| (a) | teljes tartalom, ELÁBÉ nélkül | **fő érték** |
| (b) | csak közvetlen: `W_f / (W_f + M_f)` | megmutatja, mennyit ad hozzá a közvetett tartalom |
| (c) | (a), de ELÁBÉ-val | megmutatja, mennyit magyaráz az ELÁBÉ |
| (d) | a mostani képlet | összevetés |

## 4. Adatforrás

- **Opten:** megvan. Előbb ellenőrizni kell, hogy az ELÁBÉ, a közvetített szolgáltatások és az igénybe
  vett szolgáltatások **külön sorként** mekkora lefedettséggel érhetők el. A szűk sorokra eddig csak
  kb. 15%-os lefedettséget írtál. Ha a részletes bontás csak egy részmintán van meg, a javaslat: a
  részmintán számolni, és NACE × méretkategória cellánként az összes cég árbevételére visszasúlyozni.
  A lefedettséget típusonként közölni kell.
- **IO-tábla:** Eurostat `naio_10_cp1750` (szimmetrikus, ágazat × ágazat, alapáron, HU, a legutóbbi
  elérhető év). A hazai és az import rész a `stk_flow` dimenzióban van (`DOM` / `IMP`); ezt az első
  lépésben ellenőrizni kell. Keresztellenőrzés: OECD ICIO/TiVA vagy Eurostat FIGARO.
- **A `t24` kódját ne használd újra.** Az a mérés táblaválasztási vagy dekódolási hibán bukott el
  (`docs/figyelmeztetesek/FIGYELMEZTETES_io_tabla_gyanus.md`), a gyökérok máig nyitott.

## 5. Kötelező ellenőrzések, mielőtt a szám a modellbe megy

| # | Ellenőrzés | Elfogadás |
|---|---|---|
| E1 | ágazatonként hazai + import köztes felhasználás = a nemzeti számlák P2-je (Samu tesztje; ezen bukott el a `t24`) | ±1% |
| E2 | ágazatonként munka- + tőke- + import- + nettóadó-tartalom = 1 | gépi pontosság |
| E3 | a magyar export teljes importtartalma az IO-ból = a TiVA-ban közölt külföldi hozzáadottérték-arány | ±3 százalékpont |
| E4 | lefedettség: a cég-évek és az árbevétel hány százalékánál ismert a részletes bontás, típusonként | közölni |
| E5 | plauzibilitás: `(1 − zeta_j)·(1 − aa_j)` E-nél és L-nél a TiVA-arány környékén vagy alatta, D-nél jóval alacsonyabb | csak jelzés, nem hangolás |

## 6. Amit NE

- Ne az összevont „anyagjellegű ráfordítások” sort használd: az ELÁBÉ miatt nem termelési költség.
- Ne a `t24` IO-pipeline-t használd.
- **Ne hangold a számot a modelleredményre**, például arra, hogy a fogyasztás vagy a reálbér pozitív
  legyen. Az értéket a mérés adja, a modellhatást utána nézzük meg, előre rögzített elvárással.
- Ne keverd a közvetlen és a teljes fogalmat a típusok között.
- **Ne állítsd, hogy ez cégszintű import-heterogenitást mér.** Az ágazaton belüli különbség (az exportőrök
  többet importálnak) így nem jelenik meg, ezért az E típus importarányát valószínűleg alulbecsüljük.
  Ha a KSH Kutatószobában elérhető a cégszintű külkereskedelmi adat, az a javítás. Ezt a korlátot a
  számmal együtt kell közölni.

## 7. Kimenet, és mi jön utána

- **Tábla** típusonként a négy változattal és a két részidőszakkal, a lefedettséggel és az E1–E5
  eredményével; **script** az `outputs/` alatt a meglévő `calc_aa_j.py` mellé; rövid **leírás** a
  meglévő dokumentum mintájára.
- **Utána, külön lépésben:** az új `aa_j` (és ha Evi egyetért, a `zeta_j`) kapcsoló mögött kerül a
  v11-be. Megnézzük, mit tesz a GDP-sávval, a KKV-küszöbbel és a mostani furcsa tartós eredménnyel
  (−1,03% fogyasztás, −0,46% reálbér). Az elvárást futás előtt rögzítjük. Hogy az új érték legyen-e az
  alapértelmezés (`KALIB`), az **csapatdöntés**.
- **Csak ezután jön a 3. blokk (szocho).**

**Kapcsolódó, de külön kérdés:** az `om_j` súlyok is nettó árbevételből számolódnak, ELÁBÉ-val együtt.
Ez a kereskedelemben erős típusokat túlsúlyozhatja. Érdemes ugyanebben a körben megnézni, de nem ennek
a specifikációnak a része.
