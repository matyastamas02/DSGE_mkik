"""15_output_index.py — az output/ tartalomjegyzékének generálása.

MIÉRT. A `output/tables/` szándékosan **lapos** maradt a 2026-08-16-i
átrendezéskor: 66 tábla egy mappában, mert a szétvágás ~90 őrt és ~15
scriptet írt volna át, cserébe a `t35` attól még `t35` maradt volna. A
navigálhatóságot **index** oldja meg, nem mappa — ugyanaz a logika, mint az
`ALLAPOT.md`-nél.

MIT VÁLASZOL MEG minden táblára és ábrára:
  - MELYIK SCRIPT írja (tehát hogyan reprodukálható)
  - MELYIK MODELL-VONALHOZ tartozik
  - MELYIK ÁLLÍTÁST támasztja alá (a regiszterből)
  - VAN-E RAJTA ŐR a füsttesztben

ÉS AUDITÁL IS. Három bajt jelez, amit egy kézzel írt index elrejtene:
  (1) ÁRVA: nincs script, ami előállítaná -> nem reprodukálható, pedig a
      repo szabálya szerint az `output/` minden eleme kódból jön
  (2) NÉMA: se állítás nem hivatkozik rá, se őr nem védi -> vagy felesleges,
      vagy hiányzik róla egy állítás
  (3) HIÁNYZÓ: egy script olyan táblát ír, ami nincs a lemezen -> a script
      régen futott utoljára

Futtatás:  python src/4_infra/15_output_index.py
"""

from __future__ import annotations

import pathlib
import re
import subprocess

import pandas as pd

REPO = next(p for p in pathlib.Path(__file__).resolve().parents
            if (p / "CLAUDE.md").exists())
KI = REPO / "output" / "INDEX.md"

SZEREP = {
    "hordoz": "**állítást hordoz**",
    "racs": "részletes rács (az összegzője őrzött)",
    "hatter": "leíró háttér",
    "mellek": "referencia/archív vonal",
    "abra": "ábra (az állítás a tábláján ül)",
    "hiany": "⚠ **hiányzik az állítás**",
    "visszavont": "leíró diagnosztika; **az A11 visszavont**",
}

VONAL_NEV = {
    "1_fo_vonal_jv": "🟢 fő vonal (JV)",
    "2_referencia_eagle": "🟡 referencia (EAGLE)",
    "3_archiv_korai_jv": "⚪ archív (korai JV)",
    "4_app": "🟡 app",
    "1_adat": "adat-előkészítés",
    "2_empirikus": "empirikus elemzés",
    "3_abrak": "ábrageneráló",
    "4_infra": "infrastruktúra",
}


def vonal_of(rel: str) -> str:
    reszek = rel.split("/")
    for r in reszek:
        if r in VONAL_NEV:
            return VONAL_NEV[r]
    return "—"


def git(*a: str) -> str:
    try:
        return subprocess.run(["git", *a], cwd=REPO, capture_output=True,
                              text=True, timeout=20).stdout.strip()
    except Exception:
        return "?"


