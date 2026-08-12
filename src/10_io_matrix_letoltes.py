# -*- coding: utf-8 -*-
"""A TELJES magyar ágazat×ágazat input-output mátrix letöltése és mentése.

MIÉRT PYTHON: JSON-API letöltő, mint a 01-08; a modellezés marad MATLAB-ban.

MIÉRT KELL, KÉT OKBÓL:

  (1) REPRODUKÁLHATÓSÁG. A `07_io_hazai_input_arany.py` élőben tölt le az
      Eurostat API-ról, és semmit nem ment ki nyersen — csak a `t24`
      végeredményt írja. Ha az API változik vagy leáll, a `t24` NEM
      reprodukálható. A repo szabálya szerint az `output/` teljes egészében
      elő kell álljon a `src/`-ből; jelenleg ez egy külső szolgáltatás
      elérhetőségén múlik. Ez a script NYERSEN is kiment mindent.

  (2) A `Γ` MÁTRIX IMPUTÁCIÓJA. A `07` csak nyolc ágazatra és csak a
      hazai/import ARÁNYT kéri le. A háromtípusos modell köztesinput-
      mátrixához (`docs/2026-08-05_modell_specifikacio_v07.md`, 4.2) a
      TELJES `a_sr` együtthatómátrix kell:
          Γ_jk = Σ_s Σ_r ω_js · a_sr · ω_kr
      ahol `ω_js` a típusok ágazati összetétele az Opten-panelből.

MIT TÖLT LE (Magyarország, konfigurálható év):
  - naio_10_cp1620 : használati tábla, HAZAI output (termék × ágazat)
  - naio_10_cp1630 : használati tábla, IMPORT (termék × ágazat)
  - nama_10_a64    : P1 kibocsátás és P2 köztes felhasználás ágazatonként

MIT ÁLLÍT ELŐ:
  data/raw/io/naio_10_cp1620_HU_<ev>.json     nyers JSON-stat
  data/raw/io/naio_10_cp1630_HU_<ev>.json     nyers JSON-stat
  data/raw/io/nama_10_a64_HU_<ev>.json        nyers JSON-stat
  data/processed/io_hasznalat_hazai_<ev>.csv  hosszú alak (termek, agazat, ertek)
  data/processed/io_hasznalat_import_<ev>.csv hosszú alak
  data/processed/io_egyutthato_a_sr_<ev>.csv  a_sr = hazai_use(s,r) / P1(r)

ÖNELLENŐRZÉS: a script a végén újraszámolja a `t24` fő számait a teljes
mátrixból (autóipar, elektronika, export-mag), és összeveti a meglévő
`output/tables/t24_io_hazai_input.csv`-vel. Ha eltérnek, az azt jelenti,
hogy a `07` és ez a script MÁST mér — ilyenkor meg kell nézni, melyik a jó,
mielőtt bármelyik szám modellbe kerül.

FUTTATÁS (a repo gyökeréből, internetkapcsolattal):
    python src/10_io_matrix_letoltes.py
    python src/10_io_matrix_letoltes.py --ev 2022
    python src/10_io_matrix_letoltes.py --offline   # csak a mentett JSON-okból
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

import numpy as np
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
NYERS = REPO / "data" / "raw" / "io"
FELDOLG = REPO / "data" / "processed"
T24 = REPO / "output" / "tables" / "t24_io_hazai_input.csv"

BASE = "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data"

# A dimenziónevek Eurostat-oldalon időnként változnak (ind_use/induse,
# cpa2_1/prod_na). Ezért NEM drótozzuk be őket, hanem felismerjük.
AGAZAT_DIM_JELOLTEK = ["ind_use", "induse", "nace_r2"]
TERMEK_DIM_JELOLTEK = ["cpa2_1", "prod_na", "cpa2_1_use"]


def letolt(url: str, cel: Path, offline: bool) -> dict:
    """Letölt és nyersen kiment; offline módban a mentett fájlt olvassa."""
    if offline or cel.exists():
        if not cel.exists():
            raise SystemExit(f"Offline mód, de hiányzik: {cel}")
        print(f"  [cache] {cel.name}")
        return json.loads(cel.read_text(encoding="utf-8"))
    print(f"  [letöltés] {cel.name}")
    try:
        with urllib.request.urlopen(url, timeout=180) as r:
            js = json.load(r)
    except urllib.error.URLError as e:
        raise SystemExit(
            f"Nem sikerült elérni az Eurostatot: {e}\n"
            "Ha korlátozott hálózaton futtatod, töltsd le máshol, és tedd a "
            f"JSON-t ide: {cel}\nURL: {url}") from e
    cel.parent.mkdir(parents=True, exist_ok=True)
    cel.write_text(json.dumps(js, ensure_ascii=False), encoding="utf-8")
    return js


def dim_nev(js: dict, jeloltek: list[str]) -> str:
    for j in jeloltek:
        if j in js["id"]:
            return j
    raise SystemExit(
        f"Egyik várt dimenziónév sem szerepel: {jeloltek}\n"
        f"A válaszban ezek vannak: {js['id']}\n"
        "Az Eurostat átnevezte a dimenziót — bővítsd a jelöltlistát a "
        "script tetején.")


def hosszu_alak(js: dict, sor_dim: str, oszlop_dim: str) -> pd.DataFrame:
    """JSON-stat -> hosszú alakú DataFrame. A `07` unpack()-jének általánosítása.

    A JSON-stat a `value` szótárban LAPOS indexet használ, sor-major
    sorrendben a dimenziók deklarált sorrendje szerint. A hiányzó cellák
    egyszerűen nincsenek benne — ezért nem lehet reshape-elni, ki kell
    bontani az indexeket.
    """
    dims, meretek = js["id"], js["size"]
    kategoriak = []
    for d in dims:
        idx = js["dimension"][d]["category"]["index"]
        inv = {v: k for k, v in idx.items()}
        kategoriak.append([inv[i] for i in range(len(inv))])

    i_sor = dims.index(sor_dim)
    i_oszl = dims.index(oszlop_dim)

    sorok = []
    for poz, ertek in js["value"].items():
        p = int(poz)
        kulcs = [None] * len(meretek)
        for i in range(len(meretek) - 1, -1, -1):
            kulcs[i] = kategoriak[i][p % meretek[i]]
            p //= meretek[i]
        sorok.append((kulcs[i_sor], kulcs[i_oszl], ertek))
    return pd.DataFrame(sorok, columns=["termek", "agazat", "ertek"])


def kod_egyseges(s: pd.Series) -> pd.Series:
    """CPA_C29 -> C29. A termékkódok CPA-, az ágazatkódok NACE-alakúak."""
    return (s.astype(str)
             .str.replace("^CPA_", "", regex=True)
             .str.strip())


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--ev", default="2021")
    ap.add_argument("--offline", action="store_true")
    a = ap.parse_args()
    ev = a.ev

    NYERS.mkdir(parents=True, exist_ok=True)
    FELDOLG.mkdir(parents=True, exist_ok=True)

    print(f"Magyar IO-tábla, {ev}\n")
    kozos = f"geo=HU&time={ev}&unit=MIO_EUR&format=JSON&lang=EN"
    js_dom = letolt(f"{BASE}/naio_10_cp1620?{kozos}",
                    NYERS / f"naio_10_cp1620_HU_{ev}.json", a.offline)
    js_imp = letolt(f"{BASE}/naio_10_cp1630?{kozos}",
                    NYERS / f"naio_10_cp1630_HU_{ev}.json", a.offline)
    js_na = letolt(
        f"{BASE}/nama_10_a64?geo=HU&time={ev}&unit=CP_MEUR"
        f"&na_item=P1&na_item=P2&format=JSON&lang=EN",
        NYERS / f"nama_10_a64_HU_{ev}.json", a.offline)

    ag_d = dim_nev(js_dom, AGAZAT_DIM_JELOLTEK)
    tk_d = dim_nev(js_dom, TERMEK_DIM_JELOLTEK)
    print(f"\nFelismert dimenziók: termék='{tk_d}', ágazat='{ag_d}'")

    dom = hosszu_alak(js_dom, tk_d, ag_d)
    imp = hosszu_alak(js_imp, dim_nev(js_imp, TERMEK_DIM_JELOLTEK),
                      dim_nev(js_imp, AGAZAT_DIM_JELOLTEK))
    for df in (dom, imp):
        df["termek"] = kod_egyseges(df["termek"])
        df["agazat"] = kod_egyseges(df["agazat"])

    dom.to_csv(FELDOLG / f"io_hasznalat_hazai_{ev}.csv",
               index=False, encoding="utf-8-sig")
    imp.to_csv(FELDOLG / f"io_hasznalat_import_{ev}.csv",
               index=False, encoding="utf-8-sig")
    print(f"Hazai használat: {len(dom)} cella, "
          f"{dom.termek.nunique()} termék × {dom.agazat.nunique()} ágazat")
    print(f"Import használat: {len(imp)} cella")

    # --- nemzeti számlák: P1 kibocsátás, P2 köztes felhasználás ------------
    na = hosszu_alak(js_na, "na_item", dim_nev(js_na, ["nace_r2"]))
    na.columns = ["na_item", "agazat", "ertek"]
    na["agazat"] = kod_egyseges(na["agazat"])
    p1 = na[na.na_item.eq("P1")].set_index("agazat")["ertek"]
    p2 = na[na.na_item.eq("P2")].set_index("agazat")["ertek"]

    # --- a_sr technikai együtthatók: hazai use(s,r) / kibocsátás(r) --------
    # s = szállító TERMÉK/ágazat, r = felhasználó ágazat
    M = dom.pivot_table(index="termek", columns="agazat",
                        values="ertek", aggfunc="sum")
    kozos_ag = [c for c in M.columns if c in p1.index and p1[c] > 0]
    hianyzo = sorted(set(M.columns) - set(kozos_ag))
    if hianyzo:
        print(f"\nFIGYELEM: {len(hianyzo)} ágazathoz nincs P1 kibocsátás, "
              f"kimaradnak: {hianyzo[:8]}{' ...' if len(hianyzo) > 8 else ''}")
    A = M[kozos_ag].div(p1[kozos_ag], axis=1).fillna(0.0)
    A.to_csv(FELDOLG / f"io_egyutthato_a_sr_{ev}.csv", encoding="utf-8-sig")
    print(f"\na_sr mátrix: {A.shape[0]} × {A.shape[1]}, "
          f"kiírva: io_egyutthato_a_sr_{ev}.csv")

    # Diagnosztika: a négyzetes részmátrix spektrálsugara. A modell
    # szempontjából ez a Leontief-inverz létezésének feltétele (spec 4.5).
    kozos_sq = [k for k in A.index if k in A.columns]
    if len(kozos_sq) > 1:
        Asq = A.loc[kozos_sq, kozos_sq].to_numpy(dtype=float)
        rho = float(np.max(np.abs(np.linalg.eigvals(Asq))))
        print(f"Négyzetes részmátrix ({len(kozos_sq)}×{len(kozos_sq)}) "
              f"spektrálsugara: rho = {rho:.4f}  "
              f"({'OK, < 1' if rho < 1 else 'PROBLÉMA, >= 1'})")
        print("  (Ez az ÁGAZATI mátrixé. A modell 3x3 Γ-jára a "
              "11_gamma_imputacio.py számol külön rho-t.)")

    # --- ÖNELLENŐRZÉS a t24-gyel -------------------------------------------
    print("\n" + "=" * 70)
    print("ÖNELLENŐRZÉS: a t24 fő számai újraszámolva a TELJES mátrixból")
    print("=" * 70)
    d_sum = dom.groupby("agazat")["ertek"].sum()
    i_sum = imp.groupby("agazat")["ertek"].sum()
    sorok = []
    for kod in ["C29", "C26", "C27", "C28", "C20", "C22", "C25", "TOTAL"]:
        if kod not in d_sum.index or kod not in i_sum.index:
            continue
        if kod not in p1.index or kod not in p2.index or p1[kod] == 0:
            continue
        hazai_arany = d_sum[kod] / (d_sum[kod] + i_sum[kod])
        sorok.append({"agazat_kod": kod,
                      "hazai_arany_uj": round(hazai_arany, 4),
                      "hazai_koztes_per_output_uj":
                          round(hazai_arany * p2[kod] / p1[kod], 4)})
    uj = pd.DataFrame(sorok)

    if T24.exists() and not uj.empty:
        regi = pd.read_csv(T24)
        oszv = uj.merge(regi[["agazat_kod", "hazai_arany_a_koztesben",
                              "hazai_koztes_per_output"]],
                        on="agazat_kod", how="left")
        oszv["elteres"] = (oszv["hazai_koztes_per_output_uj"]
                           - oszv["hazai_koztes_per_output"])
        print(oszv.to_string(index=False))
        maxe = oszv["elteres"].abs().max()
        if pd.notna(maxe) and maxe > 0.005:
            print(f"\nFIGYELEM: a legnagyobb eltérés {maxe:.4f}. A 07 és ez a "
                  "script MÁST mér. Tisztázd, melyik a helyes, MIELŐTT "
                  "bármelyik szám modellbe kerül.")
        else:
            print("\nEgyezik a t24-gyel (eltérés < 0,005). "
                  "A teljes mátrix konzisztens a meglévő eredménnyel.")
    else:
        print(uj.to_string(index=False))
        print("\n(t24 nem található, összevetés kimarad.)")

    print("\nKÖVETKEZŐ LÉPÉS: 11_gamma_imputacio.py — a teaor4 → ágazat "
          "leképezéssel az Opten-súlyok, majd Γ_jk és rho(Γ).")


if __name__ == "__main__":
    sys.exit(main())
