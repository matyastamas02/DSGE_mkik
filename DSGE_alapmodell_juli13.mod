
% DSGE alapmodell - EAGLE-HU (Bekesi-Kaszab-Szentmihalyi: EAGLE model for Hungary) alapjan, MNB 2017
% MI EZ?
%   Uj-keynesi, kis nyitott gazdasag DSGE modell Magyarorszagra
%   egyenletei alapjan csak hazai blokkra redukalva
%   Cel: mukodo, kalibralhato alapmodell, amire a KKV/nagyvallalat
%   szegmentacio es az euro-bevezetes szcenariok epulnek meg at lehet gondolni

% A modell szerkezete (91 endogén változó, 17 sokk)

% - Háztartások: Ricardian 0.25 (megtakarítanak, kötvényt vasarolnak, külföldi eszközt tartanak, előretekintő dönteseket hoznak, itt minden I indexel van) +
%  hand-to-mouth/non-Ricardian (ω=0.75 tanulmanybol), (J jelöli, fogyasztas/real penzallomany/ fogyasztas hatarhaszna/munkakinalat/penz forgasi sebessege)

% - Termelés: tradable azaz külkereskedelembe vonhato termekek + non-tradable szektor nem külkereskedelmezhető, mindkettő inputja a toket es a munka (Calvo arazassal)
% itt ugye a Cobb-Douglas költsegminimalizasabol jon a modell ket elso rendu feltetele az alphak
%Fontos elteres van a kettonel aszerint, hogy ki vasarolja a termeket: tradable (fogyasztas + beruhazas + export van a keresleti oldalon) míg non-tradable eseteben (fogyasztas + beruházás + kormányzat)
%Sot a rugalmassagot jelolo teta is elter miszerint kevesbe helyettesíthetőek a non-tradable termekek.
%Elter meg a markup (amennyivel dragabban adja el a vállalat a termeket, amennyibe az utolso egyseg eloallitasa kerul, tehat ar/hatarköltseg): tradable-nel 20% az arres, non-tnel 50%
% Van meg egy export szektor is de ez a hazai tradable joszagokat kombinalja az importalttal, mert a magyar export importtartalma magas (tanulmany szerint 55%)
% - Export szektor: hazai tradable + import inputból CES-bundle,
% exogén AR(1) export-kereslet (egyblokkos redukció)

% - Árazás: Calvo (ξ=0.75) ez mas mint a tanulmanyban mert ott 0.92 (ami volt ugye ez abbol jon hogy milyen gyakran változtatnak ténylegesen árat a cégek, kvazi artartossag)
%   tehat a Cobb Douglasbol jön az rmc határköltség es a Calvo arazas megmondja, hogy milyen lassan követi a termék ára ezt a határköltséget
% Szektoronkent három philips görbe van, mint sajat hatarkoltseggel, markuppal es inflacioval es a pi_C a CPI-inflacio a szektorialis inflaciok kombinacioja
% Ugye ez ertelmezheto, mert pl egy forint leertekelodeskor az export szektor inputja dragul mig mas szektorra ez nem ugy hat es eltero pi_-ket ad

%- Külföld: ra hazai és külföldi eszközök közötti nem-arbitrázs feltetelt reál fedezetlen kamatparitás (UIP) adja + SGU adósság-rugalmas kockázati prémium (γ_B*=0.1) teszi stacionáriussa(ha az ország külfölddel szemben eladósodik, a külföldi finanszírozás drágul, ami visszahúzza az eszközpozíciót a fenntartható szintre) 
% + reálárfolyam (rer) importarakon es keri merlegen keresztul kapcsolja a gazdasagot kulfoldhoz
%mi törtenhet az euro bevezetesekor itt? csökkenhet az rp_schock mert csokken az orszagkockazati premiu
%R=R_star az onallo monetaris politika hianya vegett a kamat
%euro bevezetessel a nominális árfolyam rogzul, rer csak a relatív árakon keresztül mozoghat, ami ragadós árak mellett lassú

% - Monetáris politika: Taylor-szabály (φ_π=1.7, φ_Y=0.1, φ_R=0.87, jelenlegi évesített inflációra)
%monetáris hatóság a nominális kamatot (R) egy Taylor-típusú kamatszabály szerint állítja be, amey az
% évesített CPI-inflációnak a céltól való eltérésére (φ_π = 1,70) és a kibocsátás növekedési ütemére (φ_Y = 0,10) reagál,eros kamatsimítással (φ_R = 0,87). Mivel φ_π > 1, a szabály kielégíti a Taylor-elvet (inflációs nyomásra a jegybank a reálkamatot emeli)
% A szabályhoz iid monetáris politikai sokk (ε_R) is tartozik.
%A magas non-Ricardian arány miatt a kamatcsatorna közvetlenül csak a háztartások (1−ω) hányadát érinti
%MI MÁS?? a szabály a jelenlegi évesített inflációra reagál (nem a négy negyedév mozgóátlagára)


% - Fiskális politika: teljes költségvetési korlát, hat adónem (τ_C, τ_D, τ_K, τ_N, τ_Wf, τ_Wh), adósság-stabilizáló szabály (φ_B=0.1)
%azaz a kormányzat hat torzító adóból (fogyasztás, munka [munkavállalói és munkáltatói járulék], tőke, osztalék) és lump-sum adóból finanszírozza a kizárólag non-tradable 
%termékből állóközösségi vásárlásait és a háztartási transzfereket + az államadósságot egy lump-sum adón keresztül működő, adósság-stabilizáló fiskális szabály tartja fenntartható pályán (a lump-sum adó a cél feletti adósság/GDP aránynál emelkedik)
%kormányzati kiadás/transzferek exogén AR(1) folyamatokat követnek
% Forma teljesen REÁL (minden ár CPI-hez relatív, nominális mennyiségek deflálva) — így nincs árszint-egységgyök a Calude szerint

 %Elteresek az MNB-stol a Claude szerint:
% 1. Egyblokkos (csak HU): a külföld exogén — q_X  Az export iránti keresletet exogén AR(1) folyamat (q_X_final) reprezentálja
%  import relatív árak a reálárfolyamhoz kötve (p_IMC=rer, p_IMX=0.5533·rer)
% 2. Rugalmas bérek: a bér-Calvo (f/g rekurziók) nincs benne — a bért a
%  munkapiaci tisztulás + munkakínálati FOC-ok határozzák meg
% 3. Nincs ár-indexálás (γ=0, tiszta előretekintő NKPC) — a 0.5-ös
%  indexálás + magas rigiditás determináltsági problémát okozott
% 4. ξ=0.75 a tanulmány 0.92-je helyett (a 0.92-es "lapos Phillips-görbe"
%   indeterminációt okozott; 0.75 = standard benchmark)
% 5. Taylor-szabály jelenlegi (évesített) inflációra reagál, nem a
% 4 negyedéves átlagra (utóbbi + erős simítás = klasszikus indetermináció)
% 6. Nulla trendinfláció (π̄=1) — a level-árak stacionaritásához
% 7. α_NT=0.377 (≠α_T=0.3): kalibrációs kényszer, hogy mc_NT=1/markup_NT
%  teljesüljön közös (r_K, w) mellett — később finomítható szektor-TFP-vel
% 8. Import-alkalmazkodási költségek kihagyva (a keresleti egyenletek
%  tiszta CES-ek)
% 9. G/Y=20%, tb=0, b_star=0 a steady state-ben (a tanulmány Table 4/6
%   arányai helyett saját)

