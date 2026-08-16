% stress_opten_v09.m — AZ OPTEN-KALIBRACIO HATASA A FO MODELLRE
% =====================================================================
% Az s15_opten_kalibracio.m 14 parametert szamolt ujra az Opten-panelbol
% (t46). Ez a script azt donti el, hogy MIT CSINAL EZ A MODELLEL.
%
% Negy dolgot ellenoriz:
%
% (0) REGRESSZIO. Az -DOPTEN=0 aganak PONTOSAN a korabbi eredmenyt kell
%     adnia (t44). Ez azert kell, mert a .mod-ban athelyeztuk az shl_*
%     ertekadast (korabban a -DSYM=1 shl-sora holt kod volt).
%
% (1) BK-STABILITAS az uj kalibracioval, minden SCENARIO x TSCEN mellett.
%     Kulon figyelendo az -DOPTEN=1, ahol phi_D = 0 (a D szegmens epp a
%     nem-exportalo cegeke) -> wx_D = 0. Ha ettol eltorik a modell, az
%     kiderul itt.
%
% (2) DEKOMPOZICIO. Az -DOPTEN=3 ag CSAK a rho_acc horgonyt viszi be.
%     Igy a 0->3 lepes tisztan a perzisztencia-horgony hatasa, a 3->1
%     lepes a sulyoke es a tokeattetele. Ez azert lenyeges, mert a
%     rho_acc 0.85 -> 0.9673 valtozas a hosszu tavu access-szorzot
%     1/(1-rho) reven 6.67-rol 30.6-ra emeli (4.6-szeres).
%
% (3) A KUSZOB UJRASZAMOLASA. Ha a hosszu tavu access-szorzo 4.6-szeres,
%     akkor a "mekkora ACCSCALE kell a KKV-elonyhoz" kuszobnek ARANYOSAN
%     LEJJEBB kell mennie. A kuszobforma marad (az ACCSCALE tovabbra sem
%     horgonyzott), de a KUSZOB SZINTJE valtozik.
%
% Kimenet: output/tables/t47_opten_stressz.csv
%          output/tables/t48_opten_kuszob.csv
%          output/tables/t48b_opten_kuszob_osszegzes.csv
% Futtatas: matlab -batch "cd('<repo>/src/model'); stress_opten_v09"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
repo = fileparts(fileparts(pwd));

% =====================================================================
% (0) REGRESSZIO: OPTEN=0 valtozatlan-e?
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(0) REGRESSZIO: az -DOPTEN=0 ag valtozatlan-e a t44-hez kepest?\n');
fprintf('%s\n', repmat('=', 1, 92));
T44 = readtable(fullfile(repo, 'output', 'tables', 't44_jv_access_stressz.csv'));
sor = T44(T44.SCENARIO == 1 & T44.TSCEN == 3 & T44.NOVERT == 0, :);
r0 = fut_(0, 1, 3);
elt = max(abs([r0.GDP_pct - sor.GDP_pct, r0.y_E_pct - sor.y_E_pct, ...
    r0.y_D_pct - sor.y_D_pct, r0.y_L_pct - sor.y_L_pct]));
fprintf('  t44 (tarolt):  GDP %+.4f%%  y_E %+.4f%%  y_D %+.4f%%  y_L %+.4f%%\n', ...
    sor.GDP_pct, sor.y_E_pct, sor.y_D_pct, sor.y_L_pct);
fprintf('  most (OPTEN=0):GDP %+.4f%%  y_E %+.4f%%  y_D %+.4f%%  y_L %+.4f%%\n', ...
    r0.GDP_pct, r0.y_E_pct, r0.y_D_pct, r0.y_L_pct);
fprintf('  max elteres = %.3e  -> %s\n', elt, ...
    ternary_(elt < 1e-9, 'REGRESSZIO RENDBEN', '*** REGRESSZIO ELTORT ***'));

