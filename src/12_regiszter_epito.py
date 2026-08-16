"""12_regiszter_epito.py — EGYSZERI generátor: a prózában szétszórt
paraméter-információt átrakja adattáblába.

MIÉRT. A repóban 9 különböző fájl állítja magáról, hogy leírja a jelenlegi
állapotot, és mindegyik prózában, kézzel frissül. Ez a script a
`docs/kalibracio_tabla.md` A–E kategóriáit és a hozzájuk tartozó
forrás-információt EGYSZER átemeli `docs/regiszter/parameterek.csv`-be.

EZUTÁN A CSV A FORRÁS, NEM EZ A SCRIPT. Ha egy paraméter státusza változik,
a CSV-t kell szerkeszteni — ezt a scriptet nem kell újrafuttatni. (Ha mégis
lefuttatod, felülírja a kézi szerkesztéseket: ezért kér megerősítést.)

FONTOS TERVEZÉSI DÖNTÉS: a CSV **nem tartalmaz értéket**. Az érték a
modellből jön, futásidőben (`_params_dump.csv`), mert a kézzel átírt érték
pontosan az a hibaforrás, amit el akarunk kerülni. A CSV a *metaadatot*
tartja: kategória, forrás, státusz, kapcsoló, őr, doksi.

Futtatás:  python src/12_regiszter_epito.py --megerosit
"""

from __future__ import annotations

import pathlib
import sys

import pandas as pd

REPO = pathlib.Path(__file__).resolve().parent.parent
REG = REPO / "docs" / "regiszter"
KI = REG / "parameterek.csv"

# --- A kategóriák a docs/kalibracio_tabla.md-ből, szó szerint --------------
A = ("om_E om_D om_L phi_E phi_D phi_L lev_E lev_D lev_L "
     "shl_E shl_D shl_L delta rho_acc").split()
B = "sc si sg sx sm zeta_E zeta_D zeta_L aa_E aa_D aa_L".split()
C_JV = ("sigma habit xi_p vth_p xi_x vth_x xi_w vth_w mu_x hx gam_i phi_pi "
        "nu_b rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g").split()
C_STR = "fii theta_w rho_kz rho_z om_no".split()
C_BGG = "eps_qw omega_nw".split()
D = ("chi_E chi_D chi_L psi_E psi_D psi_L tsov_E tsov_D tsov_L "
     "tbank_E tbank_D tbank_L eps_ces lambda_acc_E lambda_acc_D "
     "omega_acc_E omega_acc_D s_kkv mu_vert zsov").split()
E = ("lam_p lam_x lam_w wd_E wd_D wd_L wx_E wx_D wx_L shm_E shm_D shm_L "
     "shd_c shd_i shd_g shd_v beta nu_uni").split()

KATEGORIA = {}
for n in A:     KATEGORIA[n] = ("A", "saját adat (Opten-panel)")
for n in B:     KATEGORIA[n] = ("B", "nyilvános magyar makroadat (KSH)")
for n in C_JV:  KATEGORIA[n] = ("C", "JV-becsült (MNB WP 2008/9 poszterior)")
for n in C_STR: KATEGORIA[n] = ("C", "JV-strukturális / survey")
for n in C_BGG: KATEGORIA[n] = ("C", "BGG (1999) konvenció")
for n in D:     KATEGORIA[n] = ("D", "nem azonosított / több adat kell")
for n in E:     KATEGORIA[n] = ("E", "származtatott vagy technikai")

