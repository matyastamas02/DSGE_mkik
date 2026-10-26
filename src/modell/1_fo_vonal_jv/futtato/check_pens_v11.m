% check_pens_v11.m — v11: fiskalis blokk, 2. lepes (-DPENS=1) ellenorzese
% =====================================================================
% A -DPENS=1 (csak -DFISCAL=1 mellett) harmadik haztartastipust (nyugdijas)
% vezet be a JV (76) szerint, fogyasztasi kiadasi sulyokkal (0.75 / 0.10 /
% 0.15), a ber-Phillips-gorbebe a munkapiacon aktivak fogyasztasat (cl) teszi,
% es a nyugdijat bekoti a koltsegvetesbe (s_tr = om_p*sc).
% Brief: docs/terv/2026-10-26_fiskalis_blokk2_implementacios_brief.md
%
% ELORE ROGZITETT ELVARASOK (2026-10-26, futas elott):
%   T2a  PENS=1, OMP=0 mellett minden kozos valtozo palyaja a PENS=0-val
%        (FISCAL=1) azonos, max |elteres| < 1e-10, az aktiv alapagon es a regi
%        beallitason is.
%   T2b  PENS=1, e_trp = 0, euro-szcenario: a sulyok atrendezesenek hatasa
%        onmagaban. A tartos GDP-hatas valtozasa varhatoan kicsi (|d| < 0.1 pp),
%        mert csak a sulyok es a berigeny valtozik. Ha nagyobb, az maga is
%        jelzes. A szamot kozoljuk, barmi jon ki. Ez NEM a nyugdijasok hatasa,
%        hanem a mostani aggregalasi hiba merete.
%   T2c  E2a (SCENARIO=5, nincs euro, ETRP = 0.20): tartosan c_p = 0.20 pontosan;
%        az optimalizalok fogyasztasa csokken; a T szabaly miatt az adossag
%        tartosan analitikusan bg = s_tr*ETRP/(phi_b - (rgbar-1)) = +0.426
%        (kb. +10.7% eves GDP), tls = phi_b*bg. A GDP-hatas elojelet nem
%        jelezzuk elore.
%   T2d  E2b (PENSRULE=1, euro-szcenario): tartosan bg = -0.4292 (mint A32),
%        trp = -(phi_b/s_tr)*bg = +0.2877 analitikusan, tls = 0. Varhatoan a
%        GDP tartosan nagyobb, mint a T szaballyal, mert az optimalizalok
%        szegenyebbek (a megtakaritas nem nekik jut), igy a cl-en at alacsonyabb
%        a berigeny es tobb a munka. Az aggregalt fogyasztas valtozasa a
%        T szabalyhoz kepest kicsi lehet (hazai atcsoportositas, theta_f = 0).
%   T2e  BK: 13 instabil gyok / 13 eloretekinto valtozo mindket rezsimben, az
%        aktiv alapagon a teljes ACCSCALE-racson, T es P szaballyal, OMPTOT =
%        0.15 es 0.22 mellett; a SCENARIO=5-on es a regi beallitason is.
%   T2f  s_tr = om_p*sc gepi pontossaggal; s_tr ~ 0.0746 (KALIB, sc = 0.497).
% Szamitasi horizont 400 negyedev; kozolni legfeljebb 20 evet (a fo mutato a
% 16-20. ev atlaga = 61-80. negyedev).
%
% Kimenet: output/tables/t66_pens_racs.csv        (BK-racs)
%          output/tables/t66b_pens_osszegzes.csv  (T2a-T2f)
%          output/tables/t66c_pens_palyak.csv     (negyedeves palyak, 0-80)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_pens_v11"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

F1 = {'-DFISCAL=1'};
PN = [F1, {'-DPENS=1'}];
racs_acc = [0 20 30 40 50 60 80 100 120 150];
REGI = {'-DKALIB=0', '-DEXTCLOSE=0', '-DSOVCSAT=0', '-DHORIZON=120'};
ab = 62:81;                                      % 61-80. negyedev (16-20. ev)
ETRP = 0.20;

% --- T2a: egymasba agyazas (PENS=1, OMP=0 == PENS=0) --------------------------
RF = fut_(F1);                                   % FISCAL=1, PENS=0
R0 = fut_([PN, {'-DOMP=0'}]);
QF = fut_([REGI, F1]); Q0 = fut_([REGI, PN, {'-DOMP=0'}]);
nest_aktiv = elteres_(RF, R0); nest_regi = elteres_(QF, Q0);
fprintf('\nT2a: max |elteres| aktiv %.3g, regi %.3g\n', nest_aktiv, nest_regi);

% --- T2b: a sulyok atrendezese onmagaban -----------------------------------------
R1 = fut_(PN);                                   % OMP = OMPTOT = 0.15, T szabaly, e_trp = 0
assert(R1.p('om_no') - R1.p('om_p') > 0.05, 'om_no - om_p tul kicsi (CALIB26?)');
R1r = fut_([PN, {'-DOMPTOT=0.22'}]);

