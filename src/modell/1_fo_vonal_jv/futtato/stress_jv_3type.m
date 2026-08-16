% stress_jv_3type.m — A 2. LEPCSO DONTO TESZTJE
% =====================================================================
% Kerdes: a haromtipusos (E/D/L) szerkezet a Jakab-Vilagi magon
% Blanchard-Kahn-stabil-e, KOZOS arszint mellett?
%
% Ha IGEN: a JV-magon a meret szerinti szetbontas jarhato, es erdemes a
% 3. lepcsore menni (tipusonkenti ar es exportkereslet).
% Ha NEM : a 3. lepcsonek nincs ertelme, es vagy az EAGLE-magon maradunk,
%          vagy reszleges 3type-tal (a jelen fajl) dolgozunk tovabb.
%
% Ugyanaz a protokoll, mint a v06-nal (stress_v06.m): minden
% SCENARIO x TSCEN x NOVERT kombinacio, hogy ne egy szerencses esetre
% alapozzunk.
%
% Kimenet: output/tables/t40_jv_3type_stressz.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); stress_jv_3type"

% --- UTVONAL (repo-atrendezes, 2026-08-16) -----------------------------
% A .mod fajlok a futtato/ mappa FOLOTT vannak, es a Dynare a
% munkakonyvtarhoz kepest keresi oket -- ezert ide kell lepni. A repo
% gyokeret a script SAJAT helyebol szamoljuk (felfele a CLAUDE.md-ig), igy
% egy jovobeli athelyezes sem tori el.
cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

T = table();
for sc_ = 1:3
    for ts_ = 1:3
        for nv_ = 0:1
            args = {sprintf('-DSCENARIO=%d', sc_), sprintf('-DTSCEN=%d', ts_), ...
                    sprintf('-DNOVERT=%d', nv_)};
            hiba_ = "";
            try
                dynare('jv_dsge_v07_3type', args{:}, 'console', 'nograph');
                ok_ = oo_.deterministic_simulation.status;
                n = cellstr(M_.endo_names);
                g = @(v) 100 * oo_.steady_state(strcmp(n, v));
                pn = cellstr(M_.param_names);
                p = @(v) M_.params(strcmp(pn, v));
                % sulyozott KKV-blokk (meret-sulyokkal, E es D)
                wE = p('om_E')/(p('om_E')+p('om_D'));
                wD = p('om_D')/(p('om_E')+p('om_D'));
                ykkv = wE*g('y_E') + wD*g('y_D');
                uj = table(sc_, ts_, nv_, ok_, string(hiba_), ...
                    g('y'), g('y_E'), g('y_D'), g('y_L'), ykkv, ...
                    ykkv - g('y_L'), ...
                    10000*g('efp_E')/100, 10000*g('efp_D')/100, ...
                    10000*g('efp_L')/100, ...
                    g('rk_E'), g('rk_D'), g('rk_L'), g('rer'), g('bstar'), ...
                    'VariableNames', {'SCENARIO','TSCEN','NOVERT','konvergalt', ...
                    'hiba','GDP_pct','y_E_pct','y_D_pct','y_L_pct', ...
                    'y_KKV_pct','KKV_minus_L_pp','efp_E_bp','efp_D_bp', ...
                    'efp_L_bp','rk_E_pct','rk_D_pct','rk_L_pct','rer_pct', ...
                    'bstar_pct'});
            catch ME
                hiba_ = ME.message;
                if numel(hiba_) > 90, hiba_ = extractBefore(hiba_, 90); end
                uj = table(sc_, ts_, nv_, 0, string(hiba_), ...
                    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
                    NaN, NaN, NaN, NaN, NaN, ...
                    'VariableNames', {'SCENARIO','TSCEN','NOVERT','konvergalt', ...
                    'hiba','GDP_pct','y_E_pct','y_D_pct','y_L_pct', ...
                    'y_KKV_pct','KKV_minus_L_pp','efp_E_bp','efp_D_bp', ...
                    'efp_L_bp','rk_E_pct','rk_D_pct','rk_L_pct','rer_pct', ...
                    'bstar_pct'});
            end
            T = [T; uj]; %#ok<AGROW>
        end
    end
end

% [a repo-t a fejlec mar beallitotta]
writetable(T, fullfile(repo, 'output', 'tables', 't40_jv_3type_stressz.csv'));

fprintf('\n%s\n', repmat('=', 1, 96));
fprintf('2. LEPCSO: HAROMTIPUSOS JV-MAG, KOZOS ARSZINT -- BK-STRESSZTESZT\n');
fprintf('%s\n', repmat('=', 1, 96));
fprintf('%-24s %5s %9s %8s %8s %8s %11s\n', 'kombinacio', 'OK', 'GDP', ...
    'y_E', 'y_D', 'y_L', 'KKV-L');
fprintf('%s\n', repmat('-', 1, 96));
for i = 1:height(T)
    cim = sprintf('SC=%d TSCEN=%d NOVERT=%d', T.SCENARIO(i), T.TSCEN(i), T.NOVERT(i));
    if T.konvergalt(i) ~= 1
        fprintf('%-24s  ***  %s\n', cim, T.hiba(i));
        continue
    end
    fprintf('%-24s %5d %+8.3f%% %+7.3f%% %+7.3f%% %+7.3f%% %+8.3f pp\n', ...
        cim, T.konvergalt(i), T.GDP_pct(i), T.y_E_pct(i), T.y_D_pct(i), ...
        T.y_L_pct(i), T.KKV_minus_L_pp(i));
end
fprintf('%s\n', repmat('=', 1, 96));
n_ok = sum(T.konvergalt == 1);
fprintf('EREDMENY: %d / %d kombinacio megoldodott.\n', n_ok, height(T));
if n_ok == height(T)
    fprintf(['\n==> A 2. LEPCSO ATMENT. A haromtipusos szerkezet a JV-magon\n' ...
        '    BK-stabil kozos arszint mellett. Erdemes a 3. lepcsore menni\n' ...
        '    (tipusonkenti ar es exportkereslet) -- ott derul ki, hogy a\n' ...
        '    v04-ben dokumentalt arszint-szetvalasztasi problema jelentkezik-e.\n']);
    % plauzibilitas: a realarfolyam es az NFA ne szaladjon el
    rossz = T(abs(T.rer_pct) > 15 | abs(T.bstar_pct) > 5, :);
    if isempty(rossz)
        fprintf(['    Plauzibilitas: a realarfolyam es az NFA minden\n' ...
            '    kombinacioban ertelmes savban maradt.\n']);
    else
        fprintf(['    !! FIGYELEM: %d kombinacioban a realarfolyam vagy az NFA\n' ...
            '    elszaladt -- a zaras (nu_uni) ellenorizendo.\n'], height(rossz));
    end
else
    fprintf(['\n==> A 2. LEPCSO ELBUKOTT %d kombinacioban. A 3. lepcsonek\n' ...
        '    igy nincs ertelme; a reszleges 3type vagy az EAGLE-mag marad.\n'], ...
        height(T) - n_ok);
end
fprintf('%s\n', repmat('=', 1, 96));