% finomítási pontok a CLAUDE szerint:
% - n≈0.78 steady-state munkakínálat magas (nincs skálázó paraméter a munka-diszutilitásban) — kalibrálható
% - Rugalmas bérek → volatilis reálbér/határköltség a momentumokban
%  (bér-rigiditás visszaépítése csillapítaná)
% - Néhány változó autokorrelációja oszcilláló (komplex gyökpár) —
% bér-rigiditással szintén simulna
% - Varianciafelbontás: y-t a markup_X + export-kereslet sokkok dominálják
% (kis nyitott gazdaságra nem irreális, de a sokk-szórások még nyersek)

% EGYSZERUSITESEK A TANULMANYHOZ KEPEST Claudedal megfogalmaztatva:
% Mindegyik pontnal: MIT csinal a tanulmany -> MIT csinalunk helyette -> MIERT -> KOVETKEZMENY
%
% 1) EGYBLOKKOS SZERKEZET (a tanulmany 4-blokkos)
%    A tanulmany negy regiot modellez egyutt (Magyarorszag, eurozona, USA,
%    a vilag tobbi resze), mindegyiket teljes DSGE-blokként, endogen
%    haztartasokkal es vallalatokkal, kozottuk kereskedelmi es penzugyi
%    kapcsolatokkal (~250 egyenlet/blokk). Mi CSAK a magyar blokkot
%    tartjuk meg, a kulfoldet EXOGENNE tesszuk: a kulfoldi kamat (R_star)
%    konstans, az export irant tamasztott kereslet (q_X_final) exogen
%    AR(1) folyamat, az importarakat pedig a realarfolyamhoz kotjuk.
%    KOVETKEZMENY: nem tudjuk vizsgalni a kulfoldi sokkok visszagyuruzeset
%    (spillover), es a cserearany sem teljesen endogen. Cserebe a modell
%    kezelhet (91 egyenlet), es a KKV/euro-kerdeshez ez eppen eleg reszletes.
%
% 2) RUGALMAS BEREK (a tanulmanyban Calvo-berek = ragadós berek)
%    A tanulmanyban a haztartasok a bert is Calvo-modon allitjak (egy
%    reszuk nem tud atallitani berezni), sajat rekurziv segedvaltozokkal.
%    Mi ezt ELHAGYJUK: a ber (wr) RUGALMAS, azt a munkapiaci tisztulas
%    (kinalat=kereslet) es a haztartasok munkakinalati FOC-jai hatarozzak
%    meg minden idoszakban. KOVETKEZMENY: a realber azonnal alkalmazkodik,
%    ezert a szimulaciokban volatilisebb; a ber-merevsegi (bér-Phillips)
%    csatorna hianyzik. A ber-Calvo kesobb visszaepitheto (simitana a bert).
%
% 3) REDUKALT-FORMAJU (LINEARIZALT) PHILLIPS-GORBE
%    A tanulmany a teljes NEMLINEARIS Calvo-arazast irja fel, rekurziv
%    f_t / g_t segedvaltozokkal (az optimalis atallitasi ar szamlaloja es
%    nevezoje). Mi kozvetlenul a MASODIK RENDBEN ekvivalens, elteres-formaju
%    uj-keynesi Phillips-gorbet (NKPC) irjuk fel:
%      pi - 1 = beta*(pi(+1)-1) + kappa*(realhatárköltseg - 1/markup),
%    ahol kappa = (1-xi)(1-xi*beta)/xi a standard Calvo-meredekseg.
%    MIERT nincs veszteseg: a modellt ELSO RENDBEN oldjuk meg (order=1),
%    igy a Dynare ugyis linearizal; a teljes rekurzio elso rendu (log-
%    linearis) kozelitese a zero-inflacios steady state korul PONTOSAN ez
%    az NKPC. Elso rendben tehat a ket feliras azonos dinamikat ad.
%
% 4) DETERMINALTSAGI OKOKBOL MODOSITOTT ARAZASI/POLITIKAI PARAMETEREK
%    Harom, egyenkent is standard valasztas, amelyek egyutt biztositjak,
%    hogy a modellnek EGYERTELMU (determinalt) megoldasa legyen:
%    (a) Arragadóssag: xi=0.75 a tanulmany xi=0.92-je helyett. A 0.92
%        atlagosan ~12,5 negyedeves (3 eves!) aralkalmazkodast jelent,
%        ami tul lapos Phillips-gorbet -> indeterminaciot ad. A 0.75
%        (~4 negyedeves atarazas) a standard benchmark, meredekebb gorbe.
%    (b) Ar-indexalas: KIKAPCSOLVA (gamma=0), a tanulmany 0.5-os
%        (mult-inflaciohoz kotott) indexalasa helyett -> tiszta
%        elore-tekinto NKPC (Gali-tipus).
%    (c) Taylor-szabaly: a JELENLEGI evesitett inflaciora reagal
%        (pi_C^4), nem a 4 negyedev MOZGOATLAGARA. A mozgoatlag + eros
%        kamatsimitas a jelenlegi inflaciora tul gyenge (~0,055) azonnali
%        valaszt adott -> klasszikus "kesleltetett inflacios cel"
%        indeterminacio (Woodford; Carlstrom-Fuerst).
%    Mindharom SS-SEMLEGES (a steady state-et nem valtoztatja). A
%    tanulmany ertekeihez kesobb kozelithetunk tovabbi frikciok mellett.
%
% 5) NULLA TRENDINFLACIO (pi_target = 1, a tanulmany 1.03 = 3%/ev helyett)
%    A zero-inflacios steady state a standard benchmark: (i) itt ervenyes
%    pontosan a fenti standard NKPC-meredekseg (kappa) keplete -- pozitiv
%    trendinflacio mellett a Phillips-gorbe tovabbi tagokat kapna; (ii) a
%    steady state egyszerusodik (minden relativ ar es ar-diszperzio pontosan. KOVETKEZMENY: a modell a trendinflacio koruli ingadozasokat irja
%    le; ha explicit 3%-os trendinflacio kellene, az NKPC-ket es a
%    steady state-et annak megfeleloen kellene ujraszamolni.

%==========================================================================
% ENDOGEN VALTOZOK (91 db) - zarojelben a steady-state ertek (Az állandósult állapotot analitikusan-numerikusan vezetjük le, így nyilvan jot fog kidobni a dyner))


var
% ---------- RICARDIAN HAZTARTAS (megtakarito tipus, 25%) ----------
c_I              % fogyasztas per fo (SS: 3.378)
k_I              % tokeallomany per fo - ok birtokoljak az OSSZES toket (SS: 53.54)
i_I              % beruhazas per fo (SS: 1.338)
rm_I             % REAL penzallomany per fo, M_I/P_C (SS: 1.755)
q_I              % Tobin-fele Q: a beepitett toke erteke beruhazasi jogszagban (SS: 1)
u_I              % tokehasznositasi rata (SS: 1)
lambda_I         % fogyasztas hatarhaszna / arnyekara (SS: 0.502)
v_I              % penzsebesseg: (1+tau_C)*P_C*C_I/M_I (SS: 2.349)
gamma_v_I        % penztartasi (tranzakcios) koltsegfuggveny erteke (SS: ~0)
gamma_v_prime_I  % annak derivaltja v szerint (SS: 0.0018)
gamma_u_I        % tokehasznositasi koltsegfuggveny erteke (SS: 0)
gamma_u_prime_I  % annak derivaltja u szerint (SS: 0.0375 = r_K)
gamma_I_I        % beruhazasi alkalmazkodasi koltseg erteke (SS: 0)
gamma_I_prime_I  % annak derivaltja (SS: 0)
% ---------- NON-RICARDIAN HAZTARTAS ( 75%) -----------
% Nem tud megtakaritani/hitelt felvenni; minden jovedelmet elkolt.
% Egyetlen vagyoneszkoze a keszpenz (cash-in-advance).
c_J              % fogyasztas per fo (SS: 0.869)
rm_J             % real penzallomany per fo (SS: 0.451)
lambda_J         % fogyasztas hatarhaszna (SS: 0.864)
v_J              % penzsebesseg (SS: 2.349)
gamma_v_J        % penztartasi koltseg (SS: ~0)
gamma_v_prime_J  % derivalt (SS: 0.0018)

