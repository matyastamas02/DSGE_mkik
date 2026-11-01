% check_konsz_v11.m — v11: kiadasoldali konszolidacio (-DKONSZ=1) ellenorzese
% =====================================================================
% Samu kerese (2026-10-29): a fiskalis blokkba keruljon bele a megszoritas,
% mert az euro elott a hianyt 3% ala kell vinni, es az arstabilitas miatt a
% kormanynak ovatosan kell koltenie. A -DKONSZ=1 (csak -DFISCAL=1 mellett) a
% kormanyzati fogyasztast tartosan a GDP -DKONSZD szazalekaval csokkenti, a
% bejelentestol -DKONSZN negyedev alatt felfuttatva, es nem koltik vissza.
% A -DSCENARIO=6 ugyanez euro nelkul.
%
% Adat (2026-10): a 2025-os hiany 4,7% GDP (KSH/Eurostat), a 2026-os a
% koltsegvetes feluvizsgalata utan kb. 7,2-7,5%. A 3% alatti hianyhoz ezert
% 1,7 (a 2025-os szintrol) es 4,5 (a 2026-osrol) szazalekpont kozotti
% kiigazitas kell; a kozepso eset 3,0. Mindharmat futtatjuk.
%
% ELORE ROGZITETT ELVARASOK (2026-10-29, futas elott):
%   K1  KONSZ=1, KONSZD=0 mellett minden kozos valtozo palyaja a KONSZ=0-val
%       (FISCAL=1) azonos, max |elteres| < 1e-10; SCENARIO=4 mellett KONSZ=1
%       mellett is minden valtozo vegig 0.
%   K2  sg*g = -kons minden idoszakban (max |elteres| < 1e-12). Euro nelkul
%       (SCENARIO=6) tartosan bg = -kons/(phi_b - (rgbar-1)) analitikusan
%       (KONSZD=3: -0.857, kb. -21,4% eves GDP), tls = phi_b*bg.
%   K3  Ricardoi semlegesseg: a PHIB es a RHOM csak a koltsegvetesi valtozokat
%       (rge bg tls pb intexp) mozgatja, a tobbit nem (max |elteres| < 1e-10).
%   K4  Linearitas: az euro-szcenarioban a konszolidacio hatasa (EK - E) a
%       KONSZD-vel aranyos (max |elteres| < 1e-8).
%   K5  BK: 13 instabil gyok / 13 eloretekinto valtozo mindket rezsimben,
%       minden futasban.
%   K6  Csak elojel: euro nelkul a konszolidacio az elso 2 evben csokkenti a
%       GDP-t es az inflaciot; tartosan a GDP kevesebbel csokken, mint a
%       kiadascsokkentes (kiszoritas visszafele), a magan fogyasztas no.
%       Az euro + konszolidacio GDP-hatasanak elojelet NEM jelezzuk elore --
%       ez a kerdes.
% EREDMENY (2026-10-31, utolag): a K6 reszben NEM teljesult -- az 1. evben a
% GDP no (+0,10%), a 2. evben az inflacio nem csokken (+0,0003 pp). A futtato a
% K6-ot eredetileg nem ertekelte ki; 2026-11-01 ota evenkent kiertekeli
% (K6_* oszlopok, fusttesztor). A tartos resz teljesult.
% UTOLAGOS FELBONTAS (2026-10-31): a tartos GDP-csokkenes forrasa (C+G vagy
% nettó export) es a hatarkoltseg az 1-3. evben. Az F15/F16 korabbi
% magyarazata ("a g a GDP resze", "a haztartasok potoljak a keresletet") a
% felbontas szerint hibas, illetve hianyos volt; ezek a szamok utolagosak,
% nem elore rogzitett varakozasok.
% Szamitasi horizont 400 negyedev; kozolni legfeljebb 20 evet (a fo mutato a
% 16-20. ev atlaga = 61-80. negyedev).
%
% A hiany itt a nominalis (maastrichti) hiany valtozasa a GDP %-aban:
%   hiany = -pb + intexp + bbar_g*infl
% (az intexp a reál kamatkiadas; a nominalishoz az inflacio ertekvesztese
% visszaadando). A modellben nincs novekedes, ezert a tartosan alacsonyabb
% adossag alacsonyabb hianyt itt nem ad; a valosagban a nominalis
% GDP-novekedes miatt igen. Az 1-5. evre a ketto kozel azonos.
%
% Kimenet: output/tables/t67_konsz_racs.csv        (futasonkent: BK + fo mutatok)
%          output/tables/t67b_konsz_osszegzes.csv  (K1-K6, kozolt szamok)
%          output/tables/t67c_konsz_palyak.csv     (negyedeves palyak, 0-80)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); check_konsz_v11"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

