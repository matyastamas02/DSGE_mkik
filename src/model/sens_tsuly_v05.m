% sens_tsuly_v05.m — A PROJEKT FO ALLITASANAK EMPIRIKUS TESZTJE
% =====================================================================
% Kerdes: a "KKV tobbet nyer az euro-bevezetesbol" eredmeny mennyire all
% a t_sov/t_bank atgyuruzesi sulyok FELTEVESEN, es mennyire az adaton?
%
% Harom parameterezes:
%   TSCEN=1  FELTEVES  (eredeti): t_S > t_L, a KKV erzekenyebb
%   TSCEN=2  EMPIRIKUS: t_S < t_L, a magyar kamatstatisztika szerint
%            (08_mnb_transzmisszio.py: bankkozi -> KKV 0.299 vs
%             nagyvallalat 0.652; allampapir -> 0.206 vs 0.800)
%   TSCEN=3  EGYENLO: t_S = t_L, a legsemlegesebb feltevés
%
% Kimenet: output/tables/t26_tsuly_teszt.csv
% Futtatas: matlab -batch "cd('<repo>/src/model'); sens_tsuly_v05"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

nevek_ = {'1_felteves', '2_empirikus', '3_egyenlo'};
leiras_ = {'FELTEVES (t_S>t_L, a KKV erzekenyebb)', ...
           'EMPIRIKUS (t_S<t_L, az adat szerint)', ...
           'EGYENLO (t_S=t_L, semleges)'};
T = table();

for its_ = 1:3
    dynare('jv_dsge_v05', '-DSCENARIO=1', sprintf('-DTSCEN=%d', its_), ...
        'console');
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    eS = oo_.endo_simul(strcmp(n, 'efp_S'), 2:81) * 40000;
    eL = oo_.endo_simul(strcmp(n, 'efp_L'), 2:81) * 40000;
    [~, ic] = max(abs(eS));
    uj = table(string(nevek_{its_}), string(leiras_{its_}), ...
        g('y'), eS(ic), eL(ic), eS(ic) - eL(ic), ...
        g('i_S'), g('i_L'), g('i_S') / g('i_L'), ...
        g('y_d'), g('y_x'), ...
        'VariableNames', {'eset', 'leiras', 'GDP_pct', ...
        'KKV_felar_bp', 'nagyvall_felar_bp', 'KKV_elony_bp', ...
        'KKV_beruhazas_pct', 'nagyvall_beruhazas_pct', 'beruhazas_arany', ...
        'KKV_kibocsatas_pct', 'export_kibocsatas_pct'});
    T = [T; uj]; %#ok<AGROW>
end

repo = fileparts(fileparts(pwd));
writetable(T, fullfile(repo, 'output', 'tables', 't26_tsuly_teszt.csv'));

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('A PROJEKT FO ALLITASANAK TESZTJE: nyer-e a KKV tobbet?\n');
fprintf('%s\n', repmat('=', 1, 78));
for i = 1:height(T)
    fprintf('\n%s\n', T.leiras(i));
    fprintf('  GDP: %+.3f%% | KKV-felar %+.1f bp vs nagyvall %+.1f bp\n', ...
        T.GDP_pct(i), T.KKV_felar_bp(i), T.nagyvall_felar_bp(i));
    fprintf('  Beruhazas: KKV %+.2f%% vs nagyvallalat %+.2f%%\n', ...
        T.KKV_beruhazas_pct(i), T.nagyvall_beruhazas_pct(i));
    if T.KKV_beruhazas_pct(i) > T.nagyvall_beruhazas_pct(i)
        fprintf('  ==> A KKV NYER TOBBET (a projekt allitasa TELJESUL)\n');
    else
        fprintf('  ==> A NAGYVALLALAT NYER TOBBET (az allitas NEM teljesul!)\n');
    end
end

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf(['KOVETKEZTETES: a "KKV tobbet nyer" eredmeny KIZAROLAG a t_S>t_L\n' ...
    'felteveson all. Az empirikus sulyokkal MEGFORDUL, es meg az EGYENLO\n' ...
    'sulyokkal is a nagyvallalat nyer. A BGG-akcelerator (chi_S>chi_L)\n' ...
    'onmagaban NEM eleg a KKV-elony letrehozasahoz.\n']);
fprintf('%s\n', repmat('=', 1, 78));
