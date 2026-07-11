# -*- coding: utf-8 -*-
"""Opten nyers xlsx -> egységes, tisztított cég-év panel.

Bemenet:  data/raw/opten.xlsx          (lásd data-index.md)
Kimenet:  data/processed/opten_panel.csv

Futtatás a repo gyökeréből:  python src/01_opten_panel_tisztitas.py

Fő lépések:
  1. Beszámolók lap -> kulcs pénzügyi mezők kiválasztása, numerikus tisztítás
  2. Alap lista -> statikus cégjellemzők (méret, ágazat, régió, tulajdon)
  3. Kockázati besorolás idősor -> évenkénti merge (az AVG külön kategória,
     jelentése a szállítónál tisztázandó — lásd data-index.md)
  4. EU-támogatás és közbeszerzés -> cégszintű jelzők
  5. Származtatott változók: implicit kamatráta, hitelhozzáférés (extenzív
     margó), exportarány, tőkeáttétel, méretkategória, NUTS-2 régió
  6. QC: lefedettségi statisztikák az adathelyzet-jelentés számaival szemben
"""

from pathlib import Path

import numpy as np
import pandas as pd

REPO = Path(__file__).resolve().parents[1]
RAW = REPO / "data" / "raw" / "opten.xlsx"
OUT = REPO / "data" / "processed" / "opten_panel.csv"
IRSZ_HNK = REPO / "data" / "raw" / "makro" / "irsz_hnk.csv"

# vármegye -> NUTS-2 (a hivatalos irsz->vármegye térképhez, lásd lent)
MEGYE_NUTS2 = {
    "főváros": "HU11", "Pest": "HU12",
    "Fejér": "HU21", "Komárom-Esztergom": "HU21", "Veszprém": "HU21",
    "Győr-Moson-Sopron": "HU22", "Vas": "HU22", "Zala": "HU22",
    "Baranya": "HU23", "Somogy": "HU23", "Tolna": "HU23",
    "Borsod-Abaúj-Zemplén": "HU31", "Heves": "HU31", "Nógrád": "HU31",
    "Hajdú-Bihar": "HU32", "Jász-Nagykun-Szolnok": "HU32",
    "Szabolcs-Szatmár-Bereg": "HU32",
    "Bács-Kiskun": "HU33", "Békés": "HU33", "Csongrád-Csanád": "HU33",
}

# ---------------------------------------------------------------------------
# Beszámolók lap: pozíció -> (ellenőrző kulcsszó a fejlécben, új név)
# A pozíció szerinti kiválasztás stabil; a kulcsszó-assert véd az ellen,
# hogy egy új szállítói export némán elcsússzon.
# ---------------------------------------------------------------------------
BESZAMOLO_MEZOK = {
    0: ("Opten", "opten_id"),
    1: ("Adószám", "adoszam"),
    2: ("Cégnév", "cegnev"),
    3: ("Pénznem", "penzegyseg"),
    4: ("Év", "ev"),
    5: ("Befektetett eszközök", "befektetett_eszkozok"),
    14: ("TÁRGYI", "targyi_eszkozok"),
    19: ("Beruházások", "beruhazasok_felujitasok"),
    34: ("Forgóeszközök", "forgoeszkozok"),
    35: ("KÉSZLETEK", "keszletek"),
    42: ("KÖVETELÉSEK", "kovetelesek"),
    43: ("vevők", "vevo_kovetelesek"),
    58: ("PÉNZESZKÖZÖK", "penzeszkozok"),
    60: ("Bankbetétek", "bankbetetek"),
    65: ("ESZKÖZÖK ÖSSZESEN", "eszkozok_osszesen"),
    66: ("Saját tőke", "sajat_toke"),
    67: ("JEGYZETT", "jegyzett_toke"),
    71: ("EREDMÉNYTARTALÉK", "eredmenytartalek"),
    81: ("Kötelezettségek", "kotelezettsegek"),
    82: ("HÁTRASOROLT", "hatrasorolt_kot"),
    87: ("HOSSZÚ LEJÁRATÚ", "hosszu_lejaratu_kot"),
    88: ("kölcsönök", "hosszu_kolcsonok"),
    91: ("Beruházási és fejlesztési", "beruhazasi_hitelek"),
    92: ("Egyéb hosszú lejáratú hitelek", "egyeb_hosszu_hitelek"),
    98: ("RÖVID LEJÁRATÚ", "rovid_lejaratu_kot"),
    99: ("Rövid lejáratú kölcsönök", "rovid_kolcsonok"),
    101: ("Rövid lejáratú hitelek", "rovid_hitelek"),
    103: ("szállítók", "szallitok"),
    115: ("FORRÁSOK", "forrasok_osszesen"),
    116: ("Belföldi", "belfoldi_arbevetel"),
    117: ("Export", "export_arbevetel"),
    118: ("Értékesítés nettó", "netto_arbevetel"),
    124: ("Anyagköltség", "anyagkoltseg"),
    129: ("Anyagjellegű", "anyagjellegu_raforditasok"),
    130: ("Bérköltség", "berkoltseg"),
    132: ("Bérjárulékok", "berjarulekok"),
    133: ("Személyi jellegű ráfordítások", "szemelyi_raforditasok"),
    134: ("Értékcsökkenési", "ertekcsokkenes"),
    137: ("ÜZEMI", "uzemi_eredmeny"),
    153: ("Fizetendő kamatok", "kamatraforditas"),
    160: ("ADÓZÁS ELŐTTI", "adozas_elotti_eredmeny"),
    163: ("ADÓZ", "adozott_eredmeny"),  # a forrásban elírva: "ADÓZÓTT"
}