F1 = {'-DFISCAL=1'};
KZ = [F1, {'-DKONSZ=1'}];
DD = [1.7 3.0 4.5];
ab = 62:81;                                      % 61-80. negyedev (16-20. ev)
fisk = {'rge', 'bg', 'tls', 'pb', 'intexp'};

% --- futasok ---------------------------------------------------------------------------
RE = fut_(F1);                                   % euro, nincs konszolidacio
R0 = fut_([KZ, {'-DKONSZD=0'}]);                 % K1
RZ = fut_([KZ, {'-DSCENARIO=4'}]);               % K1
for i = 1:numel(DD)
    d = sprintf('-DKONSZD=%g', DD(i));
    EK(i) = fut_([KZ, {d}]);                     %#ok<SAGROW> euro + konszolidacio
    KK(i) = fut_([KZ, {d, '-DSCENARIO=6'}]);     %#ok<SAGROW> csak konszolidacio
end
i3 = find(DD == 3);
RM = fut_([KZ, {'-DRHOM=0.95'}]);                % K3, 5 eves atlagos lejarat
RP = fut_([KZ, {'-DPHIB=0.02'}]);                % K3, lassu visszaadas
RMP = fut_([KZ, {'-DRHOM=0.95', '-DPHIB=0.02'}]);
EM = fut_([F1, {'-DRHOM=0.95'}]);                % euro, 5 eves lejarat, konszolidacio nelkul

% --- K1-K4 --------------------------------------------------------------------------------
nest = elteres_(RE, R0, {});
sc4 = max(abs(RZ.S), [], 'all');
p = EK(i3).p; sg = p('sg');
kpalya = max(arrayfun(@(R) max(abs(sg*R.pa('g', ':') + R.kons)), [EK KK]));
bgK_an = -(DD(i3)/100)/(p('phi_b') - (p('rgbar') - 1));
bgK_hiba = abs(KK(i3).ss('bg') - bgK_an);
ric = max([elteres_(EK(i3), RM, fisk), elteres_(EK(i3), RP, fisk), elteres_(EK(i3), RMP, fisk)]);
lin = 0;
for i = 1:numel(DD)
    lin = max(lin, max(abs(kul_(EK(i), RE) - DD(i)/3*kul_(EK(i3), RE)), [], 'all'));
end
fprintf('\nK1 %.3g / %.3g  K2 %.3g / %.3g  K3 %.3g  K4 %.3g\n', nest, sc4, kpalya, bgK_hiba, ric, lin);

% --- BK-racs es fo mutatok futasonkent --------------------------------------------------
G = [sor_("euro", 1, 0, 0, 0.05, RE); sor_("euro_KONSZD0", 1, 1, 0, 0.05, R0); ...
     sor_("nulla_sokk", 4, 1, 3, 0.05, RZ)];
for i = 1:numel(DD)
    G = [G; sor_("euro_konsz", 1, 1, DD(i), 0.05, EK(i)); ...
            sor_("csak_konsz", 6, 1, DD(i), 0.05, KK(i))]; %#ok<AGROW>
end
G = [G; sor_("euro_konsz_RHOM095", 1, 1, 3, 0.05, RM); sor_("euro_konsz_PHIB002", 1, 1, 3, 0.02, RP); ...
        sor_("euro_konsz_RHOM095_PHIB002", 1, 1, 3, 0.02, RMP); sor_("euro_RHOM095", 1, 0, 0, 0.05, EM)];