% =====================================================================
% (1)+(2) BK-STRESSZ ES DEKOMPOZICIO
% =====================================================================
T = table();
for op_ = [0 3 1 2]
    for sc_ = 1:3
        for ts_ = 1:3
            T = [T; fut_(op_, sc_, ts_)]; %#ok<AGROW>
        end
    end
end
writetable(T, fullfile(repo, 'output', 'tables', 't47_opten_stressz.csv'));

fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(1)+(2) BK-STRESSZ ES DEKOMPOZICIO (ACCSCALE=100, NOVERT=0)\n');
fprintf('%s\n', repmat('=', 1, 92));
opnev = containers.Map({0,1,2,3}, {'0 atvett indulo', '1 Opten ALAP', ...
    '2 Opten KUSZOB25', '3 csak rho_acc'});
fprintf('%-18s %3s %3s %4s %9s %9s %9s %9s %11s\n', 'OPTEN', 'SC', 'TS', ...
    'OK', 'GDP', 'y_E', 'y_D', 'y_L', 'KKV-L');
fprintf('%s\n', repmat('-', 1, 92));
for i = 1:height(T)
    if T.konvergalt(i) ~= 1
        fprintf('%-18s %3d %3d  *** NEM KONVERGALT\n', opnev(T.OPTEN(i)), ...
            T.SCENARIO(i), T.TSCEN(i)); continue
    end
    fprintf('%-18s %3d %3d %4d %+8.3f%% %+8.3f%% %+8.3f%% %+8.3f%% %+10.3f pp\n', ...
        opnev(T.OPTEN(i)), T.SCENARIO(i), T.TSCEN(i), T.konvergalt(i), ...
        T.GDP_pct(i), T.y_E_pct(i), T.y_D_pct(i), T.y_L_pct(i), ...
        T.KKV_minus_L_pp(i));
end
fprintf('EREDMENY: %d / %d megoldodott.\n', sum(T.konvergalt == 1), height(T));

fprintf('\nAGGREGALT GDP-SAV AGANKENT (a korabbi kozolt sav: +0.27 ... +1.04%%):\n');
for op_ = [0 3 1 2]
    m = T.OPTEN == op_ & T.konvergalt == 1;
    fprintf('  %-18s  %+.3f%% ... %+.3f%%\n', opnev(op_), ...
        min(T.GDP_pct(m)), max(T.GDP_pct(m)));
end

% =====================================================================
% (3) A KUSZOB UJRASZAMOLASA
% =====================================================================
% Surubb racs alacsony ACCSCALE-en: ha a rho_acc-horgony tenyleg 4.6-szeres
% hosszu tavu szorzot ad, a kuszob a korabbi 36.3 tizedere is eshet.
scales = [0:2:20, 25:5:50, 60:20:140];
K = table();
for op_ = [0 3 1]
    for s_ = scales
        K = [K; fut_(op_, 1, 3, s_)]; %#ok<AGROW>
    end
end
writetable(K, fullfile(repo, 'output', 'tables', 't48_opten_kuszob.csv'));

Ki = table();
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(3) AZ ACCESS-KUSZOB AGANKENT (SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 92));
fprintf('%-18s %14s %14s %14s\n', 'OPTEN', 'kuszob D>=L', 'kuszob KKV>=L', ...
    'kuszob E>=L');
for op_ = [0 3 1]
    Kok = K(K.OPTEN == op_ & K.konvergalt == 1, :);
    kD = kuszob_(Kok.accscale, Kok.D_minus_L_pp);
    kK = kuszob_(Kok.accscale, Kok.KKV_minus_L_pp);
    kE = kuszob_(Kok.accscale, Kok.E_minus_L_pp);
    fprintf('%-18s %14.1f %14.1f %14.1f\n', opnev(op_), kD, kK, kE);
    Ki = [Ki; table(op_, string(opnev(op_)), kD, kK, kE, ...
        'VariableNames', {'OPTEN', 'ag', 'kuszob_D_L', 'kuszob_KKV_L', ...
        'kuszob_E_L'})]; %#ok<AGROW>
