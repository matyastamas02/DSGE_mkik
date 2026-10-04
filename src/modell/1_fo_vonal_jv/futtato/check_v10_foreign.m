% check_v10_foreign.m — A v10 KULFOLDI CSATORNA (ystar / r_for) ELLENORZESE
% =====================================================================
% A jv_dsge_v10_foreign.mod a -DFOREIGN=1 kapcsolo alatt visszaepiti az
% EAGLE-mag kulfoldi kereslet/kamat csatornajat (terv:
% docs/terv/2026-09-28_ystar_rstar_implementacios_terv.md). A .mod fejlece
% szerint FOREIGN=1 mellett MEG NINCS futtatva/merve. Ez a script ezt
% potolja -- EREDMENYT NEM KOZOL, csak azt dönti el, hogy a bovites
% technikailag helyes-e. A .mod fajlhoz NEM nyul (Samu dolgozik rajta);
% az impulzus-probakat az exogen palya modositasaval vegzi.
%
% Het ellenorzes:
%
% (0) REGRESSZIO v09 -> v10. FOREIGN=0 mellett a v10-nek BITRE a v09-et
%     kell adnia (a .mod fejlece ezt allitja). SC=1..4, TSCEN=3, a teljes
%     endo_simul palyan. Mindket futasnak PF-konvergensnek kell lennie.
% (1) BEAGYAZAS FOREIGN=1 vs 0. Az euro-szcenariok ystar = r_for = 0-t
%     tartanak vegig, tehat a FOREIGN=1 futasnak a kozos valtozokon
%     PONTOSAN a FOREIGN=0 palyat kell adnia. Ez csak a konstans-
%     szivargast fogja meg, a bekotes elojelet NEM -- arra a (4)/(5) valo.
% (2) BK FOREIGN=1 mellett, KEZDETI (uni=0) ES TERMINALIS (uni=1)
%     rezsimben, SC=1..3 x TSCEN=1..3, plusz a rho_ystar/rho_rfor racs
%     (0.40 / 0.625 / 0.85) SC=1, TSCEN=3 mellett. A kezdeti ellenorzes a
%     bk_candidate_compare_v09.m mintajat koveti: nulla endogen ES nulla
%     exogen steady state (uni=sov=bank=0). Varakozas mindket rezsimben:
%     instabil gyok / eloretekinto valtozo = 13/13 (terv D8).
% (3) NULLA-SOKK FOREIGN=1 mellett (SC=4): PF-konvergens, minden valtozo
%     vegig 0.
% (4) IMPULZUS, LEBEGO REZSIM (SC=4 nulla alap, vegig uni=0):
%     - +1% eps_ystar az 1. periodusban: x_E / x_D / x_L az 1. periodusban
%       NO (elojel-or), es ystar_2 / ystar_1 = rho_ystar (AR-or);
%     - +25 bp eps_rfor (NEGYEDEVES kamat, beta=0.99 -> evesitve ~+100 bp):
%       r_for_2 / r_for_1 = rho_rfor (AR-or); rer/dep/y csak info.
% (5) r_for IMPULZUS A REZSIMVALTAS KORUL (SC=1, TSCEN=3 alap; uni=0 a
%     12. periodusig, uni=1 a 13.-tol). +25 bp eps_rfor kulon-kulon a
%     12., 13. es 14. periodusban. Minden impulzusra:
%     - a ket monetaris egyenlet REZIDUUMA a teljes palyan, a .mod-ban
%       dokumentalt keplettel kivulrol szamolva (ha a bekotes elojele
%       vagy helye mas, mint amit a fejlec allit, ez nem nulla);
%     - az unios agon (k=13, 14) a hazai kamat becsapodaskor NO.
% (6) SAJATERTEKEK: FOREIGN=1 (rho_ystar=0.40, rho_rfor=0.85) teljes
%     sajatertek-halmaza = a FOREIGN=0 halmaz + pontosan {0.40, 0.85},
%     kezdeti es terminalis rezsimben is. Ez igazolja, hogy a ket uj gyok
%     valoban a ket AR-folyamate, es a meglevo gyokok nem mozdultak.
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
TOL_RES  = 1e-7;    % egyenlet-reziduum; egy elojelhiba 25 bp-nel ~5e-3
TOL_AR   = 1e-10;   % AR(1) arany: exogen folyamat, pontos
TOL_EIG  = 1e-6;    % sajatertek-parositas
N_FWD_V09 = 13;     % a v09 OPTEN=0 aganak meresebol (t47)
RFOR_BP  = 0.0025;  % +25 bp negyedeves (~+100 bp evesitett) kulfoldi kamat

