% s06_szegmens_lekepezes.m — 2. réteg: kalibrált szegmens-leképezés
% =====================================================================
% A DSGE (v0.3) szektorszintű KKV-kamatpályáját az Opten-panel implicit
% kamatráta-eloszlására vetíti, kockázati besorolás szerinti szegmensekre.
%
% FONTOS (pitch, 3. védendő pont): az itt készülő számok KALIBRÁLT
% LEKÉPEZÉSI eredmények, nem DSGE-predikciók. A leképezési szabály:
%   szegmens bp-csökkenés = aggregát KKV bp-csökkenés
%                           × (szegmens medián implicit ráta / KKV medián)
% — vagyis a hatás a kamatszinttel arányosan oszlik el (a magasabb
% kamaton finanszírozott szegmens abszolút értékben többet nyer). A sávot
% a szegmens kvartilis-rátái adják.
%
% Bemenet:  data/processed/opten_panel.csv
%           output/tables/szcenario_v03.csv, szcenario_v03_hosszutav.csv
% Kimenet:  output/tables/t09_szegmens_lekepezes.csv
%           output/figures/f07_szegmens_lekepezes.png
%
% Futtatás a repo gyökeréből:  matlab -batch "cd('src'); s06_szegmens_lekepezes"
% (Nincs 'clear' az elején — a run_all láncban a hívó munkaterét törölné.)

repo = fileparts(pwd);
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');
palya_f = fullfile(repo, 'output', 'tables', 'szcenario_v03.csv');
ht_f    = fullfile(repo, 'output', 'tables', 'szcenario_v03_hosszutav.csv');

% --- 1. Opten: implicit ráta-eloszlás szegmensenként (2021–2024, KKV) ---
opts = detectImportOptions(panel_f);
opts.SelectedVariableNames = {'ev', 'meret_kategoria', ...
    'kockazati_besorolas', 'implicit_kamatrata'};
p = readtable(panel_f, opts);
p = p(p.ev >= 2021 & p.ev <= 2024, :);
kkv = p(ismember(string(p.meret_kategoria), ["10-49", "50-249"]), :);
kkv = kkv(~isnan(kkv.implicit_kamatrata), :);

szegmensek = ["A", "B", "C", "D", "AVG"];
kkv_median = median(kkv.implicit_kamatrata);
fprintf('KKV medián implicit ráta (2021-24): %.2f%%\n', 100*kkv_median);

n_g   = zeros(numel(szegmensek), 1);
med_g = zeros(numel(szegmensek), 1);
q1_g  = zeros(numel(szegmensek), 1);
q3_g  = zeros(numel(szegmensek), 1);
for g = 1:numel(szegmensek)
    r = kkv.implicit_kamatrata(string(kkv.kockazati_besorolas) == szegmensek(g));
    n_g(g)   = numel(r);
    med_g(g) = median(r);
    q1_g(g)  = quantile(r, 0.25);
    q3_g(g)  = quantile(r, 0.75);
end

% --- 2. Modell: aggregát KKV-kamatcsökkenés szcenáriónként ---
% A vállalat külső forrásköltsége a modellben r + efp_S; évesített bp.
palya = readtable(palya_f);
ht    = readtable(ht_f);
szcenariok = ["alap", "optimista", "pesszimista"];

agg_bp_ht  = zeros(3, 1);   % hosszú táv (új steady state)
agg_bp_10e = zeros(3, 1);   % 10 éves pont
for s = 1:3
    sor_ht = string(ht.szcenario) == szcenariok(s);
    agg_bp_ht(s) = (ht.r(sor_ht) + ht.efp_S(sor_ht)) * 40000;
    resz = palya(string(palya.szcenario) == szcenariok(s), :);
    agg_bp_10e(s) = (resz.r(resz.negyedev == 40) + ...
                     resz.efp_S(resz.negyedev == 40)) * 40000;
    fprintf('%-12s: KKV-kamat hosszú táv %.0f bp, 10 év %.0f bp\n', ...
        szcenariok(s), agg_bp_ht(s), agg_bp_10e(s));
end