end
writetable(Ki, fullfile(repo, 'output', 'tables', ...
    't48b_opten_kuszob_osszegzes.csv'));

fprintf(['\nERTELMEZES:\n' ...
    '- A kuszobFORMA marad: az ACCSCALE tovabbra sem horgonyzott, tehat a\n' ...
    '  szektoralis allitas tovabbra is felteteles ("a KKV akkor nyer, ha...").\n' ...
    '- Ami valtozik, az a KUSZOB SZINTJE. A rho_acc empirikus horgonya\n' ...
    '  (0.85 -> 0.9673) a hosszu tavu access-szorzot 1/(1-rho) reven\n' ...
    '  %.2f-szeresere emeli, tehat ARANYOSAN kisebb ACCSCALE is eleg.\n' ...
    '- A 0->3 es a 3->1 lepes kulonbsegebol latszik, hogy ebbol mennyi a\n' ...
    '  perzisztencia-horgony es mennyi a sulyok/tokeattetel atrendezodese.\n'], ...
    (1-0.85)/(1-0.9673));
fprintf('%s\n', repmat('=', 1, 92));

% =====================================================================
% (4) rho_acc ERZEKENYSEG -- A LEGFONTOSABB ROBUSZTUSSAGI PROBA
% =====================================================================
% A hosszu tavu access-hatas 1/(1-rho_acc)-kal aranyos, ami rho -> 1
% kozeleben robban. Az empirikus horgony (0.9673) ONMAGABAN ALSO KORLAT
% (ceg-szintu perzisztencia), tehat epp abba az iranyba mutat, ahol a
% modell a legerzekenyebb. Ha nem mutatjuk meg a scant, ugyanazt a hibat
% kovetjuk el, mint a projekt eddigi hat esetében: egy parameter viszi az
% eredmenyt, es nem latszik, hogy o viszi.
rhos = [0.85 0.90 0.93 0.95 0.9673 0.98];
S = table();
for rh_ = rhos
    for s_ = scales
        S = [S; fut_(1, 1, 3, s_, rh_)]; %#ok<AGROW>
    end
end
writetable(S, fullfile(repo, 'output', 'tables', 't49_rhoacc_erzekenyseg.csv'));

fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(4) rho_acc ERZEKENYSEG (OPTEN=1, SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 92));
fprintf('%9s %12s %14s %14s %14s %14s\n', 'rho_acc', '1/(1-rho)', ...
    'GDP@ACC=100', 'kuszob D>=L', 'kuszob KKV>=L', 'kuszob E>=L');
Se = table();
for rh_ = rhos
    Sk = S(abs(S.rho_acc - rh_) < 1e-9 & S.konvergalt == 1, :);
    g100 = Sk.GDP_pct(Sk.accscale == 100);
    if isempty(g100), g100 = NaN; end
    kD = kuszob_(Sk.accscale, Sk.D_minus_L_pp);
    kK = kuszob_(Sk.accscale, Sk.KKV_minus_L_pp);
    kE = kuszob_(Sk.accscale, Sk.E_minus_L_pp);
    fprintf('%9.4f %12.1f %13.3f%% %14.1f %14.1f %14.1f\n', rh_, ...
        1/(1-rh_), g100, kD, kK, kE);
    Se = [Se; table(rh_, 1/(1-rh_), g100, kD, kK, kE, 'VariableNames', ...
        {'rho_acc','LR_szorzo','GDP_pct_ACC100','kuszob_D_L', ...
        'kuszob_KKV_L','kuszob_E_L'})]; %#ok<AGROW>
end
writetable(Se, fullfile(repo, 'output', 'tables', ...
    't49b_rhoacc_erzekenyseg_osszegzes.csv'));
