<!-- GENERÁLT FÁJL — NE SZERKESZD. Újragenerálás:
       python src/4_infra/15_output_index.py                        -->

# output/ — tartalomjegyzék

*Generálva · commit `4dbcf1f`*

A `output/tables/` szándékosan **lapos**: a szétvágás ~90 őrt és ~15 scriptet írt volna át, cserébe a `t35` attól még `t35` maradt volna. A navigálhatóságot ez az index adja.

**65 tábla · 26 ábra.**

## ⚠ Audit

**HIÁNYZÓ ÁLLÍTÁS (8):** élő vonalon keletkezett eredmény, amihez se állítás, se őr nem tartozik. Vagy kap egy sort az állítás-regiszterben, vagy törlendő.

- `output/tables/t10_extenziv_margo_m1.csv`
- `output/tables/t11_hozzaferes_kiigazitott.csv`
- `output/tables/t12_rata_eloszlas_ev.csv`
- `output/tables/t13_piaci_alminta_besorolas.csv`
- `output/tables/t14_tamogatasi_ek.csv`
- `output/tables/t15_csatorna_dekompozicio.csv`
- `output/tables/t17_beralkalmazkodas.csv`
- `output/tables/t25_transzmisszio.csv`

---

## Táblák

| Fájl | Előállítja | Vonal | Állítás | Őr | Szerep |
|---|---|---|---|---|---|
| `irf_v01.csv` | `src/3_abrak/03_irf_abrak.py`<br>`src/4_infra/smoke_test.m`<br>`src/modell/2_referencia_eagle/futtato/run_v01.m` | ábrageneráló | — | — | referencia/archív vonal |
| `szcenario_v02.csv` | `src/3_abrak/04_szcenario_abrak.py`<br>`src/modell/2_referencia_eagle/futtato/run_v02.m` | ábrageneráló | — | — | referencia/archív vonal |
| `szcenario_v03.csv` | `src/3_abrak/05_szcenario_abrak_v03.py`<br>`src/3_abrak/s06_szegmens_lekepezes.m`<br>`src/modell/2_referencia_eagle/futtato/run_v03.m`<br>`src/modell/2_referencia_eagle/futtato/run_v04.m` | ábrageneráló | — | — | referencia/archív vonal |
| `szcenario_v03_hosszutav.csv` | `src/3_abrak/05_szcenario_abrak_v03.py`<br>`src/3_abrak/s06_szegmens_lekepezes.m`<br>`src/4_infra/smoke_test.m`<br>`src/modell/2_referencia_eagle/futtato/run_v03.m`<br>`src/modell/2_referencia_eagle/futtato/run_v04.m` | ábrageneráló | — | ✅ 1 db | **állítást hordoz** |
| `t00_orok.csv` | `src/4_infra/13_allapotlap.py`<br>`src/4_infra/smoke_test.m` | infrastruktúra | — | ✅ 3 db | **állítást hordoz** |
| `t01_ev_attekintes.csv` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | leíró háttér |
| `t02_meret.csv` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | leíró háttér |
| `t03_kockazati_besorolas.csv` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | leíró háttér |
| `t04_regio.csv` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | leíró háttér |
| `t05_agazat.csv` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | leíró háttér |
| `t06_kockazati_atmenet.csv` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | leíró háttér |
| `t09_szegmens_lekepezes.csv` | `src/3_abrak/s06_szegmens_lekepezes.m`<br>`src/4_infra/smoke_test.m` | ábrageneráló | — | ✅ 3 db | **állítást hordoz** |
| `t10_extenziv_margo_m1.csv` | `src/2_empirikus/s07_extenziv_margo.m` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t11_hozzaferes_kiigazitott.csv` | `src/2_empirikus/s07_extenziv_margo.m` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t12_rata_eloszlas_ev.csv` | `src/2_empirikus/s08_tamogatott_hitel_teszt.m` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t13_piaci_alminta_besorolas.csv` | `src/2_empirikus/s08_tamogatott_hitel_teszt.m` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t14_tamogatasi_ek.csv` | `src/2_empirikus/s09_tamogatasi_ek.m` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t15_csatorna_dekompozicio.csv` | `src/3_abrak/s11_fazis_es_dekompozicio.m` | ábrageneráló | — | — | ⚠ **hiányzik az állítás** |
| `t16_v04_osszevetes.csv` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v03.m`<br>`src/modell/2_referencia_eagle/futtato/run_v04.m`<br>`src/modell/2_referencia_eagle/futtato/run_v05.m` | ⚪ archív (korai JV) | — | — | referencia/archív vonal |
| `t17_beralkalmazkodas.csv` | `src/2_empirikus/s12_berrugalmassag.m` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t18_v05_berragadossag.csv` | `src/modell/2_referencia_eagle/futtato/run_v05.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t19_jv_hosszutav.csv` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v03.m` | ⚪ archív (korai JV) | — | — | referencia/archív vonal |
| `t19_jv_szcenariok.csv` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v03.m` | ⚪ archív (korai JV) | — | — | referencia/archív vonal |
| `t20_jv_v04_vertikalis.csv` | `src/3_abrak/06_jv_v04_abra.py`<br>`src/modell/3_archiv_korai_jv/futtato/run_jv_v04.m` | ábrageneráló | — | — | referencia/archív vonal |
| `t21_jv_v05_hosszutav.csv` | `src/3_abrak/s13_szegmens_lekepezes_v05.m`<br>`src/4_infra/smoke_test.m`<br>`src/modell/3_archiv_korai_jv/futtato/run_jv_v05.m` | ábrageneráló | — | ✅ 1 db | **állítást hordoz** |
| `t21_jv_v05_szcenariok.csv` | `src/3_abrak/s13_szegmens_lekepezes_v05.m`<br>`src/modell/3_archiv_korai_jv/futtato/run_jv_v05.m` | ábrageneráló | — | ✅ 1 db | **állítást hordoz** |
| `t22_szegmens_lekepezes_v05.csv` | `src/3_abrak/s13_szegmens_lekepezes_v05.m`<br>`src/4_infra/smoke_test.m` | ábrageneráló | — | ✅ 3 db | **állítást hordoz** |
| `t23_sens_skkv.csv` | `src/modell/3_archiv_korai_jv/futtato/sens_skkv_v05.m` | ⚪ archív (korai JV) | — | — | referencia/archív vonal |
| `t24_io_hazai_input.csv` | `src/2_empirikus/07_io_hazai_input_arany.py`<br>`src/2_empirikus/10_io_matrix_letoltes.py` | empirikus horgonyzás | V02 | — | **állítást hordoz** |
| `t25_transzmisszio.csv` | `src/2_empirikus/08_mnb_transzmisszio.py` | empirikus horgonyzás | — | — | ⚠ **hiányzik az állítás** |
| `t26_tsuly_teszt.csv` | `src/modell/3_archiv_korai_jv/futtato/sens_tsuly_v05.m` | ⚪ archív (korai JV) | V03 | — | **állítást hordoz** |
| `t27_v06_3type_hosszutav.csv` | `src/modell/2_referencia_eagle/futtato/run_v06_3type.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t27_v06_3type_szcenariok.csv` | `src/modell/2_referencia_eagle/futtato/run_v06_3type.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t28_v06_3type_tscen_sens.csv` | `src/modell/2_referencia_eagle/futtato/run_v06_3type_tscen_sens.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t29_v07_access_hosszutav.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/2_referencia_eagle/futtato/run_v07_access.m` | infrastruktúra | — | ✅ 1 db | **állítást hordoz** |
| `t29_v07_access_szcenariok.csv` | `src/modell/2_referencia_eagle/futtato/run_v07_access.m` | 🟡 referencia (EAGLE) | — | ✅ 1 db | **állítást hordoz** |
| `t30_v07_access_tscen_sens.csv` | `src/modell/2_referencia_eagle/futtato/run_v07_access_tscen_sens.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t31_v07_access_scale_sens.csv` | `src/modell/2_referencia_eagle/futtato/run_v07_access_scale_sens.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t32_v07_access_threshold_grid.csv` | `src/modell/2_referencia_eagle/futtato/run_v07_access_threshold.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t33_v07_access_threshold_summary.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/2_referencia_eagle/futtato/run_v07_access_threshold.m` | infrastruktúra | — | ✅ 2 db | **állítást hordoz** |
| `t34_jv_v06_hosszutav.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/3_archiv_korai_jv/futtato/run_jv_v06.m` | infrastruktúra | — | ✅ 1 db | **állítást hordoz** |
| `t34_jv_v06_szcenariok.csv` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v06.m` | ⚪ archív (korai JV) | — | ✅ 1 db | **állítást hordoz** |
| `t35_sens_chi_psi_v06.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/sens_chi_psi_v06.m` | infrastruktúra | — | ✅ 4 db | **állítást hordoz** |
| `t36_access_horgonyzas.csv` | `src/2_empirikus/s14_access_horgonyzas.m` | empirikus horgonyzás | A06 · V06 | — | **állítást hordoz** |
| `t37_access_szegmens_evek.csv` | `src/2_empirikus/s14_access_horgonyzas.m`<br>`src/4_infra/smoke_test.m` | empirikus horgonyzás | A02 · A03 · A04 · A05 · A06 · V06 | ✅ 5 db | **állítást hordoz** |
| `t38_calib_eagle_vs_jv.csv` | `src/modell/2_referencia_eagle/futtato/sens_calib_v07.m` | 🟡 referencia (EAGLE) | — | — | referencia/archív vonal |
| `t39_calib_kuszob.csv` | `src/modell/2_referencia_eagle/futtato/sens_calib_kuszob_v07.m` | 🟡 referencia (EAGLE) | — | — | részletes rács (az összegzője őrzött) |
| `t39b_calib_kuszob_osszegzes.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/2_referencia_eagle/futtato/sens_calib_kuszob_v07.m` | infrastruktúra | — | ✅ 3 db | **állítást hordoz** |
| `t40_jv_3type_stressz.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_jv_3type.m` | infrastruktúra | — | ✅ 4 db | **állítást hordoz** |
| `t41_jv_3type_arak_stressz.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_jv_3type_arak.m` | infrastruktúra | — | ✅ 4 db | **állítást hordoz** |
| `t42_jv_3type_epsces_sens.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_jv_3type_arak.m` | infrastruktúra | F02 | ✅ 3 db | **állítást hordoz** |
| `t43_ellenorzes_3type.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/ellenorzes_3type.m` | infrastruktúra | A14 | ✅ 4 db | **állítást hordoz** |
| `t44_jv_access_stressz.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_jv_access_v09.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_opten_v09.m` | infrastruktúra | A01 | ✅ 3 db | **állítást hordoz** |
| `t45_jv_access_kuszob.csv` | `src/modell/1_fo_vonal_jv/futtato/stress_jv_access_v09.m` | 🟢 fő vonal (JV) | — | — | részletes rács (az összegzője őrzött) |
| `t45b_jv_access_kuszob_osszegzes.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_jv_access_v09.m` | infrastruktúra | A13 | ✅ 3 db | **állítást hordoz** |
| `t46_opten_kalibracio.csv` | `src/2_empirikus/s15_opten_kalibracio.m`<br>`src/4_infra/smoke_test.m` | empirikus horgonyzás | A08 · A09 · A10 · F03 | ✅ 6 db | **állítást hordoz** |
| `t46b_opten_kalibracio_evenkent.csv` | `src/2_empirikus/s15_opten_kalibracio.m` | empirikus horgonyzás | — | — | részletes rács (az összegzője őrzött) |
| `t46c_rho_acc_atmenet.csv` | `src/2_empirikus/s15_opten_kalibracio.m` | empirikus horgonyzás | A11 | — | **állítást hordoz** |
| `t47_opten_stressz.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_opten_v09.m` | infrastruktúra | A01 · A12 · V01 | ✅ 4 db | **állítást hordoz** |
| `t48_opten_kuszob.csv` | `src/modell/1_fo_vonal_jv/futtato/stress_opten_v09.m` | 🟢 fő vonal (JV) | F01 | — | **állítást hordoz** |
| `t48b_opten_kuszob_osszegzes.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_opten_v09.m` | infrastruktúra | F01 | ✅ 5 db | **állítást hordoz** |
| `t49_rhoacc_erzekenyseg.csv` | `src/modell/1_fo_vonal_jv/futtato/stress_opten_v09.m` | 🟢 fő vonal (JV) | — | — | részletes rács (az összegzője őrzött) |
| `t49b_rhoacc_erzekenyseg_osszegzes.csv` | `src/4_infra/smoke_test.m`<br>`src/modell/1_fo_vonal_jv/futtato/stress_opten_v09.m` | infrastruktúra | — | ✅ 4 db | **állítást hordoz** |
| `t50_bgg_blokk.csv` | `src/2_empirikus/11_bgg_blokk_kalibracio.py`<br>`src/4_infra/smoke_test.m` | empirikus horgonyzás | A07 · A08 | ✅ 4 db | **állítást hordoz** |
| `t50b_bgg_chi_reszletes.csv` | `src/2_empirikus/11_bgg_blokk_kalibracio.py`<br>`src/4_infra/smoke_test.m` | empirikus horgonyzás | A15 · F04 · V04 · V08 | ✅ 2 db | **állítást hordoz** |

