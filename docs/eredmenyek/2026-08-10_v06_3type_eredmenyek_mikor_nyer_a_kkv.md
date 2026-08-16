# v06_3type eredmények — mikor nyer a KKV?

*2026-08-10 · rövid értelmező memo a `kkv_dsge_v06_3type.mod` és a
`t28_v06_3type_tscen_sens.csv` alapján.*

## 1. Technikai státusz

A `v06_3type` modell az első explicit háromszektoros Dynare-váz:

- `E`: export-orientált KKV,
- `D`: hazai orientációjú KKV,
- `L`: aggregált nagyvállalat.

A modellben a három szektor külön termelési, árazási, beruházási és pénzügyi
akcelerátor blokkal szerepel. A szektorokhoz külön exportkereslet tartozik
(`x_E`, `x_D`, `x_L`), az aggregált export pedig ezek súlyozott átlaga.

Dynare 6.5 alatt a modell lefut:

- 62 endogén változó,
- 62 egyenlet,
- Blanchard-Kahn feltétel teljesül,
- perfect foresight megoldás mindhárom euró-szcenárióra megvan.

Az unió-ági külső zárás a JV-vonal tanulsága alapján külön `nu_uni=0.25`
horgonyt használ. Ezzel az alap szcenárió terminalis külső pozíciója
`bstar=-0.01`, nem a korábbi, gyenge zárásból adódó `-0.25`.

## 2. Fő eredmény

A modell nem azt mondja, hogy a KKV-k automatikusan nagyobb nyertesei az
euróbevezetésnek. A KKV-előny attól függ, hogy a szuverén és banki
prémiumcsökkenés milyen erősen megy át az egyes vállalati típusok
finanszírozási feltételeibe.

| TSCEN | értelmezés | aggregált GDP | export-KKV `y_E` | hazai KKV `y_D` | nagyvállalat `y_L` |
|---:|---|---:|---:|---:|---:|
| 1 | KKV-erősebb transzmisszió | +0,496% | +0,694% | +0,550% | +0,372% |
| 2 | nagyvállalat-erősebb transzmisszió | +0,695% | −0,462% | −0,125% | +1,832% |
| 3 | semleges transzmisszió | +0,576% | +0,047% | +0,144% | +1,143% |

## 3. Értelmezés

Ez nem meglepő eredmény. Semleges transzmisszió mellett a nagyvállalati blokk
nyer többet, mert:

- a nagyvállalati szektor exportkitettsége nagyobb;
- az exporttömeg jelentős része a nagyvállalati blokkban van;
- a modell pénzügyi akcelerátorában `chi_L < chi_E, chi_D`, ezért ugyanakkora
  felárcsökkenés mellett a nagyvállalati beruházás erősebben reagál;
- a `v06_3type` még nem tartalmaz külön hitelhozzáférési/extenzív margót,
  amely a KKV-k számára több, korábban nem finanszírozott beruházást nyitna
  meg.

Ezért a `v06_3type` legfontosabb tanulsága nem az, hogy a KKV-narratíva hibás,
hanem az, hogy a KKV-előny nem következik automatikusan a semleges
makropénzügyi csatornából. A KKV-előny akkor jelenik meg, ha a finanszírozási
prémiumcsökkenés aránytalanul jobban javítja a KKV-k feltételeit, vagy ha a
modellben szerepel egy külön hozzáférési csatorna.

## 4. Tanulmánybeli állítás

Védhető megfogalmazás:

> Semleges pénzügyi transzmisszió mellett az euróbevezetés nagyobb közvetlen
> reálgazdasági nyereséget ad a nagyvállalati/exportáló blokknak. A KKV-előny
> csak akkor jelenik meg, ha a közös valuta a KKV-k finanszírozási korlátait
> aránytalanul jobban lazítja, vagy ha a modellbe bekerül a hitelhozzáférési
> extenzív margin.

## 5. Következő modelllépés

A következő technikai verzió a `v07_access`. Ennek célja nem az, hogy
feltevésből kikényszerítse a KKV-előnyt, hanem hogy külön csatornaként
tesztelje a hitelhozzáférési margót.

A redukált forma:

```text
acc_E = rho_acc * acc_E(-1) - lambda_acc_E * efp_E
acc_D = rho_acc * acc_D(-1) - lambda_acc_D * efp_D

q_E = phi_i * (i_E - k_E(-1) - omega_acc_E * acc_E)
q_D = phi_i * (i_D - k_D(-1) - omega_acc_D * acc_D)
```

Intuíció: ha a KKV-felár (`efp_E`, `efp_D`) csökken, akkor az `acc_E` és
`acc_D` hozzáférési változó javul, és többletberuházást enged be azoknál a
cégeknél, amelyek a tisztán intenzív beruházási reakcióban még nem
jelennének meg.

Ezt külön kell kezelni a beszállítói `Γ`-blokktól. A `Γ` fontos, de a KKV-k
fő empirikus története jelenleg inkább a hitelhozzáférési küszöbön áll.
