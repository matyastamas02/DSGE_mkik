% sens_extclose_v11.m — v11: a kulso zaras (-DEXTCLOSE) hatasa a stabilitasra
% =====================================================================
% KIINDULAS (2026-10-07): a friss, 2015-2024-es GDP-sulyokkal (sx = 0.829,
% sm = 0.796; -DCALIB26=3 -DNOVERT=1) a v09/v10 euro-rezsime 15/13, nincs
% stabil megoldas. A diagnozis szerint az atlepo gyokpar a lassu (~28
% negyedeves) ciklus, amely a D-tipus beruhazas-q-toke-hozzaferes ciklusa;
% lebego arfolyamnal |z| = 0.945, euroban a bstar -> r hurok (nu_uni = 0.25,
% aznapi bstar) belep, es |z| = 0.994-re no.
%
% Kerdes: a kulso zaras standard, gyenge alakja (EXTCLOSE=1: nu_uni = nu_b;
% EXTCLOSE=2: ugyanez elozo idoszaki bstar-ral) helyreallitja-e a stabilitast,
% es mit tesz a tartos eredmenyekkel.
%
% ELORE ROGZITETT ELFOGADASI FELTETELEK (2026-10-07, a futas elott):
%   (1) 13/13 BK mindket rezsimben, regi ES friss sulyokkal, a teljes
%       ACCSCALE-racson (0..150);
%   (2) a lassu ciklus gyoke erdemben 1 alatt (|z| < 0.98);
%   (3) EXTCLOSE=0 mellett bitre a v09;
%   (4) a GDP-sav es a KKV-kuszob ujraszamolva, barmi jon ki -- NEM hangolunk.
%
% Kimenet: output/tables/t62_extclose_racs.csv     (ACCSCALE-racs)
%          output/tables/t62b_extclose_osszegzes.csv (zaras x sulyok)
%          output/tables/t62c_extclose_gdpsav.csv  (A01-sav: SC x TSCEN)
%          output/tables/t62d_extclose_modusz.csv  (a lassu modusz reszvetele)
%          output/tables/t62e_extclose_nuuni_scan.csv (a zaras erossege)
% Mertekegyseg: bstar a negyedeves GDP egysegeben; 1 pp eves GDP = 0.04.
% A nu_uni ezert 1600*nu bazisponttal (evesitett) emeli a kamatot 1 pp
% (eves GDP-aranyos) netto kulfoldi adossag-novekedesre.
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); sens_extclose_v11"
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

zarasok = [0 1 2];
sulyok = {{}, 'regi'; {'-DCALIB26=3', '-DNOVERT=1'}, 'friss'};
racs_acc = [0 10 20 30 40 50 60 80 100 120 150];
% HORIZONT: gyenge zarasnal a bstar evszazadok alatt all be; 120 negyedev
% mellett a palya torz (2026-10-07: 400 vs 1000 az elso 120 negyedevben egyezik).
% A tartos fixpontot es a BK-t a horizont nem erinti.
HOR = '-DHORIZON=400';

% --- (3) egymasba agyazas: v11 EXTCLOSE=0 == v09 ---------------------
dynare('jv_dsge_v09_access', 'console', 'nograph');
n9 = cellstr(evalin('base', 'M_.endo_names')); S9 = evalin('base', 'oo_.endo_simul');
a_ = regi_v11_({'-DEXTCLOSE=0'}); dynare('jv_dsge_v11', a_{:}, 'console', 'nograph');
n11 = cellstr(evalin('base', 'M_.endo_names')); S11 = evalin('base', 'oo_.endo_simul');
[~, i9, i11] = intersect(n9, n11, 'stable');
nesting_maxdiff = max(abs(S9(i9, :) - S11(i11, :)), [], 'all');
fprintf('\nNESTING: v11 EXTCLOSE=0 vs v09: max |elteres| = %.3g (%d kozos valtozo)\n', ...
    nesting_maxdiff, numel(i9));

