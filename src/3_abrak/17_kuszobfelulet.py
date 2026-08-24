"""17_kuszobfelulet.py — a KKV-előny küszöbFELÜLETE a (rho_acc, ACCSCALE) síkon.

MIÉRT. Eddig a küszöböt két külön táblában közöltük: t48b (küszöb három
kalibrációs ágon) és t49b (küszöb hat rho_acc értéken). Egy külső bíráló
(2026-08-16) joggal jegyezte meg, hogy a két horgonyzatlan paraméter EGYÜTT
határozza meg az eredményt, tehát a helyes közlési forma nem két lista,
hanem egy FELÜLET — és ebből a legfontosabb objektum a NULLA-KONTÚR: az a
(rho_acc, ACCSCALE) párokból álló vonal, amely mentén a KKV-blokk éppen
utoléri a nagyvállalatot.

Az adat MÁR MEGVAN: a t49 egy teljes 6 x 22-es rács (6 rho_acc x 22
ACCSCALE, 132 pont), a stress_opten_v09.m írta. Ez a script nem futtat
modellt, csak megjeleníti — tehát tetszőleges számú alkalommal
újrafuttatható MATLAB nélkül.

FONTOS ÉRTELMEZÉS: a felület tengelyei KÉT NEM AZONOSÍTOTT paraméter.
Az ábra nem azt mondja meg, hol vagyunk, hanem hogy a küszöb hogyan függ
attól, hol vagyunk. A megjelölt pont (rho_acc = 0,9673) leíró magas-rho
érzékenységi pont, nem a modell dinamikus szegmensparaméterének kalibrációja.

Kimenet: output/figures/f27_kuszobfelulet.png
         output/tables/t51_kuszobfelulet.csv   (a nulla-kontúr adatként)
Futtatás: python src/3_abrak/17_kuszobfelulet.py
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
BE = REPO / "output" / "tables" / "t49_rhoacc_erzekenyseg.csv"
F_KI = REPO / "output" / "figures" / "f27_kuszobfelulet.png"
T_KI = REPO / "output" / "tables" / "t51_kuszobfelulet.csv"

# a repo palettaja (lasd run_jv_v06.m)
KEK = "#2a78d6"
AQUA = "#1baf7a"
PIROS = "#c73e2d"
TINTA = "#0a0a0a"
MASOD = "#525049"
FELULET = "#fcfcfb"

ELVART_RHOK = np.array([0.85, 0.90, 0.93, 0.95, 0.9673, 0.98])
ELVART_ACCSCALE = np.array([
    0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 25, 30, 35, 40, 45, 50, 60,
    80, 100, 120, 140,
])


def kuszob(acc: np.ndarray, d: np.ndarray,
           ervenyes: np.ndarray) -> tuple[float, float]:
    """Lineáris interpoláció két szomszédos, BK-érvényes pont között."""
    for j in range(len(d) - 1):
        if ervenyes[j] == 1 and ervenyes[j + 1] == 1 and d[j] < 0 <= d[j + 1]:
            k = acc[j] + (acc[j + 1] - acc[j]) * (0 - d[j]) / (d[j + 1] - d[j])
            return k, 1.0
    if len(d) and ervenyes[0] == 1 and d[0] >= 0:
        return 0.0, 1.0
    return float("nan"), float("nan")


def main() -> None:
    if not BE.exists():
        raise SystemExit(f"Hiányzik: {BE}\nElőbb: matlab -batch "
                         "\"cd('src/modell/1_fo_vonal_jv/futtato'); "
                         "stress_opten_v09\"")
    T_all = pd.read_csv(BE)
    required = {"OPTEN", "SCENARIO", "TSCEN", "rho_acc", "accscale",
                "GDP_pct", "KKV_minus_L_pp", "solver_ok", "bk_check_ok",
                "bk_ok", "ervenyes", "n_forward", "n_unstable",
                "bk_qz_criterium"}
    missing = sorted(required - set(T_all.columns))
    if missing:
        raise SystemExit(
            f"A {BE.name} elavult, hiányzó BK-oszlopok: {', '.join(missing)}. "
            "Futtasd újra a stress_opten_v09.m scriptet.")

    kulcs = ["rho_acc", "accscale"]
    duplikalt = T_all.duplicated(kulcs, keep=False)
    vart_db = len(ELVART_RHOK) * len(ELVART_ACCSCALE)
    if len(T_all) != vart_db or duplikalt.any():
        raise SystemExit(
            f"A {BE.name} nem teljes, egyedi 6×22-es rács: "
            f"{len(T_all)}/{vart_db} sor, {int(duplikalt.sum())} "
            "duplikált kulcsú sor. Futtasd újra a stress_opten_v09.m scriptet.")

    rhok = np.sort(T_all["rho_acc"].dropna().unique())
    accok = np.sort(T_all["accscale"].dropna().unique())
    jo_rhok = (rhok.shape == ELVART_RHOK.shape and
               np.allclose(rhok, ELVART_RHOK, rtol=0, atol=1e-10))
    jo_accok = (accok.shape == ELVART_ACCSCALE.shape and
                np.allclose(accok, ELVART_ACCSCALE, rtol=0, atol=1e-10))
    if not jo_rhok or not jo_accok:
        raise SystemExit(
            f"A {BE.name} rácstengelyei eltérnek az elvárt 6 rho × 22 "
            "ACCSCALE tengelytől. Futtasd újra a stress_opten_v09.m scriptet.")

    if not (T_all["OPTEN"].eq(1).all() and
            T_all["SCENARIO"].eq(1).all() and
            T_all["TSCEN"].eq(3).all()):
        raise SystemExit(
            f"A {BE.name} nem kizárólag az elvárt OPTEN=1, SCENARIO=1, "
            "TSCEN=3 konfigurációt tartalmazza.")

    technikai_ok = T_all["solver_ok"].eq(1) & T_all["bk_check_ok"].eq(1)
    if not technikai_ok.all():
        raise SystemExit(
            f"A {BE.name} {int((~technikai_ok).sum())} során a PF solver "
            "vagy a terminális BK-diagnosztika technikailag nem futott le; "
            "nem készül részleges t51/ábra.")

    T = T_all[T_all["ervenyes"] == 1].copy()

    Z = np.full((len(rhok), len(accok)), np.nan)
    for i, r in enumerate(rhok):
        for j, a in enumerate(accok):
            m = T[(np.isclose(T["rho_acc"], r)) & (T["accscale"] == a)]
            if len(m):
                Z[i, j] = m["KKV_minus_L_pp"].iloc[0]

    # --- a nulla-kontur adatkent ---------------------------------------
    sorok = []
    for i, r in enumerate(rhok):
        sor = T_all[np.isclose(T_all["rho_acc"], r)].sort_values("accscale")
        k, bk_k = kuszob(sor["accscale"].to_numpy(),
                         sor["KKV_minus_L_pp"].to_numpy(),
                         sor["ervenyes"].to_numpy())
        pont100 = sor[sor["accscale"] == 100]
        jo100 = pont100[pont100["ervenyes"] == 1]
        sorok.append({
            "rho_acc": r,
            "LR_szorzo": round(1.0 / (1.0 - r), 2),
            "kuszob_ACCSCALE": round(k, 2) if np.isfinite(k) else np.nan,
            "GDP_pct_ACC100": round(float(jo100["GDP_pct"].iloc[0]), 4)
            if len(jo100) else np.nan,
            "bk_ok_ACC100": float(pont100["bk_ok"].iloc[0])
            if len(pont100) else np.nan,
            "bk_ok_kuszobon": bk_k,
        })
    K = pd.DataFrame(sorok)
    if T.empty or not K["bk_ok_kuszobon"].notna().all():
        raise SystemExit(
            "Nem mind a hat rho-szeleten van BK-érvényes küszöb; "
            "nem készül részleges t51/ábra.")
    K.to_csv(T_KI, index=False, encoding="utf-8")

    # --- abra ----------------------------------------------------------
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.2, 5.2),
                                   facecolor=FELULET)
    fig.subplots_adjust(left=0.06, right=0.98, top=0.85, bottom=0.22,
                        wspace=0.28)

    # BAL: a felulet + nulla-kontur
    lim = np.nanmax(np.abs(Z))
    cf = ax1.contourf(accok, rhok, Z, levels=21, cmap="RdBu_r",
                      vmin=-lim, vmax=lim)
    ax1.contour(accok, rhok, Z, levels=[0], colors=[TINTA], linewidths=2.4)
    cb = fig.colorbar(cf, ax=ax1, pad=0.02)
    cb.set_label("KKV − nagyvállalat (pp)", fontsize=9, color=MASOD)
    cb.ax.tick_params(labelsize=8, colors=MASOD)
    ax1.set_title("A KKV-előny felülete — a fekete vonal a küszöb",
                  fontsize=10.5, color=TINTA)
    ax1.set_xlabel("ACCSCALE (hozzáférési reakció erőssége)", fontsize=9)
    ax1.set_ylabel(r"$\rho_{acc}$ (a hozzáférési állapot perzisztenciája)",
                   fontsize=9)

    # JOBB: a kuszobgorbe
    jo = K.dropna(subset=["kuszob_ACCSCALE"])
    ax2.plot(jo["rho_acc"], jo["kuszob_ACCSCALE"], "o-", color=KEK,
             linewidth=2.2, markersize=6)
    for _, r in jo.iterrows():
        ax2.annotate(f"{r['kuszob_ACCSCALE']:.1f}",
                     (r["rho_acc"], r["kuszob_ACCSCALE"]),
                     textcoords="offset points", xytext=(6, 6),
                     fontsize=8, color=MASOD)
    ax2.set_title("A küszöb monoton csökken a perzisztenciában",
                  fontsize=10.5, color=TINTA)
    ax2.set_xlabel(r"$\rho_{acc}$", fontsize=9)
    ax2.set_ylabel("a KKV-előnyhöz szükséges ACCSCALE", fontsize=9)

    for ax in (ax1, ax2):
        ax.set_facecolor(FELULET)
        ax.tick_params(labelsize=9, colors=MASOD)
        for s in ("top", "right"):
            ax.spines[s].set_visible(False)
        for s in ("left", "bottom"):
            ax.spines[s].set_color(MASOD)

    # a ket nevezetes rho jelolese mindket panelen
    for ertek, cimke, szin in [(0.85, "átvett (0,85)", PIROS),
                               (0.9673, "leíró high-rho (0,9673)", AQUA)]:
        ax1.axhline(ertek, color=szin, linestyle="--", linewidth=1.3)
        # a cimke a VILAGOS (bal) oldalra megy, kulonben a sotet piros
        # zonaban olvashatatlan
        ax1.text(accok.max() * 0.015, ertek, cimke, fontsize=8, color=szin,
                 ha="left", va="bottom")
        ax2.axvline(ertek, color=szin, linestyle="--", linewidth=1.3)

    fig.suptitle("A KKV-előny KÉT nem azonosított paraméter függvénye "
                 "(jv_dsge_v09_access, SCENARIO=1, TSCEN=3, OPTEN=1)",
                 fontsize=12, color=TINTA)
    fig.text(0.06, 0.035,
             "Az ábra NEM azt mondja meg, hol vagyunk, hanem hogy a küszöb "
             "hogyan függ attól, hol vagyunk. Mindkét tengely "
             "HORGONYZATLAN paraméter:\naz ACCSCALE magyar 2021–24-es "
             "adatból nem azonosítható (A06), a rho_acc = 0,9673 pedig "
             "cég-szintű státuszperzisztenciából származó magas-rho "
             "ÉRZÉKENYSÉG,\nnem szegmens-szintű becslés vagy alsó korlát "
             "(A11). Adat: t49 (132 pont). "
             "A fehér/hiányzó tartomány terminálisan BK-indeterminált; "
             "kontúr: t51.",
             fontsize=7.8, color=MASOD, va="bottom")

    fig.savefig(F_KI, dpi=180, facecolor=FELULET)
    print(f"KIÍRVA: {F_KI}")
    print(f"KIÍRVA: {T_KI}")
    print()
    print(K.to_string(index=False))


if __name__ == "__main__":
    main()
