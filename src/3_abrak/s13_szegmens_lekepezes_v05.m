% s13_szegmens_lekepezes_v05.m — 2. réteg a SZEGMENTÁLT modellre (v05)
% =====================================================================
% Az s06 utódja. A különbség lényegi, nem csak verziószám:
%
%   s06 (régi): a DSGE egyetlen, reprezentatív vállalatot ismert, ezért a
%       KKV-hatást is UTÓLAGOS leképezéssel kellett előállítani a
%       besorolás-szegmensekre.
%   s13 (ez):  a jv_dsge_v05 már NATÍVAN szegmentált — a KKV-specifikus
%       külső finanszírozási prémium (efp_S) és a KKV-beruházás (i_S) a
%       MODELL kimenete. A leképezés szerepe ezért szűkül: már csak a
%       besorolás szerinti BELSŐ szóródást vetítjük a modell KKV-aggregátumára.
%
% Ez fontos módszertani előrelépés: a "kalibrált leképezés" réteg egyre
% kisebb részét magyarázza az eredménynek, egyre nagyobb részt a modell.
%
% Bemenet:  data/processed/opten_panel.csv
%           output/tables/t21_jv_v05_szcenariok.csv, t21_jv_v05_hosszutav.csv
% Kimenet:  output/tables/t22_szegmens_lekepezes_v05.csv
%           output/figures/f21_szegmens_lekepezes_v05.png
% Futtatás: matlab -batch "cd('<repo>/src/3_abrak'); s13_szegmens_lekepezes_v05"

repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');
palya_f = fullfile(repo, 'output', 'tables', 't21_jv_v05_szcenariok.csv');
ht_f    = fullfile(repo, 'output', 'tables', 't21_jv_v05_hosszutav.csv');

% --- 1. Opten: implicit ráta-eloszlás szegmensenként (2021-2024, KKV) ---
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

nG = numel(szegmensek);
n_g = zeros(nG,1); med_g = zeros(nG,1); q1_g = zeros(nG,1); q3_g = zeros(nG,1);
for g = 1:nG
    r = kkv.implicit_kamatrata(string(kkv.kockazati_besorolas) == szegmensek(g));
    n_g(g) = numel(r); med_g(g) = median(r);
    q1_g(g) = quantile(r, 0.25); q3_g(g) = quantile(r, 0.75);
end

% --- 2. A MODELL (v05) KKV-specifikus HITELFELÁR-hatása ----------------
% MÓDSZERTANI DÖNTÉS (diagnosztika alapján): a leképezés alapja a
% HITELFELÁR (efp), nem a teljes kamat (r + efp), és a CSÚCSHATÁS +
% 10 ÉVES pont, nem a steady state. Indoklás:
%  (a) A BGG-akcelerátor definíció szerint ÁTMENETI mechanizmus: a nettó
%      vagyon hosszú távon visszaáll, ezért a chi*tőkeáttétel tag eltűnik,
%      és a steady state-ben efp_S = efp_L (mindkettő ~-13 bp, a tsov/tbank
%      transzmisszióból). A szegmens-különbség tehát ÁTMENETI — a
%      steady state-re kötött leképezés definíció szerint 0-t adna.
%      Ellenőrzött pálya (alap szcenárió): a 13. negyedévben
%      efp_S = -100.3 bp vs. efp_L = -45.1 bp (több mint kétszeres!),
%      a 40. negyedévben -23.4 vs. -26.6 bp.
%  (b) Az 'r' az átmenet alatt a rezsimváltás miatt nagyot leng (a 13.
%      negyedévben +429 bp az árfolyam-átállás pillanata), ami elnyomná a
%      hitelfelár-jelet. A hitelkörnyezet szempontjából az efp a releváns.
palya = readtable(palya_f);
ht    = readtable(ht_f);
szcenariok = ["alap", "optimista", "pesszimista"];

agg_bp_csucs = zeros(3,1); agg_bp_10e = zeros(3,1);
nagyv_bp_csucs = zeros(3,1); nagyv_bp_10e = zeros(3,1);
for s = 1:3
    resz = palya(string(palya.szcenario) == szcenariok(s), :);
    eS = resz.efp_S * 40000;   % évesített bp
    eL = resz.efp_L * 40000;
    [~, ic] = max(abs(eS));            % a KKV-hatás csúcsa
    agg_bp_csucs(s)   = eS(ic);
    nagyv_bp_csucs(s) = eL(ic);        % ugyanabban a negyedévben
    agg_bp_10e(s)   = eS(resz.negyedev == 40);
    nagyv_bp_10e(s) = eL(resz.negyedev == 40);
    fprintf(['%-12s: KKV-felár csúcs %6.1f bp (q%d) | 10 év %6.1f bp || ' ...
        'nagyváll. csúcs %6.1f bp  => KKV-többlet: %.1f bp\n'], ...
        szcenariok(s), agg_bp_csucs(s), resz.negyedev(ic), agg_bp_10e(s), ...
        nagyv_bp_csucs(s), agg_bp_csucs(s) - nagyv_bp_csucs(s));
end