fprintf(['\nEZT KELL A TANULMANYBAN KOZOLNI: nem a "kuszob = 22.3" szamot,\n' ...
    'hanem azt, hogy a kuszob a rho_acc-on MONOTON csokken, es hogy a\n' ...
    'rendelkezesre allo horgony (0.9673) ALSO KORLAT -- tehat a valodi\n' ...
    'kuszob a tablazatban lefele mutato iranyban van.\n']);
fprintf('%s\n', repmat('=', 1, 92));

% --- lokalis fuggvenyek --------------------------------------------------
function R = fut_(op, sc, ts, accscale, rhoacc)
if nargin < 4, accscale = 100; end
if nargin < 5, rhoacc = -1; end
try
    if rhoacc > 0
        dynare('jv_dsge_v09_access', sprintf('-DSCENARIO=%d', sc), ...
            sprintf('-DTSCEN=%d', ts), sprintf('-DOPTEN=%d', op), ...
            sprintf('-DACCSCALE=%d', accscale), ...
            sprintf('-DRHOACC=%.6g', rhoacc), 'console', 'nograph');
    else
        dynare('jv_dsge_v09_access', sprintf('-DSCENARIO=%d', sc), ...
            sprintf('-DTSCEN=%d', ts), sprintf('-DOPTEN=%d', op), ...
            sprintf('-DACCSCALE=%d', accscale), 'console', 'nograph');
    end
    % A Dynare a BASE workspace-be teszi az M_/oo_-t (a driver-t evalin-nel
    % futtatja), ezert fuggvenybol hivva onnan kell elovenni -- kulonben a
    % try/catch NEMA NaN-t adna vissza minden futasra.
    M_  = evalin('base', 'M_');
    oo_ = evalin('base', 'oo_');
    ok_ = oo_.deterministic_simulation.status;
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    pn = cellstr(M_.param_names);
    p = @(v) M_.params(strcmp(pn, v));
    wE = p('om_E')/(p('om_E')+p('om_D'));
    wD = p('om_D')/(p('om_E')+p('om_D'));
    ykkv = wE*g('y_E') + wD*g('y_D');
    R = table(op, sc, ts, accscale, p('rho_acc'), ok_, g('y'), g('y_E'), ...
        g('y_D'), g('y_L'), ykkv, ykkv - g('y_L'), g('y_D') - g('y_L'), ...
        g('y_E') - g('y_L'), g('acc_E'), g('acc_D'), g('rer'), g('bstar'), ...
        'VariableNames', kolumnak_());
catch ME
    % A hibat KIIRJUK: a nema NaN-sorozat korabban ugy nezett ki, mintha a
    % modell nem konvergalt volna, pedig kodhiba volt.
    fprintf(2, '  !! HIBA (OPTEN=%d SC=%d TS=%d ACC=%d): %s\n', op, sc, ts, ...
        accscale, ME.message);
    R = table(op, sc, ts, accscale, rhoacc, 0, NaN, NaN, NaN, NaN, NaN, ...
        NaN, NaN, NaN, NaN, NaN, NaN, NaN, 'VariableNames', kolumnak_());
end
end

function c = kolumnak_()
c = {'OPTEN','SCENARIO','TSCEN','accscale','rho_acc','konvergalt','GDP_pct', ...
    'y_E_pct','y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp', ...
    'D_minus_L_pp','E_minus_L_pp','acc_E','acc_D','rer_pct','bstar_pct'};
end

function k = kuszob_(x, d)
k = NaN;
for j = 1:numel(d)-1
    if d(j) < 0 && d(j+1) >= 0
        k = x(j) + (x(j+1)-x(j))*(0-d(j))/(d(j+1)-d(j)); return
    end
end
if ~isempty(d) && d(1) >= 0, k = 0; end
end

function y = ternary_(c, a, b)
if c, y = a; else, y = b; end
end
