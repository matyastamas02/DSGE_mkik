# 1. FŐ VONAL — Jakab–Világi mag, háromtípusos

> ## 🎯 A fő csapás (2026-11-07 óta): [`jv_dsge_v12.mod`](jv_dsge_v12.mod)
>
> **Minden új munka erre épül.** A v12 a v11 három új alapértelmezéssel:
>
> - **B-forma hitelhozzáférés** (`-DACCFORM=1`): tőkeköltség-ék, nem additív beruházási tag;
> - **JV-exportegyenlet** (`-DEXPJV=1`): az `(1−hx)` súly nélkül;
> - **javított nettóvagyon-egyenlet** (`-DNWFIX=1`): a szuverén és a banki felár is levonódik az adósság után.
>
> Kikapcsolva bitre a v11. Futtató: `check_v12.m` → `t68`–`t68c`; állítások:
> `A36`, `F17`. Az euró GDP-hatása a 16–20. évben 0,39% (v11: 0,52%); a
> hozzáférési csatorna +0,006 pp.
>
> *Korábban (2026-08-12-től) a `jv_dsge_v09_access.mod` volt a leadandó, utána a
> v11 aktív alapértelmezése. Mindkettő megmarad, a füstteszt őrei rajtuk állnak.*

A 2026-07-13-i csapatdöntés szerint az alapmodell a **Jakab–Világi** (MNB WP
2008/9), mert annak paraméterei **magyar adaton becsültek** — 91-ből 28
ezzel azonnal horgonyzott. Ez a mappa a döntés kódbeli megvalósítása.

## Mi van itt, és milyen sorrendben

A négy fájl **egy levezetés négy lépcsője**, nem négy alternatíva. Mindegyik
a nála eggyel kisebbre épül, és mindegyik külön Blanchard–Kahn tesztet kapott.

| Fájl | Mit ad hozzá | régi PF-stressz | Mit bizonyított |
|---|---|---|---|
| `jv_dsge_v06.mod` | szegmens-specifikus tőkehozam (`rk_j`) | 18/18 | a `chi`-patológia nagyrészt a **közös `rk`** következménye volt |
| `jv_dsge_v07_3type.mod` | három típus (E/D/L), közös ár | 18/18 | közös ár mellett a típus-kibocsátás **mechanikus** — ebből a lépcsőből szegmens-eredményt közölni nem szabad |
| `jv_dsge_v08_3type_arak.mod` | típusonkénti ár és kereslet | 18/18; BK nem mérve | a v04-es numerikus kudarc **nem volt elkerülhetetlen** — ott a *kombináció* volt a baj |
| `jv_dsge_v09_access.mod` | hitelhozzáférési (extenzív) margó | 18/18 (`OPTEN=0`) | nesting: `ACCSCALE=0` → **pontosan** a v08 (eltérés 0,0e+00) |
| `jv_dsge_v10_foreign.mod` | külföldi kereslet és EKB-kamat (`-DFOREIGN=1`) | — | `FOREIGN=0` mellett bitre a v09 |
| `jv_dsge_v11.mod` | specifikációs kapcsolók, javasolt kalibráció és zárás, fiskális blokk | 9/9 (`F11`) | a régi beállítással bitre a v10 |
| **`jv_dsge_v12.mod`** | **B-forma hozzáférés, JV-exportegyenlet, javított nettóvagyon-egyenlet** | **24/24 BK (`A36`)** | kikapcsolva **bitre a v11**; a reviewer 184 számából 182 visszajön |

**Miért maradnak itt a korábbi lépcsők, ha csak a v09 a leadandó:** mert a
füstteszt őrei rajtuk állnak (`t34`, `t35`, `t40`–`t43`), és mert a v09
nesting-tesztje **egyszerre futtatja a v08-at és a v09-et**. Ha ezeket

> **BK-korrekció (2026-08-24):** a `t47` teljes kalibrációs rácsa 36/36
> perfect-foresight megoldást, de csak 9/36 terminális lokális BK-stabil
> esetet ad. Az `OPTEN=0` ág 9/9 stabil (13/13); az `OPTEN=1/2/3` ágak
> 0/27 stabilak (15/13). A fenti 18/18 kizárólag az alapértelmezett
> `OPTEN=0` stresszrácsra vonatkozik.
archívumba tennénk, a fő modell bizonyítéka szűnne meg.

