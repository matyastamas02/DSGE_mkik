% bk_diagnosztika_v09.m — valodi Blanchard–Kahn audit a fo v09 modellhez
% =========================================================================
% CEL
%   A jelenlegi stressz-futtatok `oo_.deterministic_simulation.status`
%   mezoje csak azt mondja meg, hogy a perfect-foresight solver talalt-e
%   numerikus palyat. Ez NEM Blanchard–Kahn-teszt. Ez a kulonallo script a
%   Dynare `check(M_, options_, oo_)` rutinjaval meri a determinaciot.
%
% FONTOS MUNKAFOLYAMAT
%   - A fo .mod fajlt es a meglevo futtatokat NEM modositja.
%   - Script-formaban fut, mert a Dynare a base workspace-t hasznalja.
%   - Minden Dynare-hivas `noclearall`, a sajat valtozok `bkx_` prefixuek.
%   - Alapbol csak a konzolra ir. CSV-t csak akkor ir, ha a
%     BK_DIAG_OUT_DIR kornyezeti valtozo egy letezo vagy letrehozhato
%     konyvtarra mutat.
%
% FUTTATAS
%   matlab -batch "cd('src/4_infra'); bk_diagnosztika_v09"
%
% KIMENETEK A MATLAB WORKSPACE-BEN
%   BK_DIAG_MAIN       36 fo konfiguracio: solver-statusz vs. valodi BK
%   BK_DIAG_REGIME     inicialis uni=0 es terminalis uni=1 lokalis rezsim
%   BK_DIAG_ISOLATION  az E/D access-hurkok es a lambda/omega lepcsok
%   BK_DIAG_CHANNEL    az E es D hurok kulon erosseg-scanje
%   BK_DIAG_BOUNDARY   finom stabilitasi hatar ACCSCALE es rho_acc szerint
%   BK_DIAG_LIMITS     biszekcios also/felso korlat a ket kritikus hatarra
%
% OPCIONALIS CSV
%   set BK_DIAG_OUT_DIR=<konyvtar>
%   Ekkor a hat tabla `bk_main.csv`, `bk_regime.csv`, `bk_isolation.csv`,
%   `bk_channel.csv`, `bk_boundary.csv` es `bk_limits.csv` neven oda kerul.
%   A repo outputjat a script alapbol szandekosan nem irja felul.

bkx_here = fileparts(mfilename('fullpath'));
bkx_repo = fileparts(fileparts(bkx_here));
bkx_model_dir = fullfile(bkx_repo, 'src', 'modell', '1_fo_vonal_jv');
bkx_model_file = fullfile(bkx_model_dir, 'jv_dsge_v09_access.mod');
assert(isfile(bkx_model_file), 'A fo modell nem talalhato: %s', bkx_model_file);

bkx_dynare = getenv('DYNARE_PATH');
if isempty(bkx_dynare)
    bkx_dynare = 'C:\dynare\6.5\matlab';
end
assert(isfolder(bkx_dynare), ...
    'A Dynare konyvtar nem talalhato. Allitsd be a DYNARE_PATH valtozot: %s', ...
    bkx_dynare);
addpath(bkx_dynare);

bkx_start_dir = pwd;
bkx_cleanup = onCleanup(@() cd(bkx_start_dir));
cd(bkx_model_dir);
bkx_qz = 1 + 1e-6;

fprintf('\n============================================================\n');
fprintf('VALODI BK-DIAGNOSZTIKA — jv_dsge_v09_access\n');
fprintf('============================================================\n');
fprintf('A solver-statusz es a BK-feltetel kulon oszlop.\n\n');

%% 1. A 36 FO KONFIGURACIO
% Az OPTEN-sorrend azonos a stress_opten_v09.m sorrendjevel.
bkx_opten_grid = [0 3 1 2];
bkx_n_main = numel(bkx_opten_grid) * 3 * 3;
bkx_main_num = nan(bkx_n_main, 14);
bkx_main_info = strings(bkx_n_main, 1);
bkx_row = 0;

