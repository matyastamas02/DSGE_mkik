% s08_tamogatott_hitel_teszt.m — a "lapos árazás" red flag adjudikálása
% =====================================================================
% Kérdés: a besorolások közti mérsékelt implicit-ráta-különbség valódi
% piaci jellemző, vagy a támogatott hitelprogramok (NHP ~2,5%, Széchenyi
% MAX ~5%) és a fix kamatozású régi állomány (vintage-hatás) nyomja össze?
%
% Három diagnosztika (KKV-cég-évek, 2021–2024):
%   1. Éves ráta-eloszlások a 3 havi BUBOR éves átlagához képest.
%      Ha a piac árazna, 2023-ban (BUBOR ~13,6%) az eloszlásnak fel
%      kellene tolódnia; ha támogatás/fix-vintage dominál, 3–6% körül
%      ragad.
%   2. "Csomósodás" a támogatott sávokban: a ráták hány %-a esik az NHP
%      (2,0–3,1%) és a Széchenyi MAX (4,5–5,6%) sávba évenként; és hány
%      % van érdemben a BUBOR alatt (ami piaci hitelnél nem lehetséges).
%   3. A DÖNTŐ teszt: a piaci árazásúnak tekinthető almintában (ráta >=
%      BUBOR - 200 bp, 2022–2024) megjelenik-e a besorolás szerinti
%      meredek differenciálás, ami a teljes mintában nem látszik.
%
% BUBOR: közelítő éves átlagok (MNB), letöltött idősorral pótolandó:
%   2021: 1,7% | 2022: 9,9% | 2023: 13,6% | 2024: 7,4%
%
% Kimenet:  output/tables/t12_rata_eloszlas_ev.csv
%           output/tables/t13_piaci_alminta_besorolas.csv
%           output/figures/f09_tamogatott_hitel_teszt.png
% Futtatás:  matlab -batch "cd('src'); s08_tamogatott_hitel_teszt"

repo = fileparts(pwd);
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');

opts = detectImportOptions(panel_f);
opts.SelectedVariableNames = {'ev', 'meret_kategoria', ...
    'kockazati_besorolas', 'implicit_kamatrata'};
p = readtable(panel_f, opts);
p = p(p.ev >= 2021 & p.ev <= 2024 & ~isnan(p.implicit_kamatrata), :);
p = p(ismember(string(p.meret_kategoria), ["10-49", "50-249"]), :);

evek  = [2021 2022 2023 2024];
bubor = [0.017 0.099 0.136 0.074];   % közelítő éves átlag!

% --- 1-2. éves eloszlás + csomósodás ------------------------------------
T12 = table();
for e = 1:4
    r = p.implicit_kamatrata(p.ev == evek(e));
    uj = table(evek(e), numel(r), 100*bubor(e), ...
        100*quantile(r, 0.10), 100*quantile(r, 0.25), 100*median(r), ...
        100*quantile(r, 0.75), 100*quantile(r, 0.90), ...
        100*mean(r >= 0.020 & r <= 0.031), ...
        100*mean(r >= 0.045 & r <= 0.056), ...
        100*mean(r >= bubor(e) - 0.02), ...
        'VariableNames', {'ev', 'n', 'bubor_pct', 'p10', 'p25', ...
        'median', 'p75', 'p90', 'nhp_sav_pct', 'szk_sav_pct', ...
        'piaci_arazasu_pct'});
    T12 = [T12; uj]; %#ok<AGROW>
end
writetable(T12, fullfile(repo, 'output', 'tables', 't12_rata_eloszlas_ev.csv'));
disp(T12);

% --- 3. piaci alminta besorolásonként (2022-2024) -----------------------
kateg = ["A", "B", "C", "D", "AVG"];
piaci = false(height(p), 1);
for e = 1:4
    piaci = piaci | (p.ev == evek(e) & ...
        p.implicit_kamatrata >= bubor(e) - 0.02);
end
piaci = piaci & p.ev >= 2022;   % 2021-ben a küszöb nem szűr (alacsony BUBOR)

T13 = table();
for g = 1:numel(kateg)
    mind_g  = string(p.kockazati_besorolas) == kateg(g);
    r_telj  = p.implicit_kamatrata(mind_g);
    r_piaci = p.implicit_kamatrata(mind_g & piaci);
    uj = table(kateg(g), numel(r_telj), 100*median(r_telj), ...
        numel(r_piaci), 100*median(r_piaci), ...
        'VariableNames', {'besorolas', 'n_teljes', 'median_teljes_pct', ...
        'n_piaci', 'median_piaci_pct'});
    T13 = [T13; uj]; %#ok<AGROW>
