% run_jv_v05.m — a szegmentált euró-szcenárió (KKV/nagyvállalat), 3 pálya
% Kimenet: output/tables/t21_jv_v05_szcenariok.csv + t21_jv_v05_hosszutav.csv
%          output/figures/f20_jv_v05_szegmentalt_szcenario.png
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_jv_v05"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 80;
szcenariok = {'alap', 'optimista', 'pesszimista'};
valt = {'y','y_d','y_x','i_S','i_L','efp_S','efp_L','nw_S','nw_L', ...
    'h_dx','xx','c','infl','r','rer'};
osszes = table(); ht = table();

for s = 1:3
    dynare('jv_dsge_v05', sprintf('-DSCENARIO=%d', s), 'console');
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
    fprintf(['%s: y hossz.tav=%+.3f%% | y_d=%+.3f%% y_x=%+.3f%% | ' ...
        'i_S=%+.3f%% i_L=%+.3f%% (h.tav) | y 10ev=%+.3f%%\n'], ...
        szcenariok{s}, 100*hts.y, 100*hts.y_d, 100*hts.y_x, ...
        100*hts.i_S, 100*hts.i_L, 100*blokk.y(40));
end

repo = fileparts(fileparts(pwd));
writetable(osszes, fullfile(repo, 'output', 'tables', ...
    't21_jv_v05_szcenariok.csv'));
writetable(ht, fullfile(repo, 'output', 'tables', ...
    't21_jv_v05_hosszutav.csv'));

% --- ábra ---
kek = [42 120 214]/255; aqua = [27 175 122]/255; sarga = [237 161 0]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29]; felulet = [0.988 0.988 0.984];
fig = figure('Visible', 'off', 'Position', [50 50 1120 460], 'Color', felulet);

alap = osszes(string(osszes.szcenario) == "alap", :);
ax1 = subplot(1, 2, 1); hold(ax1, 'on');
h1 = plot(ax1, 1:T_ki, 100*alap.y_d, '-', 'Color', sarga, 'LineWidth', 2.2);
h2 = plot(ax1, 1:T_ki, 100*alap.y_x, '-', 'Color', aqua, 'LineWidth', 2);
h3 = plot(ax1, 1:T_ki, 100*alap.h_dx, '-', 'Color', kek, 'LineWidth', 1.6);
yline(ax1, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax1, 13, ':', 'Color', masod, 'LineWidth', 1.2);
set(ax1, 'Box', 'off', 'Color', felulet, 'XColor', masod, 'YColor', masod, ...
    'FontSize', 10, 'Layer', 'top');
grid(ax1, 'on'); ax1.GridColor = [0.9 0.9 0.87]; ax1.GridAlpha = 1; ax1.XGrid='off';
legend(ax1, [h1 h2 h3], {'KKV-kibocsátás (y\_d)', 'export-kibocsátás (y\_x)', ...
    'KKV-input az exportőrhöz (h\_dx)'}, 'Box', 'off', 'FontSize', 8.5, ...
    'Location', 'northeast', 'Interpreter', 'tex');
title(ax1, 'Alappálya: KKV, export és a vertikális link', 'FontSize', 10.5, ...
    'Color', tinta);
xlabel(ax1, 'negyedév (belépés: 13.)', 'FontSize', 9);
ylabel(ax1, '% eltérés', 'FontSize', 9);

ax2 = subplot(1, 2, 2); hold(ax2, 'on');
sav = 0.35;
b1 = bar(ax2, (1:3)-sav/2, [ht.i_S], sav*0.9, 'FaceColor', kek, 'EdgeColor', 'none');
b2 = bar(ax2, (1:3)+sav/2, [ht.i_L], sav*0.9, 'FaceColor', aqua, 'EdgeColor', 'none');
set(ax2, 'XTick', 1:3, 'XTickLabel', szcenariok, 'Box', 'off', ...
    'Color', felulet, 'XColor', masod, 'YColor', masod, 'FontSize', 10);
grid(ax2, 'on'); ax2.GridColor = [0.9 0.9 0.87]; ax2.GridAlpha = 1; ax2.XGrid='off';
% értékek átszorozva 100-zal a bar-hoz
b1.YData = 100*b1.YData; b2.YData = 100*b2.YData;
ylim(ax2, [0, 1.35*max([b1.YData b2.YData])]);
legend(ax2, [b1(1) b2(1)], {'KKV-beruházás (i\_S)', 'nagyváll. beruházás (i\_L)'}, ...
    'Box', 'off', 'FontSize', 9, 'Location', 'northwest', 'Interpreter', 'tex');
title(ax2, 'Hosszú távú (steady state) beruházás szcenáriónként', ...
    'FontSize', 10.5, 'Color', tinta);
ylabel(ax2, '%', 'FontSize', 9);

fig_txt = ['Bal: az alappálya vertikális együttmozgása a tényleges euró-' ...
    'szcenárión (nem tesztsokkon). A KKV-kibocsátás (y-d) hosszú távú ' ...
    'útját a reálárfolyam-csatorna módosítja (lásd diag-yd-v04). ' ...
    'Jobb: a méret-aszimmetria mindhárom szcenárióban. ' ...
    'Zárás: nu-uni = 0.25 (lásd diag-nuuni-v05).'];
annotation(fig, 'textbox', [0.01 0.005 0.98 0.045], 'String', fig_txt, ...
    'FontSize', 7.5, 'EdgeColor', 'none', 'Color', [0.54 0.53 0.51], ...
    'Interpreter', 'none', 'VerticalAlignment', 'bottom');
sgtitle(fig, 'jv\_dsge\_v05 — szegmentált (KKV/nagyvállalat) euró-szcenárió', ...
    'FontSize', 12, 'Color', tinta);
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f20_jv_v05_szegmentalt_szcenario.png'), 'Resolution', 180);
fprintf('Kiirva: t21_jv_v05_* + f20_jv_v05_szegmentalt_szcenario.png\n');
