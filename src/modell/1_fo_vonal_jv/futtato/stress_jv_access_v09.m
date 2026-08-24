% stress_jv_access_v09.m — A 4. LEPCSO TESZTJE ES A KUSZOB A JV-MAGON
% =====================================================================
% Harom dolgot dont el:
%
% (1) NESTING. ACCSCALE=0 mellett a v09-nek PONTOSAN a v08-at kell adnia.
%     Ha nem, az access-blokk beszivarog oda is, ahova nem kellene.
%
% (2) BK-STABILITAS minden SCENARIO x TSCEN x NOVERT kombinacioban.
%
% (3) A KUSZOB A JV-MAGON. FONTOS: a v09 access-specifikacioja NEM azonos
%     Samu v07_access-eevel (ott q = phi_i*(i-k-omega*acc), itt additiv tag
%     a JV beruhazasi Euler-egyenletben -- lasd a .mod fejlecet). Ezert az
%     ACCSCALE ertekei NEM feleltethetok meg egy-az-egyben, es a kuszobot
%     KULON kell szamolni ezen a magon. Ugyanaz a 0:10:150 racs es ugyanaz
%     a linearis interpolacio, mint Samu scriptjeben -- csak a mag mas.
%
% Kimenet: output/tables/t44_jv_access_stressz.csv
%          output/tables/t45_jv_access_kuszob.csv
%          output/tables/t45b_jv_access_kuszob_osszegzes.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); stress_jv_access_v09"

% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));

sulyok = @(M_) deal(M_.params(strcmp(cellstr(M_.param_names),'om_E')), ...
                    M_.params(strcmp(cellstr(M_.param_names),'om_D')));

% =====================================================================
% (1) NESTING: ACCSCALE=0 == v08 ?
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(1) NESTING: ACCSCALE=0 visszaadja-e a v08-at?\n');
fprintf('%s\n', repmat('=', 1, 92));
valt = {'y','y_E','y_D','y_L','i_E','i_D','i_L','efp_E','efp_D','efp_L'};
dynare('jv_dsge_v08_3type_arak', '-DSCENARIO=1', '-DTSCEN=3', 'console', 'nograph');
n8 = cellstr(M_.endo_names);
v8 = cellfun(@(v) oo_.steady_state(strcmp(n8, v)), valt);
dynare('jv_dsge_v09_access', '-DSCENARIO=1', '-DTSCEN=3', '-DACCSCALE=0', ...
    'console', 'nograph');
n9 = cellstr(M_.endo_names);
v9 = cellfun(@(v) oo_.steady_state(strcmp(n9, v)), valt);
nest = max(abs(v9 - v8));
fprintf('  max |v09(ACCSCALE=0) - v08| = %.3e  (%s)\n', nest, ...
    string(nest < 1e-12) + " (1e-12 turhatar)");

% =====================================================================
% (2) BK-STRESSZTESZT
% =====================================================================
T = table();
for sc_ = 1:3
    for ts_ = 1:3
        for nv_ = 0:1
            try
                dynare('jv_dsge_v09_access', sprintf('-DSCENARIO=%d', sc_), ...
                    sprintf('-DTSCEN=%d', ts_), sprintf('-DNOVERT=%d', nv_), ...
                    'console', 'nograph');
                solver_ok_ = double(oo_.deterministic_simulation.status);
                B_ = bk_check_metrics(M_, options_, oo_);
                ok_ = solver_ok_; % legacy `konvergalt`: PF solver-statusz
                valid_ = double(solver_ok_ == 1 && B_.check_ok == 1 && ...
                    B_.bk_ok == 1);
                n = cellstr(M_.endo_names);
                g = @(v) 100 * oo_.steady_state(strcmp(n, v));
                pn = cellstr(M_.param_names);
                p = @(v) M_.params(strcmp(pn, v));
                wE = p('om_E')/(p('om_E')+p('om_D'));
                wD = p('om_D')/(p('om_E')+p('om_D'));
                ykkv = wE*g('y_E') + wD*g('y_D');
                uj = table(sc_, ts_, nv_, ok_, g('y'), g('y_E'), g('y_D'), ...
                    g('y_L'), ykkv, ykkv - g('y_L'), g('acc_E'), g('acc_D'), ...
                    g('rer'), g('bstar'), solver_ok_, B_.check_ok, B_.bk_ok, ...
                    valid_, B_.n_forward, B_.n_unstable, B_.qz_criterium, ...
                    B_.info_code, B_.nearest_unit_complex, 'VariableNames', ...
                    {'SCENARIO','TSCEN','NOVERT','konvergalt','GDP_pct', ...
                    'y_E_pct','y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp', ...
                    'acc_E','acc_D','rer_pct','bstar_pct','solver_ok', ...
                    'bk_check_ok','bk_ok','ervenyes','n_forward','n_unstable', ...
                    'bk_qz_criterium','bk_info_code','nearest_unit_complex'});
            catch ME
                fprintf(2, '  !! HIBA (SC=%d TS=%d NOVERT=%d): %s\n', ...
                    sc_, ts_, nv_, ME.message);
                hiany = num2cell(nan(1, 10));
                uj = table(sc_, ts_, nv_, 0, hiany{:}, 0, 0, NaN, 0, ...
                    NaN, NaN, NaN, NaN, NaN, 'VariableNames', ...
                    {'SCENARIO','TSCEN','NOVERT','konvergalt','GDP_pct', ...
                    'y_E_pct','y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp', ...
                    'acc_E','acc_D','rer_pct','bstar_pct','solver_ok', ...
                    'bk_check_ok','bk_ok','ervenyes','n_forward','n_unstable', ...
                    'bk_qz_criterium','bk_info_code','nearest_unit_complex'});
            end
            T = [T; uj]; %#ok<AGROW>
        end
    end