% ---------- AGGREGATUMOK (omega-sulyos atlagok) -----------------------
c                % aggregalt fogyasztas = (1-om)*c_I + om*c_J (SS: 1.496)
rm               % aggregalt real penz (SS: 0.777)
k                % aggregalt toke = (1-om)*k_I (SS: 13.38)
i                % aggregalt beruhazas = (1-om)*i_I (SS: 0.335)
n                % aggregalt munka (SS: 0.777)
n_I_agg          % Ricardian munkakinalat per fo (SS: 0.630)
n_J_agg          % non-Ricardian munkakinalat per fo (SS: 0.826)
b                % REAL allamadossag, B/P_C (SS: 1.875)
b_star           % REAL nettó kulfoldi eszkozpozicio (SS: 0)
% ---------- REAL BER ------------------------------------------------------
wr               % real ber W/P_C - a munkapiaci tisztulas hatarozza meg (SS: 1.079)
% ---------- TRADABLE SZEKTOR (exportkepes termekek) ----------------
y_T              % kibocsatas (SS: 1.140)
k_d_T            % tokekereslet (SS: 7.607)
n_d_T            % munkakereslet (SS: 0.506)
rmc_T            % REAL hatarkoltseg MC_T/P_C (SS: 0.8333 = rp_T/markup_T)
rp_T             % relativ ar P_T/P_C (SS: 1)
pi_T             % szektoralis inflacio P_T/P_T(-1) (SS: 1)
s_T              % Calvo ar-diszperzio (termeleshatekonysag-veszteseg; SS: 1)

% ---------- NON-TRADABLE SZEKTOR (szolgaltatasok stb.) ------------
y_NT             % kibocsatas (SS: 0.861)
k_d_NT           % tokekereslet (SS: 5.777)
n_d_NT           % munkakereslet (SS: 0.272)
rmc_NT           % real hatarkoltseg (SS: 0.6667 = rp_NT/markup_NT)
rp_NT            % relativ ar (SS: 1)
pi_NT            % szektoralis inflacio (SS: 1)
s_NT             % ar-diszperzio (SS: 1)

% ---------- EXPORT SZEKTOR ---------------------------------------
% Az export jav hazai tradable + importalt inputbol keszul (CES).
% Ez adja a magyar gazdasag magas "export importtartalmat" (~40% ktsg-arany).
rmc_X            % export jav real hatarkoltsege (SS: 0.8333)
rp_X             % export jav relativ ara (SS: 1)
pi_X             % export-ar inflacio (SS: 1)
q_X_final        % export volumen - EXOGEN AR(1) kereslet (SS: 1.728)
h_T_X            % hazai tradable input az exportba (SS: 0.855)
im_X             % importalt input az exportba (SS: 1.058)

% ---------- FOGYASZTASI VEGSO JAV (ketszintu CES bundle) ----------
% Kulso szint: tradable bundle (tt_c) vs non-tradable (n_T_c)
% Belso szint: hazai tradable (h_T_c) vs import (im_c)
q_C              % fogyasztasi vegso jav (SS: 1.496)
tt_c             % tradable fogyasztasi al-bundle (SS: 1.167)
h_T_c            % hazai tradable komponens (SS: 0.233)
n_T_c            % non-tradable komponens (SS: 0.329)
im_c             % import komponens (SS: 0.934)
rp_TTC           % tradable al-bundle relativ ara (SS: 1)

% ---------- BERUHAZASI VEGSO JAV (ugyanez a szerkezet) ----------
q_I_final        % beruhazasi vegso jav (SS: 0.335)
tt_i             % tradable al-bundle (SS: 0.261)
h_T_i            % hazai tradable komponens (SS: 0.052)
n_T_i            % non-tradable komponens (SS: 0.074)
im_i             % import komponens (SS: 0.209)
rp_I             % beruhazasi jav relativ ara (SS: 1)
rp_TTI           % tradable al-bundle relativ ara (SS: 1)

% ---------- AGGREGALT KERESLET A KOZBENSO JAVAK IRANT -----------------------------
h_T_t            % hazai tradable ossz-kereslet = h_T_c+h_T_i+h_T_X (SS: 1.140)
n_T_t            % non-tradable ossz-kereslet = n_T_c+n_T_i+g (SS: 0.861)

% ---------- MAKRO / PENZUGYI VALTOZOK ----------
y                % real GDP, kiadasi oldalrol (SS: 2.289)
div              % aggregalt vallalati profit/osztalek - a Ricardianoke (SS: 0.765)
tb               % kereskedelmi merleg (SS: 0)
r_K              % toke real berleti dija (SS: 0.0375)
R                % NOMINALIS brutto kamat, a Taylor-szabaly eszkoze (SS: 1.0101=1/beta)
pi_C             % CPI (fogyasztoi) inflacio (SS: 1)
pi_C_4           % evesitett CPI-inflacio = pi_C^4, a Taylor-szabalyban (SS: 1)
rer              % REALARFOLYAM: S*P^kulf/P_C; novekedes = real leertekelodes (SS: 1)
nfa_ratio        % NFA/GDP arany (a kockazati premiumhoz; SS: 0)
gamma_B_adj      % adossag-rugalmas kockazati premium (SGU-zaras; SS: 0)

% ---------- FISKALIS VALTOZOK ----------
g                % kormanyzati fogyasztas - AR(1), csak non-tradable-t vesz (SS: 0.458)
tr               % transzferek haztartasoknak - AR(1) (SS: 0.046)
T                % lump-sum ado (negativ = tamogatas) - adossag-szabaly (SS: -0.362)

% ---------- SOKK-FOLYAMATOK (AR(1) allapotvaltozok) ----------
a_T              % TFP a tradable szektorban (SS: 1)
a_NT             % TFP a non-tradable szektorban (SS: 1)
markup_T         % tradable markup-sokk folyamat (SS: 1.2)
markup_NT        % non-tradable markup (SS: 1.5)
markup_X         % export markup (SS: 1.2) - pl. olajar-sokk igy modellezheto
chi_pref         % fogyasztasi preferencia-sokk (SS: 1)
rp_shock         % orszagspecifikus kockazati premium sokk (SS: 0)
tau_C tau_D tau_K tau_N tau_Wf tau_Wh   % ado-folyamatok (AR(1) a kulcsok korul)
;

%==========================================================================
% EXOGEN SOKKOK (17 db, iid innovaciok az AR(1) folyamatokhoz)

varexo
eps_a_T eps_a_NT             % TFP-sokkok (tradable / non-tradable)
eps_markup_T eps_markup_NT eps_markup_X   % markup- (koltseg-) sokkok
eps_chi                      % fogyasztasi preferencia-sokk
eps_R_mon                    % monetaris politikai sokk (Taylor-hiba)
eps_g_spend eps_tr_transfer  % fiskalis sokkok (kiadas / transzfer)
eps_rp                       % kockazati premium sokk (tokeaR-menekules)
eps_X_demand                 % kulfoldi (export-) keresleti sokk
eps_tau_C_shock eps_tau_D_shock eps_tau_K_shock eps_tau_N_shock
eps_tau_Wf_shock eps_tau_Wh_shock         % ado-sokkok
;

