% s07_extenziv_margo.m — 3. blokk: a hitelhez jutás (extenzív margó)
% =====================================================================
% "Van-e egyáltalán banki hitele a cégnek?" — probit a 2021–2024-es
% cég-év panelen. Ez a fő üzenet második, a DSGE-től FÜGGETLEN lába:
% a C–D/AVG szegmens nem (csak) drágábban hitelez, hanem nem jut hitelhez.
%
% Két specifikáció:
%   M1 (leíró): van_hitel ~ besorolás + méret + ágazat + régió + év-FE
%       -> kiigazított hozzáférési valószínűségek besorolásonként
%   M2 (kamatkörnyezet): év-FE helyett az évi medián implicit ráta
%       -> szuggesztív rugalmasság: mit tenne a kamatszint-csökkenés a
%       hozzáféréssel. FIGYELEM: az azonosítás gyenge (4 évnyi aggregát
%       variáció, minden más évhatással összemosódva) — illusztratív,
%       a tanulmányban érzékenységként kezelendő, nem oksági becslésként.
%
% Bemenet:  data/processed/opten_panel.csv
% Kimenet:  output/tables/t10_extenziv_margo_m1.csv (M1 együtthatók)
%           output/tables/t11_hozzaferes_kiigazitott.csv
%           output/figures/f08_extenziv_margo.png
%
% Futtatás:  matlab -batch "cd('src'); s07_extenziv_margo"
% (Nincs 'clear' az elején — a run_all láncban a hívó munkaterét törölné.)

repo = fileparts(pwd);
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');

opts = detectImportOptions(panel_f);
opts.SelectedVariableNames = {'ev', 'meret_kategoria', ...
    'kockazati_besorolas', 'van_hitel', 'agazat_betu', 'nuts2', ...
    'letszam', 'implicit_kamatrata', 'exportor'};
p = readtable(panel_f, opts);
p = p(p.ev >= 2021 & p.ev <= 2024, :);
p = p(~ismissing(p.kockazati_besorolas) & ~ismissing(p.meret_kategoria) ...
      & ~ismissing(p.nuts2) & p.letszam > 0, :);

y = strcmpi(string(p.van_hitel), "true") | string(p.van_hitel) == "1";
bes = categorical(string(p.kockazati_besorolas), ...
    ["A", "B", "C", "D", "AVG"]);        % A a referencia
mer = categorical(string(p.meret_kategoria), ["10-49", "50-249", "250+"]);
aga = categorical(string(p.agazat_betu));
reg = categorical(string(p.nuts2));
evc = categorical(p.ev);
lnl = log(p.letszam);
expr = strcmpi(string(p.exportor), "true") | string(p.exportor) == "1";

% évi medián implicit ráta (kamatkörnyezet, M2-höz)
evek = unique(p.ev);
ev_rata = zeros(size(p.ev));
for e = 1:numel(evek)
    m = p.ev == evek(e);
    ev_rata(m) = median(p.implicit_kamatrata(m), 'omitnan');
end

T1 = table(y, bes, mer, aga, reg, evc, lnl, expr);
fprintf('Becslési minta: %d cég-év, hitellel: %.1f%%\n', height(T1), 100*mean(y));

% --- M1: leíró probit, év fix hatásokkal -------------------------------
m1 = fitglm(T1, 'y ~ bes + mer + aga + reg + evc + lnl + expr', ...
    'Distribution', 'binomial', 'Link', 'probit');
ki1 = m1.Coefficients;
ki1.Properties.RowNames = m1.CoefficientNames;
writetable(ki1, fullfile(repo, 'output', 'tables', ...
    't10_extenziv_margo_m1.csv'), 'WriteRowNames', true);

% kiigazított (átlagos előrejelzett) hozzáférés besorolásonként:
% mindenkit az adott besorolásba "helyezünk", a többi jellemző marad
kateg = ["A", "B", "C", "D", "AVG"];
kiig = zeros(numel(kateg), 1);
Tc = T1;
for g = 1:numel(kateg)
    Tc.bes = repmat(categorical(kateg(g), ["A","B","C","D","AVG"]), ...
        height(Tc), 1);
    kiig(g) = mean(predict(m1, Tc));
end
nyers = arrayfun(@(g) mean(y(bes == kateg(g))), 1:numel(kateg))';

% --- M2: kamatkörnyezet-rugalmasság (illusztratív!) --------------------
T2 = table(y, bes, mer, aga, reg, lnl, expr, ev_rata);
m2 = fitglm(T2, 'y ~ bes + mer + aga + reg + lnl + expr + ev_rata', ...
    'Distribution', 'binomial', 'Link', 'probit');
