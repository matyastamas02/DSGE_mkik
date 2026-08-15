% stress_jv_3type_arak.m — A 3. LEPCSO DONTO TESZTJE
% =====================================================================
% Ket kerdest dont el:
%
% (A) BK-STABILITAS. A v04 elso kiserlete a szegmens-specifikus toke +
%     ARSZINT-SZETVALASZTAS kombinaciojan bukott meg. A v06 es a v07_3type
%     mar bizonyitotta, hogy a toke-oldal onmagaban stabil -- tehat ha ITT
%     bukik, az IZOLALTAN az arra vezetheto vissza.
%
% (B) AZ eps_ces ERZEKENYSEG -- ES EZ LEGALABB OLYAN FONTOS.
%     Az elso futas gyanus eredmenyt adott: az export-KKV kibocsatasa
%     NEGATIV (-0.22%), mert a relativ ara +0.155-tel NO. Az ok szerkezeti:
%     a normalizacio (0 = sum wd_j*p_j) miatt a LEGKISEBB hazai sulyu tipus
%     (wd_E = 0.11) nyeli el a legtobb relativar-kiigazitast, es az
%     eps_ces = 6.0 ezt hatszorosara erositi a hazai keresletben
%     (d_j = y_d - eps_ces*p_j).
%     Az eps_ces UJ parameter: a JV-ben NINCS ilyen (ott ket jószag van,
%     nem differencialt tipusok), az ertek az EAGLE-vonalbol atvett
%     IRODALMI szam. Ha az eredmeny elojele az eps_ces-tol fugg, akkor ez
%     ugyanaz a "horgonyzatlan parameter viszi a fo eredmenyt" mintazat,
%     mint a t_S>t_L, a chi-aszimmetria es az ACCSCALE eseteben.
%
% Kimenet: output/tables/t41_jv_3type_arak_stressz.csv
%          output/tables/t42_jv_3type_epsces_sens.csv
% Futtatas: matlab -batch "cd('<repo>/src/model'); stress_jv_3type_arak"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

% =====================================================================
% (A) BK-stresszteszt: minden SCENARIO x TSCEN x NOVERT
% =====================================================================
T = table();
for sc_ = 1:3
    for ts_ = 1:3
        for nv_ = 0:1
            hiba_ = "";
            try
                dynare('jv_dsge_v08_3type_arak', sprintf('-DSCENARIO=%d', sc_), ...
                    sprintf('-DTSCEN=%d', ts_), sprintf('-DNOVERT=%d', nv_), ...
                    'console', 'nograph');
                ok_ = oo_.deterministic_simulation.status;
                n = cellstr(M_.endo_names);
                g = @(v) 100 * oo_.steady_state(strcmp(n, v));
                pn = cellstr(M_.param_names);
                p = @(v) M_.params(strcmp(pn, v));
                wE = p('om_E')/(p('om_E')+p('om_D'));
                wD = p('om_D')/(p('om_E')+p('om_D'));
                ykkv = wE*g('y_E') + wD*g('y_D');
                % normalizacio-ellenorzes: sum(wd_j*p_j) == 0 ?
                norm_ = p('wd_E')*g('p_E') + p('wd_D')*g('p_D') + p('wd_L')*g('p_L');
                uj = table(sc_, ts_, nv_, ok_, string(hiba_), g('y'), ...
                    g('y_E'), g('y_D'), g('y_L'), ykkv, ykkv - g('y_L'), ...
                    g('p_E'), g('p_D'), g('p_L'), norm_, ...
                    g('rer'), g('bstar'), ...
                    'VariableNames', {'SCENARIO','TSCEN','NOVERT','konvergalt', ...
                    'hiba','GDP_pct','y_E_pct','y_D_pct','y_L_pct','y_KKV_pct', ...
                    'KKV_minus_L_pp','p_E','p_D','p_L','normalizacio', ...
                    'rer_pct','bstar_pct'});
            catch ME
                hiba_ = ME.message;
                if numel(hiba_) > 80, hiba_ = extractBefore(hiba_, 80); end
                uj = table(sc_, ts_, nv_, 0, string(hiba_), NaN, NaN, NaN, ...
                    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
                    'VariableNames', {'SCENARIO','TSCEN','NOVERT','konvergalt', ...
                    'hiba','GDP_pct','y_E_pct','y_D_pct','y_L_pct','y_KKV_pct', ...
                    'KKV_minus_L_pp','p_E','p_D','p_L','normalizacio', ...
                    'rer_pct','bstar_pct'});
            end
            T = [T; uj]; %#ok<AGROW>
        end
    end
end

repo = fileparts(fileparts(pwd));
writetable(T, fullfile(repo, 'output', 'tables', 't41_jv_3type_arak_stressz.csv'));

fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('3. LEPCSO (A): TIPUSONKENTI AR -- BK-STRESSZTESZT\n');
fprintf('%s\n', repmat('=', 1, 100));
fprintf('%-24s %4s %9s %9s %9s %9s %10s\n', 'kombinacio', 'OK', 'GDP', ...
    'y_E', 'y_D', 'y_L', 'norm');
