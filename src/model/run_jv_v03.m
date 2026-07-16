% run_jv_v03.m — euró-szcenáriók a Jakab–Világi alapon (3 pálya)
% Kimenet: output/tables/t19_jv_szcenariok.csv + hosszú távú tábla,
%          output/figures/f18_jv_szcenariok.png (+ EAGLE-vonal összevetés)
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_jv_v03"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 80;
szcenariok = {'alap', 'optimista', 'pesszimista'};
valtozok = {'y', 'c', 'ii', 'i_S', 'i_L', 'efp_S', 'efp_L', 'xx', ...
            'infl', 'r', 'rer', 'dep'};
osszes = table(); ht = table();

for s = 1:3
    dynare('jv_dsge_v03', sprintf('-DSCENARIO=%d', s), 'console');
    nevek = cellstr(M_.endo_names);
    blokk = table((1:T_ki)', 'VariableNames', {'negyedev'});
    blokk.szcenario = repmat(szcenariok(s), T_ki, 1);
    hts = table(szcenariok(s), 'VariableNames', {'szcenario'});
    for v = 1:numel(valtozok)
        sor = strcmp(nevek, valtozok{v});
        blokk.(valtozok{v}) = oo_.endo_simul(sor, 2:(T_ki+1))';
        hts.(valtozok{v}) = oo_.steady_state(sor);
    end
    osszes = [osszes; blokk]; %#ok<AGROW>
    ht = [ht; hts]; %#ok<AGROW>
    fprintf('JV %s: y(10 év)=%+.3f%%, hosszú táv=%+.3f%%, dip=%+.3f%%\n', ...
        szcenariok{s}, 100*blokk.y(40), 100*hts.y, 100*min(blokk.y(1:16)));
end

repo = fileparts(fileparts(pwd));
writetable(osszes, fullfile(repo, 'output', 'tables', 't19_jv_szcenariok.csv'));
writetable(ht, fullfile(repo, 'output', 'tables', 't19_jv_hosszutav.csv'));

% --- Ábra: JV-alap 3 pálya + EAGLE-vonal (v0.4) referencia ---
kek = [42 120 214]/255; aqua = [27 175 122]/255; sarga = [237 161 0]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];
szin = {kek, aqua, sarga};
fig = figure('Visible', 'off', 'Position', [50 50 1080 460], ...
    'Color', felulet);
ax = axes(fig); hold(ax, 'on');
hv = gobjects(4, 1);
for s = 1:3
    resz = osszes(string(osszes.szcenario) == szcenariok{s}, :);
    hv(s) = plot(ax, 1:T_ki, 100*resz.y, '-', 'Color', szin{s}, ...
        'LineWidth', 2);
end
% EAGLE-vonal referencia (v0.4 unió+NR), ha megvan:
t16f = fullfile(repo, 'output', 'tables', 't16_v04_osszevetes.csv');
if exist(t16f, 'file') == 2
    t16 = readtable(t16f);
    hv(4) = plot(ax, 1:min(T_ki, height(t16)), ...
        t16.y_unio_nr_pct(1:min(T_ki, height(t16))), '--', ...
        'Color', masod, 'LineWidth', 1.5);
    cimkek = {'JV alap', 'JV optimista', 'JV pesszimista', ...
        'EAGLE-vonal v0.4 (referencia)'};
else
    hv = hv(1:3);
    cimkek = {'JV alap', 'JV optimista', 'JV pesszimista'};
end
yline(ax, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax, 13, ':', 'Color', masod, 'LineWidth', 1.2);
set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10, 'Layer', 'top');
grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
ax.XGrid = 'off';
legend(ax, hv, cimkek, 'Box', 'off', 'FontSize', 9, ...
    'Location', 'southeast');
title(ax, ['Euró-szcenáriók a Jakab–Világi (becsült) alapon — ' ...
    'kibocsátás, kamatunió-rezsimváltással'], 'FontSize', 11.5, ...
    'Color', tinta);
xlabel(ax, 'negyedév a bejelentéstől (belépés: 13.)', 'FontSize', 9);
ylabel(ax, '% eltérés', 'FontSize', 9);
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f18_jv_szcenariok.png'), 'Resolution', 180);
fprintf('Kiírva: t19 + f18_jv_szcenariok.png\n');
