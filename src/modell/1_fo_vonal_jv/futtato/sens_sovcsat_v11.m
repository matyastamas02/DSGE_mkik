% sens_sovcsat_v11.m — v11: a szuveren felar csatornaja (-DSOVCSAT)
% =====================================================================
% KIINDULAS (F09, 2026-10-07): az euro-agi kamatszabalyban szereplo
% zsov*sov rogzitett beta mellett tartosan bstar = zsov*sov/nu_uni kulso
% pozicio-eltolodast ad; a tartos GDP-hatas ezert a zaras rugalmassagan mulik
% (0.84% ... 4.43%). Kerdes: ha a szuveren felar euroban nem a hazai
% kamatot, csak a vallalati forraskoltseget (tsov_j*sov) erinti, eltunik-e
% ez a fugges, es mit ad a modell 20 eves tavon.
%   SOVCSAT = 0: v10 (UIP + euro-agi szabaly)
%   SOVCSAT = 1: euroban kozos kamat; a felar a lebego UIP-ben marad
%   SOVCSAT = 2: csak a vallalati felarban
%
% ELORE ROGZITETT ELVARASOK / ELFOGADASI FELTETELEK (2026-10-07, futas elott):
%   (1) SOVCSAT >= 1 mellett a tartos bstar = 0, es a tartos fixpont
%       EXTCLOSE=0 es 1 mellett azonos (nu-fuggetlen) -- analitikus elorejelzes;
%   (2) a stabilitast a SOVCSAT nem valtoztatja (a sov exogen, a Jacobit nem
%       erinti): EXTCLOSE=1 mellett 13/13 mindket rezsimben, regi es friss
%       sulyokkal a teljes ACCSCALE-racson; EXTCLOSE=0 mellett mint t62;
%   (3) SOVCSAT=0 visszaadja a t62-t (tartos GDP 0.838 / 4.428);
%   (4) a fo mutato a 16-20. ev atlaga (61-80. negyedev); a GDP-sav (SC x
%       TSCEN) es a KKV-kuszob ujraszamolva, barmi jon ki -- NEM hangolunk.
% Szamitasi horizont 400 negyedev (a 20 eves ertek ne torzuljon); kozolni
% legfeljebb 20-30 evet kozlunk.
%
% Kimenet: output/tables/t63_sovcsat_racs.csv      (ACCSCALE-racs)
%          output/tables/t63b_sovcsat_osszegzes.csv
%          output/tables/t63c_sovcsat_gdpsav.csv   (SC x TSCEN, ACC=100)
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); sens_sovcsat_v11"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

HOR = '-DHORIZON=400';
csatornak = [0 1 2];
zarasok = [0 1];
sulyok = {{}, 'regi'; {'-DCALIB26=3', '-DNOVERT=1'}, 'friss'};
racs_acc = [0 20 30 40 50 60 80 100 120 150];

% --- egymasba agyazas: v11 SOVCSAT=0 (alap) == v09 -------------------
dynare('jv_dsge_v09_access', 'console', 'nograph');
n9 = cellstr(evalin('base', 'M_.endo_names')); S9 = evalin('base', 'oo_.endo_simul');
dynare('jv_dsge_v11', '-DSOVCSAT=0', 'console', 'nograph');
n11 = cellstr(evalin('base', 'M_.endo_names')); S11 = evalin('base', 'oo_.endo_simul');
[~, i9, i11] = intersect(n9, n11, 'stable');
nesting_maxdiff = max(abs(S9(i9, :) - S11(i11, :)), [], 'all');
fprintf('\nNESTING: v11 SOVCSAT=0 vs v09: max |elteres| = %.3g\n', nesting_maxdiff);

% --- racs --------------------------------------------------------------
G = table();
for ic = csatornak
    for iz = zarasok
        for iw = 1:size(sulyok, 1)
            for ia = racs_acc
                args = [{'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DSOVCSAT=%d', ic), ...
                    sprintf('-DEXTCLOSE=%d', iz), sprintf('-DACCSCALE=%.10g', ia), HOR}, sulyok{iw, 1}];
                r = fut_(args);
                G = [G; [table(ic, iz, string(sulyok{iw, 2}), ia, 'VariableNames', ...
                    {'SOVCSAT', 'EXTCLOSE', 'sulyok', 'accscale'}), struct2table(r)]]; %#ok<AGROW>
            end
        end
    end