% --- 3. Leképezés: szegmens bp = aggregát bp × ráta-arány -------------
sorok = [];
for s = 1:3
    for g = 1:numel(szegmensek)
        kozep = agg_bp_ht(s)  * med_g(g) / kkv_median;
        also  = agg_bp_ht(s)  * q1_g(g)  / kkv_median;
        felso = agg_bp_ht(s)  * q3_g(g)  / kkv_median;
        tizev = agg_bp_10e(s) * med_g(g) / kkv_median;
        sorok = [sorok; {char(szcenariok(s)), char(szegmensek(g)), ...
            n_g(g), 100*med_g(g), kozep, also, felso, tizev}]; %#ok<AGROW>
    end
end
T = cell2table(sorok, 'VariableNames', {'szcenario', 'besorolas', ...
    'ceg_ev', 'median_implicit_rata_pct', 'bp_hosszutav', ...
    'bp_sav_also', 'bp_sav_felso', 'bp_10ev'});
ki_t = fullfile(repo, 'output', 'tables', 't09_szegmens_lekepezes.csv');
writetable(T, ki_t);
fprintf('Kiírva: %s\n', ki_t);

% --- 4. Ábra: szegmens-oszlopok a három szcenárióban ------------------
% (dataviz-paletta; a sáv a kvartilis-rátákból)
szin = [42 120 214; 27 175 122; 237 161 0] / 255;   % alap/opt/pessz
fig = figure('Visible', 'off', 'Position', [100 100 1040 420], ...
    'Color', [0.988 0.988 0.984]);
ax = axes(fig);
hold(ax, 'on');
nG = numel(szegmensek);
sav = 0.25;
bh = gobjects(3, 1);
for s = 1:3
    ertek = -T.bp_hosszutav(string(T.szcenario) == szcenariok(s));
    also  = -T.bp_sav_felso(string(T.szcenario) == szcenariok(s));
    felso = -T.bp_sav_also(string(T.szcenario) == szcenariok(s));
    x = (1:nG) + (s-2)*sav;
    bh(s) = bar(ax, x, ertek, sav*0.88, 'FaceColor', szin(s,:), ...
        'EdgeColor', 'none');
    for g = 1:nG
        plot(ax, [x(g) x(g)], [also(g) felso(g)], '-', ...
            'Color', [0.32 0.31 0.29], 'LineWidth', 1);
    end
end
set(ax, 'XTick', 1:nG, 'XTickLabel', cellstr(szegmensek), ...
    'FontSize', 10, 'XColor', [0.32 0.31 0.29], ...
    'YColor', [0.32 0.31 0.29], 'Color', [0.988 0.988 0.984], ...
    'Box', 'off');
grid(ax, 'on'); ax.GridColor = [0.88 0.88 0.85]; ax.GridAlpha = 1;
ax.YGrid = 'on'; ax.XGrid = 'off';
ylabel(ax, 'kamatcsökkenés, évesített bp (hosszú táv)', 'FontSize', 9);
title(ax, ['Kalibrált szegmens-leképezés — KKV-kamatcsökkenés ' ...
    'kockázati besorolás szerint'], 'FontSize', 11, ...
    'Color', [0.04 0.04 0.04], 'HorizontalAlignment', 'left', ...
    'Units', 'normalized', 'Position', [0 1.04 0]);
legend(bh, {'alap', 'optimista', 'pesszimista'}, 'Box', 'off', ...
    'FontSize', 9, 'Location', 'northwest');
annotation(fig, 'textbox', [0.01 0.0 0.98 0.05], 'String', ...
    ['Kalibrált leképezés, NEM DSGE-predikció. Szabály: aggregát KKV-hatás ' ...
     '\times szegmens/KKV medián implicit ráta arány; sáv: kvartilis-ráták. ' ...
     'A D kategória mintája vékony (28 cég-év). Az AVG jelentése a ' ...
     'szállítónál tisztázás alatt.'], ...
    'FontSize', 8, 'EdgeColor', 'none', 'Color', [0.54 0.53 0.51]);
ki_f = fullfile(repo, 'output', 'figures', 'f07_szegmens_lekepezes.png');
exportgraphics(fig, ki_f, 'Resolution', 200);
fprintf('Kiírva: %s\n', ki_f);

% --- 5. Konzol-összefoglaló -------------------------------------------
disp(T(string(T.szcenario) == "alap", :));
fprintf(['\nMEGJEGYZÉS: az Opten-adatban a besorolások közti RÁTA-különbség\n' ...
    'mérsékelt (a szelekció miatt: csak a hitelhez jutó cégeknél mérhető).\n' ...
    'A fő heterogenitás a HOZZÁFÉRÉSBEN van — lásd extenzív margó blokk.\n']);
