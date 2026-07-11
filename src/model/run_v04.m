% run_v04.m — kamatunió + nem-Ricardiánus háztartások: összehasonlító futás
% Három pálya az alap szcenárión:
%   (a) v0.3 (nincs rezsimváltás, om_nr=0)      — a szcenario_v03.csv-ből
%   (b) v0.4 unió-only (-DOMNR=0)               — csak a rezsimváltás
%   (c) v0.4 unió + 75% nem-Ricardiánus (alap)  — a teljes v0.4
% Kimenet: output/tables/t16_v04_osszevetes.csv + f16_kamatunio_v04.png
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_v04"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 80;
valtozok = {'y', 'y_S', 'y_L', 'ii', 'c', 'r', 'dep', 'rer', 'infl'};

% (b) unió-only
dynare('kkv_dsge_v04', '-DOMNR=0', 'console');
nevek = cellstr(M_.endo_names);
unio = struct(); unio_ss = struct();
for v = 1:numel(valtozok)
    sor = strcmp(nevek, valtozok{v});
    unio.(valtozok{v}) = oo_.endo_simul(sor, 2:(T_ki+1))';
    unio_ss.(valtozok{v}) = oo_.steady_state(sor);
end

% (c) unió + nem-Ricardiánus
dynare('kkv_dsge_v04', '-DOMNR=75', 'console');
nr = struct(); nr_ss = struct();
for v = 1:numel(valtozok)
    sor = strcmp(nevek, valtozok{v});
    nr.(valtozok{v}) = oo_.endo_simul(sor, 2:(T_ki+1))';
    nr_ss.(valtozok{v}) = oo_.steady_state(sor);
end

% (a) v0.3 alap referencia
repo = fileparts(fileparts(pwd));
v03 = readtable(fullfile(repo, 'output', 'tables', 'szcenario_v03.csv'));
v03 = v03(string(v03.szcenario) == "alap", :);
v03ht = readtable(fullfile(repo, 'output', 'tables', ...
    'szcenario_v03_hosszutav.csv'));
v03ht = v03ht(string(v03ht.szcenario) == "alap", :);

fprintf('\n===== Hosszú távú GDP-szint (alappálya) =====\n');
fprintf('v0.3 (nincs rezsimváltás):    %+.3f%%\n', 100*v03ht.y);
fprintf('v0.4 kamatunió (om_nr=0):     %+.3f%%\n', 100*unio_ss.y);
fprintf('v0.4 unió + 75%% nem-Ricardi: %+.3f%%\n', 100*nr_ss.y);
fprintf('10 éves pont: v0.3 %+.3f%% | unió %+.3f%% | unió+NR %+.3f%%\n', ...
    100*v03.y(40), 100*unio.y(40), 100*nr.y(40));

% tábla
T16 = table((1:T_ki)', v03.y(1:T_ki)*100, unio.y*100, nr.y*100, ...
    unio.r*40000, nr.dep*100, nr.c*100, ...
    'VariableNames', {'negyedev', 'y_v03_pct', 'y_unio_pct', ...
    'y_unio_nr_pct', 'r_unio_bp', 'dep_unio_nr_pct', 'c_unio_nr_pct'});
writetable(T16, fullfile(repo, 'output', 'tables', 't16_v04_osszevetes.csv'));

% ábra
kek = [42 120 214]/255; aqua = [27 175 122]/255; sarga = [237 161 0]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];
fig = figure('Visible', 'off', 'Position', [50 50 1080 460], ...
    'Color', felulet);
ax = axes(fig); hold(ax, 'on');
h1 = plot(ax, 1:T_ki, 100*v03.y(1:T_ki), '-',  'Color', sarga, 'LineWidth', 1.8);
h2 = plot(ax, 1:T_ki, 100*unio.y,        '-',  'Color', aqua,  'LineWidth', 1.8);
h3 = plot(ax, 1:T_ki, 100*nr.y,          '-',  'Color', kek,   'LineWidth', 2.2);
yline(ax, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax, 13, ':', 'Color', masod, 'LineWidth', 1.2);
yline(ax, 100*nr_ss.y, '--', 'Color', kek, 'LineWidth', 1, 'Alpha', 0.55);
set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10, 'Layer', 'top');
grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
ax.XGrid = 'off';
legend(ax, [h3 h2 h1], {'v0.4: kamatunió + 75% nem-Ricardiánus', ...
    'v0.4: csak kamatunió', 'v0.3: nincs rezsimváltás'}, ...
    'Box', 'off', 'FontSize', 9, 'Location', 'southeast');
title(ax, ['Kibocsátás az alappályán — a kamatunió-rezsimváltás és a ' ...
    'nem-Ricardiánus háztartások hatása'], 'FontSize', 11.5, 'Color', tinta);
xlabel(ax, 'negyedév a bejelentéstől (belépés: 13.)', 'FontSize', 9);
ylabel(ax, '% eltérés', 'FontSize', 9);
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f16_kamatunio_v04.png'), 'Resolution', 180);
fprintf('Kiírva: t16_v04_osszevetes.csv + f16_kamatunio_v04.png\n');
