# -*- coding: utf-8 -*-
"""Euró-szcenárió ábra a kkv_dsge_v02 determinisztikus szimulációból.

Bemenet:  output/tables/szcenario_v02.csv  (előállítja: src/model/run_v02.m)
Kimenet:  output/figures/f05_euro_szcenariok_v02.png
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
BE = REPO / "output" / "tables" / "szcenario_v02.csv"
KI = REPO / "output" / "figures" / "f05_euro_szcenariok_v02.png"

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

    fig, (bal, jobb) = plt.subplots(1, 2, figsize=(10.4, 4.2),
                                    facecolor=FELULET)

    # bal: aggregált kibocsátás a három szcenárióban
    stilus(bal)
    for nev, resz in d.groupby("szcenario"):
        bal.plot(resz["negyedev"], resz["y"] * 100, color=SZIN[nev],
                 linewidth=2, label=nev)
    bal.set_title("Kibocsátás — három szcenárió", fontsize=10.5,
                  color=TINTA, loc="left")
    bal.set_xlabel("negyedév a bejelentéstől", color=TINTA_MASOD, fontsize=9)
    bal.set_ylabel("% eltérés az alappályától", color=TINTA_MASOD,
                   fontsize=9)
    bal.legend(frameon=False, fontsize=9, labelcolor=TINTA_MASOD,
               loc="lower right")
    bal.text(13.4, bal.get_ylim()[1] * 0.94, "euró-belépés",
             fontsize=8, color=TENGELY)

    # jobb: alap szcenárió — KKV vs nagyvállalati beruházás
    alap = d[d["szcenario"] == "alap"]
    stilus(jobb)
    jobb.plot(alap["negyedev"], alap["i_S"] * 100, color=KEK, linewidth=2,
              label="KKV beruházás")
    jobb.plot(alap["negyedev"], alap["i_L"] * 100, color=AQUA, linewidth=2,
              label="nagyvállalati beruházás")
    jobb.set_title("Beruházás az alappályán — a KKV a fő nyertes",
                   fontsize=10.5, color=TINTA, loc="left")
    jobb.set_xlabel("negyedév a bejelentéstől", color=TINTA_MASOD,
                    fontsize=9)
    jobb.legend(frameon=False, fontsize=9, labelcolor=TINTA_MASOD,
                loc="lower right")

    fig.suptitle("kkv_dsge_v02 — euró-belépési szcenáriók "
                 "(anticipált, permanens prémium-csökkenés)",
                 fontsize=11.5, color=TINTA, x=0.01, ha="left")
    fig.text(0.01, 0.01,
             "Szuverén: −150/−200/−250 bp; banki: −30/−45/−60 bp primer, "
             "40/60/70% transzmisszió. Belépés a 13. negyedévben. "
             "v0.1-es kalibráció — nagyságrendi.",
             fontsize=8, color=TENGELY)
    fig.tight_layout(rect=(0, 0.08, 1, 0.92))
    KI.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(KI, dpi=200, facecolor=FELULET)
    print(f"Kiírva: {KI}")


if __name__ == "__main__":
    main()
