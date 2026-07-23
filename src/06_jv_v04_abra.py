# -*- coding: utf-8 -*-
"""A vertikális KKV->exportőr átgyűrűzés ábrája (jv_dsge_v04).

Bemenet:  output/tables/t20_jv_v04_vertikalis.csv (előállítja: run_jv_v04.m)
Kimenet:  output/figures/f19_jv_v04_vertikalis.png
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
BE = REPO / "output" / "tables" / "t20_jv_v04_vertikalis.csv"
KI = REPO / "output" / "figures" / "f19_jv_v04_vertikalis.png"

KEK, AQUA, SARGA = "#2a78d6", "#1baf7a", "#eda100"
TINTA, MASOD, TENGELY = "#0b0b0b", "#52514e", "#898781"
RACS, FELULET = "#e1e0d9", "#fcfcfb"


def stil(ax):
    ax.set_facecolor(FELULET)
    for o in ("top", "right"):
        ax.spines[o].set_visible(False)
    for o in ("left", "bottom"):
        ax.spines[o].set_color(TENGELY)
    ax.tick_params(colors=MASOD, labelsize=9)
    ax.yaxis.grid(True, color=RACS, linewidth=0.8)
    ax.set_axisbelow(True)
    ax.axhline(0, color=TENGELY, linewidth=0.8)


def main() -> None:
    d = pd.read_csv(BE)
    t = d["negyedev"]
    fig, (bal, jobb) = plt.subplots(1, 2, figsize=(10.4, 4.2),
                                    facecolor=FELULET)

    # bal: a vertikális együttmozgás — monetáris lazításra az export, a
    # KKV-input és a KKV-kibocsátás EGYÜTT mozdul (a beszállítói lánc)
    stil(bal)
    bal.plot(t, -100 * d["y_x_eps_r"], color=AQUA, linewidth=2.2,
             label="export-kibocsátás (y_x)")
    bal.plot(t, -100 * d["h_dx_eps_r"], color=KEK, linewidth=2,
             label="KKV-input az exportőrhöz (h_dx)")
    bal.plot(t, -100 * d["y_d_eps_r"], color=SARGA, linewidth=2,
             label="KKV-kibocsátás (y_d)")
    bal.set_title("Vertikális együttmozgás — a lánc közösen reagál "
                  "(monetáris lazítás)", fontsize=10.5, color=TINTA,
                  loc="left")
    bal.set_xlabel("negyedév", color=MASOD, fontsize=9)
    bal.set_ylabel("% eltérés", color=MASOD, fontsize=9)
    bal.legend(frameon=False, fontsize=8.5, labelcolor=MASOD,
               loc="upper right")

    # jobb: méret-aszimmetria a beruházásban (monetáris sokk)
    stil(jobb)
    jobb.plot(t, -100 * d["i_S_eps_r"], color=KEK, linewidth=2.2,
              label="KKV-beruházás")
    jobb.plot(t, -100 * d["i_L_eps_r"], color=AQUA, linewidth=2,
              label="nagyvállalati beruházás")
    jobb.set_title("Méret-aszimmetria — monetáris sokk (a KKV érzékenyebb)",
                   fontsize=10.5, color=TINTA, loc="left")
    jobb.set_xlabel("negyedév", color=MASOD, fontsize=9)
    jobb.legend(frameon=False, fontsize=8.5, labelcolor=MASOD,
                loc="upper right")

    fig.suptitle("jv_dsge_v04 — KKV=hazai / nagyvállalat=export, "
                 "vertikális beszállítói linkkel", fontsize=11.5,
                 color=TINTA, x=0.01, ha="left")
    fig.text(0.01, 0.01,
             "Bal: monetáris lazításra az exportőr és a beszállító KKV "
             "együtt mozdul (h_dx köti össze őket) — pozitív összegű lánc. "
             "Jobb: azonos sokkra a KKV-beruházás erősebb (méretfüggő "
             "akcelerátor). v04 — s_kkv, mu_vert, psi_i érzékenységi.",
             fontsize=8, color=TENGELY)
    fig.tight_layout(rect=(0, 0.05, 1, 0.93))
    KI.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(KI, dpi=200, facecolor=FELULET)
    print(f"Kiírva: {KI}")


if __name__ == "__main__":
    main()
