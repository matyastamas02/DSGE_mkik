function [CANDIDATE_MATRIX, CANDIDATE_TESTS] = bk_candidate_compare_v09
%BK_CANDIDATE_COMPARE_V09 Izolalt BK-jelolt a fo v09 modositasa nelkul.
% =====================================================================
% A script NEM irja at a jv_dsge_v09_access.mod fajlt es NEM ir a rendes
% output/ mappaba. Egy ideiglenes konyvtarban ket modellt general:
%   - main_reference: a jelenlegi v09 bitazonos masolata;
%   - bk_candidate:   explicit RHOACC + kapcsolhato ACCNORM valtozat.
%
% A jelolt ket kulon dontest tesztel:
%   (1) rho_acc ne legyen az OPTEN kapcsolo mellekhatasakent beallitva;
%   (2) ACCNORM=1 eseten az access-innovacio (1-rho_acc)-szorzot kapjon.
% A generalt jelolt elofeldolgozasi orokkel csak OPTEN=0|1|2,
% 0<RHOACC<1 es ACCNORM=0|1 ertekeket fogad el.
%
% FONTOS: (2) NEM semleges BK-javitas. Fix rho mellett ugyanaz, mint a
% lambda_acc (1-rho)-szoros csokkentese. Emiatt csak kulon strukturális
% erzekenysegi ag, nem ajanlott uj alapmodell.
%
% Opcionális CSV-kimenet:
%   set BK_CANDIDATE_OUT_DIR=<letezo vagy letrehozhato konyvtar>
%   matlab -batch "cd('src/4_infra'); bk_candidate_compare_v09"
%   Kimenet: bk_candidate_matrix.csv, bk_candidate_tests.csv,
%            bk_candidate_rho_regression.csv

repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));

model_dir = fullfile(repo, 'src', 'modell', '1_fo_vonal_jv');
main_path = fullfile(model_dir, 'jv_dsge_v09_access.mod');
v08_path = fullfile(model_dir, 'jv_dsge_v08_3type_arak.mod');
if ~isfile(main_path), error('Hianyzik a fo v09 modell: %s', main_path); end
if ~isfile(v08_path), error('Hianyzik a v08 referencia: %s', v08_path); end

tmp_dir = tempname;
mkdir(tmp_dir);
tmp_cleanup = onCleanup(@() cleanup_tmp_(tmp_dir));
old_dir = pwd;
dir_cleanup = onCleanup(@() cd(old_dir));

main_text = normalize_lf_(fileread(main_path));
candidate_text = make_candidate_(main_text);
v08_text = normalize_lf_(fileread(v08_path));

write_text_(fullfile(tmp_dir, 'jv_dsge_v09_main_reference.mod'), main_text);
write_text_(fullfile(tmp_dir, 'jv_dsge_v09_bk_candidate.mod'), candidate_text);
write_text_(fullfile(tmp_dir, 'jv_dsge_v08_reference.mod'), v08_text);
cd(tmp_dir);

fprintf('\n%s\n', repmat('=', 1, 94));
fprintf('IZOLALT BK-MODELLJELOLT — a fo v09 fajl valtozatlan marad\n');
fprintf('%s\n', repmat('=', 1, 94));

%% 1. Teljes jeloltmatrix: minden szcenario es transzmisszios palya
rhos = [0.85 0.9673];
norms = [0 1];
CANDIDATE_MATRIX = table();
for rho = rhos
    for norm = norms
        for sc = 1:3
            for ts = 1:3
                args = {sprintf('-DOPTEN=1'), sprintf('-DSCENARIO=%d', sc), ...
                    sprintf('-DTSCEN=%d', ts), sprintf('-DRHOACC=%.10g', rho), ...
                    sprintf('-DACCNORM=%d', norm), '-DACCSCALE=100'};
                r = run_model_('jv_dsge_v09_bk_candidate', args);
                r.rho_keres = rho;
                r.ACCNORM = norm;
                r.SCENARIO = sc;
                r.TSCEN = ts;
                r = movevars(r, {'rho_keres','ACCNORM','SCENARIO','TSCEN'}, ...
                    'Before', 1);
                CANDIDATE_MATRIX = [CANDIDATE_MATRIX; r]; %#ok<AGROW>
                fprintf(['rho=%.4f norm=%d sc=%d ts=%d  PF=%d  ' ...
                    'BK(init/term)=%g/%g  U/F(term)=%g/%g\n'], rho, norm, ...
                    sc, ts, r.solver_ok, r.bk_initial_ok, r.bk_terminal_ok, ...
                    r.n_unstable_terminal, r.n_forward);
            end
        end
    end