def main() -> None:
    src_fajlok = [f for f in (REPO / "src").rglob("*")
                  if f.suffix in (".m", ".py") and "15_output_index" not in f.name]
    forras = {f: f.read_text(encoding="utf-8", errors="surrogateescape")
              for f in src_fajlok}

    All = pd.read_csv(REPO / "docs" / "regiszter" / "allitasok.csv")
    orok_f = REPO / "output" / "tables" / "t00_orok.csv"
    orok = pd.read_csv(orok_f)["or"].tolist() if orok_f.exists() else []

    def elemzo(nev: str, azon: str):
        """Ki irja, melyik allitas hivatkozik ra, van-e or rajta."""
        irok = [f.relative_to(REPO).as_posix() for f, sz in forras.items()
                if nev in sz]
        # a sajat maga altal irt indexet ne szamoljuk
        irok = [i for i in irok if not i.endswith("15_output_index.py")]
        minta = re.compile(rf"\b{re.escape(azon)}\b")
        allitasok = [r["id"] for _, r in All.iterrows()
                     if isinstance(r.get("bizonyitek"), str)
                     and minta.search(r["bizonyitek"])]
        oreok = [o for o in orok if str(o).startswith(azon + ":")
                 or str(o).startswith(azon + " ")]
        return irok, allitasok, oreok

    def azonosito(nev: str) -> str:
        m = re.match(r"^(t\d+[a-z]?|f\d+)", nev)
        return m.group(1) if m else pathlib.Path(nev).stem

    def van_or(azon: str) -> bool:
        return any(str(o).startswith(azon + ":") or str(o).startswith(azon + " ")
                   for o in orok)

    def besorol(x) -> str:
        """Ha nincs allitas ES nincs or, MIERT nincs? Negy nagyon kulonbozo
        eset keveredik, es csak az egyik valodi hianyossag."""
        if x["azon"] == "t46c":
            return "visszavont"
        if x["allitasok"] or x["orok"]:
            return "hordoz"
        # az ABRA nem onallo allitashordozo, hanem egy tabla vizualizacioja --
        # az allitas a tablan ul, nem a png-n
        if x["mappa"] == "figures":
            return "abra"
        # (a) reszletes racs, aminek az OSSZEGZOJEN van or (t45 -> t45b stb.)
        alap = x["azon"].rstrip("b")
        if van_or(x["azon"] + "b") or (alap != x["azon"] and van_or(alap)):
            return "racs"
        # (b) leiro/hatter: adat-elokeszitesbol vagy leiro statisztikabol jon
        if any("1_adat" in i or "02_leiro_stat" in i for i in x["irok"]):
            return "hatter"
        # (c) referencia- vagy archiv-vonal eredmenye: nem el allitas rajta
        if any("2_referencia_eagle" in i or "3_archiv_korai_jv" in i
               for i in x["irok"]):
            return "mellek"
        return "hiany"

    sorok, arvak = [], []
    for mappa, mintazat in [("tables", "*.csv"), ("figures", "*.png")]:
        d = REPO / "output" / mappa
        if not d.is_dir():
            continue
        for f in sorted(d.glob(mintazat)):
            azon = azonosito(f.name)
            irok, allitasok, oreok = elemzo(f.name, azon)
            x = {"mappa": mappa, "fajl": f.name, "azon": azon,
                 "irok": irok, "allitasok": allitasok, "orok": oreok}
            x["besorolas"] = besorol(x)
            sorok.append(x)
            if not irok:
                arvak.append(f"output/{mappa}/{f.name}")
    nemak = [f"output/{x['mappa']}/{x['fajl']}" for x in sorok
             if x["mappa"] == "tables" and x["besorolas"] == "hiany"]

    # (3) script olyan tablat ir, ami nincs a lemezen?
    letezo = {s["fajl"] for s in sorok}
    hianyzo = set()
    for f, sz in forras.items():
        for nev in re.findall(r"'(t\d+[a-z]?_[a-z_0-9]+\.csv)'", sz):
            if nev not in letezo:
                hianyzo.add(f"{nev}  (írná: {f.relative_to(REPO).as_posix()})")

    s: list[str] = []
    w = s.append
    w("<!-- GENERÁLT FÁJL — NE SZERKESZD. Újragenerálás:")
    w("       python src/4_infra/15_output_index.py                        -->")
    w("")
    w("# output/ — tartalomjegyzék")
    w("")
    w(f"*Generálva · commit `{git('rev-parse', '--short', 'HEAD')}`*")
    w("")
    w("A `output/tables/` szándékosan **lapos**: a szétvágás ~90 őrt és ~15 "
      "scriptet írt volna át, cserébe a `t35` attól még `t35` maradt volna. "
      "A navigálhatóságot ez az index adja.")
    w("")
    t_db = sum(1 for x in sorok if x["mappa"] == "tables")
    f_db = sum(1 for x in sorok if x["mappa"] == "figures")
    w(f"**{t_db} tábla · {f_db} ábra.**")
    w("")

    if arvak or nemak or hianyzo:
        w("## ⚠ Audit")
        w("")
        if arvak:
            w(f"**ÁRVA — nincs script, ami előállítaná ({len(arvak)}):** a repo "
              "szabálya szerint az `output/` minden eleme kódból reprodukálható "
              "kell legyen. Ezek nem azok.")
            w("")
            for a in arvak:
                w(f"- `{a}`")
            w("")
        if nemak:
            w(f"**HIÁNYZÓ ÁLLÍTÁS ({len(nemak)}):** élő vonalon keletkezett "
              "eredmény, amihez se állítás, se őr nem tartozik. Vagy kap egy "
              "sort az állítás-regiszterben, vagy törlendő.")
            w("")
            for n in nemak:
                w(f"- `{n}`")
            w("")
        if hianyzo:
            w(f"**HIÁNYZÓ — script írná, de nincs a lemezen ({len(hianyzo)}):** "
              "a script régen futott utoljára.")
            w("")
            for h in sorted(hianyzo):
                w(f"- `{h}`")
            w("")
    else:
        w("✅ **Minden kimenet reprodukálható, és mindegyikhez tartozik "
          "állítás vagy őr.**")
        w("")

    for mappa, cim in [("tables", "Táblák"), ("figures", "Ábrák")]:
        reszek = [x for x in sorok if x["mappa"] == mappa]
        if not reszek:
            continue
        w("---")
        w("")
        w(f"## {cim}")
        w("")
        w("| Fájl | Előállítja | Vonal | Állítás | Őr | Szerep |")
        w("|---|---|---|---|---|---|")
        for x in reszek:
            iro = "<br>".join(f"`{i}`" for i in x["irok"]) or "**⚠ árva**"
            vonal = vonal_of(x["irok"][0]) if x["irok"] else "—"
            allit = " · ".join(x["allitasok"]) or "—"
            orr = f"✅ {len(x['orok'])} db" if x["orok"] else "—"
            w(f"| `{x['fajl']}` | {iro} | {vonal} | {allit} | {orr} | "
              f"{SZEREP[x['besorolas']]} |")
        w("")

    KI.write_text("\n".join(s), encoding="utf-8")
    print(f"KIÍRVA: {KI}")
    print(f"  {t_db} tábla, {f_db} ábra")
    print(f"  árva: {len(arvak)}  néma: {len(nemak)}  hiányzó: {len(hianyzo)}")
    for cim, lista in [("ÁRVA", arvak), ("NÉMA", nemak),
                       ("HIÁNYZÓ", sorted(hianyzo))]:
        for x in lista[:8]:
            print(f"   {cim}: {x}")


if __name__ == "__main__":
    main()