% --- racs ------------------------------------------------------------
G = table();
for iz = zarasok
    for iw = 1:size(sulyok, 1)
        for ia = racs_acc
            args = [{'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DEXTCLOSE=%d', iz), ...
                sprintf('-DACCSCALE=%.10g', ia), HOR}, sulyok{iw, 1}];
            r = fut_(args, iz);
            G = [G; table(iz, string(sulyok{iw, 2}), ia, r.solver_ok, r.n_unst_T, r.n_unst_I, ...
                r.n_fwd, r.ervenyes, r.ciklus_z, r.y, r.kkv_l, r.q_E, r.q_D, r.c, r.c_o, ...
                r.bstar, r.rer, r.r_belep_pp, r.r_sov_pp, r.r_zaras_pp, r.bstar_max, ...
                r.y_q(1), r.y_q(2), r.y_q(3), r.y_q(4), r.bstar_q120, ...
                'VariableNames', {'EXTCLOSE', 'sulyok', 'accscale', 'solver_ok', ...
                'instabil_zaro', 'instabil_kezdeti', 'eloretekinto', 'ervenyes', ...
                'ciklus_abs_z', 'GDP_pct', 'KKV_minus_L_pp', 'q_E_pct', 'q_D_pct', ...
                'c_pct', 'c_o_pct', 'bstar_tartos', 'rer_pct', 'r_belepes_ev_pp', ...
                'r_belepes_sov_ev_pp', 'r_belepes_zaras_ev_pp', 'bstar_max_abs', ...
                'GDP_q4_pct', 'GDP_q20_pct', 'GDP_q40_pct', 'GDP_q80_pct', 'bstar_q120'})]; %#ok<AGROW>
        end
    end
end
writetable(G, fullfile(tab, 't62_extclose_racs.csv'));

% --- A01-sav (SC x TSCEN, ACCSCALE=100) --------------------------------
C = table();
for iz = zarasok
    for iw = 1:size(sulyok, 1)
        for isc = 1:3
            for its = 1:3
                args = [{sprintf('-DSCENARIO=%d', isc), sprintf('-DTSCEN=%d', its), ...
                    sprintf('-DEXTCLOSE=%d', iz), HOR}, sulyok{iw, 1}];
                r = fut_(args, iz);
                C = [C; table(iz, string(sulyok{iw, 2}), isc, its, r.ervenyes, r.y, r.kkv_l, ...
                    'VariableNames', {'EXTCLOSE', 'sulyok', 'SCENARIO', 'TSCEN', ...
                    'ervenyes', 'GDP_pct', 'KKV_minus_L_pp'})]; %#ok<AGROW>
            end
        end
    end
end
writetable(C, fullfile(tab, 't62c_extclose_gdpsav.csv'));

% --- osszegzes -------------------------------------------------------
O = table();
fprintf('\n%-4s %-6s %-12s %-10s %8s %8s %9s %10s %10s %10s\n', 'zar', 'suly', ...
    'stabil ACC', 'BK-racs', 'max|z|', 'kuszob', 'GDP@100', 'GDP-sav', 'bstar@100', 'r_bel@100');
for iz = zarasok
    for iw = 1:size(sulyok, 1)
        h = G(G.EXTCLOSE == iz & G.sulyok == sulyok{iw, 2}, :);
        ok = h.ervenyes == 1 & h.instabil_kezdeti == h.eloretekinto;
        stabil_max = max([NaN; h.accscale(ok)]);
        mind_ok = all(ok);
        kus = kuszob_(h.accscale(ok), h.KKV_minus_L_pp(ok));
        h100 = h(h.accscale == 100, :);
        c = C(C.EXTCLOSE == iz & C.sulyok == sulyok{iw, 2}, :);
        if all(c.ervenyes == 1), sav = [min(c.GDP_pct) max(c.GDP_pct)]; else, sav = [NaN NaN]; end
        O = [O; table(iz, string(sulyok{iw, 2}), mind_ok, stabil_max, max(h.ciklus_abs_z), kus, ...
            h100.ervenyes, h100.GDP_pct, h100.KKV_minus_L_pp, sav(1), sav(2), sum(c.ervenyes), ...
            h100.bstar_tartos, h100.rer_pct, h100.c_o_pct, h100.q_D_pct, h100.r_belepes_ev_pp, ...
            h100.r_belepes_zaras_ev_pp, h100.GDP_q20_pct, h100.GDP_q40_pct, h100.GDP_q80_pct, ...
            'VariableNames', {'EXTCLOSE', 'sulyok', 'BK_teljes_racson', 'max_stabil_accscale', ...
            'max_ciklus_abs_z', 'KKV_kuszob_accscale', 'ervenyes_100', 'GDP_100_pct', ...
            'KKV_minus_L_100_pp', 'GDP_sav_min', 'GDP_sav_max', 'sav_ervenyes_db', ...
            'bstar_tartos_100', 'rer_100_pct', 'c_o_100_pct', 'q_D_100_pct', ...
            'r_belepes_100_ev_pp', 'r_belepes_zaras_100_ev_pp', 'GDP_q20_100_pct', ...
            'GDP_q40_100_pct', 'GDP_q80_100_pct'})]; %#ok<AGROW>
        fprintf('%-4d %-6s %-12s %-10s %8.4f %8.2f %9.3f %4.2f..%-4.2f %10.4f %10.2f\n', iz, ...
            sulyok{iw, 2}, sprintf('<=%g', stabil_max), ternary_(mind_ok, 'mind', 'NEM mind'), ...
            max(h.ciklus_abs_z), kus, h100.GDP_pct, sav(1), sav(2), h100.bstar_tartos, ...
            h100.r_belepes_ev_pp);
    end
