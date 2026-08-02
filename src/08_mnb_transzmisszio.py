# -*- coding: utf-8 -*-
"""A t_sov és t_bank átgyűrűzési súlyok EMPIRIKUS megalapozása.

KÉRDÉS: egy szuverén (állampapír-) illetve bankközi kamatváltozásból
mennyi gyűrűzik át a KKV, illetve a nagyvállalati hitelkamatba? Ezek a
modell t_sov_S/t_sov_L és t_bank_S/t_bank_L paraméterei — eddig irodalmi
becslések voltak, és mivel a vertikális link empirikusan gyengének
bizonyult, MOST EZEK HATÁROZZÁK MEG a fő eredményt (a KKV-előny méretét).

TÉT: ha a méret szerinti transzmisszió-különbség nem szignifikáns, a
projekt fő állítása (a KKV többet nyer) elveszíti az empirikus alapját.

ADATOK (ECB SDW / Eurostat; a magyar adatot az MNB szolgáltatja be):
  - ECB MIR: magyar vállalati ÚJ hitelek kamata összeg-kategória szerint
      kis összeg (<= 0.25 M EUR)  -> KKV proxy
      nagy összeg (> 1 M EUR)     -> nagyvállalati proxy
    (Az összeg-kategória a nemzetközi gyakorlatban a méret standard
     proxyja, mert méret szerinti bontás nincs a kamatstatisztikában.)
  - Eurostat irt_st_m: 3 havi bankközi kamat (BUBOR) -> t_bank referencia
  - Eurostat irt_lt_mcby: 10 éves állampapírhozam   -> t_sov referencia

MÓDSZER: két becslés, mert egyik sem tökéletes —
  (A) szint-regresszió (hosszú távú pass-through, ha kointegráltak)
  (B) differencia-regresszió kumulált hatással (rövid távú, robusztusabb)
Az azonosítás korlátait a kimenet explicit jelzi.

Kimenet: output/tables/t25_transzmisszio.csv
Futtatás: python src/08_mnb_transzmisszio.py
"""

import io
import json
import urllib.request
from pathlib import Path

import numpy as np
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
KI = REPO / "output" / "tables" / "t25_transzmisszio.csv"
ECB = "https://data-api.ecb.europa.eu/service/data"
EUROSTAT = "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data"
KEZDET = "2010-01"


def ecb_mir(amount_cat: str) -> pd.Series:
    """Magyar vállalati új hitelek kamata adott összeg-kategóriában."""
    key = f"M.HU.B.A2A.A.R.{amount_cat}.2240.HUF.N"
    url = f"{ECB}/MIR/{key}?format=csvdata&startPeriod={KEZDET}"
    with urllib.request.urlopen(url, timeout=120) as r:
        df = pd.read_csv(io.BytesIO(r.read()))
    df = df.dropna(subset=["OBS_VALUE"])
    s = pd.Series(df["OBS_VALUE"].values,
                  index=pd.PeriodIndex(df["TIME_PERIOD"], freq="M"))
    return s.sort_index()


def eurostat_rate(tbl: str) -> pd.Series:
    url = (f"{EUROSTAT}/{tbl}?geo=HU&format=JSON&lang=EN")
    with urllib.request.urlopen(url, timeout=120) as r:
        js = json.load(r)
    tidx = js["dimension"]["time"]["category"]["index"]
    inv = {v: k for k, v in tidx.items()}
    n_time = js["size"][js["id"].index("time")]
    vals = {}
    for pos, v in js["value"].items():
        t = inv[int(pos) % n_time]
        vals[t] = v
    s = pd.Series(vals)
    s.index = pd.PeriodIndex(s.index, freq="M")
    return s.sort_index()


def pass_through(loan: pd.Series, ref: pd.Series, nev: str) -> dict:
    """Ket becsles: (A) szint-regresszio, (B) differencia + 1 keses."""
    d = pd.concat([loan.rename("i"), ref.rename("r")], axis=1).dropna()
    if len(d) < 24:
        return {"nev": nev, "n": len(d), "hiba": "keves megfigyeles"}
    # (A) szint
    X = np.column_stack([np.ones(len(d)), d["r"].values])
    bA = np.linalg.lstsq(X, d["i"].values, rcond=None)[0]
    resid = d["i"].values - X @ bA
    seA = np.sqrt((resid @ resid) / (len(d) - 2)
                  * np.linalg.inv(X.T @ X)[1, 1])
    # (B) differencia + 1 keses (kumulalt)
    dd = d.diff().dropna()
    dd["r_l1"] = d["r"].diff().shift(1).reindex(dd.index)
    dd = dd.dropna()
    Xd = np.column_stack([np.ones(len(dd)), dd["r"].values,
                          dd["r_l1"].values])
    bB = np.linalg.lstsq(Xd, dd["i"].values, rcond=None)[0]
    residB = dd["i"].values - Xd @ bB
    covB = ((residB @ residB) / (len(dd) - 3)) * np.linalg.inv(Xd.T @ Xd)
    kum = bB[1] + bB[2]
    se_kum = np.sqrt(covB[1, 1] + covB[2, 2] + 2 * covB[1, 2])
    return {"nev": nev, "n": len(d),
            "szint_beta": round(bA[1], 3), "szint_se": round(seA, 3),
            "diff_kumulalt_beta": round(kum, 3),
            "diff_kumulalt_se": round(se_kum, 3)}