---

## Ábrák

| Fájl | Előállítja | Vonal | Állítás | Őr | Szerep |
|---|---|---|---|---|---|
| `f01_implicit_kamat_besorolas.png` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | ábra (az állítás a tábláján ül) |
| `f02_implicit_kamat_evenkent.png` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | ábra (az állítás a tábláján ül) |
| `f03_hitelhozzaferes_besorolas.png` | `src/1_adat/02_leiro_stat.py` | adat-előkészítés | — | — | ábra (az állítás a tábláján ül) |
| `f04_irf_hitelsokk_v01.png` | `src/3_abrak/03_irf_abrak.py` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f05_euro_szcenariok_v02.png` | `src/3_abrak/04_szcenario_abrak.py` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f06_euro_szcenariok_v03.png` | `src/3_abrak/05_szcenario_abrak_v03.py` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f07_szegmens_lekepezes.png` | `src/3_abrak/s06_szegmens_lekepezes.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f08_extenziv_margo.png` | `src/2_empirikus/s07_extenziv_margo.m` | empirikus horgonyzás | — | — | ábra (az állítás a tábláján ül) |
| `f09_tamogatott_hitel_teszt.png` | `src/2_empirikus/s08_tamogatott_hitel_teszt.m` | empirikus horgonyzás | — | — | ábra (az állítás a tábláján ül) |
| `f10_irf_sov.png` | `src/3_abrak/s10_irf_panelek.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f11_irf_bank.png` | `src/3_abrak/s10_irf_panelek.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f12_irf_monetaris.png` | `src/3_abrak/s10_irf_panelek.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f13_akcelerator_kibe.png` | `src/3_abrak/s10_irf_panelek.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f14_fazis_idovonal.png` | `src/3_abrak/s11_fazis_es_dekompozicio.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f15_csatorna_dekompozicio.png` | `src/3_abrak/s11_fazis_es_dekompozicio.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f16_kamatunio_v04.png` | `src/modell/2_referencia_eagle/futtato/run_v04.m` | 🟡 referencia (EAGLE) | — | — | ábra (az állítás a tábláján ül) |
| `f17_calvo_ber_v05.png` | `src/modell/2_referencia_eagle/futtato/run_v05.m` | 🟡 referencia (EAGLE) | — | — | ábra (az állítás a tábláján ül) |
| `f18_jv_szcenariok.png` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v03.m` | ⚪ archív (korai JV) | — | — | ábra (az állítás a tábláján ül) |
| `f19_jv_v04_vertikalis.png` | `src/3_abrak/06_jv_v04_abra.py` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f20_jv_v05_szegmentalt_szcenario.png` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v05.m` | ⚪ archív (korai JV) | — | — | ábra (az állítás a tábláján ül) |
| `f21_szegmens_lekepezes_v05.png` | `src/3_abrak/s13_szegmens_lekepezes_v05.m` | ábrageneráló | — | — | ábra (az állítás a tábláján ül) |
| `f22_sens_skkv.png` | `src/modell/3_archiv_korai_jv/futtato/sens_skkv_v05.m` | ⚪ archív (korai JV) | — | — | ábra (az állítás a tábláján ül) |
| `f23_v06_3type_szcenariok.png` | `src/modell/2_referencia_eagle/futtato/run_v06_3type.m` | 🟡 referencia (EAGLE) | — | — | ábra (az állítás a tábláján ül) |
| `f24_v07_access_szcenariok.png` | `src/modell/2_referencia_eagle/futtato/run_v07_access.m` | 🟡 referencia (EAGLE) | — | — | ábra (az állítás a tábláján ül) |
| `f25_jv_v06_belso_javitas.png` | `src/modell/3_archiv_korai_jv/futtato/run_jv_v06.m` | ⚪ archív (korai JV) | — | — | ábra (az állítás a tábláján ül) |
| `f26_access_horgonyzas.png` | `src/2_empirikus/s14_access_horgonyzas.m` | empirikus horgonyzás | — | — | ábra (az állítás a tábláján ül) |