% --- 3. Leképezés: már CSAK a besoláson belüli szóródás ----------------
sorok = [];
for s = 1:3
    for g = 1:nG
        kozep = agg_bp_csucs(s) * med_g(g) / kkv_median;
        also  = agg_bp_csucs(s) * q1_g(g)  / kkv_median;
        felso = agg_bp_csucs(s) * q3_g(g)  / kkv_median;
        tizev = agg_bp_10e(s)   * med_g(g) / kkv_median;
        sorok = [sorok; {char(szcenariok(s)), char(szegmensek(g)), ...
            n_g(g), 100*med_g(g), kozep, also, felso, tizev, ...
            agg_bp_csucs(s), nagyv_bp_csucs(s)}]; %#ok<AGROW>
    end
end
T = cell2table(sorok, 'VariableNames', {'szcenario','besorolas','ceg_ev', ...
    'median_implicit_rata_pct','bp_csucs','bp_sav_also','bp_sav_felso', ...
    'bp_10ev','modell_kkv_bp_csucs','modell_nagyvallalat_bp_csucs'});
ki_t = fullfile(repo, 'output', 'tables', 't22_szegmens_lekepezes_v05.csv');
writetable(T, ki_t);
fprintf('Kiírva: %s\n', ki_t);

% --- 4. Ábra: bal = szegmensek; jobb = a modell natív aszimmetriája ----
szin = [42 120 214; 27 175 122; 237 161 0]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29]; felulet = [0.988 0.988 0.984];
fig = figure('Visible','off','Position',[100 100 1120 430],'Color',felulet);

ax1 = subplot(1,2,1); hold(ax1,'on');
bh = gobjects(3,1); sav = 0.25;
for s = 1:3
    m = string(T.szcenario) == szcenariok(s);
    ertek = -T.bp_csucs(m);
    also  = -T.bp_sav_felso(m); felso = -T.bp_sav_also(m);
    x = (1:nG) + (s-2)*sav;
    bh(s) = bar(ax1, x, ertek, sav*0.88, 'FaceColor', szin(s,:), 'EdgeColor','none');
    for g = 1:nG
        plot(ax1, [x(g) x(g)], [also(g) felso(g)], '-', 'Color', masod, 'LineWidth', 1);
    end
end
set(ax1,'XTick',1:nG,'XTickLabel',cellstr(szegmensek),'FontSize',10, ...
    'XColor',masod,'YColor',masod,'Color',felulet,'Box','off');
grid(ax1,'on'); ax1.GridColor=[0.88 0.88 0.85]; ax1.GridAlpha=1; ax1.XGrid='off';
ylabel(ax1,'kamatcsökkenés, évesített bp','FontSize',9);
title(ax1,'Besorolás szerinti szóródás (leképezés)','FontSize',10.5,'Color',tinta);
legend(bh, cellstr(szcenariok), 'Box','off','FontSize',9,'Location','northwest');

ax2 = subplot(1,2,2); hold(ax2,'on');
sav2 = 0.32;
b1 = bar(ax2,(1:3)-sav2/2, -agg_bp_csucs,  sav2*0.9,'FaceColor',szin(1,:),'EdgeColor','none');
b2 = bar(ax2,(1:3)+sav2/2, -nagyv_bp_csucs, sav2*0.9,'FaceColor',szin(2,:),'EdgeColor','none');
set(ax2,'XTick',1:3,'XTickLabel',cellstr(szcenariok),'FontSize',10, ...
    'XColor',masod,'YColor',masod,'Color',felulet,'Box','off');
grid(ax2,'on'); ax2.GridColor=[0.88 0.88 0.85]; ax2.GridAlpha=1; ax2.XGrid='off';
ylim(ax2, [0, 1.35*max([-agg_bp_csucs; -nagyv_bp_csucs])]);
ylabel(ax2,'hitelfelár-csökkenés, évesített bp','FontSize',9);
title(ax2,'MODELL-eredmény: KKV vs. nagyvállalat (csúcshatás)', ...
    'FontSize',10.5,'Color',tinta);
legend([b1 b2], {'KKV (efp\_S)','nagyvállalat (efp\_L)'}, 'Box','off', ...
    'FontSize',9,'Location','northwest','Interpreter','tex');

annotation(fig,'textbox',[0.01 0.005 0.98 0.055],'String', ...
    ['Jobb panel: a KKV/nagyvallalat HITELFELAR-differencia mar a MODELL ' ...
     'kimenete (v05 szegmentalt BGG-blokk), nem lekepezes. A BGG-akcelerator ' ...
     'atmeneti mechanizmus: a kulonbseg a csucson el (steady state-ben ' ...
     'definicio szerint elenyeszik) - ezert a csucshatasra vetitunk. Bal ' ...
     'panel: a besorolason BELULI szorodas tovabbra is kalibralt lekepezes ' ...
     '(Opten kvartilisek); a D kategoria mintaja vekony.'], ...
    'FontSize',7.5,'EdgeColor','none','Color',[0.54 0.53 0.51], ...
    'Interpreter','none','VerticalAlignment','bottom');
ki_f = fullfile(repo,'output','figures','f21_szegmens_lekepezes_v05.png');
exportgraphics(fig, ki_f, 'Resolution', 200);
fprintf('Kiírva: %s\n', ki_f);

fprintf(['\nMODSZERTANI ELORELEPES: az s06-ban a teljes KKV-hatas lekepezes\n' ...
    'volt; itt a KKV/nagyvallalat kulonbseg mar modell-eredmeny, es csak a\n' ...
    'besorolason BELULI szorodas marad kalibralt lekepezes.\n']);
