# -*- coding: utf-8 -*-
"""Streamlit app a Jakab–Világi (+BGG) DSGE-modellhez.

A csúszkákkal beállított paramétereket átadja a Dynare-modellnek
(src/model/jv_app_model.mod), MATLAB+Dynare-ral lefuttatja, és megjeleníti
az impulzusválaszokat. A modell a validált .mod — az app csak vezérli.

Indítás a repo gyökeréből:
    streamlit run src/app/jv_app.py

Előfeltétel: MATLAB + Dynare 6.5. A MATLAB elérési útja a MATLAB_EXE
környezeti változóból, a Dynare-é a DYNARE_PATH-ból jön (alább alapértékek).
"""

import os
import subprocess
import tempfile
from pathlib import Path

import pandas as pd
import streamlit as st

REPO = Path(__file__).resolve().parents[2]
MODEL_DIR = REPO / "src" / "model"
APP_DIR = REPO / "src" / "app"
MATLAB_EXE = os.environ.get(
    "MATLAB_EXE", r"C:\Program Files\MATLAB\R2025b\bin\matlab.exe")
DYNARE_PATH = os.environ.get("DYNARE_PATH", r"C:\dynare\6.5\matlab")

# app-paraméter -> (@#define név, címke, min, max, alap, lépés)
PARAMS = {
    "SIGMA": ("σ — fogyasztás görbülete (1/IES)", 0.5, 3.0, 1.814, 0.05),
    "HABIT": ("h — fogyasztási szokás", 0.0, 0.95, 0.646, 0.01),
    "XIP":   ("ξ_p — Calvo ár-ragadósság", 0.50, 0.97, 0.921, 0.01),
    "XIW":   ("ξ_w — Calvo bér-ragadósság", 0.30, 0.95, 0.657, 0.01),
    "PHIPI": ("φ_π — Taylor inflációs válasz", 1.05, 3.0, 1.379, 0.05),
    "GAMI":  ("γ_i — kamatsimítás", 0.0, 0.95, 0.761, 0.01),
    "MUX":   ("μ_x — exportkereslet árrugalmassága", 0.1, 2.0, 0.534, 0.05),
    "PSII":  ("ψ_i — beruházási kiigazítási költség", 1.0, 20.0, 13.0, 0.5),
    "CHIS":  ("χ_S — KKV pénzügyi akcelerátor", 0.0, 0.15, 0.06, 0.005),
    "CHIL":  ("χ_L — nagyvállalati akcelerátor", 0.0, 0.15, 0.02, 0.005),
    "LEVS":  ("lev_S — KKV tőkeáttétel", 1.0, 3.0, 1.6, 0.05),
    "LEVL":  ("lev_L — nagyvállalati tőkeáttétel", 1.0, 3.0, 1.85, 0.05),
}

# szép magyar címkék az IRF-változókhoz
VALTOZOK = {
    "y": "GDP", "c": "Fogyasztás", "ii": "Beruházás (aggregált)",
    "i_S": "KKV-beruházás", "i_L": "Nagyvállalati beruházás",
    "efp_S": "KKV külső fin. prémium (EFP)", "efp_L": "Nagyváll. EFP",
    "nw_S": "KKV nettó vagyon", "nw_L": "Nagyváll. nettó vagyon",
    "xx": "Export", "infl": "CPI-infláció", "piw": "Bérinfláció",
    "r": "Nominális kamat", "rer": "Reálárfolyam", "w": "Reálbér",
    "rk": "Tőke bérleti díja",
}
SOKKOK = {
    "eps_a": "Termelékenységi sokk", "eps_r": "Monetáris sokk",
    "eps_pr": "Pénzügyi prémium sokk", "eps_x": "Exportkereslet sokk",
    "eps_c": "Fogyasztási preferencia", "eps_q": "Equity-prémium",
    "eps_md": "Belföldi ár-markup", "eps_mx": "Export ár-markup",
    "eps_w": "Bér-markup", "eps_i": "Beruházási sokk", "eps_g": "Fiskális sokk",
}

KEK, AQUA = "#2a78d6", "#1baf7a"


