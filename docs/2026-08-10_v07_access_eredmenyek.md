# v07_access eredmények — mit változtat a hitelhozzáférési margin?

*2026-08-10 · rövid értelmező memo a `kkv_dsge_v07_access.mod`,
`run_v07_access` és `t30_v07_access_tscen_sens.csv` alapján.*

## 1. Technikai státusz

A `v07_access` modell Dynare 6.5 alatt lefutott:

- 64 endogén változó,
- 64 egyenlet,
- Blanchard-Kahn feltétel teljesül,
- perfect foresight megoldás mindhárom euró-szcenárióra megvan.

A MATLAB Drive warningok nem modellhibák voltak, hanem abból jöttek, hogy a
futtató script Windows-os Dynare path alapértéket próbált hozzáadni. A script
javítva lett: csak akkor hív `addpath`-ot, ha a `DYNARE_PATH` létezik.

## 2. Alapszcenárió semleges transzmisszióval

A `run_v07_access` alapszcenáriója `TSCEN=3`, vagyis nem teszünk fel
KKV-erősebb prémium-transzmissziót. Ebben a körben a hosszú távú eredmények:

| szcenárió | aggregált GDP | export-KKV `y_E` | hazai KKV `y_D` | nagyvállalat `y_L` |
|---|---:|---:|---:|---:|
| alap | +0,764% | +0,525% | +0,870% | +0,772% |
| optimista | +1,040% | +0,714% | +1,185% | +1,051% |
| pesszimista | +0,487% | +0,335% | +0,555% | +0,493% |

Ez érdemi változás a `v06_3type` eredményéhez képest. A `v06` semleges
transzmisszió mellett a nagyvállalati blokk dominanciáját adta. A `v07` azt
mutatja, hogy ha a KKV-k beruházásában külön hitelhozzáférési margin is
szerepel, akkor semleges prémium-transzmisszió mellett is megjelenhet KKV-hatás.

## 3. TSCEN-érzékenység

| TSCEN | értelmezés | aggregált GDP | `y_E` | `y_D` | `y_L` | `acc_E` | `acc_D` |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | KKV-erősebb transzmisszió | +0,741% | +1,385% | +1,474% | −0,119% | +0,453% | +0,428% |
| 2 | nagyvállalat-erősebb transzmisszió | +0,860% | −0,115% | +0,541% | +1,513% | +0,253% | +0,300% |
| 3 | semleges transzmisszió | +0,764% | +0,525% | +0,870% | +0,772% | +0,324% | +0,333% |

## 4. Értelmezés

A hozzáférési margin pontosan azt a csatornát hozza be, amely a `v06`-ból még
hiányzott. A KKV-k nem azért reagálnak erősebben, mert ugyanarra az intenzív
beruházási problémára nagyobb Tobin-Q választ adnak, hanem azért, mert a
felárcsökkenés több korábban hitelkorlátos céget enged be a beruházási
körbe.

Ez a mechanizmus különösen a hazai orientációjú KKV-nál erős a jelenlegi
kalibrációban, mert `lambda_acc_D` és `omega_acc_D` nagyobb, mint az
export-orientált KKV megfelelő paraméterei. Ez közgazdaságilag védhető lehet,
ha a hazai KKV-k hitelhozzáférési korlátja erősebb, de empirikus horgony
nélkül ezt érzékenységi feltevésként kell kezelni.

## 5. Mit szabad állítani?

Védhető állítás:

> A háromszektoros modell semleges pénzügyi transzmisszió mellett a
> nagyvállalati blokk dominanciáját adja. Ha azonban a KKV-k esetében külön
> hitelhozzáférési margin is szerepel, akkor semleges transzmisszió mellett is
> érdemi KKV-hatás jelenik meg. Ez alátámasztja, hogy a KKV-narratíva kulcsa
> nem a nyers kamatszint, hanem a finanszírozási hozzáférés.

Amit nem szabad túlállítani:

> A `v07_access` nem bizonyítja empirikusan a hozzáférési margin méretét. A
> hozzáférési paraméterek redukált formájú kalibrációk, amelyeket MNB-adattal
> vagy vállalati panelből becsült hozzáférési reakcióval kell horgonyozni.

## 6. Következő lépés

A következő technikai feladat nem új modellblokk, hanem az access-paraméterek
érzékenységi és empirikus horgonyzása:

- `lambda_acc_E`, `lambda_acc_D`;
- `omega_acc_E`, `omega_acc_D`;
- `rho_acc`.

Minimum érzékenységi futás: gyenge, közepes és erős hozzáférési margin. A
tanulmányban csak akkor szabad a KKV-hatást fő eredményként kommunikálni, ha
az nem kizárólag egy agresszív access-paraméterezés mellett jelenik meg.

A küszöbkereséshez a `run_v07_access_threshold.m` script készült. Ez
`ACCSCALE=0:10:150` gridet futtat semleges `TSCEN=3` mellett, és külön
kiírja, hol teljesül először:

- `y_D >= y_L`;
- `y_E >= y_L`;
- súlyozott `y_KKV >= y_L`.