for bkx_oi = 1:numel(bkx_opten_grid)
    for bkx_sc = 1:3
        for bkx_ts = 1:3
            bkx_row = bkx_row + 1;
            bkx_req_op = bkx_opten_grid(bkx_oi);
            bkx_req_sc = bkx_sc;
            bkx_req_ts = bkx_ts;
            bkx_cmd = sprintf([ ...
                'dynare jv_dsge_v09_access -DSCENARIO=%d -DTSCEN=%d ' ...
                '-DOPTEN=%d -DACCSCALE=100 console nograph noclearall'], ...
                bkx_req_sc, bkx_req_ts, bkx_req_op);
            evalc(bkx_cmd);

            bkx_solver_ok = double(oo_.deterministic_simulation.status);
            options_.noprint = 1;
            options_.qz_criterium = bkx_qz;
            [bkx_ev, bkx_bk_ok, bkx_info] = check(M_, options_, oo_);
            [bkx_unstable, bkx_root1, bkx_root2, bkx_critical_complex] = ...
                bkx_root_stats_(bkx_ev, M_.nsfwrd, bkx_qz);
            bkx_rho = bkx_param_(M_, 'rho_acc');

            bkx_info_code = bkx_info(1);
            if numel(bkx_info) > 1
                bkx_info_value = bkx_info(2);
            else
                bkx_info_value = NaN;
            end
            bkx_main_num(bkx_row, :) = [bkx_req_op bkx_req_sc bkx_req_ts ...
                100 bkx_rho bkx_solver_ok double(bkx_bk_ok) M_.nsfwrd ...
                bkx_unstable bkx_root1 bkx_root2 bkx_critical_complex ...
                bkx_info_code bkx_info_value];
            bkx_main_info(bkx_row) = string(mat2str(bkx_info));

            fprintf(['MAIN op=%d sc=%d ts=%d  solver=%d  BK=%d  ' ...
                'fw=%d unstable=%d critical_complex=%.6f\n'], ...
                bkx_req_op, bkx_req_sc, bkx_req_ts, bkx_solver_ok, ...
                bkx_bk_ok, M_.nsfwrd, bkx_unstable, bkx_critical_complex);
        end
    end
end

BK_DIAG_MAIN = array2table(bkx_main_num, 'VariableNames', { ...
    'OPTEN','SCENARIO','TSCEN','ACCSCALE','rho_acc','solver_ok','bk_ok', ...
    'n_forward','n_unstable','rank_fw_plus_1','rank_fw_plus_2', ...
    'critical_complex_modulus', ...
    'info_code','info_value'});
BK_DIAG_MAIN.info = bkx_main_info;

fprintf('\nFO RACs OSSZEGZES\n');
fprintf('  perfect-foresight solver: %d / %d\n', ...
    sum(BK_DIAG_MAIN.solver_ok == 1), height(BK_DIAG_MAIN));
fprintf('  valodi BK-feltetel:       %d / %d\n', ...
    sum(BK_DIAG_MAIN.bk_ok == 1), height(BK_DIAG_MAIN));

%% 1B. A KET LOKALIS REZSIM KULON ELLENORZESE
% A perfect-foresight palya idoben valtozo rendszer, igy ez a ket lokalis
% check nem teljes rezsimvaltas-tetel. A permanens endval ertelmezesehez
% viszont a terminalis uni=1 rezsim determinacioja kotelezo. Az inicialis
% ellenproba megmutatja, hogy a hiba mar a belepes elott is fennall-e.
bkx_n_regime = numel(bkx_opten_grid) * 2;
bkx_regime_name = strings(bkx_n_regime, 1);
bkx_regime_num = nan(bkx_n_regime, 10);
bkx_row = 0;

