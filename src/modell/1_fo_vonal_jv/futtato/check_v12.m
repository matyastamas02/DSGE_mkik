% check_v12.m — v12 (a fo csapas): B-forma hozzaferes, JV-exportegyenlet, javitott nettovagyon
% =====================================================================
% A v12 a v11 masolata harom uj alapertelmezessel (lasd a .mod fejlecet):
%   -DACCFORM=1  B-forma: tokekoltseg-ek (efp = efpA - mu*acc), az omega_acc
%                tag kikerul a beruhazasi Eulerbol
%   -DEXPJV=1    JV-exportegyenlet, az (1-hx) suly nelkul
%   -DNWFIX=1    javitott nettovagyon-egyenlet: az adossag utan a szuveren es
%                a banki felar is levonodik, gam_nwx = omega_nw*beta
% Forras: kulso reviewer, "A hitelhozzaferesi csatorna: a B, C es B+C
% eredmenyei" (2026-11). A reviewer szamai a K3-ban celertekkent szerepelnek.
%
% ELORE ROGZITETT ELVARASOK (2026-11-07, futas elott):
%   K1  Nesting: -DACCFORM=0 -DEXPJV=0 -DNWFIX=0 mellett minden palya bitre a
%       v11 alapertelmezese (max |elteres| = 0).
%   K2  A B-forma mu = 0 mellett a valos valtozokban azonos a hozzaferes
%       nelkuli A-formaval (ACCSCALE=0), max |elteres| < 1e-12 (az acc es az
%       efpA kivetelevel, mert azok csak a B-formaban leteznek / hatnak).
%   K3  Reprodukcio: a reviewer v11-es tablai (1., 2., 3., 4., 6., 7. tabla,
%       harom mu, mindket nettovagyon-egyenlet) a kozolt kerekitesi
%       pontossaggal visszajonnek (|elteres| <= a kozolt utolso jegy fele).
%       Ha nem, a gam_nwx vagy egy feltevesunk mas, mint a reviewere.
%   K4  BK: 13 instabil gyok / 13 eloretekinto mindket rezsimben, minden
%       futasban (a 3 szcenario x 3 atgyuruzes racson is).
%   K5  Csak elojel: a v12 alapjan a hozzaferesi csatorna hozzajarulasa a
%       tartos GDP-hez pozitiv es kicsi (< 0.05 pp); a D-tipus kibocsatasa no,
%       az L-e csokken.
% Szamitasi horizont 400 negyedev; kozolni legfeljebb 20 evet (a fo mutato a
% 16-20. ev atlaga = 61-80. negyedev). A reviewer idoszakai: konvergencia
% 1-12., kozeptav 21-32. negyedev, tartos = a zaro allandosult allapot.
%
% Kimenet: output/tables/t68_v12_racs.csv        (futasonkent: BK + fo mutatok)
%          output/tables/t68b_v12_osszegzes.csv  (K1-K5, kozolt szamok)
%          output/tables/t68c_v12_reviewer.csv   (a reviewer szamai es a mieink)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_v12"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

M12 = 'jv_dsge_v12';
MU0 = {'-DACCMUE=0', '-DACCMUD=0'};
MU = struct('B005', {{'-DACCMUE=0.005', '-DACCMUD=0.005'}}, 'Bmert', {{}}, ...
            'Bfelso', {{'-DACCMUE=0.0104', '-DACCMUD=0.0188'}});
mun = fieldnames(MU);

% --- futasok ---------------------------------------------------------------------------
% -- V12_CACHE=1: a legutobbi futasok betoltese (csak az utofeldolgozas ismetlesehez)
gyorsitotar = fullfile(tempdir, 'check_v12_futasok.mat');
if strcmp(getenv('V12_CACHE'), '1') && isfile(gyorsitotar)
    load(gyorsitotar, 'R', 'racs');
else
R = struct();
R.v11      = fut_('jv_dsge_v11', {});
R.v12_regi = fut_(M12, {'-DACCFORM=0', '-DEXPJV=0', '-DNWFIX=0'});
R.A0_n0    = fut_(M12, {'-DACCFORM=0', '-DACCSCALE=0', '-DNWFIX=0'});
for nw = 0:1
    n = sprintf('-DNWFIX=%d', nw); s = sprintf('_n%d', nw);
    R.(['alap' s]) = fut_(M12, [MU0, {n}]);                          % hozzaferesi csatorna nelkul
    for k = 1:numel(mun)
        R.([mun{k} s]) = fut_(M12, [MU.(mun{k}), {n}]);
    end
    R.(['A' s]) = fut_(M12, {'-DACCFORM=0', n});                     % a v11 A-formaja, JV-exporttal