@st.cache_data(show_spinner=False)
def solve(param_values: tuple) -> pd.DataFrame:
    """A modell futtatása MATLAB+Dynare-ral a megadott paraméterekkel."""
    defs = " ".join(f"-D{k}={v}" for k, v in param_values)
    out = Path(tempfile.gettempdir()) / "jv_app_irf.csv"
    if out.exists():
        out.unlink()
    batch = (
        f"addpath('{DYNARE_PATH}'); addpath('{APP_DIR}'); "
        f"cd('{MODEL_DIR}'); APP_OUT='{out.as_posix()}'; "
        f"dynare jv_app_model {defs} console; jv_app_export"
    )
    res = subprocess.run([MATLAB_EXE, "-batch", batch],
                         capture_output=True, text=True, timeout=180)
    if not out.exists():
        raise RuntimeError(
            "A modell nem futott le (nincs kimenet). Gyakori ok: a "
            "paraméterek mellett sérül a Blanchard–Kahn feltétel "
            "(indetermináció/nincs megoldás). MATLAB-napló vége:\n"
            + res.stdout[-1500:])
    return pd.read_csv(out)


st.set_page_config(page_title="Jakab–Világi DSGE", layout="wide")
st.title("Jakab–Világi DSGE — interaktív impulzusválaszok")
st.caption("MNB WP 2008/9 mag + kétszektoros BGG · a modell a validált "
           "`jv_app_model.mod`, az app csak vezérli · euró/KKV projekt")

with st.sidebar:
    st.header("Paraméterek")
    st.caption("Alap = a JV becsült poszterior-átlaga (IT-rezsim).")
    vals = []
    for key, (label, lo, hi, default, step) in PARAMS.items():
        vals.append((key, st.slider(label, float(lo), float(hi),
                                    float(default), float(step))))
    if st.button("↺ Vissza az alapértékekre"):
        st.rerun()

col_run, col_shock = st.columns([1, 2])
with col_run:
    run = st.button("▶ Futtatás", type="primary", use_container_width=True)
with col_shock:
    shock = st.selectbox("Sokk", list(SOKKOK), format_func=SOKKOK.get, index=1)

if run or "irf" not in st.session_state:
    try:
        with st.spinner("Dynare fut… (~5 mp)"):
            st.session_state["irf"] = solve(tuple(vals))
        st.session_state["err"] = None
    except Exception as e:  # noqa: BLE001
        st.session_state["err"] = str(e)

if st.session_state.get("err"):
    st.error(st.session_state["err"])
elif "irf" in st.session_state:
    irf = st.session_state["irf"]
    st.subheader(f"Impulzusválaszok — {SOKKOK[shock]}")
    kulcs = ["y", "c", "ii", "i_S", "i_L", "efp_S", "efp_L", "xx",
             "infl", "piw", "r", "rer"]
    kulcs = [v for v in kulcs if f"{v}_{shock}" in irf.columns]
    cols = st.columns(3)
    for i, v in enumerate(kulcs):
        s = irf[f"{v}_{shock}"]
        skala = 40000 if v in ("efp_S", "efp_L", "infl", "piw", "r") else 100
        egys = "évesített bp" if skala == 40000 else "% eltérés"
        df = pd.DataFrame({"negyedév": irf["h"], VALTOZOK.get(v, v): s * skala})
        with cols[i % 3]:
            st.markdown(f"**{VALTOZOK.get(v, v)}** · {egys}")
            st.line_chart(df, x="negyedév", y=VALTOZOK.get(v, v), height=200)

    # a projekt kulcsábrája: KKV vs nagyvállalat aszimmetria
    st.subheader("KKV vs. nagyvállalat — a méretfüggő akcelerátor")
    comp = pd.DataFrame({
        "negyedév": irf["h"],
        "KKV-beruházás": irf.get(f"i_S_{shock}", 0) * 100,
        "nagyvállalati beruházás": irf.get(f"i_L_{shock}", 0) * 100,
    })
    st.line_chart(comp, x="negyedév",
                  y=["KKV-beruházás", "nagyvállalati beruházás"],
                  color=[KEK, AQUA], height=320)
    with st.expander("Nyers IRF-tábla"):
        st.dataframe(irf, height=300)
