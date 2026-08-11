% sens_chi_psi_v06.m — MI HAJTJA a nagyvallalati beruhazasi elonyt a v06-ban?
% =====================================================================
% A v06 megoldotta, hogy a szegmens-toke reallokacios maradek volt, es hogy
% efp_S == efp_L a steady state-ben. DE a fo eredmeny NEM fordult meg: a
% KKV nagyobb felar-csokkenest kap (-4.54 vs -3.53 bp), megis KEVESEBBET
% fektet be. Most, hogy a termeles is szegmentalt, ez mar NEM mutermek --
% valodi modell-eredmeny, tehat meg kell erteni, MELYIK kalibracios
% valasztasunk hajtja.
%
% Harom jelolt, mindharom a MI valasztasunk (egyik sem becsult):
%   (1) chi_S=0.06 > chi_L=0.02   -- BGG-erzekenyseg. Zart formula:
%       d i_ss/d F = -1/chi, azaz 1/chi_S=16.7 vs 1/chi_L=50 -> a
%       nagyvallalati beruhazas 3x erzekenyebb UGYANARRA a premium-
%       csokkenesre (a v05-ben feltart (B) problema).
%   (2) psi_i_S=8.0 < psi_i_L=13.0 -- beruhazasi kiigazitasi koltseg.
%   (3) zeta_S=0.17 vs zeta_L=0.14 -- tokehanyad. A v06-ban UJ csatorna:
%       eddig a termelesi oldal nem tudott a szegmensrol.
%
% !! MODSZERTANI TANULSAG (ez a script elso valtozatanak hibaja volt) !!
% A psi_i a STEADY STATE-et EGYALTALAN NEM erinti: a beruhazasi Euler-
% egyenletben a q/psi tag steady state-ben kiesik (q_S=q_L=0). Az elso
% valtozat ezert azonos szamokat adott a psi-esetekre, es ezt eloszor
% script-hibanak neztem -- pedig valodi tulajdonsag. A psi hatasat ezert
% a CSUCSON es a 10 EVES erteken merjuk, nem a hosszu tavon. Kovetkezmeny
% a korabbi aggodalomra: a "psi_i a KKV javara torzit" allitas a HOSSZU
% TAVU szamokra NEM all, csak az atmenetre.
%
% Minden eset TSCEN=3-mal (egyenlo t-sulyok) fut, hogy a t-felteves ne
% keveredjen bele -- ami marad, az tisztan a strukturalis kalibracio.
% Minden eset TELJES, tiszta Dynare-megoldas (-D macrok), nem utolagos
% parameter-feluliras egy mar megoldott modellen.
%
% Kimenet: output/tables/t35_sens_chi_psi_v06.csv
% Futtatas: matlab -batch "cd('<repo>/src/model'); sens_chi_psi_v06"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

%            nev                                     chiS  chiL  psiS  psiL  zetaS  zetaL
esetek = {
    'alap (chi 6/2, psi 8/13, zeta .17/.14)',        0.06, 0.02,  8.0, 13.0, 0.17,  0.14
    'chi SZIMMETRIKUS (4/4)',                        0.04, 0.04,  8.0, 13.0, 0.17,  0.14
    'chi FORDITVA (2/6)',                            0.02, 0.06,  8.0, 13.0, 0.17,  0.14
    'psi SZIMMETRIKUS (10.5/10.5)',                  0.06, 0.02, 10.5, 10.5, 0.17,  0.14
    'psi HELYESEN (13/8: KKV rugalmatlanabb)',       0.06, 0.02, 13.0,  8.0, 0.17,  0.14
    'zeta SZIMMETRIKUS (.155/.155)',                 0.06, 0.02,  8.0, 13.0, 0.155, 0.155
    'MINDEN SZIMMETRIKUS',                           0.04, 0.04, 10.5, 10.5, 0.155, 0.155
};

T = table();
for ie_ = 1:size(esetek, 1)
    dynare('jv_dsge_v06', '-DSCENARIO=1', '-DTSCEN=3', ...
        sprintf('-DCHIS=%g',  esetek{ie_, 2}), ...
        sprintf('-DCHIL=%g',  esetek{ie_, 3}), ...
        sprintf('-DPSIS=%g',  esetek{ie_, 4}), ...
        sprintf('-DPSIL=%g',  esetek{ie_, 5}), ...
        sprintf('-DZETAS=%g', esetek{ie_, 6}), ...
        sprintf('-DZETAL=%g', esetek{ie_, 7}), 'console');
    ok_ = oo_.deterministic_simulation.status;
    n = cellstr(M_.endo_names);
    g  = @(v) 100 * oo_.steady_state(strcmp(n, v));
    pa = @(v) 100 * oo_.endo_simul(strcmp(n, v), 2:81);
    iS_ = pa('i_S'); iL_ = pa('i_L');
    [~, cS_] = max(abs(iS_)); [~, cL_] = max(abs(iL_));
    uj = table(string(esetek{ie_, 1}), ok_, ...
        esetek{ie_, 2}, esetek{ie_, 3}, esetek{ie_, 4}, esetek{ie_, 5}, ...
        g('y'), g('i_S'), g('i_L'), g('i_S') - g('i_L'), ...
        iS_(cS_), iL_(cL_), iS_(40), iL_(40), iS_(40) - iL_(40), ...
        'VariableNames', {'eset', 'konvergalt', ...
        'chi_S', 'chi_L', 'psi_i_S', 'psi_i_L', ...
        'GDP_pct', 'ss_i_S_pct', 'ss_i_L_pct', 'ss_KKV_elony_pp', ...
        'csucs_i_S_pct', 'csucs_i_L_pct', ...
        'ev10_i_S_pct', 'ev10_i_L_pct', 'ev10_KKV_elony_pp'});
    T = [T; uj]; %#ok<AGROW>
end

repo = fileparts(fileparts(pwd));
writetable(T, fullfile(repo, 'output', 'tables', 't35_sens_chi_psi_v06.csv'));

fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('MI HAJTJA A NAGYVALLALATI BERUHAZASI ELONYT? (v06, SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 100));
fprintf('%-42s %8s %8s %11s %11s\n', 'eset', 'ss i_S', 'ss i_L', ...
    'ss KKV-el.', '10ev KKV-el.');
fprintf('%s\n', repmat('-', 1, 100));
for i = 1:height(T)
    if T.konvergalt(i) ~= 1
        fprintf('%-42s  *** NEM KONVERGALT, szamok nem kozolhetok ***\n', T.eset(i));
        continue
    end
    if T.ss_KKV_elony_pp(i) > 0, jel_ = ' <== KKV NYER'; else, jel_ = ''; end
    fprintf('%-42s %+7.3f%% %+7.3f%% %+8.3f pp %+8.3f pp%s\n', ...
        T.eset(i), T.ss_i_S_pct(i), T.ss_i_L_pct(i), ...
        T.ss_KKV_elony_pp(i), T.ev10_KKV_elony_pp(i), jel_);
end
fprintf('%s\n', repmat('=', 1, 100));
fprintf(['ERTELMEZES:\n' ...
    '- A psi_i a HOSSZU TAVOT nem erinti (q=0 a steady state-ben), csak az\n' ...
    '  atmenetet -- ezert szerepel a 10 eves oszlop is.\n' ...
    '- Ha a chi szimmetrizalasa/forditasa fordit a sorrenden, akkor a\n' ...
    '  nagyvallalati elony a chi-VALASZTASUNK kovetkezmenye, nem a\n' ...
    '  szegmentalt termelesi szerkezet allitasa.\n']);