end

%% 2. Bitazonos regressziok a jelenlegi fo v09-hez
tests = strings(0, 1);
passed = zeros(0, 1);
metric = zeros(0, 1);
limit = zeros(0, 1);
note = strings(0, 1);

[tests, passed, metric, limit, note] = add_pair_test_(tests, passed, ...
    metric, limit, note, "main OPTEN0 = candidate rho=.85 norm=0", ...
    run_model_('jv_dsge_v09_main_reference', ...
        {'-DOPTEN=0','-DSCENARIO=1','-DTSCEN=3','-DACCSCALE=100'}), ...
    run_model_('jv_dsge_v09_bk_candidate', ...
        {'-DOPTEN=0','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.85', ...
        '-DACCNORM=0','-DACCSCALE=100'}), 1e-10);

[tests, passed, metric, limit, note] = add_pair_test_(tests, passed, ...
    metric, limit, note, "main OPTEN1 implicit magas rho = explicit candidate", ...
    run_model_('jv_dsge_v09_main_reference', ...
        {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DACCSCALE=100'}), ...
    run_model_('jv_dsge_v09_bk_candidate', ...
        {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.9673', ...
        '-DACCNORM=0','-DACCSCALE=100'}), 1e-10);

[tests, passed, metric, limit, note] = add_pair_test_(tests, passed, ...
    metric, limit, note, "main explicit rho=.85 = candidate rho=.85 norm=0", ...
    run_model_('jv_dsge_v09_main_reference', ...
        {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.85', ...
        '-DACCSCALE=100'}), ...
    run_model_('jv_dsge_v09_bk_candidate', ...
        {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.85', ...
        '-DACCNORM=0','-DACCSCALE=100'}), 1e-10);

%% 2B. Rho/OPTEN szetvalasztasi regresszio a modell parametervektorabol
% Szandekosan egyik torteneti rho-ertekkel sem azonos probaertek. Ha az
% OPTEN barmelyik aga felulirna, az M_.params-bol visszaolvasott ertek
% azonnal elterne.
rho_probe = 0.9123456789;
rho_opten = (0:2)';
rho_requested = repmat(rho_probe, numel(rho_opten), 1);
rho_actual = nan(size(rho_opten));
rho_solver_ok = zeros(size(rho_opten));
rho_run_error = strings(size(rho_opten));
for i = 1:numel(rho_opten)
    rrho = run_model_('jv_dsge_v09_bk_candidate', ...
        {sprintf('-DOPTEN=%d', rho_opten(i)), '-DSCENARIO=1', ...
        '-DTSCEN=3', sprintf('-DRHOACC=%.10g', rho_probe), ...
        '-DACCNORM=0', '-DACCSCALE=0'});
    rho_actual(i) = rrho.rho_tenyleges;
    rho_solver_ok(i) = rrho.solver_ok;
    rho_run_error(i) = rrho.hiba;
end
rho_abs_error = abs(rho_actual-rho_requested);
CANDIDATE_RHO_REGRESSION = table(rho_opten, rho_requested, rho_actual, ...
    rho_abs_error, rho_solver_ok, rho_run_error, 'VariableNames', ...
    {'OPTEN','rho_keres','rho_tenyleges','abs_elteres','solver_ok','hiba'});

rho_tol = 1e-12;
rho_regression_ok = all(isfinite(rho_actual)) && ...
    all(rho_abs_error < rho_tol) && max(rho_actual)-min(rho_actual) < rho_tol;
rho_metric = max(rho_abs_error);
if ~isfinite(rho_metric), rho_metric = Inf; end
tests(end+1, 1) = "explicit azonos rho-t az OPTEN=0/1/2 nem irja felul";
passed(end+1, 1) = double(rho_regression_ok);
metric(end+1, 1) = rho_metric;
limit(end+1, 1) = rho_tol;
note(end+1, 1) = sprintf('M_.params rho=[%.10g %.10g %.10g]', rho_actual);

%% 3. Nesting es a normalizalas pontos azonossagai
v08 = run_model_('jv_dsge_v08_reference', ...
    {'-DSCENARIO=1','-DTSCEN=3'});
for norm = [0 1]
    cand0 = run_model_('jv_dsge_v09_bk_candidate', ...
        {'-DOPTEN=0','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.85', ...
        sprintf('-DACCNORM=%d', norm), '-DACCSCALE=0'});
    [tests, passed, metric, limit, note] = add_pair_test_(tests, passed, ...
        metric, limit, note, sprintf("ACCSCALE=0 nesting v08 (norm=%d)", norm), ...
        v08, cand0, 1e-10);
end

norm_hi = run_model_('jv_dsge_v09_bk_candidate', ...
    {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.9673', ...
    '-DACCNORM=1','-DLAMSCALE=100','-DOMSCALE=100'});
legacy_low_lambda = run_model_('jv_dsge_v09_bk_candidate', ...
    {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.9673', ...
    '-DACCNORM=0','-DLAMSCALE=3.27','-DOMSCALE=100'});
[tests, passed, metric, limit, note] = add_pair_test_(tests, passed, ...
    metric, limit, note, ...
    "norm=1 LAM100 = legacy LAM3.27 (96.73% hurokero-vagas)", ...
    norm_hi, legacy_low_lambda, 1e-9);

compensated = run_model_('jv_dsge_v09_bk_candidate', ...
    {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.9673', ...
    '-DACCNORM=1','-DLAMSCALE=3058.103975535','-DOMSCALE=100'});
legacy_hi = run_model_('jv_dsge_v09_bk_candidate', ...
    {'-DOPTEN=1','-DSCENARIO=1','-DTSCEN=3','-DRHOACC=0.9673', ...
    '-DACCNORM=0','-DLAMSCALE=100','-DOMSCALE=100'});
[tests, passed, metric, limit, note] = add_pair_test_(tests, passed, ...
    metric, limit, note, ...
    "lambda-visszaskalazas visszaadja a legacy dinamikat es BK-hibat", ...
    compensated, legacy_hi, 1e-8);

%% 4. Elore rogzitett minosegi orok
mask_low_legacy = CANDIDATE_MATRIX.rho_keres == 0.85 & ...
    CANDIDATE_MATRIX.ACCNORM == 0;
mask_high_legacy = CANDIDATE_MATRIX.rho_keres == 0.9673 & ...
    CANDIDATE_MATRIX.ACCNORM == 0;
mask_high_norm = CANDIDATE_MATRIX.rho_keres == 0.9673 & ...
    CANDIDATE_MATRIX.ACCNORM == 1;

[tests, passed, metric, limit, note] = add_bool_test_(tests, passed, ...
    metric, limit, note, "minden jelolt PF futas megoldodott", ...
    all(CANDIDATE_MATRIX.solver_ok == 1), ...
    sum(CANDIDATE_MATRIX.solver_ok == 1), height(CANDIDATE_MATRIX));
[tests, passed, metric, limit, note] = add_bool_test_(tests, passed, ...
    metric, limit, note, "az inicialis uni=0 rezsim mindenhol BK-stabil", ...
    all(CANDIDATE_MATRIX.bk_initial_ok == 1), ...
    sum(CANDIDATE_MATRIX.bk_initial_ok == 1), height(CANDIDATE_MATRIX));
[tests, passed, metric, limit, note] = add_bool_test_(tests, passed, ...
    metric, limit, note, "rho=.85 legacy terminalis BK-stabil", ...
    all(CANDIDATE_MATRIX.bk_terminal_ok(mask_low_legacy) == 1), ...
    sum(CANDIDATE_MATRIX.bk_terminal_ok(mask_low_legacy) == 1), sum(mask_low_legacy));
[tests, passed, metric, limit, note] = add_bool_test_(tests, passed, ...
    metric, limit, note, "rho=.9673 legacy reprodukalja a terminalis BK-hibat", ...
    all(CANDIDATE_MATRIX.bk_terminal_ok(mask_high_legacy) == 0), ...
    sum(CANDIDATE_MATRIX.bk_terminal_ok(mask_high_legacy) == 0), sum(mask_high_legacy));
[tests, passed, metric, limit, note] = add_bool_test_(tests, passed, ...
    metric, limit, note, "rho=.9673 normalizalt jelolt terminalis BK-stabil", ...
    all(CANDIDATE_MATRIX.bk_terminal_ok(mask_high_norm) == 1), ...
    sum(CANDIDATE_MATRIX.bk_terminal_ok(mask_high_norm) == 1), sum(mask_high_norm));

CANDIDATE_TESTS = table(tests, passed, metric, limit, note, ...
    'VariableNames', {'teszt','rendben','meroszam','turhatar_vagy_cel','megjegyzes'});

% A diagnosztikai tablakat az audit-assert ELOTT kell tartosra irni. Igy
% egy szandekosan elbukott negativ kontroll vagy regresszio utan is megmarad
% minden sor, ami a hiba feltarasahoz kell.
out_dir = getenv('BK_CANDIDATE_OUT_DIR');
if ~isempty(out_dir)
    if ~isfolder(out_dir), mkdir(out_dir); end
    writetable(CANDIDATE_MATRIX, fullfile(out_dir, 'bk_candidate_matrix.csv'));
    writetable(CANDIDATE_TESTS, fullfile(out_dir, 'bk_candidate_tests.csv'));
    writetable(CANDIDATE_RHO_REGRESSION, ...
        fullfile(out_dir, 'bk_candidate_rho_regression.csv'));
    fprintf('CSV-k kiirva az assert elott: %s\n', out_dir);
else
    fprintf('CSV nem keszult (BK_CANDIDATE_OUT_DIR nincs beallitva).\n');
end

fprintf('\n%s\n', repmat('-', 1, 94));
disp(CANDIDATE_TESTS);
assert(all(CANDIDATE_TESTS.rendben == 1), ...
    'A BK-modelljelolt legalabb egy kotelezo tesztje elbukott.');

fprintf('BK-MODELLJELOLT OSSZEHASONLITAS KESZ.\n');
end

function text = make_candidate_(text)
text = strrep(text, 'jv_dsge_v09_access.mod', ...
    'jv_dsge_v09_bk_candidate.mod');

% A fejlec javitasa opcionális: a helyes mukodest az alábbi, stabil
% makroblokkok koze irt dokumentacio es az elofeldolgozasi or garantalja.
text = strrep(text, '-DOPTEN=0|1|2|3', '-DOPTEN=0|1|2');

acc_anchor = sprintf(['@#ifndef ACCSCALE\n' ...
    '  @#define ACCSCALE = 100\n@#endif']);
acc_replacement = sprintf(['%s\n' ...
    '// KULON STRUKTURALIS JELOLT; 0 = legacy, 1 = (1-rho) normalizalt.\n' ...
    '@#ifndef ACCNORM\n  @#define ACCNORM = 0\n@#endif\n' ...
    '@#if ACCNORM != 0 && ACCNORM != 1\n' ...
    '  @#error "ACCNORM must be 0 or 1"\n@#endif'], acc_anchor);
text = replace_once_(text, acc_anchor, acc_replacement, 'ACCNORM beszurasa');

decompw_anchor = sprintf(['@#ifndef DECOMPW\n' ...
    '  @#define DECOMPW = 1\n@#endif']);
opten_anchor = sprintf(['@#ifndef OPTEN\n' ...
    '  @#define OPTEN = 0\n@#endif']);
opten_replacement = sprintf(['%s\n' ...
    '// BK-CANDIDATE: OPTEN csak 0|1|2; rho_acc-ot csak RHOACC valaszt.\n' ...
    '%s\n' ...
    '@#if OPTEN != 0 && OPTEN != 1 && OPTEN != 2\n' ...
    '  @#error "OPTEN must be 0, 1, or 2; use RHOACC for rho_acc"\n' ...
    '@#endif'], decompw_anchor, opten_anchor);
text = replace_block_(text, decompw_anchor, opten_anchor, ...
    opten_replacement, 'OPTEN dokumentacio es tartomanyor');

rho_start = 'rho_acc = 0.85;';
rho_end = sprintf(['@#if RHOACC > 0\n' ...
    'rho_acc = @{RHOACC};\n@#endif']);
rho_replacement = sprintf([ ...
    '// JELOLT: rho_acc explicit, es nem az OPTEN mellekhatasa.\n' ...
    '@#ifndef RHOACC\n  @#define RHOACC = 0.85\n@#endif\n' ...
    '@#if RHOACC <= 0 || RHOACC >= 1\n' ...
    '  @#error "RHOACC must satisfy 0 < RHOACC < 1"\n@#endif\n' ...
    'rho_acc = @{RHOACC};']);
text = replace_block_(text, rho_start, rho_end, rho_replacement, ...
    'rho_acc/OPTEN szetvalasztasa');

eq_anchor = sprintf([ ...
    'acc_E = rho_acc*acc_E(-1) - lambda_acc_E*efp_E;\n' ...
    'acc_D = rho_acc*acc_D(-1) - lambda_acc_D*efp_D;']);
eq_replacement = sprintf([ ...
    '@#if ACCNORM == 1\n' ...
    'acc_E = rho_acc*acc_E(-1) - (1-rho_acc)*lambda_acc_E*efp_E;\n' ...
    'acc_D = rho_acc*acc_D(-1) - (1-rho_acc)*lambda_acc_D*efp_D;\n' ...
    '@#else\n' ...
    'acc_E = rho_acc*acc_E(-1) - lambda_acc_E*efp_E;\n' ...
    'acc_D = rho_acc*acc_D(-1) - lambda_acc_D*efp_D;\n' ...
    '@#endif']);
text = replace_once_(text, eq_anchor, eq_replacement, ...
    'ACCNORM egyenletag');
end

function R = run_model_(model_name, args) %#ok<INUSD>
try
    evalc("dynare(model_name, args{:}, 'console', 'nograph', 'noclearall')");
    M = evalin('base', 'M_');
    oo = evalin('base', 'oo_');
    options = evalin('base', 'options_');
    solver_ok = double(oo.deterministic_simulation.status);

    bt = bk_check_metrics(M, options, oo);
    oo0 = oo;
    oo0.steady_state = zeros(M.endo_nbr, 1);
    oo0.exo_steady_state = zeros(M.exo_nbr, 1);
    oo0.exo_det_steady_state = zeros(M.exo_det_nbr, 1);
    bi = bk_check_metrics(M, options, oo0);

    names = strtrim(cellstr(M.endo_names));
    get = @(v) 100 * oo.steady_state(strcmp(names, v));
    pnames = strtrim(cellstr(M.param_names));
    getp = @(v) M.params(strcmp(pnames, v));
    wE = getp('om_E')/(getp('om_E')+getp('om_D'));
    wD = getp('om_D')/(getp('om_E')+getp('om_D'));
    ykkv = wE*get('y_E') + wD*get('y_D');

    rho_actual = NaN;
    rho_idx = strcmp(pnames, 'rho_acc');
    if any(rho_idx), rho_actual = M.params(rho_idx); end

    R = table(solver_ok, bt.check_ok, bt.bk_ok, bi.check_ok, bi.bk_ok, ...
        bt.n_forward, bt.n_unstable, bi.n_unstable, bt.qz_criterium, ...
        bt.info_code, bt.nearest_unit_complex, rho_actual, get('y'), ...
        get('y_E'), get('y_D'), get('y_L'), ykkv-get('y_L'), "", ...
        'VariableNames', {'solver_ok','bk_terminal_check_ok','bk_terminal_ok', ...
        'bk_initial_check_ok','bk_initial_ok','n_forward','n_unstable_terminal', ...
        'n_unstable_initial','bk_qz_criterium','bk_info_code_terminal', ...
        'nearest_unit_complex_terminal','rho_tenyleges','GDP_pct','y_E_pct', ...
        'y_D_pct','y_L_pct','KKV_minus_L_pp','hiba'});
catch ME
    R = table(0, 0, NaN, 0, NaN, NaN, NaN, NaN, NaN, NaN, NaN, ...
        NaN, NaN, NaN, NaN, NaN, NaN, string(ME.message), ...
        'VariableNames', {'solver_ok','bk_terminal_check_ok','bk_terminal_ok', ...
        'bk_initial_check_ok','bk_initial_ok','n_forward','n_unstable_terminal', ...
        'n_unstable_initial','bk_qz_criterium','bk_info_code_terminal', ...
        'nearest_unit_complex_terminal','rho_tenyleges','GDP_pct','y_E_pct', ...
        'y_D_pct','y_L_pct','KKV_minus_L_pp','hiba'});
end
end

function [tests, passed, metric, limit, note] = add_pair_test_( ...
        tests, passed, metric, limit, note, name, a, b, tol)
d = max(abs([a.GDP_pct-b.GDP_pct, a.y_E_pct-b.y_E_pct, ...
    a.y_D_pct-b.y_D_pct, a.y_L_pct-b.y_L_pct, ...
    a.KKV_minus_L_pp-b.KKV_minus_L_pp, ...
    a.nearest_unit_complex_terminal-b.nearest_unit_complex_terminal]));
same_status = a.solver_ok == b.solver_ok && ...
    isequaln(a.bk_terminal_ok, b.bk_terminal_ok) && ...
    isequaln(a.n_unstable_terminal, b.n_unstable_terminal);
tests(end+1, 1) = string(name);
passed(end+1, 1) = double(same_status && d < tol);
metric(end+1, 1) = d;
limit(end+1, 1) = tol;
note(end+1, 1) = sprintf('statuszazonos=%d', same_status);
end

function [tests, passed, metric, limit, note] = add_bool_test_( ...
        tests, passed, metric, limit, note, name, ok, value, target)
tests(end+1, 1) = string(name);
passed(end+1, 1) = double(ok);
metric(end+1, 1) = value;
limit(end+1, 1) = target;
note(end+1, 1) = "darab/cel";
end

function text = normalize_lf_(text)
cr = char(13); lf = newline;
text = strrep(text, [cr lf], lf);
text = strrep(text, cr, lf);
end

function text = replace_once_(text, old, new, label)
hits = strfind(text, old);
if ~isscalar(hits)
    error('%s: vart 1 minta, talalt %d.', label, numel(hits));
end
text = strrep(text, old, new);
end

function text = replace_block_(text, first, last, replacement, label)
starts = strfind(text, first);
if ~isscalar(starts), error('%s: a kezdominta nem egyedi.', label); end
tails = strfind(text, last);
tails = tails(tails >= starts(1));
if ~isscalar(tails), error('%s: a zaro minta nem egyedi.', label); end
block_end = tails(1) + length(last) - 1;
text = [text(1:starts(1)-1), replacement, text(block_end+1:end)];
end

function write_text_(path, text)
[fid, msg] = fopen(path, 'w', 'n', 'UTF-8');
if fid < 0, error('Nem irhato %s: %s', path, msg); end
closer = onCleanup(@() fclose(fid));
fprintf(fid, '%s', text);
end

function cleanup_tmp_(path)
if isfolder(path)
    try
        if startsWith(pwd, path, 'IgnoreCase', true)
            cd(tempdir);
        end
        rmdir(path, 's');
    catch
        fprintf(2, 'FIGYELEM: az ideiglenes jeloltmappa nem torolheto: %s\n', path);
    end
end
end
