% sens_skkv_v05.m — ÉRZÉKENYSÉGI PROTOKOLL a vertikális link erősségére
% =====================================================================
% Kérdés (a hétfői meeting legvárhatóbb kritikája): "honnan tudod, hogy a
% vertikális beszállítói link tényleg számít, és nem csak egy dísz a
% modellben?"
%
% Módszer: az s_kkv paramétert (a KKV-input költséghányada az exportban)
% 0-tól 0.35-ig végigmérjük, és megnézzük, hogyan változnak a fő
% eredmények. Az s_kkv=0 a "link nélküli" ellenpróba (a mennyiségi
% csatornát is kikapcsoljuk mu_vert=0-val, hogy tiszta legyen a teszt).
%
% Amit mérünk minden s_kkv-nál:
%   - GDP hosszú távú hatás (a link aggregált hozzájárulása)
%   - KKV és nagyvállalati hitelfelár-csúcs (a szegmens-aszimmetria)
%   - a KKV-input (h_dx) csúcsa (maga a csatorna erőssége)
%   - reálárfolyam (plauzibilitás-ellenőrzés: nem szalad-e el)
%
% Kimenet: output/tables/t23_sens_skkv.csv
% Futtatás: matlab -batch "cd('<repo>/src/modell/3_archiv_korai_jv/futtato'); sens_skkv_v05"

% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

% FIGYELEM: a ciklusváltozók nevei szándékosan aláhúzás-végűek — a Dynare a
% modell paramétereit (sc, si, sg, sx, sm, k, ...) a base workspace-be tölti,
% és egy 'sc' nevű ciklusváltozó ütközne velük.
% Az ÉRVÉNYES SÁV s_kkv < 0.25 (a modellnek szingularitása van ~0.25-nél,
% lásd a jv_dsge_v05.mod fejlécét). Ezen belül sűrűbben mérünk, és a
% pólus két oldalát is megmutatjuk figyelmeztetésként.
s_ertekek_ = [0 0.05 0.10 0.15 0.20 0.24 0.26];   % 0.20 = alapkalibráció
szcenariok_ = {'alap', 'optimista', 'pesszimista'};
T = table();

for isc_ = 1:3
    for ik_ = 1:numel(s_ertekek_)
        sk = s_ertekek_(ik_);
        % s_kkv=0 esetén a mennyiségi csatornát is kikapcsoljuk (tiszta
        % ellenpróba); egyébként a mu_vert az alapértéken marad
        if sk == 0
            mv = 0;
        else
            mv = 0.50;
        end
        dynare('jv_dsge_v05', sprintf('-DSCENARIO=%d', isc_), ...
            sprintf('-DSKKV=%g', sk), sprintf('-DMUVERT=%g', mv), 'console');
        n = cellstr(M_.endo_names);
        gv = @(v) oo_.steady_state(strcmp(n, v));
        % pálya a csúcshatás kereséséhez (80 negyedév)
        eS = oo_.endo_simul(strcmp(n,'efp_S'), 2:81) * 40000;
        eL = oo_.endo_simul(strcmp(n,'efp_L'), 2:81) * 40000;
        hd = oo_.endo_simul(strcmp(n,'h_dx'),  2:81) * 100;
        [~, ic] = max(abs(eS));
        uj = table(string(szcenariok_{isc_}), sk, mv, ...
            100*gv('y'), 100*gv('y_d'), 100*gv('y_x'), 100*gv('rer'), ...
            100*gv('i_S'), 100*gv('i_L'), ...
            eS(ic), eL(ic), eS(ic)-eL(ic), max(abs(hd)), ...
            'VariableNames', {'szcenario','s_kkv','mu_vert', ...
            'y_pct','y_d_pct','y_x_pct','rer_pct','i_S_pct','i_L_pct', ...
            'efp_S_csucs_bp','efp_L_csucs_bp','kkv_tobblet_bp','h_dx_csucs_pct'});
        T = [T; uj]; %#ok<AGROW>
    end
end

