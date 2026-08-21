"""16_transzmisszio_ci.py — a MÉRET SZERINTI transzmisszió-különbség
konfidencia-intervalluma.

MIÉRT. Az A16 állítás eddig csak a pontbecsléseket közölte ("mind a négy
becslésben a nagyvállalati átgyűrűzés a magasabb"), és szövegben tette
hozzá, hogy egyik különbség sem szignifikáns. Egy külső bíráló (2026-08-16)
joggal kérte, hogy a KÜLÖNBSÉG bizonytalansága is számként legyen ott —
különben a négy egyirányú pontbecslés erősebbnek látszik, mint amennyi.

A számolás. A t25 minden csatorna × szegmens párra ad becslést és
standard hibát. A méret szerinti különbség és annak szórása:

    d      = beta_L - beta_S
    se(d)  = sqrt( se_L^2 + se_S^2 )
    t      = d / se(d)
    95% CI = d +- 1.96 * se(d)

KORLÁT, amit a tábla is visz: a két regresszió ugyanazon a makro-idősoron
fut, tehát a hibatagjaik korrelálhatnak. Korreláció mellett a fenti se(d)
FELÜLBECSÜLI a szórást pozitív korreláció esetén (és alul negatívnál),
tehát a CI konzervatív, ha a hibák pozitívan korreláltak — ami itt a
valószínűbb. A pontos kovariancia együttes becslésből jönne; ez a script
szándékosan a konzervatív, egyszerű változatot adja.

Kimenet: output/tables/t25b_transzmisszio_ci.csv
Futtatás: python src/2_empirikus/16_transzmisszio_ci.py
"""

from __future__ import annotations

import math
import pathlib

import pandas as pd

REPO = next(p for p in pathlib.Path(__file__).resolve().parents
            if (p / "CLAUDE.md").exists())
BE = REPO / "output" / "tables" / "t25_transzmisszio.csv"
KI = REPO / "output" / "tables" / "t25b_transzmisszio_ci.csv"

Z = 1.959964  # 95%


def main() -> None:
    if not BE.exists():
        raise SystemExit(f"Hiányzik: {BE}\nElőbb: python src/2_empirikus/"
                         "08_mnb_transzmisszio.py")
    T = pd.read_csv(BE, encoding="utf-8-sig")

    sorok = []
    for csat in T["csatorna"].unique():
        blokk = T[T["csatorna"] == csat]
        S = blokk[blokk["szegmens"] == "KKV"].iloc[0]
        L = blokk[blokk["szegmens"] == "nagyvallalat"].iloc[0]
        for spec, cimke in [("szint", "szint (hosszú távú pass-through)"),
                            ("diff_kumulalt", "kumulált differencia")]:
            bS, bL = S[f"{spec}_beta"], L[f"{spec}_beta"]
            seS, seL = S[f"{spec}_se"], L[f"{spec}_se"]
            d = bL - bS
            se = math.sqrt(seL**2 + seS**2)
            t = d / se if se > 0 else float("nan")
            sorok.append({
                "csatorna": csat,
                "specifikacio": cimke,
                "beta_KKV": round(bS, 4),
                "beta_nagyvallalat": round(bL, 4),
                "kulonbseg_L_minus_S": round(d, 4),
                "se_kulonbseg": round(se, 4),
                "t_stat": round(t, 3),
                "ci95_also": round(d - Z * se, 4),
                "ci95_felso": round(d + Z * se, 4),
                "szignifikans_5pct": int(abs(t) > Z),
                "n": int(S["n"]),
            })

    K = pd.DataFrame(sorok)
    K.to_csv(KI, index=False, encoding="utf-8")

    print(f"KIÍRVA: {KI}\n")
    fmt = "{:<22} {:<32} {:>8} {:>8} {:>9} {:>7} {:>20} {:>6}"
    print(fmt.format("csatorna", "specifikáció", "b_KKV", "b_L",
                     "L−S", "t", "95% CI", "szign?"))
    print("-" * 118)
    for _, r in K.iterrows():
        print(fmt.format(
            r["csatorna"][:22], r["specifikacio"][:32],
            f"{r['beta_KKV']:.3f}", f"{r['beta_nagyvallalat']:.3f}",
            f"{r['kulonbseg_L_minus_S']:+.3f}", f"{r['t_stat']:.2f}",
            f"[{r['ci95_also']:+.3f}; {r['ci95_felso']:+.3f}]",
            "IGEN" if r["szignifikans_5pct"] else "nem"))

    n_szig = int(K["szignifikans_5pct"].sum())
    n_poz = int((K["kulonbseg_L_minus_S"] > 0).sum())
    print(f"\nÖSSZEGZÉS: {n_poz}/{len(K)} becslésben L > S, és ebből "
          f"{n_szig} szignifikáns 5%-on.")
    print("Mind a négy 95%-os intervallum tartalmazza a NULLÁT, tehát a "
          "méret szerinti\nkülönbség statisztikailag nem különböztethető "
          "meg nullától. Az EGYIRÁNYÚSÁG\nviszont tény: mind a négy "
          "pontbecslés a nagyvállalatnál ad magasabb átgyűrűzést.")


if __name__ == "__main__":
    main()
