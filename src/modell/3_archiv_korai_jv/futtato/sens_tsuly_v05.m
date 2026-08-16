% sens_tsuly_v05.m — A t_sov/t_bank SULYOK ERZEKENYSEGI SAVJA
% =====================================================================
% Kerdes: a "KKV tobbet nyer az euro-bevezetesbol" eredmeny mennyire all
% a t_sov/t_bank atgyuruzesi sulyok FELTEVESEN, es mennyire a modell
% strukturajan?
%
% Harom parameterezes:
%   TSCEN=1  FELTEVES (eredeti): t_S > t_L, a KKV erzekenyebb
%   TSCEN=2  TUKORKEP: t_S < t_L -- FIGYELEM, ez NEM "empirikus" becsles,
%            hanem a TSCEN=1 tukorkepe. A magyar kamatstatisztikan a
%            becsult t_bank_S/t_bank_L arany 0.26 es 2.75 kozott szorodik
%            (specifikaciotol fuggoen), egyetlen kulonbseg sem szignifikans
%            5%-on -> AZONOSITASI KUDARC, nem ellenkezo elojelu eredmeny.
%   TSCEN=3  EGYENLO: t_S = t_L, strukturalisan semleges (AJANLOTT ALAP)
%
% !! KET ERTELMEZESI FIGYELMEZTETES !!
% (1) A modell EXAKTUL LINEARIS a tsov/tbank parameterekben (ezek csak
%     exogen valtozok egyutthatoi, az atmeneti matrixot nem erintik), ezert
%     a TSCEN=3 minden kimenete a TSCEN=1 es 2 exakt atlaga (1e-15).
%     A TSCEN=3 tehat NEM onallo teszt, hanem szamtani keverek.
% (2) A SZEGMENS-BERUHAZAS (i_S/i_L) A MODELLBEN REALLOKACIOS MARADEK, es
%     az itt jelentett ertek a TERMINALIS STEADY STATE (oo_.steady_state).
%     Steady state-ben efp_S == efp_L (kozos rk), tehat epp ott olvassuk,
%     ahol a premium-res nulla. A hosszu tavu algebra szerint
%     d i_ss / d F = -1/chi, azaz 1/chi_S=16.7 vs 1/chi_L=50 -> a
%     chi_S>chi_L feltevés a KKV ELLEN dolgozik. Ezek az oszlopok
%     DIAGNOSZTIKAK, NEM KOZOLHETO EREDMENYEK.
%
% JAVITVA (2026-08): a felar-oszlopok korabban HIBASAK voltak. A csucs-
% idopontot a script csak az efp_S-bol valasztotta ([~,ic]=max(abs(eS))),
% es az efp_L-t is ezen a datumon olvasta. A csucs-index szcenariorol
% szcenariora valtozik (17, 21, 18), mikozben az efp_L mindig a 17.
% periodusban tetozik -> a ket oszlop KULONBOZO datumokon mert erteket
% tartalmazott, tehat soronkent nem volt osszehasonlithato (a linearitastol
% is +1.70 / -2.37 bp-tal tert el). Most: fix osszehasonlitasi datum
% (a KKV-elonyhoz) + mindket szegmens sajat csucsa kulon oszlopban.
%
% Kimenet: output/tables/t26_tsuly_teszt.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/3_archiv_korai_jv/futtato'); sens_tsuly_v05"

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

nevek_ = {'1_felteves', '2_tukorkep', '3_egyenlo'};
leiras_ = {'FELTEVES (t_S>t_L, a KKV erzekenyebb)', ...
           'TUKORKEP (t_S<t_L, NEM empirikus becsles)', ...
           'EGYENLO (t_S=t_L, semleges - ajanlott alap)'};
T = table();
IC_FIX = 17;   % fix osszehasonlitasi datum: az efp_L csucsa (lasd fejlec)

