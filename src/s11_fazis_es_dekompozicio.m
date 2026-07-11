% s11_fazis_es_dekompozicio.m — B2+B3 kulcsábrák a szcenáriófejezethez
% =====================================================================
% B2: fázis-annotált idővonal — az alappálya kibocsátása az 5 szakasz
%     sávozásával (bejelentés / ERM-II / belépés / normalizálódás /
%     tartós), a belépés előtti reálfelértékelődési visszaesés kiemelve.
% B3: csatorna-dekompozíció — a lineáris modellben a szuverén-only és
%     bank-only futás összege a teljes pálya; halmozott terület-ábra.
%
% A v0.3-at futtatja háromszor (teljes, -DCHANNEL=1, -DCHANNEL=2).
% Kimenet:  output/figures/f14_fazis_idovonal.png,
%           f15_csatorna_dekompozicio.png
%           output/tables/t15_csatorna_dekompozicio.csv
% Futtatás: matlab -batch "cd('src'); s11_fazis_es_dekompozicio"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 60;
ide_ = pwd; cd('model');
dynare('kkv_dsge_v03', 'console');
nevek = cellstr(M_.endo_names);
y_telj = oo_.endo_simul(strcmp(nevek, 'y'), 2:(T_ki+1))';
rer_telj = oo_.endo_simul(strcmp(nevek, 'rer'), 2:(T_ki+1))';
dynare('kkv_dsge_v03', '-DCHANNEL=1', 'console');
y_sov = oo_.endo_simul(strcmp(nevek, 'y'), 2:(T_ki+1))';
dynare('kkv_dsge_v03', '-DCHANNEL=2', 'console');
y_bank = oo_.endo_simul(strcmp(nevek, 'y'), 2:(T_ki+1))';
cd(ide_);

repo = fileparts(pwd);
abrak = fullfile(repo, 'output', 'figures');

% dekompozíció-ellenőrzés (linearitás): sov + bank ~= teljes
elteres = max(abs(y_sov + y_bank - y_telj));
fprintf('Dekompozíció-ellenőrzés: max |sov+bank-teljes| = %.2e (~0 kell)\n', ...
    elteres);
T15 = table((1:T_ki)', 100*y_telj, 100*y_sov, 100*y_bank, ...
    'VariableNames', {'negyedev', 'y_teljes_pct', 'y_szuveren_pct', ...
    'y_banki_pct'});
writetable(T15, fullfile(repo, 'output', 'tables', ...
    't15_csatorna_dekompozicio.csv'));

kek = [42 120 214]/255; aqua = [27 175 122]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];

% --- B2: fázis-idővonal -------------------------------------------------
fig = figure('Visible', 'off', 'Position', [50 50 1080 460], ...
    'Color', felulet);
ax = axes(fig); hold(ax, 'on');
% fázis-sávok: q1 bejelentés | q1-12 ERM-II | q13 belépés | q13-16 norm. | q17- tartós
savok = [1 12; 13 16];
savszin = [0.945 0.933 0.90; 0.90 0.92 0.945];
for b = 1:2
    fill(ax, [savok(b,1) savok(b,2)+0.5 savok(b,2)+0.5 savok(b,1)], ...
        [-0.35 -0.35 0.35 0.35], savszin(b,:), 'EdgeColor', 'none');
end
plot(ax, 1:T_ki, 100*y_telj, '-', 'Color', kek, 'LineWidth', 2.2);
plot(ax, 1:T_ki, 100*rer_telj, '--', 'Color', aqua, 'LineWidth', 1.6);
yline(ax, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax, 13, ':', 'Color', masod, 'LineWidth', 1.2);
ylim(ax, [-0.35 0.35]); xlim(ax, [1 T_ki]);
set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10, 'Layer', 'top');
grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
ax.XGrid = 'off';
text(ax, 2, 0.31, 'bejelentés + ERM-II', 'FontSize', 9, 'Color', masod);
text(ax, 13.4, 0.31, 'belépés + normalizálódás', 'FontSize', 9, ...
    'Color', masod);
text(ax, 30, 0.31, 'tartós szakasz', 'FontSize', 9, 'Color', masod);
text(ax, 7, -0.28, {'konvergenciás', 'felértékelődési dip'}, ...
    'FontSize', 8.5, 'Color', tinta, 'HorizontalAlignment', 'center');
title(ax, ['Az euró-belépés időprofilja — kibocsátás (kék) és ' ...
    'reálárfolyam (zöld szaggatott), alappálya'], 'FontSize', 11.5, ...
    'Color', tinta);
xlabel(ax, 'negyedév a bejelentéstől', 'FontSize', 9);
ylabel(ax, '% eltérés', 'FontSize', 9);
exportgraphics(fig, fullfile(abrak, 'f14_fazis_idovonal.png'), ...
    'Resolution', 180);
fprintf('Kiírva: f14_fazis_idovonal.png\n');

% --- B3: csatorna-dekompozíció (halmozott terület) ----------------------
fig = figure('Visible', 'off', 'Position', [50 50 1080 460], ...
    'Color', felulet);
ax = axes(fig); hold(ax, 'on');
ar = area(ax, 1:T_ki, 100*[y_sov y_bank], 'EdgeColor', 'none');
ar(1).FaceColor = kek;  ar(1).FaceAlpha = 0.85;
ar(2).FaceColor = aqua; ar(2).FaceAlpha = 0.85;
hT = plot(ax, 1:T_ki, 100*y_telj, '-', 'Color', tinta, 'LineWidth', 1.6);
yline(ax, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax, 13, ':', 'Color', masod, 'LineWidth', 1.2);
set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10, 'Layer', 'top');
grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
ax.XGrid = 'off';
legend(ax, [ar(1) ar(2) hT], {'szuverén csatorna (EFP+UIP)', ...
    'banki forrásköltség csatorna', 'teljes pálya'}, 'Box', 'off', ...
    'FontSize', 9, 'Location', 'southeast');
title(ax, ['Csatorna-dekompozíció — a kibocsátási hatás felbontása ' ...
    '(lineáris modell: a két csatorna additív)'], 'FontSize', 11.5, ...
    'Color', tinta);
xlabel(ax, 'negyedév a bejelentéstől', 'FontSize', 9);
ylabel(ax, '% eltérés', 'FontSize', 9);
exportgraphics(fig, fullfile(abrak, 'f15_csatorna_dekompozicio.png'), ...
    'Resolution', 180);
fprintf('Kiírva: f15_csatorna_dekompozicio.png\n');
