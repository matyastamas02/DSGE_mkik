% check_fiscal1_v11.m — v11: fiskalis blokk, 1. lepes (-DFISCAL=1) ellenorzese
% =====================================================================
% A -DFISCAL=1 allamadossagot, kamatkiadast, egyosszegu adot adossagszaballyal,
% lejarati szerkezetet es a kulfoldiek altal tartott adossag kamatanak a kulso
% pozicioba koteset (tulajdonosi zaras) kapcsolja be.
% Brief: docs/terv/2026-10-25_fiskalis_blokk1_implementacios_brief.md
%
% ELORE ROGZITETT ELVARASOK (2026-10-25, futas elott):
%   T1a  FISCAL=1, THETAF=0 mellett minden regi valtozo palyaja a FISCAL=0-val
%        azonos (max |elteres| < 1e-10), az aktiv alapagon es a regi
%        beallitason is (ricardoi teszt: a hazai resz nyilvantartas);
%        SCENARIO=4 (nulla sokk) mellett minden valtozo 0.
%   T1b  a tartos adossag es ado az analitikus keplettel egyezik:
%            bg = bbar_g*rgbar*(rg - infl)/(phi_b - (rgbar-1)),  tls = phi_b*bg
%        (relativ elteres < 1e-8). Varhato nagysagrend az alapszcenarioban
%        (sov = -0.005; euroban tartosan r = 0): bg ~ -0.43 negyedeves GDP
%        (kb. -10.7% eves GDP), tls ~ -0.021 (kb. 2.1% GDP/ev adocsokkentes,
%        ebbol kb. 1.5% a kozvetlen kamatmegtakaritas, a tobbi a kisebb
%        adossag kamata).
%   T1c  THETAF=0.4 (SZEMLELTETES, nem adat): a kulso pozicio a csatlakozas
%        utan javul; a tartos bstar = 0 marad (SOVCSAT=1: euroban r = -nu_b*bstar,
%        es tartosan r = 0), ezert a nyereseg tartosan negativabb kereskedelmi
%        merlegkent (tobb fogyasztas, tobb import) jelenik meg. A tartos
%        nyereseg-aram theta_f*(bbar_g*|drg| + (rgbar-1/beta)*|dbg|)
%        ~ 0.4*(1.48% + 0.21%) ~ 0.68% GDP/ev. A forintos szakaszban (1-12.
%        negyedev) a bejelentesi felertekelodes miatt az aram negativ lehet.
%        A GDP-hatas elojelet es nagysagat NEM jelezzuk elore -- barmi jon ki,
%        kozoljuk.
%   T1d  BK: 13 instabil gyok / 13 eloretekinto valtozo mindket rezsimben, az
%        aktiv alapagon a teljes ACCSCALE-racson (THETAF = 0 es 0.4), a regi
%        beallitason (ACC = 100) es FOREIGN=1 mellett is. Az adossag stabil
%        gyoke rgbar - phi_b = 0.965 (THETAF=0 mellett pontosan).
%   T1e  RHOM=0.95: a tartos ertek (bg, tls) azonos a RHOM=0 esettel; a
%        kamatmegtakaritas lassabban epul fel (az 1. es 5. evben kisebb).
% Szamitasi horizont 400 negyedev; kozolni legfeljebb 20 evet (a fo mutato a
% 16-20. ev atlaga = 61-80. negyedev).
%
% Kimenet: output/tables/t65_fiscal1_racs.csv        (BK-racs)
%          output/tables/t65b_fiscal1_osszegzes.csv  (T1a-T1e)
%          output/tables/t65c_fiscal1_palyak.csv     (negyedeves palyak, 0-80)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_fiscal1_v11"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

THETA = 0.4;                                     % szemleltetes, nem adat
racs_acc = [0 20 30 40 50 60 80 100 120 150];
REGI = {'-DKALIB=0', '-DEXTCLOSE=0', '-DSOVCSAT=0', '-DHORIZON=120'};
ab = 62:81;                                      % 61-80. negyedev (16-20. ev)

