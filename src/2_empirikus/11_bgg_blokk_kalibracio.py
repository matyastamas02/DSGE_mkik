"""11_bgg_blokk_kalibracio.py — a BGG pénzügyi blokk 5 paramétere az Opten-panelből.

CÉL
---
Öt paraméter, amelyek EGY egyenlet két oldalán állnak a modellben:

    efp_j = chi_j * (q_j + k_j - nw_j)          [külső finanszírozási felár]
    lev_j = K_j / N_j                            [állandósult tőkeáttétel]

    lev_E, lev_D, lev_L   — tőkeáttétel szegmensenként (szint)
    chi_S, chi_L          — a felár tőkeáttétel-érzékenysége (meredekség)

Ezért érdemes együtt kalibrálni őket: a `lev` a BGG-szerződés
állandósult pontja, a `chi` pedig ugyanannak a szerződésnek a lokális
meredeksége. Ha a kettőt külön forrásból vesszük, a pénzügyi blokk
belsőleg inkonzisztens lehet.

FÜGGŐSÉGEK: csak pandas + numpy (a fix hatásos becslés kézzel van megírva,
hogy statsmodels nélkül is fusson — a repóban nincs telepítve).

BEMENET
    data/processed/opten_panel.csv        (a 01_opten_panel_tisztitas.py kimenete)
    data/processed/bubor_evatlag.csv      (MNB BUBOR-fixing éves átlag; a
                                           src/bubor_evatlag.m írja ki)
KIMENET
    output/tables/t50_bgg_blokk.csv       (az 5 paraméter + diagnosztika)
    output/tables/t50b_bgg_chi_reszletes.csv

FUTTATÁS
    python src/11_bgg_blokk_kalibracio.py

MEGJEGYZÉS A REPO KONVENCIÓJÁHOZ: a CLAUDE.md szerint az új scriptek
MATLAB-ban készülnek. Ez szándékos kivétel — kifejezetten azért Python,
hogy a kalibráció külön ellenőrizhető legyen a modellkörnyezettől
függetlenül. A számnév-prefix a repo Python-scriptjeinek konvenciója
(01–10 Python, s06–s15 MATLAB).
"""

from __future__ import annotations

import pathlib
import sys

import numpy as np
import pandas as pd

REPO = next(p for p in pathlib.Path(__file__).resolve().parents
            if (p / "CLAUDE.md").exists())
PANEL = REPO / "data" / "processed" / "opten_panel.csv"
BUBOR = REPO / "data" / "processed" / "bubor_evatlag.csv"
OUT = REPO / "output" / "tables"

EVEK = [2021, 2022, 2023, 2024]
SZG = ["E_export_KKV", "D_hazai_KKV", "L_nagyvallalat"]


# ---------------------------------------------------------------------------
# Segédfüggvények
# ---------------------------------------------------------------------------
def cim(s: str) -> None:
    print("\n" + "=" * 78)
    print(s)
    print("=" * 78)


def within(y: np.ndarray, g: np.ndarray) -> np.ndarray:
    """Csoporton (cégen) belüli demeaning — a fix hatás kiléptetése."""
    n = np.bincount(g)
    m = np.bincount(g, weights=y) / n
    return y - m[g]


def fe_ols(y, X, gid, nevek):
    """Cég-fix hatásos OLS, cégre klaszterezett standard hibával.

    A cég-fix hatást within-transzformációval léptetjük ki (Frisch–Waugh),
    az év-dummykat is demeanelve tesszük be, így a kétirányú (cég + év)
    fix hatás EGZAKT — nem közelítés, ami kiegyensúlyozatlan panelen
    egyszerű kettős demeaninggel hiba lenne.
    """
    yw = within(y, gid)
    Xw = np.column_stack([within(X[:, k], gid) for k in range(X.shape[1])])
    beta, *_ = np.linalg.lstsq(Xw, yw, rcond=None)
    res = yw - Xw @ beta

    XtXinv = np.linalg.pinv(Xw.T @ Xw)
    ncl = gid.max() + 1
    S = np.zeros((ncl, Xw.shape[1]))
    XU = Xw * res[:, None]
    for k in range(Xw.shape[1]):
        S[:, k] = np.bincount(gid, weights=XU[:, k], minlength=ncl)
    V = XtXinv @ (S.T @ S) @ XtXinv * (ncl / (ncl - 1))
    se = np.sqrt(np.diag(V))
    return pd.DataFrame(
        {"valtozo": nevek, "egyutthato": beta, "klaszt_SE": se,
         "t": beta / se}
    ), len(y), ncl