for bkx_oi = 1:numel(bkx_opten_grid)
    bkx_req_op = bkx_opten_grid(bkx_oi);
    bkx_cmd = sprintf([ ...
        'dynare jv_dsge_v09_access -DSCENARIO=1 -DTSCEN=3 ' ...
        '-DOPTEN=%d -DACCSCALE=100 console nograph noclearall'], bkx_req_op);
    evalc(bkx_cmd);
    options_.noprint = 1;
    options_.qz_criterium = bkx_qz;

    for bkx_regime = 0:1
        bkx_row = bkx_row + 1;
        bkx_oo_regime = oo_;
        if bkx_regime == 0
            % A modell log-linearis, ezert a nulla endogen steady state
            % mindket rezsimben egzakt. A determinisztikus exogenek kozul
            % uni=0, sov=0 es bank=0 adja az inicialis lebegeto rezsimet.
            bkx_regime_name(bkx_row) = "inicialis uni=0";
            bkx_oo_regime.steady_state = zeros(M_.endo_nbr, 1);
            bkx_oo_regime.exo_steady_state = zeros(M_.exo_nbr, 1);
            bkx_oo_regime.exo_det_steady_state = zeros(M_.exo_det_nbr, 1);
        else
            bkx_regime_name(bkx_row) = "terminalis uni=1";
        end

        [bkx_ev, bkx_bk_ok, bkx_info] = check(M_, options_, bkx_oo_regime);
        [bkx_unstable, bkx_root1, bkx_root2, bkx_critical_complex] = ...
            bkx_root_stats_(bkx_ev, M_.nsfwrd, bkx_qz);
        bkx_regime_num(bkx_row, :) = [bkx_req_op bkx_regime ...
            bkx_param_(M_, 'rho_acc') double(bkx_bk_ok) M_.nsfwrd ...
            bkx_unstable bkx_root1 bkx_root2 bkx_critical_complex bkx_info(1)];
        fprintf(['REGIME op=%d %s BK=%d fw=%d unstable=%d ' ...
            'critical_complex=%.6f\n'], bkx_req_op, ...
            bkx_regime_name(bkx_row), bkx_bk_ok, M_.nsfwrd, ...
            bkx_unstable, bkx_critical_complex);
    end
end

BK_DIAG_REGIME = array2table(bkx_regime_num, 'VariableNames', { ...
    'OPTEN','uni','rho_acc','bk_ok','n_forward','n_unstable', ...
    'rank_fw_plus_1','rank_fw_plus_2','critical_complex_modulus','info_code'});
BK_DIAG_REGIME.rezsim = bkx_regime_name;
BK_DIAG_REGIME = movevars(BK_DIAG_REGIME, 'rezsim', 'Before', 2);

%% 2. GYOKEROK IZOLALASA PARAMETER-ATIRASSAL
% A modell egyenletei linearisak az endogen valtozokban, ezert a dinamikus
% Jacobian nem fugg a steady-state szintjetol. A mar preprocesszalt M_
% parametervektoraban igy biztonsagosan kikapcsolhatok az egyes access-
% hurkok, majd ugyanazzal a Dynare `check` rutinnal ujramerethetok a gyokok.
%
% Friss, egyertelmu bazis: OPTEN=1, SCENARIO=1, TSCEN=3, ACCSCALE=100.
bkx_cmd = ['dynare jv_dsge_v09_access -DSCENARIO=1 -DTSCEN=3 ' ...
    '-DOPTEN=1 -DACCSCALE=100 console nograph noclearall'];
evalc(bkx_cmd);
options_.noprint = 1;
options_.qz_criterium = bkx_qz;
bkx_M_base = M_;
bkx_oo_base = oo_;

bkx_iso_names = [ ...
    "bazis: E+D access";
    "nincs omega: access nem hat a beruhazasra";
    "nincs lambda: EFP nem hat az accessre";
    "csak E access-hurok";
    "csak D access-hurok";
    "E elso lepcso nelkul: lambda_E=0";
    "D elso lepcso nelkul: lambda_D=0";
    "azonos szorzat: lambda x2, omega x0.5";
    "azonos szorzat: lambda x0.5, omega x2";
    "fel szorzat: lambda x0.5";
    "rho_acc = 0.85, teljes access"
];
bkx_n_iso = numel(bkx_iso_names);
bkx_iso_num = nan(bkx_n_iso, 13);