end
% [a repo-t a fejlec mar beallitotta]
writetable(T, fullfile(repo, 'output', 'tables', 't44_jv_access_stressz.csv'));

fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(2) TERMINALIS LOKALIS BK-STRESSZTESZT (ACCSCALE=100)\n');
fprintf('%s\n', repmat('=', 1, 92));
fprintf('%-24s %3s %3s %7s %9s %9s %9s %9s %11s\n', ...
    'kombinacio','PF','BK','U/F','GDP','y_E','y_D','y_L','KKV-L');
fprintf('%s\n', repmat('-', 1, 92));
for i = 1:height(T)
    cim = sprintf('SC=%d TSCEN=%d NOVERT=%d', T.SCENARIO(i), T.TSCEN(i), T.NOVERT(i));
    if T.solver_ok(i) ~= 1, fprintf('%-24s   0   -       - *** PF SOLVER HIBA\n', cim); continue; end
    fprintf('%-24s %3d %3d %2d/%-2d %+8.3f%% %+8.3f%% %+8.3f%% %+8.3f%% %+10.3f pp\n', cim, ...
        T.solver_ok(i), T.bk_ok(i), T.n_unstable(i), T.n_forward(i), ...
        T.GDP_pct(i), T.y_E_pct(i), T.y_D_pct(i), ...
        T.y_L_pct(i), T.KKV_minus_L_pp(i));
end
fprintf(['EREDMENY: PF solver %d/%d; terminalis lokalis BK %d/%d; ' ...
    'mindketto %d/%d.\n'], sum(T.solver_ok == 1), height(T), ...
    sum(T.bk_ok == 1), height(T), sum(T.ervenyes == 1), height(T));

% =====================================================================
% (3) KUSZOB A JV-MAGON
% =====================================================================
scales = 0:10:150;
K = table();
for s_ = scales
    try
        dynare('jv_dsge_v09_access', '-DSCENARIO=1', '-DTSCEN=3', ...
            sprintf('-DACCSCALE=%d', s_), 'console', 'nograph');
        solver_ok_ = double(oo_.deterministic_simulation.status);
        B_ = bk_check_metrics(M_, options_, oo_);
        ok_ = solver_ok_; % legacy `konvergalt`: PF solver-statusz
        valid_ = double(solver_ok_ == 1 && B_.check_ok == 1 && ...
            B_.bk_ok == 1);
        n = cellstr(M_.endo_names);
        g = @(v) 100 * oo_.steady_state(strcmp(n, v));
        pn = cellstr(M_.param_names);
        p = @(v) M_.params(strcmp(pn, v));
        wE = p('om_E')/(p('om_E')+p('om_D')); wD = p('om_D')/(p('om_E')+p('om_D'));
        ykkv = wE*g('y_E') + wD*g('y_D');
        K = [K; table(s_, ok_, g('y'), g('y_E'), g('y_D'), g('y_L'), ykkv, ...
            ykkv-g('y_L'), g('y_D')-g('y_L'), g('y_E')-g('y_L'), ...
            solver_ok_, B_.check_ok, B_.bk_ok, valid_, B_.n_forward, ...
            B_.n_unstable, B_.qz_criterium, B_.info_code, ...
            B_.nearest_unit_complex, ...
            'VariableNames', {'accscale','konvergalt','GDP_pct','y_E_pct', ...
            'y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp','D_minus_L_pp', ...
            'E_minus_L_pp','solver_ok','bk_check_ok','bk_ok','ervenyes', ...
            'n_forward','n_unstable','bk_qz_criterium','bk_info_code', ...
            'nearest_unit_complex'})]; %#ok<AGROW>
    catch ME
        fprintf(2, '  !! HIBA (ACCSCALE=%d): %s\n', s_, ME.message);
        hiany = num2cell(nan(1, 8));
        K = [K; table(s_, 0, hiany{:}, 0, 0, NaN, 0, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', {'accscale','konvergalt','GDP_pct','y_E_pct', ...
            'y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp','D_minus_L_pp', ...
            'E_minus_L_pp','solver_ok','bk_check_ok','bk_ok','ervenyes', ...
            'n_forward','n_unstable','bk_qz_criterium','bk_info_code', ...
            'nearest_unit_complex'})]; %#ok<AGROW>
    end
