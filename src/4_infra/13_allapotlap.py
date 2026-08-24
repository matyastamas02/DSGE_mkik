"""13_allapotlap.py — az EGYETLEN állapotlap generálása.

MIÉRT. A repóban kilenc különböző fájl állította magáról, hogy leírja a
jelenlegi állapotot, mind prózában, mind kézzel frissítve. Ez a script
egyetlen, GENERÁLT oldalt állít elő három adatforrásból:

    docs/regiszter/allitasok.csv   — mit állítunk, mi a státusza, mi védi
    docs/regiszter/parameterek.csv — a 91 paraméter metaadata
    output/tables/t00_orok.csv     — a füstteszt őreinek eredménye
    docs/regiszter/_params_dump.csv— a paraméterek ÉLŐ értéke a modellből

A lap nem írható kézzel, tehát nem tud elcsúszni.

NEM CSAK RIPORT — ELLENŐRIZ IS. Három konzisztencia-hibát fog el:
  (1) egy állítás olyan őrre hivatkozik, ami nem létezik  -> a szöveg elavult
  (2) egy "áll" állításnak nincs őre                      -> nincs mi védje
  (3) egy őr megbukott                                    -> az állítás dől

Futtatás:  python src/4_infra/13_allapotlap.py
Előtte:    matlab -batch "cd('src/4_infra'); smoke_test"   (ez írja a t00-t)
"""

from __future__ import annotations

import pathlib
import subprocess
import sys

import pandas as pd

REPO = next(p for p in pathlib.Path(__file__).resolve().parents
            if (p / "CLAUDE.md").exists())
REG = REPO / "docs" / "regiszter"
KI = REPO / "ALLAPOT.md"

JELOLES = {"áll": "🟢", "feltételes": "🟡", "VISSZAVONT": "🔴"}
STAT_JEL = {"horgonyzott": "🟢", "feltételes": "🟡", "horgonyzatlan": "🔴",
            "pótolandó": "🟡", "származtatott": "⚪"}


def git(*args: str) -> str:
    try:
        return subprocess.run(["git", *args], cwd=REPO, capture_output=True,
                              text=True, timeout=20).stdout.strip()
    except Exception:
        return "?"


def _doksi_link(nev: str) -> str:
    """Egy doksi-fajlnevbol markdown link. A fajlok a docs/ ALMAPPAIBAN
    vannak (figyelmeztetesek/, eredmenyek/, terv/, modszertan/), ezert a
    valodi utvonalat megkeressuk; ha nincs meg, a puszta nevet adjuk vissza
    link nelkul, hogy ne kepzodjon torott hivatkozas."""
    talalt = list((REPO / "docs").rglob(nev))
    if not talalt:
        return nev
    return f"[{nev}]({talalt[0].relative_to(REPO).as_posix()})"