for bkx_i = 1:bkx_n_iso
    M_ = bkx_M_base;
    oo_ = bkx_oo_base;

    % [lambda_E lambda_D omega_E omega_D rho] szorzok / felulirasok.
    bkx_lam_E_mult = 1; bkx_lam_D_mult = 1;
    bkx_om_E_mult = 1;  bkx_om_D_mult = 1;
    bkx_rho_override = NaN;
    switch bkx_i
        case 2
            bkx_om_E_mult = 0; bkx_om_D_mult = 0;
        case 3
            bkx_lam_E_mult = 0; bkx_lam_D_mult = 0;
        case 4
            bkx_lam_D_mult = 0; bkx_om_D_mult = 0;
        case 5
            bkx_lam_E_mult = 0; bkx_om_E_mult = 0;
        case 6
            bkx_lam_E_mult = 0;
        case 7
            bkx_lam_D_mult = 0;
        case 8
            bkx_lam_E_mult = 2; bkx_lam_D_mult = 2;
            bkx_om_E_mult = 0.5; bkx_om_D_mult = 0.5;
        case 9
            bkx_lam_E_mult = 0.5; bkx_lam_D_mult = 0.5;
            bkx_om_E_mult = 2; bkx_om_D_mult = 2;
        case 10
            bkx_lam_E_mult = 0.5; bkx_lam_D_mult = 0.5;
        case 11
            bkx_rho_override = 0.85;
    end

    M_ = bkx_set_param_(M_, 'lambda_acc_E', ...
        bkx_param_(bkx_M_base, 'lambda_acc_E') * bkx_lam_E_mult);
    M_ = bkx_set_param_(M_, 'lambda_acc_D', ...
        bkx_param_(bkx_M_base, 'lambda_acc_D') * bkx_lam_D_mult);
    M_ = bkx_set_param_(M_, 'omega_acc_E', ...
        bkx_param_(bkx_M_base, 'omega_acc_E') * bkx_om_E_mult);
    M_ = bkx_set_param_(M_, 'omega_acc_D', ...
        bkx_param_(bkx_M_base, 'omega_acc_D') * bkx_om_D_mult);
    if isfinite(bkx_rho_override)
        M_ = bkx_set_param_(M_, 'rho_acc', bkx_rho_override);
    end

    [bkx_ev, bkx_bk_ok, bkx_info] = check(M_, options_, oo_);
    [bkx_unstable, bkx_root1, bkx_root2, bkx_critical_complex] = ...
        bkx_root_stats_(bkx_ev, M_.nsfwrd, bkx_qz);
    bkx_iso_num(bkx_i, :) = [ ...
        bkx_param_(M_, 'rho_acc') ...
        bkx_param_(M_, 'lambda_acc_E') bkx_param_(M_, 'lambda_acc_D') ...
        bkx_param_(M_, 'omega_acc_E')  bkx_param_(M_, 'omega_acc_D') ...
        bkx_param_(M_, 'lambda_acc_E') * bkx_param_(M_, 'omega_acc_E') ...
        bkx_param_(M_, 'lambda_acc_D') * bkx_param_(M_, 'omega_acc_D') ...
        double(bkx_bk_ok) M_.nsfwrd bkx_unstable bkx_root1 bkx_root2 ...
        bkx_critical_complex];
    fprintf('ISO  %-45s BK=%d unstable=%d critical_complex=%.6f\n', ...
        bkx_iso_names(bkx_i), bkx_bk_ok, bkx_unstable, bkx_critical_complex);
end

BK_DIAG_ISOLATION = array2table(bkx_iso_num, 'VariableNames', { ...
    'rho_acc','lambda_E','lambda_D','omega_E','omega_D','product_E', ...
    'product_D','bk_ok','n_forward','n_unstable','rank_fw_plus_1', ...
    'rank_fw_plus_2','critical_complex_modulus'});
BK_DIAG_ISOLATION.eset = bkx_iso_names;
BK_DIAG_ISOLATION = movevars(BK_DIAG_ISOLATION, 'eset', 'Before', 1);

