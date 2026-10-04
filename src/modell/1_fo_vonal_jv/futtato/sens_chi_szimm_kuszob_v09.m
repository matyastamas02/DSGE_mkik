% sens_chi_szimm_kuszob_v09.m — A KKV-KUSZOB SZIMMETRIKUS chi MELLETT
% =====================================================================
% Kerdes (workshop-review, 2026-10-03, 3. pont): a KKV-L kuszob
% (t48b) az alapag teljes parameterezese mellett mert ertek, es az alapag
% a VISSZAVONT 3x-os chi-aszimmetriat futtatja (chi = 0.06/0.06/0.02,
% V04, alapertelmezes-konfliktus K01). Mennyit mozdul a kuszob, ha a chi
% szimmetrikus? Es letezik-e egyaltalan kuszob?
%
% Modszer: pontosan a stress_opten_v09.m (3) reszenek racsa es
% interpolacioja (ACCSCALE-rács, SC=1, TSCEN=3, KKV-L elojelvaltas
% linearis interpolacioval), plusz BK-ellenorzes a kuszobpontban.
% Az uj -DCHISYM=<x> kapcsolo mindharom tipus chi-jet x-re allitja; nelkule
% a modell bitre az alapag.
%
% Agak: OPTEN = 0 (atvett indulo, rho_acc = 0.85) es OPTEN = 1 (Opten ALAP,
% rho_acc = 0.9673), mindegyikre:
%   - ASZIMM: kapcsolo nelkul (kontroll: vissza kell adnia a t48b-t)
%   - chi = 0.02 / 0.04 / 0.06 szimmetrikusan. A 0.04 a SYM-teszt
%     erteke (es kb. a meretsulyozott atlag, 0.042); a 0.02 es 0.06 a
%     jelenlegi ket szelso ertek. Az irodalmi sav 0.042-0.067 (F04).
%
% ⚠ Ez ERZEKENYSEGI meres, nem uj kalibracio: a chi tovabbra is
% horgonyzatlan, az alapertelmezes cserje csapatdontes.
%
% Kimenet: output/tables/t58_chi_szimm_kuszob.csv (racs)
%          output/tables/t58b_chi_szimm_kuszob_osszegzes.csv (kuszobok)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); sens_chi_szimm_kuszob_v09"
% Kell hozza: Dynare (DYNARE_PATH vagy C:\dynare\6.5\matlab).

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));

% ⚠ A Dynare a base workspace-be irja a modell parametereit azonos nevu
% valtozokent; a ciklusvaltozok neve ezert nem utkozhet parameternevvel.
racs_acc = [0:2:20, 25:5:50, 60:20:140];      % = stress_opten_v09 (3)
agak_chi = [-1 0.02 0.04 0.06];                % -1 = ASZIMM (kapcsolo nelkul)
agak_op  = [0 1];

G = table();
for iop = agak_op
    for ichi = agak_chi
        fprintf('\n--- OPTEN=%d, chi=%s ---\n', iop, chinev_(ichi));
        for iacc = racs_acc
            G = [G; fut_(iop, ichi, iacc)]; %#ok<AGROW>
        end
    end
end
writetable(G, fullfile(repo, 'output', 'tables', 't58_chi_szimm_kuszob.csv'));

% --- kuszobok + BK a kuszobpontban -------------------------------------
Ref = readtable(fullfile(repo, 'output', 'tables', 't48b_opten_kuszob_osszegzes.csv'));
O = table();
fprintf('\n%s\n', repmat('=', 1, 86));
fprintf('%-6s %-8s %12s %10s %12s %16s\n', 'OPTEN', 'chi', 'kuszob KKV-L', 'BK@kuszob', ...
    'racs BK ok', 'KKV-L @ACC=100');
