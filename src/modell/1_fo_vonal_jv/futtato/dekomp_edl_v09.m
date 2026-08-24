% dekomp_edl_v09.m — E/D/L DEKOMPOZICIOS SCAN: TECHNOLOGIA VAGY FINANSZIROZAS?
% =====================================================================
% MIERT (korlatok-riport 2026-08-21, 2. teendo / 7. szakasz).
%
% A harom tipus ELEVE kulonbozo technologiat kapott. A .mod maga mondja ki:
% "Ez ATVITEL, nem becsles." A zeta_j (tokehanyad) es az aa_j (a munka
% aranya a munka+import kompozitban) a JV export-, illetve hazai
% szektorabol van atvive, az exportorientacio alapjan:
%       zeta:  E 0.14   D 0.17   L 0.155
%       aa  :  E 0.45   D 0.80   L 0.60
% Vagyis ha az E es a D maskepp reagal az euro-szcenariora, abban BENNE VAN
% az is, hogy mi adtunk nekik mas termelesi parametert.
%
% A referee elso kerdese ez lesz:
%     "Show me that your main conclusion is not an artifact of the E/D/L
%      calibration."
% Erre eddig NEM VOLT VALASZUNK. Ez a script az.
%
% NEGY AG (-DDECOMP), mindegyik egyszerre EGY heterogenitas-dimenziot hagy
% meg, a tobbit kozos ertekre allitja:
%
%   A (1)  csak phi_j        -> a piaci orientacio ONMAGABAN
%   B (2)  csak penzugyi     -> a FINANSZIROZASI heterogenitas ONMAGABAN
%          (chi, lev, psi, es az E-D kozotti access-kulonbseg)
%   C (3)  csak aa_j         -> a magyar dualis szerkezet ONMAGABAN
%   D (4)  minden TECHNOLOGIAI parameter azonos (zeta_j, aa_j)
%          -> a maradek: phi + penzugy
%
% A DONTESI SZABALY, amit elore kimondunk (hogy ne utolag valogassunk):
%   - Ha a KKV-eredmeny a B es a D agon IS megvan, akkor tenyleg
%     finanszirozasi heterogenitasrol szol.
%   - Ha csak az A / C agon van meg, akkor TECHNOLOGIAI MUTERMEK, es a
%     tanulmany fo allitasat at kell fogalmazni.
%
% KET ERTELMEZESI OVATOSSAG, amit nem hallgatunk el:
%  (i) A "kozos ertek" valasztasa nem semleges. Alapertelmezesben a
%      MERETSULYOZOTT (om_j) atlagot hasznaljuk, mert az hagyja
%      valtozatlanul az aggregalt technologiat. A -DDECOMPW=0 (egyszeru
%      szamtani atlag) ellenprobat is lefuttatjuk: a KOVETKEZTETES nem
%      mulhat a semlegesites modjan.
% (ii) A B ag NEM tudja semlegesiteni az omega_acc_L = 0 feltevest -- a
%      nagyvallalatnak definicio szerint nincs acc-egyenlete. Az kulon
%      teendo (korlatok-riport 4. pont), es ezt a scan NEM valaszolja meg.
%
% A KOZLES FORMAJA: nem pontbecsles, hanem KUSZOB -- ugyanugy, ahogy a
% t48b/t51/t52 eseteben. Aganként megkeressuk, mekkora access-skala kell
% ahhoz, hogy a KKV-blokk utolerje a nagyvallalatot. Ha a kuszob a B/D agon
% nem szall el, az eredmeny nem technologiai mutermek.
%
% Kimenet: output/tables/t53_dekomp_edl.csv        (agak, ket sulyozassal)
%          output/tables/t53b_dekomp_kuszob.csv    (aganKENTi kuszob)
%          output/tables/t53c_dekomp_bk.csv        (BK-stressz)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); dekomp_edl_v09"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

