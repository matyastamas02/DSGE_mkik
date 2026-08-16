# 1. FŐ VONAL — Jakab–Világi mag, háromtípusos

> **Itt van a leadandó modell:** [`jv_dsge_v09_access.mod`](jv_dsge_v09_access.mod)

A 2026-07-13-i csapatdöntés szerint az alapmodell a **Jakab–Világi** (MNB WP
2008/9), mert annak paraméterei **magyar adaton becsültek** — 91-ből 28
ezzel azonnal horgonyzott. Ez a mappa a döntés kódbeli megvalósítása.

## Mi van itt, és milyen sorrendben

A négy fájl **egy levezetés négy lépcsője**, nem négy alternatíva. Mindegyik
a nála eggyel kisebbre épül, és mindegyik külön Blanchard–Kahn tesztet kapott.

| Fájl | Mit ad hozzá | BK | Mit bizonyított |
|---|---|---|---|
| `jv_dsge_v06.mod` | szegmens-specifikus tőkehozam (`rk_j`) | 18/18 | a `chi`-patológia nagyrészt a **közös `rk`** következménye volt |
| `jv_dsge_v07_3type.mod` | három típus (E/D/L), közös ár | 18/18 | közös ár mellett a típus-kibocsátás **mechanikus** — ebből a lépcsőből szegmens-eredményt közölni nem szabad |
| `jv_dsge_v08_3type_arak.mod` | típusonkénti ár és kereslet | 18/18 | a v04-es BK-kudarc **nem volt elkerülhetetlen** — ott a *kombináció* volt a baj |
| **`jv_dsge_v09_access.mod`** | hitelhozzáférési (extenzív) margó | 18/18 | nesting: `ACCSCALE=0` → **pontosan** a v08 (eltérés 0,0e+00) |

**Miért maradnak itt a korábbi lépcsők, ha csak a v09 a leadandó:** mert a
füstteszt őrei rajtuk állnak (`t34`, `t35`, `t40`–`t43`), és mert a v09
nesting-tesztje **egyszerre futtatja a v08-at és a v09-et**. Ha ezeket
archívumba tennénk, a fő modell bizonyítéka szűnne meg.

## Futtatás

Minden futtató a [`futtato/`](futtato/) mappában van, és **maga lép a
megfelelő könyvtárba** — elég a nevén hívni:

```bash
matlab -batch "cd('src/modell/1_fo_vonal_jv/futtato'); stress_jv_access_v09"
```

| Script | Mit csinál | Kimenet |
|---|---|---|
| `stress_opten_v09.m` | az Opten-kalibráció hatása + `rho_acc` scan | `t47`–`t49b` |
| `stress_jv_access_v09.m` | 4. lépcső: BK-stressz, nesting, `ACCSCALE`-küszöb | `t44`, `t45`, `t45b` |
| `stress_jv_3type_arak.m` | 3. lépcső + `eps_ces` érzékenység | `t41`, `t42` |
| `stress_jv_3type.m` | 2. lépcső BK-stressz | `t40` |
| `ellenorzes_3type.m` | **független verifikáció** (17 azonosság) | `t43` |
| `sens_chi_psi_v06.m` · `stress_v06.m` · `check_v06_ss.m` | a v06-lépcső vizsgálatai | `t35` |

## Makró-kapcsolók

`-DSCENARIO=1..4` · `-DTSCEN=1|2|3` · `-DACCSCALE=<0..150>` · `-DEPSCES=<x>` ·
`-DSYM=1` (szimmetria-teszt) · `-DNOVERT=1` · `-DNUUNI=<x>` ·
**`-DOPTEN=0|1|2|3`** (kalibrációs ág) · **`-DRHOACC=<x>`**

Kalibrációs változtatás **mindig kapcsolóval**, ne felülírással — így minden
variáns futtatható és összevethető marad. Az alapértelmezés váltása
**csapatdöntés**, nem kódolási lépés.

## Amit erről a modellről NEM szabad közölni

- **Szegmens-szintű kibocsátást pontbecslésként** — két horgonyzatlan
  paraméter (`eps_ces`, `ACCSCALE`) viszi, és mindkettőn fordul az előjel.
  Küszöbforma kell.
- **Az `s_kkv` IO-számokat** — a mérés hibás (`docs/figyelmeztetesek/`).
- **A `t_S > t_L` feltevést** eredményként — nem azonosítható.

*Az aktuális állításokat és a paraméterek státuszát az
[`ALLAPOT.md`](../../../ALLAPOT.md) viszi, nem ez a fájl.*