% --- T1a: egymasba agyazas (FISCAL=1, THETAF=0 == FISCAL=0) ------------------
R0 = fut_({});                                   % aktiv alapag, FISCAL=0
R1 = fut_({'-DFISCAL=1'});                       % aktiv alapag, THETAF=0
Q0 = fut_(REGI);
Q1 = fut_([REGI, {'-DFISCAL=1'}]);
nest_aktiv = elteres_(R0, R1); nest_regi = elteres_(Q0, Q1);
Z4 = fut_({'-DFISCAL=1', sprintf('-DTHETAF=%g', THETA), '-DSCENARIO=4'});
sc4_maxabs = max(abs(Z4.S), [], 'all');
fprintf('\nT1a: max |elteres| aktiv %.3g, regi %.3g; SCENARIO=4 max |x| %.3g\n', ...
    nest_aktiv, nest_regi, sc4_maxabs);

% --- T1b: analitikus tartos ertek -------------------------------------------
p = R1.p; v = R1.ss;
rg_fix = v('rg'); infl_fix = v('infl');
bg_an = p('bbar_g')*p('rgbar')*(rg_fix - infl_fix)/(p('phi_b') - (p('rgbar') - 1));
tls_an = p('phi_b')*bg_an;
t1b_rel = max(abs([v('bg') - bg_an, v('tls') - tls_an]) ./ abs([bg_an, tls_an]));
fprintf('T1b: bg %.6f (analitikus %.6f), tls %.6f (%.6f), rel. hiba %.3g\n', ...
    v('bg'), bg_an, v('tls'), tls_an, t1b_rel);

% --- T1c: kulfoldi tulajdonosi resz (THETAF = 0.4, szemleltetes) -------------
R4 = fut_({'-DFISCAL=1', sprintf('-DTHETAF=%g', THETA)});
ny4 = nyereseg_(R4);

% --- T1e: lejarati szerkezet ----------------------------------------------------
RM = fut_({'-DFISCAL=1', '-DRHOM=0.95'});

% --- T1d: BK-racs ------------------------------------------------------------------
G = table();
for th = [0 THETA]
    for ia = racs_acc
        r = fut_({'-DFISCAL=1', sprintf('-DTHETAF=%g', th), sprintf('-DACCSCALE=%g', ia)});
        G = [G; sor_("aktiv", th, 0, ia, r)]; %#ok<AGROW>
    end
end
G = [G; sor_("aktiv_FISCAL0", 0, 0, 100, R0)];
G = [G; sor_("aktiv_RHOM095", 0, 0.95, 100, RM)];
G = [G; sor_("regi_FISCAL0", 0, 0, 100, Q0)];
G = [G; sor_("regi", 0, 0, 100, Q1)];
G = [G; sor_("regi", THETA, 0, 100, fut_([REGI, {'-DFISCAL=1', sprintf('-DTHETAF=%g', THETA)}]))];
G = [G; sor_("aktiv_FOREIGN1", THETA, 0, 100, ...
    fut_({'-DFISCAL=1', sprintf('-DTHETAF=%g', THETA), '-DFOREIGN=1'}))];
writetable(G, fullfile(tab, 't65_fiscal1_racs.csv'));

