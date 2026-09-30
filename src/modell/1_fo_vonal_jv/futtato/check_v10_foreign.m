% check_v10_foreign.m — A v10 KULFOLDI CSATORNA (ystar / r_for) ELLENORZESE
% =====================================================================
% A jv_dsge_v10_foreign.mod a -DFOREIGN=1 kapcsolo alatt visszaepiti az
% EAGLE-mag kulfoldi kereslet/kamat csatornajat (terv:
% docs/terv/2026-09-28_ystar_rstar_implementacios_terv.md). A .mod fejlece
% szerint FOREIGN=1 mellett MEG NINCS futtatva/merve. Ez a script ezt
% potolja -- EREDMENYT NEM KOZOL, csak azt dönti el, hogy a bovites
% technikailag helyes-e. A .mod fajlhoz NEM nyul (Samu dolgozik rajta);
% az impulzus-probat az exogen palya modositasaval vegzi.
%
% Ot ellenorzes:
%
% (0) REGRESSZIO v09 -> v10. FOREIGN=0 mellett a v10-nek BITRE a v09-et
%     kell adnia (a .mod fejlece ezt allitja). SC=1..4, TSCEN=3, a teljes
%     endo_simul palyan.
% (1) BEAGYAZAS FOREIGN=1 vs 0. Az euro-szcenariok ystar = r_for = 0-t
%     tartanak vegig, tehat a FOREIGN=1 futasnak a kozos valtozokon
%     PONTOSAN a FOREIGN=0 palyat kell adnia. Ha nem, a bekotes
%     (x_j vagy UIP/monetaris ag) konstanst szivarogtat.
% (2) TERMINALIS BK FOREIGN=1 mellett, SC=1..3 x TSCEN=1..3, plusz a
%     rho_ystar/rho_rfor racs (0.40 / 0.625 / 0.85) SC=1, TSCEN=3 mellett.
%     Varakozas: a ket uj AR(1) visszatekinto, tehat az instabil gyokok
%     es az eloretekinto valtozok szama VALTOZATLANUL 13/13.
% (3) NULLA-SOKK FOREIGN=1 mellett (SC=4): minden valtozo vegig 0.
% (4) IMPULZUS-ELOJEL. SC=4 (nulla alap) FOREIGN=1 mellett egy +1%-os
%     eps_ystar az 1. periodusban: az x_E / x_D / x_L exportnak NONIE
%     kell az 1. periodusban. Egy +100 bp eps_rfor-ra a valutaarfolyam-
%     es GDP-valaszt csak KIIRJUK (elojel-orunk nincs ra, mert az
%     uni=0 ag UIP-dinamikaja kalibraciofuggo).
%
% ⚠ Ezek NEM eredmenyek: a rho_ystar/rho_rfor ertekek erzekenysegi
% pontok, hivatkozott forras nelkul. A t56 tablabol GDP-szam nem kozolheto.
% Ha minden sor rendben, a kovetkezo lepes a regiszter 94 parameterre
% bovitese es a t56 or felvetele a smoke_test.m-be (terv 6. szakasz).
%
% Kimenet: output/tables/t56_v10_foreign_ellenorzes.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_v10_foreign"
% Kell hozza: Dynare (DYNARE_PATH vagy C:\dynare\6.5\matlab).

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));

TOL_BIT  = 1e-12;   % v09 == v10 (FOREIGN=0): azonos modell, azonos solver
TOL_NEST = 1e-9;    % FOREIGN=1 vs 0: mas valtozoszam -> solver-tolerancia
N_FWD_V09 = 13;     % a v09 OPTEN=0 aganak meresebol (t47)

S = {};  % {teszt, reszlet, ertek, kuszob, rendben}

% =====================================================================
% (0) REGRESSZIO v09 -> v10 (FOREIGN=0)
% =====================================================================
fejlec_('(0) REGRESSZIO: v10 FOREIGN=0 == v09?');
for sc = 1:4
    a = fut_('jv_dsge_v09_access', {sc, 3});
    b = fut_('jv_dsge_v10_foreign', {sc, 3, 'FOREIGN=0'});
    d = maxelt_(a, b);
    S(end+1, :) = {'0_regresszio', sprintf('SC=%d TS=3', sc), d, TOL_BIT, d < TOL_BIT}; %#ok<SAGROW>
    fprintf('  SC=%d: max |v10-v09| = %.3e  %s\n', sc, d, ok_(d < TOL_BIT));
end