%==========================================================================
% PARAMETEREK

parameters
beta sigma chi kappa omega delta alpha alpha_NT
mu_C v_C mu_TC v_TC mu_I v_I_bundle mu_TI v_TI mu_X v_X
theta_T theta_NT xi_T xi_NT
gamma_T gamma_NT gamma_X kappa_T kappa_NT kappa_X
gamma_I gamma_u_1 gamma_u_2 gamma_B_star gamma_v_1 gamma_v_2
phi_R phi_pi phi_Y pi_target_q R_bar R_star
phi_B B_Y_target
tau_C_ss tau_D_ss tau_K_ss tau_N_ss tau_Wf_ss tau_Wh_ss
rho_a_T rho_a_NT rho_markup_T rho_markup_NT rho_markup_X rho_chi
rho_X_demand rho_g rho_tr rho_rp
rho_tau_C rho_tau_D rho_tau_K rho_tau_N rho_tau_Wf rho_tau_Wh
markup_T_ss markup_NT_ss markup_X_ss
pimx_scale g_ss tr_ss qX_ss
;

%==========================================================================
% KALIBRACIO - forras: MNB WP 2017/7 Table 1-3, 5 (HU oszlop),
% kiveve ahol jelezve (determinaltsagi vagy konzisztencia-okokbol elterve)


% --- Haztartasi preferenciak (Table 1) ---
beta = 0.99;     % diszkontfaktor -> SS real kamat = 1/beta = 4.1%/ev
sigma = 0.4;     % relativ kockazatkerules; IES = 1/0.4 = 2.5 (magas, a tanulmanybol)
chi = 2.0;       % Frisch-rugalmassag inverze (munkakinalati gorbe meredeksege)
kappa = 0.7;     % fogyasztasi szokasok (habit) - simitja a fogyasztast
omega = 0.75;    % non-Ricardian (hand-to-mouth) haztartasok aranya - HU-ra magas!
delta = 0.025;   % toke amortizacio (negyedeves, ~10%/ev)

% --- Termeles (Table 1) ---
alpha = 0.3;             % toke reszaranya a tradable szektorban
% alpha_NT KALIBRALT (nem a tanulmanybol): ugy, hogy kozos (r_K, w) mellett
% rmc_NT = 1/markup_NT pontosan teljesuljon SS-ben. A tanulmany kozos
% alpha-ja a ket szektor elteroo markupjaval (1.2 vs 1.5) SS-ellentmondast
% adna. Kesobb finomithato pl. eltero szektoralis TFP-szinttel.
alpha_NT = 0.37727595;

% --- CES sulyok es rugalmassagok (Table 1) ---
% mu = helyettesitesi rugalmassag, v = sulyparameter a CES-ben
mu_C = 0.50;   v_C = 0.78;    % fogyasztas: tradable vs non-tradable
mu_TC = 2.50;  v_TC = 0.20;   % tradable fogyasztas: hazai vs IMPORT (import-sulyos!)
mu_I = 0.50;   v_I_bundle = 0.78;  % beruhazas: tradable vs non-tradable
mu_TI = 2.50;  v_TI = 0.20;   % tradable beruhazas: hazai vs import
mu_X = 2.50;   v_X = 0.78;    % export: hazai tradable vs importalt input

% --- Arrigiditas (Table 2 es 5) ---
theta_T = 6.0;   % tradable termekvaltozatok helyettesitesi rugalmassaga (markup=1.2)
theta_NT = 3.0;  % non-tradable (markup=1.5)
% xi = Calvo-parameter: annak valoszinusege, hogy egy ceg NEM arazthat ujra.
% ELTERES: a tanulmany 0.92-je "tul lapos" Phillips-gorbet adott ->
% indeterminacio. 0.75 = standard (atlagosan 4 negyedevente uj ar).
xi_T = 0.75;  xi_NT = 0.75;
% Ar-indexalas (hatratekinto tag sulya az NKPC-ben).
% ELTERES: kikapcsolva (0), mert a magas rigiditas + 0.5-os indexalas
% determinaltsagi problemat okozott. Tiszta elore-tekinto NKPC (Gali).
gamma_T = 0.0; gamma_NT = 0.0; gamma_X = 0.0;
% NKPC meredekseg: kappa = (1-xi)(1-xi*beta)/xi; xi=0.75 -> 0.0858
kappa_T = 0.08583333; kappa_NT = 0.08583333; kappa_X = 0.08583333;

% --- Alkalmazkodasi koltsegek (Table 2) ---
gamma_I = 6.0;          % beruhazasi alkalmazkodas (i_t/i_{t-1} valtozasat bunteti)
% gamma_u_1 KALIBRALT: = r_K_ss, hogy u=1 legyen SS-ben (a toke-Euler
% egyenletbol levezetett r_K_ss = [1-beta(1-delta)-beta*tau_K*delta]/[beta(1-tau_K)])
gamma_u_1 = 0.03747038;
gamma_u_2 = 2000.0;     % tokehasznositas valtoztatasa nagyon draga (Table 2)
% SGU adossag-rugalmas kockazati premium: stabilizalja az NFA-t.
% ELTERES: 0.01 -> 0.1 (a hatarozott determinaltsaghoz; SS-semleges).
gamma_B_star = 0.1;
gamma_v_1 = 0.029; gamma_v_2 = 0.15;   % penztartasi koltseg (NAWM-forma) parameterei

% --- Monetaris politika: Taylor-szabaly (Table 3) ---
phi_R = 0.87;        % kamatsimitas
phi_pi = 1.70;       % inflacios valasz (>1: Taylor-elv teljesul)
phi_Y = 0.10;        % kibocsatas-novekedesi valasz
pi_target_q = 1.00;  % ELTERES: nulla trendinflacio (a tanulmany 3%-os celja
                     % a level-arak nemstacionaritasat okozna a mi formankban)
R_bar = 1.01010101;  % SS nominalis kamat = 1/beta (Fisher-relacio, pi=1 mellett)
R_star = 1.01010101; % kulfoldi kamat (exogen konstans; = hazai SS kamat, igy NFA=0 fenntarthato)

% --- Fiskalis politika (Table 3) ---
phi_B = 0.10;        % lump-sum ado valasza az adossag/GDP eltereserre
B_Y_target = 2.40;   % adossag/GDP cel (negyedeves GDP-re vetitve = 60%/ev)

% --- Adokulcsok steady state (Table 3, HU) ---
tau_C_ss = 0.22;     % fogyasztasi ado (AFA-jellegu)
tau_D_ss = 0.15;     % osztalekado
tau_K_ss = 0.19;     % tokejovedelm-ado
tau_N_ss = 0.15;     % szemelyi jovedelemado
tau_Wf_ss = 0.219;   % munkaltatoi jarulek
tau_Wh_ss = 0.118;   % munkavallaloi jarulek

% --- Sokk-perzisztenciak (standard 0.95, kesobb becsulendo!) ---
rho_a_T = 0.95; rho_a_NT = 0.95;
rho_markup_T = 0.95; rho_markup_NT = 0.95; rho_markup_X = 0.95;
rho_chi = 0.95; rho_X_demand = 0.95;
rho_g = 0.95;   rho_tr = 0.95;  rho_rp = 0.95;
rho_tau_C = 0.95; rho_tau_D = 0.95; rho_tau_K = 0.95;
rho_tau_N = 0.95; rho_tau_Wf = 0.95; rho_tau_Wh = 0.95;

