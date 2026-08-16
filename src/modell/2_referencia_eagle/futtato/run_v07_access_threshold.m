% run_v07_access_threshold.m — access-kuszob kereses a v07 modellhez
%
% Cel: megtalalni azt az ACCSCALE szintet, ahol a KKV-hatas eleri vagy
% meghaladja a nagyvallalati hatast semleges premium-transzmisszio mellett.
%
% Futtatas:
%   matlab -batch "cd('<mappa>'); run_v07_access_threshold"

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

model_file = 'kkv_dsge_v07_access.mod';
model_text = fileread(model_file);
if ~contains(model_text, 'ACCSCALE')
    error(['A kkv_dsge_v07_access.mod regi verzio: nincs benne ACCSCALE. ' ...
        'Masold felul a MATLAB Drive-ban a friss mod fajllal.']);
end

scales = 0:10:150;
sy_E = 0.18; sy_D = 0.37; sy_L = 0.45;
kkv_weight = sy_E + sy_D;

valt = {'y','y_E','y_D','y_L','i_E','i_D','i_L', ...
    'efp_E','efp_D','efp_L','acc_E','acc_D','bstar'};
ht = table();

for j = 1:numel(scales)
    dynare('kkv_dsge_v07_access', '-DSCENARIO=1', '-DTSCEN=3', ...
        sprintf('-DACCSCALE=%d', scales(j)), 'console');
    endo = cellstr(M_.endo_names);
    sor = table(scales(j), 'VariableNames', {'ACCSCALE'});
    for v = 1:numel(valt)
        ix = strcmp(endo, valt{v});
        sor.(valt{v}) = oo_.steady_state(ix);
    end
    sor.y_KKV = (sy_E*sor.y_E + sy_D*sor.y_D) / kkv_weight;
    sor.D_minus_L = sor.y_D - sor.y_L;
    sor.E_minus_L = sor.y_E - sor.y_L;
    sor.KKV_minus_L = sor.y_KKV - sor.y_L;
    ht = [ht; sor]; %#ok<AGROW>
    fprintf(['ACCSCALE=%3d | y=%+.3f%% | E=%+.3f%% D=%+.3f%% ' ...
        'KKV=%+.3f%% L=%+.3f%% | D-L=%+.3f pp KKV-L=%+.3f pp\n'], ...
        scales(j), 100*sor.y, 100*sor.y_E, 100*sor.y_D, 100*sor.y_KKV, ...
        100*sor.y_L, 100*sor.D_minus_L, 100*sor.KKV_minus_L);
end

thr_D = first_threshold(ht.ACCSCALE, ht.D_minus_L);
thr_E = first_threshold(ht.ACCSCALE, ht.E_minus_L);
thr_KKV = first_threshold(ht.ACCSCALE, ht.KKV_minus_L);

summary = table(thr_D, thr_E, thr_KKV, ...
    'VariableNames', {'D_ge_L_ACCSCALE','E_ge_L_ACCSCALE','KKV_ge_L_ACCSCALE'});

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

writetable(ht, fullfile(tablazatok, 't32_v07_access_threshold_grid.csv'));
writetable(summary, fullfile(tablazatok, 't33_v07_access_threshold_summary.csv'));

fprintf('\\nKuszobok (linearisan interpolalva a gridpontok kozott):\\n');
fprintf('  D >= L:      ACCSCALE = %.1f\\n', thr_D);
fprintf('  E >= L:      ACCSCALE = %.1f\\n', thr_E);
fprintf('  KKV >= L:    ACCSCALE = %.1f\\n', thr_KKV);
fprintf('Kiirva: %s\\n', fullfile(tablazatok, 't32_v07_access_threshold_grid.csv'));
fprintf('Kiirva: %s\\n', fullfile(tablazatok, 't33_v07_access_threshold_summary.csv'));

function thr = first_threshold(x, gap)
    thr = NaN;
    for i = 1:numel(x)
        if gap(i) >= 0
            if i == 1
                thr = x(i);
            else
                x0 = x(i-1); x1 = x(i);
                g0 = gap(i-1); g1 = gap(i);
                thr = x0 + (0-g0)*(x1-x0)/(g1-g0);
            end
            return;
        end
    end
end