ALAP_MEZOK = {
    0: ("Opten", "opten_id"),
    3: ("ir.szám", "szekhely_irsz"),
    4: ("település", "szekhely_telepules"),
    6: ("Nemzetgazdasági", "nemzetgazdasagi_ag"),
    7: ("TEÁOR", "teaor_kod"),
    9: ("2024", "letszam_2024"),
    10: ("2023", "letszam_2023"),
    11: ("Állami", "allami_tul"),
    12: ("Önkormányzati", "onkormanyzati_tul"),
    13: ("Külföldi", "kulfoldi_tul"),
    14: ("Kockázati", "kockazati_besorolas_2025"),
    19: ("Alapítás", "alapitas_eve"),
}

KOCKAZATI_MEZOK = {
    0: ("Opten", "opten_id"),
    3: ("Év", "ev"),
    4: ("Kockázati", "kockazati_besorolas"),
    5: ("ESG", "esg_index"),
}


def kivalaszt(df: pd.DataFrame, mezok: dict, lap: str) -> pd.DataFrame:
    """Pozíció szerinti oszlopkiválasztás fejléc-ellenőrzéssel."""
    cols = list(df.columns)
    for poz, (kulcsszo, _) in mezok.items():
        if kulcsszo.lower() not in str(cols[poz]).lower():
            raise ValueError(
                f"{lap}: a(z) {poz}. oszlop fejléce nem tartalmazza: "
                f"{kulcsszo!r} (talált: {cols[poz]!r}) — a forrásfájl "
                f"szerkezete megváltozott?"
            )
    out = df.iloc[:, list(mezok)].copy()
    out.columns = [uj for _, uj in mezok.values()]
    return out


