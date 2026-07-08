# -*- coding: utf-8 -*-
"""Leíró statisztika a tisztított Opten cég-év panelről.

Bemenet:  data/processed/opten_panel.csv  (előállítja: 01_opten_panel_tisztitas.py)
Kimenet:  output/tables/t01..t06_*.csv és output/figures/f01..f03_*.png

Futtatás a repo gyökeréből:  python src/02_leiro_stat.py

A pénzmezők a panelben ezer Ft-ban vannak; a táblákban millió Ft-ot mutatunk.
A kockázati „AVG" kategória jelentése a szállítónál tisztázás alatt — az
ábrákon szürkével, külön jelöljük.
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
PANEL = REPO / "data" / "processed" / "opten_panel.csv"
TABLAK = REPO / "output" / "tables"
ABRAK = REPO / "output" / "figures"

BESOROLAS_SORREND = ["A", "B", "C", "D", "AVG"]
MERET_SORREND = ["10-49", "50-249", "250+"]

# dataviz-paletta (világos felület): ordinális kék lépcső + semleges szürke
KEK = {"A": "#86b6ef", "B": "#5598e7", "C": "#2a78d6", "D": "#1c5cab"}
SZURKE_AVG = "#c3c2b7"
KEK_FO = "#2a78d6"
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


def pct(s: pd.Series) -> float:
    return float(s.mean() * 100)


def main() -> None:
    p = pd.read_csv(PANEL, dtype={"opten_id": str})
    TABLAK.mkdir(parents=True, exist_ok=True)
    ABRAK.mkdir(parents=True, exist_ok=True)

    ir = p["implicit_kamatrata"] * 100  # %-ban
    p = p.assign(ir=ir)

    # --- t01: évenkénti áttekintés ------------------------------------------
    t01 = p.groupby("ev").agg(
        ceg_ev=("opten_id", "size"),
        median_arbevetel_mFt=("netto_arbevetel", lambda s: s.median() / 1e3),
        hitellel_rendelkezo_pct=("van_hitel", pct),
        kamatfizeto_pct=("kamatraforditas", lambda s: (s.fillna(0) > 0).mean() * 100),
        implicit_kamat_median_pct=("ir", "median"),
        exportor_pct=("exportor", pct),
    ).round(2)
    t01.to_csv(TABLAK / "t01_ev_attekintes.csv", encoding="utf-8-sig")

    # --- t02: méretkategória ------------------------------------------------
    t02 = p.groupby("meret_kategoria", observed=True).agg(
        ceg_ev=("opten_id", "size"),
        ceg=("opten_id", "nunique"),
        median_arbevetel_mFt=("netto_arbevetel", lambda s: s.median() / 1e3),
        median_eszkoz_mFt=("eszkozok_osszesen", lambda s: s.median() / 1e3),
        hitellel_rendelkezo_pct=("van_hitel", pct),
        implicit_kamat_median_pct=("ir", "median"),
        exportor_pct=("exportor", pct),
        median_tokeattetel=("tokeattetel", "median"),
    ).reindex(MERET_SORREND).round(2)
    t02.to_csv(TABLAK / "t02_meret.csv", encoding="utf-8-sig")

    # --- t03: kockázati besorolás (a heterogén EFP magja) -------------------
    t03 = p.groupby("kockazati_besorolas").agg(
        ceg_ev=("opten_id", "size"),
        hitellel_rendelkezo_pct=("van_hitel", pct),
        implicit_kamat_median_pct=("ir", "median"),
        implicit_kamat_q1_pct=("ir", lambda s: s.quantile(.25)),
        implicit_kamat_q3_pct=("ir", lambda s: s.quantile(.75)),
        median_tokeattetel=("tokeattetel", "median"),
        exportor_pct=("exportor", pct),
    ).reindex(BESOROLAS_SORREND).round(2)
    t03.to_csv(TABLAK / "t03_kockazati_besorolas.csv", encoding="utf-8-sig")

    # --- t04 / t05: régió és ágazat -----------------------------------------
    t04 = p.groupby("nuts2").agg(
        ceg_ev=("opten_id", "size"),
        hitellel_rendelkezo_pct=("van_hitel", pct),
        implicit_kamat_median_pct=("ir", "median"),
        exportor_pct=("exportor", pct),
    ).round(2)
    t04.to_csv(TABLAK / "t04_regio.csv", encoding="utf-8-sig")

    t05 = p.groupby("agazat_betu").agg(
        ceg_ev=("opten_id", "size"),
        hitellel_rendelkezo_pct=("van_hitel", pct),
        implicit_kamat_median_pct=("ir", "median"),
        exportor_pct=("exportor", pct),
    ).sort_values("ceg_ev", ascending=False).round(2)
    t05.to_csv(TABLAK / "t05_agazat.csv", encoding="utf-8-sig")

    # --- t06: kockázati átmenet 2021 -> 2024 (cégszint) ---------------------
    b21 = p[p["ev"].eq(2021)].set_index("opten_id")["kockazati_besorolas"]
    b24 = p[p["ev"].eq(2024)].set_index("opten_id")["kockazati_besorolas"]
    kozos = b21.index.intersection(b24.index)
    t06 = pd.crosstab(b21.loc[kozos], b24.loc[kozos]).reindex(
        index=BESOROLAS_SORREND, columns=BESOROLAS_SORREND)
    t06.index.name = "2021 \\ 2024"
    t06.to_csv(TABLAK / "t06_kockazati_atmenet.csv", encoding="utf-8-sig")

    # ======================= ÁBRÁK =======================
    szinek = [KEK.get(b, SZURKE_AVG) for b in BESOROLAS_SORREND]

    # f01: implicit kamatráta besorolás szerint
    fig, ax = plt.subplots(figsize=(6.4, 3.8), facecolor=FELULET)
    stilus(ax)
    ertekek = t03["implicit_kamat_median_pct"]
    ax.bar(BESOROLAS_SORREND, ertekek, color=szinek, width=0.62)
    for i, v in enumerate(ertekek):
        ax.text(i, v + 0.12, f"{v:.1f}%", ha="center", fontsize=9,
                color=TINTA)
    ax.set_title("Medián implicit kamatráta kockázati besorolás szerint",
                 fontsize=11, color=TINTA, loc="left")
    ax.set_ylabel("%", color=TINTA_MASOD, fontsize=9)
    ax.text(0.0, -0.16,
            "Kamatráfordítás / hitelállomány, ahol mindkettő pozitív. "
            "Az AVG jelentése a szállítónál tisztázás alatt.",
            transform=ax.transAxes, fontsize=8, color=TENGELY)
    fig.tight_layout()
    fig.savefig(ABRAK / "f01_implicit_kamat_besorolas.png", dpi=200,
                facecolor=FELULET)
    plt.close(fig)

    # f02: implicit kamatráta évenként (medián + IQR-sáv)
    ev_stat = p.groupby("ev")["ir"].agg(
        median="median", q1=lambda s: s.quantile(.25),
        q3=lambda s: s.quantile(.75))
    fig, ax = plt.subplots(figsize=(6.4, 3.8), facecolor=FELULET)
    stilus(ax)
    x = ev_stat.index.astype(int)
    ax.fill_between(x, ev_stat["q1"], ev_stat["q3"], color=KEK_FO,
                    alpha=0.15, linewidth=0)
    ax.plot(x, ev_stat["median"], color=KEK_FO, linewidth=2, marker="o",
            markersize=5)
    for xv, yv in zip(x, ev_stat["median"]):
        ax.text(xv, yv + 0.35, f"{yv:.1f}%", ha="center", fontsize=9,
                color=TINTA)
    ax.set_xticks(list(x))
    ax.set_title("Implicit kamatráta évenként — medián és kvartilis-sáv",
                 fontsize=11, color=TINTA, loc="left")
    ax.set_ylabel("%", color=TINTA_MASOD, fontsize=9)
    ax.text(0.0, -0.16,
            "2025 részleges (2 757 cég lezárt beszámolóval) — csak jelzésértékű.",
            transform=ax.transAxes, fontsize=8, color=TENGELY)
    fig.tight_layout()
    fig.savefig(ABRAK / "f02_implicit_kamat_evenkent.png", dpi=200,
                facecolor=FELULET)
    plt.close(fig)

    # f03: hitelhozzáférés (extenzív margó) besorolás szerint
    fig, ax = plt.subplots(figsize=(6.4, 3.8), facecolor=FELULET)
    stilus(ax)
    ertekek = t03["hitellel_rendelkezo_pct"]
    ax.bar(BESOROLAS_SORREND, ertekek, color=szinek, width=0.62)
    for i, v in enumerate(ertekek):
        ax.text(i, v + 0.5, f"{v:.1f}%", ha="center", fontsize=9, color=TINTA)
    ax.set_title("Banki hitellel rendelkező cég-évek aránya besorolás szerint",
                 fontsize=11, color=TINTA, loc="left")
    ax.set_ylabel("%", color=TINTA_MASOD, fontsize=9)
    ax.text(0.0, -0.16,
            "„Van hitel”: hosszú/rövid lejáratú hitel- vagy kölcsönállomány > 0 "
            "(extenzív margó).",
            transform=ax.transAxes, fontsize=8, color=TENGELY)
    fig.tight_layout()
    fig.savefig(ABRAK / "f03_hitelhozzaferes_besorolas.png", dpi=200,
                facecolor=FELULET)
    plt.close(fig)

    # --- konzol-összefoglaló -------------------------------------------------
    print("=== t01: évenként ===");             print(t01.to_string())
    print("\n=== t02: méret ===");              print(t02.to_string())
    print("\n=== t03: kockázati besorolás ==="); print(t03.to_string())
    print("\n=== t04: régió ===");              print(t04.to_string())
    print("\n=== t05: ágazat ===");             print(t05.to_string())
    print("\n=== t06: átmenet 2021->2024 ==="); print(t06.to_string())
    valtozott = (b21.loc[kozos] != b24.loc[kozos]).mean() * 100
    print(f"\nBesorolás-váltó cégek 2021->2024: {valtozott:.1f}%")
    print(f"\nTáblák: {TABLAK}\nÁbrák: {ABRAK}")


if __name__ == "__main__":
    main()
