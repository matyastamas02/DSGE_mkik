"""18_lam_om_felulet.py — a KKV-előny küszöbe a (lambda, omega) síkon.

MIÉRT. Eddig egyetlen szám (`ACCSCALE`) skálázta a hozzáférési csatorna
MINDKÉT lépcsőjét — a felár→hozzáférés rugalmasságot (`lambda_acc`) és a
hozzáférés→beruházás rugalmasságot (`omega_acc`) —, ezért a közölt „22,3-as
küszöb" valójában két rugalmasság SZORZATÁN volt, előre rögzített arány
mellett. Így nem volt interpretálható. (Korlátok-riport 2026-08-21, 1. teendő.)

A `sens_lam_om_v09.m` szétbontotta a kettőt (`-DLAMSCALE`, `-DOMSCALE`), és
az eredmény ennél élesebb, mint amire számítottunk: a modellben a két
paraméter KIZÁRÓLAG a szorzatán keresztül hat. A hosszú távú access-hatás

    − omega_acc · lambda_acc / (1 − rho_acc) · efp

alakú, tehát a küszöb nem egy szám, hanem egy IZO-SZORZAT GÖRBE. A mért
kontúron a szorzat 28-szoros lambda-tartományon 0,1%-on belül állandó.

KÖVETKEZMÉNY, amit ki kell mondani: a modell a lambda-t és az omegát
KÜLÖN-KÜLÖN NEM AZONOSÍTJA, még elvben sem. Aki a kettőt külön akarja
horgonyozni, olyan adatot keres, ami a modellen keresztül nem létezik.

Ez a script nem futtat modellt, csak megjeleníti a `sens_lam_om_v09.m`
tábláit — tetszőleges számú alkalommal újrafuttatható MATLAB nélkül.

Kimenet: output/figures/f28_lam_om_felulet.png
Futtatás: python src/3_abrak/18_lam_om_felulet.py
"""

from __future__ import annotations

import pathlib

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

REPO = next(p for p in pathlib.Path(__file__).resolve().parents
            if (p / "CLAUDE.md").exists())
TAB = REPO / "output" / "tables"
KI = REPO / "output" / "figures" / "f28_lam_om_felulet.png"

# a repo palettaja (lasd 17_kuszobfelulet.py)
KEK = "#2a78d6"
AQUA = "#1baf7a"
PIROS = "#c73e2d"
TINTA = "#0a0a0a"
MASOD = "#525049"
FELULET = "#fcfcfb"

ELVART_RACS = np.array([0, 5, 10, 15, 20, 30, 40, 60, 80, 100, 140])
ELVART_KONTUR_LAMBDA = np.array([
    5, 10, 15, 20, 22.3, 25, 30, 40, 50, 70, 100, 140,
])
ELVART_ATLO_OPTEN = np.array([0, 1])