end
R.alap_regiexp_n0 = fut_(M12, [MU0, {'-DEXPJV=0', '-DNWFIX=0'}]);
R.alap_regiexp_n1 = fut_(M12, [MU0, {'-DEXPJV=0', '-DNWFIX=1'}]);
% a v12 alapertelmezese a 3 szcenario x 3 atgyuruzes racson (a Bmert_n1 = SCENARIO 1, TSCEN 3)
racs = {};
% (a ciklusvaltozok neve nem utkozhet parameternevvel: a Dynare a parametereket
% a munkaterulet valtozoikent is beirja, pl. sc = 0.497)
for iszc = 1:3
    for itsc = 1:3
        nev = sprintf('v12_s%d_t%d', iszc, itsc);
        if iszc == 1 && itsc == 3, R.(nev) = R.Bmert_n1;
        else, R.(nev) = fut_(M12, {sprintf('-DSCENARIO=%d', iszc), sprintf('-DTSCEN=%d', itsc)}); end
        racs{end+1} = nev; %#ok<SAGROW>
    end
end
save(gyorsitotar, 'R', 'racs');
end

% --- K1, K2 -----------------------------------------------------------------------------
nest = elteres_(R.v12_regi, R.v11, {});
k2 = elteres_(R.alap_n0, R.A0_n0, {'acc_E', 'acc_D', 'efpA_E', 'efpA_D'});
fprintf('\nK1 %.3g  K2 %.3g\n', nest, k2);

% --- mutatok ---------------------------------------------------------------------------
nevek = fieldnames(R);
Mt = struct();
for i = 1:numel(nevek), Mt.(nevek{i}) = mutat_(R.(nevek{i})); end

% --- K3: a reviewer szamai (v11 vegleges kalibracio, JV-export) ------------------------
% {futas, mutato, ertek, tizedes}; a d-mutatok a hozzaferes nelkuli futashoz kepest.
C = {};
cel = @(f, m, v, d) {f, m, v, d};
t1 = {'GDPkonv', 'GDPkozep', 'GDPtartos', 'efpEkozep', 'efpEtartos', 'efpDkozep', 'efpDtartos'};
d1 = [3 3 3 2 2 2 2];
v1 = [-0.556 0.146 0.214 -21.55 -16.68 -20.53 -16.62; -0.519 0.295 0.379 -29.94 -27.36 -27.65 -26.07];
for nw = 0:1
    for m = 1:numel(t1), C(end+1, :) = cel(sprintf('alap_n%d', nw), t1{m}, v1(nw+1, m), d1(m)); end %#ok<SAGROW>
end
t2 = {'dfelarE_t', 'dfelarD_t', 'dfelarL_t', 'accE_t', 'accD_t'};
v2 = [-0.32 -0.38 -0.01 0.53 0.65; -0.33 -0.82 -0.02 0.53 0.61; -0.64 -1.24 -0.04 0.51 0.57; ...
      -0.53 -0.60 -0.02 0.87 1.03; -0.54 -1.29 -0.04 0.87 0.96; -1.05 -1.94 -0.06 0.83 0.89];
t3 = {'dfelarE_k', 'dfelarD_k', 'dfelarL_k', 'accE_k', 'accD_k'};
v3 = [-0.67 -0.78 -0.03 0.70 0.84; -0.70 -1.74 -0.07 0.70 0.81; -1.39 -2.70 -0.11 0.68 0.77; ...
      -0.86 -0.96 -0.04 0.90 1.04; -0.90 -2.14 -0.09 0.90 1.00; -1.77 -3.33 -0.14 0.88 0.96];
t4 = {'dyE_t', 'dyD_t', 'dyL_t', 'diE_t', 'diD_t', 'diL_t'};
v4 = [0.002 0.009 -0.004 0.018 0.027 -0.002; 0.000 0.019 -0.008 0.018 0.058 -0.004; ...
      0.001 0.028 -0.012 0.035 0.087 -0.006; 0.003 0.013 -0.006 0.029 0.042 -0.003; ...
      0.000 0.029 -0.013 0.030 0.090 -0.007; 0.002 0.044 -0.019 0.058 0.136 -0.010];
