% check_v06_ss.m — gyors ellenorzes: megszunt-e az efp_S==efp_L patologia
% a szegmens-specifikus rk_S/rk_L bevezetese utan (v06)?
% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

addpath('C:\dynare\6.5\matlab');
dynare('jv_dsge_v06', '-DSCENARIO=1', '-DTSCEN=3', 'console');
n = cellstr(M_.endo_names);
g = @(v) 100 * oo_.steady_state(strcmp(n, v));
fprintf('\n%s\n', repmat('=', 1, 70));
fprintf('V06 TERMINALIS STEADY STATE (SCENARIO=1, TSCEN=3 egyenlo sulyok)\n');
fprintf('%s\n', repmat('=', 1, 70));
fprintf('rk_S  = %+.4f%%   rk_L  = %+.4f%%   (kulonbseg: %.4f pp)\n', g('rk_S'), g('rk_L'), g('rk_S')-g('rk_L'));
fprintf('efp_S = %+.4f%%   efp_L = %+.4f%%   (kulonbseg: %.4f pp)\n', g('efp_S'), g('efp_L'), g('efp_S')-g('efp_L'));
fprintf('i_S   = %+.4f%%   i_L   = %+.4f%%\n', g('i_S'), g('i_L'));
fprintf('k_S   = %+.4f%%   k_L   = %+.4f%%\n', g('k_S'), g('k_L'));
fprintf('mc_S  = %+.4f%%   mc_L_rel = %+.4f%%\n', g('mc_S'), g('mc_L_rel'));
fprintf('y (aggregalt GDP) = %+.4f%%\n', g('y'));
if abs(g('efp_S') - g('efp_L')) > 1e-6
    fprintf('\n==> efp_S != efp_L: A HOSSZU TAVU PATOLOGIA MEGSZUNT.\n');
else
    fprintf('\n==> efp_S == efp_L MEG MINDIG: a fix nem oldotta meg.\n');
end