% [a repo-t a fejlec mar beallitotta]
writetable(T, fullfile(repo,'output','tables','t23_sens_skkv.csv'));

% --- konzol-összefoglaló: az ALAP szcenárió a döntő ---
A = T(T.szcenario == "alap", :);
fprintf('\n===== ALAP SZCENÁRIÓ: az s_kkv hatása =====\n');
fprintf('%-7s %8s %8s %10s %10s %10s %9s\n', 's_kkv','y(%)','rer(%)', ...
    'efpS(bp)','efpL(bp)','KKVtöbb.','h_dx(%)');
for i = 1:height(A)
    fprintf('%-7.2f %8.3f %8.2f %10.1f %10.1f %10.1f %9.2f\n', ...
        A.s_kkv(i), A.y_pct(i), A.rer_pct(i), A.efp_S_csucs_bp(i), ...
        A.efp_L_csucs_bp(i), A.kkv_tobblet_bp(i), A.h_dx_csucs_pct(i));
end

% a link hozzájárulása: s_kkv=0.20 vs s_kkv=0
y0 = A.y_pct(A.s_kkv == 0); y20 = A.y_pct(A.s_kkv == 0.20);
fprintf(['\nA VERTIKÁLIS LINK HOZZÁJÁRULÁSA (alap szcenárió):\n' ...
    '  link nélkül (s_kkv=0):    GDP %+.3f%%\n' ...
    '  alapkalibrációval (0.20): GDP %+.3f%%\n' ...
    '  => a link hozzájárulása:  %+.3f%% (a teljes hatás %.0f%%-a)\n'], ...
    y0, y20, y20-y0, 100*(y20-y0)/y20);

% monotonitás / érvényességi sáv ellenőrzés
fprintf(['\nÉRVÉNYESSÉGI SÁV ELLENŐRZÉSE (a modellnek szingularitása van\n' ...
    's_kkv ~ 0.25-nél; a pólus alatt sima és monoton, felette nem értelmes):\n']);
ervenyes = A.s_kkv < 0.25;
fprintf('  s_kkv < 0.25 (érvényes):  GDP %+.3f%% ... %+.3f%%  — monoton: %s\n', ...
    min(A.y_pct(ervenyes)), max(A.y_pct(ervenyes)), ...
    string(all(diff(A.y_pct(ervenyes)) > 0)));
if any(~ervenyes)
    fprintf(['  s_kkv >= 0.25 (POLUSON TULI, nem ertelmezheto): GDP %+.3f%%\n' ...
        '     -> ezt az erteket NEM szabad eredmenykent kozolni!\n'], ...
        A.y_pct(~ervenyes));
end

fprintf(['\nSKALAZODAS az ervenyes savon (a link hozzajarulasa 0.01 s_kkv-ra):\n']);
for i = 2:height(A)
    if A.s_kkv(i) < 0.25
        fprintf('  s_kkv=%.2f: GDP-tobblet %+.3f%%  (%.3f%% / 0.01 s_kkv)\n', ...
            A.s_kkv(i), A.y_pct(i)-y0, (A.y_pct(i)-y0)/(A.s_kkv(i)*100));
    end
end
fprintf(['\nOLVASAT: a hozzajarulas NEM linearis - gyorsul, ahogy kozeledunk\n' ...
    'a poluhoz. A BIZTONSAGOS sav ezert szukebb, mint a formalisan ervenyes:\n' ...
    '  s_kkv <= 0.20 : sima, monoton, plauzibilis felar-ertekek (-37..-44 bp)\n' ...
    '  s_kkv ~ 0.24  : formalisan meg konvergal, de a felar +501 bp-ra ugrik\n' ...
    '                  -> POLUS-KOZELI, nem hasznalhato\n' ...
    '  s_kkv >= 0.25 : poluson tul, ertelmezhetetlen\n' ...
    'Ezert a KSH IO-tabla ellenorzese PRIORITAS: ha a valodi KKV-input\n' ...
    'arany 0.20 felett van, a modellt at kell strukturalni (pl. explicit\n' ...
    'CES-input-aggregatorral, ami nem hoz be poluhoz vezeto hurkot).\n']);