end
writetable(K, fullfile(repo, 'output', 'tables', 't45_jv_access_kuszob.csv'));

Kok = K(K.ervenyes == 1, :);
kD = kuszob_(Kok.accscale, Kok.D_minus_L_pp);
kK = kuszob_(Kok.accscale, Kok.KKV_minus_L_pp);
kE = kuszob_(Kok.accscale, Kok.E_minus_L_pp);
bkD = bk_at_scale_(kD); bkK = bk_at_scale_(kK); bkE = bk_at_scale_(kE);
Ki = table(kD, kK, kE, nest, bkD, bkK, bkE, 'VariableNames', ...
    {'kuszob_D_L','kuszob_KKV_L','kuszob_E_L','nesting_elteres', ...
    'bk_ok_D_L','bk_ok_KKV_L','bk_ok_E_L'});
writetable(Ki, fullfile(repo,'output','tables','t45b_jv_access_kuszob_osszegzes.csv'));

fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(3) AZ ACCESS-KUSZOB A JV-MAGON (SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 92));
fprintf(['RACS ERVENYESSEG: PF solver %d/%d; terminalis lokalis BK %d/%d; ' ...
    'mindketto %d/%d.\n'], sum(K.solver_ok == 1), height(K), ...
    sum(K.bk_ok == 1), height(K), sum(K.ervenyes == 1), height(K));
invalid_scales = K.accscale(K.ervenyes ~= 1);
if ~isempty(invalid_scales)
    fprintf('  Nem ervenyes ACCSCALE-pontok:');
    fprintf(' %g', invalid_scales);
    fprintf('\n');
end
fprintf('%9s %9s %9s %9s %9s %11s\n','ACCSCALE','GDP','y_E','y_D','y_L','KKV-L');
fprintf('%s\n', repmat('-', 1, 92));
for i = 1:height(Kok)
    fprintf('%9d %+8.3f%% %+8.3f%% %+8.3f%% %+8.3f%% %+10.3f pp\n', ...
        Kok.accscale(i), Kok.GDP_pct(i), Kok.y_E_pct(i), Kok.y_D_pct(i), ...
        Kok.y_L_pct(i), Kok.KKV_minus_L_pp(i));
end
fprintf('%s\n', repmat('=', 1, 92));
fprintf('KUSZOBOK (linearis interpolacio):\n');
fprintf('  hazai KKV >= nagyvallalat  (y_D >= y_L):   ACCSCALE = %.1f\n', kD);
fprintf('  sulyozott KKV >= nagyvallalat:             ACCSCALE = %.1f\n', kK);
fprintf('  export-KKV >= nagyvallalat (y_E >= y_L):   ACCSCALE = %.1f\n', kE);
fprintf(['\nOSSZEVETES: Samu EAGLE-magu v07_access-en a sulyozott KKV-kuszob\n' ...
    '101.0 (EAGLE-kalibracioval) illetve 94.2 (JV-parameterekkel) volt.\n' ...
    'FIGYELEM: az ACCSCALE ertekei a KET MAGON NEM feleltethetok meg\n' ...
    'egy-az-egyben, mert az access-specifikacio elter (lasd .mod fejlec).\n' ...
    'A szamok egyutt csak azt mutatjak, hogy MINDKET magon letezik veges\n' ...
    'kuszob -- a szintjuk nem osszehasonlithato.\n']);
fprintf('%s\n', repmat('=', 1, 92));

function k = kuszob_(x, d)
    k = NaN;
    for j = 1:numel(d)-1
        if d(j) < 0 && d(j+1) >= 0
            k = x(j) + (x(j+1)-x(j))*(0-d(j))/(d(j+1)-d(j)); return
        end
    end
    if ~isempty(d) && d(1) >= 0, k = 0; end
end

function b = bk_at_scale_(accscale)
b = NaN;
if ~isfinite(accscale), return, end
try
    dynare('jv_dsge_v09_access', '-DSCENARIO=1', '-DTSCEN=3', ...
        sprintf('-DACCSCALE=%.10g', accscale), 'console', 'nograph');
    M = evalin('base', 'M_');
    oo = evalin('base', 'oo_');
    options = evalin('base', 'options_');
    solver_ok = double(oo.deterministic_simulation.status);
    B = bk_check_metrics(M, options, oo);
    if solver_ok == 1 && B.check_ok == 1, b = B.bk_ok; end
catch ME
    fprintf(2, '  !! BK-HIBA (ACCSCALE=%.10g): %s\n', accscale, ME.message);
end
end
