% check_hhsp_v12.m — v12: haztartasi kamatfelar (-DHHSP=1) es a kulso zaras rugalmassaga (-DNUB)
% =====================================================================
% A -DHHSP=1 az optimalizalo haztartas Euler-egyenleteben a kamatot
% r + tsov_h*sov + tbank_h*bank-ra cserli: a szuveren es a banki felar egy resze
% a haztartasokat is eleri, mikozben a kozos hazai kamat, a cegek es az allam
% kamata valtozatlan (SOVCSAT=1). A -DNUB a kulso zaras rugalmassaga (nu_b),
% EXTCLOSE>=1 mellett mindket rezsimben; 1 pp eves GDP-aranyos kulso adossag a
% kamatot nu_b*1600 bp-vel emeli.
% Elozmeny (2026-11-11): a SOVCSAT=0-s racs megmutatta, hogy a felar a
% haztartasoknal eladosodast indit, de a SOVCSAT=0 a kozos kamatot mozgatja (a
% cegeket es az allamot is), es a merteket a nem horgonyzott nu_b donti el.
%
% ELORE ROGZITETT ELVARASOK (2026-11-11, futas elott; a SOVCSAT=0-s racs mar ismert volt):
%   K1  A HHSP=0, NUB=0.001 alapag a t68b-ben rogzitett v12-es erteket adja
%       (GDP 16-20. ev, |elteres| < 1e-12).
%   K2  HHSP=1, TSOVH=0, TBANKH=0 mellett minden kozos valtozo palyaja bitre a
%       HHSP=0-e.
%   K3  Tartosan euroban r + tsov_h*sov + tbank_h*bank = 0 (a haztartas reálkamata
%       visszaall), es bstar = (tsov_h*sov + tbank_h*bank)/nu_b analitikusan
%       (rel. hiba < 1e-8).
%   K4  BK: 13 instabil gyok / 13 eloretekinto mindket rezsimben, minden futasban.
%   K5  Csak elojel: az elso 10 evben a fogyasztas magasabb, mint HHSP=0 mellett,
%       es a kulonbseg nu_b-ben csokken; a kulso adossag tartosan negativ.
% Racs: nu_b = 0.001 / 0.0025 / 0.005 / 0.01 (1,6 / 4 / 8 / 16 bp per 1 pp
% adossag), semleges atgyuruzessel (0.175 / 0.45); nu_b = 0.0025 mellett fel
% (0.0875 / 0.225) es teljes (1 / 1) atgyuruzes is. Szamitasi horizont 400
% negyedev; kozolni legfeljebb 20 evet (a fo mutato a 16-20. ev atlaga).
%
% Kimenet: output/tables/t72_hhsp_racs.csv        (futasonkent: BK + fo mutatok)
%          output/tables/t72b_hhsp_osszegzes.csv  (K1-K5, kozolt szamok)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_hhsp_v12"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

% (a nevek nem utkozhetnek parameternevvel: a Dynare a parametereket a munkaterulet
% valtozoikent is beirja)
NURACS = [0.001 0.0025 0.005 0.01];
ATGY = {{'semleges', 0.175, 0.45}, {'fel', 0.0875, 0.225}, {'teljes', 1, 1}};

% --- futasok ---------------------------------------------------------------------------
F = struct('nev', {}, 'hhsp', {}, 'nub', {}, 'atgy', {}, 'R', {});
for knu = 1:numel(NURACS)
    nb = sprintf('-DNUB=%g', NURACS(knu));
    F(end+1) = struct('nev', sprintf('alap_nu%g', NURACS(knu)), 'hhsp', 0, 'nub', NURACS(knu), ...
        'atgy', "", 'R', fut_({nb})); %#ok<SAGROW>
    F(end+1) = struct('nev', sprintf('hhsp_semleges_nu%g', NURACS(knu)), 'hhsp', 1, 'nub', NURACS(knu), ...
        'atgy', "semleges", 'R', fut_({'-DHHSP=1', nb})); %#ok<SAGROW>
end
for ka = 2:3
    a = ATGY{ka};
    F(end+1) = struct('nev', sprintf('hhsp_%s_nu0.0025', a{1}), 'hhsp', 1, 'nub', 0.0025, 'atgy', string(a{1}), ...
        'R', fut_({'-DHHSP=1', '-DNUB=0.0025', sprintf('-DTSOVH=%g', a{2}), sprintf('-DTBANKH=%g', a{3})})); %#ok<SAGROW>
end
RZ = fut_({'-DHHSP=1', '-DTSOVH=0', '-DTBANKH=0'});      % K2