% --- ábra: az érvényes sáv + a pólus ---
A2 = A(A.s_kkv <= 0.20, :);
kek = [42 120 214]/255; aqua = [27 175 122]/255; gap = [164 69 47]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29]; felulet = [0.988 0.988 0.984];
fig = figure('Visible','off','Position',[80 80 1080 420],'Color',felulet);

ax1 = subplot(1,2,1); hold(ax1,'on');
plot(ax1, A2.s_kkv, A2.y_pct, '-o', 'Color', kek, 'LineWidth', 2.2, ...
    'MarkerFaceColor', kek, 'MarkerSize', 5);
yline(ax1, y0, '--', 'Color', masod, 'LineWidth', 1);
xline(ax1, 0.20, ':', 'Color', kek, 'LineWidth', 1.2);
text(ax1, 0.005, y0+0.012, 'link nélkül (s\_kkv = 0)', 'FontSize', 8.5, ...
    'Color', masod, 'Interpreter', 'tex');
text(ax1, 0.148, min(A2.y_pct)+0.03, 'alapkalibráció', 'FontSize', 8.5, ...
    'Color', kek);
set(ax1,'Box','off','Color',felulet,'XColor',masod,'YColor',masod,'FontSize',10);
grid(ax1,'on'); ax1.GridColor=[0.9 0.9 0.87]; ax1.GridAlpha=1; ax1.XGrid='off';
xlabel(ax1,'s\_kkv (KKV-input aránya az export költségében)','FontSize',9, ...
    'Interpreter','tex');
ylabel(ax1,'GDP-hatás, % (hosszú táv)','FontSize',9);
title(ax1,'A vertikális link hozzájárulása','FontSize',10.5,'Color',tinta);

ax2 = subplot(1,2,2); hold(ax2,'on');
h1 = plot(ax2, A2.s_kkv, -A2.efp_S_csucs_bp, '-o', 'Color', kek, ...
    'LineWidth', 2.2, 'MarkerFaceColor', kek, 'MarkerSize', 5);
h2 = plot(ax2, A2.s_kkv, -A2.efp_L_csucs_bp, '-s', 'Color', aqua, ...
    'LineWidth', 2, 'MarkerFaceColor', aqua, 'MarkerSize', 5);
set(ax2,'Box','off','Color',felulet,'XColor',masod,'YColor',masod,'FontSize',10);
grid(ax2,'on'); ax2.GridColor=[0.9 0.9 0.87]; ax2.GridAlpha=1; ax2.XGrid='off';
xlabel(ax2,'s\_kkv','FontSize',9,'Interpreter','tex');
ylabel(ax2,'hitelfelár-csökkenés a csúcson, bp','FontSize',9);
title(ax2,'A szegmens-aszimmetria stabil a sávban','FontSize',10.5,'Color',tinta);
legend([h1 h2], {'KKV','nagyvállalat'}, 'Box','off','FontSize',9, ...
    'Location','northwest');

annotation(fig,'textbox',[0.01 0.005 0.98 0.05],'String', ...
    ['Csak az ERVENYES sav (s_kkv <= 0.20) van abrazolva. A modellnek ' ...
     'szingularitasa van s_kkv ~ 0.25-nel (0.24-nel a felar mar +501 bp-ra ' ...
     'ugrik, 0.26-nal a GDP -4.2%), ezert a polus-kozeli ertekek nem ' ...
     'kozolhetok. A KSH IO-tabla ellenorzese prioritas.'], ...
    'FontSize',7.5,'EdgeColor','none','Color',[0.54 0.53 0.51], ...
    'Interpreter','none','VerticalAlignment','bottom');
exportgraphics(fig, fullfile(repo,'output','figures','f22_sens_skkv.png'), ...
    'Resolution', 200);
fprintf('\nKiirva: t23_sens_skkv.csv + f22_sens_skkv.png\n');