fprintf('%s\n', repmat('-', 1, 86));
for iop = agak_op
    for ichi = agak_chi
        m = G.OPTEN == iop & G.chi_szimm == ichi & G.ervenyes == 1;
        Gm = sortrows(G(m, :), 'accscale');
        k = kuszob_(Gm.accscale, Gm.KKV_minus_L_pp);
        bk = NaN;
        if isfinite(k)
            rk = fut_(iop, ichi, k);
            bk = rk.ervenyes;
        end
        v100 = G.KKV_minus_L_pp(G.OPTEN == iop & G.chi_szimm == ichi & G.accscale == 100);
        nok = sum(G.OPTEN == iop & G.chi_szimm == ichi & G.ervenyes == 1);
        O = [O; table(iop, ichi, k, bk, nok, numel(racs_acc), v100, ...
            'VariableNames', {'OPTEN', 'chi_szimm', 'kuszob_KKV_L', 'bk_ok_kuszob', ...
            'racs_ervenyes', 'racs_meret', 'KKV_minus_L_pp_ACC100'})]; %#ok<AGROW>
        fprintf('%-6d %-8s %12.2f %10g %8d/%-3d %+16.3f\n', iop, chinev_(ichi), k, bk, ...
            nok, numel(racs_acc), v100);
    end
end
writetable(O, fullfile(repo, 'output', 'tables', 't58b_chi_szimm_kuszob_osszegzes.csv'));

% --- kontroll: az ASZIMM ag vissza kell adja a t48b-t ------------------
fprintf('\nKONTROLL (ASZIMM vs tarolt t48b):\n');
for iop = agak_op
    uj = O.kuszob_KKV_L(O.OPTEN == iop & O.chi_szimm == -1);
    regi = Ref.kuszob_KKV_L(Ref.OPTEN == iop);
    fprintf('  OPTEN=%d: most %.4f, t48b %.4f, elteres %.2e  %s\n', iop, uj, regi, ...
        abs(uj - regi), ternary_(abs(uj - regi) < 1e-6, 'RENDBEN', '*** ELTER ***'));
end

% =====================================================================
function R = fut_(op, chi, accscale)
args = {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DOPTEN=%d', op), ...
    sprintf('-DACCSCALE=%.10g', accscale)};
if chi > 0, args{end+1} = sprintf('-DCHISYM=%.6g', chi); end
try
    dynare('jv_dsge_v09_access', args{:}, 'console', 'nograph');
    M_  = evalin('base', 'M_');
    oo_ = evalin('base', 'oo_');
    options_ = evalin('base', 'options_');
    solver_ok_ = double(oo_.deterministic_simulation.status);
    B_ = bk_check_metrics(M_, options_, oo_);
    valid_ = double(solver_ok_ == 1 && B_.check_ok == 1 && B_.bk_ok == 1);
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    pn = cellstr(M_.param_names);
    p = @(v) M_.params(strcmp(pn, v));
    wE = p('om_E')/(p('om_E')+p('om_D'));
    wD = p('om_D')/(p('om_E')+p('om_D'));
    ykkv = wE*g('y_E') + wD*g('y_D');
    R = table(op, chi, accscale, p('chi_E'), p('chi_D'), p('chi_L'), p('rho_acc'), ...
        g('y'), g('y_E'), g('y_D'), g('y_L'), ykkv - g('y_L'), solver_ok_, ...
        B_.bk_ok, B_.n_unstable, B_.n_forward, valid_, 'VariableNames', kol_());
catch ME
    fprintf(2, '  !! HIBA (OPTEN=%d chi=%g ACC=%.10g): %s\n', op, chi, accscale, ME.message);
    R = table(op, chi, accscale, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0, ...
        NaN, NaN, NaN, 0, 'VariableNames', kol_());
end
end

function c = kol_()
c = {'OPTEN', 'chi_szimm', 'accscale', 'chi_E', 'chi_D', 'chi_L', 'rho_acc', ...
    'GDP_pct', 'y_E_pct', 'y_D_pct', 'y_L_pct', 'KKV_minus_L_pp', 'solver_ok', ...
    'bk_ok', 'n_unstable', 'n_forward', 'ervenyes'};
end

function k = kuszob_(x, d)
% = stress_opten_v09.m kuszob_: az elso negativ -> nemnegativ elojelvaltas
k = NaN;
for j = 1:numel(d)-1
    if d(j) < 0 && d(j+1) >= 0
        k = x(j) + (x(j+1)-x(j))*(0-d(j))/(d(j+1)-d(j)); return
    end
end
if ~isempty(d) && d(1) >= 0, k = 0; end
end

function s = chinev_(c)
if c < 0, s = 'ASZIMM'; else, s = sprintf('%.2f', c); end
end

function y = ternary_(c, a, b)
if c, y = a; else, y = b; end
end