b_rata = m2.Coefficients{'ev_rata', 'Estimate'};
% átlagos marginális hatás -100 bp-ra (= -0.01 a rátában)
xb = predict(m2, T2);            % p-k
% AME numerikusan: ráta -100 bp mindenkinek
T2m = T2; T2m.ev_rata = T2.ev_rata - 0.01;
ame_100bp = mean(predict(m2, T2m) - xb);
fprintf(['M2: évi medián ráta együttható = %.2f; -100 bp -> ' ...
    '+%.2f százalékpont hozzáférés (AME, illusztratív)\n'], ...
    b_rata, 100*ame_100bp);

% FIGYELEM: az M2 együtthatója POZITÍV (magasabb rátakörnyezet ~ több
% hitelezés) — a 2021–24-es aggregát variáció a konjunktúrával összemosódik,
% az azonosítás nem működik. Ezért a kamatrugalmasság SZCENÁRIÓ-ALKALMAZÁSA
% itt tudatosan KIMARAD: a rugalmasságot jobb azonosítással (keresztmetszeti
% kitettség-design) vagy irodalmi értékkel kell pótolni. -> nyitott feladat.
if b_rata > 0
    fprintf(['FIGYELEM: M2 elojele pozitiv -> konjunktura-torzitas, ' ...
        'a ratahatas nem alkalmazhato szcenariora.\n']);
end

KI = table(kateg', nyers*100, kiig*100, ...
    'VariableNames', {'besorolas', 'nyers_hozzaferes_pct', ...
    'kiigazitott_hozzaferes_pct'});
writetable(KI, fullfile(repo, 'output', 'tables', ...
    't11_hozzaferes_kiigazitott.csv'));
disp(KI);

% --- Ábra: kiigazított hozzáférés + alappálya-változás -----------------
kek = [42 120 214]/255; aqua = [27 175 122]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];
fig = figure('Visible', 'off', 'Position', [100 100 1040 420], ...
    'Color', felulet);

ax1 = subplot(1, 2, 1);
hold(ax1, 'on');
b1 = bar(ax1, 1:5, KI.kiigazitott_hozzaferes_pct, 0.6, ...
    'FaceColor', kek, 'EdgeColor', 'none');
for g = 1:5
    text(ax1, g, KI.kiigazitott_hozzaferes_pct(g) + 0.5, ...
        sprintf('%.1f%%', KI.kiigazitott_hozzaferes_pct(g)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', tinta);
end
set(ax1, 'XTick', 1:5, 'XTickLabel', cellstr(kateg), 'Box', 'off', ...
    'Color', felulet, 'XColor', masod, 'YColor', masod, 'FontSize', 10);
ylim(ax1, [0, max(KI.kiigazitott_hozzaferes_pct)*1.25]);
grid(ax1, 'on'); ax1.GridColor = [0.88 0.88 0.85]; ax1.GridAlpha = 1;
ax1.XGrid = 'off';
title(ax1, 'Kiigazított hitelhozzáférés (M1 probit)', 'FontSize', 10.5, ...
    'Color', tinta);
ylabel(ax1, '% (méret, ágazat, régió, év kiszűrve)', 'FontSize', 9);

ax2 = subplot(1, 2, 2);
hold(ax2, 'on');
sav = 0.32;
b2a = bar(ax2, (1:5) - sav/2, KI.nyers_hozzaferes_pct, sav*0.9, ...
    'FaceColor', aqua, 'EdgeColor', 'none');
b2b = bar(ax2, (1:5) + sav/2, KI.kiigazitott_hozzaferes_pct, sav*0.9, ...
    'FaceColor', kek, 'EdgeColor', 'none');
set(ax2, 'XTick', 1:5, 'XTickLabel', cellstr(kateg), 'Box', 'off', ...
    'Color', felulet, 'XColor', masod, 'YColor', masod, 'FontSize', 10);
grid(ax2, 'on'); ax2.GridColor = [0.88 0.88 0.85]; ax2.GridAlpha = 1;
ax2.XGrid = 'off';
title(ax2, 'Nyers vs. kiigazított — az összetétel-hatás', ...
    'FontSize', 10.5, 'Color', tinta);
ylabel(ax2, '%', 'FontSize', 9);
legend(ax2, [b2a b2b], {'nyers', 'kiigazított'}, 'Box', 'off', ...
    'FontSize', 9, 'Location', 'northeast');

annotation(fig, 'textbox', [0.01 0.005 0.98 0.09], 'String', ...
    ['M1: probit, 2021-2024, ~148e cég-év. A nyers A-C szakadék nagyját ' ...
     'az összetétel magyarázza. M2 (kamatrugalmasság) azonosítása ' ...
     'konjunktúra-torzított - szcenárió-alkalmazása nyitott feladat.'], ...
    'FontSize', 7.5, 'EdgeColor', 'none', 'Color', [0.54 0.53 0.51], ...
    'VerticalAlignment', 'bottom');
exportgraphics(fig, fullfile(repo, 'output', 'figures', ...
    'f08_extenziv_margo.png'), 'Resolution', 200);
fprintf('Kiírva: t10, t11 + f08_extenziv_margo.png\n');