end
writetable(G, fullfile(tab, 't63_sovcsat_racs.csv'));

% --- GDP-sav (SC x TSCEN, ACC=100) ---------------------------------------
C = table();
for ic = csatornak
    for iz = zarasok
        for iw = 1:size(sulyok, 1)
            for isc = 1:3
                for its = 1:3
                    args = [{sprintf('-DSCENARIO=%d', isc), sprintf('-DTSCEN=%d', its), ...
                        sprintf('-DSOVCSAT=%d', ic), sprintf('-DEXTCLOSE=%d', iz), HOR}, sulyok{iw, 1}];
                    r = fut_(args);
                    C = [C; [table(ic, iz, string(sulyok{iw, 2}), isc, its, 'VariableNames', ...
                        {'SOVCSAT', 'EXTCLOSE', 'sulyok', 'SCENARIO', 'TSCEN'}), struct2table(r)]]; %#ok<AGROW>
                end
            end
        end
    end
end
writetable(C, fullfile(tab, 't63c_sovcsat_gdpsav.csv'));

% --- osszegzes -------------------------------------------------------
O = table();
fprintf('\n%-3s %-3s %-6s %-6s %7s %8s %8s %8s %8s %13s %8s\n', 'SOV', 'ZAR', 'suly', 'BK', ...
    'max|z|', 'kus_fix', 'kus_1620', 'GDPfix', 'GDP1620', 'sav 16-20', 'bstar');
for ic = csatornak
    for iz = zarasok
        for iw = 1:size(sulyok, 1)
            h = G(G.SOVCSAT == ic & G.EXTCLOSE == iz & G.sulyok == sulyok{iw, 2}, :);
            ok = h.ervenyes == 1 & h.instabil_kezdeti == h.eloretekinto;
            h100 = h(h.accscale == 100, :);
            c = C(C.SOVCSAT == ic & C.EXTCLOSE == iz & C.sulyok == sulyok{iw, 2}, :);
            cv = c(c.ervenyes == 1, :);
            if height(cv) == 9
                sav = [min(cv.GDP_1620_pct) max(cv.GDP_1620_pct) min(cv.GDP_fix_pct) max(cv.GDP_fix_pct)];
            else
                sav = nan(1, 4);
            end
            O = [O; table(ic, iz, string(sulyok{iw, 2}), all(ok), max([NaN; h.accscale(ok)]), ...
                max(h.ciklus_abs_z), kuszob_(h.accscale(ok), h.KKV_L_fix_pp(ok)), ...
                kuszob_(h.accscale(ok), h.KKV_L_1620_pp(ok)), h100.ervenyes, h100.GDP_fix_pct, ...
                h100.GDP_q80_pct, h100.GDP_1620_pct, h100.GDP_q4_pct, h100.GDP_q40_pct, ...
                h100.KKV_L_1620_pp, sav(1), sav(2), sav(3), sav(4), height(cv), h100.bstar_fix, ...
                h100.rer_fix_pct, h100.c_o_fix_pct, h100.q_D_fix_pct, h100.q_E_fix_pct, nesting_maxdiff, ...
                'VariableNames', {'SOVCSAT', 'EXTCLOSE', 'sulyok', 'BK_teljes_racson', ...
                'max_stabil_accscale', 'max_ciklus_abs_z', 'KKV_kuszob_fix', 'KKV_kuszob_1620', ...
                'ervenyes_100', 'GDP_fix_100_pct', 'GDP_q80_100_pct', 'GDP_1620_100_pct', ...
                'GDP_q4_100_pct', 'GDP_q40_100_pct', 'KKV_L_1620_100_pp', 'sav_1620_min', ...
                'sav_1620_max', 'sav_fix_min', 'sav_fix_max', 'sav_ervenyes_db', 'bstar_fix_100', ...
                'rer_fix_100_pct', 'c_o_fix_100_pct', 'q_D_fix_100_pct', 'q_E_fix_100_pct', ...
                'nesting_maxdiff'})]; %#ok<AGROW>
            fprintf('%-3d %-3d %-6s %-6s %7.4f %8.2f %8.2f %8.3f %8.3f %6.2f..%-6.2f %8.4f\n', ic, iz, ...
                sulyok{iw, 2}, ternary_(all(ok), 'mind', 'NEM'), max(h.ciklus_abs_z), ...
                O.KKV_kuszob_fix(end), O.KKV_kuszob_1620(end), h100.GDP_fix_pct, h100.GDP_1620_pct, ...
                sav(1), sav(2), h100.bstar_fix);
        end
    end