# ---------------------------------------------------------------------------
# 1. Panel betöltése és szegmentálása (AZONOS az s14 / s15 definícióval)
# ---------------------------------------------------------------------------
def betolt() -> pd.DataFrame:
    if not PANEL.exists():
        sys.exit(f"Hiányzik: {PANEL}")
    kell = [
        "opten_id", "ev", "meret_kategoria", "exportor", "van_hitel",
        "eszkozok_osszesen", "sajat_toke", "kotelezettsegek",
        "targyi_eszkozok", "befektetett_eszkozok", "hitelallomany",
        "kamatraforditas", "implicit_kamatrata",
    ]
    p = pd.read_csv(PANEL, usecols=kell, low_memory=False)

    # FIGYELEM: a van_hitel / exportor SZÖVEGES "True"/"False" a panelben.
    p["exportal"] = p["exportor"].astype(str).str.lower().eq("true")

    meret = p["meret_kategoria"].astype(str)
    nagy = meret.eq("250+")
    kkv = meret.isin(["10-49", "50-249"])

    p["szegmens"] = pd.NA
    p.loc[kkv & p["exportal"], "szegmens"] = SZG[0]
    p.loc[kkv & ~p["exportal"], "szegmens"] = SZG[1]
    p.loc[nagy, "szegmens"] = SZG[2]

    p = p[p["ev"].isin(EVEK) & p["szegmens"].notna()].copy()
    print(f"Panel: {len(p)} cég-év, {p['opten_id'].nunique()} cég "
          f"({min(EVEK)}–{max(EVEK)}, 10+ fő)")
    return p


# ---------------------------------------------------------------------------
# 2. lev_E / lev_D / lev_L — a BGG tőkeáttétel szintje
# ---------------------------------------------------------------------------
def tokeattetel(p: pd.DataFrame) -> pd.DataFrame:
    cim("lev_E / lev_D / lev_L — TŐKEÁTTÉTEL (BGG: K/N)")

    # (a) FŐ MÉRTÉK: mérlegfőösszeg / saját tőke.
    #     A BGG-ben lev = K/N, ahol K az eszközállomány, N a nettó vagyon.
    lev = p["eszkozok_osszesen"] / p["sajat_toke"]
    jo = (p["sajat_toke"] > 0) & (p["eszkozok_osszesen"] > 0) \
        & lev.between(1, 100)

    # (b) KERESZTPRÓBA: 1/(1 - kötelezettségek/eszközök).
    #     Ha a mérleg pontosan E = SzT + K lenne, a kettő azonos volna.
    #     Az eltérés a passzív időbeli elhatárolás és a céltartalék.
    d = p["kotelezettsegek"].fillna(0) / p["eszkozok_osszesen"]

    # (c) ÉRZÉKENYSÉG: befektetett eszközök / saját tőke — szűkebb K-fogalom,
    #     közelebb a BGG "fizikai tőke" értelmezéséhez.
    levb = p["befektetett_eszkozok"] / p["sajat_toke"]
    job = (p["sajat_toke"] > 0) & (p["befektetett_eszkozok"] > 0) \
        & levb.between(0.01, 100)

    sorok = []
    for s in SZG:
        m = jo & p["szegmens"].eq(s)
        mb = job & p["szegmens"].eq(s)
        md = m & d.notna()
        sorok.append({
            "szegmens": s,
            "lev_median": lev[m].median(),
            "lev_atlag": lev[m].mean(),
            "lev_p25": lev[m].quantile(0.25),
            "lev_p75": lev[m].quantile(0.75),
            "n": int(m.sum()),
            "keresztproba_1_per_1mind": 1 / (1 - d[md].median()),
            "befektetett_eszk_alap": levb[mb].median(),
        })
    T = pd.DataFrame(sorok)
    with pd.option_context("display.width", 200, "display.max_columns", 20):
        print(T.round(4).to_string(index=False))
    print("\n  jelenlegi modellérték: lev_E = lev_D = 1.60, lev_L = 1.85")
    return T