%% 3. E ES D ACCESS-HUROK KULON EROSSEG-SCANJE
% Az A22-ben dokumentalt szorzat-invariancia miatt eleg a lambda lepcsot
% skalazni: az eredmeny ugyanaz, mintha az omega lepcsot skalaznank azonos
% aranyban. Az egyik tipus mindig 100%-on marad, a masikat kapcsoljuk fel.
bkx_channel_grid = [0 0.25 0.50 0.60 0.70 0.75 0.80 0.85 0.90 1.00];
bkx_n_channel = 2 * numel(bkx_channel_grid);
bkx_channel_axis = strings(bkx_n_channel, 1);
bkx_channel_num = nan(bkx_n_channel, 7);
bkx_row = 0;
for bkx_axis = 1:2
    for bkx_factor = bkx_channel_grid
        bkx_row = bkx_row + 1;
        M_ = bkx_M_base; oo_ = bkx_oo_base;
        if bkx_axis == 1
            bkx_channel_axis(bkx_row) = "E";
            M_ = bkx_set_param_(M_, 'lambda_acc_E', ...
                bkx_param_(bkx_M_base, 'lambda_acc_E') * bkx_factor);
        else
            bkx_channel_axis(bkx_row) = "D";
            M_ = bkx_set_param_(M_, 'lambda_acc_D', ...
                bkx_param_(bkx_M_base, 'lambda_acc_D') * bkx_factor);
        end
        [bkx_ev, bkx_bk_ok] = check(M_, options_, oo_);
        [bkx_unstable, bkx_root1, bkx_root2, bkx_critical_complex] = ...
            bkx_root_stats_(bkx_ev, M_.nsfwrd, bkx_qz);
        bkx_channel_num(bkx_row, :) = [bkx_factor double(bkx_bk_ok) ...
            M_.nsfwrd bkx_unstable bkx_root1 bkx_root2 bkx_critical_complex];
        fprintf(['CHANNEL %s factor=%.2f BK=%d unstable=%d ' ...
            'critical_complex=%.6f\n'], bkx_channel_axis(bkx_row), ...
            bkx_factor, bkx_bk_ok, bkx_unstable, bkx_critical_complex);
    end
end
BK_DIAG_CHANNEL = array2table(bkx_channel_num, 'VariableNames', { ...
    'factor','bk_ok','n_forward','n_unstable','rank_fw_plus_1', ...
    'rank_fw_plus_2','critical_complex_modulus'});
BK_DIAG_CHANNEL.skalazott_hurok = bkx_channel_axis;
BK_DIAG_CHANNEL = movevars(BK_DIAG_CHANNEL, 'skalazott_hurok', 'Before', 1);

%% 4. FINOM STABILITASI HATAR
% A parameter-atiras itt is eleg: a modell dinamikus Jacobianja linearis.
% A racs celja nem egy vegleges kalibracio, hanem annak megmutatasa, hogy
% a determinacios hatar hol metszi a publikalt ACCSCALE/rho tartomanyt.
bkx_scale_grid = [0 22.36 40 60 70 75 77.5 78 78.5 79 79.5 80 100];
bkx_rho_grid = [0.85 0.90 0.92 0.925 0.926 0.927 0.928 0.929 0.93 0.95 0.9673];
bkx_n_bound = numel(bkx_scale_grid) + numel(bkx_rho_grid);
bkx_bound_num = nan(bkx_n_bound, 9);
bkx_bound_axis = strings(bkx_n_bound, 1);
bkx_row = 0;

for bkx_s = bkx_scale_grid
    bkx_row = bkx_row + 1;
    M_ = bkx_M_base; oo_ = bkx_oo_base;
    bkx_mult = bkx_s / 100;
    M_ = bkx_set_param_(M_, 'lambda_acc_E', ...
        bkx_param_(bkx_M_base, 'lambda_acc_E') * bkx_mult);
    M_ = bkx_set_param_(M_, 'lambda_acc_D', ...
        bkx_param_(bkx_M_base, 'lambda_acc_D') * bkx_mult);
    M_ = bkx_set_param_(M_, 'omega_acc_E', ...
        bkx_param_(bkx_M_base, 'omega_acc_E') * bkx_mult);
    M_ = bkx_set_param_(M_, 'omega_acc_D', ...
        bkx_param_(bkx_M_base, 'omega_acc_D') * bkx_mult);
    [bkx_ev, bkx_bk_ok] = check(M_, options_, oo_);
    [bkx_unstable, bkx_root1, bkx_root2, bkx_critical_complex] = ...
        bkx_root_stats_(bkx_ev, M_.nsfwrd, bkx_qz);
    bkx_bound_axis(bkx_row) = "ACCSCALE";
    bkx_bound_num(bkx_row, :) = [bkx_s bkx_param_(M_, 'rho_acc') ...
        double(bkx_bk_ok) M_.nsfwrd bkx_unstable bkx_root1 bkx_root2 ...
        bkx_critical_complex (bkx_s/100)^2];