## Futtatás

Minden futtató a [`futtato/`](futtato/) mappában van, és **maga lép a
megfelelő könyvtárba** — elég a nevén hívni:

```bash
matlab -batch "cd('src/modell/1_fo_vonal_jv/futtato'); stress_jv_access_v09"
```

| Script | Mit csinál | Kimenet |
|---|---|---|
| **`check_v12.m`** | **a fő csapás: nesting a v11-re, a reviewer számainak reprodukciója, BK-rács, a v12 eredményei** | `t68`–`t68c` |
| `stress_opten_v09.m` | az Opten-kalibráció hatása + `rho_acc` scan | `t47`–`t49b` |
| `sens_lam_om_v09.m` | **az `ACCSCALE` szétbontása**: a küszöb a `(λ, ω)` síkon | `t52`–`t52e` |
| `dekomp_edl_v09.m` | **E/D/L dekompozíció**: technológia vagy finanszírozás? | `t53`–`t53d` |
| `stress_jv_access_v09.m` | 4. lépcső: BK-stressz, nesting, `ACCSCALE`-küszöb | `t44`, `t45`, `t45b` |
| `stress_jv_3type_arak.m` | 3. lépcső + `eps_ces` érzékenység | `t41`, `t42` |
| `stress_jv_3type.m` | 2. lépcső PF-solver stressz (nem BK) | `t40` |
| `ellenorzes_3type.m` | **független verifikáció** (17 azonosság) | `t43` |
| `sens_chi_psi_v06.m` · `stress_v06.m` · `check_v06_ss.m` | a v06-lépcső vizsgálatai | `t35` |

## Makró-kapcsolók

**v12:** **`-DACCFORM=0|1`** (A / **B**, alap 1) · **`-DACCMUE=<x>` / `-DACCMUD=<x>`**
(a `μ_j`, alap 0,0051 / 0,0116) · **`-DEXPJV=0|1`** (alap 1) · **`-DNWFIX=0|1`**
(alap 1). A v11 kapcsolói (`KALIB`, `EXTCLOSE`, `SOVCSAT`, `NWSPEC`, `FISCAL`,
`PENS`, `KONSZ` stb.) a v12-ben változatlanul megvannak.

**Korábbiak:** `-DSCENARIO=1..4` · `-DTSCEN=1|2|3` · `-DACCSCALE=<0..150>` · `-DEPSCES=<x>` ·
`-DSYM=1` (szimmetria-teszt) · `-DNOVERT=1` · `-DNUUNI=<x>` ·
**`-DOPTEN=0|1|2|3`** (kalibrációs ág) · **`-DRHOACC=<x>`** ·
**`-DLAMSCALE=<x>` / `-DOMSCALE=<x>`** (az `ACCSCALE` két lépcsője külön;
alapértelmezés `-1` = az `ACCSCALE`-t örökli, tehát bitre visszafelé
kompatibilis) · **`-DDECOMP=0|1|2|3|4`** (E/D/L dekompozíciós ág) ·
**`-DDECOMPW=0|1`** (a közös érték méretsúlyozott vagy számtani átlag)

Kalibrációs változtatás **mindig kapcsolóval**, ne felülírással — így minden
variáns futtatható és összevethető marad. Az alapértelmezés váltása
**csapatdöntés**, nem kódolási lépés.

## Amit erről a modellről NEM szabad közölni

- **Szegmens-szintű kibocsátást pontbecslésként** — két horgonyzatlan
  paraméter (`eps_ces`, `ACCSCALE`) viszi, és mindkettőn fordul az előjel.
  Küszöbforma kell.
- **Az „`ACCSCALE` ≥ 22,3" küszöböt EGY SZÁMKÉNT** — 2026-08-24 óta tudjuk,
  hogy a modell a `lambda_acc`-ot és az `omega_acc`-ot külön nem
  azonosítja, csak a szorzatukat (`A22`). A közlendő objektum
  `(λ·ω)* = 500`; a 22,3 ennek egyetlen pontja (`√500`).
- **Az `s_kkv` IO-számokat** — a mérés hibás (`docs/figyelmeztetesek/`).
- **A `t_S > t_L` feltevést** eredményként — nem azonosítható.

*Az aktuális állításokat és a paraméterek státuszát az
[`ALLAPOT.md`](../../../ALLAPOT.md) viszi, nem ez a fájl.*
