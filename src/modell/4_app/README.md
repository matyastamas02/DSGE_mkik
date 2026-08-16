# 4. APP-MODELL

> **Külön termék, nem a modell-létra része.** A Streamlit-app által
> vezérelt futtató-változat.

`jv_app_model.mod` a [`jv_dsge_v02`](../3_archiv_korai_jv/jv_dsge_v02.mod)
változata, ahol a felhasználó által állítható paraméterek `@#define`-ból
jönnek. Így az app egyetlen hívással újraparaméterezhető:

```
dynare jv_app_model -DSIGMA=... -DHABIT=... console
```

A `-D`-vel nem felülírt paraméterek a JV becsült poszterior-átlagát veszik
fel (alapértelmezés).

## ⚠ Ezt NE szerkeszd modellezéshez

Ez az **app futtató-változata**. A kanonikus modell a
[`jv_dsge_v02.mod`](../3_archiv_korai_jv/jv_dsge_v02.mod); a **fő modell**
pedig a [`jv_dsge_v09_access.mod`](../1_fo_vonal_jv/jv_dsge_v09_access.mod).
Ha itt módosítasz valamit, az az appban jelenik meg, nem az eredményekben.

## Kapcsolódó

Az app kódja: [`src/app/`](../../app/) — `jv_app.py` (Streamlit) és
`jv_app_export.m` (MATLAB-oldali export).