% --- Markupok (Table 5) ---
markup_T_ss = 1.20; markup_NT_ss = 1.50; markup_X_ss = 1.20;

% --- Levezetett skala-konstansok (sajat SS-levezetes) ---
% pimx_scale: az export-input importar szintje ugy kalibralva, hogy
% rmc_X = 1/markup_X pontosan teljesuljon SS-ben (kulonben pi_X != 1 lenne)
pimx_scale = 0.55330529;
g_ss = 0.45777549;   % G/Y = 20% a levezetett SS-ben
tr_ss = 0.04577755;  % transzferek = 2% GDP
qX_ss = 1.72824268;  % export-kereslet szintje ugy, hogy tb=0 SS-ben

%==========================================================================
% MODELL - 91 egyenlet
%==========================================================================
model;

%--------------------------------------------------------------------------
% 1. RICARDIAN HAZTARTAS
%    Max E0 sum beta^t [ (xi_t*(C-kappa*C(-1))/(1-kappa))^(1-sigma)/(1-sigma)
%                        - N^(1+chi)/(1+chi) ]
%    Vagyoneszkozei: toke, hazai kotveny, kulfoldi kotveny, penz.
%    A tanulmany 3.2.1 / 7.1 szakaszanak FOC-jai, real formaban.
%--------------------------------------------------------------------------

% Penztartasi (tranzakcios) koltseg:
% Gamma_v(v) = gv1*v + gv2/v - 2*sqrt(gv1*gv2)  >= 0, minimuma v*-nal.
% A fogyasztas "effektiv ara" (1+tau_C+Gamma_v)*P_C - a penztartas csokkenti
% a tranzakcios koltseget (cash-in-advance motivacio).
gamma_v_I = gamma_v_1 * v_I + gamma_v_2 / v_I - 2 * sqrt(gamma_v_1 * gamma_v_2);
gamma_v_prime_I = gamma_v_1 - gamma_v_2 / (v_I^2);

% A fogyasztas hatarhaszna (Lagrange-multiplikator).
% Szamlaloban: hatarhaszon habit-tal (chi_pref = preferencia-sokk);
% nevezoben: a fogyasztas effektiv relativ ara (ado + tranzakcios ek).
lambda_I = ((chi_pref * (c_I - kappa * c_I(-1)) / (1 - kappa))^(-sigma)) /
           (1 + tau_C + gamma_v_I + gamma_v_prime_I * v_I);

% Hazai kotveny Euler-egyenlete: a megtakaritas hataraldozata = hozama.
% R_t mar t-ben ismert nominalis kamat; pi_C(+1) valtja realra.
% Ez az egyenlet koti ossze a monetaris politikat a realgazdasaggal!
beta * R * (lambda_I(+1) / lambda_I) / pi_C(+1) = 1;

% Penztartasi Euler: a penz hozama (likviditasi szolgalat) = alternativa-
% koltsege. A kotveny-Eulerrel kombinalva: 1/R = 1 - v^2*Gamma_v'(v),
% azaz a penzkereslet a nominalis kamattol fugg (LM-gorbe jelleg).
beta * (lambda_I(+1) / lambda_I) / pi_C(+1) = 1 - (v_I^2) * gamma_v_prime_I;

% Penzsebesseg definicioja (real formaban P_C kiesik):
v_I = (1 + tau_C) * c_I / rm_I;

% --- Kulfoldi kotveny blokk (UIP + SGU-zaras) ---
% NFA/GDP arany (a 300-as szorzo az eredeti nominalis arfolyam-szint
% normalizacio oroksege - csak skala, a dinamikat nem befolyasolja):
nfa_ratio = 300 * rer * b_star / y;
% Adossag-rugalmas kockazati premium (Schmitt-Grohe-Uribe zaras):
% ha az orszag eladosodik kulfold fele (b_star<0), a kulfoldi hitel
% dragabb lesz -> stabilizalja az NFA-t. rp_shock = premium-sokk.
gamma_B_adj = gamma_B_star * (exp(nfa_ratio) - 1) - rp_shock;
% REAL fedezetlen kamatparitas (UIP): a hazai es kulfoldi megtakaritas
% varhato hozama kiegyenlitodik; rer(+1)/rer = varhato real leertekelodes.
beta * R_star * (1 - gamma_B_adj) * (lambda_I(+1) / lambda_I) * (rer(+1) / rer) = 1;

% --- Toke blokk ---
% Tokehasznositasi koltseg: Gamma_u(u) = gu1*(u-1) + gu2/2*(u-1)^2.
% gu1 = r_K_ss biztositja, hogy SS-ben u=1 optimalis legyen.
gamma_u_I = gamma_u_1 * (u_I - 1) + (gamma_u_2 / 2) * (u_I - 1)^2;
gamma_u_prime_I = gamma_u_1 + gamma_u_2 * (u_I - 1);
% Hasznositas FOC: a tobblet-hasznositas hozadeka = hatarkoltsege:
r_K = gamma_u_prime_I * rp_I;

% Beruhazasi alkalmazkodasi koltseg: a beruhazas NOVEKEDESI UTEMENEK
% valtoztatasat bunteti (i/i(-1) - 1)^2 formaban -> simitja a beruhazast.
gamma_I_I = (gamma_I / 2) * ((i_I / i_I(-1)) - 1)^2;
gamma_I_prime_I = gamma_I * ((i_I / i_I(-1)) - 1);

% Tokefelhalmozas (Dynare konvencio: k_I = periodus VEGI allomany,
% ezert k_I(-1) az orokolt toke - NEM k_I(+1)=... forma!):
k_I = (1 - delta) * k_I(-1) + (1 - gamma_I_I) * i_I;

% Beruhazasi FOC (Tobin-Q feltetel): egy egyseg beruhazas koltsege
% (rp_I) = a letrejovo toke erteke (q_I), korrigalva az alkalmazkodasi
% koltseggel es annak jovobeli megtakaritasaval:
rp_I = q_I * (1 - gamma_I_I - gamma_I_prime_I * (i_I / i_I(-1))) +
       beta * (lambda_I(+1) / lambda_I) * q_I(+1) *
       (gamma_I * ((i_I(+1) / i_I) - 1)) * ((i_I(+1) / i_I)^2);

% Toke-Euler (eszkozarazas): a toke ma feladott fogyasztasertekenek
% meg kell terulnie holnap: tovabb-eladasi ertek (1-delta)*q_I(+1)
% + adozott berleti dij + ado-pajzs az amortizacion - hasznositasi ktsg.
q_I = beta * (lambda_I(+1) / lambda_I) * (
      (1 - delta) * q_I(+1) +
      (1 - tau_K(+1)) * r_K(+1) * u_I(+1) +
      (tau_K(+1) * delta - (1 - tau_K(+1)) *
       (gamma_u_1 * (u_I(+1) - 1) + (gamma_u_2 / 2) * (u_I(+1) - 1)^2))
      * rp_I(+1) );

% Munkakinalati FOC: a munka hatar-diszutilitasa (N^chi) = az adozott
% real ber fogyasztas-ertekben. RUGALMAS BER (a ber-Calvo egyszerusitese).
n_I_agg^chi = lambda_I * (1 - tau_N - tau_Wh) * wr;