def main() -> None:
    hianyzo = [p for p in [REG / "allitasok.csv", REG / "parameterek.csv",
                           REPO / "output" / "tables" / "t00_orok.csv",
                           REG / "_params_dump.csv"] if not p.exists()]
    if hianyzo:
        sys.exit("Hiányzó bemenet:\n  " + "\n  ".join(map(str, hianyzo)) +
                 "\n\nA t00-hoz futtasd: matlab -batch \"cd('src/4_infra'); smoke_test\"")

    All = pd.read_csv(REG / "allitasok.csv")
    Par = pd.read_csv(REG / "parameterek.csv")
    Orr = pd.read_csv(REPO / "output" / "tables" / "t00_orok.csv")
    Ert = pd.read_csv(REG / "_params_dump.csv")

    orok = dict(zip(Orr["or"], Ert.index if False else Orr["rendben"]))
    futas_ido = str(Orr["idopont"].iloc[0]) if len(Orr) else "?"

    def or_statusz(nev: str):
        """Az őr azonosítása a nevének SZAVAIVAL, részsorozat-illesztéssel.

        Miért nem prefix vagy pontos egyezés: a füstteszt üzeneteibe bele van
        írva az aktuális szám (pl. „t46: delta = 0.0242 megerositi…”), ami
        futásonként változhat. Ezért a CSV-ben a rövid, stabil szórészletet
        tartjuk, és azt keressük RÉSZSOROZATKÉNT az őr nevében. Így a szám
        beszúrása nem töri el a hivatkozást, de elgépelés igen — ami pont a
        kívánt viselkedés.
        """
        if not isinstance(nev, str) or not nev.strip():
            return None, None
        keresett = nev.lower().split()
        talalatok = []
        for k, v in orok.items():
            szavak = str(k).lower().split()
            i = 0
            for sz in szavak:
                if i < len(keresett) and keresett[i] == sz:
                    i += 1
            if i == len(keresett):
                talalatok.append((k, int(v)))
        if len(talalatok) == 1:
            return talalatok[0]
        if len(talalatok) > 1:          # kétértelmű: a legrövidebb a jó
            return min(talalatok, key=lambda t: len(t[0]))
        return None, None

    # --- KONZISZTENCIA-ELLENŐRZÉS -------------------------------------
    gondok = []
    for _, r in All.iterrows():
        nev = r.get("or", "")
        talalt, rendben = or_statusz(nev)
        if isinstance(nev, str) and nev.strip() and talalt is None:
            gondok.append(f"**{r['id']}** — nem létező őrre hivatkozik: "
                          f"`{nev}`. Vagy az őr tűnt el, vagy a szöveg elavult.")
        elif talalt and rendben == 0:
            gondok.append(f"**{r['id']}** — az őre MEGBUKOTT: `{talalt}`. "
                          f"Az állítás nem áll.")
        if r["statusz"] == "áll" and (not isinstance(nev, str) or not nev.strip()):
            gondok.append(f"**{r['id']}** — „áll” státuszú állítás ŐR NÉLKÜL. "
                          f"Vagy őrt kap, vagy „feltételes”-re kell tenni.")
    bukott = Orr[Orr["rendben"] == 0]

    # --- ÍRÁS ----------------------------------------------------------
    s = []
    w = s.append
    w("<!-- GENERÁLT FÁJL — NE SZERKESZD. Forrás: docs/regiszter/*.csv +")
    w("     output/tables/t00_orok.csv. Újragenerálás:")
    w("       matlab -batch \"cd('src/4_infra'); smoke_test\"")
    w("       python src/4_infra/13_allapotlap.py                                -->")
    w("")
    w("# DSGE_mkik — állapotlap")
    w("")
    w(f"*Generálva a füstteszt {futas_ido}-kor futott eredményéből · "
      f"commit `{git('rev-parse', '--short', 'HEAD')}` · "
      f"ág `{git('rev-parse', '--abbrev-ref', 'HEAD')}`*")
    w("")
    w("**Fő modell:** `src/modell/1_fo_vonal_jv/jv_dsge_v09_access.mod` (Jakab–Világi mag). "
      "A `kkv_dsge_*` a referencia-vonal.")
    w("")
    w(f"**Őrök:** {int((Orr['rendben'] == 1).sum())} rendben, "
      f"{int((Orr['rendben'] == 0).sum())} hiba.")
    w("")

    if gondok or len(bukott):
        w("## ⚠ FIGYELMEZTETÉS — a regiszter és az őrök nincsenek szinkronban")
        w("")
        for g in gondok:
            w(f"- {g}")
        for _, b in bukott.iterrows():
            w(f"- MEGBUKOTT ŐR: `{b['or']}`")
        w("")
    else:
        w("✅ **Minden „áll” állításnak van őre, és minden őr fut.**")
        w("")

    # --- ÁLLÍTÁSOK -----------------------------------------------------
    w("---")
    w("")
    w("## Mit állítunk ma")
    w("")
    cimek = {
        "áll": ("🟢 Ami ÁLL", "Ezekre lehet építeni a tanulmányban."),
        "feltételes": ("🟡 Ami FELTÉTELES",
                       "Csak a feltétellel együtt közölhető — küszöbformában, "
                       "vagy az elfogadási feltétel kiírásával."),
        "VISSZAVONT": ("🔴 Amit VISSZAVONTUNK",
                       "Ezek **nem** kerülhetnek vissza a szövegbe. A dátum és "
                       "az ok azért van itt, hogy ne kelljen újra levezetni."),
    }
    for st, (cim, alcim) in cimek.items():
        reszek = All[All["statusz"] == st]
        w(f"### {cim} — {len(reszek)} db")
        w("")
        w(f"*{alcim}*")
        w("")
        for _, r in reszek.iterrows():
            talalt, rendben = or_statusz(r.get("or", ""))
            if talalt is None:
                orjel = "— *nincs őr*" if st != "VISSZAVONT" else ""
            else:
                orjel = f"— őr: {'✅' if rendben else '❌'} `{talalt}`"
            w(f"**{r['id']}.** {r['allitas']}")
            w("")
            biz = r.get("bizonyitek", "")
            biz = f"bizonyíték: `{biz}`" if isinstance(biz, str) and biz else ""
            kapcsolat = " — " if biz and orjel else ""
            if biz or orjel:
                w(f"> {biz}{kapcsolat}{orjel}")
            w(f"> *{r['datum']} · {r['megjegyzes']}*")
            w("")

    # --- PARAMÉTEREK ---------------------------------------------------
    P = Par.merge(Ert, on="parameter", how="left")
    w("---")
    w("")
    w("## A 91 paraméter")
    w("")
    osszeg = P.groupby("statusz").size().sort_values(ascending=False)
    w("| Státusz | db |")
    w("|---|---:|")
    for k, v in osszeg.items():
        w(f"| {STAT_JEL.get(k, '')} {k} | {v} |")
    w("")
    w("*Az **érték** oszlop a modellből jön futásidőben "
      "(`-DOPTEN=0` ág), nem a CSV-ből — kézzel átírt érték nem tud "
      "becsúszni.*")
    w("")
    for kat in sorted(P["kategoria"].unique()):
        resz = P[P["kategoria"] == kat]
        w(f"### {kat}. {resz['kategoria_nev'].iloc[0]} — {len(resz)} db")
        w("")
        w("| Paraméter | Érték | Státusz | Forrás | Kapcsoló | Doksi |")
        w("|---|---:|---|---|---|---|")
        for _, r in resz.iterrows():
            e = r.get("ertek_OPTEN0")
            e = "—" if pd.isna(e) else f"{e:g}"
            f_ = r["forras"] if isinstance(r["forras"], str) else ""
            k_ = r["kapcsolo"] if isinstance(r["kapcsolo"], str) else ""
            d_ = r["doksi"] if isinstance(r["doksi"], str) else ""
            # A doksi mezo TOBB fajlnevet is tarthat, `; `-vel elvalasztva
            # (2026-08-24 ota van ilyen). Korabban a generator egyetlen
            # sztringkent linkelte, amitol `[a; b](docs/a; b)` lett -- torott
            # link. Emellett a fajlok almappakban vannak (figyelmeztetesek/,
            # eredmenyek/, terv/), ezert a valodi utvonalat megkeressuk.
            d_ = " · ".join(_doksi_link(x.strip()) for x in d_.split(";") if x.strip())
            w(f"| `{r['parameter']}` | {e} | {STAT_JEL.get(r['statusz'], '')} "
              f"{r['statusz']} | {f_} | {k_} | {d_} |")
        w("")

    # --- ŐRÖK ----------------------------------------------------------
    w("---")
    w("")
    w(f"## Őrök ({len(Orr)} db)")
    w("")
    w("*A füstteszt minden ellenőrzése. Ez a projekt egyetlen olyan "
      "nyilvántartása, ami nem tud némán elcsúszni: ha egy állítás megdől, "
      "itt megbukik egy sor.*")
    w("")
    w("<details><summary>Teljes lista</summary>")
    w("")
    for _, r in Orr.iterrows():
        w(f"- {'✅' if r['rendben'] else '❌'} {r['or']}")
    w("")
    w("</details>")
    w("")

    KI.write_text("\n".join(s), encoding="utf-8")
    print(f"KIÍRVA: {KI}")
    print(f"  állítások: {len(All)}  (áll {sum(All.statusz=='áll')}, "
          f"feltételes {sum(All.statusz=='feltételes')}, "
          f"visszavont {sum(All.statusz=='VISSZAVONT')})")
    print(f"  paraméterek: {len(P)}   őrök: {len(Orr)}")
    if gondok:
        print(f"\n  ⚠ {len(gondok)} konzisztencia-gond, lásd a lap tetején:")
        for g in gondok:
            print("   -", g.replace("**", ""))


if __name__ == "__main__":
    main()
