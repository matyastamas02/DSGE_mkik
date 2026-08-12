# -*- coding: utf-8 -*-
"""DIAGNOSZTIKA: mi van valójában az Eurostat IO-tábla dimenzióiban?

MIÉRT KELL. A `10_io_matrix_letoltes.py` futása két gyanús számot adott:

    TOTAL hazai_koztes_per_output = 0,0578
    az a_sr mátrix spektrálsugara = 0,0381

Egy valódi IO-együtthatómátrix spektrálsugara tipikusan 0,3-0,6 körül van.
A 0,0578 azt állítaná, hogy a magyar köztes felhasználás ~90%-a import —
ez nem lehet igaz.

EZ NEM KALIBRÁCIÓS RÉSZLET. Ugyanez a mérés adja a `t24`-et és az
`s_kkv = 0,05` paramétert, amivel a 2026-08-02-i napló a vertikális link
hozzájárulását 42%-ról 4,4%-ra korrigálta. Ha a hazai arány alulmért, a
beszállítói link NAGYOBB, és a "az euró alig éri el a hazai orientációjú
KKV-t" következtetés gyengül.

NEGY GYANU, amit ez a script eldönt:
  (A) A dimenziók AGGREGÁTUMOKAT is tartalmaznak a részletek mellett
      (TOTAL, C10-12), tehát a naiv összegzés többszörösen számol.
  (B) A hazai tábla sorai között HOZZÁADOTT ÉRTÉK tételek is vannak
      (D1, B2A3G, D21X31), amelyek az import táblában nem léteznek.
  (C) Az "ágazat" dimenzióban VÉGSŐ FELHASZNÁLÁS oszlopok is vannak
      (P3, P51G, P6), amelyek nem ágazatok.
  (D) Kódformátum-eltérés a nemzeti számlákkal (C10-12 vs C10-C12) —
      a `10` script 119 ágazatból csak 53-hoz talált P1-et.

A DÖNTŐ TESZT: a köztes felhasználás hazai és import része össze kell
adódjon a nemzeti számlák P2-jére.
    dom_sum(ágazat) + imp_sum(ágazat)  ==  P2(ágazat)
Ha az összeg jóval NAGYOBB -> aggregátumokat is beleszámolunk.
Ha KISEBB -> sorok hiányoznak.

FUTTATÁS (a mentett JSON-okból, internet nem kell):
    python src/10b_io_diagnosztika.py
    python src/10b_io_diagnosztika.py --dir /utvonal/data/raw/io --ev 2021

MEGJEGYZÉS AZ ELŐZŐ FUTÁSHOZ: a `10` script a SAJÁT helyétől számítva két
szinttel feljebb hozza létre a `data/` mappát. Ha a scriptet nem a repo
`src/` mappájából futtattad, a JSON-ok máshova kerültek — a --dir
kapcsolóval megadhatod, hol vannak.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

import pandas as pd

REPO = Path(__file__).resolve().parents[1]

# Hozzáadott érték és kibocsátás tételek: ezek a hazai használati tábla
# SORAI között szerepelnek, de nem termékek. Az import táblában nincsenek.
VA_KODOK = {
    "D1", "D11", "D12", "D2", "D21", "D29", "D21X31", "D29X39", "D3", "D31",
    "D39", "B1G", "B2A3G", "B2N", "B3N", "P1", "P2", "TS_BP", "OP_RES",
    "D2X3", "D9", "K1", "TU", "TS",
}
# Végső felhasználás oszlopok az "ágazat" dimenzióban.
VEGSO_MINTA = re.compile(r"^(P3|P4|P5|P6|P7|TOTAL|TU|TFU|TS)")


def betolt(d: Path, nev: str) -> dict:
    f = d / nev
    if not f.exists():
        raise SystemExit(f"Hiányzik: {f}\nFuttasd előbb: 10_io_matrix_letoltes.py")
    return json.loads(f.read_text(encoding="utf-8"))


def dimnev(js: dict, jeloltek: list[str]) -> str:
    for j in jeloltek:
        if j in js["id"]:
            return j
    raise SystemExit(f"Nincs meg egyik dimenzió sem: {jeloltek} / {js['id']}")


def hosszu(js: dict, sor_dim: str, oszl_dim: str) -> pd.DataFrame:
    dims, meretek = js["id"], js["size"]
    kat = []
    for d in dims:
        idx = js["dimension"][d]["category"]["index"]
        inv = {v: k for k, v in idx.items()}
        kat.append([inv[i] for i in range(len(inv))])
    i_s, i_o = dims.index(sor_dim), dims.index(oszl_dim)
    sorok = []
    for poz, ert in js["value"].items():
        p = int(poz)
        kulcs = [None] * len(meretek)
        for i in range(len(meretek) - 1, -1, -1):
            kulcs[i] = kat[i][p % meretek[i]]
            p //= meretek[i]
        sorok.append((kulcs[i_s], kulcs[i_o], ert))
    return pd.DataFrame(sorok, columns=["sor", "oszlop", "ertek"])


def tisztit(s: pd.Series) -> pd.Series:
    return s.astype(str).str.replace("^CPA_", "", regex=True).str.strip()


def alkotoreszek(kod: str) -> list[str]:
    """Egy összevont kód lehetséges alkotóelemei. C10-12 -> C10, C11, C12."""
    m = re.match(r"^([A-Z])(\d+)-(?:[A-Z])?(\d+)$", kod)
    if m:
        b, a1, a2 = m.group(1), int(m.group(2)), int(m.group(3))
        if a2 >= a1:
            return [f"{b}{i:02d}" for i in range(a1, a2 + 1)]
    m = re.match(r"^([A-Z])(\d+)_(\d+)$", kod)      # C31_32 alak
    if m:
        return [f"{m.group(1)}{m.group(2)}", f"{m.group(1)}{m.group(3)}"]
    return []


def aggregatum_kodok(kodok: set[str]) -> set[str]:
    """ADATVEZÉRELT aggregátum-felismerés.

    FONTOS: A64 szinten a `C10-12` LEGITIM RÉSZLETKATEGÓRIA, nem aggregátum.
    Ezért nem a kód ALAKJA dönt, hanem az, hogy az alkotóelemei külön is
    szerepelnek-e ugyanabban a dimenzióban. Ha igen, összevonás -> kihagyandó.
    Ha nem, ez maga a részletszint -> megtartandó.
    """
    agg = {k for k in kodok if k == "TOTAL"}
    for k in kodok:
        reszek = alkotoreszek(k)
        if reszek and sum(1 for r in reszek if r in kodok) >= 2:
            agg.add(k)                       # az alkotóelemei is megvannak
        if re.fullmatch(r"[A-U]", k):        # egybetűs szekció
            if any(re.match(rf"^{k}\d", o) for o in kodok):
                agg.add(k)
    return agg


def nama_illesztes(kod: str, p1_index) -> str | None:
    """C10-12 <-> C10-C12 kódformátum-áthidalás."""
    if kod in p1_index:
        return kod
    m = re.match(r"^([A-Z])(\d+)-(\d+)$", kod)
    if m and f"{m.group(1)}{m.group(2)}-{m.group(1)}{m.group(3)}" in p1_index:
        return f"{m.group(1)}{m.group(2)}-{m.group(1)}{m.group(3)}"
    m = re.match(r"^([A-Z])(\d+)-([A-Z])(\d+)$", kod)
    if m and f"{m.group(1)}{m.group(2)}-{m.group(4)}" in p1_index:
        return f"{m.group(1)}{m.group(2)}-{m.group(4)}"
    return None


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=str(REPO / "data" / "raw" / "io"))
    ap.add_argument("--ev", default="2021")
    a = ap.parse_args()
    d, ev = Path(a.dir), a.ev

    js_dom = betolt(d, f"naio_10_cp1620_HU_{ev}.json")
    js_imp = betolt(d, f"naio_10_cp1630_HU_{ev}.json")
    js_na = betolt(d, f"nama_10_a64_HU_{ev}.json")

    tk = dimnev(js_dom, ["cpa2_1", "prod_na"])
    ag = dimnev(js_dom, ["ind_use", "induse", "nace_r2"])
    dom = hosszu(js_dom, tk, ag)
    imp = hosszu(js_imp, dimnev(js_imp, ["cpa2_1", "prod_na"]),
                 dimnev(js_imp, ["ind_use", "induse", "nace_r2"]))
    for x in (dom, imp):
        x["sor"] = tisztit(x["sor"])
        x["oszlop"] = tisztit(x["oszlop"])

    # =================================================================
    print("=" * 72)
    print("1. MI VAN A DIMENZIÓKBAN?")
    print("=" * 72)
    sorok_d = sorted(dom["sor"].unique())
    sorok_i = sorted(imp["sor"].unique())
    oszl = sorted(dom["oszlop"].unique())

    va_d = [s for s in sorok_d if s in VA_KODOK]
    agg_sor = aggregatum_kodok(set(sorok_d))
    agg_d = sorted(agg_sor)
    veg_o = [o for o in oszl if VEGSO_MINTA.match(o)]
    agg_oszl = aggregatum_kodok(set(oszl))
    agg_o = sorted(agg_oszl)

    print(f"SOROK (termék) — hazai: {len(sorok_d)}, import: {len(sorok_i)}")
    print(f"  ebből hozzáadott érték tétel (gyanú B): {len(va_d)} -> {va_d}")
    print(f"  ebből aggregátum (gyanú A): {len(agg_d)} -> {agg_d[:12]}")
    print(f"  csak a HAZAI táblában szereplő sorok: "
          f"{sorted(set(sorok_d) - set(sorok_i))}")
    print(f"\nOSZLOPOK (ágazat): {len(oszl)}")
    print(f"  ebből végső felhasználás (gyanú C): {len(veg_o)} -> {veg_o}")
    print(f"  ebből aggregátum (gyanú A): {len(agg_o)} -> {agg_o[:12]}")

    # =================================================================
    print("\n" + "=" * 72)
    print("2. A DÖNTŐ TESZT: dom + imp  ==  P2 ?")
    print("=" * 72)
    na = hosszu(js_na, "na_item", dimnev(js_na, ["nace_r2"]))
    na["oszlop"] = tisztit(na["oszlop"])
    p1 = na[na["sor"].eq("P1")].set_index("oszlop")["ertek"]
    p2 = na[na["sor"].eq("P2")].set_index("oszlop")["ertek"]

    # (i) naiv: minden sor, minden oszlop — ahogy a 07 és a 10 csinálja
    naiv_d = dom.groupby("oszlop")["ertek"].sum()
    naiv_i = imp.groupby("oszlop")["ertek"].sum()

    # (ii) szűrt: VA sorok és aggregátum sorok nélkül
    tiszta_sor = [s for s in sorok_d
                  if s not in VA_KODOK and s not in agg_sor]
    szurt_d = (dom[dom["sor"].isin(tiszta_sor)]
               .groupby("oszlop")["ertek"].sum())
    szurt_i = (imp[imp["sor"].isin(tiszta_sor)]
               .groupby("oszlop")["ertek"].sum())

    sorok = []
    for kod in ["C29", "C26", "C20", "TOTAL"]:
        nk = nama_illesztes(kod, p2.index)
        sorok.append({
            "agazat": kod,
            "P2_nemzeti_szamlak": round(p2.get(nk, float("nan")), 1),
            "naiv_dom+imp": round(naiv_d.get(kod, 0) + naiv_i.get(kod, 0), 1),
            "szurt_dom+imp": round(szurt_d.get(kod, 0) + szurt_i.get(kod, 0), 1),
        })
    R = pd.DataFrame(sorok)
    R["naiv/P2"] = (R["naiv_dom+imp"] / R["P2_nemzeti_szamlak"]).round(3)
    R["szurt/P2"] = (R["szurt_dom+imp"] / R["P2_nemzeti_szamlak"]).round(3)
    print(R.to_string(index=False))
    print("\nÉRTELMEZÉS: az arány ~1,00 a helyes szűrés. Ha >>1, aggregátumokat")
    print("is összeadunk (gyanú A/B). Ha <<1, sorok hiányoznak.")

    # =================================================================
    print("\n" + "=" * 72)
    print("3. A HAZAI ARÁNY A KÉT SZŰRÉSSEL — ez dönti el a t24 sorsát")
    print("=" * 72)
    sorok = []
    for kod, nev in [("C29", "Autóipar"), ("C26", "Elektronika"),
                     ("C27", "Elektromos ber."), ("C20", "Vegyipar"),
                     ("TOTAL", "Teljes gazdaság")]:
        nd, ni = naiv_d.get(kod, 0), naiv_i.get(kod, 0)
        sd, si = szurt_d.get(kod, 0), szurt_i.get(kod, 0)
        nk = nama_illesztes(kod, p1.index)
        p2p1 = (p2.get(nk, float("nan")) / p1.get(nk, float("nan"))
                if nk else float("nan"))
        sorok.append({
            "agazat": nev,
            "hazai_arany_NAIV": round(nd / (nd + ni), 4) if nd + ni else None,
            "hazai_arany_SZURT": round(sd / (sd + si), 4) if sd + si else None,
            "koztes/output": round(p2p1, 4),
            "s_felso_NAIV": round(nd / (nd + ni) * p2p1, 4) if nd + ni else None,
            "s_felso_SZURT": round(sd / (sd + si) * p2p1, 4) if sd + si else None,
        })
    S = pd.DataFrame(sorok)
    print(S.to_string(index=False))
    print("\nA t24 a NAIV oszlopot közli (autóipar 0,0596 / 0,0504).")
    print("Ha a SZURT érdemben eltér, a t24-et és az s_kkv-t felül kell vizsgálni.")

    # =================================================================
    print("\n" + "=" * 72)
    print("4. KÓDILLESZTÉS A NEMZETI SZÁMLÁKKAL (gyanú D)")
    print("=" * 72)
    valodi_ag = [o for o in oszl
                 if not VEGSO_MINTA.match(o) and o not in agg_oszl]
    talalt = sum(1 for k in valodi_ag if nama_illesztes(k, p1.index))
    print(f"Valódi (nem aggregált, nem végső) ágazat: {len(valodi_ag)}")
    print(f"  ebből P1-et találunk: {talalt}")
    hiany = [k for k in valodi_ag if not nama_illesztes(k, p1.index)]
    if hiany:
        print(f"  NEM illeszkedik: {hiany}")
    print(f"\nP1-ben szereplő kódok mintája: {sorted(p1.index)[:15]}")

    print("\n" + "=" * 72)
    print("KÖVETKEZTETÉS: a 2. blokk 'szurt/P2' aránya dönt. Ha az ~1,00 és a")
    print("naiv >>1, akkor a t24 többszörösen számol, és a hazai arány — vele")
    print("az s_kkv és a vertikális link hozzájárulása — újraszámolandó.")
    print("=" * 72)


if __name__ == "__main__":
    main()