for its_ = 1:3
    dynare('jv_dsge_v05', '-DSCENARIO=1', sprintf('-DTSCEN=%d', its_), ...
        'console');
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    eS = oo_.endo_simul(strcmp(n, 'efp_S'), 2:81) * 40000;
    eL = oo_.endo_simul(strcmp(n, 'efp_L'), 2:81) * 40000;
    [pS_, icS_] = max(abs(eS));  pS_ = eS(icS_);   % sajat csucs, KKV
    [pL_, icL_] = max(abs(eL));  pL_ = eL(icL_);   % sajat csucs, nagyvall.
    uj = table(string(nevek_{its_}), string(leiras_{its_}), ...
        g('y'), ...
        eS(IC_FIX), eL(IC_FIX), eS(IC_FIX) - eL(IC_FIX), ...
        pS_, icS_, pL_, icL_, ...
        g('i_S'), g('i_L'), g('i_S') / g('i_L'), ...
        g('y_d'), g('y_x'), ...
        'VariableNames', {'eset', 'leiras', 'GDP_pct', ...
        'KKV_felar_bp_q17', 'nagyvall_felar_bp_q17', 'KKV_elony_bp_q17', ...
        'KKV_felar_csucs_bp', 'KKV_csucs_q', ...
        'nagyvall_felar_csucs_bp', 'nagyvall_csucs_q', ...
        'ss_i_S_pct_DIAG', 'ss_i_L_pct_DIAG', 'ss_beruh_arany_DIAG', ...
        'KKV_kibocsatas_pct', 'export_kibocsatas_pct'});
    T = [T; uj]; %#ok<AGROW>
end

% [a repo-t a fejlec mar beallitotta]
writetable(T, fullfile(repo, 'output', 'tables', 't26_tsuly_teszt.csv'));

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('A t-SULYOK ERZEKENYSEGI SAVJA (jv_dsge_v05, SCENARIO=1)\n');
fprintf('%s\n', repmat('=', 1, 78));
for i = 1:height(T)
    fprintf('\n%s\n', T.leiras(i));
    fprintf('  GDP (h.tav): %+.3f%%   [KOZOLHETO]\n', T.GDP_pct(i));
    if T.KKV_elony_bp_q17(i) < 0
        ki_ = sprintf('a KKV %.1f bp-tal TOBBET nyer', ...
            abs(T.KKV_elony_bp_q17(i)));
    else
        ki_ = sprintf('a NAGYVALLALAT %.1f bp-tal tobbet nyer', ...
            T.KKV_elony_bp_q17(i));
    end
    fprintf('  Felar q%d-ben: KKV %+.1f bp vs nagyvall %+.1f bp -> %s\n', ...
        IC_FIX, T.KKV_felar_bp_q17(i), T.nagyvall_felar_bp_q17(i), ki_);
    fprintf('  Sajat csucs: KKV %+.1f bp (q%d) | nagyvall %+.1f bp (q%d)\n', ...
        T.KKV_felar_csucs_bp(i), T.KKV_csucs_q(i), ...
        T.nagyvall_felar_csucs_bp(i), T.nagyvall_csucs_q(i));
    fprintf('  [DIAG, NEM KOZOLHETO] ss-beruhazas: KKV %+.2f%% vs nagyv %+.2f%%\n', ...
        T.ss_i_S_pct_DIAG(i), T.ss_i_L_pct_DIAG(i));
end

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf(['ERTELMEZES:\n' ...
    '1. A KKV-felar elonye (q%d) a t-sulyok FELTEVESEN all, nem a modell\n' ...
    '   strukturalis kovetkezmenye. A becsult arany 0.26-2.75 kozott szorodik,\n' ...
    '   egyetlen kulonbseg sem szignifikans -> AZONOSITASI KUDARC.\n' ...
    '2. A TSCEN=3 a TSCEN=1 es 2 exakt atlaga (a modell linearis a t-ben),\n' ...
    '   tehat nem fuggetlen harmadik teszt.\n' ...
    '3. A ss-beruhazasi oszlopok DIAGNOSZTIKAK: a szegmens-toke reallokacios\n' ...
    '   maradek, es a steady state-ben efp_S==efp_L. A chi_S>chi_L a hosszu\n' ...
    '   tavon a KKV ELLEN dolgozik (1/chi_S=16.7 vs 1/chi_L=50).\n' ...
    '   ==> SZEGMENS-SZINTU BERUHAZAST EBBOL A MODELLBOL NE KOZOLJ.\n'], IC_FIX);
fprintf('%s\n', repmat('=', 1, 78));
