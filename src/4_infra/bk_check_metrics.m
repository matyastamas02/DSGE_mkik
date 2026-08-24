function B = bk_check_metrics(M, options, oo)
%BK_CHECK_METRICS Dynare Blanchard-Kahn meroszamok egy lokalis rezsimhez.
% =====================================================================
% A `oo.deterministic_simulation.status` csak a perfect-foresight solver
% numerikus sikeret jelzi. A BK-feltetelt a Dynare `check` rutinja meri.
% Ez a helper a ket fogalmat szandekosan nem keveri ossze.
% Perfect-foresight futas utan a kapott steady state az endval (a v09-ben
% az uni=1 terminalis rezsim), tehat ez TERMINALIS LOKALIS BK-ellenorzes;
% nem allitas a teljes, idoben valtozo atmeneti palya determinaciojarol.
%
% B = bk_check_metrics(M_, options_, oo_)
%
% Visszaadott mezok:
%   check_ok             1, ha a Dynare `check` technikailag lefutott
%   bk_ok                1, ha a gyokszam- ES rangfeltetel teljesul
%   n_forward            eloretekinto valtozok szama
%   n_unstable           qz_criterium folotti sajatertekek szama
%   qz_criterium         az alkalmazott Dynare-kuszob
%   info_code            a Dynare info-vektoranak elso eleme
%   info_value           a masodik elem, ha letezik
%   largest_stable       a legnagyobb stabil gyok modulusza
%   smallest_unstable    a legkisebb instabil gyok modulusza
%   nearest_unit_complex az egysegkorhoz legkozelebbi komplex gyok modulusza
%   eigenvalues          a teljes sajatertek-vektor diagnosztikai celra

    arguments
        M (1,1) struct
        options (1,1) struct
        oo (1,1) struct
    end

    local_options = options;
    local_options.noprint = 1;
    if ~isfield(local_options, 'qz_criterium') || ...
            isempty(local_options.qz_criterium)
        local_options.qz_criterium = 1 + 1e-6;
    end

    B = struct();
    B.check_ok = 0;
    B.bk_ok = NaN;
    B.n_forward = M.nsfwrd;
    B.n_unstable = NaN;
    B.qz_criterium = local_options.qz_criterium;
    B.info_code = NaN;
    B.info_value = NaN;
    B.largest_stable = NaN;
    B.smallest_unstable = NaN;
    B.nearest_unit_complex = NaN;
    B.eigenvalues = [];
    B.error_identifier = "";
    B.error_message = "";

    try
        [eigenvalues, bk_ok, info] = check(M, local_options, oo);
        modulus = abs(eigenvalues);

        B.check_ok = 1;
        B.bk_ok = double(bk_ok);
        B.n_unstable = sum(modulus > local_options.qz_criterium);
        if ~isempty(info)
            B.info_code = info(1);
        end
        if numel(info) > 1
            B.info_value = info(2);
        end

        stable = modulus(modulus <= local_options.qz_criterium & isfinite(modulus));
        unstable = modulus(modulus > local_options.qz_criterium);
        if ~isempty(stable), B.largest_stable = max(stable); end
        if ~isempty(unstable), B.smallest_unstable = min(unstable); end

        complex_roots = eigenvalues(abs(imag(eigenvalues)) > 1e-8 & ...
            isfinite(eigenvalues));
        if ~isempty(complex_roots)
            [~, idx] = min(abs(abs(complex_roots) - 1));
            B.nearest_unit_complex = abs(complex_roots(idx));
        end
        B.eigenvalues = eigenvalues;
    catch ME
        % A PF solver eredmenyet a hivo ettol meg megorizheti. A technikai
        % check-hibat nem szabad BK-serulesnek (bk_ok=0) alcazni.
        B.error_identifier = string(ME.identifier);
        B.error_message = string(ME.message);
    end
end