# --- Státusz: mi HORGONYZOTT ma, és mi nem --------------------------------
# horgonyzott  = van rá hivatkozható forrás vagy saját becslés
# feltételes   = kiszámoltuk, de elfogadási feltétel van rajta
# horgonyzatlan= nincs forrás; a modellben szereplő érték feltevés
HORGONYZOTT = {
    # JV-becsült: magyar adaton Bayes-i poszterior átlag
    **{n: ("horgonyzott", "Jakab–Világi, MNB WP 2008/9, becsült poszterior átlag",
           "", "") for n in C_JV},
    **{n: ("horgonyzott", "Jakab–Világi, MNB WP 2008/9 (strukturális/survey)",
           "", "") for n in C_STR},
    **{n: ("horgonyzott", "Bernanke–Gertler–Gilchrist (1999) konvenció",
           "", "") for n in C_BGG},
    # 2026-08-16, Opten-panel
    "delta": ("horgonyzott",
              "Opten-panel 2021–24 (0,0242) ÉS Christensen–Dib (2008) 1. tábla (0,025)",
              "-DOPTEN", "t46: delta megerositi"),
    "phi_L": ("horgonyzott", "Opten-panel 2021–24 (0,3649)",
              "-DOPTEN", "t46: phi_L megerositi"),
    "lev_E": ("horgonyzott",
              "Opten-panel medián 1,939 (sáv 1,68–1,94); irodalom k/n=2 (C&D 2008 1. tábla)",
              "-DOPTEN", "t50: tokeattetel-sorrend"),
    "lev_D": ("horgonyzott", "Opten-panel medián 1,719 (sáv 1,58–1,72)",
              "-DOPTEN", "t50: tokeattetel-sorrend"),
    "lev_L": ("horgonyzott", "Opten-panel medián 2,337 (sáv 1,81–2,34)",
              "-DOPTEN", "t50: tokeattetel-sorrend"),
    "rho_acc": ("horgonyzott",
                "Opten-panel van_hitel átmenet-mátrix (0,9673) — ALSÓ KORLÁT",
                "-DOPTEN / -DRHOACC", "t49b: kuszob monoton a rho_acc-ban"),
    # feltételes: kiszámolva, de elfogadási feltétellel
    **{n: ("feltételes",
           "Opten-panel, de a 10+ fős körön BELÜLI részesedés — KSH/Eurostat SBS "
           "mikrokör-bontás kell az átskálázáshoz (teendők 2.5)",
           "-DOPTEN", "t46: sulyok 1-re osszegzodnek")
       for n in "om_E om_D om_L shl_E shl_D shl_L".split()},
    "phi_E": ("feltételes",
              "Opten-panel; a definíciótól függ (ALAP 0,376 vs KÜSZÖB25 0,691)",
              "-DOPTEN", "t46"),
    "phi_D": ("feltételes",
              "Opten-panel; az ALAP definícióban DEFINÍCIÓ SZERINT 0, nem mérés",
              "-DOPTEN", "t46"),
    # chi: 2026-08-16 megbecsülve, de nem azonosított
    "chi_E": ("horgonyzatlan",
              "Opten-panel: chi_S≈+0,002 (alsó korlát); irodalom 0,042–0,067 "
              "(C&D 2008; BGG-konvenció) — méret szerinti bontás NÉLKÜL",
              "", ""),
    "chi_D": ("horgonyzatlan",
              "Opten-panel: chi_S≈+0,002 (alsó korlát); irodalom 0,042–0,067",
              "", ""),
    "chi_L": ("horgonyzatlan",
              "NEM AZONOSÍTOTT: n=230, t=-0,78, rossz előjel (kalibracio_bgg_blokk.md)",
              "", ""),
}

KAPCSOLO_EXTRA = {
    "eps_ces": "-DEPSCES", "s_kkv": "-DSKKV", "mu_vert": "-DMUVERT",
    "nu_uni": "-DNUUNI",
    "lambda_acc_E": "-DACCSCALE", "lambda_acc_D": "-DACCSCALE",
    "omega_acc_E": "-DACCSCALE", "omega_acc_D": "-DACCSCALE",
}
DOKSI = {
    **{n: "kalibracio_bgg_blokk.md" for n in
       "lev_E lev_D lev_L chi_E chi_D chi_L".split()},
    **{n: "2026-08-16_opten_kalibracio_eredmeny.md" for n in
       ("om_E om_D om_L shl_E shl_D shl_L phi_E phi_D phi_L delta "
        "rho_acc").split()},
    **{n: "2026-08-12_access_horgonyzas_eredmeny.md" for n in
       "lambda_acc_E lambda_acc_D omega_acc_E omega_acc_D".split()},
    **{n: "FIGYELMEZTETES_io_tabla_gyanus.md" for n in "s_kkv mu_vert".split()},
    **{n: "FIGYELMEZTETES_fo_allitas.md" for n in
       "tsov_E tsov_D tsov_L tbank_E tbank_D tbank_L".split()},
}


def main() -> None:
    if "--megerosit" not in sys.argv:
        sys.exit(
            "Ez a script FELÜLÍRJA a docs/regiszter/parameterek.csv-t, benne\n"
            "minden kézi szerkesztéssel. A CSV a forrás, nem ez a script.\n"
            "Ha tényleg újra akarod építeni: python src/12_regiszter_epito.py --megerosit"
        )

    dump = REG / "_params_dump.csv"
    if not dump.exists():
        sys.exit(f"Hiányzik: {dump}\n"
                 "Előbb: matlab -batch \"cd('src/model'); "
                 "dynare('jv_dsge_v09_access', ...)\" (lásd a doksit)")

    nevek = pd.read_csv(dump)["parameter"].tolist()
    sorok = []
    for n in nevek:
        kat, katnev = KATEGORIA.get(n, ("?", "BESOROLATLAN"))
        st, forras, kapcs, orr = HORGONYZOTT.get(
            n, ("horgonyzatlan" if kat == "D" else
                ("származtatott" if kat == "E" else "pótolandó"), "", "", ""))
        if not forras and kat == "B":
            forras = "jelenleg JV-érték átvitele; KSH-ból pótolandó (teendők 2.4)"
        if not forras and kat == "D":
            forras = "nincs hivatkozható forrás"
        if not forras and kat == "E":
            forras = "más paraméterekből számolódik / technikai zárás"
        sorok.append({
            "parameter": n,
            "kategoria": kat,
            "kategoria_nev": katnev,
            "statusz": st,
            "forras": forras,
            "kapcsolo": kapcs or KAPCSOLO_EXTRA.get(n, ""),
            "or": orr,
            "doksi": DOKSI.get(n, ""),
        })

    df = pd.DataFrame(sorok)
    REG.mkdir(parents=True, exist_ok=True)
    df.to_csv(KI, index=False, encoding="utf-8")
    print(f"KIÍRVA: {KI}  ({len(df)} paraméter)")
    print(df.groupby(["kategoria", "statusz"]).size().to_string())


if __name__ == "__main__":
    main()
