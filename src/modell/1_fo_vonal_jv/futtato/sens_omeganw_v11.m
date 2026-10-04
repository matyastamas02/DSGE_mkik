% sens_omeganw_v11.m — v11 / W0b kiegeszites: a nettovagyon-perzisztencia (omega_nw)
% =====================================================================
% UTOLAGOS (nem elore rogzitett) scan, de a W0-levezetesbol kovetkezik: a
% vallalkozoi jovedelem tag sulya W^e/N = 1 - omega_nw - gam*pi*lev, es a
% tartos fixpontban 1/(1-omega_nw) szorzot kap. A W0b (sens_nwspec_v11.m)
% szerint NWSPEC=1 mellett eros hozzaferesi csatornanal a tartos fixpont
% polushoz er. A v10 omega_nw = 0.95-ot hasznal, mikozben a regiszter "BGG
% konvencio"-kent hivatkozik ra, a BGG/Christensen-Dib tulelesi rata pedig
% 0.9728 (ebben a jelolesben omega_nw = 0.9728/beta = 0.9826).
%
% Racs: omega_nw = 0.95 / 0.9728 / 0.9826  x  NWSPEC = 0 / 1
%       x OPTEN = 0 / 1  x  chi aszimm. / 0.04  x  ACCSCALE-racs.
% Plusz: A01 GDP-sav (OPTEN=0, SC x TSCEN, ACC=100) minden (omega, NWSPEC)-re.
%
% Kimenet: output/tables/t61f_omeganw_kuszob.csv (racs)
%          output/tables/t61g_omeganw_osszegzes.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); sens_omeganw_v11"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

racs_acc = [0:2:20, 25:5:50, 60:20:140];
racs_om = [0.95 0.9728 0.9826];
G = table();
for iom = racs_om
    for insp = [0 1]
        for iop = [0 1]
            for ichi = [-1 0.04]
                for iacc = racs_acc
                    args = {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DOPTEN=%d', iop), ...
                        sprintf('-DACCSCALE=%.10g', iacc), sprintf('-DNWSPEC=%d', insp), ...
                        sprintf('-DOMEGANW=%.6g', iom)};
                    if ichi > 0, args{end+1} = sprintf('-DCHISYM=%.6g', ichi); end %#ok<AGROW>
                    r = fut_(args);
                    G = [G; table(iom, insp, iop, ichi, iacc, r.kkv_l, r.y, r.ervenyes, ...
                        'VariableNames', {'omega_nw', 'NWSPEC', 'OPTEN', 'chi_szimm', ...
                        'accscale', 'KKV_minus_L_pp', 'GDP_pct', 'ervenyes'})]; %#ok<AGROW>
                end
            end
        end
    end
end
writetable(G, fullfile(tab, 't61f_omeganw_kuszob.csv'));

O = table();
fprintf('\n%-7s %-6s %-6s %-7s %9s %9s %11s %11s %12s\n', 'omega', 'NWSPEC', 'OPTEN', 'chi', ...
    'kuszob', 'BK@k', 'KKV-L@0', 'KKV-L@100', 'GDP-sav');
for iom = racs_om
    for insp = [0 1]
        % A01 GDP-sav
        gd = nan(1, 9); gv = zeros(1, 9); ig = 0;
        for isc = 1:3
            for its = 1:3
                ig = ig + 1;
                r = fut_({sprintf('-DSCENARIO=%d', isc), sprintf('-DTSCEN=%d', its), ...
                    sprintf('-DNWSPEC=%d', insp), sprintf('-DOMEGANW=%.6g', iom)});
                gd(ig) = r.y; gv(ig) = r.ervenyes;
            end
        end
        for iop = [0 1]
            for ichi = [-1 0.04]
                m = G.omega_nw == iom & G.NWSPEC == insp & G.OPTEN == iop & ...
                    G.chi_szimm == ichi & G.ervenyes == 1;
                Gm = sortrows(G(m, :), 'accscale');
                k = kuszob_(Gm.accscale, Gm.KKV_minus_L_pp);
                bk = NaN;
                if isfinite(k) && k > 0
                    args = {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DOPTEN=%d', iop), ...
                        sprintf('-DACCSCALE=%.10g', k), sprintf('-DNWSPEC=%d', insp), ...
                        sprintf('-DOMEGANW=%.6g', iom)};
                    if ichi > 0, args{end+1} = sprintf('-DCHISYM=%.6g', ichi); end %#ok<AGROW>
                    bk = fut_(args).ervenyes;
                elseif k == 0
                    bk = 1;
                end
                v = @(a) G.KKV_minus_L_pp(G.omega_nw == iom & G.NWSPEC == insp & ...
                    G.OPTEN == iop & G.chi_szimm == ichi & G.accscale == a);
                % polus-jelzo: elojelvaltas negativba a kuszob UTAN a racson
                d = G.KKV_minus_L_pp(G.omega_nw == iom & G.NWSPEC == insp & ...
                    G.OPTEN == iop & G.chi_szimm == ichi);
                polus = double(any(diff(sign(d(d ~= 0))) < 0));
                fprintf('%-7.4f %-6d %-6d %-7s %9.2f %9g %+11.3f %+11.3f  %+.2f..%+.2f (%d/9)%s\n', ...
                    iom, insp, iop, chinev_(ichi), k, bk, v(0), v(100), min(gd(gv == 1)), ...
                    max(gd(gv == 1)), sum(gv), ternary_(polus, '  POLUS', ''));
                O = [O; table(iom, insp, iop, ichi, k, bk, v(0), v(100), ...
                    min(gd(gv == 1)), max(gd(gv == 1)), sum(gv), polus, ...
                    'VariableNames', {'omega_nw', 'NWSPEC', 'OPTEN', 'chi_szimm', ...
                    'kuszob_KKV_L', 'bk_ok_kuszob', 'KKV_minus_L_ACC0', 'KKV_minus_L_ACC100', ...
                    'GDP_sav_min', 'GDP_sav_max', 'GDP_sav_bk_ervenyes', 'polus_a_racson'})]; %#ok<AGROW>
            end
        end
    end
end
writetable(O, fullfile(tab, 't61g_omeganw_osszegzes.csv'));
fprintf('\nKESZ\n');

% =====================================================================
function r = fut_(args)
r = struct('ervenyes', 0, 'kkv_l', NaN, 'y', NaN);
try
    dynare('jv_dsge_v11', args{:}, 'console', 'nograph');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    B = bk_check_metrics(M, op, oo);
    r.ervenyes = double(oo.deterministic_simulation.status == 1 && B.check_ok == 1 && B.bk_ok == 1);
    n = cellstr(M.endo_names); g = @(v) 100 * oo.steady_state(strcmp(n, v));
    pn = cellstr(M.param_names); p = @(v) M.params(strcmp(pn, v));
    wE = p('om_E') / (p('om_E') + p('om_D')); wD = 1 - wE;
    r.kkv_l = wE*g('y_E') + wD*g('y_D') - g('y_L');
    r.y = g('y');
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

function s = chinev_(c)
if c < 0, s = 'ASZIMM'; else, s = sprintf('%.2f', c); end
end

function y = ternary_(c, a, b)
if c, y = a; else, y = b; end
end
