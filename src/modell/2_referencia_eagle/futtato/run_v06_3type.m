% run_v06_3type.m — explicit haromtipusos KKV/nagyvallalat vaz futtatasa
%
% Kimenet:
%   output/tables/t27_v06_3type_szcenariok.csv
%   output/tables/t27_v06_3type_hosszutav.csv
%   output/figures/f23_v06_3type_szcenariok.png
%
% Futtatas:
%   matlab -batch "cd('<repo>/src/modell/2_referencia_eagle/futtato'); run_v06_3type"

% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 80;
szcenariok = {'alap', 'optimista', 'pesszimista'};
valt = {'y','yd','y_E','y_D','y_L','x_E','x_D','x_L', ...
    'i_E','i_D','i_L','efp_E','efp_D','efp_L', ...
    'xx','c','infl','r','rer','bstar'};
osszes = table(); ht = table();

for s = 1:3
    dynare('kkv_dsge_v06_3type', sprintf('-DSCENARIO=%d', s), ...
        '-DTSCEN=3', 'console');
    nevek = cellstr(M_.endo_names);
    blokk = table((1:T_ki)', 'VariableNames', {'negyedev'});
    blokk.szcenario = repmat(szcenariok(s), T_ki, 1);
    hts = table(szcenariok(s), 'VariableNames', {'szcenario'});
    for v = 1:numel(valt)
        sor = strcmp(nevek, valt{v});
        blokk.(valt{v}) = oo_.endo_simul(sor, 2:(T_ki+1))';
        hts.(valt{v}) = oo_.steady_state(sor);
    end
    osszes = [osszes; blokk]; %#ok<AGROW>
    ht = [ht; hts]; %#ok<AGROW>
    fprintf(['%s: y=%+.3f%% | E=%+.3f%% D=%+.3f%% L=%+.3f%% | ' ...
        'i_E=%+.3f%% i_D=%+.3f%% i_L=%+.3f%% (h.tav)\n'], ...
        szcenariok{s}, 100*hts.y, 100*hts.y_E, 100*hts.y_D, ...
        100*hts.y_L, 100*hts.i_E, 100*hts.i_D, 100*hts.i_L);
end

% [repo-illesztes, 2026-08-12] az eredeti a szerzo MATLAB Drive-elrendezeset
% feltetelezte (ott a pwd a repo gyokere volt); itt a src/model. MODELL ERINTETLEN.
% [a repo-t es a munkakonyvtarat a fejlec mar beallitotta]
output_root = fullfile(repo, 'output');
try
    if ~exist(output_root, 'dir'), mkdir(output_root); end
catch
    output_root = fullfile(tempdir, 'kkv_dsge_v06_3type_output');
end
tablazatok = fullfile(output_root, 'tables');
abrak = fullfile(output_root, 'figures');
if ~exist(tablazatok, 'dir'), mkdir(tablazatok); end
if ~exist(abrak, 'dir'), mkdir(abrak); end

writetable(osszes, fullfile(tablazatok, 't27_v06_3type_szcenariok.csv'));
writetable(ht, fullfile(tablazatok, 't27_v06_3type_hosszutav.csv'));

% --- alap abra ---
kek = [42 120 214]/255; aqua = [27 175 122]/255;
sarga = [237 161 0]/255; voros = [190 60 55]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];
fig = figure('Visible', 'off', 'Position', [50 50 1120 460], ...
    'Color', felulet);

alap = osszes(string(osszes.szcenario) == "alap", :);
ax1 = subplot(1, 2, 1); hold(ax1, 'on');
h1 = plot(ax1, 1:T_ki, 100*alap.y_E, '-', 'Color', aqua, 'LineWidth', 2.2);
h2 = plot(ax1, 1:T_ki, 100*alap.y_D, '-', 'Color', sarga, 'LineWidth', 2.0);
h3 = plot(ax1, 1:T_ki, 100*alap.y_L, '-', 'Color', kek, 'LineWidth', 1.8);
h4 = plot(ax1, 1:T_ki, 100*alap.y, '--', 'Color', voros, 'LineWidth', 1.5);
yline(ax1, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax1, 13, ':', 'Color', masod, 'LineWidth', 1.2);
set(ax1, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10, 'Layer', 'top');
grid(ax1, 'on'); ax1.GridColor = [0.9 0.9 0.87];
ax1.GridAlpha = 1; ax1.XGrid = 'off';
legend(ax1, [h1 h2 h3 h4], {'export-KKV (E)', 'hazai KKV (D)', ...
    'nagyvallalat (L)', 'aggregalt y'}, 'Box', 'off', ...
    'FontSize', 8.5, 'Location', 'southeast');
title(ax1, 'Alappalya: kibocsatas harom vallalati tipusra', ...
    'FontSize', 10.5, 'Color', tinta);
xlabel(ax1, 'negyedev (belepes: 13.)', 'FontSize', 9);
ylabel(ax1, '% elteres', 'FontSize', 9);

ax2 = subplot(1, 2, 2); hold(ax2, 'on');
sav = 0.24;
b1 = bar(ax2, (1:3)-sav, 100*[ht.i_E], sav*0.9, ...
    'FaceColor', aqua, 'EdgeColor', 'none');
b2 = bar(ax2, (1:3), 100*[ht.i_D], sav*0.9, ...
    'FaceColor', sarga, 'EdgeColor', 'none');
b3 = bar(ax2, (1:3)+sav, 100*[ht.i_L], sav*0.9, ...
    'FaceColor', kek, 'EdgeColor', 'none');
set(ax2, 'XTick', 1:3, 'XTickLabel', szcenariok, 'Box', 'off', ...
    'Color', felulet, 'XColor', masod, 'YColor', masod, 'FontSize', 10);
grid(ax2, 'on'); ax2.GridColor = [0.9 0.9 0.87];
ax2.GridAlpha = 1; ax2.XGrid = 'off';
ylim(ax2, [0, 1.35*max([b1.YData b2.YData b3.YData 0.001])]);
legend(ax2, [b1(1) b2(1) b3(1)], {'i_E', 'i_D', 'i_L'}, ...
    'Box', 'off', 'FontSize', 9, 'Location', 'northwest');
title(ax2, 'Hosszu tavu beruhazas szcenarionkent', ...
    'FontSize', 10.5, 'Color', tinta);
ylabel(ax2, '%', 'FontSize', 9);

annotation(fig, 'textbox', [0.01 0.005 0.98 0.045], ...
    'String', ['v06_3type: elso explicit haromtipusos vaz. ' ...
    'Nincs benne reszletes IO/Gamma es hiszterezis; ' ...
    'TSCEN=3 semleges premium-transzmisszio.'], ...
    'FontSize', 7.5, 'EdgeColor', 'none', 'Color', [0.54 0.53 0.51], ...
    'Interpreter', 'none', 'VerticalAlignment', 'bottom');
sgtitle(fig, 'kkv\_dsge\_v06\_3type — export-KKV / hazai KKV / nagyvallalat', ...
    'FontSize', 12, 'Color', tinta);
exportgraphics(fig, fullfile(abrak, 'f23_v06_3type_szcenariok.png'), ...
    'Resolution', 180);

fprintf('Kiirva: t27_v06_3type_* + f23_v06_3type_szcenariok.png\n');
fprintf('Output mappa: %s\n', output_root);
