"""14_utvonal_atiro.py — EGYSZERI atiro a 2026-08-16-i repo-atrendezeshez.

MIT CSINAL. A scriptek eddig a MUNKAKONYVTARBOL szamoltak a repo gyokeret
(`repo = fileparts(pwd)`, `Path(__file__).parents[1]`), ami feltetelezte,
hogy pontosan hany szint melyen vannak. Az atrendezes ezt eltorte volna.

Helyette mindenhol ugyanaz: a script a SAJAT HELYEBOL indul, es felfele
megy, amig meg nem talalja a CLAUDE.md-t. Ez tetszoleges melysegben
mukodik, tehat egy jovobeli athelyezes sem tori el.

A modell-futtatok emellett `cd`-t is kapnak a .mod fajlok mappajaba, mert
a Dynare a munkakonyvtarhoz kepest keresi a modellt.

EGYSZERI SCRIPT. Lefutott 2026-08-16-an; utana a forras a javitott fajl.
Azert marad a repoban, hogy az atrendezes reprodukalhato legyen.

Futtatas: python src/4_infra/14_utvonal_atiro.py --megerosit
"""

from __future__ import annotations

import pathlib
import re
import sys

REPO = next(p for p in pathlib.Path(__file__).resolve().parents
            if (p / "CLAUDE.md").exists())
SRC = REPO / "src"

M_WALK = ("repo = fileparts(mfilename('fullpath'));\n"
          "while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end")

M_FEJLEC = """% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
"""

# A ket kondicionalis repo-logikaju script kezzel keszul (if/else agakkal),
# a run_jv_v06 pedig KET mappabol hasznal .mod-ot -- ezeket kihagyjuk.
KIHAGY = {"run_v06_3type.m", "run_v07_access.m", "run_jv_v06.m"}

PY_WALK = ('REPO = next(p for p in {mod}Path(__file__).resolve().parents\n'
           '            if (p / "CLAUDE.md").exists())')


def atir_matlab(f: pathlib.Path, futtato: bool) -> str | None:
    sz = f.read_text(encoding="utf-8", errors="surrogateescape")
    eredeti = sz

    # 1. a ketsoros feltételes valtozat (s14, s15)
    sz = re.sub(r"repo = fileparts\(pwd\);\s*\n"
                r"if ~endsWith\(pwd, 'src'\), repo = pwd; end",
                M_WALK, sz)
    # 2. az egysoros valtozatok
    sz = sz.replace("repo = fileparts(fileparts(pwd));", M_WALK)
    sz = sz.replace("repo = fileparts(pwd);", M_WALK)
    sz = sz.replace("repo = fileparts(fileparts(mfilename('fullpath')));", M_WALK)

    if futtato:
        # a fejlec a vezeto kommentblokk UTAN megy, az elso erdemi sor ele
        sorok = sz.split("\n")
        i = 0
        while i < len(sorok) and (sorok[i].startswith("%") or not sorok[i].strip()):
            i += 1
        sorok.insert(i, M_FEJLEC)
        sz = "\n".join(sorok)
        # a fejlec mar beallitotta a repo-t: a kesobbi szamitas felesleges
        sz = sz.replace(M_WALK, "% [a repo-t a fejlec mar beallitotta]")

    if sz == eredeti:
        return None
    f.write_text(sz, encoding="utf-8", errors="surrogateescape")
    return f.relative_to(REPO).as_posix()


def atir_python(f: pathlib.Path) -> str | None:
    sz = f.read_text(encoding="utf-8")
    eredeti = sz
    mod = "pathlib." if "pathlib.Path(__file__)" in sz else ""
    sz = re.sub(r"REPO = (?:pathlib\.)?Path\(__file__\)\.resolve\(\)"
                r"\.(?:parents\[\d+\]|parent\.parent(?:\.parent)?)",
                PY_WALK.format(mod=mod), sz)
    if sz == eredeti:
        return None
    f.write_text(sz, encoding="utf-8")
    return f.relative_to(REPO).as_posix()


def main() -> None:
    if "--megerosit" not in sys.argv:
        sys.exit("Ez a script FELULIRJA a forrasfajlokat. "
                 "Futtatas: python src/4_infra/14_utvonal_atiro.py --megerosit")

    valtozott = []
    for f in sorted(SRC.rglob("*.m")):
        if f.name in KIHAGY:
            continue
        futtato = f.parent.name == "futtato"
        r = atir_matlab(f, futtato)
        if r:
            valtozott.append(r)
    for f in sorted(SRC.rglob("*.py")):
        if f.name.startswith("14_"):
            continue
        r = atir_python(f)
        if r:
            valtozott.append(r)

    print(f"ATIRVA: {len(valtozott)} fajl")
    for r in valtozott:
        print("  ", r)
    print("\nKEZZEL kell javitani (kondicionalis vagy ket-mappas logika):")
    for n in sorted(KIHAGY):
        print("  ", n)


if __name__ == "__main__":
    main()