% --- palyak (negyedeves, 0-80) -----------------------------------------------
P = table((0:80)', 'VariableNames', {'negyedev'});
for nv = {'bg', 'tls', 'intexp', 'rge', 'bstar'}
    P.([nv{1} '_th0'])   = R1.pa(nv{1}, 1:81)';
    P.([nv{1} '_th04'])  = R4.pa(nv{1}, 1:81)';
    P.([nv{1} '_rhom'])  = RM.pa(nv{1}, 1:81)';
end
P.nyereseg_aram_th04 = ny4(1:81)';
for nv = {'y', 'c', 'im', 'rer', 'dep'}
    P.(['d_' nv{1} '_th04_pp']) = 100*(R4.pa(nv{1}, 1:81) - R1.pa(nv{1}, 1:81))';
end
writetable(P, fullfile(tab, 't65c_fiscal1_palyak.csv'));

% --- osszegzes -----------------------------------------------------------------
akt = G(G.beallitas == "aktiv", :); rg_ = G(G.beallitas == "regi", :);
b = R1; m = RM;
q = @(R, nv, t) R.pa(nv, t + 1);                % t. negyedev erteke
O = table();
O.nest_aktiv_maxdiff = nest_aktiv; O.nest_regi_maxdiff = nest_regi; O.sc4_maxabs = sc4_maxabs;
O.bg_fix = v('bg'); O.bg_analitikus = bg_an; O.tls_fix = v('tls'); O.tls_analitikus = tls_an;
O.t1b_rel_hiba = t1b_rel;
O.rg_fix_pp_eves = 400*rg_fix;
O.adossag_valtozas_eves_GDP_pct = 100*v('bg')/4;
O.ado_valtozas_GDP_pct = 100*v('tls');
O.kamatmegtakaritas_kozvetlen_GDP_pct = 100*p('bbar_g')*p('rgbar')*(rg_fix - infl_fix);
O.kamatkiadas_fix_GDP_pct = 100*v('intexp');
O.bg_5ev_arany = q(b, 'bg', 20)/v('bg'); O.bg_20ev_arany = q(b, 'bg', 80)/v('bg');
O.ado_1620_GDP_pct = 100*mean(b.pa('tls', ab));
O.kamatkiadas_1ev_GDP_pct = 100*q(b, 'intexp', 4); O.kamatkiadas_5ev_GDP_pct = 100*q(b, 'intexp', 20);
O.kamatkiadas_1620_GDP_pct = 100*mean(b.pa('intexp', ab));
% T1c
O.theta_f = THETA;
O.nyereseg_aram_fix_GDP_pct = 100*ny4(end);
O.nyereseg_aram_1620_GDP_pct = 100*mean(ny4(ab));
O.nyereseg_aram_forint_atl_GDP_pct = 100*mean(ny4(2:13));      % 1-12. negyedev
O.nyereseg_aram_forint_min_GDP_pct = 100*min(ny4(2:13));
O.bstar_th04_max = max(R4.pa('bstar', 1:81)); O.bstar_th04_q80 = q(R4, 'bstar', 80);
O.bstar_th04_fix = R4.ss('bstar');
d_ = @(nv) 100*(R4.pa(nv, ab) - R1.pa(nv, ab));
O.dGDP_1620_pp = mean(d_('y')); O.dC_1620_pp = mean(d_('c')); O.dIM_1620_pp = mean(d_('im'));
O.dRER_1620_pp = mean(d_('rer'));
O.dGDP_fix_pp = 100*(R4.ss('y') - R1.ss('y')); O.dC_fix_pp = 100*(R4.ss('c') - R1.ss('c'));
O.dIM_fix_pp = 100*(R4.ss('im') - R1.ss('im'));
O.GDP_1620_th0_pct = 100*mean(R1.pa('y', ab)); O.GDP_1620_th04_pct = 100*mean(R4.pa('y', ab));
% T1d
O.BK_aktiv_db = sum(akt.ervenyes == 1); O.BK_aktiv_ossz = height(akt);
O.BK_regi_db = sum(rg_.ervenyes == 1); O.BK_regi_ossz = height(rg_);
O.BK_minden_db = sum(G.ervenyes == 1); O.BK_minden_ossz = height(G);
O.instabil_min = min([G.instabil_kezdeti; G.instabil_zaro]);
O.instabil_max = max([G.instabil_kezdeti; G.instabil_zaro]);
O.eloretekinto_min = min(G.eloretekinto); O.eloretekinto_max = max(G.eloretekinto);
O.gyok_0965_th0 = all(akt.gyok_adossag(akt.THETAF == 0) == 1);
% T1e
O.rhom_bg_fix_elteres = abs(m.ss('bg') - v('bg'));
O.rhom_kamatkiadas_1ev_GDP_pct = 100*q(m, 'intexp', 4);
O.rhom_kamatkiadas_5ev_GDP_pct = 100*q(m, 'intexp', 20);
O.rhom_kamatkiadas_1620_GDP_pct = 100*mean(m.pa('intexp', ab));
O.rhom_bg_20ev_arany = q(m, 'bg', 80)/m.ss('bg');
writetable(O, fullfile(tab, 't65b_fiscal1_osszegzes.csv'));
disp(rows2vars(O));

% =====================================================================
function R = fut_(args)
% Egy futas az aktiv v11-alapagon (+ a megadott kapcsolok), BK mindket rezsimben.
R = struct('ok', 0, 'B', [], 'B0', [], 'S', [], 'nev', {{}});
try
    dynare('jv_dsge_v11', args{:}, 'console', 'nograph', 'nolog');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    R.ok = double(oo.deterministic_simulation.status == 1);
    R.B = bk_check_metrics(M, op, oo);
    oo0 = oo; oo0.steady_state(:) = 0; oo0.exo_steady_state(:) = 0;
    if isfield(oo0, 'exo_det_steady_state'), oo0.exo_det_steady_state(:) = 0; end
    R.B0 = bk_check_metrics(M, op, oo0);
    R.nev = cellstr(M.endo_names); R.S = oo.endo_simul; pn = cellstr(M.param_names);
    pv = M.params; ssv = oo.steady_state; n = R.nev; S = R.S;
    R.p  = @(x) pv(strcmp(pn, x));
    R.ss = @(x) ssv(strcmp(n, x));
    R.pa = @(x, t) S(strcmp(n, x), t);
catch ME
    fprintf(2, '  !! HIBA (%s): %s\n', strjoin(args, ' '), ME.message);
end
end

function d = elteres_(A, B)
[~, ia, ib] = intersect(A.nev, B.nev, 'stable');
d = max(abs(A.S(ia, :) - B.S(ib, :)), [], 'all');
if numel(ia) ~= numel(A.nev), d = NaN; end      % minden regi valtozonak meg kell lennie
end

function f = nyereseg_(R)
% A tulajdonosi zaras tagja a bstar-egyenletben (+ = az orszag nyer), negyedevenkent.
% f(t) = -theta_f*( bbar_g*(rge(t-1) - dep(t)) + (rgbar - 1/beta)*bg(t-1) )
th = R.p('theta_f'); bb = R.p('bbar_g'); rr = R.p('rgbar'); be = R.p('beta');
rge = R.pa('rge', ':'); dep = R.pa('dep', ':'); bg = R.pa('bg', ':');
f = zeros(size(rge));
f(2:end) = -th*(bb*(rge(1:end-1) - dep(2:end)) + (rr - 1/be)*bg(1:end-1));
end

function T = sor_(beall, th, rhom, acc, R)
B = R.B; B0 = R.B0;
erv = double(R.ok == 1 && B.check_ok == 1 && B.bk_ok == 1 && B0.check_ok == 1 && B0.bk_ok == 1);
gy = NaN; bgf = NaN;
if any(strcmp(R.nev, 'bg'))
    ev = B.eigenvalues(isfinite(B.eigenvalues));
    gy = double(any(abs(ev - (R.p('rgbar') - R.p('phi_b'))) < 1e-8));
    bgf = R.ss('bg');
end
ab = 62:81;
T = table(string(beall), th, rhom, acc, R.ok, erv, B0.n_unstable, B.n_unstable, B.n_forward, gy, ...
    100*mean(R.pa('y', ab)), 100*R.ss('y'), R.ss('bstar'), bgf, ...
    'VariableNames', {'beallitas', 'THETAF', 'RHOM', 'accscale', 'solver_ok', 'ervenyes', ...
    'instabil_kezdeti', 'instabil_zaro', 'eloretekinto', 'gyok_adossag', 'GDP_1620_pct', ...
    'GDP_fix_pct', 'bstar_fix', 'bg_fix'});
end