% --- K1, K2 -----------------------------------------------------------------------------
R0 = F(1).R;                                              % HHSP=0, NUB=0.001
V68 = readtable(fullfile(tab, 't68b_v12_osszegzes.csv'));
k1 = abs(100*mean(R0.pa('y', 62:81)) - V68.v12_GDP_1620_pct);
k2 = elteres_(RZ, R0);
fprintf('\nK1 %.3g  K2 %.3g\n', k1, k2);

% --- racs -------------------------------------------------------------------------------
G = table();
for i = 1:numel(F)
    G = [G; sor_(F(i))]; %#ok<AGROW>
end
writetable(G, fullfile(tab, 't72_hhsp_racs.csv'));

% --- osszegzes --------------------------------------------------------------------------
O = table();
O.k1_GDP_elteres = k1; O.k2_maxdiff = k2;
O.K3_max_rel_hiba = max(G.bstar_rel_hiba(G.HHSP == 1));
O.K3_max_rh_tartos = max(abs(G.rh_tartos_bp(G.HHSP == 1)));
O.BK_db = sum(G.ervenyes == 1) + double(RZ.erv); O.BK_ossz = height(G) + 1;
O.instabil_min = min([G.instabil_kezdeti; G.instabil_zaro]); O.instabil_max = max([G.instabil_kezdeti; G.instabil_zaro]);
O.eloretekinto_min = min(G.eloretekinto); O.eloretekinto_max = max(G.eloretekinto);
% K5 es a kozolt szamok: semleges atgyuruzes, nu_b-nkent, a HHSP=0-hoz kepest
for knu = 1:numel(NURACS)
    t = strrep(sprintf('%g', NURACS(knu)), '.', '');
    a = G(G.HHSP == 0 & G.NUB == NURACS(knu), :); h = G(strcmp(G.nev, sprintf('hhsp_semleges_nu%g', NURACS(knu))), :);
    O.(['C_1_10ev_hhsp_nu' t]) = h.C_1_10ev_pct; O.(['C_1_10ev_alap_nu' t]) = a.C_1_10ev_pct;
    O.(['C_1620_hhsp_nu' t]) = h.C_1620_pct; O.(['C_1620_alap_nu' t]) = a.C_1620_pct;
    O.(['C_tartos_hhsp_nu' t]) = h.C_tartos_pct; O.(['GDP_1620_hhsp_nu' t]) = h.GDP_1620_pct;
    O.(['GDP_1620_alap_nu' t]) = a.GDP_1620_pct;
    O.(['bstar_20ev_hhsp_nu' t]) = h.bstar_20ev_eves_GDP_pct; O.(['bstar_tartos_hhsp_nu' t]) = h.bstar_tartos_eves_GDP_pct;
    O.(['rh_1_10ev_hhsp_nu' t]) = h.rh_1_10ev_bp; O.(['GDP_tartos_hhsp_nu' t]) = h.GDP_tartos_pct;
    O.(['r_tartos_hhsp_nu' t]) = h.r_tartos_bp; O.(['r_efpD_tartos_hhsp_nu' t]) = h.r_efpD_tartos_bp;
    O.(['r_efpD_tartos_alap_nu' t]) = a.r_efpD_tartos_bp; O.(['II_1620_hhsp_nu' t]) = h.II_1620_pct;
end
d = arrayfun(@(k) O.(['C_1_10ev_hhsp_nu' strrep(sprintf('%g', NURACS(k)), '.', '')]) - ...
    O.(['C_1_10ev_alap_nu' strrep(sprintf('%g', NURACS(k)), '.', '')]), 1:numel(NURACS));
O.K5_C_1_10ev_magasabb = double(all(d > 0)); O.K5_kulonbseg_csokken = double(all(diff(d) < 0));
O.K5_adossag_negativ = double(all(G.bstar_tartos_eves_GDP_pct(G.HHSP == 1) < 0));
for ka = 2:3
    h = G(strcmp(G.nev, sprintf('hhsp_%s_nu0.0025', ATGY{ka}{1})), :);
    O.(['C_1_10ev_hhsp_' ATGY{ka}{1} '_nu00025']) = h.C_1_10ev_pct;
    O.(['C_1620_hhsp_' ATGY{ka}{1} '_nu00025']) = h.C_1620_pct;
    O.(['bstar_20ev_hhsp_' ATGY{ka}{1} '_nu00025']) = h.bstar_20ev_eves_GDP_pct;
    O.(['GDP_1620_hhsp_' ATGY{ka}{1} '_nu00025']) = h.GDP_1620_pct;
end
writetable(O, fullfile(tab, 't72b_hhsp_osszegzes.csv'));
disp(rows2vars(O));