# ---------------------------------------------------------------------------
# 3. chi_S / chi_L — a felár tőkeáttétel-érzékenysége
# ---------------------------------------------------------------------------
def chi(p: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    cim("chi_S / chi_L — A FELÁR TŐKEÁTTÉTEL-ÉRZÉKENYSÉGE")
    print("""
Becsült egyenlet (cég- ÉS év-fix hatással):

    r_it = chi_eves * log(lev_it) + alpha_i + delta_t + e_it

  r_it        implicit kamatráta = kamatráfordítás / hitelállomány (éves, tizedes)
  log(lev_it) log tőkeáttétel (eszközök / saját tőke)
  alpha_i     cég-fix hatás  -> a tartós kockázati szint kiesik
  delta_t     év-fix hatás   -> a kockázatmentes szint (BUBOR) KIESIK,
                                ezért a becsléshez BUBOR-adat nem is kell

A modell efp-je NEGYEDÉVES tizedes (efp = -0.0025 <=> -100 bp/év), ezért
    chi = chi_eves / 4
""")

    p = p.sort_values(["opten_id", "ev"]).copy()
    elozo = (p["opten_id"] == p["opten_id"].shift(1)) & \
            (p["ev"] == p["ev"].shift(1) + 1)
    hitel_lag = p["hitelallomany"].shift(1).where(elozo)

    lev = p["eszkozok_osszesen"] / p["sajat_toke"]
    x = np.log(lev)

    # KÉT MÉRTÉK AZ IMPLICIT RÁTÁRA — a különbségük dönti el, hogy a becsült
    # együttható mérési műtermék-e:
    #   (A) a panel eredeti oszlopa: kamat_t / hitelállomány_t (ÉV VÉGI állomány)
    #   (B) kamat_t / a nyitó és záró állomány ÁTLAGA
    # Ha egy cég év közben vesz fel új hitelt, az (A)-ban a számláló csak
    # töredékévnyi kamat, a nevező viszont már a teljes új állomány -> a mért
    # ráta MECHANIKUSAN lecsökken, épp amikor a tőkeáttétel nő. Ez önmagában
    # NEGATÍV együtthatót gyárt. A (B) ezt a torzítást felezi.
    r_a = p["implicit_kamatrata"]
    atlagallomany = (p["hitelallomany"] + hitel_lag) / 2
    r_b = (p["kamatraforditas"] / atlagallomany).where(atlagallomany > 0)

    alap = np.isfinite(x) & (p["sajat_toke"] > 0) & lev.between(1, 100) \
        & (p["hitelallomany"] > 0)

    # HARMADIK METSZET: csak azok a cég-évek, ahol a hitelállomány NEM mozdult
    # érdemben (±10%). Itt a fenti flow/stock műtermék nem működhet, mert nincs
    # jelentős évközi felvét. Ha a negatív előjel ITT is megmarad, akkor nem
    # mérési kérdés.
    valtozas = (p["hitelallomany"] / p["hitelallomany"].shift(1)).where(elozo)
    stabil = valtozas.between(0.9, 1.1)

    specek = [
        ("A: kamat / ÉV VÉGI állomány", r_a, alap),
        ("B: kamat / ÁTLAGOS állomány", r_b, alap & elozo),
        ("C: B + stabil hitelállomány", r_b, alap & elozo & stabil),
    ]
    csoportok = {
        "S_KKV_egyben": p["szegmens"].isin(SZG[:2]),
        "L_nagyvallalat": p["szegmens"].eq(SZG[2]),
        "E_export_KKV (diagnosztika)": p["szegmens"].eq(SZG[0]),
        "D_hazai_KKV (diagnosztika)": p["szegmens"].eq(SZG[1]),
    }

    reszletes, sorok = [], []
    for spec_nev, r, szures in specek:
        print(f"\n  --- {spec_nev} ---")
        jo = szures & r.notna() & r.between(0.001, 0.50)
        for nev, maszk in csoportok.items():
            m = jo & maszk
            if m.sum() < 200:
                print(f"  {nev:<30} (kihagyva: n = {int(m.sum())})")
                continue
            q = p[m]
            gid = pd.factorize(q["opten_id"])[0]
            D = np.column_stack(
                [(q["ev"] == e).to_numpy(float) for e in EVEK[1:]])
            X = np.column_stack([x[m].to_numpy(), D])
            nevek = ["log(lev)"] + [f"ev={e}" for e in EVEK[1:]]
            R, n, ncl = fe_ols(r[m].to_numpy(), X, gid, nevek)
            R.insert(0, "csoport", nev)
            R.insert(0, "spec", spec_nev)
            reszletes.append(R)

            b, se = R.loc[0, "egyutthato"], R.loc[0, "klaszt_SE"]
            sorok.append({
                "spec": spec_nev, "csoport": nev, "chi_eves": b,
                "chi_negyedeves": b / 4, "klaszt_SE_negyedeves": se / 4,
                "t": b / se, "n_ceg_ev": n, "n_ceg": ncl,
            })
            print(f"  {nev:<30} chi_eves = {b:+.5f} (SE {se:.5f}, "
                  f"t {b/se:+.2f})  ->  chi = {b/4:+.5f}   n = {n}")

    C = pd.DataFrame(sorok)
    print("\n  jelenlegi modellérték: chi_E = chi_D = 0.06, chi_L = 0.02")
    print("  (a BGG-elmélet POZITÍV chi-t követel: több tőkeáttétel -> nagyobb felár)")
    return C, pd.concat(reszletes, ignore_index=True)


# ---------------------------------------------------------------------------
# 4. Leíró: a felár SZINTJE (a BGG 200 bp/év konvencióhoz)
# ---------------------------------------------------------------------------
def felar_szint(p: pd.DataFrame) -> None:
    cim("LEÍRÓ — A FELÁR SZINTJE (a BGG állandósult 200 bp/év-hez)")
    if not BUBOR.exists():
        print(f"  (kihagyva: hiányzik {BUBOR})")
        return
    b = pd.read_csv(BUBOR).set_index("ev")["bubor_3h_eves_atlag"]
    r = p["implicit_kamatrata"]
    jo = r.notna() & r.between(0.001, 0.50)
    q = p[jo].copy()
    q["spread_bp"] = (r[jo] - q["ev"].map(b)) * 10000
    t = q.groupby("szegmens")["spread_bp"].agg(["median", "mean", "count"])
    print(t.round(1).to_string())
    print("\n  FIGYELEM: az implicit ráta a TELJES állományra vett átlagos ráta,")
    print("  benne a támogatott (Széchenyi/NHP) hitelekkel — a 2022–24-es")
    print("  években ez a piaci felárnál SZISZTEMATIKUSAN alacsonyabb, sőt")
    print("  negatív szpredet is adhat. Szintként ezért nem használható.")


# ---------------------------------------------------------------------------
def main() -> None:
    p = betolt()
    L = tokeattetel(p)
    C, R = chi(p)
    felar_szint(p)

    OUT.mkdir(parents=True, exist_ok=True)
    ossz = pd.DataFrame([
        {"parameter": "lev_E", "jelenlegi": 1.60,
         "opten": L.loc[L.szegmens == SZG[0], "lev_median"].iloc[0]},
        {"parameter": "lev_D", "jelenlegi": 1.60,
         "opten": L.loc[L.szegmens == SZG[1], "lev_median"].iloc[0]},
        {"parameter": "lev_L", "jelenlegi": 1.85,
         "opten": L.loc[L.szegmens == SZG[2], "lev_median"].iloc[0]},
        {"parameter": "chi_S", "jelenlegi": 0.06,
         "opten": C.loc[(C.csoport == "S_KKV_egyben")
                        & C.spec.str.startswith("C"),
                        "chi_negyedeves"].iloc[0]},
        {"parameter": "chi_L", "jelenlegi": 0.02,
         "opten": C.loc[(C.csoport == "L_nagyvallalat")
                        & C.spec.str.startswith("C"),
                        "chi_negyedeves"].iloc[0]},
    ])
    ossz["elteres_pct"] = 100 * (ossz["opten"] / ossz["jelenlegi"] - 1)
    ossz.to_csv(OUT / "t50_bgg_blokk.csv", index=False)
    R.to_csv(OUT / "t50b_bgg_chi_reszletes.csv", index=False)

    cim("AZ ÖT PARAMÉTER")
    print(ossz.round(5).to_string(index=False))
    print(f"\nKiírva: {OUT / 't50_bgg_blokk.csv'}")
    print(f"        {OUT / 't50b_bgg_chi_reszletes.csv'}")


if __name__ == "__main__":
    main()