end
writetable(O, fullfile(tab, 't63b_sovcsat_osszegzes.csv'));

% =====================================================================
function r = fut_(args)
r = struct('solver_ok', 0, 'instabil_zaro', NaN, 'instabil_kezdeti', NaN, 'eloretekinto', NaN, ...
    'ervenyes', 0, 'ciklus_abs_z', NaN, 'GDP_fix_pct', NaN, 'GDP_q4_pct', NaN, 'GDP_q40_pct', NaN, ...
    'GDP_q80_pct', NaN, 'GDP_1620_pct', NaN, 'KKV_L_fix_pp', NaN, 'KKV_L_1620_pp', NaN, ...
    'bstar_fix', NaN, 'rer_fix_pct', NaN, 'c_o_fix_pct', NaN, 'q_D_fix_pct', NaN, 'q_E_fix_pct', NaN);
try
    dynare('jv_dsge_v11', args{:}, 'console', 'nograph');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    r.solver_ok = double(oo.deterministic_simulation.status == 1);
    B = bk_check_metrics(M, op, oo);
    oo0 = oo; oo0.steady_state(:) = 0; oo0.exo_steady_state(:) = 0;
    if isfield(oo0, 'exo_det_steady_state'), oo0.exo_det_steady_state(:) = 0; end
    B0 = bk_check_metrics(M, op, oo0);
    r.instabil_zaro = B.n_unstable; r.instabil_kezdeti = B0.n_unstable; r.eloretekinto = B.n_forward;
    r.ervenyes = double(r.solver_ok == 1 && B.check_ok == 1 && B.bk_ok == 1);
    ev = B.eigenvalues(isfinite(B.eigenvalues)); a = abs(angle(ev));
    c = ev(imag(ev) > 1e-8 & a > 0.12 & a < 0.40 & abs(ev) > 0.85 & abs(ev) < 1.10);
    if ~isempty(c), r.ciklus_abs_z = max(abs(c)); end
    n = cellstr(M.endo_names); pn = cellstr(M.param_names); p = @(v) M.params(strcmp(pn, v));
    ss = @(v) 100 * oo.steady_state(strcmp(n, v)); S = oo.endo_simul;
    pa = @(v) 100 * S(strcmp(n, v), :);
    wE = p('om_E') / (p('om_E') + p('om_D')); wD = 1 - wE;
    ab = 62:81;                                   % 61-80. negyedev (16-20. ev)
    y = pa('y'); kl = wE*pa('y_E') + wD*pa('y_D') - pa('y_L');
    r.GDP_fix_pct = ss('y'); r.GDP_q4_pct = y(5); r.GDP_q40_pct = y(41); r.GDP_q80_pct = y(81);
    r.GDP_1620_pct = mean(y(ab));
    r.KKV_L_fix_pp = wE*ss('y_E') + wD*ss('y_D') - ss('y_L'); r.KKV_L_1620_pp = mean(kl(ab));
    r.bstar_fix = oo.steady_state(strcmp(n, 'bstar')); r.rer_fix_pct = ss('rer');
    r.c_o_fix_pct = ss('c_o'); r.q_D_fix_pct = ss('q_D'); r.q_E_fix_pct = ss('q_E');
catch ME
    fprintf(2, '  !! HIBA (%s): %s\n', strjoin(args, ' '), ME.message);
end
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
