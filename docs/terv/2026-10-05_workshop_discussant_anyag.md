# Euró és magyar KKV-k — háttéranyag a discussantnek

*2026-09-30 · Tamás · Export a Claude Docs dokumentumból: https://claude.ai/code/artifact/d06f29fd-77a1-4744-9b30-bc4776f81545*

## Mit kérünk

A workshop központi kérdése: **milyen feltételek mellett állíthatjuk, hogy az euró bevezetése eltérően érinti az exportáló KKV-kat, a hazai KKV-kat és a nagyvállalatokat?** A te 10 perces hozzászólásod nyitja a bírálói kört, utána mindenki sorban szól. Összefoglalót nem kérünk. Négy kérdésre várjuk a válaszod:

1. Mi a modell legerősebb része?
2. Mi a legsúlyosabb kifogásod?
3. Melyik állítást nem engednéd még publikálni?
4. Milyen teszt győzne meg?

A projekt kérdése: milyen tartós makrohatása lenne az euró bevezetésének Magyarországon, és a KKV-k relatíve nyernének-e vagy veszítenének a nagyvállalatokhoz képest. Megbízó a Magyar Kereskedelmi és Iparkamara (MKIK), a határidő 2026. december.

A modell építése kész, a fennmaradó munka a paraméterek horgonyzása. Ezért a legtöbbet egy forrás, egy adat vagy egy azonosítási ötlet ér. Az 5. szakasz négy nyitott kérdése segít, hol érdemes keresni.

## A modell röviden

A fő modell egy New Keynesian kis nyitott gazdaság Jakab–Világi-magon (MNB WP 2008/9). A mag paraméterei magyar adaton becsültek. Három vállalattípust különböztetünk meg, mindegyiknek saját ára, kereslete és pénzügyi súrlódása van.

| Típus | Hitelhozzáférés (Opten, 2021–24) | Tőkeáttétel |
| --- | --- | --- |
| E — exportáló KKV | 61,9% | 1,94 |
| D — hazai piacra termelő KKV | 4,8% | 1,72 |
| L — nagyvállalat | 43,4% | 2,34 |

A tábla számai az Opten-panelből származó saját mérések. A tőkeáttétel sorrendje mérőfüggetlen, a szintje viszont sávban közlendő.

Az euró három csatornán hat:

- **Felár-konvergencia:** −200 bp szuverén és −45 bp banki felár, fokozatosan, 16 negyedév alatt.
- **Rezsimváltás:** a 13. negyedévtől megszűnik az önálló monetáris politika és az árfolyam.
- **Hitelhozzáférési (extenzív) margó:** a finanszírozási körülmények javulása növeli a hitelhez jutó cégek arányát. Ennek erejét két rugalmasság, `λ` és `ω` adja, perzisztenciáját a `rho_acc`.

A legfrissebb bővítés (v10) visszaköti a külföldi keresletet (`ystar`) az exportáló típusok keresleti egyenletébe, a külföldi kamatot (`r_for`) pedig a kamatparitásba. Ez a rész megépült, de még nincs lefuttatva és validálva, ezért eredményt nem közlünk belőle.

## Mit állítunk

Az aggregált hatás pozitív és robusztus. A KKV-k relatív előnye viszont csak egy küszöb fölött jelenik meg, ezért azt küszöbformában közöljük.

1. **GDP:** a tartós GDP-hatás +0,52% … +1,18%. Mind a 9 BK-stabil konfigurációban pozitív (3 felár-szcenárió × 3 transzmissziós változat).
2. **Programvezérelt hitelpiac:** 2021–24-ben a BUBOR 12,8 pontot mozgott, a hozzáférési arányok legfeljebb 2,2-t. A hazai KKV hozzáférése a kamatcsúcs felé még nőtt is (4,5% → 5,1%). Ezért a hozzáférési csatorna strukturális erejét ebből az időszakból nem lehet azonosítani.
3. **Küszöb:** a modell a két hozzáférési rugalmasságot külön nem azonosítja, csak a szorzatukat. A KKV-előny feltétele egy izo-szorzat görbe: `(λ·ω)* ≈ 500`, a feltételes `rho_acc = 0,9673` változat mellett.
4. **Nem technológiai műtermék:** ha a három típus technológiáját teljesen kiegyenlítjük, a küszöb csak 3%-kal mozdul (az ACCSCALE-skálán, ahol a küszöb √500 ≈ 22,36: 22,36 → 22,95). A KKV-eredményt tehát a pénzügyi heterogenitás viszi.

