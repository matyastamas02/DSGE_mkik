% sens_nwspec_v11.m — v11 / W0b: A TELJES NETTOVAGYON-EGYENLET HATASA
% =====================================================================
% A W0-levezetes (docs/terv/2026-10-04_v11_W0_nettovagyon_levezetes.md)
% szerint a v10 redukalt nettovagyon-egyenlete elhagy egy, ebben a
% kalibracioban nem kicsi tagot (vallalkozoi jovedelem / belepo transzfer).
% Ez a script a v11 -DNWSPEC kapcsolojaval ujramer mindent, amire ez hat.
% A specifikacio es a parameterezes a futtatas ELOTT rogzitve (W0, 8. pont).
%
% (1) REGRESSZIO: v11 NWSPEC=0 == v10 (FOREIGN=0), SC=1..4, bitre.
% (2) TECHNIKAI: BK kezdeti (uni=0) es terminalis (uni=1), nulla-sokk,
%     NWSPEC = 0 / 1 / 2, plusz NWSPEC=1 a PINW = 0.0025 / 0.0075 racson.
% (3) A01 GDP-SAV: OPTEN=0, SC=1..3 x TSCEN=1..3, ACCSCALE=100.
% (4) KKV-KUSZOB: a t58 racsa (OPTEN=0/1, chi aszimm. es 0.04), NWSPEC=0/1/2.
% (5) A W0 JOSLATA: tartos nw tipusonkent az ujraoldott modellben.
%
% ⚠ Akarmi az eredmeny, kozoljuk (v11-terv 0. szakasz, 4. szabaly).
% ⚠ A Dynare a base workspace-be irja a modell parametereit azonos nevu
%   valtozokent (pl. sc, k...): a ciklusvaltozok neve ezert i-vel kezdodik.
%
% Kimenet: output/tables/t61_nwspec_technikai.csv
%          output/tables/t61b_nwspec_gdp_sav.csv
%          output/tables/t61c_nwspec_kuszob.csv (racs) + t61d (osszegzes)
%          output/tables/t61e_nwspec_nw_tartos.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); sens_nwspec_v11"
% MEGJEGYZES (2026-10-07): a v11 alapertelmezese a vegleges kalibracio; ez a
% futtato a regi beallitasra rogzitett (regi_v11_ a fajl vegen).

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));
tab = fullfile(repo, 'output', 'tables');

% =====================================================================
% (1) REGRESSZIO
% =====================================================================
fejlec_('(1) REGRESSZIO: v11 NWSPEC=0 == v10?');
for isc = 1:4
    a = fut_('jv_dsge_v10_foreign', {sprintf('-DSCENARIO=%d', isc), '-DTSCEN=3'});
    b = fut_('jv_dsge_v11', {sprintf('-DSCENARIO=%d', isc), '-DTSCEN=3', '-DNWSPEC=0'});
    d = Inf;
    if a.ok && b.ok && a.solver_ok == 1 && b.solver_ok == 1 && isequal(size(a.simul), size(b.simul))
        d = max(abs(a.simul(:) - b.simul(:)));
    end
    fprintf('  SC=%d: max |v11-v10| = %.3e  %s\n', isc, d, ok_(d < 1e-12));
    if isc == 1, REG = d; else, REG(end+1) = d; end %#ok<AGROW>
end

% =====================================================================
% (2) TECHNIKAI: BK + nulla-sokk
% =====================================================================
fejlec_('(2) TECHNIKAI: BK (kezdeti + terminalis) es nulla-sokk');
tech_cfg = {0, 0.005; 1, 0.005; 2, 0.005; 1, 0.0025; 1, 0.0075};
TT = table();
for ic = 1:size(tech_cfg, 1)
    insp = tech_cfg{ic, 1}; ipi = tech_cfg{ic, 2};
    r1 = fut_('jv_dsge_v11', {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DNWSPEC=%d', insp), ...
        sprintf('-DPINW=%.6g', ipi)});
    r4 = fut_('jv_dsge_v11', {'-DSCENARIO=4', '-DTSCEN=3', sprintf('-DNWSPEC=%d', insp), ...
        sprintf('-DPINW=%.6g', ipi)});
    nulla = Inf; if r4.ok && r4.solver_ok == 1, nulla = max(abs(r4.simul(:))); end
    jo = r1.ok && r1.solver_ok == 1 && r1.B.bk_ok == 1 && r1.B0.bk_ok == 1 && ...
        r1.B.n_unstable == r1.B.n_forward && r1.B0.n_unstable == r1.B0.n_forward && nulla < 1e-12;
    fprintf('  NWSPEC=%d PINW=%.4f: PF=%d BK kezdeti %d (%d/%d) terminalis %d (%d/%d) nulla=%.1e  %s\n', ...
        insp, ipi, r1.solver_ok, r1.B0.bk_ok, r1.B0.n_unstable, r1.B0.n_forward, r1.B.bk_ok, ...
        r1.B.n_unstable, r1.B.n_forward, nulla, ok_(jo));
    TT = [TT; table(insp, ipi, r1.solver_ok, r1.B0.bk_ok, r1.B0.n_unstable, r1.B.bk_ok, ...
        r1.B.n_unstable, r1.B.n_forward, nulla, double(jo), r1.B.nearest_unit_complex, ...
        'VariableNames', {'NWSPEC', 'PINW', 'solver_ok', 'bk_kezdeti', 'n_unstable_kezdeti', ...
        'bk_terminalis', 'n_unstable_terminalis', 'n_forward', 'nulla_sokk_max', 'rendben', ...
        'nearest_unit_complex'})]; %#ok<AGROW>