def main() -> None:
    print(f"Beolvasás: {RAW}")
    xls = pd.ExcelFile(RAW, engine="openpyxl")

    # --- 1. Beszámolók -----------------------------------------------------
    besz = kivalaszt(xls.parse("Beszámolók"), BESZAMOLO_MEZOK, "Beszámolók")

    egysegek = besz["penzegyseg"].value_counts(dropna=False)
    print("\nPénzegység megoszlás:")
    print(egysegek.to_string())
    nem_eft = besz["penzegyseg"].astype(str).str.strip().str.lower() != "ezer forint"
    if nem_eft.any():
        print(f"FIGYELEM: {nem_eft.sum()} sor nem 'ezer Forint' egységű — "
              f"ezek kimaradnak a panelből (nincs megbízható átváltás).")
        besz = besz[~nem_eft]
    besz = besz.drop(columns="penzegyseg")

    szamoszlopok = [c for c in besz.columns
                    if c not in ("opten_id", "adoszam", "cegnev")]
    besz[szamoszlopok] = besz[szamoszlopok].apply(pd.to_numeric, errors="coerce")
    besz["ev"] = besz["ev"].astype("Int64")
    besz = besz.dropna(subset=["opten_id", "ev"])

    # cég-év duplikátumok: a legtöbb kitöltött mezővel bíró sor marad
    besz["_kitoltott"] = besz[szamoszlopok].notna().sum(axis=1)
    besz = (besz.sort_values("_kitoltott", ascending=False)
                .drop_duplicates(["opten_id", "ev"])
                .drop(columns="_kitoltott"))
    print(f"\nBeszámoló-panel: {len(besz)} cég-év, "
          f"{besz['opten_id'].nunique()} cég")
    print(besz["ev"].value_counts().sort_index().to_string())

    # --- 2. Alap lista -----------------------------------------------------
    alap = kivalaszt(xls.parse("Alap lista"), ALAP_MEZOK, "Alap lista")
    for c in ("letszam_2024", "letszam_2023", "alapitas_eve"):
        alap[c] = pd.to_numeric(alap[c], errors="coerce")
    for c in ("allami_tul", "onkormanyzati_tul", "kulfoldi_tul"):
        alap[c] = alap[c].astype(str).str.strip().str.lower().eq("igen")

    letszam = alap["letszam_2024"].fillna(alap["letszam_2023"])
    alap["letszam"] = letszam
    alap["meret_kategoria"] = pd.cut(
        letszam, bins=[9, 49, 249, np.inf],
        labels=["10-49", "50-249", "250+"])

    # TEÁOR: az 5. számjegy évkód (4=2008, 5=2025), az első 4 a valódi kód
    teaor = alap["teaor_kod"].astype(str).str.extract(r"^(\d{4})")[0]
    alap["teaor4"] = teaor
    alap["agazat_betu"] = alap["nemzetgazdasagi_ag"]

    # NUTS-2: elsődlegesen a hivatalos irsz->vármegye térképből (IrszHnk,
    # KSH+posta forrás); ha a fájl hiányzik, a sáv-alapú közelítés marad
    hivatalos = hivatalos_irsz_terkep()
    if hivatalos is not None:
        irsz_str = pd.to_numeric(alap["szekhely_irsz"], errors="coerce")
        alap["nuts2"] = irsz_str.map(hivatalos)
        maradek = alap["nuts2"].isna()
        alap.loc[maradek, "nuts2"] = alap.loc[maradek, "szekhely_irsz"].map(
            irsz_to_nuts2)
        print(f"NUTS-2: hivatalos térkép ({(~maradek).sum()} cég), "
              f"sáv-közelítés csak {maradek.sum()} cégre")
    else:
        alap["nuts2"] = alap["szekhely_irsz"].map(irsz_to_nuts2)
        print("NUTS-2: IrszHnk hiányzik — sáv-alapú közelítés "
              "(lásd data-index.md)")

    # --- 3. Kockázati besorolás idősor -------------------------------------
    kock = kivalaszt(xls.parse("Kockázati bes.,ESG előző évekre"),
                     KOCKAZATI_MEZOK, "Kockázati")
    kock["ev"] = pd.to_numeric(kock["ev"], errors="coerce").astype("Int64")
    kock["esg_index"] = pd.to_numeric(kock["esg_index"], errors="coerce")
    kock = kock.dropna(subset=["opten_id", "ev"]).drop_duplicates(
        ["opten_id", "ev"])

    # --- 4. EU-támogatás, közbeszerzés (cégszintű jelzők) -------------------
    eu = xls.parse("EU-s támogatás")
    kozb = xls.parse("Közbeszerzési adatok")

    def cegszintu(df: pd.DataFrame, prefix: str) -> pd.DataFrame:
        d = df.iloc[:, [0, 3, 4, 5]].copy()
        d.columns = ["opten_id", "ev", "a", "b"]
        d[["a", "b"]] = d[["a", "b"]].apply(pd.to_numeric, errors="coerce")
        # a fejléc szerint 'a' a darabszám, de a nagyságrend dönt:
        # a darabszám a kisebb medián értékű oszlop
        if d["a"].median() > d["b"].median():
            d = d.rename(columns={"a": "osszeg_ft", "b": "db"})
        else:
            d = d.rename(columns={"a": "db", "b": "osszeg_ft"})
        agg = d.groupby("opten_id").agg(
            db=("db", "sum"), osszeg_ft=("osszeg_ft", "sum"))
        agg[f"{prefix}_nyertes"] = True
        return agg.rename(columns={"db": f"{prefix}_db",
                                   "osszeg_ft": f"{prefix}_osszeg_ft"})

    eu_agg = cegszintu(eu, "eu_tamogatas")
    kozb_agg = cegszintu(kozb, "kozbeszerzes")

    # --- 5. Összefűzés ------------------------------------------------------
    panel = besz.merge(alap.drop(columns=["nemzetgazdasagi_ag", "teaor_kod"]),
                       on="opten_id", how="left")
    panel = panel.merge(kock[["opten_id", "ev", "kockazati_besorolas",
                              "esg_index"]],
                        on=["opten_id", "ev"], how="left")
    # 2025-re nincs idősoros besorolás -> a statikus (2025-ös) érték
    m25 = panel["ev"].eq(2025) & panel["kockazati_besorolas"].isna()
    panel.loc[m25, "kockazati_besorolas"] = panel.loc[
        m25, "kockazati_besorolas_2025"]
    panel = panel.merge(eu_agg, on="opten_id", how="left")
    panel = panel.merge(kozb_agg, on="opten_id", how="left")
    for c in ("eu_tamogatas_nyertes", "kozbeszerzes_nyertes"):
        panel[c] = panel[c].eq(True)
    for c in ("eu_tamogatas_db", "eu_tamogatas_osszeg_ft",
              "kozbeszerzes_db", "kozbeszerzes_osszeg_ft"):
        panel[c] = panel[c].fillna(0)

    # --- 6. Származtatott változók (minden állomány ezer Ft-ban) -----------
    hitel = (panel[["hosszu_kolcsonok", "beruhazasi_hitelek",
                    "egyeb_hosszu_hitelek", "rovid_kolcsonok",
                    "rovid_hitelek"]].fillna(0).sum(axis=1))
    panel["hitelallomany"] = hitel
    panel["van_hitel"] = hitel > 0
    kamat = panel["kamatraforditas"].fillna(0)
    ok = (hitel > 0) & (kamat > 0)
    panel["implicit_kamatrata"] = np.where(ok, kamat / hitel, np.nan)
    # szélsőértékek levágása: 0-100% közé eső ráták maradnak
    panel.loc[panel["implicit_kamatrata"] > 1, "implicit_kamatrata"] = np.nan

    arb = panel["netto_arbevetel"]
    panel["export_arany"] = np.where(
        arb > 0, panel["export_arbevetel"].fillna(0) / arb, np.nan)
    panel["exportor"] = panel["export_arbevetel"].fillna(0) > 0
    panel["tokeattetel"] = np.where(
        panel["eszkozok_osszesen"] > 0,
        panel["kotelezettsegek"].fillna(0) / panel["eszkozok_osszesen"],
        np.nan)

    panel = panel.sort_values(["opten_id", "ev"])

    # --- 7. QC az adathelyzet-jelentés számaival szemben --------------------
    print("\n================ QC ================")
    print(f"Cég-év megfigyelés: {len(panel)}  (jelentés: 150 982)")
    print(f"Egyedi cég: {panel['opten_id'].nunique()}  (jelentés: 37 805)")
    print("\nMéretkategória (cégszint, jelentés: 31 483 / 5 160 / 1 083):")
    print(alap["meret_kategoria"].value_counts().to_string())
    print("\nLefedettség (cég-év, %):")
    for c, cimke in [("sajat_toke", "Saját tőke (jelentés: 100%)"),
                     ("kotelezettsegek", "Kötelezettségek (99,5%)"),
                     ("netto_arbevetel", "Árbevétel (98,9%)")]:
        print(f"  {cimke}: {panel[c].notna().mean()*100:.1f}%")
    print(f"  Kamatráfordítás>0 (16,4%): "
          f"{(panel['kamatraforditas'].fillna(0) > 0).mean()*100:.1f}%")
    print(f"  Exportőr (13,6%): {panel['exportor'].mean()*100:.1f}%")
    ir = panel["implicit_kamatrata"].dropna()
    print(f"\nImplicit kamatráta: n={len(ir)} (jelentés: 17 355), "
          f"medián={ir.median()*100:.1f}% (4,3%), "
          f"IQR={ir.quantile(.25)*100:.1f}–{ir.quantile(.75)*100:.1f}% "
          f"(2,0–9,9%)")
    print("\nKockázati besorolás (cég-év):")
    print(panel["kockazati_besorolas"].value_counts(dropna=False).to_string())
    print("\nNUTS-2 régió (cégszint, közelítő irsz-alapú):")
    print(alap["nuts2"].value_counts(dropna=False).to_string())

    OUT.parent.mkdir(parents=True, exist_ok=True)
    panel.to_csv(OUT, index=False, encoding="utf-8-sig")
    print(f"\nKiírva: {OUT}  ({len(panel)} sor, {panel.shape[1]} oszlop)")