%--------------------------------------------------------------------------
% 2. NON-RICARDIAN (HAND-TO-MOUTH) HAZTARTAS
%    Nincs hozzaferese toke-/kotvenypiachoz; a folyo jovedelmet elkolti.
%    A tanulmany 3.2.2 / 7.2 szakasza. Az euro-hatas szempontjabol
%    kulcsfontossagu tipus: a KKV-alkalmazottak/likviditaskorlatosok proxy-ja.
%--------------------------------------------------------------------------
gamma_v_J = gamma_v_1 * v_J + gamma_v_2 / v_J - 2 * sqrt(gamma_v_1 * gamma_v_2);
gamma_v_prime_J = gamma_v_1 - gamma_v_2 / (v_J^2);

lambda_J = ((chi_pref * (c_J - kappa * c_J(-1)) / (1 - kappa))^(-sigma)) /
           (1 + tau_C + gamma_v_J + gamma_v_prime_J * v_J);

% Penz-Euler (az egyetlen intertemporalis dontesuk: mennyi keszpenzt
% vigyenek at a kovetkezo idoszakra):
beta * (lambda_J(+1) / lambda_J) / pi_C(+1) = 1 - (v_J^2) * gamma_v_prime_J;

v_J = (1 + tau_C) * c_J / rm_J;

% Koltsegvetesi korlat (BINDING - ez hatarozza meg c_J-t!):
% kiadas (fogyasztas adoval+tranzakcios ktsg + penzallomany-valtozas)
% = adozott berjovedelem + transzfer - lump-sum ado.
% rm_J(-1)/pi_C: a tavalyi penz real erteket az inflacio erodalja!
(1 + tau_C + gamma_v_J) * c_J + rm_J - rm_J(-1) / pi_C =
    (1 - tau_N - tau_Wh) * wr * n_J_agg + tr - T;

% Munkakinalati FOC (sajat lambda_J-vel -> tobbet dolgoznak, mert
% szegenyebbek: n_J > n_I a steady state-ben):
n_J_agg^chi = lambda_J * (1 - tau_N - tau_Wh) * wr;

%--------------------------------------------------------------------------
% 3. AGGREGACIO (tanulmany 7.5: X = (1-omega)*X_I + omega*X_J)
%--------------------------------------------------------------------------
c = (1 - omega) * c_I + omega * c_J;
rm = (1 - omega) * rm_I + omega * rm_J;
k = (1 - omega) * k_I;    % toket csak a Ricardianok birtokolnak
i = (1 - omega) * i_I;    % beruhazast is csak ok vegeznek
n = (1 - omega) * n_I_agg + omega * n_J_agg;

%--------------------------------------------------------------------------
% 4. TERMELES - kozbenso javak (tanulmany 3.1.2 / 7.3)
%    Cobb-Douglas technologia, koltsegminimalizalas.
%    FONTOS: nincs kulon zart keplet a hatarkoltsegre - a termelesi
%    fuggveny + 2 FOC egyutt IMPLICIT modon hatarozza meg rmc-t
%    (a zart keplet redundans lenne, ez korabban szingularitast okozott).
%--------------------------------------------------------------------------
% Tradable szektor:
y_T = a_T * (k_d_T^alpha) * (n_d_T^(1 - alpha));
r_K = alpha * rmc_T * y_T / k_d_T;                       % toke-FOC
(1 + tau_Wf) * wr = (1 - alpha) * rmc_T * y_T / n_d_T;   % munka-FOC (munkaltatoi jarulekkal!)

% Non-tradable szektor (sajat alpha_NT-vel):
y_NT = a_NT * (k_d_NT^alpha_NT) * (n_d_NT^(1 - alpha_NT));
r_K = alpha_NT * rmc_NT * y_NT / k_d_NT;
(1 + tau_Wf) * wr = (1 - alpha_NT) * rmc_NT * y_NT / n_d_NT;

%--------------------------------------------------------------------------
% 5. ARAZAS - uj-keynesi Phillips-gorbek (Calvo)
%    REDUKALT FORMA: a linearizalt (elteres-formaju) NKPC, nem a teljes
%    nemlinearis f/g rekurzio - elso rendu kozelitesben ekvivalens.
%    A hajtoero a REAL hatarkoltseg elterese a kivant szinttol:
%    rmc/rp - 1/markup. SS: rmc/rp = 1/markup -> pi = 1.
%    gamma_* = 0 most (nincs indexalas), a hatratekinto tag kikapcsolva.
%--------------------------------------------------------------------------
pi_T - 1 = (beta / (1 + beta * gamma_T)) * (pi_T(+1) - 1) +
           (gamma_T / (1 + beta * gamma_T)) * (pi_T(-1) - 1) +
           kappa_T * (rmc_T / rp_T - 1 / markup_T);

pi_NT - 1 = (beta / (1 + beta * gamma_NT)) * (pi_NT(+1) - 1) +
            (gamma_NT / (1 + beta * gamma_NT)) * (pi_NT(-1) - 1) +
            kappa_NT * (rmc_NT / rp_NT - 1 / markup_NT);

pi_X - 1 = (beta / (1 + beta * gamma_X)) * (pi_X(+1) - 1) +
           (gamma_X / (1 + beta * gamma_X)) * (pi_X(-1) - 1) +
           kappa_X * (rmc_X / rp_X - 1 / markup_X);

% Relativ arak mozgastorvenye: rp_t/rp_{t-1} = pi_szektor/pi_CPI
% (a szektoralis ar gyorsabban no mint a CPI -> a relativ ar emelkedik):
rp_T = rp_T(-1) * pi_T / pi_C;
rp_NT = rp_NT(-1) * pi_NT / pi_C;
rp_X = rp_X(-1) * pi_X / pi_C;

% Calvo ar-diszperzio: az arak szorodasa termelesi hatekonysagveszteseget
% okoz (y = s * kereslet, s >= 1). Elso rendben elhanyagolhato, de a
% szerkezet teljessege miatt bent van. (p_tilde = p redukcioval.)
s_T = (1 - xi_T) + xi_T * ((pi_T / pi_target_q)^theta_T) * s_T(-1);
s_NT = (1 - xi_NT) + xi_NT * ((pi_NT / pi_target_q)^theta_NT) * s_NT(-1);

%--------------------------------------------------------------------------
% 6. EXPORT SZEKTOR (tanulmany kulon ujitasa: import az exportban!)
%    Az export jav CES(hazai tradable, importalt input) - igy az arfolyam
%    az export koltsegoldalat IS eri, nem csak a keresletet. Ez lesz az
%    euro-elemzes egyik kulcsmechanizmusa.
%--------------------------------------------------------------------------
% Export hatarkoltseg = a CES koltsegfuggveny dualisa; az importalt input
% relativ ara pimx_scale*rer (leertekelodes -> dragabb input):
rmc_X = (v_X * rp_T^(1 - mu_X) + (1 - v_X) * (pimx_scale * rer)^(1 - mu_X))^(1 / (1 - mu_X));
% Koltsegminimalizalo input-keresletek:
h_T_X = v_X * ((rp_T / rmc_X)^(-mu_X)) * q_X_final;
im_X = (1 - v_X) * ((pimx_scale * rer / rmc_X)^(-mu_X)) * q_X_final;
% Export-kereslet: EXOGEN AR(1) (egyblokkos redukcio - a 4-blokkos
% modellben ez a kulfoldi blokk keresleti fuggvenye lenne):
log(q_X_final) = (1 - rho_X_demand) * log(qX_ss) + rho_X_demand * log(q_X_final(-1)) + eps_X_demand;

