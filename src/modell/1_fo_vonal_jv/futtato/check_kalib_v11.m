% check_kalib_v11.m — v11: a vegleges csapatkalibracio (-DKALIB=1) ellenorzese
% =====================================================================
% A -DKALIB=1 a parameterek_szamolasa.xlsx szerinti vegleges ertekeket allitja
% be (Tomi 50%-os Opten-szamitasai + az elso helyen megnevezett felelos erteke).
% Kerdes: stabil-e, es mit ad a mai (EXTCLOSE=0, SOVCSAT=0) es a javasolt
% (EXTCLOSE=1, SOVCSAT=1, F10) zarassal.
%
% ELORE ROGZITETT ELVARASOK (2026-10-07, futas elott):
%   (1) KALIB=0 mellett a v11 bitre a v09;
%   (2) a KALIB a friss GDP-sulyokat (sm = 0.796) tartalmazza, ezert a mai
%       zarassal a zaro rezsim valoszinuleg nem stabil (A27); a javasolt
%       zarassal stabilnak kell lennie mindket rezsimben;
%   (3) a GDP-sav (SC x TSCEN, 16-20. ev atlaga) es a KKV-kuszob ujraszamolva,
%       barmi jon ki -- NEM hangolunk.
% Szamitasi horizont 400 negyedev; kozolni legfeljebb 20-30 evet kozlunk.
%
% Kimenet: output/tables/t64_kalib_gdpsav.csv, t64b_kalib_racs.csv,
%          t64c_kalib_osszegzes.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_kalib_v11"
% MEGJEGYZES (2026-10-07): a v11 alapertelmezese a vegleges kalibracio; ez a
% futtato a regi beallitasra rogzitett (regi_v11_ a fajl vegen).

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

HOR = '-DHORIZON=400';
zarasok = {{'-DEXTCLOSE=0', '-DSOVCSAT=0'}, 'mai'; {'-DEXTCLOSE=1', '-DSOVCSAT=1'}, 'javasolt'};
racs_acc = [0 20 40 60 80 100 120 150];

% --- egymasba agyazas: KALIB=0 == v09 -------------------------------------
dynare('jv_dsge_v09_access', 'console', 'nograph');
n9 = cellstr(evalin('base', 'M_.endo_names')); S9 = evalin('base', 'oo_.endo_simul');
a_ = regi_v11_({'-DKALIB=0'}); dynare('jv_dsge_v11', a_{:}, 'console', 'nograph');
n11 = cellstr(evalin('base', 'M_.endo_names')); S11 = evalin('base', 'oo_.endo_simul');
[~, i9, i11] = intersect(n9, n11, 'stable');
nesting_maxdiff = max(abs(S9(i9, :) - S11(i11, :)), [], 'all');
fprintf('\nNESTING: v11 KALIB=0 vs v09: max |elteres| = %.3g\n', nesting_maxdiff);

% --- GDP-sav: KALIB x zaras x SC x TSCEN (ACC=100) --------------------------
C = table();
for ik = [0 1]
    for iz = 1:size(zarasok, 1)
        for isc = 1:3
            for its = 1:3
                args = [{sprintf('-DKALIB=%d', ik), sprintf('-DSCENARIO=%d', isc), ...
                    sprintf('-DTSCEN=%d', its), HOR}, zarasok{iz, 1}];
                r = fut_(args);
                C = [C; [table(ik, string(zarasok{iz, 2}), isc, its, 'VariableNames', ...
                    {'KALIB', 'zaras', 'SCENARIO', 'TSCEN'}), struct2table(r)]]; %#ok<AGROW>
            end
        end
    end
end
writetable(C, fullfile(tab, 't64_kalib_gdpsav.csv'));

% --- ACCSCALE-racs (SC=1, TSCEN=3) ------------------------------------------
G = table();
for ik = [0 1]
    for iz = 1:size(zarasok, 1)
        for ia = racs_acc
            args = [{sprintf('-DKALIB=%d', ik), '-DSCENARIO=1', '-DTSCEN=3', ...
                sprintf('-DACCSCALE=%.10g', ia), HOR}, zarasok{iz, 1}];
            r = fut_(args);
            G = [G; [table(ik, string(zarasok{iz, 2}), ia, 'VariableNames', ...
                {'KALIB', 'zaras', 'accscale'}), struct2table(r)]]; %#ok<AGROW>
        end
    end
end
writetable(G, fullfile(tab, 't64b_kalib_racs.csv'));

% --- osszegzes ----------------------------------------------------------------
O = table();
for ik = [0 1]
    for iz = 1:size(zarasok, 1)
        c = C(C.KALIB == ik & C.zaras == zarasok{iz, 2}, :);
        h = G(G.KALIB == ik & G.zaras == zarasok{iz, 2}, :);
        b = c(c.SCENARIO == 1 & c.TSCEN == 3, :);
        okc = c.ervenyes == 1 & c.instabil_kezdeti == c.eloretekinto;
        okh = h.ervenyes == 1 & h.instabil_kezdeti == h.eloretekinto;
        if all(okc), sav = [min(c.GDP_1620_pct) max(c.GDP_1620_pct) min(c.GDP_fix_pct) max(c.GDP_fix_pct)];
        else, sav = nan(1, 4); end
        O = [O; table(ik, string(zarasok{iz, 2}), sum(okc), all(okh), max([NaN; h.accscale(okh)]), ...
            max(h.ciklus_abs_z), b.ervenyes, b.instabil_zaro, b.GDP_fix_pct, b.GDP_1620_pct, b.GDP_q4_pct, ...
            b.KKV_L_1620_pp, b.KKV_L_fix_pp, sav(1), sav(2), sav(3), sav(4), ...
            kuszob_(h.accscale(okh), h.KKV_L_fix_pp(okh)), kuszob_(h.accscale(okh), h.KKV_L_1620_pp(okh)), ...
            b.bstar_fix, nesting_maxdiff, 'VariableNames', {'KALIB', 'zaras', 'BK_ervenyes_9bol', ...
            'BK_teljes_racson', 'max_stabil_accscale', 'max_ciklus_abs_z', 'ervenyes_alap', ...
            'instabil_zaro_alap', 'GDP_fix_alap_pct', 'GDP_1620_alap_pct', 'GDP_q4_alap_pct', ...
            'KKV_L_1620_alap_pp', 'KKV_L_fix_alap_pp', 'sav_1620_min', 'sav_1620_max', 'sav_fix_min', ...
            'sav_fix_max', 'KKV_kuszob_fix', 'KKV_kuszob_1620', 'bstar_fix_alap', 'nesting_maxdiff'})]; %#ok<AGROW>