def main() -> None:
    racs_f = TAB / "t52_lam_om_racs.csv"
    kont_f = TAB / "t52b_lam_om_kontur.csv"
    diag_f = TAB / "t52d_lam_om_diagonalis.csv"
    for f in (racs_f, kont_f, diag_f):
        if not f.exists():
            raise SystemExit(
                f"Hiányzik: {f}\nElőbb: matlab -batch \"cd('src/modell/"
                "1_fo_vonal_jv/futtato'); sens_lam_om_v09\"")

    G = pd.read_csv(racs_f)
    required_g = {"OPTEN", "accscale", "lamscale", "omscale",
                  "KKV_minus_L_pp", "solver_ok", "bk_check_ok", "bk_ok",
                  "ervenyes", "n_forward", "n_unstable",
                  "bk_qz_criterium"}
    missing = sorted(required_g - set(G.columns))
    if missing:
        raise SystemExit(
            f"A {racs_f.name} elavult, hiányzó BK-oszlopok: {', '.join(missing)}. "
            "Futtasd újra a sens_lam_om_v09.m scriptet.")

    racs_kulcs = ["lamscale", "omscale"]
    duplikalt = G.duplicated(racs_kulcs, keep=False)
    vart_db = len(ELVART_RACS) ** 2
    if len(G) != vart_db or duplikalt.any():
        raise SystemExit(
            f"A {racs_f.name} nem teljes, egyedi 11×11-es rács: "
            f"{len(G)}/{vart_db} sor, {int(duplikalt.sum())} duplikált "
            "kulcsú sor. Futtasd újra a sens_lam_om_v09.m scriptet.")

    lam = np.sort(G["lamscale"].dropna().unique())
    om = np.sort(G["omscale"].dropna().unique())
    jo_lam = (lam.shape == ELVART_RACS.shape and
              np.allclose(lam, ELVART_RACS, rtol=0, atol=1e-10))
    jo_om = (om.shape == ELVART_RACS.shape and
             np.allclose(om, ELVART_RACS, rtol=0, atol=1e-10))
    if not jo_lam or not jo_om:
        raise SystemExit(
            f"A {racs_f.name} tengelyei eltérnek az elvárt 11×11-es "
            "lambda×omega rácstól. Futtasd újra a sens_lam_om_v09.m scriptet.")

    if not (G["OPTEN"].eq(1).all() and G["accscale"].eq(100).all()):
        raise SystemExit(
            f"A {racs_f.name} nem kizárólag az elvárt OPTEN=1, "
            "ACCSCALE=100 konfigurációt tartalmazza.")

    technikai_ok = G["solver_ok"].eq(1) & G["bk_check_ok"].eq(1)
    if not technikai_ok.all():
        raise SystemExit(
            f"A {racs_f.name} {int((~technikai_ok).sum())} során a PF solver "
            "vagy a terminális BK-diagnosztika technikailag nem futott le; "
            "nem készül részleges ábra.")

    G = G[G["ervenyes"] == 1].copy()
    if G.empty:
        raise SystemExit("A t52 rácson nincs BK-érvényes cella; nem készül ábra.")

    K = pd.read_csv(kont_f)
    required_k = {"lambda_skala", "kuszob_omega", "szorzat",
                  "bk_ok_kuszobon"}
    missing = sorted(required_k - set(K.columns))
    if missing:
        raise SystemExit(
            f"A {kont_f.name} elavult, hiányzó oszlopok: {', '.join(missing)}.")
    k_lam = np.sort(K["lambda_skala"].dropna().unique())
    jo_k_lam = (k_lam.shape == ELVART_KONTUR_LAMBDA.shape and
                np.allclose(k_lam, ELVART_KONTUR_LAMBDA,
                            rtol=0, atol=1e-10))
    if (len(K) != len(ELVART_KONTUR_LAMBDA) or
            K.duplicated(["lambda_skala"], keep=False).any() or not jo_k_lam):
        raise SystemExit(
            f"A {kont_f.name} nem a teljes, egyedi, elvárt 12 soros "
            "lambda-kontúrt tartalmazza.")
    if (not K["bk_ok_kuszobon"].eq(1).all() or
            not np.isfinite(K[["kuszob_omega", "szorzat"]].to_numpy()).all()):
        raise SystemExit(
            f"A {kont_f.name} legalább egy küszöbpontja nem véges vagy "
            "terminálisan BK-invalid; nem készül részleges ábra.")

    D = pd.read_csv(diag_f)
    required_d = {"OPTEN", "kuszob_diagonalis", "szorzat_a_diagonalison",
                  "bk_ok_kuszobon"}
    missing = sorted(required_d - set(D.columns))
    if missing:
        raise SystemExit(
            f"A {diag_f.name} elavult, hiányzó oszlopok: {', '.join(missing)}.")
    d_opten = np.sort(D["OPTEN"].dropna().unique())
    if (len(D) != len(ELVART_ATLO_OPTEN) or
            D.duplicated(["OPTEN"], keep=False).any() or
            not np.array_equal(d_opten, ELVART_ATLO_OPTEN)):
        raise SystemExit(
            f"A {diag_f.name} nem az elvárt két egyedi OPTEN=0/1 átlósort "
            "tartalmazza.")
    if (not D["bk_ok_kuszobon"].eq(1).all() or
            not np.isfinite(D[["kuszob_diagonalis",
                               "szorzat_a_diagonalison"]].to_numpy()).all()):
        raise SystemExit(
            f"A {diag_f.name} legalább egy átlópontja nem véges vagy "
            "terminálisan BK-invalid; nem készül ábra.")

    d1 = float(D.loc[D["OPTEN"] == 1, "kuszob_diagonalis"].iloc[0])
    szorzat = float(K["szorzat"].median())

    Z = np.full((len(lam), len(om)), np.nan)
    for i, L in enumerate(lam):
        for j, O in enumerate(om):
            m = G[(G["lamscale"] == L) & (G["omscale"] == O)]
            if len(m):
                Z[i, j] = m["KKV_minus_L_pp"].iloc[0]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.2, 5.4),
                                   facecolor=FELULET)
    fig.subplots_adjust(left=0.06, right=0.98, top=0.84, bottom=0.24,
                        wspace=0.28)

    # --- BAL: a felulet + a mert nulla-kontur ---------------------------
    lim = np.nanmax(np.abs(Z))
    cf = ax1.contourf(om, lam, Z, levels=21, cmap="RdBu_r",
                      vmin=-lim, vmax=lim)
    ax1.contour(om, lam, Z, levels=[0], colors=[TINTA], linewidths=2.4)
    cb = fig.colorbar(cf, ax=ax1, pad=0.02)
    cb.set_label("KKV − nagyvállalat (pp)", fontsize=9, color=MASOD)
    cb.ax.tick_params(labelsize=8, colors=MASOD)
    ax1.set_title("A küszöb nem pont, hanem GÖRBE", fontsize=10.5,
                  color=TINTA)
    ax1.set_xlabel(r"$\omega$-skála (hozzáférés $\to$ beruházás)", fontsize=9)
    ax1.set_ylabel(r"$\lambda$-skála (felár $\to$ hozzáférés)", fontsize=9)
    # a korabban kozolt EGYETLEN pont: ahol a ket lepcsot azonosan skalaztuk
    ax1.plot([d1], [d1], "o", color=AQUA, markersize=9,
             markeredgecolor="white", markeredgewidth=1.4, zorder=5)
    ax1.annotate(f"a korábban közölt\negyetlen szám: {d1:.2f}",
                 (d1, d1), textcoords="offset points", xytext=(14, 10),
                 fontsize=8, color=AQUA, fontweight="bold")

    # --- JOBB: a kontur log-log skalan -> egyenes, meredekseg -1 --------
    ax2.loglog(K["lambda_skala"], K["kuszob_omega"], "o-", color=KEK,
               linewidth=2.2, markersize=6, label="mért küszöb-kontúr",
               zorder=3)
    x = np.logspace(np.log10(K["lambda_skala"].min() * 0.8),
                    np.log10(K["lambda_skala"].max() * 1.2), 100)
    ax2.loglog(x, szorzat / x, "--", color=PIROS, linewidth=1.6,
               label=rf"izo-szorzat: $\lambda\cdot\omega = {szorzat:.0f}$",
               zorder=2)
    ax2.plot([d1], [d1], "o", color=AQUA, markersize=9,
             markeredgecolor="white", markeredgewidth=1.4, zorder=4)
    ax2.annotate(f"({d1:.2f}, {d1:.2f})", (d1, d1),
                 textcoords="offset points", xytext=(10, 8), fontsize=8,
                 color=AQUA, fontweight="bold")
    ax2.set_title(r"log-log skálán EGYENES, meredeksége $-1$",
                  fontsize=10.5, color=TINTA)
    ax2.set_xlabel(r"$\lambda$-skála", fontsize=9)
    ax2.set_ylabel(r"a küszöbhöz szükséges $\omega$-skála", fontsize=9)
    ax2.legend(fontsize=8.5, frameon=False, loc="upper right")
    ax2.grid(True, which="both", linewidth=0.4, color=MASOD, alpha=0.25)

    for ax in (ax1, ax2):
        ax.set_facecolor(FELULET)
        ax.tick_params(labelsize=9, colors=MASOD)
        for s in ("top", "right"):
            ax.spines[s].set_visible(False)
        for s in ("left", "bottom"):
            ax.spines[s].set_color(MASOD)

    fig.suptitle("A hozzáférési csatorna KÉT lépcsője — a modell csak a "
                 "SZORZATUKAT azonosítja\n"
                 "(jv_dsge_v09_access, SCENARIO=1, TSCEN=3, OPTEN=1, "
                 r"$\rho_{acc}=0{,}9673$)",
                 fontsize=11.5, color=TINTA)
    fig.text(0.06, 0.035,
             "A 100-as skála a v07_access-ből ÁTVETT értékeket jelenti "
             r"($\lambda_E=2{,}0$, $\lambda_D=2{,}5$, $\omega_E=0{,}35$, "
             r"$\omega_D=0{,}45$)."
             "\nA korábban közölt „22,3-as küszöb” ennek a görbének "
             "EGYETLEN pontja: az, ahol a két lépcsőt azonos arányban "
             f"skáláztuk — vagyis $\\sqrt{{{szorzat:.0f}}}$.\n"
             "Ugyanaz az eredmény áll elő pl. "
             rf"$\lambda$-skála $=5$, $\omega$-skála $=100$ mellett is. "
             "Mindkét tengely HORGONYZATLAN paraméter (D kategória). "
             "Adat: t52 (rács), t52b (kontúr), t52d (átló).\n"
             "A fehér/hiányzó cella terminálisan BK-indeterminált vagy "
             "technikailag érvénytelen futás; nem egyszerű adathiány.",
             fontsize=7.8, color=MASOD, va="bottom")

    fig.savefig(KI, dpi=180, facecolor=FELULET)
    print(f"KIÍRVA: {KI}")
    print()
    print(K.to_string(index=False))
    print()
    print(f"A kontúron a szorzat mediánja: {szorzat:.1f} "
          f"(relatív szórás {100 * K['szorzat'].std() / K['szorzat'].mean():.2f}%)")
    print(f"Az átló (lambda = omega): {d1:.2f}  ->  {d1:.2f}^2 = {d1 ** 2:.1f}")


if __name__ == "__main__":
    main()
