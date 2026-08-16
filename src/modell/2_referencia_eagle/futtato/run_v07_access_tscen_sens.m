% run_v07_access_tscen_sens.m — TSCEN-erzekenyseg a v07_access modellhez
%
% Cel: megmutatni, hogy a hitelhozzaferesi margoval bovített modell
% hosszu tavu szektoralis eredmenye mennyire fugg a premium-transzmisszio
% E/D/L megosztasatol.
%
% Futtatas:
%   matlab -batch "cd('<mappa>'); run_v07_access_tscen_sens"

% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if ~isempty(dynare_path) && exist(dynare_path, 'dir')
    addpath(dynare_path);
end

tscens = [1 2 3];
nevek_t = {'KKV-erosebb', 'L-erosebb', 'semleges'};
valt = {'y','y_E','y_D','y_L','x_E','x_D','x_L', ...
    'i_E','i_D','i_L','efp_E','efp_D','efp_L','acc_E','acc_D','bstar'};
ht = table();

for j = 1:numel(tscens)
    dynare('kkv_dsge_v07_access', '-DSCENARIO=1', ...
        sprintf('-DTSCEN=%d', tscens(j)), 'console');
    endo = cellstr(M_.endo_names);
    sor = table(tscens(j), nevek_t(j), 'VariableNames', {'TSCEN','leiras'});
    for v = 1:numel(valt)
        ix = strcmp(endo, valt{v});
        sor.(valt{v}) = oo_.steady_state(ix);
    end
    ht = [ht; sor]; %#ok<AGROW>
    fprintf(['TSCEN=%d (%s): y=%+.3f%% | E=%+.3f%% D=%+.3f%% L=%+.3f%% | ' ...
        'x_E=%+.3f%% x_D=%+.3f%% x_L=%+.3f%% | acc_E=%+.3f%% acc_D=%+.3f%%\n'], ...
        tscens(j), nevek_t{j}, 100*sor.y, 100*sor.y_E, 100*sor.y_D, ...
        100*sor.y_L, 100*sor.x_E, 100*sor.x_D, 100*sor.x_L, ...
        100*sor.acc_E, 100*sor.acc_D);
end

% [repo-illesztes, 2026-08-12] eredetileg fullfile(pwd,'output') -- a
% szerzo elrendezeseben a pwd a repo gyokere volt; itt a src/model. A
% MODELL ERINTETLEN.
% [a repo-t a fejlec mar beallitotta; a pwd itt mar a .mod mappaja]
output_root = fullfile(repo, 'output');
try
    if ~exist(output_root, 'dir'), mkdir(output_root); end
catch
    output_root = fullfile(tempdir, 'kkv_dsge_v07_access_output');
end
tablazatok = fullfile(output_root, 'tables');
if ~exist(tablazatok, 'dir'), mkdir(tablazatok); end

writetable(ht, fullfile(tablazatok, 't30_v07_access_tscen_sens.csv'));
fprintf('Kiirva: %s\n', fullfile(tablazatok, 't30_v07_access_tscen_sens.csv'));
