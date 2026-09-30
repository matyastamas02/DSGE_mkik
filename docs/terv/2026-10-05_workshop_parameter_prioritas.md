# Mi hajtja a KKV-eredményt? — paraméter-prioritás

*2026-09-30 · Tamás · Export a Claude Docs dokumentumból (a workshopon ott töltjük ki élőben): https://claude.ai/code/artifact/9b755cc0-acc6-4c46-a09c-c90dab2934c8*

## A tábla

Három paraméter már bizonyítottan megfordíthatja a KKV–nagyvállalat különbség előjelét, egy negyedik a küszöb szintjét mozgatja. Egyik sincs horgonyozva. A táblát az állítás- és paraméterregiszterből töltöttük ki. Ahol „nem mértük” áll, ott nincs futtatásunk a hatásról, nem az a válasz, hogy nincs hatás.

| Paraméter | Mit visz a modellben | Megfordíthatja az előjelet? | Forrás, megbízhatóság | Következő ellenőrzés | Csoport: prioritás |
| --- | --- | --- | --- | --- | --- |
| `λ·ω` (`lambda_acc` × `omega_acc`) | a hitelhozzáférési csatorna ereje | **Igen:** a KKV-előny küszöbe `(λ·ω)* ≈ 500` (F01) | horgonyzatlan; a modell csak a szorzatot azonosítja (A22) | EIBIS, illetve a SAFE éves kör magyar mikrobontása | Magas / Közepes / Alacsony |
| `eps_ces` | helyettesítés a vállalattípusok között | **Igen:** az export-KKV kibocsátásának előjele kb. 2,3-nál fordul (F02) | horgonyzatlan; a magyar markup-becslés (Dobrinsky et al., 2006) más objektum, csak plauzibilitási sáv | olyan becslés, amely vállalattípusok, nem termékváltozatok közötti helyettesítést mér | Magas / Közepes / Alacsony |
| `chi_j` | a hitelfelár érzékenysége a tőkeáttételre (BGG) | **Igen:** a sorrend megfordítása a szegmenssorrendet is fordítja (−1,22 → +0,74 pp) | gyenge: a panel alsó korlátja +0,002, az irodalom 0,042–0,067; a 3×-os aszimmetria visszavonva, az alapág mégis ezt futtatja | méret szerinti szint-becslés | Magas / Közepes / Alacsony |
| `rho_acc` | a hozzáférés perzisztenciája, `1/(1−ρ)` alakban hat | a küszöb szintjét mozgatja: 0,85 → 0,9673 mellett 36,5 → 22,3 | horgonyzatlan; a 0,9673 leíró cégstátusz-statisztika, nem alsó korlát | a hitelstátuszt váltó cégek almintája | Magas / Közepes / Alacsony |
| `lev_E/D/L` | tőkeáttétel típusonként | nem mértük külön; az eredményt a pénzügyi heterogenitás viszi (A23) | erős: Opten 1,94 / 1,72 / 2,34, a sorrend mérőfüggetlen; az alapág mégis 1,6 = 1,6-ot futtat | az alapértelmezés cseréje (csapatdöntés) | Magas / Közepes / Alacsony |
| `tbank_j` | a banki felár átgyűrűzése típusonként | nem mértük; az alapág semleges | ellentmondás: az euróövezeti irodalom KKV-ra teljes átgyűrűzést talál, a saját mérésünk nagyvállalatra magasabbat (F06) | az ellentmondás feloldása | Magas / Közepes / Alacsony |
| `psi_j` | beruházási kiigazítási költség | nem mértük | nincs becslés; az irodalom a miénkkel ellentétes méret-sorrendet sugall | érzékenységi scan | Magas / Közepes / Alacsony |
| `phi_E` | az export-KKV exportárbevétel-aránya | nem mértük külön | Opten, de definíciófüggő: 0,376 vagy 0,691 | az exportáló-definíció rögzítése | Magas / Közepes / Alacsony |
| `s_kkv` | a KKV-k beszállítói súlya | nem közölhető | az IO-alapú számítás hibás | újraszámolás OECD TiVA/ICIO alapján | Magas / Közepes / Alacsony |
| `tsov_j` | a szuverén felár átgyűrűzése típusonként | nem mértük; az alapág semleges | nincs szintbecslés; Bottero–Lenzu–Mezzanotti (2018) a semleges szerkezetet támasztja alá | — | Magas / Közepes / Alacsony |
| `zsov` | a szuverén felár átgyűrűzése a kamatba | az aggregált hatást viszi; hogy a szuverén csatorna mennyire dominál, még nyitott (az F05 csak az első negyedévet méri, amikor a banki felár még nem mozdult) | horgonyzatlan, de a legolcsóbb: két nyilvános idősorból mérhető | szuverén felár vs. BUBOR–EURIBOR különbözet (támpont: Vonnák, MNB WP 2010/1) | Magas / Közepes / Alacsony |

A `mu_vert` (beszállítói ár-átgyűrűzés) kimaradt: kerestünk rá irodalmat, és nem találtunk becslést.

## Hogyan használjuk a workshopon

A cél egyetlen döntés: melyik paraméter horgonyzása növelné a legjobban a KKV-állítás hitelességét. 25 perc jut rá.

1. Soronként csak ott állunk meg, ahol valaki nem ért egyet az előre kitöltött értékeléssel.
2. A csoport minden sorhoz kiválasztja a prioritást az utolsó oszlopban.
3. Záró kérdés mindenkinek: **„Ha egyetlen bizonytalan paramétert mérhetnénk meg tökéletesen, melyik lenne az?”**

A leggyakoribb válasz lesz a következő adat- vagy kutatási feladat. Felelősét és határidejét a záró döntési táblában rögzítjük.
