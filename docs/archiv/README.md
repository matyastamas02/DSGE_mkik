# Archívum

> ⚠ **Ezek meghaladott pillanatképek.** A bennük szereplő útvonalak,
> számok és teendők a keletkezésük napján voltak érvényesek.
>
> **Az aktuális állapot: [`ALLAPOT.md`](../../ALLAPOT.md)** (generált).

Konkrétan, ami ezekben a fájlokban már NEM stimmel:

- **Útvonalak.** A 2026-08-16-i repo-átrendezés óta a modellek a
  `src/modell/<vonal>/` alatt vannak, nem a `src/model/`-ben. Az itt
  szereplő `matlab -batch "cd('src/model'); ..."` parancsok nem futnak le.
  A helyes parancsok: [`README.md`](../../README.md).
- **Az aggregált GDP-sáv.** Az `ATADAS_2026-08-12.md` a „+0,27…+1,04%"
  sávot közli. Ezt 2026-08-16-án visszavontuk (`V01` az állítás-regiszterben);
  a horgonyzott `rho_acc` mellett a helyes sáv **+0,3…+2,9%**.
- **A `chi_S > chi_L` háromszoros KKV-fölény.** Visszavonva (`V04`).

**Miért maradnak itt:** az `ATADAS` a JV-vonal négylépcsős felzárkóztatásának
egyetlen összefüggő elbeszélése, és a hibafeltárás menetét is rögzíti. A
történetet érdemes megőrizni — csak nem szabad belőle számot idézni.