end
writetable(T13, fullfile(repo, 'output', 'tables', ...
    't13_piaci_alminta_besorolas.csv'));
disp(T13);

% --- Ábra ----------------------------------------------------------------
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];
ev_szin = [158 197 244; 85 152 231; 42 120 214; 24 79 149] / 255;
kek = [42 120 214]/255; aqua = [27 175 122]/255;

fig = figure('Visible', 'off', 'Position', [100 100 1120 430], ...
    'Color', felulet);

% bal: éves sűrűségek + BUBOR-vonalak
ax1 = subplot(1, 2, 1);
hold(ax1, 'on');
hv = gobjects(4, 1);
for e = 1:4
    r = p.implicit_kamatrata(p.ev == evek(e));
    [f, x] = ksdensity(r, 'Support', 'positive', 'BandWidth', 0.004);
    hv(e) = plot(ax1, 100*x, f/100, '-', 'Color', ev_szin(e,:), ...
        'LineWidth', 2);
    plot(ax1, [100*bubor(e) 100*bubor(e)], [0 0.32], ':', ...
        'Color', ev_szin(e,:), 'LineWidth', 1.2);
end
xlim(ax1, [0 22]); ylim(ax1, [0 0.35]);
set(ax1, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
    'YColor', masod, 'FontSize', 10);
grid(ax1, 'on'); ax1.GridColor = [0.88 0.88 0.85]; ax1.GridAlpha = 1;
ax1.XGrid = 'off';
title(ax1, 'Implicit ráta-eloszlás évenként vs. BUBOR (pontozott)', ...
    'FontSize', 10.5, 'Color', tinta);
xlabel(ax1, 'implicit kamatráta, %', 'FontSize', 9);
ylabel(ax1, 'sűrűség', 'FontSize', 9);
legend(ax1, hv, {'2021', '2022', '2023', '2024'}, 'Box', 'off', ...
    'FontSize', 9, 'Location', 'northeast');

% jobb: medián besorolásonként — teljes vs. piaci alminta
ax2 = subplot(1, 2, 2);
hold(ax2, 'on');
sav = 0.32;
b1 = bar(ax2, (1:5) - sav/2, T13.median_teljes_pct, sav*0.9, ...
    'FaceColor', aqua, 'EdgeColor', 'none');
b2 = bar(ax2, (1:5) + sav/2, T13.median_piaci_pct, sav*0.9, ...
    'FaceColor', kek, 'EdgeColor', 'none');
for g = 1:5
    text(ax2, g + sav/2, T13.median_piaci_pct(g) + 0.3, ...
        sprintf('n=%d', T13.n_piaci(g)), 'HorizontalAlignment', ...
        'center', 'FontSize', 8, 'Color', masod);
end
set(ax2, 'XTick', 1:5, 'XTickLabel', cellstr(kateg), 'Box', 'off', ...
    'Color', felulet, 'XColor', masod, 'YColor', masod, 'FontSize', 10);
grid(ax2, 'on'); ax2.GridColor = [0.88 0.88 0.85]; ax2.GridAlpha = 1;
ax2.XGrid = 'off';
title(ax2, 'Medián ráta besorolásonként — teljes vs. piaci alminta', ...
    'FontSize', 10.5, 'Color', tinta);
ylabel(ax2, '%', 'FontSize', 9);
legend(ax2, [b1 b2], {'teljes minta', 'piaci árazású (≥BUBOR−2pp, 2022–24)'}, ...
    'Box', 'off', 'FontSize', 9, 'Location', 'northwest');

annotation(fig, 'textbox', [0.01 0.005 0.98 0.08], 'String', ...
    ['KKV cég-évek (10-249 fő), 2021-2024. BUBOR: közelítő éves átlag ' ...
     '(MNB) - letöltött idősorral pótolandó. NHP-sáv: 2,0-3,1%; ' ...
     'Széchenyi MAX-sáv: 4,5-5,6%. A "piaci" küszöb a fix kamatozású ' ...
     'régi (vintage) hiteleket is kiszűri.'], ...
    'FontSize', 7.5, 'EdgeColor', 'none', 'Color', [0.54 0.53 0.51], ...
    'VerticalAlignment', 'bottom');
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f09_tamogatott_hitel_teszt.png'), 'Resolution', 200);
fprintf('Kiírva: t12, t13 + f09_tamogatott_hitel_teszt.png\n');