TAB = @(n) fullfile(repo, 'output', 'tables', n);
AGNEV = containers.Map({0,1,2,3,4}, { ...
    '0 alap (minden heterogen)', 'A csak phi_j', 'B csak penzugyi', ...
    'C csak aa_j', 'D technologia azonos'});

% =====================================================================
% (0) REGRESSZIO — a DECOMP=0 ag valtozatlan-e?
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('(0) REGRESSZIO: a -DDECOMP=0 ag azonos-e a tarolt t44 baseline-nal?\n');
fprintf('%s\n', repmat('=', 1, 100));
% FIGYELEM: a t44 baseline az -DOPTEN=0 agon all, ezert itt is OPTEN=0-val
% kell futtatni. (Elso irasban OPTEN=1 volt, es a "regresszio eltort"
% uzenet ebbol jott, nem a modellbol -- a kulonbseg pont az OPTEN 0->1
% lepes volt.)
r0 = fut_(0, 1, 0, 100, 1, 3);
T44 = readtable(TAB('t44_jv_access_stressz.csv'));
s44 = T44(T44.SCENARIO == 1 & T44.TSCEN == 3 & T44.NOVERT == 0, :);
d = max(abs([r0.GDP_pct - s44.GDP_pct, r0.y_E_pct - s44.y_E_pct, ...
    r0.y_D_pct - s44.y_D_pct, r0.y_L_pct - s44.y_L_pct]));
fprintf('  t44 (tarolt): GDP %+.4f%%  y_E %+.4f%%  y_D %+.4f%%  y_L %+.4f%%\n', ...
    s44.GDP_pct, s44.y_E_pct, s44.y_D_pct, s44.y_L_pct);
fprintf('  most        : GDP %+.4f%%  y_E %+.4f%%  y_D %+.4f%%  y_L %+.4f%%\n', ...
    r0.GDP_pct, r0.y_E_pct, r0.y_D_pct, r0.y_L_pct);
fprintf('  max elteres = %.3e  -> %s\n', d, ...
    ternary_(d < 1e-9, 'REGRESSZIO RENDBEN', '*** REGRESSZIO ELTORT ***'));
% A fusttesztnek ADATKENT is kell, kulonben az or nem tudja ellenorizni.
writetable(table(d, r0.GDP_pct, s44.GDP_pct, 'VariableNames', ...
    {'max_elteres', 'GDP_pct_most', 'GDP_pct_t44'}), ...
    TAB('t53d_dekomp_regresszio.csv'));

% =====================================================================
% (1)+(2) A NEGY AG, KET SULYOZASSAL, KET KALIBRACIOS AGON
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('(1) A NEGY AG (SCENARIO=1, TSCEN=3, ACCSCALE=100)\n');
fprintf('%s\n', repmat('=', 1, 100));

T = table();
for op_ = [0 1]
    for w_ = [1 0]
        for dc_ = [0 1 2 3 4]
            if dc_ == 0 && w_ == 0, continue, end   % a 0 agon a suly nem szamit
            T = [T; fut_(dc_, w_, op_, 100, 1, 3)]; %#ok<AGROW>
        end
    end
end
writetable(T, TAB('t53_dekomp_edl.csv'));

for op_ = [0 1]
    for w_ = [1 0]
        cim = ternary_(w_ == 1, 'meretsulyozott (om_j) atlag', ...
            'egyszeru szamtani atlag [ELLENPROBA]');
        fprintf('\n  OPTEN=%d, kozos ertek = %s\n', op_, cim);
        fprintf('  %-26s %4s %10s %10s %10s %10s %12s\n', 'ag', 'OK', ...
            'GDP', 'y_E', 'y_D', 'y_L', 'KKV-L');
        fprintf('  %s\n', repmat('-', 1, 88));
        for dc_ = [0 1 2 3 4]
            m = T.DECOMP == dc_ & T.OPTEN == op_ & ...
                (T.DECOMPW == w_ | T.DECOMP == 0);
            if ~any(m), continue, end
            i = find(m, 1);
            if T.konvergalt(i) ~= 1
                fprintf('  %-26s  *** NEM KONVERGALT\n', AGNEV(dc_)); continue
            end
            fprintf('  %-26s %4d %+9.3f%% %+9.3f%% %+9.3f%% %+9.3f%% %+10.3f pp\n', ...
                AGNEV(dc_), T.konvergalt(i), T.GDP_pct(i), T.y_E_pct(i), ...
                T.y_D_pct(i), T.y_L_pct(i), T.KKV_minus_L_pp(i));
        end
    end