% --- T2c: E2a, tartos nyugdijemeles euro nélkul ------------------------------------
R5 = fut_([PN, {'-DSCENARIO=5', sprintf('-DETRP=%g', ETRP)}]);
p5 = R5.p;
bg5_an = p5('s_tr')*ETRP/(p5('phi_b') - (p5('rgbar') - 1));

% --- T2d: E2b, P szabaly az euro-szcenarioban --------------------------------------
RP = fut_([PN, {'-DPENSRULE=1'}]);
pp = RP.p; vp = RP.ss;
bgP_an = pp('bbar_g')*pp('rgbar')*(vp('rg') - vp('infl'))/(pp('phi_b') - (pp('rgbar') - 1));
trpP_an = -(pp('phi_b')/pp('s_tr'))*bgP_an;
fprintf('T2d: bg %.6f (an. %.6f), trp %.6f (an. %.6f)\n', vp('bg'), bgP_an, vp('trp'), trpP_an);

% --- T2e: BK-racs ----------------------------------------------------------------------
G = table();
for pr = [0 1]
    for ot = [0.15 0.22]
        for ia = racs_acc
            r = fut_([PN, {sprintf('-DPENSRULE=%d', pr), sprintf('-DOMPTOT=%g', ot), ...
                sprintf('-DACCSCALE=%g', ia)}]);
            G = [G; sor_("aktiv", pr, ot, ia, 1, r)]; %#ok<AGROW>
        end
    end
end
G = [G; sor_("aktiv_FISCAL1_PENS0", NaN, 0, 100, 1, RF)];
G = [G; sor_("aktiv_SCENARIO5", 0, 0.15, 100, 5, R5)];
G = [G; sor_("aktiv_SCENARIO5_P", 1, 0.15, 100, 5, ...
    fut_([PN, {'-DSCENARIO=5', sprintf('-DETRP=%g', ETRP), '-DPENSRULE=1'}]))];
G = [G; sor_("regi", 0, 0.15, 100, 1, fut_([REGI, PN]))];
G = [G; sor_("regi", 1, 0.15, 100, 1, fut_([REGI, PN, {'-DPENSRULE=1'}]))];
writetable(G, fullfile(tab, 't66_pens_racs.csv'));