S = {};  % {teszt, reszlet, ertek, kuszob, rendben}
% ⚠ A Dynare a BASE workspace-be irja a modell PARAMETEREIT is, azonos
% nevu valtozokkent (pl. sc = 0.54 a fogyasztasi hanyad). Egy `sc` nevu
% ciklusvaltozot ezert az elso futas felulir -- innen az isc/its nevek.

% =====================================================================
% (0) REGRESSZIO v09 -> v10 (FOREIGN=0)
% =====================================================================
fejlec_('(0) REGRESSZIO: v10 FOREIGN=0 == v09?');
for isc = 1:4
    a = fut_('jv_dsge_v09_access', {isc, 3});
    b = fut_('jv_dsge_v10_foreign', {isc, 3, 'FOREIGN=0'});
    d = maxelt_(a, b);
    S(end+1, :) = {'0_regresszio', sprintf('SC=%d TS=3', isc), d, TOL_BIT, d < TOL_BIT}; %#ok<SAGROW>
    fprintf('  SC=%d: max |v10-v09| = %.3e  %s\n', isc, d, ok_(d < TOL_BIT));
end

% =====================================================================
% (1) BEAGYAZAS: FOREIGN=1 (ystar=r_for=0) == FOREIGN=0
% =====================================================================
fejlec_('(1) BEAGYAZAS: FOREIGN=1 nulla kulso sokkal == FOREIGN=0?');
for isc = 1:3
    a = fut_('jv_dsge_v10_foreign', {isc, 3, 'FOREIGN=0'});
    b = fut_('jv_dsge_v10_foreign', {isc, 3, 'FOREIGN=1'});
    d = maxelt_(a, b);
    S(end+1, :) = {'1_beagyazas', sprintf('SC=%d TS=3', isc), d, TOL_NEST, d < TOL_NEST}; %#ok<SAGROW>
    fprintf('  SC=%d: max |F1-F0| = %.3e  %s\n', isc, d, ok_(d < TOL_NEST));
end

% =====================================================================
% (2) BK FOREIGN=1 mellett: kezdeti (uni=0) ES terminalis (uni=1)
% =====================================================================
fejlec_('(2) BK: FOREIGN=1, kezdeti + terminalis, SC x TSCEN es rho-racs');
for isc = 1:3
    for its = 1:3
        r = fut_('jv_dsge_v10_foreign', {isc, its, 'FOREIGN=1'});
        S(end+1, :) = bk_sor_(r, sprintf('SC=%d TS=%d', isc, its), N_FWD_V09); %#ok<SAGROW>
        if isc == 1 && its == 3, r_sc1 = r; end   % az (5) alapfutasa
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
if r0.ok && r0.solver_ok == 1, d = max(abs(r0.simul(:))); else, d = Inf; end
S(end+1, :) = {'3_nulla_sokk', 'SC=4 TS=3 (PF-konvergens)', d, TOL_BIT, d < TOL_BIT};
fprintf('  max |palya| = %.3e  %s\n', d, ok_(d < TOL_BIT));

% =====================================================================
% (4) IMPULZUS, LEBEGO REZSIM (SC=4 alap, a .mod modositasa nelkul)
% =====================================================================
fejlec_('(4) IMPULZUS (uni=0): +1% eps_ystar es +25 bp eps_rfor, SC=4 alapon');
ri = impulzus_(r0, 'eps_ystar', 0.01, 1);
if ri.ok
    dx = [ri.d('x_E', 1), ri.d('x_D', 1), ri.d('x_L', 1)];
    jo = all(dx > 0);
    S(end+1, :) = {'4_ystar_elojel', 'x_E,x_D,x_L az 1. periodusban > 0', min(dx), 0, jo};
    fprintf('  ystar: x_E %+.4f  x_D %+.4f  x_L %+.4f  y %+.4f (1. per., %%)  %s\n', ...
        100*dx, 100*ri.d('y', 1), ok_(jo));
    S(end+1, :) = ar_sor_(ri, 'ystar', 'rho_ystar', TOL_AR);
else
    S(end+1, :) = {'4_ystar_elojel', ['HIBA: ' ri.msg], NaN, 0, false};
