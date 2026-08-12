# v07_access összefoglaló — háromszektoros euróbevezetési modell KKV-hitelhozzáférési margóval

*2026-08-10 · meeting-kompatibilis technikai összefoglaló*

## 1. Mi készült el?

Elkészült és Dynare 6.5 alatt lefutott a háromszektoros modell első olyan
változata, amelyben a KKV-hatás nem pusztán a prémiumcsökkenés intenzív
beruházási reakcióján keresztül jelenik meg, hanem külön hitelhozzáférési
margin is szerepel.

A modell három vállalati szektort különít el:

- `E`: export-orientált KKV;
- `D`: hazai orientációjú KKV;
- `L`: aggregált nagyvállalat.

Mindhárom szektornak külön termelési, árazási, beruházási és pénzügyi
akcelerátor blokkja van. A szektorok külön exportkereslettel rendelkeznek
(`x_E`, `x_D`, `x_L`), az aggregált export pedig ezek súlyozott átlaga.

Technikai státusz:

| modell | változó | egyenlet | BK | perfect foresight |
|---|---:|---:|---|---|
| `v06_3type` | 62 | 62 | teljesül | lefut |
| `v07_access` | 64 | 64 | teljesül | lefut |

Az unió-ági külső zárás külön `nu_uni=0.25` horgonyt használ. Ezzel az alap
szcenárió terminalis külső pozíciója `bstar=-0.01`, vagyis nem szalad el a
külső pozíció.

## 2. Mi volt a v06 fő tanulsága?

A `v06_3type` modellben még nincs külön hitelhozzáférési margin. Ebben a
verzióban a kérdés az volt: ha az euróbevezetés szuverén és banki
prémiumcsökkenése azonos erővel megy át a KKV-kra és a nagyvállalatokra,
akkor melyik blokk nyer nagyobbat?

A válasz: semleges pénzügyi transzmisszió mellett a nagyvállalati blokk nyer.

| transzmisszió | aggregált GDP | export-KKV `y_E` | hazai KKV `y_D` | nagyvállalat `y_L` |
|---|---:|---:|---:|---:|
| KKV-erősebb | +0,496% | +0,694% | +0,550% | +0,372% |
| nagyvállalat-erősebb | +0,695% | −0,462% | −0,125% | +1,832% |
| semleges | +0,576% | +0,047% | +0,144% | +1,143% |

Ez nem meglepő és nem modellhiba. A nagyvállalati blokk exportkitettsége
nagyobb, az exporttömeg jelentős része ott van, és a pénzügyi akcelerátor
algebrája miatt ugyanakkora felárcsökkenés mellett a nagyvállalati beruházás
erősebben reagál.

A `v06` tanulsága ezért módszertanilag fontos:

> A KKV-előny nem automatikus következménye az euróbevezetés semleges
> makropénzügyi csatornájának. A KKV-narratíva kulcsa nem a nyers
> kamatszint, hanem a finanszírozási hozzáférés.

## 3. Mit ad hozzá a v07_access?

A `v07_access` modell redukált formában bevezet egy KKV-specifikus
hitelhozzáférési margót. Ez azt méri, hogy a felár csökkenése nemcsak a már
hitelezett cégek intenzív beruházását emeli, hanem korábban hitelkorlátos
cégeket is beenged a beruházási körbe.

A hozzáférési blokk:

```text
acc_E = rho_acc * acc_E(-1) - lambda_acc_E * efp_E
acc_D = rho_acc * acc_D(-1) - lambda_acc_D * efp_D
```

Beruházási kapcsolat:

```text
q_E = phi_i * (i_E - k_E(-1) - omega_acc_E * acc_E)
q_D = phi_i * (i_D - k_D(-1) - omega_acc_D * acc_D)
```

Intuíció: ha a KKV-felár csökken, akkor `acc_E` és `acc_D` javul. Ez többlet
beruházási keresletet enged be az E és D KKV-szektorban. A nagyvállalati
szektorban nincs ilyen access margin.

## 4. v07 eredmények semleges transzmisszió mellett

A `run_v07_access` alapszcenáriója semleges pénzügyi transzmisszióval fut
(`TSCEN=3`). Ebben a modell már nem a nagyvállalat egyértelmű dominanciáját
adja:

| euró-szcenárió | aggregált GDP | export-KKV `y_E` | hazai KKV `y_D` | nagyvállalat `y_L` |
|---|---:|---:|---:|---:|
| alap | +0,764% | +0,525% | +0,870% | +0,772% |
| optimista | +1,040% | +0,714% | +1,185% | +1,051% |
| pesszimista | +0,487% | +0,335% | +0,555% | +0,493% |

Az alapszcenárióban a hazai KKV (`D`) reagál legerősebben, a nagyvállalat
második, az export-orientált KKV pozitív, de kisebb hatást kap.