%--------------------------------------------------------------------------
% 7. FOGYASZTASI VEGSO JAV (tanulmany 3.1.1 / 7.4, ketszintu CES)
%    Megjegyzes: a CES mennyisegi aggregator (q_C = CES(...)) NINCS kulon
%    egyenletkent - a dualis ar-index + keresleti fuggvenyek egyutt
%    matematikailag implikaljak (CES-dualitas; kulon felvenni redundans
%    lenne - ez korabban szingularitast okozott).
%--------------------------------------------------------------------------
% Kulso szint keresletei (tradable bundle vs non-tradable):
tt_c = v_C * ((rp_TTC)^(-mu_C)) * q_C;
n_T_c = (1 - v_C) * ((rp_NT)^(-mu_C)) * q_C;
% Belso szint keresletei (hazai tradable vs import; az import relativ
% ara = rer, mert P_IM = S*P^kulf es realban P^kulf normalizalt):
h_T_c = v_TC * ((rp_T / rp_TTC)^(-mu_TC)) * tt_c;
im_c = (1 - v_TC) * ((rer / rp_TTC)^(-mu_TC)) * tt_c;
% CPI-IDENTITAS: mivel minden ar a CPI-hez relativ, a CPI sajat relativ
% ara = 1. Ez a numeraire-megkotes - implicit modon ez hatarozza meg
% pi_C-t (a szektoralis inflaciok CPI-konzisztens kombinacioja):
1 = (v_C * rp_TTC^(1 - mu_C) + (1 - v_C) * rp_NT^(1 - mu_C))^(1 / (1 - mu_C));
% Tradable al-bundle ar-indexe:
rp_TTC = (v_TC * rp_T^(1 - mu_TC) + (1 - v_TC) * rer^(1 - mu_TC))^(1 / (1 - mu_TC));

%--------------------------------------------------------------------------
% 8. BERUHAZASI VEGSO JAV (azonos szerkezet)
%--------------------------------------------------------------------------
tt_i = v_I_bundle * ((rp_TTI / rp_I)^(-mu_I)) * q_I_final;
n_T_i = (1 - v_I_bundle) * ((rp_NT / rp_I)^(-mu_I)) * q_I_final;
h_T_i = v_TI * ((rp_T / rp_TTI)^(-mu_TI)) * tt_i;
im_i = (1 - v_TI) * ((rer / rp_TTI)^(-mu_TI)) * tt_i;
% A beruhazasi jav ar-indexe (nem 1, mert nem o a numeraire!):
rp_I = (v_I_bundle * rp_TTI^(1 - mu_I) + (1 - v_I_bundle) * rp_NT^(1 - mu_I))^(1 / (1 - mu_I));
rp_TTI = (v_TI * rp_T^(1 - mu_TI) + (1 - v_TI) * rer^(1 - mu_TI))^(1 / (1 - mu_TI));

%--------------------------------------------------------------------------
% 9. PIACTISZTULAS (tanulmany 7.6)
%--------------------------------------------------------------------------
% Fogyasztasi jav: termeles = fogyasztas + tranzakcios koltseg
% (a penztartasi koltseg valos eroforrast emeszt fel, fogyasztasaranyosan):
q_C = c + (1 - omega) * gamma_v_I * c_I + omega * gamma_v_J * c_J;
% Beruhazasi jav: termeles = beruhazas + tokehasznositasi koltseg:
q_I_final = i + gamma_u_I * k(-1);
% Hazai tradable: ossz-kereslet a harom felhasznalotol, diszperzioval:
h_T_t = h_T_c + h_T_i + h_T_X;
y_T = s_T * h_T_t;
% Non-tradable: fogyasztas + beruhazas + KORMANYZAT (a kormany csak
% non-tradable-t vasarol a tanulmany szerint):
n_T_t = n_T_c + n_T_i + g;
y_NT = s_NT * n_T_t;
% Toke-szolgaltatasok: hasznositas * OROKOLT allomany = szektorok kereslete:
u_I * k(-1) = k_d_T + k_d_NT;
% MUNKAPIACI TISZTULAS: aggregalt kinalat = kereslet.
% Ez az egyenlet zarja a realoldalt - implicit modon ez hatarozza meg
% a real bert (wr) rugalmas berek mellett:
n = n_d_T + n_d_NT;

%--------------------------------------------------------------------------
% 10. KULKERESKEDELEM ES NFA (tanulmany 7.7)
%--------------------------------------------------------------------------
% Kereskedelmi merleg: export ertek - import ertek (mind arazva!):
% import = fogyasztasi + beruhazasi + export-input import.
tb = rp_X * q_X_final - rer * (im_c + im_i + pimx_scale * im_X);
% NFA-felhalmozas: a mult idoszaki pozicio kamatostul + a mult idoszaki
% tb devizaerteke. Szigoruan visszatekinto (predetermined) - a tanulmany
% R*^{-1}_{t-1}B*_t = B*_{t-1} + TB_{t-1}/S_{t-1} egyenletebol:
b_star = R_star * (b_star(-1) + tb(-1) / (300 * rer(-1)));

%--------------------------------------------------------------------------
% 11. GDP ES PROFIT
%--------------------------------------------------------------------------
% Real GDP kiadasi oldalrol: C + I + G + NX (a numeraire a CPI).
% Az eroforras-korlat kulon nem szerepel - Walras torvenye szerint
% a tobbi koltsegvetesi korlat + piactisztulas implikalja.
y = q_C + rp_I * q_I_final + rp_NT * g + tb;
% Aggregalt profit = ertekesites - tenyezokoltsegek, mindharom szektorbol
% (T + NT operativ profit + export szektor markup-profitja).
% A Ricardian haztartasok kapjak osztalekkent (tau_D adoval):
div = rp_T * y_T + rp_NT * y_NT - r_K * (k_d_T + k_d_NT)
      - (1 + tau_Wf) * wr * n + (rp_X - rmc_X) * q_X_final;

%--------------------------------------------------------------------------
% 12. MONETARIS POLITIKA - Taylor-szabaly (tanulmany 3.3, modositva)
%--------------------------------------------------------------------------
% Evesitett inflacio. ELTERES a tanulmanytol: a JELENLEGI negyedeves
% inflacio evesitve (pi_C^4), NEM a 4 negyedev mozgoatlaga - az atlagolas
% + eros simitas a jelenlegi inflaciora ~0.055-os effektiv valaszt adott,
% ami klasszikus indeterminacios forras (Woodford; Carlstrom-Fuerst):
pi_C_4 = pi_C^4;
% Taylor-szabaly evesitett kamatokkal (R^4), elteres-formaban
% (R_bar = SS kamat horgony), kamatsimitassal es novekedesi valasszal:
(R)^4 - (R_bar)^4 = phi_R * ((R(-1))^4 - (R_bar)^4) +
    (1 - phi_R) * (phi_pi * (pi_C_4 - pi_target_q) + phi_Y * (y / y(-1) - 1))
    + eps_R_mon;

%--------------------------------------------------------------------------
% 13. FISKALIS POLITIKA (tanulmany 3.3 / 7.5)
%--------------------------------------------------------------------------
% Kormanyzati koltsegvetesi korlat (real formaban):
% KIADAS: kormanyzati vasarlas + transzfer + lejaro adossag (realban:
%   b(-1)/pi_C - az inflacio erodalja!) + lejaro penz real erteke
% BEVETEL: hat adonem + lump-sum ado + uj adossag-kibocsatas diszkontalt
%   erteke (b/R) + uj penz kibocsatasa (seignorage).
rp_NT * g + tr + b(-1) / pi_C + rm(-1) / pi_C =
    tau_C * c + (tau_N + tau_Wh) * wr * n + tau_Wf * wr * n
    + tau_K * (r_K * u_I - (gamma_u_I + delta) * rp_I) * k(-1)
    + tau_D * div + T + b / R + rm;