end

% =====================================================================
% (3) A KUSZOB AGANKENT — EZ A KOZLENDO FORMA
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('(3) AGANKENTI ACCESS-KUSZOB (mekkora skala kell a KKV-elonyhoz?)\n');
fprintf('%s\n', repmat('=', 1, 100));
fprintf('  %-26s %6s %14s %16s\n', 'ag', 'OPTEN', 'kuszob', 'a 0-aghoz kepest');
fprintf('  %s\n', repmat('-', 1, 70));
K = table();
for op_ = [0 1]
    alapk = NaN;
    for dc_ = [0 1 2 3 4]
        k = kuszob_(dc_, 1, op_, 400);
        if dc_ == 0, alapk = k; end
        ar = k / alapk;
        K = [K; table(dc_, string(AGNEV(dc_)), op_, k, ar, 'VariableNames', ...
            {'DECOMP','ag','OPTEN','kuszob','arany_a_0_aghoz'})]; %#ok<AGROW>
        fprintf('  %-26s %6d %14.2f %15.2fx\n', AGNEV(dc_), op_, k, ar);
    end
end
writetable(K, TAB('t53b_dekomp_kuszob.csv'));

% =====================================================================
% (4) BK-STRESSZ — minden ag, minden szcenario es transzmisszios feltevés
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('(4) BK-STRESSZ: minden ag x SCENARIO x TSCEN (OPTEN=1)\n');
fprintf('%s\n', repmat('=', 1, 100));
S = table();
for dc_ = [0 1 2 3 4]
    for sc_ = 1:3
        for ts_ = 1:3
            S = [S; fut_(dc_, 1, 1, 100, sc_, ts_)]; %#ok<AGROW>
        end
    end
end
writetable(S, TAB('t53c_dekomp_bk.csv'));
fprintf('  %d / %d kombinacio BK-stabil.\n', sum(S.konvergalt == 1), height(S));
fprintf('\n  GDP-SAV AGANKENT (az A01 kozolt savja: +0.3 ... +2.9%%):\n');
for dc_ = [0 1 2 3 4]
    m = S.DECOMP == dc_ & S.konvergalt == 1;
    fprintf('    %-26s  %+.3f%% ... %+.3f%%   (KKV-L elojel: %s)\n', ...
        AGNEV(dc_), min(S.GDP_pct(m)), max(S.GDP_pct(m)), ...
        elojel_(S.KKV_minus_L_pp(m)));
end

% =====================================================================
% ERTELMEZES
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 100));
kB = K.kuszob(K.DECOMP == 2 & K.OPTEN == 1);
kD = K.kuszob(K.DECOMP == 4 & K.OPTEN == 1);
kA = K.kuszob(K.DECOMP == 1 & K.OPTEN == 1);
kC = K.kuszob(K.DECOMP == 3 & K.OPTEN == 1);
k0 = K.kuszob(K.DECOMP == 0 & K.OPTEN == 1);
fprintf(['A DONTESI SZABALY KIERTEKELESE (OPTEN=1):\n' ...
    '  alap ag kuszobe            : %.2f\n' ...
    '  B (csak penzugyi)          : %.2f  (%.2fx)\n' ...
    '  D (technologia azonos)     : %.2f  (%.2fx)\n' ...
    '  A (csak phi_j)             : %.2f  (%.2fx)\n' ...
    '  C (csak aa_j)              : %.2f  (%.2fx)\n'], ...
    k0, kB, kB/k0, kD, kD/k0, kA, kA/k0, kC, kC/k0);