end
end
writetable(O, fullfile(tab, 't64c_kalib_osszegzes.csv'));
disp(O);

% =====================================================================
function r = fut_(args)
r = struct('solver_ok', 0, 'instabil_zaro', NaN, 'instabil_kezdeti', NaN, 'eloretekinto', NaN, ...
    'ervenyes', 0, 'ciklus_abs_z', NaN, 'GDP_fix_pct', NaN, 'GDP_q4_pct', NaN, 'GDP_q40_pct', NaN, ...
    'GDP_q80_pct', NaN, 'GDP_1620_pct', NaN, 'KKV_L_fix_pp', NaN, 'KKV_L_1620_pp', NaN, ...
    'bstar_fix', NaN, 'rer_fix_pct', NaN, 'c_o_fix_pct', NaN, 'q_D_fix_pct', NaN, 'q_E_fix_pct', NaN);
try
    args = regi_v11_(args); dynare('jv_dsge_v11', args{:}, 'console', 'nograph');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    r.solver_ok = double(oo.deterministic_simulation.status == 1);
    B = bk_check_metrics(M, op, oo);
    oo0 = oo; oo0.steady_state(:) = 0; oo0.exo_steady_state(:) = 0;
    if isfield(oo0, 'exo_det_steady_state'), oo0.exo_det_steady_state(:) = 0; end
    B0 = bk_check_metrics(M, op, oo0);
    r.instabil_zaro = B.n_unstable; r.instabil_kezdeti = B0.n_unstable; r.eloretekinto = B.n_forward;
    r.ervenyes = double(r.solver_ok == 1 && B.check_ok == 1 && B.bk_ok == 1);
    ev = B.eigenvalues(isfinite(B.eigenvalues)); a = abs(angle(ev));
    c = ev(imag(ev) > 1e-8 & a > 0.12 & a < 0.40 & abs(ev) > 0.85 & abs(ev) < 1.10);
    if ~isempty(c), r.ciklus_abs_z = max(abs(c)); end
    n = cellstr(M.endo_names); pn = cellstr(M.param_names); p = @(v) M.params(strcmp(pn, v));
    ss = @(v) 100 * oo.steady_state(strcmp(n, v)); S = oo.endo_simul;
    pa = @(v) 100 * S(strcmp(n, v), :);
    wE = p('om_E') / (p('om_E') + p('om_D')); wD = 1 - wE;
    ab = 62:81;                                   % 61-80. negyedev (16-20. ev)
    y = pa('y'); kl = wE*pa('y_E') + wD*pa('y_D') - pa('y_L');
    r.GDP_fix_pct = ss('y'); r.GDP_q4_pct = y(5); r.GDP_q40_pct = y(41); r.GDP_q80_pct = y(81);
    r.GDP_1620_pct = mean(y(ab));
    r.KKV_L_fix_pp = wE*ss('y_E') + wD*ss('y_D') - ss('y_L'); r.KKV_L_1620_pp = mean(kl(ab));
    r.bstar_fix = oo.steady_state(strcmp(n, 'bstar')); r.rer_fix_pct = ss('rer');
    r.c_o_fix_pct = ss('c_o'); r.q_D_fix_pct = ss('q_D'); r.q_E_fix_pct = ss('q_E');
catch ME
    fprintf(2, '  !! HIBA (%s): %s\n', strjoin(args, ' '), ME.message);
end
end

function k = kuszob_(x, d)
k = NaN;
for j = 1:numel(d)-1
    if d(j) < 0 && d(j+1) >= 0
        k = x(j) + (x(j+1)-x(j))*(0-d(j))/(d(j+1)-d(j)); return
    end
end
if ~isempty(d) && d(1) >= 0, k = 0; end
end

function y = ternary_(c, a, b)
if c, y = a; else, y = b; end
end

function a = regi_v11_(a)
% 2026-10-07: a v11 alapertelmezese a vegleges kalibracio (KALIB=1, EXTCLOSE=1,
% SOVCSAT=1, HORIZON=400). Ez a futtato a REGI beallitasra rogzitett: amit a
% hivas nem ad meg kifejezetten, azt a regi ertekre allitjuk, hogy a tarolt
% tablak reprodukalhatok maradjanak.
alap = {'KALIB', '0'; 'EXTCLOSE', '0'; 'SOVCSAT', '0'; 'HORIZON', '120'};
for i = 1:size(alap, 1)
    if ~any(startsWith(a, ['-D' alap{i, 1} '=']))
        a{end+1} = ['-D' alap{i, 1} '=' alap{i, 2}]; %#ok<AGROW>
    end
end
end
