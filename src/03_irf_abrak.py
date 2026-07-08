# -*- coding: utf-8 -*-
"""IRF-ábra a kkv_dsge_v01 modellből: KKV vs. nagyvállalat aszimmetria.

Bemenet:  output/tables/irf_v01.csv  (előállítja: src/model/run_v01.m)
Kimenet:  output/figures/f04_irf_hitelsokk_v01.png

Az euró-irányú szcenárió a prémiumok CSÖKKENÉSE, ezért a tárolt (+1 szórás)
IRF-eket -1-gyel szorozva ábrázoljuk.
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
IRF = REPO / "output" / "tables" / "irf_v01.csv"
KI = REPO / "output" / "figures" / "f04_irf_hitelsokk_v01.png"

KEK = "#2a78d6"      # KKV (1. kategorikus szín)
AQUA = "#1baf7a"     # nagyvállalat (2. kategorikus szín)
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


def main() -> None:
    irf = pd.read_csv(IRF)
    t = irf["negyedev"]

    fig, (bal, jobb) = plt.subplots(1, 2, figsize=(10.4, 4.0),
                                    facecolor=FELULET)

    # bal: beruházási válasz a banki forrásköltség-prémium csökkenésére
    stilus(bal)
    bal.plot(t, -irf["i_S_e_bank"] * 100, color=KEK, linewidth=2,
             label="KKV")
    bal.plot(t, -irf["i_L_e_bank"] * 100, color=AQUA, linewidth=2,
             label="nagyvállalat")
    bal.set_title("Beruházás — banki forrásköltség-sokk (euró-irány)",
                  fontsize=10.5, color=TINTA, loc="left")
    bal.set_xlabel("negyedév", color=TINTA_MASOD, fontsize=9)
    bal.set_ylabel("% eltérés", color=TINTA_MASOD, fontsize=9)
    bal.legend(frameon=False, fontsize=9, labelcolor=TINTA_MASOD)

    # jobb: EFP-válasz ugyanarra a sokkra (évesített bázispont)
    stilus(jobb)
    jobb.plot(t, -irf["efp_S_e_bank"] * 40000, color=KEK, linewidth=2,
              label="KKV")
    jobb.plot(t, -irf["efp_L_e_bank"] * 40000, color=AQUA, linewidth=2,
              label="nagyvállalat")
    jobb.set_title("Külső finanszírozási prémium (EFP), évesített bp",
                   fontsize=10.5, color=TINTA, loc="left")
    jobb.set_xlabel("negyedév", color=TINTA_MASOD, fontsize=9)
    jobb.legend(frameon=False, fontsize=9, labelcolor=TINTA_MASOD)

    fig.suptitle("kkv_dsge_v01 — a méretfüggő akcelerátor működik: "
                 "azonos sokk, aszimmetrikus válasz",
                 fontsize=11.5, color=TINTA, x=0.01, ha="left")
    fig.text(0.01, 0.01,
             "−1 szórásnyi banki forrásköltség-sokk (prémium-csökkenés). "
             "v0.1 kalibráció — nagyságrendi, nem végleges.",
             fontsize=8, color=TENGELY)
    fig.tight_layout(rect=(0, 0.08, 1, 0.92))
    KI.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(KI, dpi=200, facecolor=FELULET)
    print(f"Kiírva: {KI}")


if __name__ == "__main__":
    main()
