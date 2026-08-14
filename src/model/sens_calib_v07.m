% sens_calib_v07.m — EAGLE-KALIBRALT vs JAKAB-VILAGI BECSULT parameterkeszlet
% =====================================================================
% A csapat 2026-07-13-an azzal az ervvel dontott a Jakab-Vilagi alapmodell
% mellett, hogy annak parameterei MAGYAR ADATON BAYES-I MODSZERREL
% BECSULTEK, nem kalibraltak. A legbovebb modell (kkv_dsge_v07_access)
% viszont az EAGLE-vonalon epult, es a makro-magban EAGLE-KALIBRALT
% ertekeket visz. Vagyis a fo vonal INDOKLASA es a hasznalt modell
% KALIBRACIOJA nem all ossze -- ez biralóval szemben nem vedheto.
%
% Ez a script MERHETOVE teszi a kerdest: ugyanaz a modell, ket
% parameterkeszlet (-DCALIB=1|2), minden mas valtozatlan.
%
% MIT CSERELUNK ES MIT NEM (reszletes indoklas a .mod CALIB-blokkjaban):
%   CSEREL (11 parameter, ugyanaz az objektum):
%     sigma, habit, kappa, rho_r, phi_pi, phi_y, chiw, eta_w, theta_w,
%     om_nr, rho_a, rho_g
%   NEM CSEREL (mas fogalom, egyenletenkent ellenorizve):
%     alpha  -- itt ketinputos tokehanyad, a JV zeta harominputos
%     phi_i  -- itt q=phi_i*(i-k), a JV-ben invertalt spec (i <- q)
%     eta_x  -- itt kulon rer- es sajat-ar rugalmassag, a JV mu_x egyben
%
% ELOREJELZES (amit varunk, es amit a futas eldont): az om_nr 0.75 -> 0.25
% valtas onmagaban CSOKKENTI a hatast, mert a korabbi EAGLE-tanulsag
% szerint a nem-Ricardianus blokk masfelszeresere emelte a tartos hatast
% (v0.3 +0.49% -> v0.4 +0.73%). Ha a JV-keszlettel kisebb GDP-hatas jon ki,
% az NEM hiba, hanem a becsult parameterek kovetkezmenye.
%
% Kimenet: output/tables/t38_calib_eagle_vs_jv.csv
% Futtatas: matlab -batch "cd('<repo>/src/model'); sens_calib_v07"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

nevek_ = {'1_EAGLE_kalibralt', '2_JV_becsult'};
leiras_ = {'EAGLE-HU kalibralt (WP 2017/7)', ...
           'Jakab-Vilagi BECSULT (MNB WP 2008/9)'};
valt = {'y','y_E','y_D','y_L','i_E','i_D','i_L', ...
        'efp_E','efp_D','efp_L','acc_E','acc_D','c','bstar'};
T = table();

for ic_ = 1:2
    dynare('kkv_dsge_v07_access', '-DSCENARIO=1', '-DTSCEN=3', ...
        sprintf('-DCALIB=%d', ic_), 'console');
    ok_ = oo_.deterministic_simulation.status;
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    % sulyozott KKV-blokk (a szegmens-kibocsatasi sulyokkal)
    sy_E = M_.params(strcmp(cellstr(M_.param_names), 'sy_E'));
    sy_D = M_.params(strcmp(cellstr(M_.param_names), 'sy_D'));
    w_E = sy_E/(sy_E+sy_D); w_D = sy_D/(sy_E+sy_D);
    y_kkv = w_E*g('y_E') + w_D*g('y_D');
    uj = table(string(nevek_{ic_}), string(leiras_{ic_}), ok_, ...
        g('y'), g('y_E'), g('y_D'), g('y_L'), y_kkv, y_kkv - g('y_L'), ...
        g('i_E'), g('i_D'), g('i_L'), g('c'), ...
        'VariableNames', {'eset', 'leiras', 'konvergalt', ...
        'GDP_pct', 'y_E_pct', 'y_D_pct', 'y_L_pct', ...
        'y_KKV_sulyozott_pct', 'KKV_minus_L_pp', ...
        'i_E_pct', 'i_D_pct', 'i_L_pct', 'c_pct'});
    T = [T; uj]; %#ok<AGROW>
end

repo = fileparts(fileparts(pwd));
writetable(T, fullfile(repo, 'output', 'tables', 't38_calib_eagle_vs_jv.csv'));

fprintf('\n%s\n', repmat('=', 1, 88));
fprintf('EAGLE-KALIBRALT vs JV-BECSULT PARAMETERKESZLET (v07_access, TSCEN=3, ACCSCALE=100)\n');
fprintf('%s\n', repmat('=', 1, 88));
fprintf('%-38s %9s %8s %8s %8s %11s\n', 'parameterkeszlet', 'GDP', 'y_E', ...
    'y_D', 'y_L', 'KKV-L');
fprintf('%s\n', repmat('-', 1, 88));
for i = 1:height(T)
    if T.konvergalt(i) ~= 1
        fprintf('%-38s  *** NEM KONVERGALT / BK SERUL ***\n', T.leiras(i));
        continue
    end
    fprintf('%-38s %+8.3f%% %+7.3f%% %+7.3f%% %+7.3f%% %+8.3f pp\n', ...
        T.leiras(i), T.GDP_pct(i), T.y_E_pct(i), T.y_D_pct(i), ...
        T.y_L_pct(i), T.KKV_minus_L_pp(i));
end
fprintf('%s\n', repmat('=', 1, 88));
if all(T.konvergalt == 1)
    d = T.GDP_pct(2) - T.GDP_pct(1);
    fprintf(['ELTERES: a JV-becsult keszlettel a tartos GDP-hatas %+.3f pp-tal ' ...
        '%s.\n'], d, ternar_(d < 0, 'KISEBB', 'NAGYOBB'));
    fprintf(['A szektoralis sorrend %s.\n'], ...
        ternar_(sign(T.KKV_minus_L_pp(1)) == sign(T.KKV_minus_L_pp(2)), ...
        'NEM valtozik', '!!! MEGFORDUL !!!'));
end
fprintf(['\nERTELMEZES: ez NEM azt mutatja, melyik keszlet "helyes".\n' ...
    'Azt mutatja, mennyire fugg a fo eredmeny attol a kalibracios\n' ...
    'valasztastol, amit a csapat indoklasa szerint mar meghoztunk\n' ...
    '(magyar adaton becsult parameterek). Ha az elteres nagy, a\n' ...
    'kalibracios keszlet megvalasztasa NEM technikai reszlet.\n']);

function s = ternar_(felt, a, b)
    if felt, s = a; else, s = b; end
end