% =====================================================================
% (1) BEAGYAZAS: FOREIGN=1 (ystar=r_for=0) == FOREIGN=0
% =====================================================================
fejlec_('(1) BEAGYAZAS: FOREIGN=1 nulla kulso sokkal == FOREIGN=0?');
for sc = 1:3
    a = fut_('jv_dsge_v10_foreign', {sc, 3, 'FOREIGN=0'});
    b = fut_('jv_dsge_v10_foreign', {sc, 3, 'FOREIGN=1'});
    d = maxelt_(a, b);
    S(end+1, :) = {'1_beagyazas', sprintf('SC=%d TS=3', sc), d, TOL_NEST, d < TOL_NEST}; %#ok<SAGROW>
    fprintf('  SC=%d: max |F1-F0| = %.3e  %s\n', sc, d, ok_(d < TOL_NEST));
end

% =====================================================================
% (2) TERMINALIS BK FOREIGN=1 mellett
% =====================================================================
fejlec_('(2) TERMINALIS BK: FOREIGN=1, SC x TSCEN es rho-racs');
for sc = 1:3
    for ts = 1:3
        r = fut_('jv_dsge_v10_foreign', {sc, ts, 'FOREIGN=1'});
        S(end+1, :) = bk_sor_(r, sprintf('SC=%d TS=%d', sc, ts), N_FWD_V09); %#ok<SAGROW>
    end
end
for rho = [0.40 0.625 0.85]
    r = fut_('jv_dsge_v10_foreign', {1, 3, 'FOREIGN=1', ...
        sprintf('RHOYSTAR=%.6g', rho), sprintf('RHORFOR=%.6g', rho)});
    S(end+1, :) = bk_sor_(r, sprintf('SC=1 TS=3 rho=%.3g', rho), N_FWD_V09); %#ok<SAGROW>
end

% =====================================================================
% (3) NULLA-SOKK FOREIGN=1 mellett
% =====================================================================
fejlec_('(3) NULLA-SOKK: FOREIGN=1, SC=4');
r0 = fut_('jv_dsge_v10_foreign', {4, 3, 'FOREIGN=1'});
d = max(abs(r0.simul(:)));
S(end+1, :) = {'3_nulla_sokk', 'SC=4 TS=3', d, TOL_BIT, d < TOL_BIT};
fprintf('  max |palya| = %.3e  %s\n', d, ok_(d < TOL_BIT));

% =====================================================================
% (4) IMPULZUS-ELOJEL (a .mod modositasa nelkul)
% =====================================================================
fejlec_('(4) IMPULZUS: +1% eps_ystar es +100 bp eps_rfor, SC=4 alapon');
ri = impulzus_(r0, 'eps_ystar', 0.01);
if ri.ok
    dx = [ri.v('x_E'), ri.v('x_D'), ri.v('x_L')];
    jo = all(dx > 0);
    S(end+1, :) = {'4_ystar_elojel', 'x_E,x_D,x_L az 1. periodusban > 0', min(dx), 0, jo};
    fprintf('  ystar: x_E %+.4f  x_D %+.4f  x_L %+.4f  y %+.4f (1. per., %%)  %s\n', ...
        100*dx, 100*ri.v('y'), ok_(jo));
else
    S(end+1, :) = {'4_ystar_elojel', ['HIBA: ' ri.msg], NaN, 0, false};
end
rr = impulzus_(r0, 'eps_rfor', 0.01);
if rr.ok
    S(end+1, :) = {'4_rfor_info', 'rer (1. per.) -- csak info', rr.v('rer'), NaN, true};
    fprintf('  r_for: rer %+.4f  dep %+.4f  y %+.4f  (1. per., %%; csak info)\n', ...
        100*rr.v('rer'), 100*rr.v('dep'), 100*rr.v('y'));
else
    S(end+1, :) = {'4_rfor_info', ['HIBA: ' rr.msg], NaN, NaN, false};
end

% =====================================================================
% OSSZEGZES + KIIRAS
% =====================================================================
T = cell2table(S, 'VariableNames', {'teszt', 'reszlet', 'ertek', 'kuszob', 'rendben'});
T.rendben = double(T.rendben);
writetable(T, fullfile(repo, 'output', 'tables', 't56_v10_foreign_ellenorzes.csv'));
fejlec_(sprintf('EREDMENY: %d/%d sor rendben', sum(T.rendben), height(T)));
if all(T.rendben)
    fprintf(['  A v10 FOREIGN=1 ag technikailag helyes. Kovetkezo lepes: regiszter\n' ...
        '  94 parameterre + t56 or a smoke_test.m-be. GDP-szam MEG NEM kozolheto.\n']);
