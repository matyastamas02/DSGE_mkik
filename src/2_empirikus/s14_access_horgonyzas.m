% s14_access_horgonyzas.m - A v07_access HOZZAFERESI PARAMETEREINEK
% EMPIRIKUS HORGONYZASA az Opten-panelbol
% =====================================================================
% MIERT EZ A KOVETKEZO LEPES. Samu v07_access modellje (2026-08-10) a
% projekt eddigi legjobban megalapozott iranya: a KKV-elonyt nem egy
% feltevesbol (t_S>t_L vagy chi_S>chi_L) hozza ki, hanem egy KULON
% HITELHOZZAFERESI (extenziv) margobol -- es ez az EGYETLEN aszimmetria a
% projektben, amire VAN sajat adatunk (6.7% mikro vs 41.6% kozep).
%
% A sajat doksijuk nevezi meg kovetkezo feladatkent:
%   "Meg kell becsulni vagy legalabb savosan kalibralni, hogy egy 100 bp-os
%    felarcsokkenes mekkora valtozast okoz a KKV-k hitelhozzaferesi
%    aranyaban, es ebbol mekkora beruhazasi tobblet kovetkezik."
%
% EZ EGYBEN A BOROTVAEL-PROBLEMAT IS KEZELI. A t33 kuszob szerint a
% sulyozott KKV-blokk ACCSCALE=101.0-nel elozi meg a nagyvallalatot, a
% baseline pedig ACCSCALE=100 -- azaz a kvalitativ valasz PONTOSAN a
% valasztott kalibracios pontban fordul at. Amig az ACCSCALE horgonyzatlan,
% a tanulmany nem allithatja, hogy "a KKV nyer", csak azt, hogy "a KKV akkor
% nyer, ha a hozzaferesi reakcio legalabb akkora, mint a tippunk".
%
% AZONOSITASI STRATEGIA es ANNAK KORLATAI (olvasd el, mielott hivatkozol ra)
% A panel 2021-2024 (4 ev), a BUBOR ez alatt ~1% -> ~12-13% -> vissza.
% Ket becslest futtatunk:
%   (A) SZEGMENS-EV aggregalt: hozzaferesi arany vs BUBOR. 3 szegmens x
%       4 ev = 12 pont. Nyers, de attekintheto.
%   (B) CEG-FIX HATASOS linearis valoszinusegi modell BUBOR x szegmens
%       interakciokkal. A SZINT-egyutthato itt is konfundalt (a BUBOR
%       kozos minden cegre, tehat barmi mas idoben valtozo hatassal
%       keveredik: COVID-kilabalas, haboru, NHP/Szechenyi indulas-kifutas).
%       DE az INTERAKCIO (mennyivel erosebben reagal a KKV, mint a
%       nagyvallalat) egy diff-in-diff jellegu kontraszt, es EZ az, amit a
%       modell tenylegesen igenyel (lambda_acc_E, lambda_acc_D > 0,
%       a nagyvallalatnak nincs access-margoja).
% ==> A SZINT-becslest NEM kozoljuk okozati hataskent; a KULONBSEG a
%     vedheto objektum. Ez ugyanaz a fegyelem, amit a t_S/t_L tesztnel
%     megtanultunk (docs/FIGYELMEZTETES_fo_allitas.md).
%
% Kimenet: output/tables/t36_access_horgonyzas.csv
%          output/tables/t37_access_szegmens_evek.csv
%          output/figures/f26_access_horgonyzas.png
% Futtatas: matlab -batch "cd('<repo>/src/2_empirikus'); s14_access_horgonyzas"
%   (MATLAB-script: 's' elotag, mert a szammal kezdodo nev nem ervenyes
%    MATLAB-azonosito -- a repo 01-10 szamu scriptjei Pythonban vannak)

repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');
assert(exist(panel_f, 'file') == 2, 'Hianyzik: %s', panel_f);

fprintf('Panel betoltese...\n');
o = detectImportOptions(panel_f, 'VariableNamingRule', 'preserve');
kell = {'opten_id', 'ev', 'van_hitel', 'meret_kategoria', 'exportor', ...
    'implicit_kamatrata', 'beruhazasok_felujitasok', 'targyi_eszkozok', ...
    'letszam'};