end
rr = impulzus_(r0, 'eps_rfor', RFOR_BP, 1);
if rr.ok
    S(end+1, :) = {'4_rfor_info', 'rer (1. per.) -- csak info', rr.d('rer', 1), NaN, true};
    fprintf('  r_for: rer %+.4f  dep %+.4f  y %+.4f  (1. per., %%; csak info)\n', ...
        100*rr.d('rer', 1), 100*rr.d('dep', 1), 100*rr.d('y', 1));
    S(end+1, :) = ar_sor_(rr, 'r_for', 'rho_rfor', TOL_AR);
else
    S(end+1, :) = {'4_rfor_info', ['HIBA: ' rr.msg], NaN, NaN, false};
end

% =====================================================================
% (5) r_for IMPULZUS A REZSIMVALTAS KORUL (SC=1 alap)
% =====================================================================
fejlec_('(5) r_for A REZSIMVALTAS KORUL: SC=1 TS=3, impulzus a 12./13./14. periodusban');
for k = [12 13 14]
    re = impulzus_(r_sc1, 'eps_rfor', RFOR_BP, k);
    if ~re.ok
        S(end+1, :) = {'5_rfor_rezsim', sprintf('k=%d HIBA: %s', k, re.msg), NaN, TOL_RES, false}; %#ok<SAGROW>
        continue
    end
    res = monet_rezid_(re);
    S(end+1, :) = {'5_rfor_rezsim', sprintf('k=%d (uni=%g) monetaris reziduum', k, re.x('uni', k)), ...
        res, TOL_RES, res < TOL_RES}; %#ok<SAGROW>
    fprintf('  k=%d uni=%g: max |reziduum| = %.3e  %s', k, re.x('uni', k), res, ok_(res < TOL_RES));
    if re.x('uni', k) == 1
        dr = re.d('r', k);
        jo = dr > 0;
        S(end+1, :) = {'5_rfor_euro_elojel', sprintf('k=%d dr/dr_for = %.4f', k, dr / RFOR_BP), ...
            dr, 0, jo}; %#ok<SAGROW>
        fprintf('   dr/dr_for = %.4f  %s', dr / RFOR_BP, ok_(jo));
    end
    fprintf('\n');
end