Azonosítási álláspontunk: az empirikus adatok a hozzáférési csatorna reduced-form hatásait azonosítják, a strukturális paramétert nem. Ezért az eredmény küszöbfüggő.

## Mit nem állítunk és miért

A projektben hatszor fordult elő, hogy egy horgonyzatlan paraméter vitte a szektorális eredményt, miközben az aggregált stabil maradt. Ezért az alábbiakat tudatosan nem közöljük.

| Amit nem közlünk | Miért |
| --- | --- |
| Szegmens-szintű kibocsátás pontbecslésként | Két horgonyzatlan paraméter (`eps_ces`, `ACCSCALE`) viszi, és mindkettőn megfordul az előjel. |
| A „KKV-k nagyobb előnye” pontszámként | Csak a `(λ·ω)*` küszöb fölött áll fenn, a küszöb pedig nem horgonyzott. |
| A magas perzisztenciájú (`OPTEN=1/2/3`) ágak számai | Terminálisan nem BK-stabilak (15 instabil gyök jut 13 előretekintő változóra). |
| A `rho_acc = 0,9673` mint empirikus horgony | Cégstátusz-leíró statisztika, főként állandó heterogenitást mér, nem a modell dinamikus állapotát. |
| A v10 külföldi csatorna bármely eredménye | Még nincs lefuttatva és validálva. |

Két nyitott alapértelmezés-konfliktus is van. A modell alapága `chi`-aszimmetriát (0,06 / 0,06 / 0,02) és `lev_E = lev_D = 1,6`-ot futtat, pedig az elsőt visszavontuk, a másodikat az adat megcáfolta. Hogy mire cseréljük őket, arról még döntenünk kell.

## Négy nyitott kérdés, ahol a legtöbbet segíthetsz

Nem kell mind a négyre válaszolni. Egy konkrét forrás, adat vagy egy „ez így nem védhető” egyetlen kérdésre többet ér, mint egy áttekintés mind a négyről.

1. **A −200 bp felár-konvergencia horgonya.** Ma hivatkozás nélküli kalibrált kontrafaktuális. Melyik csatlakozási tapasztalat (szlovák, balti, horvát) és milyen módszer adná a legjobb horgonyt a magyar szuverén és banki felárra?
2. **A `λ·ω` azonosítása.** A 2021–24-es hitelpiac programvezérelt volt. Van-e olyan kvázi-kísérlet (programjogosultsági küszöb, szabályváltozás időzítése), amely mégis a hozzáférési csatorna strukturális erejét azonosítaná, nem a program teljes finanszírozási hatását?
3. **A külföldi keresleti csatorna (v10).** A meglévő közös exportkeresleti sokk (`e_x_ar`) és az új `ystar` szétválasztása ma csak a perzisztencia-paramétereken múlik. A `rho_ystar`-ra 0,40 / 0,625 / 0,85-os érzékenységi rácsot használunk. Mi a magyar standard érték, és kell-e egyáltalán két külön csatorna?
4. **Az alapértelmezés-konfliktusok.** Ha nincs hivatkozott forrás egy KKV/nagyvállalati aszimmetriára, a szimmetrikus alapértelmezés a védhetőbb, vagy a legjobb becslésünk (akár horgonyzatlanul)?

## Gyakorlati információk

- **Időpont:** 2026. október 5., hétfő. Kezdés és helyszín: pontosítandó.
- **Formátum:** kb. 8 fős kerekasztal, közgazdász hallgatók és szakértők, 2 óra 15 perc. Menete: rövid bevezető, a modell mechanizmusainak közös végigvitele, egy euró-forgatókönyv, a KKV-eredményt hajtó paraméterek rangsorolása, bírálói kör (ezt nyitod te), végül döntések és felelősök.
- **Bizalmasság:** az anyag megbízásos munka részeredménye. Kérjük, ne add tovább, és ne idézd a számokat a workshopon kívül.
- **Háttér:** kérésre küldünk részletes módszertani leírást és a teljes paramétertáblát (91 paraméter, forrás szerint besorolva).
