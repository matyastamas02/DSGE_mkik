% sens_calib_kuszob_v07.m — MENNYIVEL MOZDUL AZ ACCESS-KUSZOB, HA A
% JV-BECSULT PARAMETEREKET HASZNALJUK?
% =====================================================================
% A sens_calib_v07.m kimutatta, hogy a JV-becsult keszlettel a szektoralis
% sorrend MEGFORDUL az ACCSCALE=100 alapkalibracional (KKV-L: -0.015 pp ->
% +0.095 pp). A projekt fo szama viszont nem ez, hanem a KUSZOB: mekkora
% hozzaferesi reakcio kell ahhoz, hogy a sulyozott KKV-blokk megelozze a
% nagyvallalatot.
%
% A kerdes tehat: a JV-kalibracio MENNYIVEL VISZI LEJJEBB a kuszobot?
% Ez azert fontos, mert az s14 szerint az ACCSCALE magyar adatbol NEM
% horgonyozhato -- de ha a kuszob erdemben alacsonyabb, akkor a
% "KKV-elony" allitas KEVESEBB horgonyzatlan hozzaferesi reakciot igenyel,
% tehat vedhetobbe valik.
%
% Modszer: ugyanaz a 0:10:150 racs, mint a szerzo run_v07_access_threshold.m
% scriptjeben, de MINDKET parameterkeszlettel vegigfuttatva. A kuszob
% linearis interpolacio a racspontok kozott (ugyanaz az eljaras).
%
% Kimenet: output/tables/t39_calib_kuszob.csv
% Futtatas: matlab -batch "cd('<repo>/src/model'); sens_calib_kuszob_v07"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

scales = 0:10:150;
kalib  = [1 2];
knev   = {'EAGLE_kalibralt', 'JV_becsult'};
R = table();

for ic_ = kalib
    for s_ = scales
        dynare('kkv_dsge_v07_access', '-DSCENARIO=1', '-DTSCEN=3', ...
            sprintf('-DCALIB=%d', ic_), sprintf('-DACCSCALE=%d', s_), ...
            'console');
        ok_ = oo_.deterministic_simulation.status;
        n = cellstr(M_.endo_names);
        g = @(v) 100 * oo_.steady_state(strcmp(n, v));
        pn = cellstr(M_.param_names);
        sy_E = M_.params(strcmp(pn, 'sy_E'));
        sy_D = M_.params(strcmp(pn, 'sy_D'));
        wE = sy_E/(sy_E+sy_D); wD = sy_D/(sy_E+sy_D);
        ykkv = wE*g('y_E') + wD*g('y_D');
        R = [R; table(string(knev{ic_}), ic_, s_, ok_, g('y'), ...
            g('y_E'), g('y_D'), g('y_L'), ykkv, ykkv - g('y_L'), ...
            g('y_D') - g('y_L'), g('y_E') - g('y_L'), ...
            'VariableNames', {'kalibracio','calib','accscale','konvergalt', ...
            'GDP_pct','y_E_pct','y_D_pct','y_L_pct','y_KKV_pct', ...
            'KKV_minus_L_pp','D_minus_L_pp','E_minus_L_pp'})]; %#ok<AGROW>
    end
end

repo = fileparts(fileparts(pwd));
writetable(R, fullfile(repo, 'output', 'tables', 't39_calib_kuszob.csv'));


fprintf('\n%s\n', repmat('=', 1, 84));
fprintf('AZ ACCESS-KUSZOB A KET PARAMETERKESZLETTEL (v07_access, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 84));
fprintf('%-18s %14s %14s %14s\n', 'kalibracio', 'D >= L', 'KKV >= L', 'E >= L');
fprintf('%s\n', repmat('-', 1, 84));
K = table();
for ic_ = kalib
    m = R.calib == ic_ & R.konvergalt == 1;
    x = R.accscale(m);
    kD = kuszob_(x, R.D_minus_L_pp(m));
    kK = kuszob_(x, R.KKV_minus_L_pp(m));
    kE = kuszob_(x, R.E_minus_L_pp(m));
    fprintf('%-18s %14.1f %14.1f %14.1f\n', knev{ic_}, kD, kK, kE);
    K = [K; table(string(knev{ic_}), kD, kK, kE, ...
        'VariableNames', {'kalibracio','kuszob_D_L','kuszob_KKV_L', ...
        'kuszob_E_L'})]; %#ok<AGROW>
end
writetable(K, fullfile(repo, 'output', 'tables', 't39b_calib_kuszob_osszegzes.csv'));
fprintf('%s\n', repmat('=', 1, 84));
if height(K) == 2
    d = K.kuszob_KKV_L(2) - K.kuszob_KKV_L(1);
    if d < 0, ir_ = 'ALACSONYABB'; else, ir_ = 'MAGASABB'; end
    fprintf(['A sulyozott KKV-blokk kuszobe %+.1f ponttal %s a JV-becsult\n' ...
        'keszlettel (%.1f -> %.1f).\n'], d, ...
        ir_, ...
        K.kuszob_KKV_L(1), K.kuszob_KKV_L(2));
end
fprintf(['\nMIT JELENT: a kuszob azt mondja meg, mekkora horgonyzatlan\n' ...
    'hozzaferesi reakcio kell a KKV-elonyhoz. Alacsonyabb kuszob =\n' ...
    'KEVESEBB horgonyzatlan feltevesre van szukseg = vedhetobb allitas.\n' ...
    'Ha a JV-keszlettel a kuszob 100 ALATT van, akkor a KKV-elony mar a\n' ...
    'baseline access-kalibracio ALATT is teljesul.\n']);
fprintf('%s\n', repmat('=', 1, 84));

% --- kuszob-kereses linearis interpolacioval (mint a szerzo scriptjeben) --
function k = kuszob_(x, d)
    k = NaN;
    for j = 1:numel(d)-1
        if d(j) < 0 && d(j+1) >= 0
            k = x(j) + (x(j+1)-x(j)) * (0 - d(j)) / (d(j+1) - d(j));
            return
        end
    end
    if d(1) >= 0, k = 0; end     % mar a nulla racsponton is pozitiv
end