Ez azt jelenti, hogy a hozzáférési margin képes átfordítani a v06 eredményét:
semleges pénzügyi transzmisszió mellett is megjelenik érdemi KKV-hatás.

## 5. Mekkora access margin kell a KKV-előnyhöz?

A kulcskérdés az, hogy a hozzáférési margin mennyire erős. Ezért készült az
`ACCSCALE` érzékenység. Az `ACCSCALE=0` kikapcsolja a hozzáférési csatornát,
az `ACCSCALE=100` a jelenlegi baseline kalibráció, az `ACCSCALE=150` erősebb
hozzáférési reakciót jelent.

| ACCSCALE | aggregált GDP | `y_E` | `y_D` | `y_L` |
|---:|---:|---:|---:|---:|
| 0 | +0,576% | +0,047% | +0,144% | +1,143% |
| 50 | +0,636% | +0,181% | +0,382% | +1,026% |
| 100 | +0,764% | +0,525% | +0,870% | +0,772% |
| 150 | +0,888% | +0,931% | +1,317% | +0,517% |

A küszöbkeresés `ACCSCALE=0:10:150` grid alapján, lineáris interpolációval:

| feltétel | küszöb |
|---|---:|
| hazai KKV megelőzi a nagyvállalatot: `y_D >= y_L` | 93,6 |
| export-KKV megelőzi a nagyvállalatot: `y_E >= y_L` | 118,3 |
| súlyozott KKV-blokk megelőzi a nagyvállalatot: `y_KKV >= y_L` | 101,0 |

Ez a modell legfontosabb új eredménye:

> A KKV-előny nem beégetett modellfeltevés. A nagyvállalat dominál, ha nincs
> hitelhozzáférési margin. A súlyozott KKV-blokk akkor előzi meg a
> nagyvállalatot, ha a hozzáférési csatorna nagyjából eléri a baseline
> kalibráció erősségét.

## 6. Mit szabad állítani?

Erős, védhető állítás:

> A háromszektoros modell szerint semleges pénzügyi transzmisszió mellett az
> euróbevezetés közvetlen reálgazdasági nyeresége alapból a nagyvállalati
> blokkban koncentrálódik. A KKV-előny akkor jelenik meg, ha a felár
> csökkenése a hitelhozzáférési küszöbön is átlök cégeket. Ez összhangban
> van az empirikus narratívával, amely szerint a KKV-probléma főként
> hozzáférési, nem nyers kamatszint-probléma.

Amit nem szabad túlállítani:

> A `v07_access` jelenleg nem empirikusan becsült access-modul. A
> hozzáférési paraméterek redukált formájú kalibrációk. A modell azt mutatja
> meg, mekkora hozzáférési reakció mellett fordul át a szektorális eredmény,
> nem azt, hogy ez a reakció biztosan ekkora a magyar adatokban.

## 7. Mi a következő empirikus feladat?

A következő feladat az access-paraméterek empirikus horgonyzása. A legfontosabb
paraméterek:

- `lambda_acc_E`, `lambda_acc_D`: mennyire reagál a hozzáférési margin a
  felárcsökkenésre;
- `omega_acc_E`, `omega_acc_D`: a hozzáférési margin mennyire fordul át
  többletberuházásba;
- `rho_acc`: mennyire tartós a hozzáférési állapot.

A horgonyzáshoz szükséges adatok:

- MNB új szerződéses hitelkamat méret szerint;
- támogatott és piaci hitelek bontása;
- hitelhez jutási arány méret és exportstátusz szerint;
- beruházási aktivitás külön hitelezett és nem hitelezett KKV-kra.

Minimum empirikus cél:

> Meg kell becsülni vagy legalább sávosan kalibrálni, hogy egy 100 bp-os
> felárcsökkenés mekkora változást okoz a KKV-k hitelhozzáférési arányában,
> és ebből mekkora beruházási többlet következik.

## 8. Döntési javaslat

Javasolt modellstátusz:

- `v06_3type`: diagnosztikai baseline, amely megmutatja, hogy access margin
  nélkül L dominál;
- `v07_access`: fő KKV-mechanizmus tesztmodell, amely megmutatja az access
  küszöböt;
- `Γ` beszállítói blokk: következő, de nem elsődleges bővítés. Előbb az
  access-paramétereket kell horgonyozni.

Javasolt tanulmánybeli szerkezet:

1. Semleges transzmissziós baseline: nagyvállalati dominancia.
2. Hitelhozzáférési margin bevezetése: KKV-hatás megjelenik.
3. Küszöb: a súlyozott KKV-blokk kb. `ACCSCALE=101` mellett előzi meg az L
   blokkot.
4. Empirikus nyitott kérdés: a magyar adatok alapján eléri-e a hozzáférési
   reakció ezt a nagyságrendet.