end
TT.regresszio_max = repmat(max(REG), height(TT), 1);
writetable(TT, fullfile(tab, 't61_nwspec_technikai.csv'));

% =====================================================================
% (3) A01 GDP-SAV
% =====================================================================
fejlec_('(3) A01 GDP-SAV: OPTEN=0, SC x TSCEN, ACCSCALE=100');
GS = table();
for insp = 0:2
    for isc = 1:3
        for its = 1:3
            r = fut_('jv_dsge_v11', {sprintf('-DSCENARIO=%d', isc), sprintf('-DTSCEN=%d', its), ...
                sprintf('-DNWSPEC=%d', insp)});
            GS = [GS; table(insp, isc, its, r.g('y'), r.g('y_E'), r.g('y_D'), r.g('y_L'), ...
                r.ervenyes, 'VariableNames', {'NWSPEC', 'SCENARIO', 'TSCEN', 'GDP_pct', ...
                'y_E_pct', 'y_D_pct', 'y_L_pct', 'ervenyes'})]; %#ok<AGROW>
        end
    end
    m = GS.NWSPEC == insp & GS.ervenyes == 1;
    fprintf('  NWSPEC=%d: GDP-sav %+.3f%% ... %+.3f%%  (BK-ervenyes %d/9)\n', insp, ...
        min(GS.GDP_pct(m)), max(GS.GDP_pct(m)), sum(m));
end
writetable(GS, fullfile(tab, 't61b_nwspec_gdp_sav.csv'));

% =====================================================================
% (4) KKV-KUSZOB
% =====================================================================
fejlec_('(4) KKV-KUSZOB: OPTEN x chi x NWSPEC, ACCSCALE-racs');
racs_acc = [0:2:20, 25:5:50, 60:20:140];
G = table();
for insp = 0:2
    for iop = [0 1]
        for ichi = [-1 0.04]
            for iacc = racs_acc
                args = {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DOPTEN=%d', iop), ...
                    sprintf('-DACCSCALE=%.10g', iacc), sprintf('-DNWSPEC=%d', insp)};
                if ichi > 0, args{end+1} = sprintf('-DCHISYM=%.6g', ichi); end %#ok<AGROW>
                r = fut_('jv_dsge_v11', args);
                G = [G; table(insp, iop, ichi, iacc, r.kkv_l, r.g('y'), r.ervenyes, ...
                    'VariableNames', {'NWSPEC', 'OPTEN', 'chi_szimm', 'accscale', ...
                    'KKV_minus_L_pp', 'GDP_pct', 'ervenyes'})]; %#ok<AGROW>
            end
        end
    end
end
writetable(G, fullfile(tab, 't61c_nwspec_kuszob.csv'));
O = table();
fprintf('%-7s %-6s %-7s %12s %10s %14s %14s\n', 'NWSPEC', 'OPTEN', 'chi', 'kuszob', ...
    'BK@kusz', 'KKV-L @ACC=0', 'KKV-L @ACC=100');
for insp = 0:2
    for iop = [0 1]
        for ichi = [-1 0.04]
            m = G.NWSPEC == insp & G.OPTEN == iop & G.chi_szimm == ichi & G.ervenyes == 1;
            Gm = sortrows(G(m, :), 'accscale');
            k = kuszob_(Gm.accscale, Gm.KKV_minus_L_pp);
            bk = NaN;
            if isfinite(k) && k > 0
                args = {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DOPTEN=%d', iop), ...
                    sprintf('-DACCSCALE=%.10g', k), sprintf('-DNWSPEC=%d', insp)};
                if ichi > 0, args{end+1} = sprintf('-DCHISYM=%.6g', ichi); end %#ok<AGROW>
                bk = fut_('jv_dsge_v11', args).ervenyes;
            elseif k == 0
                bk = 1;
            end
            v0 = valt_(G, insp, iop, ichi, 0); v100 = valt_(G, insp, iop, ichi, 100);
            fprintf('%-7d %-6d %-7s %12.2f %10g %+14.3f %+14.3f\n', insp, iop, chinev_(ichi), ...
                k, bk, v0, v100);
            O = [O; table(insp, iop, ichi, k, bk, sum(m), v0, v100, 'VariableNames', ...
                {'NWSPEC', 'OPTEN', 'chi_szimm', 'kuszob_KKV_L', 'bk_ok_kuszob', ...
                'racs_ervenyes', 'KKV_minus_L_ACC0', 'KKV_minus_L_ACC100'})]; %#ok<AGROW>
        end
    end
