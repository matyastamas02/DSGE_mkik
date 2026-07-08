% run_v03.m — euró-szcenáriók (alap / optimista / pesszimista) futtatása
% Kimenet: output/tables/szcenario_v03.csv          (pályák, 80 negyedév)
%          output/tables/szcenario_v03_hosszutav.csv (új steady state-ek)
% Futtatás:  matlab -batch "cd('<repo>/src/model'); run_v03"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path)
    dynare_path = 'C:\dynare\6.5\matlab';
end
addpath(dynare_path);

szcenariok = {'alap', 'optimista', 'pesszimista'};
valtozok = {'y', 'y_S', 'y_L', 'ii', 'i_S', 'i_L', 'c', 'nn', ...
            'efp_S', 'efp_L', 'nw_S', 'nw_L', 'infl', 'r', 'rer', 'xx'};
T_ki = 80;  % 20 év
osszes = table();
hosszutav = table();

for s = 1:3
    dynare('kkv_dsge_v03', ['-DSCENARIO=' num2str(s)], 'console');
    nevek = cellstr(M_.endo_names);
    blokk = table((1:T_ki)', 'VariableNames', {'negyedev'});
    blokk.szcenario = repmat(szcenariok(s), T_ki, 1);
    ht = table(szcenariok(s), 'VariableNames', {'szcenario'});
    for v = 1:numel(valtozok)
        sor = strcmp(nevek, valtozok{v});
        blokk.(valtozok{v}) = oo_.endo_simul(sor, 2:(T_ki+1))';
        ht.(valtozok{v}) = oo_.steady_state(sor);
    end
    exonevek = cellstr(M_.exo_names);
    blokk.sov  = oo_.exo_simul(2:(T_ki+1), strcmp(exonevek, 'sov'));
    blokk.bank = oo_.exo_simul(2:(T_ki+1), strcmp(exonevek, 'bank'));
    osszes = [osszes; blokk];   %#ok<AGROW>
    hosszutav = [hosszutav; ht]; %#ok<AGROW>
    fprintf('Szcenario %s: y(10 ev) = %.3f%%, y(hosszu tav) = %.3f%%\n', ...
        szcenariok{s}, 100*blokk.y(40), 100*ht.y);
end

outdir = fullfile('..', '..', 'output', 'tables');
writetable(osszes, fullfile(outdir, 'szcenario_v03.csv'));
writetable(hosszutav, fullfile(outdir, 'szcenario_v03_hosszutav.csv'));
fprintf('Kiirva: szcenario_v03.csv (%d sor) + hosszutav-tabla\n', ...
    height(osszes));
