% run_jv_v06.m — a v05 BELSO javitasa (nem a meret/piac szetvalasztasa), 3 palya
% Kimenet: output/tables/t34_jv_v06_szcenariok.csv + t34_jv_v06_hosszutav.csv
%          output/figures/f25_jv_v06_belso_javitas.png
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_jv_v06"
%
% A v05-höz képest az ÚJDONSÁG nem az aggregált szám (az gyakorlatilag
% változatlan), hanem hogy a szegmens-szintű kimenetnek VAN szerkezeti
% alapja: a BGG-tőke közvetlenül a saját szegmens termelését hajtja, és
% rk_S != rk_L. Az ábra ezt bizonyítja: a v05-ben efp_S és efp_L hosszú
% távon EGY PONTBA fut (közös rk miatt), a v06-ban nem.
%
% FIGYELEM az értelmezésnél: a szegmens-beruházás a v06-ban már NEM
% reallokációs maradék (ez a v06 lényege), DE a szegmensek közti KÜLÖNBSÉG
% továbbra is a t_sov/t_bank súlyok FELTEVÉSÉN is áll, amit az adat nem
% azonosít (lásd docs/FIGYELMEZTETES_fo_allitas.md). A -DTSCEN kapcsolóval
% a sáv végigmérhető.

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T_ki = 80;
szcenariok = {'alap', 'optimista', 'pesszimista'};
valt = {'y','y_d','y_x','i_S','i_L','efp_S','efp_L','nw_S','nw_L', ...
    'h_dx','xx','c','infl','r','rer','rk_S','rk_L','z_S','z_L','l_S','l_L'};
osszes = table(); ht = table();

for s = 1:3
    dynare('jv_dsge_v06', sprintf('-DSCENARIO=%d', s), 'console');
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
    fprintf(['%s: y h.tav=%+.3f%% | i_S=%+.3f%% i_L=%+.3f%% | ' ...
        'rk_S=%+.3f%% rk_L=%+.3f%% | efp_S-efp_L=%+.4f pp | y 10ev=%+.3f%%\n'], ...
        szcenariok{s}, 100*hts.y, 100*hts.i_S, 100*hts.i_L, ...
        100*hts.rk_S, 100*hts.rk_L, 100*(hts.efp_S - hts.efp_L), ...
        100*blokk.y(40));
end

% --- v05 alappálya az ÖSSZEHASONLÍTÁSHOZ (a fix bizonyítéka) ---
dynare('jv_dsge_v05', '-DSCENARIO=1', 'console');
n5 = cellstr(M_.endo_names);
v05_efpS = oo_.endo_simul(strcmp(n5, 'efp_S'), 2:(T_ki+1))' * 10000;
v05_efpL = oo_.endo_simul(strcmp(n5, 'efp_L'), 2:(T_ki+1))' * 10000;
v05_y_ss = 100 * oo_.steady_state(strcmp(n5, 'y'));
v05_efpS_ss = 10000 * oo_.steady_state(strcmp(n5, 'efp_S'));
v05_efpL_ss = 10000 * oo_.steady_state(strcmp(n5, 'efp_L'));

repo = fileparts(fileparts(pwd));
writetable(osszes, fullfile(repo, 'output', 'tables', ...
    't34_jv_v06_szcenariok.csv'));
writetable(ht, fullfile(repo, 'output', 'tables', ...
    't34_jv_v06_hosszutav.csv'));

fprintf('\n%s\n', repmat('=', 1, 74));
fprintf('A FIX BIZONYITEKA — hosszu tavu szegmens-premium-differencia:\n');
fprintf('  v05: efp_S=%+.2f bp, efp_L=%+.2f bp -> kulonbseg %.4f bp\n', ...
    v05_efpS_ss, v05_efpL_ss, v05_efpS_ss - v05_efpL_ss);
fprintf('  v06: efp_S=%+.2f bp, efp_L=%+.2f bp -> kulonbseg %.2f bp\n', ...
    10000*ht.efp_S(1), 10000*ht.efp_L(1), ...
    10000*(ht.efp_S(1) - ht.efp_L(1)));
fprintf('AGGREGALT GDP (alap): v05 %+.3f%% -> v06 %+.3f%%  (elteres %.3f pp)\n', ...
    v05_y_ss, 100*ht.y(1), 100*ht.y(1) - v05_y_ss);
fprintf('%s\n', repmat('=', 1, 74));

% --- ábra ---
kek = [42 120 214]/255; aqua = [27 175 122]/255; sarga = [237 161 0]/255;
piros = [199 62 45]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29]; felulet = [0.988 0.988 0.984];
fig = figure('Visible', 'off', 'Position', [50 50 1180 500], 'Color', felulet);

alap = osszes(string(osszes.szcenario) == "alap", :);

