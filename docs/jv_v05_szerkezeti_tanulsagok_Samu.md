# `jv_dsge_v05.mod` — szerkezeti tanulságok és a minimális védhető átépítés

Ez a jegyzet a `DSGE_mkik` repó `src/model/jv_dsge_v05.mod` verziójára
vonatkozik.

## A fő szerkezeti probléma

A jelenlegi modellben két külön dimenzió csúszik egymásra:

- a **KKV–nagyvállalat** felosztás mint **pénzügyi heterogenitás**
- a **hazai–export** felosztás mint **reálgazdasági heterogenitás**

Ez azt jelenti, hogy a modellben a `S/L` bontás a pénzügyi blokkban él
(`k_S`, `k_L`, `i_S`, `i_L`, `nw_S`, `nw_L`, `efp_S`, `efp_L`), miközben a
termelési, keresleti és árazási blokk végig a `d/x` dimenzióban van
(`y_d`, `y_x`, `l_d`, `l_x`, `mc_d`, `mcx_rel`, `xx`).

Következmény: a `KKV = hazai`, `nagyvállalat = export` megfeleltetés nem
eredmény, hanem modellbe épített azonosítás.

## Miért gond ez?

Így a modell nem tud tisztán válaszolni arra a kérdésre, hogy:

> az euró bevezetése eltérően hat-e a KKV-kra és a nagyvállalatokra?

Ennek oka, hogy a modellben a KKV nem önálló reálgazdasági termelőegység.
Van pénzügyi szegmens, de nincs külön:

- KKV-kibocsátás
- KKV-munkakereslet
- KKV-árazás
- KKV hazai és export értékesítés

Ezért a KKV-ra vonatkozó erős állítások jelenleg csak közvetetten,
kalibrációs feltevéseken keresztül jelennek meg, nem tiszta strukturális
eredményként.

## A legkisebb védhető átépítés

A minimális védhető irány az lenne, hogy a **méret** és a **piac** két külön
dimenzióvá válik:

- **méret:** KKV vs. nagyvállalat
- **piac:** hazai értékesítés vs. export

Ennek megfelelően a KKV és a nagyvállalat **külön termelőegységként**
jelenne meg, miközben **mindkettő értékesít a hazai piacon és exportál is**.

Vagyis nem ez lenne a leképezés:

- KKV = hazai
- nagyvállalat = export

hanem ez:

- KKV: hazai + export értékesítés
- nagyvállalat: hazai + export értékesítés

## A vertikális kapcsolat helyes értelmezése

A vertikális linket nem ágazati kapcsolatként, hanem **beszállítói
kapcsolatként** kellene modellezni.

Például:

- a KKV-output egy része köztes input a nagyvállalatnak
- a nagyvállalat export- és/vagy hazai termeléséhez KKV-beszállítás kell

Ez közgazdaságilag tisztább, mint a jelenlegi `hazai -> export` azonosítás,
mert a valódi kérdés nem az, hogy a hazai ágazat beszállít-e az export
ágazatnak, hanem az, hogy a **KKV-k szállítanak-e be a nagyvállalatoknak**.

## Mit nyerne ezzel a modell?

Ha ez a szétválasztás megtörténik, akkor a KKV-ra vonatkozó állítások
potenciálisan valódi strukturális eredményekké válhatnak.

Például értelmes modellobjektummá válna:

- a KKV-kibocsátás
- a KKV-beruházás mint reálváltozó, nem reallokációs maradék
- a KKV-foglalkoztatás
- a KKV hazai és export értékesítése
- a beszállítói csatorna méret szerinti hatása

Így a fő kutatási kérdés is tisztábban megfogalmazható lenne:

> az euró bevezetése eltérően hat-e a KKV-kra és a nagyvállalatokra,
> ha a méret és a piac nem ugyanannak a felosztásnak két neve?

## Fontos korlát

Ez nem kis javítás, hanem szerkezeti átépítés.

Legalább a következő blokkokat újra kell gondolni:

- termelési blokk
- keresleti aggregáció
- árazás / marginális költség
- vertikális inputstruktúra
- aggregáció a KKV/nagy és hazai/export dimenziók között

Tehát ez a lépés koncepcionálisan helyes, de munkaigénye már új
modellverziót jelent, nem egyszerű finomhangolást.

## Rövid záró verdikt

A `jv_dsge_v05.mod` jelenlegi szerkezetében a KKV–nagyvállalat állítás azért
nem védhető teljesen, mert a méretbeli és a piaci heterogenitás össze van
csúsztatva. A legkisebb védhető átépítés az, hogy a KKV és a nagyvállalat
külön termelőegység legyen, miközben mindkettő jelen van a hazai és az export
piacon, a vertikális kapcsolat pedig beszállítói kapcsolatként jelenjen meg.
Ez a helyes irány, ha a projekt a fő állítást strukturális modell-eredményként
akarja megtartani.