% =====================================================================
% (6) SAJATERTEKEK: FOREIGN=1 = FOREIGN=0 + {rho_ystar, rho_rfor}
% =====================================================================
fejlec_('(6) SAJATERTEKEK: ket uj gyok = {0.40, 0.85}, a tobbi valtozatlan');
e0 = fut_('jv_dsge_v10_foreign', {1, 3, 'FOREIGN=0'});
e1 = fut_('jv_dsge_v10_foreign', {1, 3, 'FOREIGN=1', 'RHOYSTAR=0.40', 'RHORFOR=0.85'});
for rezsim = {'terminalis', 'kezdeti'}
    if ~(e0.ok && e1.ok)
        S(end+1, :) = {'6_sajatertek', [rezsim{1} ' HIBA'], NaN, TOL_EIG, false}; %#ok<SAGROW>
        continue
    end
    if strcmp(rezsim{1}, 'terminalis'), b0 = e0.B; b1 = e1.B; else, b0 = e0.B0; b1 = e1.B0; end
    [maradek, hiba] = sajatertek_kulonbseg_(b1.eigenvalues, b0.eigenvalues, TOL_EIG);
    elter = Inf;
    if ~hiba && numel(maradek) == 2
        elter = max(abs(sort(real(maradek)) - [0.40; 0.85])) + max(abs(imag(maradek)));
    end
    jo = elter < TOL_EIG;
    S(end+1, :) = {'6_sajatertek', sprintf('%s: uj gyokok = %s', rezsim{1}, mat2str(real(maradek(:)'), 6)), ...
        elter, TOL_EIG, jo}; %#ok<SAGROW>
    fprintf('  %-10s uj gyokok: %s  %s\n', rezsim{1}, mat2str(real(maradek(:)'), 6), ok_(jo));
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
% r.ok: a Dynare-hivas lefutott; r.solver_ok: a PF solver konvergalt.
% A ketto kulon mezo -- a hivo dolga mindkettot megkovetelni.
opts = [{sprintf('-DSCENARIO=%d', arg{1}), sprintf('-DTSCEN=%d', arg{2})}, ...
    cellfun(@(s) ['-D' s], arg(3:end), 'UniformOutput', false)];
r = struct('ok', false, 'msg', '', 'solver_ok', 0);
try
    dynare(modell, opts{:}, 'console', 'nograph');
    r.M  = evalin('base', 'M_');
    r.oo = evalin('base', 'oo_');
    r.op = evalin('base', 'options_');
    r.names = cellstr(r.M.endo_names);
    r.simul = r.oo.endo_simul;
    r.solver_ok = double(r.oo.deterministic_simulation.status);
    % terminalis (uni=1) lokalis BK: a PF utani steady state az endval
    r.B = bk_check_metrics(r.M, r.op, r.oo);
    % kezdeti (uni=0) lokalis BK: nulla endogen es exogen steady state
    % (ugyanugy, mint a bk_candidate_compare_v09.m-ben)
    oo0 = r.oo;
    oo0.steady_state = zeros(r.M.endo_nbr, 1);
    oo0.exo_steady_state = zeros(r.M.exo_nbr, 1);
    oo0.exo_det_steady_state = zeros(r.M.exo_det_nbr, 1);
    r.B0 = bk_check_metrics(r.M, r.op, oo0);
    r.ok = true;
catch ME
    r.msg = ME.message;
    fprintf(2, '  !! HIBA (%s %s): %s\n', modell, strjoin(opts, ' '), ME.message);
end
end

function d = maxelt_(a, b)
% A kozos valtozokon, a teljes palyan. Hiba VAGY nem konvergalt PF -> Inf.
d = Inf;
if ~(a.ok && b.ok && a.solver_ok == 1 && b.solver_ok == 1), return, end
[~, ia, ib] = intersect(a.names, b.names, 'stable');
if size(a.simul, 2) ~= size(b.simul, 2), return, end
d = max(max(abs(a.simul(ia, :) - b.simul(ib, :))));
end

function s = bk_sor_(r, reszlet, n_fwd)
if ~r.ok
    s = {'2_bk', [reszlet ' HIBA: ' r.msg], NaN, n_fwd, false};
    fprintf('  %-22s HIBA\n', reszlet); return
end
bt = r.B; bi = r.B0;
jo_t = bt.check_ok == 1 && bt.bk_ok == 1 && bt.n_unstable == n_fwd;
jo_i = bi.check_ok == 1 && bi.bk_ok == 1 && bi.n_unstable == n_fwd;
jo = r.solver_ok == 1 && bt.n_forward == n_fwd && jo_t && jo_i;
s = {'2_bk', sprintf('%s (gyok/elo kezdeti=%d/%d, terminalis=%d/%d, PF=%d)', reszlet, ...
    bi.n_unstable, bi.n_forward, bt.n_unstable, bt.n_forward, r.solver_ok), ...
    bt.n_unstable, n_fwd, jo};
fprintf('  %-22s PF=%d  kezdeti BK=%d (%d/%d)  terminalis BK=%d (%d/%d)  %s\n', reszlet, ...
    r.solver_ok, bi.bk_ok, bi.n_unstable, bi.n_forward, bt.bk_ok, bt.n_unstable, ...
    bt.n_forward, ok_(jo));
end

function ri = impulzus_(rb, sokk, meret, k)
% Az rb alapfutas exogen palyajaba a k. szimulacios periodusban egy
% innovaciot teszunk, es ujraoldjuk. Az exo_simul/endo_simul elso
% maximum_lag sora/oszlopa a kezdeti ertek, ezert a k. periodus indexe
% maximum_lag + k.
%   ri.d(v, j): a v endogen valtozo elterese az alapfutastol a j. periodusban
%   ri.x(v, j): a v exogen valtozo erteke a j. periodusban
ri = struct('ok', false, 'msg', '');
if ~(rb.ok && rb.solver_ok == 1), ri.msg = 'az alapfutas hibas vagy nem konvergalt'; return, end
try
    M_ = rb.M; options_ = rb.op; oo_ = rb.oo;
    j = find(strcmp(cellstr(M_.exo_names), sokk));
    if isempty(j), error('nincs ilyen exogen: %s', sokk); end
    t1 = M_.maximum_lag + 1;
    oo_.exo_simul(t1 + k - 1, j) = oo_.exo_simul(t1 + k - 1, j) + meret;
    try
        oo_ = perfect_foresight_solver(M_, options_, oo_);   % Dynare 6.x
    catch
        assignin('base', 'M_', M_); assignin('base', 'options_', options_);
        assignin('base', 'oo_', oo_);                          % Dynare 5.x
        evalin('base', 'perfect_foresight_solver;');
        oo_ = evalin('base', 'oo_');
    end
    if oo_.deterministic_simulation.status ~= 1
        error('a PF solver nem konvergalt az impulzusra');
    end
    n  = cellstr(M_.endo_names);
    xn = cellstr(M_.exo_names);
    alap = rb.oo.endo_simul;
    uj = oo_.endo_simul;
    ri.d = @(v, jj) uj(strcmp(n, v), t1 + jj - 1) - alap(strcmp(n, v), t1 + jj - 1);
    ri.x = @(v, jj) oo_.exo_simul(t1 + jj - 1, strcmp(xn, v));
    ri.M = M_; ri.oo = oo_; ri.t1 = t1; ri.k = k; ri.periods = options_.periods;
    ri.ok = true;
catch ME
    ri.msg = ME.message;
    fprintf(2, '  !! IMPULZUS-HIBA (%s, k=%d): %s\n', sokk, k, ME.message);
end
end

function s = ar_sor_(ri, valt, param, tol)
% AR(1)-or: az impulzus utani periodusban valt_{k+1} / valt_k = param.
pn = cellstr(ri.M.param_names);
rho = ri.M.params(strcmp(pn, param));
arany = ri.d(valt, ri.k + 1) / ri.d(valt, ri.k);
elter = abs(arany - rho);
s = {'4_ar_perzisztencia', sprintf('%s_{k+1}/%s_k = %.6f (%s = %.6g)', valt, valt, ...
    arany, param, rho), elter, tol, elter < tol};
fprintf('  %s: %s_{k+1}/%s_k = %.6f  vs  %s = %.6g  %s\n', valt, valt, valt, arany, ...
    param, rho, ok_(elter < tol));
end

function e = monet_rezid_(ri)
% A ket rezsimfuggo monetaris egyenlet reziduuma a teljes szimulacios
% palyan, a .mod fejleceben dokumentalt alakban, KIVULROL szamolva:
%   (1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
%       + uni*(r - r_for - zsov*sov + nu_uni*bstar) = 0
%   (1-uni)*(r - r_for - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0
M = ri.M; Y = ri.oo.endo_simul; X = ri.oo.exo_simul; t1 = ri.t1;
n = cellstr(M.endo_names); xn = cellstr(M.exo_names); pn = cellstr(M.param_names);
p = @(v) M.params(strcmp(pn, v));
v = @(nev, t) Y(strcmp(n, nev), t);
x = @(nev, t) X(t, strcmp(xn, nev));
e = 0;
for t = t1:(t1 + ri.periods - 1)
    uni = x('uni', t);
    e1 = (1-uni)*(v('r',t) - p('gam_i')*v('r',t-1) - (1-p('gam_i'))*p('phi_pi')*v('infl',t) ...
        - x('eps_r',t)) + uni*(v('r',t) - v('r_for',t) - p('zsov')*x('sov',t) ...
        + p('nu_uni')*v('bstar',t));
    e2 = (1-uni)*(v('r',t) - v('r_for',t) - v('dep',t+1) + p('nu_b')*v('bstar',t) ...
        - p('zsov')*x('sov',t) - v('e_pr_ar',t)) + uni*v('dep',t);
    e = max([e, abs(e1), abs(e2)]);
end
end

function [maradek, hiba] = sajatertek_kulonbseg_(e1, e0, tol)
% A veges e1 sajatertekek kozul mohon kiveszi az e0 minden veges elemehez
% legkozelebbit; ami megmarad, az az uj gyok. A Dynare a vegtelen
% altalanositott sajatertekeket gyakran NAGY VEGES szamkent adja vissza
% (pl. 3.5e15), ezert az 1e10 feletti modulusz vegtelennek szamit, es a
% parositas RELATIV tureshatarral megy. hiba=true, ha egy e0-elemnek nincs
% parja, vagy a vegtelen gyokok szama elter; a parositas ilyenkor is
% vegigmegy, hogy a maradek informativ legyen.
NAGY = 1e10;
hiba = false;
fin1 = isfinite(e1) & abs(e1) < NAGY; fin0 = isfinite(e0) & abs(e0) < NAGY;
v1 = e1(fin1); v0 = e0(fin0);
if sum(~fin1) ~= sum(~fin0), hiba = true; end
for i = 1:numel(v0)
    [m, j] = min(abs(v1 - v0(i)));
    if isempty(m) || m > tol * max(1, abs(v0(i))), hiba = true; continue, end
    v1(j) = [];
end
maradek = v1;
end

function fejlec_(s)
fprintf('\n%s\n%s\n%s\n', repmat('=', 1, 80), s, repmat('=', 1, 80));
end

function s = ok_(c)
if c, s = 'RENDBEN'; else, s = '*** BUKOTT ***'; end
end
