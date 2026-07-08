% run_v02.m — euró-szcenáriók (alap / optimista / pesszimista) futtatása
% és a pályák exportja az output/tables/szcenario_v02.csv fájlba.
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_v02"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path)
    dynare_path = 'C:\dynare\6.5\matlab';
end
addpath(dynare_path);

szcenariok = {'alap', 'optimista', 'pesszimista'};
valtozok = {'y', 'y_S', 'y_L', 'ii', 'i_S', 'i_L', 'c', 'nn', ...
            'efp_S', 'efp_L', 'nw_S', 'nw_L', 'infl', 'r', 'rer', 'xx'};
T_ki = 40;  % 10 év
osszes = table();

for s = 1:3
    dynare('kkv_dsge_v02', ['-DSCENARIO=' num2str(s)], 'console');
    % oo_.endo_simul: nvars x (1 kezdeti + periods + 1 terminális)
    nevek = cellstr(M_.endo_names);
    blokk = table((1:T_ki)', 'VariableNames', {'negyedev'});
    blokk.szcenario = repmat(szcenariok(s), T_ki, 1);
    for v = 1:numel(valtozok)
        sor = strcmp(nevek, valtozok{v});
        palya = oo_.endo_simul(sor, 2:(T_ki+1))';
        blokk.(valtozok{v}) = palya;
    end
    % exogén prémium-pályák is
    exonevek = cellstr(M_.exo_names);
    blokk.sov  = oo_.exo_simul(2:(T_ki+1), strcmp(exonevek, 'sov'));
    blokk.bank = oo_.exo_simul(2:(T_ki+1), strcmp(exonevek, 'bank'));
    osszes = [osszes; blokk]; %#ok<AGROW>
    fprintf('Szcenario %s kesz: y(40. negyedev) = %.3f%%\n', ...
        szcenariok{s}, 100*blokk.y(end));
end

outdir = fullfile('..', '..', 'output', 'tables');
writetable(osszes, fullfile(outdir, 'szcenario_v02.csv'));
fprintf('Kiirva: %s (%d sor)\n', fullfile(outdir, 'szcenario_v02.csv'), ...
    height(osszes));
