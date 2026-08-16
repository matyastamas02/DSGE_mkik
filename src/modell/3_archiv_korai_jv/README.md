# 3. ARCHÍVUM — korai JV-lépcsők

> **Meghaladott modellek.** Nem ezekkel dolgozunk. A leadandó a
> [`1_fo_vonal_jv/`](../1_fo_vonal_jv/)-ban van.
>
> **Miért nem töröltük őket:** mindegyik megtanított valamit, amit a fő
> modell azóta is hordoz. Egy törölt zsákutcát a projekt hajlamos újra
> bejárni — ez már megtörtént.

## Mi van itt, és mit tanultunk belőle

| Fájl | Státusz | A tanulság, ami megmaradt |
|---|---|---|
| `jv_dsge_v01.mod` | meghaladott | **Egységgyök-csapda:** a relatívár-identitások naiv felírása egységgyököt hagy. A megoldás — a súlyozott relatívár-összeg explicit nullára kötése, és az `infl` reziduumként — a **v08-ban ma is így van**. |
| `jv_dsge_v02.mod` | meghaladott, de **él** | A JV-mag + kétszektoros BGG. Ennek app-vezérelt változata a [`4_app/jv_app_model.mod`](../4_app/), tehát a fájl nem halott. |
| `jv_dsge_v03.mod` | meghaladott | első teljes szcenárió-futás (`szcenario_v03`, `t19`) |
| `jv_dsge_v04.mod` | **BK-KUDARC** | A szegmens-tőke + árszint-szétválasztás **együtt** törte el a modellt, külön-külön egyik sem. Ebből lett a szabály: **szerkezeti bővítést lépcsőzetesen**, mindegyikre külön BK-teszt. |
| `jv_dsge_v05.mod` | meghaladott | A szegmens-tőke itt még **reallokációs maradék** volt — ebből nem szabad szegmens-eredményt közölni. A `v06` oldotta meg. Lásd `docs/modszertan/jv_v05_szerkezeti_tanulsagok_Samu.md`. |
| `jv_dsge_v06_stoch.mod` | ⚠ **NYITOTT TÉTEL** | lásd lentebb |

## ⚠ `jv_dsge_v06_stoch.mod` — csapatdöntést igényel

A csapattárs sztochasztikus fájlja (2026-08-05), a **`v05` ikerpárja**:
az `uni` fordítási idejű makró (`-DUNI=0|1`), így mindkét rezsim külön
lineáris modell, amin megy a `stoch_simul`. Célja a **stabilizációs
költség** mérése (OCA-kérdés).

Három ok, amiért itt van, és nem a fő vonalban:

1. **Nincs hozzá futtató** — így nem is reprodukálható.
2. **Névütközés:** a „v06" szám a fő vonalon a `jv_dsge_v06.mod`-é, ez
   viszont a `v05`-re épül. A számozás tehát félrevezető.
3. A fejléce két kötelező ellenőrzést ír elő (közös zárás `nu_fx`-szel;
   `check;` előbb, mert az `UNI=1` ágon nincs Taylor-szabály), és ezek
   sincsenek lefuttatva.

**Ez az elhelyezés ideiglenes** — nem tudtam eldönteni, hova tartozik.
Ha a stabilizációs költség bekerül a tanulmányba, ez a fájl a fő vonalba
való, saját futtatóval és rendezett névvel.

## Futtatás

```bash
matlab -batch "cd('src/modell/3_archiv_korai_jv/futtato'); run_jv_v05"
```

⚠ **`run_jv_v06.m` a kivétel:** ez **két mappából** használ modellt — a
`jv_dsge_v05`-öt innen, a `jv_dsge_v06`-ot a fő vonalból —, mert épp a
kettő összevetése a lényege (ez bizonyítja, hogy a v05-ben a két felár egy
pontba fut, a v06-ban nem). A script mindkét útvonalat külön kezeli.