def main() -> None:
    print("Adatok letoltese (ECB MIR + Eurostat)...")
    # Az ECB MIR magyar adatban ket osszeg-kategoria van (ellenorizve):
    #   "0" = <= 1 M EUR   -> KKV proxy
    #   "1" = >  1 M EUR   -> nagyvallalati proxy
    kkv = ecb_mir("0")
    nagy = ecb_mir("1")

    bubor = eurostat_rate("irt_st_m")           # 3 havi bankkozi (BUBOR)
    allampapir = eurostat_rate("irt_lt_mcby_m")  # 10 eves allampapirhozam

    print(f"  KKV-proxy kamat : {len(kkv):>4} megfigyeles "
          f"({kkv.index.min()}..{kkv.index.max()})" if len(kkv) else "  KKV: NINCS")
    print(f"  Nagyvall. kamat : {len(nagy):>4} megfigyeles" if len(nagy) else "  Nagy: NINCS")
    print(f"  BUBOR (3 ho)    : {len(bubor):>4} megfigyeles")
    print(f"  Allampapir (10y): {len(allampapir):>4} megfigyeles")

    sorok = []
    for csat, ref in (("t_bank (bankkozi)", bubor),
                      ("t_sov (allampapir)", allampapir)):
        for szegm, loan in (("KKV", kkv), ("nagyvallalat", nagy)):
            if loan is None or loan.empty:
                continue
            r = pass_through(loan, ref, f"{csat} -> {szegm}")
            r["csatorna"] = csat
            r["szegmens"] = szegm
            sorok.append(r)

    T = pd.DataFrame(sorok)
    KI.parent.mkdir(parents=True, exist_ok=True)
    T.to_csv(KI, index=False, encoding="utf-8-sig")

    print(f"\n{'='*82}")
    print("ATGYURUZESI SULYOK (pass-through) — magyar adat")
    print(f"{'='*82}")
    print(f"{'':<34} {'szint-becsles':>18} {'diff-kumulalt':>18}")
    for _, r in T.iterrows():
        if "hiba" in r and pd.notna(r.get("hiba")):
            print(f"{r['nev']:<34} {r['hiba']}")
            continue
        print(f"{r['nev']:<34} {r['szint_beta']:>9.3f} "
              f"({r['szint_se']:.3f}) {r['diff_kumulalt_beta']:>9.3f} "
              f"({r['diff_kumulalt_se']:.3f})   n={r['n']}")

    # a DONTO kerdes: kulonbozik-e a KKV es a nagyvallalati transzmisszio?
    print(f"\n{'='*82}")
    print("A DONTO KERDES: szignifikansan kulonbozik-e a ket szegmens?")
    print(f"{'='*82}")
    for csat in T["csatorna"].unique():
        sub = T[T["csatorna"] == csat]
        if len(sub) < 2:
            continue
        for oszlop, se_oszlop, cimke in (
                ("szint_beta", "szint_se", "szint"),
                ("diff_kumulalt_beta", "diff_kumulalt_se", "differencia")):
            bs = sub[sub["szegmens"] == "KKV"][oszlop].values
            bl = sub[sub["szegmens"] == "nagyvallalat"][oszlop].values
            ss = sub[sub["szegmens"] == "KKV"][se_oszlop].values
            sl = sub[sub["szegmens"] == "nagyvallalat"][se_oszlop].values
            if not len(bs) or not len(bl):
                continue
            diff = bs[0] - bl[0]
            se_d = np.sqrt(ss[0] ** 2 + sl[0] ** 2)
            t = diff / se_d if se_d > 0 else np.nan
            szig = "SZIGNIFIKANS" if abs(t) > 1.96 else "NEM szignifikans"
            print(f"  {csat:<22} ({cimke:<11}): KKV-nagyvall. = "
                  f"{diff:+.3f}  t={t:+.2f}  -> {szig}")

    print(f"\nKiirva: {KI}")
    print("\nKORLAT: az osszeg-kategoria a meret PROXYja, nem maga a meret;")
    print("a kamatszint mas tenyezoktol is fugg (fedezet, lejarat, program-")
    print("hitelek). A becsles IRANYADO, nem strukturalis azonositas.")


if __name__ == "__main__":
    main()