t6 = {'dlE_t', 'dlD_t', 'dlL_t', 'dKKVL_t'};
v6 = [0.001 0.007 -0.003 0.011; 0.000 0.015 -0.007 0.023; 0.001 0.022 -0.011 0.035; ...
      0.002 0.011 -0.005 0.017; 0.000 0.023 -0.011 0.037; 0.001 0.035 -0.017 0.056];
t7 = {'dGDPkonv', 'dGDPkozep', 'dGDPtartos', 'dIIkozep', 'dIItartos', 'dLLkozep', 'dLLtartos'};
v7 = [0.002 0.003 0.002 0.018 0.011 0.004 0.002; 0.004 0.006 0.004 0.035 0.021 0.007 0.005; ...
      0.006 0.009 0.007 0.053 0.033 0.011 0.008; 0.002 0.004 0.004 0.030 0.017 0.006 0.004; ...
      0.004 0.009 0.007 0.060 0.033 0.012 0.008; 0.007 0.013 0.011 0.092 0.051 0.018 0.012];
sor = 0;
for nw = 0:1
    for k = 1:numel(mun)
        sor = sor + 1; f = sprintf('%s_n%d', mun{k}, nw);
        for m = 1:5, C(end+1, :) = cel(f, t2{m}, v2(sor, m), 2); end %#ok<SAGROW>
        for m = 1:5, C(end+1, :) = cel(f, t3{m}, v3(sor, m), 2); end %#ok<SAGROW>
        for m = 1:6, C(end+1, :) = cel(f, t4{m}, v4(sor, m), 3); end %#ok<SAGROW>
        for m = 1:4, C(end+1, :) = cel(f, t6{m}, v6(sor, m), 3); end %#ok<SAGROW>
        for m = 1:7, C(end+1, :) = cel(f, t7{m}, v7(sor, m), 3); end %#ok<SAGROW>
    end
end
% a D-felar bontasa (Bmert, tartos) es az A-forma GDP-hozzajarulasa
C(end+1, :) = cel('Bmert_n0', 'ekD_t', -2.82, 2);  C(end+1, :) = cel('Bmert_n1', 'ekD_t', -4.45, 2);
C(end+1, :) = cel('Bmert_n0', 'defpAD_t', 2.00, 2); C(end+1, :) = cel('Bmert_n1', 'defpAD_t', 3.16, 2);
C(end+1, :) = cel('A_n0', 'dGDPtartos', 0.40, 2);   C(end+1, :) = cel('A_n1', 'dGDPtartos', 0.63, 2);
% a szovegbol: a regi exportegyenlettel az alapeset (v11, eredeti nettovagyon)
C(end+1, :) = cel('alap_regiexp_n0', 'GDPkonv', -0.28, 2); C(end+1, :) = cel('alap_regiexp_n0', 'GDPtartos', 0.16, 2);

T3 = cell2table(C, 'VariableNames', {'futas', 'mutato', 'reviewer', 'tizedes'});
T3.mienk = zeros(height(T3), 1);
for r = 1:height(T3)
    f = T3.futas{r}; m = T3.mutato{r};
    alap = regexprep(f, '^(B005|Bmert|Bfelso|A)_', 'alap_');
    T3.mienk(r) = ertek_(Mt.(f), Mt.(alap), m);
end
T3.elteres = T3.mienk - T3.reviewer;
T3.ok = double(abs(T3.elteres) <= 0.5*10.^(-T3.tizedes) + 1e-9);
writetable(T3, fullfile(tab, 't68c_v12_reviewer.csv'));
fprintf('K3: %d / %d egyezik a kozolt kerekitessel\n', sum(T3.ok), height(T3));

% --- BK-racs es fo mutatok futasonkent --------------------------------------------------
G = table();
for i = 1:numel(nevek)
    x = R.(nevek{i}); m = Mt.(nevek{i});
    erv = double(x.ok == 1 && x.B.check_ok == 1 && x.B.bk_ok == 1 && x.B0.check_ok == 1 && x.B0.bk_ok == 1);
    G = [G; table(string(nevek{i}), x.ok, erv, x.B0.n_unstable, x.B.n_unstable, x.B.n_forward, ...
        m.GDPkonv, m.GDPkozep, m.GDP1620, m.GDPtartos, m.efpEtartos, m.efpDtartos, m.efpLtartos, ...
        'VariableNames', {'futas', 'solver_ok', 'ervenyes', 'instabil_kezdeti', 'instabil_zaro', ...
        'eloretekinto', 'GDP_konv_pct', 'GDP_kozep_pct', 'GDP_1620_pct', 'GDP_tartos_pct', ...
        'felar_E_tartos_bp', 'felar_D_tartos_bp', 'felar_L_tartos_bp'})]; %#ok<AGROW>