% Adossag-stabilizacios szabaly: ha az adossag/GDP a cel folott van,
% no a lump-sum ado (phi_B > 0 garantalja a fiskalis fenntarthatosagot):
T = phi_B * (b(-1) / y - B_Y_target) * y;
% Kiadasi folyamatok (AR(1) log-formaban):
log(g) = (1 - rho_g) * log(g_ss) + rho_g * log(g(-1)) + eps_g_spend;
log(tr) = (1 - rho_tr) * log(tr_ss) + rho_tr * log(tr(-1)) + eps_tr_transfer;

%--------------------------------------------------------------------------
% 14. SOKK-FOLYAMATOK (tanulmany 7.9) - AR(1) log-formaban
%--------------------------------------------------------------------------
log(a_T) = rho_a_T * log(a_T(-1)) + eps_a_T;
log(a_NT) = rho_a_NT * log(a_NT(-1)) + eps_a_NT;
log(markup_T) = (1 - rho_markup_T) * log(markup_T_ss) + rho_markup_T * log(markup_T(-1)) + eps_markup_T;
log(markup_NT) = (1 - rho_markup_NT) * log(markup_NT_ss) + rho_markup_NT * log(markup_NT(-1)) + eps_markup_NT;
log(markup_X) = (1 - rho_markup_X) * log(markup_X_ss) + rho_markup_X * log(markup_X(-1)) + eps_markup_X;
log(chi_pref) = rho_chi * log(chi_pref(-1)) + eps_chi;
rp_shock = rho_rp * rp_shock(-1) + eps_rp;
log(tau_C) = (1 - rho_tau_C) * log(tau_C_ss) + rho_tau_C * log(tau_C(-1)) + eps_tau_C_shock;
log(tau_D) = (1 - rho_tau_D) * log(tau_D_ss) + rho_tau_D * log(tau_D(-1)) + eps_tau_D_shock;
log(tau_K) = (1 - rho_tau_K) * log(tau_K_ss) + rho_tau_K * log(tau_K(-1)) + eps_tau_K_shock;
log(tau_N) = (1 - rho_tau_N) * log(tau_N_ss) + rho_tau_N * log(tau_N(-1)) + eps_tau_N_shock;
log(tau_Wf) = (1 - rho_tau_Wf) * log(tau_Wf_ss) + rho_tau_Wf * log(tau_Wf(-1)) + eps_tau_Wf_shock;
log(tau_Wh) = (1 - rho_tau_Wh) * log(tau_Wh_ss) + rho_tau_Wh * log(tau_Wh(-1)) + eps_tau_Wh_shock;

end;

%==========================================================================
% STEADY STATE KEZDOERTEKEK
% Analitikusan/numerikusan levezetett, (a levezetes: arak=1 normalizacio -> Fisher-relacio -> toke-Euler
% -> r_K -> NKPC-k -> rmc=1/markup -> koltsegfuggveny -> wr -> tenyezo-aranyok -> fixpont a termeles/kereslet/munkapiac/fiskalis blokkon).
% A steady; parancs innen konvergal (residualok ~0).
%==========================================================================
initval;
c_I = 3.37828983;
k_I = 53.53722852;
i_I = 1.33843071;
rm_I = 1.75467118;
q_I = 1.0;
u_I = 1.0;
lambda_I = 0.50190804;
v_I = 2.34888088;
gamma_v_I = 0.00006868;
gamma_v_prime_I = 0.00181250;
gamma_u_I = 0;
gamma_u_prime_I = 0.03747038;
gamma_I_I = 0;
gamma_I_prime_I = 0;
c_J = 0.86909208;
rm_J = 0.45140320;
lambda_J = 0.86392611;
v_J = 2.34888088;
gamma_v_J = 0.00006868;
gamma_v_prime_J = 0.00181250;
c = 1.49639152;
rm = 0.77722020;
k = 13.38430713;
i = 0.33460768;
n = 0.77706735;
n_I_agg = 0.62972302;
n_J_agg = 0.82618213;
b = 1.87511975;
b_star = 0;
wr = 1.07935401;
y_T = 1.14021910;
k_d_T = 7.60746954;
n_d_T = 0.50551901;
rmc_T = 0.83333333;
rp_T = 1.0;
pi_T = 1.0;
s_T = 1.0;
y_NT = 0.86061793;
k_d_NT = 5.77683759;
n_d_NT = 0.27154834;
rmc_NT = 0.66666667;
rp_NT = 1.0;
pi_NT = 1.0;
s_NT = 1.0;
rmc_X = 0.83333333;
rp_X = 1.0;
pi_X = 1.0;
q_X_final = 1.72824268;
h_T_X = 0.85456719;
im_X = 1.05843023;
q_C = 1.49649430;
tt_c = 1.16726555;
h_T_c = 0.23345311;
n_T_c = 0.32922875;
im_c = 0.93381244;
rp_TTC = 1.0;
q_I_final = 0.33460768;
tt_i = 0.26099399;
h_T_i = 0.05219880;
n_T_i = 0.07361369;
im_i = 0.20879519;
rp_I = 1.0;
rp_TTI = 1.0;
h_T_t = 1.14021910;
n_T_t = 0.86061793;
y = 2.28887747;
div = 0.76494960;
tb = 0;
r_K = 0.03747038;
R = 1.01010101;
pi_C = 1.0;
pi_C_4 = 1.0;
rer = 1.0;
nfa_ratio = 0;
gamma_B_adj = 0;
g = 0.45777549;
tr = 0.04577755;
T = -0.36181862;
a_T = 1.0;
a_NT = 1.0;
markup_T = 1.2;
markup_NT = 1.5;
markup_X = 1.2;
chi_pref = 1.0;
rp_shock = 0;
tau_C = 0.22;
tau_D = 0.15;
tau_K = 0.19;
tau_N = 0.15;
tau_Wf = 0.219;
tau_Wh = 0.118;
end;

%==========================================================================
% SOKK-SZORASOK (meg NYERS ertekek - a kalibracios fazisban a magyar
% adatokbol becsulendok! 1% a real/fiskalis sokkokra, 0.1% a monetaris
% es premium-sokkokra)
%==========================================================================
shocks;
var eps_a_T = 0.01^2;
var eps_a_NT = 0.01^2;
var eps_markup_T = 0.01^2;
var eps_markup_NT = 0.01^2;
var eps_markup_X = 0.01^2;
var eps_chi = 0.01^2;
var eps_R_mon = 0.001^2;
var eps_g_spend = 0.01^2;
var eps_tr_transfer = 0.01^2;
var eps_rp = 0.001^2;
var eps_X_demand = 0.01^2;
var eps_tau_C_shock = 0.01^2;
var eps_tau_D_shock = 0.01^2;
var eps_tau_K_shock = 0.01^2;
var eps_tau_N_shock = 0.01^2;
var eps_tau_Wf_shock = 0.01^2;
var eps_tau_Wh_shock = 0.01^2;
end;

%==========================================================================
% SZAMITASOK
%==========================================================================
steady;   % steady state ellenorzes (az initval-bol azonnal konvergal)
check;    % Blanchard-Kahn feltetel (13 instabil gyok = 13 jumper: OK)
% Elso rendu perturbacios megoldas, 20 negyedeves IRF-ek, abrak nelkul
stoch_simul(order=1, irf=20);

