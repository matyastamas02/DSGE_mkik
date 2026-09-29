% stress_calib26_v09.m — A 2026-08-26-i PARAMETER-REVIEW ATVEZETESE
% =====================================================================
% MIT CSINAL. Lefuttatja a fo v09 modellt a jelenlegi kalibracioval es a
% kollega parameter-review-janak harom agaval, MINDEGYIKEN VALODI
% Blanchard-Kahn-ellenorzessel (nem csak perfect-foresight solver
% statusszal -- lasd a 2026-08-24-i BK-korrekciot).
%
%   CALIB26 = 0   jelenlegi kalibracio (referencia)
%   CALIB26 = 1   TELJES javaslat
%   CALIB26 = 2   a javaslat a makrosuly-blokk NELKUL
%   CALIB26 = 3   CSAK a makrosuly-blokk (nyitottsag-ugras)
%
% MIERT EZ A HAROM AG. A javaslat ket fuggetlen dolgot csinal egyszerre:
% atirja a szegmens/technologiai/penzugyi parametereket, ES a
% GDP-felhasznalasi sulyokat a zarodo friss definiciora viszi (sx 0.60 ->
% 0.83, sm 0.47 -> 0.80). Ez utobbi a gazdasag nyitottsagat valtoztatja
% meg. Egyben futtatva nem lehetne megmondani, melyik mit csinalt --
% ezert 2 = "minden, csak a makrosulyok nem", 3 = "csak a makrosulyok".
%
% MIT VARJUNK. Nem tudjuk elore, hogy a javaslat BK-valid marad-e. Ket
% valtoztatas kifejezetten a BK-hatar FELE tol: tbank 0.45 -> 0.85/1.05 es
% lev_L 1.85 -> 2.882 (mindketto erositi a penzugyi akceleratort). A
% review maga nem emlit BK-t. Ezert fut itt minden agon a check().
%
% Kimenet: output/tables/t55_calib26.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); stress_calib26_v09"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));   % bk_check_metrics

AGNEV = containers.Map({0, 1, 2, 3}, { ...
    '0 jelenlegi kalibracio', '1 TELJES javaslat', ...
    '2 javaslat makrosuly NELKUL', '3 CSAK makrosulyok'});

fprintf('\n%s\n', repmat('=', 1, 104));
fprintf('A 2026-08-26-i parameter-review atvezetese -- VALODI BK-ellenorzessel\n');
fprintf('%s\n', repmat('=', 1, 104));

T = table();
for cb = [0 1 2 3]
    for sc_ = 1:3
        for ts_ = 1:3
            T = [T; fut_(cb, sc_, ts_)]; %#ok<AGROW>
        end
    end
end
writetable(T, fullfile(repo, 'output', 'tables', 't55_calib26.csv'));

% --- (1) BK-osszegzes aganként ------------------------------------------
fprintf('\n%-30s %6s %6s %10s %10s\n', 'ag', 'PF', 'BK', 'gyok/elo', 'megjegyzes');
fprintf('%s\n', repmat('-', 1, 104));
for cb = [0 1 2 3]
    m = T.CALIB26 == cb;
    pf = sum(T.solver_ok(m) == 1);
    bk = sum(T.bk_ok(m) == 1);
    nu = unique(T.n_unstable(m & T.bk_check_ok == 1));
    nf = unique(T.n_forward(m & T.bk_check_ok == 1));
    if isscalar(nu) && isscalar(nf), gy = sprintf('%d/%d', nu, nf);
    else, gy = 'vegyes'; end
    if bk == sum(m), mj = 'BK-VALID';
    elseif bk == 0,  mj = '*** MIND BK-INVALID ***';
    else,            mj = '*** RESZBEN BK-INVALID ***'; end
    fprintf('%-30s %3d/%-2d %3d/%-2d %10s   %s\n', AGNEV(cb), pf, sum(m), ...
        bk, sum(m), gy, mj);
end