end

for bkx_rho = bkx_rho_grid
    bkx_row = bkx_row + 1;
    M_ = bkx_M_base; oo_ = bkx_oo_base;
    M_ = bkx_set_param_(M_, 'rho_acc', bkx_rho);
    [bkx_ev, bkx_bk_ok] = check(M_, options_, oo_);
    [bkx_unstable, bkx_root1, bkx_root2, bkx_critical_complex] = ...
        bkx_root_stats_(bkx_ev, M_.nsfwrd, bkx_qz);
    bkx_bound_axis(bkx_row) = "rho_acc";
    bkx_bound_num(bkx_row, :) = [100 bkx_rho double(bkx_bk_ok) ...
        M_.nsfwrd bkx_unstable bkx_root1 bkx_root2 bkx_critical_complex 1];
end

BK_DIAG_BOUNDARY = array2table(bkx_bound_num, 'VariableNames', { ...
    'ACCSCALE','rho_acc','bk_ok','n_forward','n_unstable', ...
    'rank_fw_plus_1','rank_fw_plus_2','critical_complex_modulus', ...
    'relative_access_product'});
BK_DIAG_BOUNDARY.tengely = bkx_bound_axis;
BK_DIAG_BOUNDARY = movevars(BK_DIAG_BOUNDARY, 'tengely', 'Before', 1);

fprintf('\nSTABILITASI HATAR — ACCSCALE (rho_acc=0.9673)\n');
disp(BK_DIAG_BOUNDARY(BK_DIAG_BOUNDARY.tengely == "ACCSCALE", ...
    {'ACCSCALE','rho_acc','bk_ok','n_unstable','critical_complex_modulus'}));
fprintf('STABILITASI HATAR — rho_acc (ACCSCALE=100)\n');
disp(BK_DIAG_BOUNDARY(BK_DIAG_BOUNDARY.tengely == "rho_acc", ...
    {'ACCSCALE','rho_acc','bk_ok','n_unstable','critical_complex_modulus'}));

%% 5. BISZEKCIOS KORLATOK
% Nem "kalibralt optimumot" keresunk, hanem reprodukalhatoan szuk
% intervallumba zarjuk azt a pontot, ahol a kritikus komplex gyokpar a
% Dynare qz-kuszobe folott mar ket extra instabil gyokot ad.
bkx_bisect_iter = 32;

% (A) Kozos ACCSCALE, rho_acc=0.9673. Elozetesen ellenorzott bracket:
% 79 stabil, 80 mar BK-serto.
bkx_scale_lo = 79;
bkx_scale_hi = 80;
for bkx_i = 1:bkx_bisect_iter
    bkx_mid = (bkx_scale_lo + bkx_scale_hi) / 2;
    M_ = bkx_M_base; oo_ = bkx_oo_base;
    bkx_mult = bkx_mid / 100;
    M_ = bkx_set_param_(M_, 'lambda_acc_E', ...
        bkx_param_(bkx_M_base, 'lambda_acc_E') * bkx_mult);
    M_ = bkx_set_param_(M_, 'lambda_acc_D', ...
        bkx_param_(bkx_M_base, 'lambda_acc_D') * bkx_mult);
    M_ = bkx_set_param_(M_, 'omega_acc_E', ...
        bkx_param_(bkx_M_base, 'omega_acc_E') * bkx_mult);
    M_ = bkx_set_param_(M_, 'omega_acc_D', ...
        bkx_param_(bkx_M_base, 'omega_acc_D') * bkx_mult);
    [~, bkx_bk_ok] = check(M_, options_, oo_);
    if bkx_bk_ok
        bkx_scale_lo = bkx_mid;
    else
        bkx_scale_hi = bkx_mid;
    end
end