o.SelectedVariableNames = kell;
P = readtable(panel_f, o);
fprintf('  %d sor betoltve\n', height(P));

% --- szegmensek: E = export-KKV, D = hazai KKV, L = nagyvallalat ---------
% A meret_kategoria "250+" a nagyvallalat; a KKV a 10-49 es 50-249.
% (A mikrocegek <10 fo NINCSENEK a panelben -- ez a horgonyzas egyik
%  korlatja, mert a Szechenyi Kartya ott koncentraltabb.)
meret = string(P.meret_kategoria);
nagy  = meret == "250+";
kkv   = meret == "10-49" | meret == "50-249";
% FIGYELEM: a panelben a van_hitel es az exportor SZOVEGES "True"/"False"
% cella, NEM szam. A str2double() ezekre NaN-t ad, amitol minden szegmens
% urese/nullava valna -- ezt a diagnosztika fogta el.
exportal = strcmpi(string(P.exportor), "True");

P.szegmens = strings(height(P), 1);
P.szegmens(kkv &  exportal) = "E_export_KKV";
P.szegmens(kkv & ~exportal) = "D_hazai_KKV";
P.szegmens(nagy)            = "L_nagyvallalat";

% van_hitel -> 0/1 (szoveges "True"/"False", lasd fent)
P.hozzafer = double(strcmpi(string(P.van_hitel), "True"));

evek_mind = P.ev;
if ~isnumeric(evek_mind), evek_mind = str2double(string(evek_mind)); end
P.ev = evek_mind;

% ervenyes minta: 2021-2024, besorolt szegmens, ertelmes hozzaferes
ok = ismember(P.ev, 2021:2024) & P.szegmens ~= "" & ~isnan(P.hozzafer);
P = P(ok, :);
fprintf('  ervenyes minta: %d ceg-ev, %d ceg\n', height(P), ...
    numel(unique(P.opten_id)));

% --- BUBOR eves atlagok --------------------------------------------------
evek = (2021:2024)';
addpath(fullfile(repo, 'src'));
try
    bub = bubor_evatlag(evek);
    bub_forras = 'MNB BUBOR-fixing (data/raw/makro/bubor_tortenet.xls)';
catch ME
    error(['BUBOR nem olvashato (%s). A horgonyzas kamatsor nelkul ' ...
        'ertelmetlen -- ne helyettesitsd talalt ertekkel.'], ME.message);
end
fprintf('\nBUBOR eves atlag: ');
fprintf('%d=%.2f%%  ', [evek'; 100*bub']);
fprintf('\n');

% --- (A) szegmens-ev aggregalt hozzaferesi aranyok ------------------------
szg = ["E_export_KKV"; "D_hazai_KKV"; "L_nagyvallalat"];
A = table();
for i = 1:numel(szg)
    for j = 1:numel(evek)
        m = P.szegmens == szg(i) & P.ev == evek(j);
        A = [A; table(szg(i), evek(j), sum(m), 100*mean(P.hozzafer(m)), ...
            100*bub(j), 'VariableNames', {'szegmens', 'ev', 'n', ...
            'hozzaferes_pct', 'bubor_pct'})]; %#ok<AGROW>
    end
end
writetable(A, fullfile(repo, 'output', 'tables', ...
    't37_access_szegmens_evek.csv'));

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('(A) HOZZAFERESI ARANY SZEGMENSENKENT ES EVENKENT\n');
fprintf('%s\n', repmat('=', 1, 78));
fprintf('%-16s', 'szegmens');
fprintf('%10d', evek); fprintf('   BUBOR-valtozasra\n');
for i = 1:numel(szg)
    s = A(A.szegmens == szg(i), :);
    fprintf('%-16s', szg(i));
    fprintf('%9.1f%%', s.hozzaferes_pct);
    % nyers szemi-elaszticitas: pp valtozas / 100bp BUBOR-valtozas
    b = [ones(numel(evek),1), s.bubor_pct] \ s.hozzaferes_pct;
    fprintf('   %+6.2f pp / 100bp\n', b(2));
    A.szemi_elaszt_pp_100bp(A.szegmens == szg(i)) = b(2);
