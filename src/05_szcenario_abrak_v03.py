# -*- coding: utf-8 -*-
"""Euró-szcenárió ábra a kkv_dsge_v03 szimulációból (20 év + hosszú táv).

Bemenet:  output/tables/szcenario_v03.csv + szcenario_v03_hosszutav.csv
Kimenet:  output/figures/f06_euro_szcenariok_v03.png
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
BE = REPO / "output" / "tables" / "szcenario_v03.csv"
BE_HT = REPO / "output" / "tables" / "szcenario_v03_hosszutav.csv"
KI = REPO / "output" / "figures" / "f06_euro_szcenariok_v03.png"

SZIN = {"alap": "#2a78d6", "optimista": "#1baf7a", "pesszimista": "#eda100"}
KEK = "#2a78d6"
AQUA = "#1baf7a"
TINTA = "#0b0b0b"
TINTA_MASOD = "#52514e"
TENGELY = "#898781"
RACS = "#e1e0d9"
FELULET = "#fcfcfb"


def stilus(ax):
    ax.set_facecolor(FELULET)
    for oldal in ("top", "right"):
        ax.spines[oldal].set_visible(False)
    for oldal in ("left", "bottom"):
        ax.spines[oldal].set_color(TENGELY)
    ax.tick_params(colors=TINTA_MASOD, labelsize=9)
    ax.yaxis.grid(True, color=RACS, linewidth=0.8)
    ax.set_axisbelow(True)
    ax.axhline(0, color=TENGELY, linewidth=0.8)
    ax.axvline(13, color=TENGELY, linewidth=0.8, linestyle=":")


def main() -> None:
    d = pd.read_csv(BE)
    ht = pd.read_csv(BE_HT).set_index("szcenario")

    fig, (bal, jobb) = plt.subplots(1, 2, figsize=(10.4, 4.2),
                                    facecolor=FELULET)

    # bal: kibocsátás, 20 év + hosszú távú szint szaggatottan
    stilus(bal)
    for nev, resz in d.groupby("szcenario"):
        bal.plot(resz["negyedev"], resz["y"] * 100, color=SZIN[nev],
                 linewidth=2, label=nev)
        bal.axhline(ht.loc[nev, "y"] * 100, color=SZIN[nev], linewidth=1,
                    linestyle="--", alpha=0.55)
    bal.set_title("Kibocsátás — pálya (vonal) és új steady state (szaggatott)",
                  fontsize=10.5, color=TINTA, loc="left")
    bal.set_xlabel("negyedév a bejelentéstől", color=TINTA_MASOD, fontsize=9)
    bal.set_ylabel("% eltérés", color=TINTA_MASOD, fontsize=9)
    bal.legend(frameon=False, fontsize=9, labelcolor=TINTA_MASOD,
               loc="center right")
    bal.text(13.4, bal.get_ylim()[1] * 0.95, "euró-belépés", fontsize=8,
             color=TENGELY)

    # jobb: alap szcenárió — szektorális kibocsátás
    alap = d[d["szcenario"] == "alap"]
    stilus(jobb)
    jobb.plot(alap["negyedev"], alap["y_S"] * 100, color=KEK, linewidth=2,
              label="KKV kibocsátás")
    jobb.plot(alap["negyedev"], alap["y_L"] * 100, color=AQUA, linewidth=2,
              label="nagyvállalati kibocsátás")
    jobb.axhline(ht.loc["alap", "y_S"] * 100, color=KEK, linewidth=1,
                 linestyle="--", alpha=0.55)
    jobb.axhline(ht.loc["alap", "y_L"] * 100, color=AQUA, linewidth=1,
                 linestyle="--", alpha=0.55)
    jobb.set_title("Alappálya szektoronként — a KKV-többlet tartós",
                   fontsize=10.5, color=TINTA, loc="left")
    jobb.set_xlabel("negyedév a bejelentéstől", color=TINTA_MASOD,
                    fontsize=9)
    jobb.legend(frameon=False, fontsize=9, labelcolor=TINTA_MASOD,
                loc="lower right")

    fig.suptitle("kkv_dsge_v03 — euró-szcenáriók WP 2017/7 kalibrációval "
                 "és UIP-országprémium csatornával",
                 fontsize=11.5, color=TINTA, x=0.01, ha="left")
    fig.text(0.01, 0.01,
             "Hosszú távú GDP-szint: alap +0,49%, optimista +0,67%, "
             "pesszimista +0,32% — csak a hitelköltség-csatorna; a felépülés "
             "lassú (tőkefelhalmozás). Belépés: 13. negyedév.",
             fontsize=8, color=TENGELY)
    fig.tight_layout(rect=(0, 0.08, 1, 0.92))
    KI.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(KI, dpi=200, facecolor=FELULET)
    print(f"Kiírva: {KI}")


if __name__ == "__main__":
    main()