% BAL: a fix bizonyítéka — v05 egy pontba fut, v06 nem
% (explicit pozíciók, hogy a lábjegyzetnek maradjon hely alul)
ax1 = subplot(1, 2, 1); hold(ax1, 'on');
set(ax1, 'Position', [0.065 0.235 0.395 0.63]);
h1 = plot(ax1, 1:T_ki, 10000*alap.efp_S, '-', 'Color', kek, 'LineWidth', 2.2);
h2 = plot(ax1, 1:T_ki, 10000*alap.efp_L, '-', 'Color', aqua, 'LineWidth', 2.2);
h3 = plot(ax1, 1:T_ki, v05_efpS, '--', 'Color', kek, 'LineWidth', 1.1);
h4 = plot(ax1, 1:T_ki, v05_efpL, '--', 'Color', aqua, 'LineWidth', 1.1);
yline(ax1, 0, 'Color', masod, 'LineWidth', 0.7);
xline(ax1, 13, ':', 'Color', masod, 'LineWidth', 1.2);
set(ax1, 'Box', 'off', 'Color', felulet, 'XColor', masod, 'YColor', masod, ...
    'FontSize', 10, 'Layer', 'top');
grid(ax1, 'on'); ax1.GridColor = [0.9 0.9 0.87]; ax1.GridAlpha = 1; ax1.XGrid='off';
legend(ax1, [h1 h2 h3 h4], {'KKV-felár, v06', 'nagyváll. felár, v06', ...
    'KKV-felár, v05 (közös rk)', 'nagyváll. felár, v05'}, ...
    'Box', 'off', 'FontSize', 8, 'Location', 'southeast', 'Interpreter', 'tex');
title(ax1, 'A fix bizonyítéka: a v05-ben a két felár egy pontba fut', ...
    'FontSize', 10.5, 'Color', tinta);
xlabel(ax1, 'negyedév (belépés: 13.)', 'FontSize', 9);
ylabel(ax1, 'bázispont', 'FontSize', 9);

% JOBB: szegmens-beruházás — a v06-ban MÁR NEM reallokációs maradék
ax2 = subplot(1, 2, 2); hold(ax2, 'on');
set(ax2, 'Position', [0.575 0.235 0.395 0.63]);
sav = 0.35;
b1 = bar(ax2, (1:3)-sav/2, 100*ht.i_S, sav*0.9, 'FaceColor', kek, 'EdgeColor', 'none');
b2 = bar(ax2, (1:3)+sav/2, 100*ht.i_L, sav*0.9, 'FaceColor', aqua, 'EdgeColor', 'none');
set(ax2, 'XTick', 1:3, 'XTickLabel', szcenariok, 'Box', 'off', ...
    'Color', felulet, 'XColor', masod, 'YColor', masod, 'FontSize', 10);
grid(ax2, 'on'); ax2.GridColor = [0.9 0.9 0.87]; ax2.GridAlpha = 1; ax2.XGrid='off';
ylim(ax2, [0, 1.35*max([b1.YData b2.YData])]);
legend(ax2, [b1(1) b2(1)], {'KKV-beruházás (i\_S)', 'nagyváll. beruházás (i\_L)'}, ...
    'Box', 'off', 'FontSize', 9, 'Location', 'northwest', 'Interpreter', 'tex');
title(ax2, 'Hosszú távú beruházás — most már termelés hajtja', ...
    'FontSize', 10.5, 'Color', tinta);
ylabel(ax2, '%', 'FontSize', 9);

fig_txt = ['Bal: a v05-ben (szaggatott) a ket felar hosszu tavon EGY PONTBA fut ' ...
    '(kozos rk), a v06-ban (folytonos) nem -- rk-S =/= rk-L, a res tartos.' newline ...
    'Jobb: a szegmens-beruhazas mar NEM reallokacios maradek. FIGYELEM: a ' ...
    'szegmensek kozti KULONBSEG a t-sov/t-bank sulyok feltevesen is all ' ...
    '(-DTSCEN sav; lasd FIGYELMEZTETES-fo-allitas.md).'];
annotation(fig, 'textbox', [0.02 0.015 0.96 0.10], 'String', fig_txt, ...
    'FontSize', 8, 'EdgeColor', 'none', 'Color', [0.5 0.49 0.47], ...
    'Interpreter', 'none', 'VerticalAlignment', 'bottom', 'FitBoxToText', 'off');
sgtitle(fig, ['jv\_dsge\_v06 — a KKV/nagyvállalat szétválasztás a ' ...
    'TERMELÉSI oldalon is'], 'FontSize', 12, 'Color', tinta);
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f25_jv_v06_belso_javitas.png'), 'Resolution', 180);
fprintf('Kiirva: t34_jv_v06_* + f25_jv_v06_belso_javitas.png\n');
