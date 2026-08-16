# 2. REFERENCIA-VONAL — EAGLE-HU mag

> **Ez NEM versenyző és NEM elvetett.** Robusztussági összevetés a fő
> vonalhoz. A leadandó modell a [`1_fo_vonal_jv/`](../1_fo_vonal_jv/)-ban van.

Ez a sor volt a projekt eredeti gerince. A 2026-07-13-i csapatdöntés a
Jakab–Világi magra váltott, mert annak paraméterei magyar adaton becsültek —
de az EAGLE-vonal megmaradt, mert **független szerkezeten adott hasonló
aggregált eredményt**, és ez önmagában bizonyíték.

## Mi van itt

| Fájl | Mit ad hozzá |
|---|---|
| `kkv_dsge_v01.mod` | futó váz |
| `kkv_dsge_v02.mod` | euró-belépési szcenárió |
| `kkv_dsge_v03.mod` | WP 2017/7 kalibráció + UIP-országprémium |
| `kkv_dsge_v04.mod` | rezsimváltás + nem-Ricardiánus háztartások |
| `kkv_dsge_v05.mod` | Calvo-bérek (EHL bér-Phillips-görbe) |
| `kkv_dsge_v06_3type.mod` | az első explicit háromtípusos váz (E/D/L) |
| `kkv_dsge_v07_access.mod` | hitelhozzáférési margó Tobin-Q-n keresztül |

## ⚠ Amit a két vonal között NEM szabad összehasonlítani

**Az `ACCSCALE` skálája a két magon nem feleltethető meg egy-az-egyben.**
Az EAGLE-vonalon az access a **Tobin-Q**-n át hat
(`q = phi_i·(i − k − ω·acc)`), a JV-magon viszont a beruházási
**Euler-egyenlet** additív forcing tagja. Ezért az itteni küszöbök (94–101)
és a fő vonaléi (22–62) **külön skálán vannak**.

Amit a két szám együtt mutat: **mindkét magon létezik véges küszöb** — a
szintjük nem összevethető.

Ugyanígy: ha valahol EAGLE-értékeket látsz (`sigma`=0,4, `om_nr`=0,75,
`rho_a`=0,90), az **ez a vonal**, nem a fő. Az `om_nr`-nél a két vonal
között **háromszoros** az eltérés.

## Futtatás

```bash
matlab -batch "cd('src/modell/2_referencia_eagle/futtato'); run_v07_access"
```

| Script | Kimenet |
|---|---|
| `run_v01` … `run_v05` | `irf_v01`, `szcenario_v02/v03`, `t16`–`t18` |
| `run_v06_3type` · `run_v06_3type_tscen_sens` | `t27`, `t28`, `f23` |
| `run_v07_access` · `_tscen_sens` · `_scale_sens` · `_threshold` | `t29`–`t33`, `f24` |
| `sens_calib_v07` · `sens_calib_kuszob_v07` | `t38`, `t39`, `t39b` |

**Replikálva 2026-08-12:** a `v07_access` minden közölt száma pontosan
kijött (alap: y +0,764% / E +0,525% / D +0,870% / L +0,772%; küszöbök
93,6 / **101,0** / 118,3).