end
O.nesting_maxdiff = repmat(nesting_maxdiff, height(O), 1);
writetable(O, fullfile(tab, 't62b_extclose_osszegzes.csv'));

% --- a zaras erossege: nu_uni-scan (EXTCLOSE=0, aznapi bstar, ACC=100) ---
E = table();
for iw = 1:size(sulyok, 1)
    for nu = [0.25 0.1 0.05 0.025 0.01 0.005 0.0025 0.001]
        args = [{'-DSCENARIO=1', '-DTSCEN=3', '-DEXTCLOSE=0', sprintf('-DNUUNI=%.10g', nu), HOR}, sulyok{iw, 1}];
        r = fut_(args, 0);
        E = [E; table(string(sulyok{iw, 2}), nu, 1600*nu, r.ervenyes, r.n_unst_T, r.ciklus_z, ...
            r.y, r.y_q(2), r.y_q(3), r.y_q(4), r.kkv_l, r.bstar, -r.bstar/4*100, r.rer, r.c_o, ...
            r.r_belep_pp, r.r_zaras_pp, 'VariableNames', {'sulyok', 'nu_uni', ...
            'felar_bp_per_1pp_NIIP', 'ervenyes', 'instabil_zaro', 'ciklus_abs_z', 'GDP_tartos_pct', ...
            'GDP_q20_pct', 'GDP_q40_pct', 'GDP_q80_pct', 'KKV_minus_L_pp', 'bstar_tartos', ...
            'kulso_adossag_novekmeny_eves_GDP_pct', 'rer_pct', 'c_o_pct', 'r_belepes_ev_pp', ...
            'r_belepes_zaras_ev_pp'})]; %#ok<AGROW>
    end
end
writetable(E, fullfile(tab, 't62e_extclose_nuuni_scan.csv'));
disp(E(:, [1 2 4 6 7 8 9 12 13]));

% --- a lassu modusz reszvetele (ACCSCALE=100, ahol megoldhato) --------
D = table();
for iz = zarasok
    for iw = 1:size(sulyok, 1)
        for reg = ["zaro", "kezdeti"]
            args = [{'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DEXTCLOSE=%d', iz)}, sulyok{iw, 1}];
            m = modusz_(args, reg);
            D = [D; table(iz, string(sulyok{iw, 2}), reg, m.abs_z, m.periodus, m.bstar, ...
                m.d_blokk, string(m.top), 'VariableNames', {'EXTCLOSE', 'sulyok', 'rezsim', ...
                'abs_z', 'periodus_nev', 'bstar_reszvetel', 'D_beruhazasi_blokk_reszvetel', ...
                'top6'})]; %#ok<AGROW>
        end
    end
end
writetable(D, fullfile(tab, 't62d_extclose_modusz.csv'));
disp(D(:, 1:7));

% =====================================================================
function r = fut_(args, iz)
r = struct('solver_ok', 0, 'n_unst_T', NaN, 'n_unst_I', NaN, 'n_fwd', NaN, 'ervenyes', 0, ...
    'ciklus_z', NaN, 'y', NaN, 'kkv_l', NaN, 'q_E', NaN, 'q_D', NaN, 'c', NaN, 'c_o', NaN, ...
    'bstar', NaN, 'rer', NaN, 'r_belep_pp', NaN, 'r_sov_pp', NaN, 'r_zaras_pp', NaN, ...
    'bstar_max', NaN, 'y_q', nan(1, 4), 'bstar_q120', NaN);
