% run_v01.m — kkv_dsge_v01 futtatása + IRF-export
% Futtatás:
%   matlab -batch "cd('<repo>/src/modell/2_referencia_eagle/futtato'); run_v01"
% A Dynare útvonala gépenként eltérhet — állítsd a DYNARE_PATH környezeti
% változót, vagy írd át az alapértelmezést.

% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path)
    dynare_path = 'C:\dynare\6.5\matlab';
end
addpath(dynare_path);

dynare kkv_dsge_v01 console

% IRF-ek exportja csv-be (output/tables/irf_v01.csv)
irfnames = fieldnames(oo_.irfs);
T = table((1:options_.irf)', 'VariableNames', {'negyedev'});
for i = 1:numel(irfnames)
    T.(irfnames{i}) = oo_.irfs.(irfnames{i})';
end
outdir = fullfile('..', '..', 'output', 'tables');
writetable(T, fullfile(outdir, 'irf_v01.csv'));
fprintf('IRF-ek kiirva: %s (%d valtozo, %d negyedev)\n', ...
    fullfile(outdir, 'irf_v01.csv'), numel(irfnames), options_.irf);
