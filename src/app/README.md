# Streamlit app — Jakab–Világi DSGE

Interaktív felület a JV-mag + kétszektoros BGG modellhez: csúszkákkal
állítod a paramétereket, a `▶ Futtatás` gomb lefuttatja a modellt
(MATLAB + Dynare a `src/model/jv_app_model.mod`-on), és megjeleníti az
impulzusválaszokat + a KKV/nagyvállalat aszimmetriát.

## Futtatás

```
streamlit run src/app/jv_app.py
```

vagy a repo-beli `.claude/launch.json`-ból a `jv-app` konfigurációval.

## Előfeltételek

- Python: `streamlit`, `pandas` (`pip install streamlit pandas`)
- MATLAB + Dynare 6.5
- Útvonalak környezeti változóból (alapértékek Windowsra):
  - `MATLAB_EXE` (alap: `C:\Program Files\MATLAB\R2025b\bin\matlab.exe`)
  - `DYNARE_PATH` (alap: `C:\dynare\6.5\matlab`)

## Hogyan működik

Az app a csúszka-értékeket `-D` makrókként adja át egyetlen
`dynare jv_app_model -DSIGMA=... console` hívásban, majd a
`jv_app_export.m` az IRF-eket ideiglenes CSV-be írja, amit az app
beolvas és kirajzol. A modell tehát a validált `.mod` — az app csak
vezérli, nincs párhuzamos modell-implementáció.

Állítható: σ, habit, Calvo ár/bér, Taylor φ_π, kamatsimítás,
exportkereslet-rugalmasság, beruházási kiigazítás, és a pénzügyi blokk
(χ_S, χ_L, lev_S, lev_L). Ha egy paraméter-készlet mellett sérül a
Blanchard–Kahn feltétel (indetermináció), az app hibaüzenetet ad — ez
maga is informatív a determináltsági határok feltérképezéséhez.