end
writetable(O, fullfile(tab, 't61d_nwspec_kuszob_osszegzes.csv'));

% =====================================================================
% (5) A W0 JOSLATA: tartos nw
% =====================================================================
fejlec_('(5) TARTOS nw tipusonkent (OPTEN=0, SC=1, TSCEN=3)');
NW = table();
for insp = 0:2
    for ichi = [-1 0.04]
        for iacc = [0 100]
            args = {'-DSCENARIO=1', '-DTSCEN=3', sprintf('-DACCSCALE=%d', iacc), ...
                sprintf('-DNWSPEC=%d', insp)};
            if ichi > 0, args{end+1} = sprintf('-DCHISYM=%.6g', ichi); end %#ok<AGROW>
            r = fut_('jv_dsge_v11', args);
            NW = [NW; table(insp, ichi, iacc, r.g('nw_E'), r.g('nw_D'), r.g('nw_L'), ...
                r.g('efp_E'), r.g('efp_D'), r.g('efp_L'), r.kkv_l, r.g('y'), ...
                'VariableNames', {'NWSPEC', 'chi_szimm', 'accscale', 'nw_E', 'nw_D', 'nw_L', ...
                'efp_E', 'efp_D', 'efp_L', 'KKV_minus_L_pp', 'GDP_pct'})]; %#ok<AGROW>
            fprintf('  NWSPEC=%d chi=%-6s ACC=%3d: nw E/D/L %+.3f/%+.3f/%+.3f  efp E/D/L %+.3f/%+.3f/%+.3f  KKV-L %+.3f\n', ...
                insp, chinev_(ichi), iacc, r.g('nw_E'), r.g('nw_D'), r.g('nw_L'), ...
                r.g('efp_E'), r.g('efp_D'), r.g('efp_L'), r.kkv_l);
        end
    end
end
writetable(NW, fullfile(tab, 't61e_nwspec_nw_tartos.csv'));
fejlec_('KESZ');

% =====================================================================
function r = fut_(modell, args)
r = struct('ok', false, 'solver_ok', 0, 'ervenyes', 0, 'kkv_l', NaN, 'g', @(v) NaN);
try
    if strcmp(modell, 'jv_dsge_v11'), args = regi_v11_(args); end
    dynare(modell, args{:}, 'console', 'nograph');
    M = evalin('base', 'M_'); oo = evalin('base', 'oo_'); op = evalin('base', 'options_');
    r.simul = oo.endo_simul;
    r.solver_ok = double(oo.deterministic_simulation.status);
    r.B = bk_check_metrics(M, op, oo);
    oo0 = oo;
    oo0.steady_state = zeros(M.endo_nbr, 1);
    oo0.exo_steady_state = zeros(M.exo_nbr, 1);
    oo0.exo_det_steady_state = zeros(M.exo_det_nbr, 1);
    r.B0 = bk_check_metrics(M, op, oo0);
    r.ervenyes = double(r.solver_ok == 1 && r.B.check_ok == 1 && r.B.bk_ok == 1);
    n = cellstr(M.endo_names);
    ss = oo.steady_state;
    r.g = @(v) 100 * ss(strcmp(n, v));
    pn = cellstr(M.param_names);
    p = @(v) M.params(strcmp(pn, v));
    wE = p('om_E') / (p('om_E') + p('om_D'));
    wD = p('om_D') / (p('om_E') + p('om_D'));
    r.kkv_l = wE*r.g('y_E') + wD*r.g('y_D') - r.g('y_L');
    r.ok = true;
catch ME
    fprintf(2, '  !! HIBA (%s %s): %s\n', modell, strjoin(args, ' '), ME.message);
end
end

function v = valt_(G, insp, iop, ichi, iacc)
m = G.NWSPEC == insp & G.OPTEN == iop & G.chi_szimm == ichi & G.accscale == iacc;
v = NaN; if any(m), v = G.KKV_minus_L_pp(find(m, 1)); end
end

function k = kuszob_(x, d)
% = stress_opten_v09.m kuszob_
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

function fejlec_(s)
fprintf('\n%s\n%s\n%s\n', repmat('=', 1, 80), s, repmat('=', 1, 80));
end

function s = ok_(c)
if c, s = 'RENDBEN'; else, s = '*** BUKOTT ***'; end
end

function a = regi_v11_(a)
% 2026-10-07: a v11 alapertelmezese a vegleges kalibracio (KALIB=1, EXTCLOSE=1,
% SOVCSAT=1, HORIZON=400). Ez a futtato a REGI beallitasra rogzitett: amit a
% hivas nem ad meg kifejezetten, azt a regi ertekre allitjuk, hogy a tarolt
% tablak reprodukalhatok maradjanak.
alap = {'KALIB', '0'; 'EXTCLOSE', '0'; 'SOVCSAT', '0'; 'HORIZON', '120'};
for i = 1:size(alap, 1)
    if ~any(startsWith(a, ['-D' alap{i, 1} '=']))
        a{end+1} = ['-D' alap{i, 1} '=' alap{i, 2}]; %#ok<AGROW>
    end
end
end
