% s29_workshop_euro_palya.m — EGY EURO-FORGATOKONYV LEPESENKENT (workshop)
% =====================================================================
% A 2026-10-05-i workshop "egyetlen futas vegigvezetese" blokkjahoz.
% A fo modell (jv_dsge_v09_access) BK-ervenyes OPTEN=0 aganak alap
% euro-szcenarioja (SCENARIO=1, TSCEN=3), a transzmisszios lanc menten:
%
%   (1) bemenet: szuveren es banki felar-palya (exogen)
%   (2) kamat (r) es realarfolyam (rer)
%   (3) vallalati kulso finanszirozasi felar tipusonkent (efp_E/D/L)
%   (4) hitelhozzaferes (acc_E, acc_D) -- a nagyvallalatnak nincs ilyen
%   (5) aggregalt GDP (y)
%   (6) KKV - nagyvallalat kibocsatas-kulonbseg KET ACCSCALE-erteken:
%       a KKV-L kuszob ALATT es FELETT. Ez szandekosan NEM egyetlen
%       szegmens-palya: a szegmens-kibocsatas pontbecslesként nem
%       kozolheto (CLAUDE.md), a kuszobforma igen.
%
% A kuszobot a t48b tablabol olvassuk (OPTEN=0 ag, kuszob_KKV_L), nem
% irjuk be kezzel. Az "alatta" pont a kuszob fele, a "felette" pont a
% .mod alapertelmezese (ACCSCALE=100), amely a t47 szerint BK-ervenyes.
%
% MINDEN futasra terminalis BK-ellenorzes (bk_check_metrics). Ha barmelyik
% nem BK-ervenyes, a script ABRA NELKUL leall -- BK-invalid palyat nem
% rajzolunk ki (lasd a 2026-08-24-i BK-korrekciot).
%
% Kimenet: output/figures/f29_euro_palya_v09.png   (1-5. panel)
%          output/figures/f30_kkv_kuszob_palya.png  (6. panel, kulon)
%          output/tables/t57_workshop_palya.csv    (a kirajzolt szamok
%              osszegzese; mielott barmelyik diara kerul, allitas-sor
%              es or kell a regiszterbe -- CLAUDE.md, prezentacios szabaly)
% Futtatas: matlab -batch "cd('<repo>/src/3_abrak'); s29_workshop_euro_palya"
% Kell hozza: Dynare (DYNARE_PATH vagy C:\dynare\6.5\matlab).

repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
abrak = fullfile(repo, 'output', 'figures');
tablak = fullfile(repo, 'output', 'tables');

H = 60;   % kirajzolt horizont, negyedev (a szimulacio 120)

% --- a kuszob a tarolt tablabol -------------------------------------
K = readtable(fullfile(tablak, 't48b_opten_kuszob_osszegzes.csv'));
kuszob = K.kuszob_KKV_L(K.OPTEN == 0);
acc_alatt = round(kuszob / 2, 1);
acc_felett = 100;
fprintf('KKV-L kuszob (OPTEN=0, t48b): ACCSCALE* = %.2f\n', kuszob);
fprintf('Futasok: ACCSCALE = %.1f (alatta) es %.0f (felette)\n', acc_alatt, acc_felett);

ide_ = pwd;
cd(fullfile(repo, 'src', 'modell', '1_fo_vonal_jv'));
R_felett = fut_(acc_felett, H);
R_alatt  = fut_(acc_alatt, H);
cd(ide_);

if ~(R_felett.ervenyes && R_alatt.ervenyes)
    error(['s29: legalabb egy futas NEM BK-ervenyes (felett=%d, alatt=%d) ' ...
        '-- abra nem keszul.'], R_felett.ervenyes, R_alatt.ervenyes);
end

% --- 1. abra: a transzmisszios lanc (alap: ACCSCALE=100) ---------------
R = R_felett;  t = 0:H-1;
szE = [0.85 0.33 0.10]; szD = [0.95 0.62 0.00]; szL = [0.00 0.45 0.70];
f = figure('Visible', 'off', 'Position', [100 100 1400 820]);
tl = tiledlayout(f, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, sprintf(['Alap euro-szcenario, v09 fo modell (OPTEN=0, SCENARIO=1, ' ...
    'ACCSCALE=%d) — BK-ervenyes'], acc_felett), 'FontWeight', 'bold');

nexttile; hold on
plot(t, 1e4*R.x('sov'), 'LineWidth', 2);
plot(t, 1e4*R.x('bank'), 'LineWidth', 2);
xline(12, ':', 'csatlakozas');
title('1. Bemenet: felar-konvergencia'); ylabel('bazispont');
legend({'szuveren felar', 'banki felar'}, 'Location', 'southwest'); grid on

nexttile; hold on
plot(t, 100*R.v('r'), 'LineWidth', 2);
plot(t, 100*R.v('rer'), 'LineWidth', 2);
xline(12, ':');
title('2. Kamat es realarfolyam'); ylabel('elteres, szazalekpont / %');
legend({'kamat (r)', 'realarfolyam (rer)'}, 'Location', 'best'); grid on

nexttile; hold on
plot(t, 100*R.v('efp_E'), 'Color', szE, 'LineWidth', 2);
plot(t, 100*R.v('efp_D'), 'Color', szD, 'LineWidth', 2);
plot(t, 100*R.v('efp_L'), 'Color', szL, 'LineWidth', 2);
xline(12, ':');
title('3. Vallalati finanszirozasi felar'); ylabel('elteres, szazalekpont');
legend({'E: export-KKV', 'D: hazai KKV', 'L: nagyvallalat'}, 'Location', 'best'); grid on