else
    disp(T(T.rendben == 0, :));
end

% =====================================================================
% SEGEDFUGGVENYEK
% =====================================================================
function r = fut_(modell, arg)
% arg = {SCENARIO, TSCEN, 'KAPCSOLO=ertek', ...}
opts = [{sprintf('-DSCENARIO=%d', arg{1}), sprintf('-DTSCEN=%d', arg{2})}, ...
    cellfun(@(s) ['-D' s], arg(3:end), 'UniformOutput', false)];
r = struct('ok', false, 'msg', '');
try
    dynare(modell, opts{:}, 'console', 'nograph');
    r.M  = evalin('base', 'M_');
    r.oo = evalin('base', 'oo_');
    r.op = evalin('base', 'options_');
    r.names = cellstr(r.M.endo_names);
    r.simul = r.oo.endo_simul;
    r.solver_ok = double(r.oo.deterministic_simulation.status);
    r.B = bk_check_metrics(r.M, r.op, r.oo);
    r.ok = true;
catch ME
    r.msg = ME.message;
    fprintf(2, '  !! HIBA (%s %s): %s\n', modell, strjoin(opts, ' '), ME.message);
end
end

function d = maxelt_(a, b)
% A kozos valtozokon, a teljes palyan. Hiba -> Inf (a teszt bukik).
d = Inf;
if ~(a.ok && b.ok), return, end
[k, ia, ib] = intersect(a.names, b.names, 'stable'); %#ok<ASGLU>
if size(a.simul, 2) ~= size(b.simul, 2), return, end
d = max(max(abs(a.simul(ia, :) - b.simul(ib, :))));
end

function s = bk_sor_(r, reszlet, n_fwd)
if ~r.ok
    s = {'2_bk', [reszlet ' HIBA: ' r.msg], NaN, n_fwd, false};
    fprintf('  %-22s HIBA\n', reszlet); return
end
jo = r.solver_ok == 1 && r.B.check_ok == 1 && r.B.bk_ok == 1 && ...
    r.B.n_forward == n_fwd && r.B.n_unstable == n_fwd;
s = {'2_bk', sprintf('%s (gyok/elo=%d/%d, PF=%d)', reszlet, r.B.n_unstable, ...
    r.B.n_forward, r.solver_ok), r.B.n_unstable, n_fwd, jo};
fprintf('  %-22s PF=%d  BK=%d  gyok/elo=%d/%d  %s\n', reszlet, r.solver_ok, ...
    r.B.bk_ok, r.B.n_unstable, r.B.n_forward, ok_(jo));
end

function ri = impulzus_(r0, sokk, meret)
% Az SC=4 (nulla) futas exogen palyajaba egy 1. periodusi innovaciot
% teszunk, es ujraoldjuk. Az exo_simul 1. sora a kezdeti periodus, ezert
% az 1. szimulacios periodus a (maximum_lag+1). sor.
ri = struct('ok', false, 'msg', '');
if ~r0.ok, ri.msg = 'az SC=4 alapfutas hibas'; return, end
try
    M_ = r0.M; options_ = r0.op; oo_ = r0.oo;
    j = find(strcmp(cellstr(M_.exo_names), sokk));
    if isempty(j), error('nincs ilyen exogen: %s', sokk); end
    t1 = M_.maximum_lag + 1;
    oo_.exo_simul(t1, j) = oo_.exo_simul(t1, j) + meret;
    try
        oo_ = perfect_foresight_solver(M_, options_, oo_);   % Dynare 6.x
    catch
        assignin('base', 'oo_', oo_);                          % Dynare 5.x
        evalin('base', 'perfect_foresight_solver;');
        oo_ = evalin('base', 'oo_');
    end
    if oo_.deterministic_simulation.status ~= 1
        error('a PF solver nem konvergalt az impulzusra');
    end
    n = cellstr(M_.endo_names);
    ri.v = @(v) oo_.endo_simul(strcmp(n, v), t1);
    ri.ok = true;
catch ME
    ri.msg = ME.message;
    fprintf(2, '  !! IMPULZUS-HIBA (%s): %s\n', sokk, ME.message);
end
end

function fejlec_(s)
fprintf('\n%s\n%s\n%s\n', repmat('=', 1, 80), s, repmat('=', 1, 80));
end

function s = ok_(c)
if c, s = 'RENDBEN'; else, s = '*** BUKOTT ***'; end
end
