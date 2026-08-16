% stress_v06.m — robusztussagi teszt: BK/konvergencia minden SCENARIO x
% TSCEN x NOVERT kombinacioban, hogy ne egy szerencses esetre alapozzunk.
% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

addpath('C:\dynare\6.5\matlab');
kombo = {};
for sc_ = 1:3
    for ts_ = 1:3
        for nv_ = 0:1
            kombo{end+1} = sprintf('-DSCENARIO=%d -DTSCEN=%d -DNOVERT=%d', sc_, ts_, nv_); %#ok<SAGROW>
        end
    end
end
eredmeny = {};
for i_ = 1:numel(kombo)
    args_ = strsplit(kombo{i_}, ' ');
    try
        dynare('jv_dsge_v06', args_{:}, 'console', 'nograph');
        n = cellstr(M_.endo_names);
        g = @(v) 100 * oo_.steady_state(strcmp(n, v));
        ok_ = oo_.deterministic_simulation.status;
        eredmeny{i_} = sprintf('%-40s OK=%d  y=%+.3f%%  efp_S-efp_L=%.4fpp', ...
            kombo{i_}, ok_, g('y'), g('efp_S')-g('efp_L')); %#ok<SAGROW>
    catch ME
        eredmeny{i_} = sprintf('%-40s HIBA: %s', kombo{i_}, ME.message); %#ok<SAGROW>
    end
end
fprintf('\n%s\n', repmat('=', 1, 90));
fprintf('V06 ROBUSZTUSSAGI TESZT: 18 kombinacio (3 SCENARIO x 3 TSCEN x 2 NOVERT)\n');
fprintf('%s\n', repmat('=', 1, 90));
for i_ = 1:numel(eredmeny)
    fprintf('%s\n', eredmeny{i_});
end