try
    args = regi_v11_(args); dynare('jv_dsge_v11', args{:}, 'console', 'nograph');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    r.solver_ok = double(oo.deterministic_simulation.status == 1);
    B = bk_check_metrics(M, op, oo);
    oo0 = oo; oo0.steady_state(:) = 0; oo0.exo_steady_state(:) = 0;
    if isfield(oo0, 'exo_det_steady_state'), oo0.exo_det_steady_state(:) = 0; end
    B0 = bk_check_metrics(M, op, oo0);
    r.n_unst_T = B.n_unstable; r.n_unst_I = B0.n_unstable; r.n_fwd = B.n_forward;
    r.ervenyes = double(r.solver_ok == 1 && B.check_ok == 1 && B.bk_ok == 1);
    ev = B.eigenvalues(isfinite(B.eigenvalues)); a = abs(angle(ev));
    c = ev(imag(ev) > 1e-8 & a > 0.12 & a < 0.40 & abs(ev) > 0.85 & abs(ev) < 1.10);
    if ~isempty(c), r.ciklus_z = max(abs(c)); end
    n = cellstr(M.endo_names); g = @(v) 100 * oo.steady_state(strcmp(n, v));
    pn = cellstr(M.param_names); p = @(v) M.params(strcmp(pn, v));
    wE = p('om_E') / (p('om_E') + p('om_D')); wD = 1 - wE;
    r.y = g('y'); r.kkv_l = wE*g('y_E') + wD*g('y_D') - g('y_L');
    r.q_E = g('q_E'); r.q_D = g('q_D'); r.c = g('c'); r.c_o = g('c_o'); r.rer = g('rer');
    ib = strcmp(n, 'bstar'); r.bstar = oo.steady_state(ib);
    S = oo.endo_simul; r.bstar_max = max(abs(S(ib, :)));
    % belepes (13. negyedev = 14. oszlop); evesitett szazalekpont
    ir = strcmp(n, 'r'); xn = cellstr(M.exo_names);
    sov13 = oo.exo_simul(14, strcmp(xn, 'sov'));
    if iz == 2, b = S(ib, 13); else, b = S(ib, 14); end
    r.r_belep_pp = 400 * S(ir, 14);
    iy = strcmp(n, 'y'); r.y_q = 100 * S(iy, [5 21 41 81]); r.bstar_q120 = S(ib, 121);
    r.r_sov_pp = 400 * p('zsov') * sov13;
    r.r_zaras_pp = -400 * p('nu_uni') * b;
catch ME
    fprintf(2, '  !! HIBA (%s): %s\n', strjoin(args, ' '), ME.message);
end
end

function m = modusz_(args, reg)
% A lassu (szog 0.12..0.40 rad) komplex modusz reszvetele az allapotvaltozokban.
m = struct('abs_z', NaN, 'periodus', NaN, 'bstar', NaN, 'd_blokk', NaN, 'top', "");
try
    args = regi_v11_(args); dynare('jv_dsge_v11', args{:}, 'console', 'nograph');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    if reg == "kezdeti"
        oo.steady_state(:) = 0; oo.exo_steady_state(:) = 0;
        if isfield(oo, 'exo_det_steady_state'), oo.exo_det_steady_state(:) = 0; end
    end
    op.order = 1; op.qz_criterium = 1 + 1e-6;
    oo.dr = set_state_space(oo.dr, M);
    [dr, info] = resol(0, M, op, oo.dr, oo.steady_state, oo.exo_steady_state, oo.exo_det_steady_state);
    if info(1) ~= 0, m.top = sprintf("nincs stabil megoldas (info %d)", info(1)); return; end
    sv = dr.state_var; A = dr.ghx(dr.inv_order_var(sv), :);
    [V, Dg] = eig(A); lam = diag(Dg); W = inv(V);
    a = abs(angle(lam)); k = find(imag(lam) > 1e-8 & a > 0.12 & a < 0.40);
    [~, j] = max(abs(lam(k))); k = k(j);
    pf = abs(V(:, k) .* W(k, :).'); pf = pf / sum(pf);
    nm = cellstr(M.endo_names); nsv = nm(sv);
    m.abs_z = abs(lam(k)); m.periodus = 2*pi/abs(angle(lam(k)));
    m.bstar = sum(pf(strcmp(nsv, 'bstar')));
    m.d_blokk = sum(pf(ismember(nsv, {'q_D', 'i_D', 'k_D', 'acc_D', 'nw_D'})));
    [ps, ix] = sort(pf, 'descend');
    m.top = strjoin(arrayfun(@(t) sprintf('%s %.3f', nsv{ix(t)}, ps(t)), 1:6, 'UniformOutput', false), '; ');
catch ME
    m.top = string(ME.message);
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