% --- palyak (negyedeves, 0-80) ------------------------------------------------------
P = table((0:80)', 'VariableNames', {'negyedev'});
for nv = {'y', 'c', 'c_o', 'c_no', 'w', 'll', 'bg', 'tls'}
    P.([nv{1} '_alap'])   = RF.pa(nv{1}, 1:81)';
    P.([nv{1} '_T2b'])    = R1.pa(nv{1}, 1:81)';
    P.([nv{1} '_E2a'])    = R5.pa(nv{1}, 1:81)';
    P.([nv{1} '_E2b'])    = RP.pa(nv{1}, 1:81)';
end
for nv = {'c_p', 'cl', 'trp'}
    P.([nv{1} '_T2b']) = R1.pa(nv{1}, 1:81)';
    P.([nv{1} '_E2a']) = R5.pa(nv{1}, 1:81)';
    P.([nv{1} '_E2b']) = RP.pa(nv{1}, 1:81)';
end
writetable(P, fullfile(tab, 't66c_pens_palyak.csv'));

% --- osszegzes ---------------------------------------------------------------------
akt = G(G.beallitas == "aktiv", :);
q = @(R, nv, t) R.pa(nv, t + 1);
m = @(R, nv) 100*mean(R.pa(nv, ab));
fx = @(R, nv) 100*R.ss(nv);
O = table();
O.nest_aktiv_maxdiff = nest_aktiv; O.nest_regi_maxdiff = nest_regi;
% T2f
O.s_tr = R1.p('s_tr'); O.s_tr_hiba = abs(R1.p('s_tr') - R1.p('om_p')*R1.p('sc'));
O.om_o = 1 - R1.p('om_no'); O.om_r = R1.p('om_no') - R1.p('om_p'); O.om_p = R1.p('om_p');
% T2b (a sulyok atrendezese, e_trp = 0) a PENS=0-hoz kepest, szazalekpont
for spec = {{R1, 'T2b'}, {R1r, 'T2b_omptot022'}}
    R = spec{1}{1}; t = spec{1}{2};
    O.([t '_dGDP_1620_pp']) = m(R, 'y') - m(RF, 'y');
    O.([t '_dGDP_fix_pp'])  = fx(R, 'y') - fx(RF, 'y');
    O.([t '_dC_1620_pp'])   = m(R, 'c') - m(RF, 'c');
    O.([t '_dC_fix_pp'])    = fx(R, 'c') - fx(RF, 'c');
    O.([t '_dW_fix_pp'])    = fx(R, 'w') - fx(RF, 'w');
    O.([t '_dL_fix_pp'])    = fx(R, 'll') - fx(RF, 'll');
end
O.GDP_1620_PENS0_pct = m(RF, 'y'); O.GDP_1620_T2b_pct = m(R1, 'y');
O.C_fix_PENS0_pct = fx(RF, 'c'); O.C_fix_T2b_pct = fx(R1, 'c');
% T2c (E2a): eltérés a nulla-palyatol (nincs euro), szazalek
O.E2a_ETRP = ETRP;
O.E2a_c_p_fix_pct = fx(R5, 'c_p'); O.E2a_c_fix_pct = fx(R5, 'c'); O.E2a_c_o_fix_pct = fx(R5, 'c_o');
O.E2a_c_1620_pct = m(R5, 'c'); O.E2a_c_o_1620_pct = m(R5, 'c_o');
O.E2a_GDP_fix_pct = fx(R5, 'y'); O.E2a_GDP_1620_pct = m(R5, 'y'); O.E2a_GDP_q4_pct = 100*q(R5, 'y', 4);
O.E2a_ll_fix_pct = fx(R5, 'll'); O.E2a_w_fix_pct = fx(R5, 'w'); O.E2a_rer_fix_pct = fx(R5, 'rer');
O.E2a_bg_fix = R5.ss('bg'); O.E2a_bg_analitikus = bg5_an;
O.E2a_bg_hiba = abs(R5.ss('bg') - bg5_an); O.E2a_tls_fix_GDP_pct = fx(R5, 'tls');
% T2d (E2b): P szabaly az euro-szcenarioban
O.E2b_bg_fix = vp('bg'); O.E2b_bg_analitikus = bgP_an; O.E2b_trp_fix = vp('trp');
O.E2b_trp_analitikus = trpP_an;
O.E2b_rel_hiba = max(abs([vp('bg') - bgP_an, vp('trp') - trpP_an]) ./ abs([bgP_an, trpP_an]));
O.E2b_tls_maxabs = max(abs(RP.pa('tls', ':')));
O.E2b_trp_1ev_pct = 100*q(RP, 'trp', 4); O.E2b_trp_min3ev_pct = 100*min(RP.pa('trp', 2:13));
O.E2b_trp_5ev_pct = 100*q(RP, 'trp', 20); O.E2b_trp_1620_pct = m(RP, 'trp');
O.E2b_dGDP_1620_pp = m(RP, 'y') - m(R1, 'y'); O.E2b_dGDP_fix_pp = fx(RP, 'y') - fx(R1, 'y');
O.E2b_dC_1620_pp = m(RP, 'c') - m(R1, 'c'); O.E2b_dC_fix_pp = fx(RP, 'c') - fx(R1, 'c');
O.E2b_dCo_fix_pp = fx(RP, 'c_o') - fx(R1, 'c_o'); O.E2b_dL_fix_pp = fx(RP, 'll') - fx(R1, 'll');
O.E2b_dW_fix_pp = fx(RP, 'w') - fx(R1, 'w');
O.E2b_GDP_1620_pct = m(RP, 'y');
% T2e
O.BK_aktiv_db = sum(akt.ervenyes == 1); O.BK_aktiv_ossz = height(akt);
O.BK_minden_db = sum(G.ervenyes == 1); O.BK_minden_ossz = height(G);
O.instabil_min = min([G.instabil_kezdeti; G.instabil_zaro]);
O.instabil_max = max([G.instabil_kezdeti; G.instabil_zaro]);
O.eloretekinto_min = min(G.eloretekinto); O.eloretekinto_max = max(G.eloretekinto);
writetable(O, fullfile(tab, 't66b_pens_osszegzes.csv'));
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

function T = sor_(beall, pr, ot, acc, sc, R)
B = R.B; B0 = R.B0;
erv = double(R.ok == 1 && B.check_ok == 1 && B.bk_ok == 1 && B0.check_ok == 1 && B0.bk_ok == 1);
ab = 62:81;
cp = NaN; if any(strcmp(R.nev, 'c_p')), cp = 100*R.ss('c_p'); end
T = table(string(beall), pr, ot, acc, sc, R.ok, erv, B0.n_unstable, B.n_unstable, B.n_forward, ...
    100*mean(R.pa('y', ab)), 100*R.ss('y'), 100*R.ss('c'), cp, R.ss('bg'), ...
    'VariableNames', {'beallitas', 'PENSRULE', 'OMPTOT', 'accscale', 'SCENARIO', 'solver_ok', ...
    'ervenyes', 'instabil_kezdeti', 'instabil_zaro', 'eloretekinto', 'GDP_1620_pct', ...
    'GDP_fix_pct', 'C_fix_pct', 'C_p_fix_pct', 'bg_fix'});
end
