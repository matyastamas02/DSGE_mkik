# -*- coding: utf-8 -*-
"""Az s_kkv paraméter empirikus megalapozása input-output adatból.

MIÉRT PYTHON (és nem MATLAB, a projekt-szabály ellenére): ez egy
JSON-API letöltő script, mint a 01–05 adat-előkészítők; a modellezés
maradt MATLAB-ban.

KÉRDÉS: mekkora a HAZAI köztes input aránya a magyar exportáló ágazatok
termelési értékén? Ez adja az `s_kkv` (a KKV-input költséghányada az
exportban) FELSŐ KORLÁTJÁT — az IO-tábla ágazati, nem méret szerinti
bontású, tehát a KKV-rész ennek csak egy része.

MÓDSZER (két Eurostat-forrás kombinálva):
  1. IO-táblák (naio_10_cp1620 hazai / cp1630 import): a köztes
     felhasználás hazai–import megoszlása ágazatonként.
  2. Nemzeti számlák (nama_10_a64): P1 output, P2 köztes felhasználás.
  => hazai köztes / output = (hazai / (hazai+import)) × (P2 / P1)

MEGJEGYZÉS: a KSH saját ÁKM-je (ksh.hu) lett volna az elsődleges forrás,
de a szerver nem volt elérhető; az Eurostat ugyanezt az adatot közli
(a KSH szolgáltatja be), tehát egyenértékű.

Kimenet: output/tables/t24_io_hazai_input.csv
Futtatás: python src/07_io_hazai_input_arany.py
"""

import json
import urllib.request
from collections import defaultdict
from pathlib import Path

import pandas as pd

REPO = Path(__file__).resolve().parents[1]
KI = REPO / "output" / "tables" / "t24_io_hazai_input.csv"
BASE = "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data"
EV = "2021"

AGAZATOK = [
    ("C29", "Autóipar"),
    ("C26", "Elektronika, számítástechnika"),
    ("C27", "Elektromos berendezés"),
    ("C28", "Gépgyártás"),
    ("C20", "Vegyipar"),
    ("C22", "Gumi, plasztik"),
    ("C25", "Fémfeldolgozás"),
    ("TOTAL", "Teljes gazdaság"),
]


def get(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=150) as r:
        return json.load(r)


def unpack(js: dict, want: list) -> dict:
    dims, sizes = js["id"], js["size"]
    cats = []
    for d in dims:
        ci = js["dimension"][d]["category"]["index"]
        inv = {v: k for k, v in ci.items()}
        cats.append([inv[i] for i in range(len(inv))])
    wi = [dims.index(d) for d in want]
    out = {}
    for pos, val in js["value"].items():
        p = int(pos)
        key = [None] * len(sizes)
        for i in range(len(sizes) - 1, -1, -1):
            key[i] = cats[i][p % sizes[i]]
            p //= sizes[i]
        out[tuple(key[i] for i in wi)] = val
    return out


def main() -> None:
    dom = unpack(get(f"{BASE}/naio_10_cp1620?geo=HU&time={EV}&unit=MIO_EUR"
                     f"&format=JSON&lang=EN"), ["ind_use", "cpa2_1"])
    imp = unpack(get(f"{BASE}/naio_10_cp1630?geo=HU&time={EV}&unit=MIO_EUR"
                     f"&format=JSON&lang=EN"), ["ind_use", "cpa2_1"])
    na = unpack(get(f"{BASE}/nama_10_a64?geo=HU&time={EV}&unit=CP_MEUR"
                    f"&na_item=P1&na_item=P2&format=JSON&lang=EN"),
                ["na_item", "nace_r2"])

    d_sum, i_sum = defaultdict(float), defaultdict(float)
    for (ind, _), v in dom.items():
        d_sum[ind] += v
    for (ind, _), v in imp.items():
        i_sum[ind] += v

    sorok = []
    for kod, nev in AGAZATOK:
        d, i = d_sum.get(kod), i_sum.get(kod)
        p1, p2 = na.get(("P1", kod)), na.get(("P2", kod))
        if not all((d, i, p1, p2)):
            continue
        hazai_arany = d / (d + i)
        p2p1 = p2 / p1
        s_felso = hazai_arany * p2p1
        sorok.append({
            "agazat_kod": kod, "agazat": nev,
            "hazai_koztes_MEUR": round(d), "import_koztes_MEUR": round(i),
            "hazai_arany_a_koztesben": round(hazai_arany, 4),
            "koztes_per_output": round(p2p1, 4),
            "hazai_koztes_per_output": round(s_felso, 4),
            "s_kkv_felso_korlat": round(s_felso, 4),
            "polus_alatt": s_felso < 0.25,
        })

    T = pd.DataFrame(sorok)
    KI.parent.mkdir(parents=True, exist_ok=True)
    T.to_csv(KI, index=False, encoding="utf-8-sig")

    print(f"\nHAZAI KÖZTES INPUT / OUTPUT — Magyarország, {EV} (Eurostat IO)")
    print("=" * 78)
    for _, r in T.iterrows():
        print(f"{r['agazat']:<30} hazai a köztesben: "
              f"{100*r['hazai_arany_a_koztesben']:>5.1f}%  →  "
              f"s_kkv felső korlát: {r['s_kkv_felso_korlat']:.3f}")
    print("=" * 78)
    exportmag = T[T["agazat_kod"].isin(["C29", "C26", "C27"])]
    print(f"\nAz EXPORT-MAG (autó, elektronika, elektromos berendezés) "
          f"átlaga: {exportmag['s_kkv_felso_korlat'].mean():.3f}")
    print("FIGYELEM: ez MINDEN cégméretre vonatkozik. Az s_kkv csak a")
    print("KKV-rész, tehát a tényleges érték ENNÉL KISEBB (kb. a fele).")
    print(f"\nKiírva: {KI}")


if __name__ == "__main__":
    main()