end
writetable(G, fullfile(tab, 't68_v12_racs.csv'));

% --- osszegzes --------------------------------------------------------------------------
c = Mt.Bmert_n1; b = Mt.alap_n1;                  % a v12 alapertelmezese es hozzaferes nelkul
O = table();
O.nest_maxdiff = nest; O.k2_maxdiff = k2;
O.K3_egyezik = sum(T3.ok); O.K3_ossz = height(T3); O.K3_max_elteres = max(abs(T3.elteres));
O.BK_db = sum(G.ervenyes == 1); O.BK_ossz = height(G);
O.instabil_min = min([G.instabil_kezdeti; G.instabil_zaro]); O.instabil_max = max([G.instabil_kezdeti; G.instabil_zaro]);
O.eloretekinto_min = min(G.eloretekinto); O.eloretekinto_max = max(G.eloretekinto);
% a v12 alapertelmezese (SCENARIO 1, TSCEN 3): az euro hatasa
O.v12_GDP_1620_pct = c.GDP1620; O.v12_GDP_tartos_pct = c.GDPtartos;
O.v12_GDP_konv_pct = c.GDPkonv; O.v12_GDP_kozep_pct = c.GDPkozep;
g = cellfun(@(n) Mt.(n).GDP1620, racs);
O.v12_GDP_1620_min_pct = min(g); O.v12_GDP_1620_max_pct = max(g);
O.v12_felar_E_tartos_bp = c.efpEtartos; O.v12_felar_D_tartos_bp = c.efpDtartos; O.v12_felar_L_tartos_bp = c.efpLtartos;
% a hozzaferesi csatorna hozzajarulasa a v12-ben (Bmert_n1 - alap_n1)
for m = {'dGDPtartos', 'dGDP1620', 'dfelarD_t', 'dfelarE_t', 'accE_t', 'accD_t', 'dyE_t', 'dyD_t', 'dyL_t', ...
         'diE_t', 'diD_t', 'diL_t', 'dKKVL_t', 'dKKVL_1620'}
    O.(['v12_hozz_' m{1}]) = ertek_(c, b, m{1});
end
% mit valtoztat a harom uj alapertelmezes egyenkent (hozzaferes nelkul, tartos GDP)
O.exportJV_GDP_konv_pp = Mt.alap_n0.GDPkonv - Mt.alap_regiexp_n0.GDPkonv;
O.exportJV_GDP_tartos_pp = Mt.alap_n0.GDPtartos - Mt.alap_regiexp_n0.GDPtartos;
O.nwfix_GDP_tartos_pp = Mt.alap_n1.GDPtartos - Mt.alap_n0.GDPtartos;
O.nwfix_felar_D_tartos_bp = Mt.alap_n1.efpDtartos - Mt.alap_n0.efpDtartos;
O.Aforma_hozz_GDP_tartos_pp = ertek_(Mt.A_n1, b, 'dGDPtartos');
O.Aforma_hozz_GDP_1620_pp = ertek_(Mt.A_n1, b, 'dGDP1620');
O.v11_GDP_1620_pct = Mt.v11.GDP1620;
writetable(O, fullfile(tab, 't68b_v12_osszegzes.csv'));
disp(rows2vars(O));

% =====================================================================
function R = fut_(modell, args)
% Egy futas (a v11 aktiv alapagan + a megadott kapcsolok), BK mindket rezsimben.
R = struct('ok', 0, 'B', [], 'B0', [], 'S', [], 'nev', {{}}, 'p', [], 'ss', [], 'pa', []);
try
    dynare(modell, args{:}, 'console', 'nograph', 'nolog');
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
    fprintf(2, '  !! HIBA (%s %s): %s\n', modell, strjoin(args, ' '), ME.message);
end
end