def hivatalos_irsz_terkep() -> dict | None:
    """Hivatalos irányítószám -> NUTS-2 térkép az IrszHnk csv-ből.

    Forrás: github.com/tamas-ferenci/IrszHnk (KSH helységnévtár + posta
    irányítószám-jegyzék összerendelése). Egy irsz elvben több településhez
    is tartozhat — a leggyakoribb vármegye dönt (gyakorlatban egyezik).
    """
    if not IRSZ_HNK.exists():
        return None
    m = pd.read_csv(IRSZ_HNK, sep=";", encoding="utf-8",
                    usecols=["IRSZ", "Vármegye.megnevezése"])
    m["nuts2"] = m["Vármegye.megnevezése"].map(MEGYE_NUTS2)
    m = m.dropna(subset=["nuts2"])
    m["IRSZ"] = pd.to_numeric(m["IRSZ"], errors="coerce")
    return (m.groupby("IRSZ")["nuts2"]
             .agg(lambda s: s.mode().iat[0])
             .to_dict())


def irsz_to_nuts2(irsz) -> str | None:
    """Irányítószám -> NUTS-2 régió, közelítő sávok alapján.

    NUTS-2 szinten a magyar irányítószám-sávok szinte pontosan illeszkednek
    (a megyehatár-menti kivételeket külön kezeljük: Keszthely/Hévíz -> HU22,
    Rétság/Balassagyarmat környéke -> HU31). A maradék hiba <1%.
    """
    try:
        n = int(irsz)
    except (TypeError, ValueError):
        return None
    if 2651 <= n <= 2699:   # Nógrád megyei irsz-ek a váci sávban
        return "HU31"
    if 8360 <= n <= 8399:   # Keszthely, Hévíz -> Zala
        return "HU22"
    savok = [
        (1000, 1999, "HU11"),  # Budapest
        (2000, 2399, "HU12"),  # Pest
        (2400, 2599, "HU21"),  # Fejér, Komárom-Esztergom
        (2600, 2799, "HU12"),  # Pest (Vác, Cegléd)
        (2800, 2999, "HU21"),  # Komárom-Esztergom
        (3000, 3999, "HU31"),  # Heves, Nógrád, Borsod
        (4000, 4999, "HU32"),  # Hajdú-Bihar, Szabolcs
        (5000, 5499, "HU32"),  # Jász-Nagykun-Szolnok
        (5500, 5999, "HU33"),  # Békés
        (6000, 6999, "HU33"),  # Bács-Kiskun, Csongrád-Csanád
        (7000, 7099, "HU21"),  # Fejér (Sárbogárd)
        (7100, 7999, "HU23"),  # Tolna, Somogy, Baranya
        (8000, 8099, "HU21"),  # Fejér
        (8100, 8599, "HU21"),  # Veszprém
        (8600, 8799, "HU23"),  # Somogy
        (8800, 8999, "HU22"),  # Zala
        (9000, 9499, "HU22"),  # Győr-Moson-Sopron
        (9500, 9999, "HU22"),  # Vas
    ]
    for lo, hi, kod in savok:
        if lo <= n <= hi:
            return kod
    return None


if __name__ == "__main__":
    main()