% --- (2) eredmenyek CSAK a BK-valid pontokon ----------------------------
fprintf('\n%s\n', repmat('=', 1, 104));
fprintf('EREDMENYEK -- kizarolag a BK-VALID pontokon (a tobbi nem modell-eredmeny)\n');
fprintf('%s\n', repmat('=', 1, 104));
fprintf('%-30s %14s %14s %14s\n', 'ag', 'GDP-sav', 'KKV-L sav', 'db');
for cb = [0 1 2 3]
    v = T(T.CALIB26 == cb & T.ervenyes == 1, :);
    if isempty(v)
        fprintf('%-30s %14s %14s %14d\n', AGNEV(cb), '—', '—', 0); continue
    end
    fprintf('%-30s %6.2f..%-6.2f %6.2f..%-6.2f %14d\n', AGNEV(cb), ...
        min(v.GDP_pct), max(v.GDP_pct), min(v.KKV_minus_L_pp), ...
        max(v.KKV_minus_L_pp), height(v));
end

% --- (3) kulcsparameterek, amiket a javaslat mozgat ---------------------
fprintf('\n%s\n', repmat('=', 1, 104));
fprintf('A MOZGATOTT KULCSPARAMETEREK (SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 104));
oszl = {'sx', 'sm', 's_kkv', 'shd_v', 'lev_L', 'tbank_L', 'tsov_L', 'aa_D'};
fprintf('%-30s', 'ag');
fprintf('%9s', oszl{:}); fprintf('\n');
for cb = [0 1 2 3]
    r = T(T.CALIB26 == cb & T.SCENARIO == 1 & T.TSCEN == 3, :);
    fprintf('%-30s', AGNEV(cb));
    for k = 1:numel(oszl), fprintf('%9.4g', r.(oszl{k})); end
    fprintf('\n');
end

fprintf(['\nERTELMEZES: a 0. ag a referencia. Ha az 1. ag BK-invalid, de a\n' ...
    '2. vagy a 3. valid, akkor tudjuk, MELYIK valtozascsoport tori el.\n' ...
    'A BK-invalid pontok GDP/KKV-L szamai NEM modell-eredmenyek.\n']);
fprintf('%s\n', repmat('=', 1, 104));

% --- lokalis fuggvenyek --------------------------------------------------
function R = fut_(cb, sc, ts)
try
    dynare('jv_dsge_v09_access', sprintf('-DSCENARIO=%d', sc), ...
        sprintf('-DTSCEN=%d', ts), sprintf('-DCALIB26=%d', cb), ...
        'console', 'nograph', 'noclearall');
    M_ = evalin('base', 'M_'); oo_ = evalin('base', 'oo_');
    options_ = evalin('base', 'options_');
    solver_ok = double(oo_.deterministic_simulation.status);
    bk = bk_check_metrics(M_, options_, oo_);
    n = strtrim(cellstr(M_.endo_names));
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    pn = strtrim(cellstr(M_.param_names));
    p = @(v) M_.params(strcmp(pn, v));
    wE = p('om_E')/(p('om_E')+p('om_D'));
    wD = p('om_D')/(p('om_E')+p('om_D'));
    ykkv = wE*g('y_E') + wD*g('y_D');
    ervenyes = double(solver_ok == 1 && bk.check_ok == 1 && bk.bk_ok == 1);
    R = table(cb, sc, ts, solver_ok, bk.check_ok, bk.bk_ok, ervenyes, ...
        bk.n_forward, bk.n_unstable, bk.qz_criterium, ...
        g('y'), g('y_E'), g('y_D'), g('y_L'), ykkv, ykkv - g('y_L'), ...
        p('sx'), p('sm'), p('s_kkv'), p('shd_v'), p('lev_L'), ...
        p('tbank_L'), p('tsov_L'), p('aa_D'), "", 'VariableNames', kol_());
catch ME
    fprintf(2, '  !! HIBA (CALIB26=%d SC=%d TS=%d): %s\n', cb, sc, ts, ME.message);
    R = table(cb, sc, ts, 0, 0, NaN, 0, NaN, NaN, NaN, NaN, NaN, NaN, ...
        NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
        string(ME.message), 'VariableNames', kol_());
end
end

function c = kol_()
c = {'CALIB26','SCENARIO','TSCEN','solver_ok','bk_check_ok','bk_ok', ...
    'ervenyes','n_forward','n_unstable','bk_qz_criterium','GDP_pct', ...
    'y_E_pct','y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp', ...
    'sx','sm','s_kkv','shd_v','lev_L','tbank_L','tsov_L','aa_D','hiba'};
end