% (B) rho_acc, ACCSCALE=100. Elozetesen ellenorzott bracket:
% 0.928 stabil, 0.929 mar BK-serto.
bkx_rho_lo = 0.928;
bkx_rho_hi = 0.929;
for bkx_i = 1:bkx_bisect_iter
    bkx_mid = (bkx_rho_lo + bkx_rho_hi) / 2;
    M_ = bkx_M_base; oo_ = bkx_oo_base;
    M_ = bkx_set_param_(M_, 'rho_acc', bkx_mid);
    [~, bkx_bk_ok] = check(M_, options_, oo_);
    if bkx_bk_ok
        bkx_rho_lo = bkx_mid;
    else
        bkx_rho_hi = bkx_mid;
    end
end

BK_DIAG_LIMITS = table( ...
    ["ACCSCALE, rho_acc=0.9673"; "rho_acc, ACCSCALE=100"], ...
    [bkx_scale_lo; bkx_rho_lo], [bkx_scale_hi; bkx_rho_hi], ...
    [bkx_scale_hi-bkx_scale_lo; bkx_rho_hi-bkx_rho_lo], ...
    [(bkx_scale_lo/100)^2; NaN], [(bkx_scale_hi/100)^2; NaN], ...
    'VariableNames', {'hatar','stabil_oldal','serto_oldal','intervallum', ...
    'stabil_relativ_access_szorzat','serto_relativ_access_szorzat'});

fprintf('\nBISZEKCIOS BK-KORLATOK (qz_criterium=%.7f)\n', bkx_qz);
disp(BK_DIAG_LIMITS);

%% 6. OPCIONALIS, EXPLICIT CSV-EXPORT
bkx_out_dir = getenv('BK_DIAG_OUT_DIR');
if ~isempty(bkx_out_dir)
    if ~isfolder(bkx_out_dir), mkdir(bkx_out_dir); end
    writetable(BK_DIAG_MAIN, fullfile(bkx_out_dir, 'bk_main.csv'));
    writetable(BK_DIAG_REGIME, fullfile(bkx_out_dir, 'bk_regime.csv'));
    writetable(BK_DIAG_ISOLATION, fullfile(bkx_out_dir, 'bk_isolation.csv'));
    writetable(BK_DIAG_CHANNEL, fullfile(bkx_out_dir, 'bk_channel.csv'));
    writetable(BK_DIAG_BOUNDARY, fullfile(bkx_out_dir, 'bk_boundary.csv'));
    writetable(BK_DIAG_LIMITS, fullfile(bkx_out_dir, 'bk_limits.csv'));
    fprintf('\nCSV-k kiirva ide: %s\n', bkx_out_dir);
else
    fprintf('\nCSV nem keszult (BK_DIAG_OUT_DIR nincs beallitva).\n');
end

fprintf('\nBK-DIAGNOSZTIKA KESZ.\n');

% -------------------------------------------------------------------------
% HELYI SEGEDFUGGVENYEK
% -------------------------------------------------------------------------
function value = bkx_param_(M, name)
    names = strtrim(cellstr(M.param_names));
    idx = find(strcmp(names, name), 1);
    assert(~isempty(idx), 'Ismeretlen parameter: %s', name);
    value = M.params(idx);
end

function M = bkx_set_param_(M, name, value)
    names = strtrim(cellstr(M.param_names));
    idx = find(strcmp(names, name), 1);
    assert(~isempty(idx), 'Ismeretlen parameter: %s', name);
    M.params(idx) = value;
end

function [n_unstable, rank1, rank2, critical_complex] = ...
        bkx_root_stats_(eigval, n_forward, qz)
    modulus = sort(abs(eigval), 'descend');
    n_unstable = sum(modulus > qz);
    rank1 = NaN; rank2 = NaN;
    if numel(modulus) >= n_forward + 1
        rank1 = modulus(n_forward + 1);
    end
    if numel(modulus) >= n_forward + 2
        rank2 = modulus(n_forward + 2);
    end
    complex_roots = eigval(abs(imag(eigval)) > 1e-8 & isfinite(eigval));
    critical_complex = NaN;
    if ~isempty(complex_roots)
        [~, idx] = min(abs(abs(complex_roots) - 1));
        critical_complex = abs(complex_roots(idx));
    end
end