end

% --- (B) ceg-fix hatasos LPM, BUBOR x szegmens interakcioval --------------
% hozzafer_it = alpha_i + b1*BUBOR_t + b2*(BUBOR_t x E_i) + b3*(BUBOR_t x D_i) + e
% A referencia a nagyvallalat (L). b2, b3 = mennyivel EROSEBBEN reagal a
% KKV-hozzaferes ugyanarra a kamatvaltozasra. EZ a vedheto objektum.
fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('(B) CEG-FIX HATASOS LPM: BUBOR x SZEGMENS INTERAKCIO\n');
fprintf('%s\n', repmat('=', 1, 78));

[uid, ~, gidx] = unique(P.opten_id);
bub_i = zeros(height(P), 1);
for j = 1:numel(evek), bub_i(P.ev == evek(j)) = 100*bub(j); end
isE = double(P.szegmens == "E_export_KKV");
isD = double(P.szegmens == "D_hazai_KKV");

% ceg-fix hatas: within-transzformacio (kivonjuk a ceg-atlagot)
X = [bub_i, bub_i.*isE, bub_i.*isD];
y = P.hozzafer;
% within-transzformacio accumarray-jel (a splitapply matrixon egyenetlen
% csoportmeretek mellett vertcat-hibat dob)
nobs_g = accumarray(gidx, 1);
Xbar = zeros(numel(uid), size(X,2));
for k = 1:size(X,2), Xbar(:,k) = accumarray(gidx, X(:,k)) ./ nobs_g; end
ybar = accumarray(gidx, y) ./ nobs_g;
Xw = X - Xbar(gidx, :);
yw = y - ybar(gidx);
bhat = Xw \ yw;
res = yw - Xw*bhat;
dof = height(P) - numel(uid) - size(X,2);
% klaszterezett (ceg szintu) standard hiba
% (vektorizalva: a ceg-szintu ciklus 40e cegen x 150e soron nem futna le
%  ertelmes idon belul; a klaszter-osszegek accumarray-jel kepezhetok)
XtXinv = inv(Xw'*Xw);
XU = Xw .* res;
S = zeros(numel(uid), size(X,2));
for k = 1:size(X,2), S(:,k) = accumarray(gidx, XU(:,k)); end
meat = S' * S;
V = XtXinv * meat * XtXinv * (numel(uid)/(numel(uid)-1));
se = sqrt(diag(V));

nev = {'BUBOR (szint, KONFUNDALT)', 'BUBOR x export-KKV', 'BUBOR x hazai-KKV'};
fprintf('%-30s %10s %10s %8s\n', 'valtozo', 'egyutth.', 'klaszt.SE', 't');
for k = 1:3
    fprintf('%-30s %+9.4f %10.4f %+8.2f\n', nev{k}, 100*bhat(k), ...
        100*se(k), bhat(k)/se(k));
end
fprintf('(egyutthatok: szazalekpont hozzaferes-valtozas / 100 bp BUBOR)\n');
fprintf('n = %d ceg-ev, %d ceg, dof = %d\n', height(P), numel(uid), dof);

% --- (C) beruhazasi atvitel: omega_acc horgonyzasa ------------------------
% Mennyivel magasabb a beruhazasi rata a hitelhez juto cegeknel, ceg-fix
% hatas mellett? (within-ceg: amikor egy ceg hitelhez jut, mennyivel no a
% beruhazasa) -- ez adja, hogy a hozzaferes mennyire fordul beruhazasba.
ber = P.beruhazasok_felujitasok; te = P.targyi_eszkozok;
if ~isnumeric(ber), ber = str2double(string(ber)); end
if ~isnumeric(te),  te  = str2double(string(te));  end
rate = ber ./ te;
jo = isfinite(rate) & te > 0 & rate >= 0 & rate < 2;   % szelsoertek-vagas
fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('(C) BERUHAZASI ATVITEL (omega_acc horgony)\n');
fprintf('%s\n', repmat('=', 1, 78));
Bt = table();
for i = 1:numel(szg)
    m = jo & P.szegmens == szg(i);
    [u2, ~, g2] = unique(P.opten_id(m));
    a = P.hozzafer(m); r = rate(m);
    n2 = accumarray(g2, 1);
    abar = accumarray(g2, a) ./ n2;
    rbar = accumarray(g2, r) ./ n2;
    aw = a - abar(g2);
    rw = r - rbar(g2);
    if sum(abs(aw)) < 1e-9
        b2 = NaN;
    else
        b2 = (aw'*rw) / (aw'*aw);
    end
    fprintf('%-16s  within-ceg beruhazasi rata elteres hitel mellett: %+.4f (n=%d ceg)\n', ...
        szg(i), b2, numel(u2));
    Bt = [Bt; table(szg(i), b2, numel(u2), ...
        'VariableNames', {'szegmens', 'beruh_atvitel', 'n_ceg'})]; %#ok<AGROW>
end

% --- (D) modell-egysegre valtas ------------------------------------------
% A modellben: acc = rho_acc*acc(-1) - lambda_acc*efp,  efp NEGYEDEVES
% decimalis (efp = -0.0025 <=> -100 bp/ev). Hosszu tavon:
%   acc_LR = -lambda_acc/(1-rho_acc) * efp
% Az empirikus objektum: d(hozzaferesi arany, pp) / d(100 bp/ev).
% A modell acc-ja LOG-ELTERES, ezert a pp-valtozast a szegmens ATLAGOS
% hozzaferesi aranyahoz kell viszonyitani: acc_LR ~ d_pp / atlag_pct.
rho_acc = 0.85;   % Samu kalibracioja (v07_access); ha valtozik, ide is
fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('(D) ATVALTAS MODELL-EGYSEGRE (rho_acc = %.2f)\n', rho_acc);
fprintf('%s\n', repmat('=', 1, 78));
K = table();
for i = 1:2   % csak E es D -- L-nek nincs access-margoja a modellben
    s = A(A.szegmens == szg(i), :);
    atl = mean(s.hozzaferes_pct);
    if i == 1, d_pp = 100*(bhat(1) + bhat(2)); else, d_pp = 100*(bhat(1) + bhat(3)); end
    d_pp_diff = 100*bhat(i+1);            % csak a KKV-tobblet (vedheto)
    acc_LR      = (d_pp      / atl);      % relativ valtozas 100 bp-ra
    acc_LR_diff = (d_pp_diff / atl);
    lam_teljes  = -acc_LR      * (1-rho_acc) / 0.0025;
    lam_diff    = -acc_LR_diff * (1-rho_acc) / 0.0025;
    fprintf(['%-16s atlag hozzaferes %.1f%% | teljes: %+.2f pp/100bp -> ' ...
        'lambda %+.2f | KKV-TOBBLET: %+.2f pp/100bp -> lambda %+.2f\n'], ...
        szg(i), atl, d_pp, lam_teljes, d_pp_diff, lam_diff);
    K = [K; table(szg(i), atl, d_pp, lam_teljes, d_pp_diff, lam_diff, ...
        'VariableNames', {'szegmens', 'atlag_hozzaferes_pct', ...
        'teljes_pp_100bp', 'lambda_teljes', 'tobblet_pp_100bp', ...
        'lambda_tobblet'})]; %#ok<AGROW>
end

K.rho_acc(:) = rho_acc;
K.bubor_forras(:) = string(bub_forras);
writetable(K, fullfile(repo, 'output', 'tables', 't36_access_horgonyzas.csv'));

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf(['OSSZEVETES Samu baseline-javal (lambda_acc_E = 2.0, ' ...
    'lambda_acc_D = 2.5 @ ACCSCALE=100):\n']);
for i = 1:height(K)
    ref = [2.0, 2.5];
    fprintf('  %-16s becsult lambda (KKV-tobblet) %+.2f  vs  baseline %.1f  ->  ACCSCALE ~ %.0f\n', ...
        K.szegmens(i), K.lambda_tobblet(i), ref(i), ...
        100*K.lambda_tobblet(i)/ref(i));
end

% --- ABRA: a fo bizonyitek ------------------------------------------------
kek=[42 120 214]/255; aqua=[27 175 122]/255; sarga=[237 161 0]/255;
piros=[199 62 45]/255; tinta=[.04 .04 .04]; masod=[.32 .31 .29];
felulet=[.988 .988 .984];
fig = figure('Visible','off','Position',[50 50 1080 460],'Color',felulet);
ax = axes('Position',[0.070 0.20 0.545 0.68]); hold(ax,'on');
szin = {kek, aqua, sarga};
hh = gobjects(3,1);
for i = 1:3
    s = A(A.szegmens == szg(i), :);
    hh(i) = plot(ax, s.ev, s.hozzaferes_pct, '-o', 'Color', szin{i}, ...
        'LineWidth', 2.2, 'MarkerFaceColor', szin{i}, 'MarkerSize', 5);
end
set(ax,'Box','off','Color',felulet,'XColor',masod,'YColor',masod, ...
    'FontSize',10,'XTick',evek,'Layer','top');
grid(ax,'on'); ax.GridColor=[.9 .9 .87]; ax.GridAlpha=1; ax.XGrid='off';
ylabel(ax,'hitelhez juto cegek aranya (%)','FontSize',9);
yyaxis(ax,'right');
hb = plot(ax, evek, 100*bub, '--s', 'Color', piros, 'LineWidth', 2, ...
    'MarkerFaceColor', piros, 'MarkerSize', 5);
ax.YAxis(2).Color = piros;
ylabel(ax,'BUBOR eves atlag (%)','FontSize',9);
ylim(ax,[0 16]);
legend(ax, [hh; hb], {'export-KKV (E)','hazai KKV (D)','nagyvallalat (L)', ...
    'BUBOR (jobb tengely)'}, 'Box','off','FontSize',8.5, ...
    'Position',[0.725 0.58 0.25 0.20]);
title(ax, ['A hozzaferes gyakorlatilag NEM mozdul, ' ...
    'mikozben a BUBOR 12,8 pontot ugrik'], 'FontSize',11,'Color',tinta);

txt = {sprintf('BUBOR-savszelesseg:  %.1f pp', max(100*bub)-min(100*bub)), ...
       sprintf('E hozzaferes-sav:    %.1f pp', ...
         max(A.hozzaferes_pct(A.szegmens==szg(1)))-min(A.hozzaferes_pct(A.szegmens==szg(1)))), ...
       sprintf('D hozzaferes-sav:    %.1f pp', ...
         max(A.hozzaferes_pct(A.szegmens==szg(2)))-min(A.hozzaferes_pct(A.szegmens==szg(2)))), ...
       sprintf('L hozzaferes-sav:    %.1f pp', ...
         max(A.hozzaferes_pct(A.szegmens==szg(3)))-min(A.hozzaferes_pct(A.szegmens==szg(3))))};
annotation(fig,'textbox',[0.725 0.26 0.25 0.26],'String',txt, ...
    'FontSize',9,'EdgeColor',[.85 .83 .79],'BackgroundColor',[.97 .96 .94], ...
    'Color',tinta,'Interpreter','none','FitBoxToText','off', ...
    'VerticalAlignment','top');
annotation(fig,'textbox',[0.02 0.005 0.96 0.10],'String', ...
    ['A D-szegmens hozzaferese MONOTON NO a kamatcsucs fele (4.5% -> 5.1%): ' ...
     'a tamogatott programok epp akkor bovultek, amikor a piaci kamat ' ...
     'tetozott. Ezert a piaci kamat varianciaja NEM azonositja a piaci ' ...
     'kamatra vett hozzaferesi rugalmassagot.'], ...
    'FontSize',8,'EdgeColor','none','Color',[.5 .49 .47], ...
    'Interpreter','none','VerticalAlignment','bottom','FitBoxToText','off');
exportgraphics(fig, fullfile(repo,'output','figures', ...
    'f26_access_horgonyzas.png'), 'Resolution', 180);

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('VERDIKT — NEM SIKERULT HORGONYOZNI, ES EZ MAGA IS EREDMENY\n');
fprintf('%s\n', repmat('=', 1, 78));
fprintf(['A BUBOR 2021-2024 kozott %.1f pontot mozgott (%.1f%% -> %.1f%% -> %.1f%%),\n' ...
    'a hozzaferesi aranyok viszont 1 pontnal kevesebbet:\n'], ...
    max(100*bub)-min(100*bub), 100*bub(1), 100*bub(3), 100*bub(4));
for i = 1:3
    s = A(A.szegmens == szg(i), :);
    fprintf('  %-16s %.1f%% -> %.1f%%  (savszelesseg %.1f pp)\n', szg(i), ...
        s.hozzaferes_pct(1), s.hozzaferes_pct(end), ...
        max(s.hozzaferes_pct)-min(s.hozzaferes_pct));
end
fprintf(['\nKET OLVASAT, es a masodik a valoszinubb:\n' ...
    '(A) A hozzaferes valoban erzeketlen a kamatra -> az access-csatorna nem\n' ...
    '    tudja hozni, amit a modell igenyel (ACCSCALE ~ 0-16 a szukseges 101\n' ...
    '    helyett), tehat a v07 fo eredmenye nem all.\n' ...
    '(B) A 2021-24-es magyar epizod NEM AZONOSITJA ezt: a tamogatott programok\n' ...
    '    epp akkor bovultek, amikor a piaci kamat tetozott -- a D-szegmens\n' ...
    '    hozzaferese MONOTON NO a kamatcsucs fele. Amit merunk, az a\n' ...
    '    POLITIKAVAL STABILIZALT hozzaferes, nem a piaci reakcio.\n' ...
    '\nEZ UGYANAZ A BETEGSEG, ami a t_S/t_L tesztet is ervenytelenitette: a\n' ...
    'magyar KKV-hitelpiac ebben az idoszakban programvezerelt volt, ezert a\n' ...
    'PIACI kamat varianciaja nem azonositja a PIACI kamatra vett rugalmassagot.\n' ...
    '\nKOVETKEZMENY A MODELLRE: az ACCSCALE ebbol az adatbol NEM horgonyozhato.\n' ...
    'A v07 eredmenyet tovabbra is KUSZOBKENT kell kozolni ("a KKV akkor nyer,\n' ...
    'ha a hozzaferesi reakcio eleri X-et"), es a kuszob melle oda kell irni,\n' ...
    'hogy X-et jelenleg NEM tudjuk magyar adatbol megmondani.\n' ...
    '\nAMIT VISZONT MEGERGSIT: ha a programok tartjak a KKV-hozzaferest a\n' ...
    'kamatciklus ellenere, akkor a relevans kerdes nem az, hogy az euro\n' ...
    'mennyivel viszi lejjebb a piaci kamatot, hanem hogy MI TORTENIK A\n' ...
    'PROGRAMOK KIFUTASAKOR -- azaz a tamogatas-kivezetesi irany.\n']);
fprintf('%s\n', repmat('=', 1, 78));
fprintf(['KORLATOK (a tablaban is szerepelnek):\n' ...
    '- 4 ev, aggregalt kamatvaltozas -> a SZINT-egyutthato konfundalt\n' ...
    '  (COVID-kilabalas, haboru, NHP/Szechenyi indulas es kifutas).\n' ...
    '  A vedheto objektum a KKV-TOBBLET (interakcio), nem a szint.\n' ...
    '- A mikrocegek (<10 fo) NINCSENEK a panelben, pedig ott koncentraltabb\n' ...
    '  a Szechenyi Kartya -> a hozzaferesi reakcio valoszinuleg ALULBECSULT.\n' ...
    '- A BUBOR nem azonos a vallalati felarral; a modell efp-je felar, nem\n' ...
    '  alapkamat. Az atvaltas ezt 1:1-nek veszi -- ez FELSO korlat jellegu.\n']);