nexttile; hold on
plot(t, 100*R.v('acc_E'), 'Color', szE, 'LineWidth', 2);
plot(t, 100*R.v('acc_D'), 'Color', szD, 'LineWidth', 2);
xline(12, ':');
title('4. Hitelhozzaferes (csak KKV)'); ylabel('elteres, %');
legend({'E: export-KKV', 'D: hazai KKV'}, 'Location', 'best'); grid on

nexttile; hold on
plot(t, 100*R.v('y'), 'k', 'LineWidth', 2.5);
xline(12, ':'); yline(0, '-', 'Color', [0.6 0.6 0.6]);
title('5. Aggregalt GDP'); ylabel('elteres, %'); xlabel('negyedev'); grid on

nexttile; axis off
text(0, 0.9, 'Hogyan olvasd:', 'FontWeight', 'bold', 'FontSize', 11);
text(0, 0.72, {'A 13. negyedevtol kozos monetaris politika;', ...
    'a felar 16 negyedev alatt konvergal.', '', ...
    'A szegmens-szintu kibocsatast itt szandekosan', ...
    'NEM mutatjuk: az a hozzaferesi csatorna', ...
    'erossegen fordul (kulon abra: f30).'}, ...
    'FontSize', 10, 'VerticalAlignment', 'top');
exportgraphics(f, fullfile(abrak, 'f29_euro_palya_v09.png'), 'Resolution', 150);
close(f);

% --- 2. abra: KKV - L kulonbseg a kuszob alatt es felett ---------------
f = figure('Visible', 'off', 'Position', [100 100 900 520]); hold on
plot(t, R_alatt.kkv_l(1:H), 'LineWidth', 2.5, 'Color', szL);
plot(t, R_felett.kkv_l(1:H), 'LineWidth', 2.5, 'Color', szE);
yline(0, 'k-'); xline(12, ':', 'csatlakozas');
title({'KKV - nagyvallalat kibocsatas-kulonbseg: a hozzaferesi csatorna erossegen mulik', ...
    sprintf('KKV-L kuszob: ACCSCALE* = %.1f (t48b, OPTEN=0)', kuszob)});
ylabel('y_{KKV} - y_L, szazalekpont'); xlabel('negyedev');
legend({sprintf('ACCSCALE = %.1f (kuszob alatt)', acc_alatt), ...
    sprintf('ACCSCALE = %d (kuszob felett)', acc_felett)}, 'Location', 'best');
grid on
exportgraphics(f, fullfile(abrak, 'f30_kkv_kuszob_palya.png'), 'Resolution', 150);
close(f);

% --- osszegzo tabla ----------------------------------------------------
T = table([acc_alatt; acc_felett], [R_alatt.ervenyes; R_felett.ervenyes], ...
    [R_alatt.n_unstable; R_felett.n_unstable], [R_alatt.n_forward; R_felett.n_forward], ...
    100*[R_alatt.y_vegso; R_felett.y_vegso], ...
    [R_alatt.kkv_l(end); R_felett.kkv_l(end)], ...
    'VariableNames', {'accscale', 'bk_ervenyes', 'n_unstable', 'n_forward', ...
    'GDP_tartos_pct', 'KKV_minus_L_tartos_pp'});
writetable(T, fullfile(tablak, 't57_workshop_palya.csv'));
disp(T);
fprintf('Kesz: f29, f30, t57. A szamok diara csak regiszter-sor + or utan mehetnek.\n');

% =====================================================================
function R = fut_(accscale, H)
dynare('jv_dsge_v09_access', '-DSCENARIO=1', '-DTSCEN=3', '-DOPTEN=0', ...
    sprintf('-DACCSCALE=%.10g', accscale), 'console', 'nograph');
M_  = evalin('base', 'M_');
oo_ = evalin('base', 'oo_');
options_ = evalin('base', 'options_');
B = bk_check_metrics(M_, options_, oo_);
R.ervenyes = double(oo_.deterministic_simulation.status == 1 && ...
    B.check_ok == 1 && B.bk_ok == 1);
R.n_unstable = B.n_unstable;  R.n_forward = B.n_forward;
n  = cellstr(M_.endo_names);
xn = cellstr(M_.exo_names);
t1 = M_.maximum_lag + 1;     % az 1. szimulacios periodus sora
% R.v / R.x: az elso H periodus (rajzolashoz); vteljes: a terminalis
% oszloppal egyutt (a tartos ertekhez).
R.v = @(v) oo_.endo_simul(strcmp(n, v), t1:t1+H-1)';
R.x = @(v) oo_.exo_simul(t1:t1+H-1, strcmp(xn, v));
vteljes = @(v) oo_.endo_simul(strcmp(n, v), t1:end)';
pn = cellstr(M_.param_names);
p  = @(v) M_.params(strcmp(pn, v));
wE = p('om_E') / (p('om_E') + p('om_D'));
wD = p('om_D') / (p('om_E') + p('om_D'));
R.kkv_l = 100 * (wE*vteljes('y_E') + wD*vteljes('y_D') - vteljes('y_L'));
R.y_vegso = oo_.steady_state(strcmp(n, 'y'));   % terminalis = tartos hatas (mint t47)
end
