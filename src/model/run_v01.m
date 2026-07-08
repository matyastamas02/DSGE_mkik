% run_v01.m — kkv_dsge_v01 futtatása + IRF-export
% Futtatás:
%   matlab -batch "cd('<repo>/src/model'); run_v01"
% A Dynare útvonala gépenként eltérhet — állítsd a DYNARE_PATH környezeti
% változót, vagy írd át az alapértelmezést.

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
