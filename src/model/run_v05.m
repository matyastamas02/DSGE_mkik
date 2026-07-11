% run_v05.m — Calvo-bérek: v0.4 (rugalmas bér) vs. v0.5 érzékenységi sáv
% Négy pálya az alap szcenárión (unió + 75% NR mindegyikben):
%   (a) v0.4: rugalmas bér         — t16-ból
%   (b) v0.5: theta_w = 0.60       (rugalmasabb)
%   (c) v0.5: theta_w = 0.75       (EAGLE/WDN alap)
%   (d) v0.5: theta_w = 0.85       (merevebb)
% Kimenet: output/tables/t18_v05_berragadossag.csv + f17_calvo_ber_v05.png
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_v05"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 80;
thetak = [60 75 85];
palyak = struct(); ss_y = zeros(3, 1); dip = zeros(3, 1);

for i = 1:3
    dynare('kkv_dsge_v05', sprintf('-DTHETAW=%d', thetak(i)), 'console');
    nevek = cellstr(M_.endo_names);
    yp = oo_.endo_simul(strcmp(nevek, 'y'), 2:(T_ki+1))';
    palyak.(sprintf('t%d', thetak(i))) = yp;
    ss_y(i) = oo_.steady_state(strcmp(nevek, 'y'));
    dip(i)  = min(yp(1:16));
    fprintf('theta_w=0.%d: hosszú táv %+.3f%%, dip %+.3f%%\n', ...
        thetak(i), 100*ss_y(i), 100*dip(i));
end

repo = fileparts(fileparts(pwd));
v04 = readtable(fullfile(repo, 'output', 'tables', 't16_v04_osszevetes.csv'));

T18 = table((1:T_ki)', v04.y_unio_nr_pct(1:T_ki), ...
    100*palyak.t60, 100*palyak.t75, 100*palyak.t85, ...
    'VariableNames', {'negyedev', 'y_v04_rugalmas_pct', ...
    'y_thetaw060_pct', 'y_thetaw075_pct', 'y_thetaw085_pct'});
writetable(T18, fullfile(repo, 'output', 'tables', ...
    't18_v05_berragadossag.csv'));

% ábra
kek = [42 120 214]/255; vil_kek = [134 182 239]/255;
sot_kek = [24 79 149]/255; masod = [0.32 0.31 0.29];
tinta = [0.04 0.04 0.04]; felulet = [0.988 0.988 0.984];
fig = figure('Visible', 'off', 'Position', [50 50 1080 460], ...
    'Color', felulet);
ax = axes(fig); hold(ax, 'on');
h0 = plot(ax, 1:T_ki, v04.y_unio_nr_pct(1:T_ki), '--', ...
    'Color', masod, 'LineWidth', 1.6);
h1 = plot(ax, 1:T_ki, 100*palyak.t60, '-', 'Color', vil_kek, 'LineWidth', 1.8);
h2 = plot(ax, 1:T_ki, 100*palyak.t75, '-', 'Color', kek, 'LineWidth', 2.2);
h3 = plot(ax, 1:T_ki, 100*palyak.t85, '-', 'Color', sot_kek, 'LineWidth', 1.8);
yline(ax, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax, 13, ':', 'Color', masod, 'LineWidth', 1.2);
set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10, 'Layer', 'top');
grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
ax.XGrid = 'off';
legend(ax, [h0 h1 h2 h3], {'v0.4: rugalmas bér', ...
    'v0.5: \theta_w=0.60', 'v0.5: \theta_w=0.75 (alap)', ...
    'v0.5: \theta_w=0.85'}, 'Box', 'off', 'FontSize', 9, ...
    'Location', 'southeast');
title(ax, ['Kibocsátás az alappályán — a bér-ragadósság szerepe ' ...
    '(unió + 75% nem-Ricardiánus mindegyikben)'], 'FontSize', 11.5, ...
    'Color', tinta);
xlabel(ax, 'negyedév a bejelentéstől (belépés: 13.)', 'FontSize', 9);
ylabel(ax, '% eltérés', 'FontSize', 9);
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f17_calvo_ber_v05.png'), 'Resolution', 180);
fprintf('Kiírva: t18_v05_berragadossag.csv + f17_calvo_ber_v05.png\n');
