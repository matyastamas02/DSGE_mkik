% run_jv_v04.m — a vertikális KKV->exportőr átgyűrűzés IRF-exportja
% Egy a KKV-t érő pénzügyi prémium sokkra (eps_pr) megmutatja, hogy a
% beszállítói láncon át az EXPORTŐR is reagál (h_dx, y_x).
% Kimenet: output/tables/t20_jv_v04_vertikalis.csv
% Futtatás: matlab -batch "cd('<repo>/src/model'); run_jv_v04"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

dynare jv_dsge_v04 console
irf = oo_.irfs;
H = options_.irf;

valt = {'y','y_d','y_x','i_S','i_L','efp_S','efp_L','h_dx','xx','mcx_rel'};
sokk = {'eps_x','eps_r'};   % export-kereslet (vertikális link); monetáris
T = table((1:H)', 'VariableNames', {'negyedev'});
for s = 1:numel(sokk)
    for v = 1:numel(valt)
        nev = [valt{v} '_' sokk{s}];
        if isfield(irf, nev)
            T.([valt{v} '_' sokk{s}]) = irf.(nev)';
        end
    end
end
repo = fileparts(fileparts(pwd));
writetable(T, fullfile(repo, 'output', 'tables', 't20_jv_v04_vertikalis.csv'));
fprintf('Kiirva: t20_jv_v04_vertikalis.csv\n');