fprintf('%s\n', repmat('=', 1, 100));

% --- lokalis fuggvenyek --------------------------------------------------
function R = fut_(dc, w, op, accscale, sc, ts)
try
    dynare('jv_dsge_v09_access', sprintf('-DSCENARIO=%d', sc), ...
        sprintf('-DTSCEN=%d', ts), sprintf('-DOPTEN=%d', op), ...
        sprintf('-DACCSCALE=%.10g', accscale), ...
        sprintf('-DDECOMP=%d', dc), sprintf('-DDECOMPW=%d', w), ...
        'console', 'nograph');
    M_  = evalin('base', 'M_');
    oo_ = evalin('base', 'oo_');
    ok_ = oo_.deterministic_simulation.status;
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    pn = cellstr(M_.param_names);
    p = @(v) M_.params(strcmp(pn, v));
    wE = p('om_E')/(p('om_E')+p('om_D'));
    wD = p('om_D')/(p('om_E')+p('om_D'));
    ykkv = wE*g('y_E') + wD*g('y_D');
    R = table(dc, w, op, accscale, sc, ts, ok_, ...
        p('zeta_E'), p('zeta_D'), p('aa_E'), p('aa_D'), p('phi_E'), ...
        p('phi_D'), p('lev_E'), p('lev_D'), p('omega_acc_E'), ...
        p('omega_acc_D'), g('y'), g('y_E'), g('y_D'), g('y_L'), ykkv, ...
        ykkv - g('y_L'), g('y_D') - g('y_L'), g('y_E') - g('y_L'), ...
        'VariableNames', kolumnak_());
catch ME
    fprintf(2, '  !! HIBA (DECOMP=%d W=%d OPTEN=%d ACC=%g SC=%d TS=%d): %s\n', ...
        dc, w, op, accscale, sc, ts, ME.message);
    R = table(dc, w, op, accscale, sc, ts, 0, NaN, NaN, NaN, NaN, NaN, ...
        NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
        'VariableNames', kolumnak_());
end
end

function c = kolumnak_()
c = {'DECOMP','DECOMPW','OPTEN','accscale','SCENARIO','TSCEN','konvergalt', ...
    'zeta_E','zeta_D','aa_E','aa_D','phi_E','phi_D','lev_E','lev_D', ...
    'omega_acc_E','omega_acc_D','GDP_pct','y_E_pct','y_D_pct','y_L_pct', ...
    'y_KKV_pct','KKV_minus_L_pp','D_minus_L_pp','E_minus_L_pp'};
end

function k = kuszob_(dc, w, op, felso)
% Az az ACCSCALE (a lambda-t es az omega-t egyutt skalazva), ahol a
% KKV-blokk eppen utoleri a nagyvallalatot. Bisekcio: a KKV-L az
% access-skalaban monoton no.
lo = 0; hi = felso;
rhi = fut_(dc, w, op, hi, 1, 3);
if rhi.konvergalt ~= 1 || rhi.KKV_minus_L_pp < 0, k = Inf; return, end
rlo = fut_(dc, w, op, lo, 1, 3);
if rlo.konvergalt == 1 && rlo.KKV_minus_L_pp >= 0, k = 0; return, end
for it = 1:18
    mid = 0.5*(lo+hi);
    rm = fut_(dc, w, op, mid, 1, 3);
    if rm.konvergalt == 1 && rm.KKV_minus_L_pp >= 0, hi = mid; else, lo = mid; end
    if hi - lo < 0.01, break, end
end
k = 0.5*(lo+hi);
end

function s = elojel_(v)
if all(v > 0), s = 'vegig POZITIV';
elseif all(v < 0), s = 'vegig NEGATIV';
else, s = 'VALTAKOZIK'; end
end

function y = ternary_(c, a, b)
if c, y = a; else, y = b; end
end