function m = mutat_(R)
% A reviewer mutatoi (szintek; a d-mutatokat az ertek_ kepzi). %, bp/ev, szazalekpont.
konv = 2:13; kozep = 22:33; ab = 62:81;
a = @(x, t) 100*mean(R.pa(x, t)); f = @(x) 100*R.ss(x);
bp = @(x, t) 40000*mean(R.pa(x, t)); bpf = @(x) 40000*R.ss(x);
m.GDPkonv = a('y', konv); m.GDPkozep = a('y', kozep); m.GDP1620 = a('y', ab); m.GDPtartos = f('y');
for j = 'EDL'
    m.(['efp' j 'kozep']) = bp(['efp_' j], kozep); m.(['efp' j 'tartos']) = bpf(['efp_' j]);
    m.(['y' j '_t']) = f(['y_' j]); m.(['i' j '_t']) = f(['i_' j]); m.(['l' j '_t']) = f(['l_' j]);
    m.(['y' j '_1620']) = a(['y_' j], ab);
end
for j = 'ED'
    m.(['acc' j '_t']) = f(['acc_' j]); m.(['acc' j '_k']) = a(['acc_' j], kozep);
end
m.II_k = a('ii', kozep); m.II_t = f('ii'); m.LL_k = a('ll', kozep); m.LL_t = f('ll');
w = [R.p('om_E') R.p('om_D')]; w = w/sum(w);
m.KKVL_t = w(1)*m.yE_t + w(2)*m.yD_t - m.yL_t;
m.KKVL_1620 = w(1)*m.yE_1620 + w(2)*m.yD_1620 - m.yL_1620;
m.efpAD_t = 0; m.ekD_t = 0;
if any(strcmp(R.nev, 'efpA_D'))
    m.efpAD_t = bpf('efpA_D');
    m.ekD_t = -40000*R.p('mu_acc_D')*R.ss('acc_D');
end
end

function v = ertek_(m, b, mut)
% Egy mutato erteke; a d-mutatok a hozzaferes nelkuli futas (b) kulonbsegekent.
switch mut
    case {'GDPkonv', 'GDPkozep', 'GDPtartos', 'efpEkozep', 'efpEtartos', 'efpDkozep', 'efpDtartos', ...
          'accE_t', 'accD_t', 'accE_k', 'accD_k', 'ekD_t'}
        v = m.(mut);
    case {'dfelarE_t', 'dfelarD_t', 'dfelarL_t'}, j = mut(7); v = m.(['efp' j 'tartos']) - b.(['efp' j 'tartos']);
    case {'dfelarE_k', 'dfelarD_k', 'dfelarL_k'}, j = mut(7); v = m.(['efp' j 'kozep']) - b.(['efp' j 'kozep']);
    case {'dyE_t', 'dyD_t', 'dyL_t', 'diE_t', 'diD_t', 'diL_t', 'dlE_t', 'dlD_t', 'dlL_t'}
        v = m.(mut(2:end)) - b.(mut(2:end));
    case 'dKKVL_t', v = m.KKVL_t - b.KKVL_t;
    case 'dKKVL_1620', v = m.KKVL_1620 - b.KKVL_1620;
    case 'dGDPkonv', v = m.GDPkonv - b.GDPkonv;
    case 'dGDPkozep', v = m.GDPkozep - b.GDPkozep;
    case 'dGDPtartos', v = m.GDPtartos - b.GDPtartos;
    case 'dGDP1620', v = m.GDP1620 - b.GDP1620;
    case 'dIIkozep', v = m.II_k - b.II_k;
    case 'dIItartos', v = m.II_t - b.II_t;
    case 'dLLkozep', v = m.LL_k - b.LL_k;
    case 'dLLtartos', v = m.LL_t - b.LL_t;
    case 'defpAD_t', v = m.efpAD_t - b.efpDtartos;
    otherwise, error('ismeretlen mutato: %s', mut);
end
end

function d = elteres_(A, B, kihagy)
% Max |elteres| a kozos valtozokon (a kihagyottak es a segedvaltozok nelkul).
kozos = setdiff(intersect(A.nev, B.nev, 'stable'), kihagy, 'stable');
kozos = kozos(~startsWith(kozos, 'AUX_'));
[~, ia] = ismember(kozos, A.nev); [~, ib] = ismember(kozos, B.nev);
d = max(abs(A.S(ia, :) - B.S(ib, :)), [], 'all');
if numel(intersect(A.nev, B.nev)) < min(numel(A.nev), numel(B.nev)) - 4, d = NaN; end
end