% =====================================================================
function R = fut_(args)
% Egy futas az aktiv v12-alapagon (+ a megadott kapcsolok), BK mindket rezsimben.
R = struct('ok', 0, 'erv', 0, 'B', [], 'B0', [], 'S', [], 'nev', {{}}, 'p', [], 'ss', [], 'pa', []);
try
    dynare('jv_dsge_v12', args{:}, 'console', 'nograph', 'nolog');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    R.ok = double(oo.deterministic_simulation.status == 1);
    R.B = bk_check_metrics(M, op, oo);
    oo0 = oo; oo0.steady_state(:) = 0; oo0.exo_steady_state(:) = 0;
    if isfield(oo0, 'exo_det_steady_state'), oo0.exo_det_steady_state(:) = 0; end
    R.B0 = bk_check_metrics(M, op, oo0);
    R.erv = double(R.ok == 1 && R.B.check_ok == 1 && R.B.bk_ok == 1 && R.B0.check_ok == 1 && R.B0.bk_ok == 1);
    R.nev = cellstr(M.endo_names); R.S = oo.endo_simul; pn = cellstr(M.param_names);
    pv = M.params; ssv = oo.steady_state; n = R.nev; S = R.S;
    en = cellstr(M.exo_names); xss = oo.exo_steady_state;
    R.p  = @(x) pv(strcmp(pn, x));
    R.ss = @(x) ssv(strcmp(n, x));
    R.pa = @(x, t) S(strcmp(n, x), t);
    R.xs = @(x) xss(strcmp(en, x));
    R.X = oo.exo_simul; R.en = en;
catch ME
    fprintf(2, '  !! HIBA (%s): %s\n', strjoin(args, ' '), ME.message);
end
end

function T = sor_(f)
% Egy racssor: BK, fogyasztas, GDP, a haztartas reálkamata es a kulso adossag.
R = f.R; B = R.B; B0 = R.B0;
ev10 = 2:41; ab = 62:81;                                  % 1-10. ev; 16-20. ev
nT = size(R.S, 2); spp = zeros(1, nT); an = 0; rel = 0; rht = 0;
if f.hhsp == 1
    th = R.p('tsov_h'); tb = R.p('tbank_h');
    spp = (th*R.X(1:nT, strcmp(R.en, 'sov')) + tb*R.X(1:nT, strcmp(R.en, 'bank')))';
    spf = th*R.xs('sov') + tb*R.xs('bank');               % tartos haztartasi felar
    an = spf/R.p('nu_b'); rel = abs(R.ss('bstar') - an)/abs(an);
    rht = 40000*(R.ss('r') + spf - R.ss('infl'));
end
rh = R.pa('r', 1:nT) + spp - R.pa('infl', 1:nT);          % a haztartas reálkamata (felarral)
T = table(string(f.nev), f.hhsp, f.nub, string(f.atgy), R.ok, R.erv, B0.n_unstable, B.n_unstable, B.n_forward, ...
    100*mean(R.pa('c', ev10)), 100*mean(R.pa('c', ab)), 100*R.ss('c'), ...
    100*mean(R.pa('y', ab)), 100*R.ss('y'), 40000*mean(rh(ev10)), 100*R.pa('bstar', 81)/4, ...
    100*R.ss('bstar')/4, 100*an/4, rel, rht, 40000*R.ss('r'), 40000*(R.ss('r') + R.ss('efp_D')), ...
    100*R.ss('ii'), 100*mean(R.pa('ii', ab)), ...
    'VariableNames', {'nev', 'HHSP', 'NUB', 'atgyuruzes', 'solver_ok', 'ervenyes', 'instabil_kezdeti', ...
    'instabil_zaro', 'eloretekinto', 'C_1_10ev_pct', 'C_1620_pct', 'C_tartos_pct', 'GDP_1620_pct', ...
    'GDP_tartos_pct', 'rh_1_10ev_bp', 'bstar_20ev_eves_GDP_pct', 'bstar_tartos_eves_GDP_pct', ...
    'bstar_analitikus_eves_GDP_pct', 'bstar_rel_hiba', 'rh_tartos_bp', 'r_tartos_bp', 'r_efpD_tartos_bp', ...
    'II_tartos_pct', 'II_1620_pct'});
end

function d = elteres_(A, B)
% Max |elteres| a kozos, nem segedvaltozokon.
na = A.nev(~startsWith(A.nev, 'AUX_')); nb = B.nev(~startsWith(B.nev, 'AUX_'));
kozos = intersect(na, nb, 'stable');
[~, ia] = ismember(kozos, A.nev); [~, ib] = ismember(kozos, B.nev);
d = max(abs(A.S(ia, :) - B.S(ib, :)), [], 'all');
end