fprintf('%s\n', repmat('-', 1, 100));
for i = 1:height(T)
    cim = sprintf('SC=%d TSCEN=%d NOVERT=%d', T.SCENARIO(i), T.TSCEN(i), T.NOVERT(i));
    if T.konvergalt(i) ~= 1
        fprintf('%-24s ***  %s\n', cim, T.hiba(i)); continue
    end
    fprintf('%-24s %4d %+8.3f%% %+8.3f%% %+8.3f%% %+8.3f%% %9.1e\n', ...
        cim, T.konvergalt(i), T.GDP_pct(i), T.y_E_pct(i), T.y_D_pct(i), ...
        T.y_L_pct(i), T.normalizacio(i));
end
n_ok = sum(T.konvergalt == 1);
fprintf('%s\n', repmat('=', 1, 100));
fprintf('(A) EREDMENY: %d / %d kombinacio megoldodott.\n', n_ok, height(T));
if n_ok == height(T)
    fprintf(['==> A 3. LEPCSO BK-BAN ATMENT. Az arszint-szetvalasztas a\n' ...
        '    JV-magon NEM tori el a modellt (a v04-es kudarc tehat nem\n' ...
        '    elkerulhetetlen -- ott a KOMBINACIO volt a baj).\n']);
else
    fprintf(['==> A 3. LEPCSO %d kombinacioban ELBUKOTT. Mivel a toke-oldal\n' ...
        '    onmagaban stabil (v06, v07_3type), ez IZOLALTAN az\n' ...
        '    arszint-szetvalasztasra vezetheto vissza.\n'], height(T)-n_ok);
end

% =====================================================================
% (B) eps_ces erzekenyseg -- horgonyzatlan parameter, viszi-e a fo eredmenyt?
% =====================================================================
epsv = [2 3 4 6 8 11];
E = table();
for e_ = epsv
    try
        dynare('jv_dsge_v08_3type_arak', '-DSCENARIO=1', '-DTSCEN=3', ...
            sprintf('-DEPSCES=%g', e_), 'console', 'nograph');
        ok_ = oo_.deterministic_simulation.status;
        n = cellstr(M_.endo_names);
        g = @(v) 100 * oo_.steady_state(strcmp(n, v));
        pn = cellstr(M_.param_names);
        p = @(v) M_.params(strcmp(pn, v));
        wE = p('om_E')/(p('om_E')+p('om_D'));
        wD = p('om_D')/(p('om_E')+p('om_D'));
        ykkv = wE*g('y_E') + wD*g('y_D');
        E = [E; table(e_, ok_, g('y'), g('y_E'), g('y_D'), g('y_L'), ...
            ykkv, ykkv - g('y_L'), g('p_E'), ...
            'VariableNames', {'eps_ces','konvergalt','GDP_pct','y_E_pct', ...
            'y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp','p_E'})]; %#ok<AGROW>
    catch
        E = [E; table(e_, 0, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
            'VariableNames', {'eps_ces','konvergalt','GDP_pct','y_E_pct', ...
            'y_D_pct','y_L_pct','y_KKV_pct','KKV_minus_L_pp','p_E'})]; %#ok<AGROW>
    end
end
writetable(E, fullfile(repo, 'output', 'tables', 't42_jv_3type_epsces_sens.csv'));

fprintf('\n%s\n', repmat('=', 1, 100));
fprintf('3. LEPCSO (B): eps_ces ERZEKENYSEG (SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 100));
fprintf('%9s %4s %9s %9s %9s %9s %11s\n', 'eps_ces', 'OK', 'GDP', 'y_E', ...
    'y_D', 'y_L', 'KKV-L');
fprintf('%s\n', repmat('-', 1, 100));
for i = 1:height(E)
    if E.konvergalt(i) ~= 1
        fprintf('%9.1f  ***  NEM KONVERGALT\n', E.eps_ces(i)); continue
    end
    jel = '';
    if E.eps_ces(i) == 6, jel = '  <== jelenlegi alap (EAGLE-bol atvett)'; end
    fprintf('%9.1f %4d %+8.3f%% %+8.3f%% %+8.3f%% %+8.3f%% %+10.3f pp%s\n', ...
        E.eps_ces(i), E.konvergalt(i), E.GDP_pct(i), E.y_E_pct(i), ...
        E.y_D_pct(i), E.y_L_pct(i), E.KKV_minus_L_pp(i), jel);
end
fprintf('%s\n', repmat('=', 1, 100));
Eok = E(E.konvergalt == 1, :);
if height(Eok) > 1
    if any(Eok.y_E_pct > 0) && any(Eok.y_E_pct < 0)
        fprintf(['!! FIGYELEM: az export-KKV kibocsatasanak ELOJELE FUGG az\n' ...
            '   eps_ces-tol (%.3f ... %.3f). Ez UJ, horgonyzatlan parameter\n' ...
            '   (a JV-ben nincs ilyen, az ertek EAGLE-bol atvett irodalmi\n' ...
            '   szam) -- ugyanaz a mintazat, mint a t_S>t_L, a chi-aszimmetria\n' ...
            '   es az ACCSCALE eseteben. Az eredmenyt KUSZOBFORMABAN kell\n' ...
            '   kozolni, es az eps_ces-t horgonyozni kell.\n'], ...
            min(Eok.y_E_pct), max(Eok.y_E_pct));
    else
        fprintf(['A szektoralis elojelek az eps_ces teljes savjaban STABILAK\n' ...
            '(y_E: %.3f ... %.3f) -- az eredmeny nem ezen a parameteren all.\n'], ...
            min(Eok.y_E_pct), max(Eok.y_E_pct));
    end
end
fprintf('%s\n', repmat('=', 1, 100));