writetable(G, fullfile(tab, 't67_konsz_racs.csv'));

% --- palyak (negyedeves, 0-80), KONSZD = 3 ----------------------------------------------
P = table((0:80)', 'VariableNames', {'negyedev'});
for nv = {'y', 'c', 'c_o', 'c_no', 'g', 'ii', 'll', 'w', 'infl', 'r', 'rer', 'bg', 'tls'}
    P.([nv{1} '_euro'])  = RE.pa(nv{1}, 1:81)';
    P.([nv{1} '_konsz']) = KK(i3).pa(nv{1}, 1:81)';
    P.([nv{1} '_euro_konsz']) = EK(i3).pa(nv{1}, 1:81)';
end
P.hiany_euro = hiany_(RE, 1:81)'; P.hiany_konsz = hiany_(KK(i3), 1:81)';
P.hiany_euro_konsz = hiany_(EK(i3), 1:81)';
P.hiany_euro_konsz_RHOM095_PHIB002 = hiany_(RMP, 1:81)';
writetable(P, fullfile(tab, 't67c_konsz_palyak.csv'));

% --- osszegzes --------------------------------------------------------------------------
m  = @(R, nv) 100*mean(R.pa(nv, ab));
fx = @(R, nv) 100*R.ss(nv);
ev = @(R, nv, k) 100*mean(R.pa(nv, 4*k-2:4*k+1));              % k. ev atlaga
inf3 = @(R) 400*mean(R.pa('infl', 2:13));                       % 1-3. ev, evesitett pp
hev = @(R, k) 100*mean(hiany_(R, 4*k-2:4*k+1));                 % k. ev hianyvaltozasa, pp
O = table();
O.nest_maxdiff = nest; O.sc4_maxabs = sc4; O.kons_palya_maxdiff = kpalya;
O.bg_konsz_fix = KK(i3).ss('bg'); O.bg_konsz_analitikus = bgK_an; O.bg_konsz_hiba = bgK_hiba;
O.ricardo_maxdiff = ric; O.linearitas_maxdiff = lin;
O.sg = sg; O.g_csokkenes_fix_pct = -fx(KK(i3), 'g');
% fo mutatok: E (euro), K (csak konszolidacio), EK (euro + konszolidacio), KONSZD = 1.7 / 3 / 4.5
O.E_GDP_1620_pct = m(RE, 'y'); O.E_GDP_fix_pct = fx(RE, 'y');
O.E_C_1620_pct = m(RE, 'c'); O.E_C_fix_pct = fx(RE, 'c');
for i = 1:numel(DD)
    t = strrep(sprintf('%.1f', DD(i)), '.', '');
    O.(['EK' t '_GDP_1620_pct']) = m(EK(i), 'y'); O.(['EK' t '_GDP_fix_pct']) = fx(EK(i), 'y');
    O.(['K' t '_GDP_1620_pct'])  = m(KK(i), 'y'); O.(['K' t '_GDP_fix_pct'])  = fx(KK(i), 'y');
    O.(['EK' t '_C_1620_pct'])   = m(EK(i), 'c'); O.(['EK' t '_C_fix_pct'])   = fx(EK(i), 'c');
    O.(['K' t '_C_1620_pct'])    = m(KK(i), 'c'); O.(['K' t '_C_fix_pct'])    = fx(KK(i), 'c');
    % az euro hatasa konszolidacio mellett (mindket agon ugyanaz a megszoritas)
    O.(['euro_hatas_K' t '_GDP_1620_pp']) = m(EK(i), 'y') - m(KK(i), 'y');
    O.(['euro_hatas_K' t '_GDP_fix_pp'])  = fx(EK(i), 'y') - fx(KK(i), 'y');
end
% KONSZD = 3: rovid tav, arstabilitas, hiany, adossag
R3 = EK(i3); K3 = KK(i3);
for k = 1:3
    O.(sprintf('E_GDP_%dev_pct', k)) = ev(RE, 'y', k);
    O.(sprintf('K3_GDP_%dev_pct', k)) = ev(K3, 'y', k);
    O.(sprintf('EK3_GDP_%dev_pct', k)) = ev(R3, 'y', k);
end
O.E_GDP_5ev_pct = ev(RE, 'y', 5); O.EK3_GDP_5ev_pct = ev(R3, 'y', 5); O.K3_GDP_5ev_pct = ev(K3, 'y', 5);
O.E_infl_1_3ev_pp = inf3(RE); O.K3_infl_1_3ev_pp = inf3(K3); O.EK3_infl_1_3ev_pp = inf3(R3);
O.K3_Co_fix_pct = fx(K3, 'c_o'); O.K3_Cno_fix_pct = fx(K3, 'c_no'); O.K3_L_fix_pct = fx(K3, 'll');
O.K3_W_fix_pct = fx(K3, 'w'); O.K3_I_fix_pct = fx(K3, 'ii');
% utolagos felbontas (2026-10-31): y = sc*c + si*ii + sg*g + sx*xx - sm*im, tartosan, pp
O.K3_hozz_C_fix_pp = p('sc')*fx(K3, 'c'); O.K3_hozz_G_fix_pp = p('sg')*fx(K3, 'g');
O.K3_hozz_I_fix_pp = p('si')*fx(K3, 'ii'); O.K3_hozz_X_fix_pp = p('sx')*fx(K3, 'xx');
O.K3_hozz_M_fix_pp = -p('sm')*fx(K3, 'im');
O.K3_hozz_hiba = abs(O.K3_hozz_C_fix_pp + O.K3_hozz_G_fix_pp + O.K3_hozz_I_fix_pp + ...
    O.K3_hozz_X_fix_pp + O.K3_hozz_M_fix_pp - fx(K3, 'y'));
O.K3_rer_fix_pct = fx(K3, 'rer'); O.K3_X_fix_pct = fx(K3, 'xx'); O.K3_M_fix_pct = fx(K3, 'im');
% inflacio: a hazai kereslet az 1. evben, a hatarkoltseg az 1-3. evben (wz_j = aa_j*w + (1-aa_j)*rer)
O.K3_yd_1ev_pct = ev(K3, 'y_d', 1);
for j = {'E', 'D', 'L'}
    O.(['K3_mc_' j{1} '_1_3ev_pct']) = 100*mean(K3.pa(['mc_' j{1}], 2:13));
    O.(['aa_' j{1}]) = p(['aa_' j{1}]);
end
% K6 kiertekelese (2026-11-01, utolag: a futtato eredetileg nem ertekelte ki). Evenkent nezzuk.
O.K3_infl_1ev_pp = 400*mean(K3.pa('infl', 2:5)); O.K3_infl_2ev_pp = 400*mean(K3.pa('infl', 6:9));
O.K6_GDP_1ev_csokken = double(O.K3_GDP_1ev_pct < 0); O.K6_GDP_2ev_csokken = double(O.K3_GDP_2ev_pct < 0);
O.K6_infl_1ev_csokken = double(O.K3_infl_1ev_pp < 0); O.K6_infl_2ev_csokken = double(O.K3_infl_2ev_pp < 0);
O.K6_tartos_GDP_kisebb_mint_kiadas = double(abs(fx(K3, 'y')) < DD(i3));
O.K6_C_no = double(fx(K3, 'c') > 0);
O.K6_teljesult = double(O.K6_GDP_1ev_csokken && O.K6_GDP_2ev_csokken && O.K6_infl_1ev_csokken && ...
    O.K6_infl_2ev_csokken && O.K6_tartos_GDP_kisebb_mint_kiadas && O.K6_C_no);
for k = [1 2 3 5 10 20]
    O.(sprintf('E_hiany_%dev_pp', k)) = hev(RE, k);
    O.(sprintf('EM_hiany_%dev_pp', k)) = hev(EM, k);
    O.(sprintf('EK3_hiany_%dev_pp', k)) = hev(R3, k);
    O.(sprintf('EK3_RHOM_hiany_%dev_pp', k)) = hev(RM, k);
    O.(sprintf('EK3_RHOM_PHIB_hiany_%dev_pp', k)) = hev(RMP, k);
end
O.EK3_adossag_3ev_GDP_pct = 100*R3.pa('bg', 13)/4; O.EK3_adossag_20ev_GDP_pct = 100*R3.pa('bg', 81)/4;
O.EK3_adossag_fix_GDP_pct = 100*R3.ss('bg')/4; O.K3_adossag_fix_GDP_pct = 100*K3.ss('bg')/4;
% K5
O.BK_db = sum(G.ervenyes == 1); O.BK_ossz = height(G);
O.instabil_min = min([G.instabil_kezdeti; G.instabil_zaro]);
O.instabil_max = max([G.instabil_kezdeti; G.instabil_zaro]);
O.eloretekinto_min = min(G.eloretekinto); O.eloretekinto_max = max(G.eloretekinto);
writetable(O, fullfile(tab, 't67b_konsz_osszegzes.csv'));
disp(rows2vars(O));

% =====================================================================
function R = fut_(args)
% Egy futas az aktiv v11-alapagon (+ a megadott kapcsolok), BK mindket rezsimben.
R = struct('ok', 0, 'B', [], 'B0', [], 'S', [], 'nev', {{}}, 'kons', 0, 'p', [], 'ss', [], 'pa', []);
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
    en = cellstr(M.exo_names);
    if any(strcmp(en, 'kons')), R.kons = oo.exo_simul(:, strcmp(en, 'kons'))'; end
    R.p  = @(x) pv(strcmp(pn, x));
    R.ss = @(x) ssv(strcmp(n, x));
    R.pa = @(x, t) S(strcmp(n, x), t);
catch ME
    fprintf(2, '  !! HIBA (%s): %s\n', strjoin(args, ' '), ME.message);
end
end

function h = hiany_(R, t)
% A nominalis hiany valtozasa a GDP aranyaban (negyedeves aram / negyedeves GDP).
h = -R.pa('pb', t) + R.pa('intexp', t) + R.p('bbar_g')*R.pa('infl', t);
end

function D = kul_(A, B)
% A - B palyai B valtozoin (B a KONSZ=0 alap, A-ban van egy segedvaltozoval tobb).
[~, ia] = ismember(B.nev, A.nev);
D = A.S(ia, :) - B.S;
end

function d = elteres_(A, B, kihagy)
% Max |elteres| a kozos valtozokon (a kihagyottak es a segedvaltozok nelkul).
kozos = setdiff(intersect(A.nev, B.nev, 'stable'), kihagy, 'stable');
kozos = kozos(~startsWith(kozos, 'AUX_'));
[~, ia] = ismember(kozos, A.nev); [~, ib] = ismember(kozos, B.nev);
d = max(abs(A.S(ia, :) - B.S(ib, :)), [], 'all');
if numel(intersect(A.nev, B.nev)) < min(numel(A.nev), numel(B.nev)) - 1, d = NaN; end
end

function T = sor_(beall, sc, kz, kd, phib, R)
B = R.B; B0 = R.B0;
erv = double(R.ok == 1 && B.check_ok == 1 && B.bk_ok == 1 && B0.check_ok == 1 && B0.bk_ok == 1);
ab = 62:81;
T = table(string(beall), sc, kz, kd, phib, R.ok, erv, B0.n_unstable, B.n_unstable, B.n_forward, ...
    100*mean(R.pa('y', ab)), 100*R.ss('y'), 100*mean(R.pa('c', ab)), 100*R.ss('c'), 100*R.ss('bg')/4, ...
    'VariableNames', {'beallitas', 'SCENARIO', 'KONSZ', 'KONSZD', 'PHIB', 'solver_ok', 'ervenyes', ...
    'instabil_kezdeti', 'instabil_zaro', 'eloretekinto', 'GDP_1620_pct', 'GDP_fix_pct', ...
    'C_1620_pct', 'C_fix_pct', 'adossag_fix_eves_GDP_pct'});
end
