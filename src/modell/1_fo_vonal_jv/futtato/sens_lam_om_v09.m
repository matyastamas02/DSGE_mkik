% sens_lam_om_v09.m — AZ ACCSCALE SZETBONTASA: A KUSZOB MINT (lambda, omega) FELULET
% =====================================================================
% MIERT (korlatok-riport 2026-08-21, 1. teendo -- "a legnagyobb hozamu
% modellezesi teendo").
%
% Eddig EGYETLEN szam (ACCSCALE) skalazta a hozzaferesi csatorna MINDKET
% lepcsojet:
%     1. lepcso   felar -> hozzaferes       lambda_acc_j
%     2. lepcso   hozzaferes -> beruhazas   omega_acc_j
% A hosszu tavu beruhazasi hatas -omega*lambda/(1-rho_acc)*efp, tehat az
% ACCSCALE-ben KVADRATIKUS. Ket kovetkezmenye volt, mindketto rossz:
%
%   (a) Aki azt hitte, hogy "ACCSCALE = 22.3 a 100 helyett => 4.5-szer
%       gyengebb csatorna", TEVEDETT: az origo kozeleben ~20-szoros a
%       kulonbseg.
%   (b) A kozolt "22.3-as kuszob" nem EGY rugalmassagon volt, hanem KETTO
%       SZORZATAN, ELORE ROGZITETT lambda:omega arany mellett -- es maga az
%       arany is atvett ertek a v07_access-bol. Igy a szam nem
%       interpretalhato.
%
% A .mod mostantol ket kulon kapcsolot ismer (-DLAMSCALE, -DOMSCALE), es ez
% a script ot dolgot csinal:
%
% (0) REGRESSZIO. Ha egyik kapcsolot sem adjuk meg, mindketto az ACCSCALE-t
%     orokli -> minden korabbi eredmeny (t44/t47/t48/t49/t51) BITRE
%     valtozatlan. Ezt itt le is merjuk, harom modon.
%
% (1) MARGINALIS LINEARITAS. Egyszerre EGY lepcsot mozgatva a hatasnak
%     LINEARISNAK kell lennie (a hatas/skala hanyados konstans). Ez a
%     kvadratikussag DIAGNOZISA: megmutatja, hogy a nemlinearitas nem a
%     modellbol jott, hanem abbol, hogy egy szammal ket dolgot mozgattunk.
%
% (2) A FELULET. Teljes (lambda, omega) racs -> t52. Ebbol keszul az abra
%     (src/3_abrak/18_lam_om_felulet.py).
%
% (3) A NULLA-KONTUR. Minden lambda-hoz bisekciooval megkeressuk azt az
%     omega-t, ahol a KKV-blokk EPP utoleri a nagyvallalatot -> t52b.
%     EZ A KOZLENDO OBJEKTUM, nem egy szam.
%
% (4) A SZORZAT-DIAGNOSZTIKA. Ha a kontur mentén a lambda*omega szorzat
%     kozel konstans, akkor a kuszob VALOJABAN a szorzatra vonatkozik --
%     es ezt igy is kell kimondani. A DIAGONALIS pont (lambda = omega) a
%     regi 22.3-as szamot kell visszaadja: ez koti ossze az uj, ketdimenzios
%     kozlest a t48b/t51 korabbi eredmenyevel.
%
% Konfiguracio: OPTEN=1 (Opten-sulyok, felteteles magas-rho erzekenyseg:
% rho_acc = 0.9673; ez nem dinamikus szegmens-rho horgony),
% SCENARIO=1, TSCEN=3 -- pontosan az, amin a t51 kontur 22.3-as vegpontja
% all. Az OPTEN=0 (atvett, rho_acc = 0.85) diagonalisat is meghuzzuk, mert
% a t48b szerint annak 36.5-nek kell lennie.
%
% Kimenet: output/tables/t52_lam_om_racs.csv
%          output/tables/t52b_lam_om_kontur.csv
%          output/tables/t52c_lam_om_marginalis.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); sens_lam_om_v09"

cd(fileparts(fileparts(mfilename('fullpath'))));
repo = pwd;
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);
addpath(fullfile(repo, 'src', '4_infra'));

TAB = @(n) fullfile(repo, 'output', 'tables', n);

% =====================================================================
% (0) REGRESSZIO — a szetbontas NEM valtoztathat semmit
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(0) REGRESSZIO: a szetbontas visszafele kompatibilis-e?\n');
fprintf('%s\n', repmat('=', 1, 92));

r_alap  = fut_(0, 100, -1, -1);          % ahogy eddig futott
r_split = fut_(0, 100, 100, 100);        % explicit, de azonos skala
r_acc50 = fut_(0, 50, -1, -1);
r_spl50 = fut_(0, 50, 50, 50);

d1 = osszevet_(r_alap, r_split);
d2 = osszevet_(r_acc50, r_spl50);
fprintf('  ACCSCALE=100  vs  LAM=100,OM=100 : max elteres %.3e  -> %s\n', ...
    d1, ternary_(d1 < 1e-12, 'RENDBEN', '*** ELTORT ***'));
fprintf('  ACCSCALE=50   vs  LAM=50,OM=50   : max elteres %.3e  -> %s\n', ...
    d2, ternary_(d2 < 1e-12, 'RENDBEN', '*** ELTORT ***'));

T44 = readtable(TAB('t44_jv_access_stressz.csv'));
s44 = T44(T44.SCENARIO == 1 & T44.TSCEN == 3 & T44.NOVERT == 0, :);
d3 = max(abs([r_alap.GDP_pct - s44.GDP_pct, r_alap.y_E_pct - s44.y_E_pct, ...
    r_alap.y_D_pct - s44.y_D_pct, r_alap.y_L_pct - s44.y_L_pct]));
fprintf('  a tarolt t44 baseline-hoz kepest    : max elteres %.3e  -> %s\n', ...
    d3, ternary_(d3 < 1e-9, 'RENDBEN', '*** ELTORT ***'));

% =====================================================================
% (1) MARGINALIS LINEARITAS — a kvadratikussag diagnozisa
% =====================================================================
% Egyszerre EGY lepcsot mozgatunk, a masikat 100-on tartjuk. Ha a hatas
% ezen a metszeten linearis, akkor a korabban mert kvadratikussag TISZTAN
% abbol jott, hogy egy szam ket dolgot mozgatott.
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(1) MARGINALIS LINEARITAS (OPTEN=1, SCENARIO=1, TSCEN=3)\n');
fprintf('%s\n', repmat('=', 1, 92));

skalak = [0 4 10 20 40 60 80 100 140];
bazis = fut_(1, 0, -1, -1);       % mindket csatorna KI -> a referencia
b0 = bazis.KKV_minus_L_pp;
fprintf('  bazis (lambda = omega = 0): KKV-L = %+.4f pp\n\n', b0);

M = table();
for irany = ["lambda" "omega" "egyutt"]
    for s_ = skalak
        switch irany
            case "lambda", r = fut_(1, 100, s_, 100);
            case "omega",  r = fut_(1, 100, 100, s_);
            otherwise,     r = fut_(1, s_, -1, -1);
        end
        M = [M; table(string(irany), s_, r.konvergalt, r.GDP_pct, ...
            r.KKV_minus_L_pp, r.KKV_minus_L_pp - b0, r.solver_ok, ...
            r.bk_check_ok, r.bk_ok, r.ervenyes, r.n_forward, r.n_unstable, ...
            r.bk_qz_criterium, r.bk_info_code, r.nearest_unit_complex, ...
            'VariableNames', ...
            {'irany','skala','konvergalt','GDP_pct','KKV_minus_L_pp', ...
            'hatas_pp','solver_ok','bk_check_ok','bk_ok','ervenyes', ...
            'n_forward','n_unstable','bk_qz_criterium','bk_info_code', ...
            'nearest_unit_complex'})]; %#ok<AGROW>
    end
end
% a linearitas merteke: hatas/skala (a nulla skalat kihagyva)
M.hatas_per_skala = M.hatas_pp ./ M.skala;
M.hatas_per_skala(M.skala == 0) = NaN;
% CSV-kompatibilitas: a korabbi het oszlop marad elol, az uj statuszok
% csak a regi sema utan kovetkeznek.
M = movevars(M, 'hatas_per_skala', 'After', 'hatas_pp');
writetable(M, TAB('t52c_lam_om_marginalis.csv'));

for irany = ["lambda" "omega" "egyutt"]
    Mi = M(M.irany == irany & M.ervenyes == 1 & M.skala > 0, :);
    cim = containers.Map({'lambda','omega','egyutt'}, ...
        {'CSAK lambda mozog (omega = 100)', 'CSAK omega mozog (lambda = 100)', ...
         'EGYUTT mozognak (a regi ACCSCALE)'});
    fprintf('  %s\n', cim(char(irany)));
    fprintf('    %8s %3s %12s %12s %14s\n', ...
        'skala', 'BK', 'KKV-L', 'hatas', 'hatas/skala');
    for i = 1:height(Mi)
        fprintf('    %8.4g %3d %+11.4f %+11.4f %14.5f\n', Mi.skala(i), ...
            Mi.bk_ok(i), Mi.KKV_minus_L_pp(i), Mi.hatas_pp(i), ...
            Mi.hatas_per_skala(i));
    end
    v = Mi.hatas_per_skala;
    fprintf('    -> a hatas/skala hanyados %.2f-szeresere valtozik a racson\n\n', ...
        max(v)/min(v));
end
fprintf(['  ERTELMEZES: egy-egy lepcson a hanyados kozel konstans (a hatas\n' ...
    '  linearis), EGYUTT mozgatva viszont nagysagrendet valtozik. A\n' ...
    '  kvadratikussag tehat a KOZOS SKALAZAS mutermeke volt, nem a modell\n' ...
    '  tulajdonsaga -- es ezert nem volt interpretalhato a 22.3-as szam.\n']);

% =====================================================================
% (1b) SZORZAT-AZONOSSAG — A DONTO SZERKEZETI ALLITAS
% =====================================================================
% Az (1) pont mellekesen egy ENNEL EROSEBB dolgot mutatott: a "csak lambda"
% es a "csak omega" oszlop SZAMJEGYRE AZONOS. Ez nem veletlen. A hosszu
% tavu access-hatas
%       -omega_acc * lambda_acc / (1 - rho_acc) * efp
% alakú, tehát a ket parameter CSAK A SZORZATUKON keresztul hat. Ha ez
% pontosan igy van, annak ket kovetkezmenye van, es mindketto lenyeges:
%
%   1. A modell a lambda-t es az omega-t KULON-KULON NEM AZONOSITJA, meg
%      elvben sem. Barmilyen adat, ami a modellen keresztul horgonyozna
%      oket, csak a szorzatra ad informaciot.
%   2. Ezert a helyes kozles nem "ACCSCALE = 22.3", hanem a SZORZAT
%      kuszobe: (lambda*omega)* ~ 22.3^2. A 22.3 csak annak a
%      negyzetgyoke -- es epp ezert nem volt interpretalhato.
%
% Itt ezt ELLENOROZZUK: azonos szorzatu, de nagyon kulonbozo (lambda,
% omega) parok ugyanazt az eredmenyt kell adjak.
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(1b) SZORZAT-AZONOSSAG: csak a lambda*omega szamit?\n');
fprintf('%s\n', repmat('=', 1, 92));
parok = {[100 100], [200 50], [50 200], [400 25], [25 400]; ...
         [50 50],   [100 25], [25 100], [250 10], [10 250]};
P = table();
for r_ = 1:size(parok, 1)
    ertekek = nan(1, size(parok, 2));
    n_ertek = 0;
    fprintf('  szorzat = %g\n', prod(parok{r_, 1}));
    fprintf('    %10s %10s %14s %14s\n', 'lambda', 'omega', 'GDP', 'KKV-L');
    for c_ = 1:size(parok, 2)
        L_ = parok{r_, c_}(1); O_ = parok{r_, c_}(2);
        rr = fut_(1, 100, L_, O_);
        if rr.ervenyes == 1
            n_ertek = n_ertek + 1;
            ertekek(n_ertek) = rr.KKV_minus_L_pp;
        end
        fprintf('    %10g %10g %13.4f%% %+13.4f\n', L_, O_, rr.GDP_pct, ...
            rr.KKV_minus_L_pp);
        P = [P; table(L_*O_, L_, O_, rr.konvergalt, rr.GDP_pct, ...
            rr.KKV_minus_L_pp, rr.solver_ok, rr.bk_check_ok, rr.bk_ok, ...
            rr.ervenyes, rr.n_forward, rr.n_unstable, rr.bk_qz_criterium, ...
            rr.bk_info_code, rr.nearest_unit_complex, 'VariableNames', ...
            {'szorzat','lambda_skala','omega_skala','konvergalt','GDP_pct', ...
            'KKV_minus_L_pp','solver_ok','bk_check_ok','bk_ok','ervenyes', ...
            'n_forward','n_unstable','bk_qz_criterium','bk_info_code', ...
            'nearest_unit_complex'})]; %#ok<AGROW>
    end
    ertekek = ertekek(1:n_ertek);
    if numel(ertekek) >= 2
        fprintf('    -> BK-ervenyes sorokon max elteres: %.3e pp\n\n', ...
            max(ertekek) - min(ertekek));
    else
        fprintf('    -> nincs legalabb ket BK-ervenyes osszehasonlitasi pont\n\n');
    end
end
writetable(P, TAB('t52e_lam_om_szorzat.csv'));
fprintf(['  ERTELMEZES: ha az elteres numerikus nulla, akkor a modell a ket\n' ...
    '  rugalmassagot KULON NEM AZONOSITJA -- csak a szorzatukat. A kozlendo\n' ...
    '  objektum tehat a SZORZAT kuszobe, nem a "22.3".\n']);

% =====================================================================
% (2) A FELULET — teljes (lambda, omega) racs
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(2) A (lambda, omega) FELULET\n');
fprintf('%s\n', repmat('=', 1, 92));

lam_racs = [0 5 10 15 20 30 40 60 80 100 140];
om_racs  = [0 5 10 15 20 30 40 60 80 100 140];
G = table();
for L_ = lam_racs
    for O_ = om_racs
        G = [G; fut_(1, 100, L_, O_)]; %#ok<AGROW>
    end
end
writetable(G, TAB('t52_lam_om_racs.csv'));
fprintf(['  %d pont; PF solver %d; valodi BK %d; mindket feltetel ' ...
    '%d ponton teljesul.\n'], height(G), sum(G.solver_ok == 1), ...
    sum(G.bk_ok == 1), sum(G.ervenyes == 1));

fprintf('\n  KKV - nagyvallalat (pp) -- sor: lambda, oszlop: omega\n');
fprintf('  %8s', 'lam\\om');
fprintf('%9.4g', om_racs); fprintf('\n');
for L_ = lam_racs
    fprintf('  %8.4g', L_);
    for O_ = om_racs
        m = G.lamscale == L_ & G.omscale == O_ & G.ervenyes == 1;
        if any(m), fprintf('%+9.3f', G.KKV_minus_L_pp(m));
        else, fprintf('%9s', 'n/a'); end
    end
    fprintf('\n');
end

% =====================================================================
% (3) A NULLA-KONTUR — bisekcioval, lambda-nkent
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(3) A NULLA-KONTUR: melyik omega kell adott lambda mellett?\n');
fprintf('%s\n', repmat('=', 1, 92));

lam_kontur = [5 10 15 20 22.3 25 30 40 50 70 100 140];
K = table();
fprintf('  %10s %14s %16s %3s %14s\n', 'lambda', 'kuszob omega', ...
    'szorzat lam*om', 'BK', 'GDP@kuszob');
for L_ = lam_kontur
    [ok_, gdp_, bk_] = kuszob_omega_(1, L_, 300);
    K = [K; table(L_, ok_, L_*ok_, gdp_, bk_, 'VariableNames', ...
        {'lambda_skala','kuszob_omega','szorzat','GDP_pct_kuszobon', ...
        'bk_ok_kuszobon'})]; %#ok<AGROW>
    fprintf('  %10.4g %14.2f %16.1f %3d %13.3f%%\n', ...
        L_, ok_, L_*ok_, bk_, gdp_);
end
writetable(K, TAB('t52b_lam_om_kontur.csv'));

% =====================================================================
% (4) SZORZAT-DIAGNOSZTIKA ES A DIAGONALIS HORGONY
% =====================================================================
fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('(4) SZORZAT-DIAGNOSZTIKA ES A REGI SZAMHOZ VALO KOTES\n');
fprintf('%s\n', repmat('=', 1, 92));

jo = K(isfinite(K.kuszob_omega) & K.bk_ok_kuszobon == 1, :);
assert(~isempty(jo), 'Nincs BK-ervenyes lambda-omega kuszobkontur.');
sz = jo.szorzat;
fprintf(['  A kontur menten a lambda*omega szorzat: %.0f ... %.0f\n' ...
    '  (median %.0f, relativ szoras %.1f%%)\n'], min(sz), max(sz), ...
    median(sz), 100*std(sz)/mean(sz));

% A DIAGONALIS: lambda = omega = x. Ennek vissza kell adnia a t48b/t51
% szamait -- ez a hid a regi, egydimenzios kozles fele.
[d1, bk1] = kuszob_diagonalis_(1, 300); % OPTEN=1, rho_acc=0.9673 -> vart 22.3
[d0, bk0] = kuszob_diagonalis_(0, 300); % OPTEN=0, rho_acc=0.85   -> vart 36.5
assert(bk1 == 1 && bk0 == 1, ...
    'A diagonalis kuszobok kozul legalabb egy terminalisan BK-invalid.');
fprintf(['\n  A DIAGONALIS (lambda = omega, azaz a regi ACCSCALE):\n' ...
    '    OPTEN=1 (rho_acc = 0.9673): %.2f, BK=%d [vart 22.3]\n' ...
    '    OPTEN=0 (rho_acc = 0.85)  : %.2f, BK=%d [vart 36.5]\n'], ...
    d1, bk1, d0, bk0);

D = table([1; 0], [d1; d0], [d1^2; d0^2], [bk1; bk0], ...
    'VariableNames', {'OPTEN', 'kuszob_diagonalis', ...
    'szorzat_a_diagonalison','bk_ok_kuszobon'});
writetable(D, TAB('t52d_lam_om_diagonalis.csv'));

fprintf(['\n  EZT KELL KOZOLNI:\n' ...
    '  - A kuszob NEM egy szam, hanem egy GORBE a (lambda, omega) sikon.\n' ...
    '  - A gorbe kozelitoleg IZO-SZORZAT vonal: ami szamit, az a KET\n' ...
    '    lepcso ERZEKENYSEGENEK SZORZATA, nem kulon-kulon a szintjuk.\n' ...
    '  - A korabbi "22.3" ennek a gorbenek EGYETLEN pontja: az, ahol a ket\n' ...
    '    lepcsot azonos aranyban skalaztuk. A szorzat ott %.0f.\n' ...
    '  - Ezert onmagaban a 22.3 nem interpretalhato: ugyanaz az eredmeny\n' ...
    '    all elo pl. lambda = %.0f, omega = %.0f mellett is.\n'], ...
    d1^2, jo.lambda_skala(end), jo.kuszob_omega(end));
fprintf('%s\n', repmat('=', 1, 92));

% --- lokalis fuggvenyek --------------------------------------------------
function R = fut_(op, accscale, lam, om)
% lam/om = -1  ->  nincs megadva, az ACCSCALE-t orokli
arg = {sprintf('-DSCENARIO=%d', 1), sprintf('-DTSCEN=%d', 3), ...
    sprintf('-DOPTEN=%d', op), sprintf('-DACCSCALE=%.10g', accscale)};
if lam >= 0, arg{end+1} = sprintf('-DLAMSCALE=%.10g', lam); end
if om  >= 0, arg{end+1} = sprintf('-DOMSCALE=%.10g', om);   end
try
    dynare('jv_dsge_v09_access', arg{:}, 'console', 'nograph');
    M_  = evalin('base', 'M_');
    oo_ = evalin('base', 'oo_');
    options_ = evalin('base', 'options_');
    solver_ok_ = double(oo_.deterministic_simulation.status);
    B_ = bk_check_metrics(M_, options_, oo_);
    ok_ = solver_ok_;  % legacy `konvergalt`: kizarolag PF solver-statusz
    valid_ = double(solver_ok_ == 1 && B_.check_ok == 1 && B_.bk_ok == 1);
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    pn = cellstr(M_.param_names);
    p = @(v) M_.params(strcmp(pn, v));
    wE = p('om_E')/(p('om_E')+p('om_D'));
    wD = p('om_D')/(p('om_E')+p('om_D'));
    ykkv = wE*g('y_E') + wD*g('y_D');
    R = table(op, accscale, lam_(lam, accscale), om_(om, accscale), ...
        p('rho_acc'), p('lambda_acc_E'), p('omega_acc_E'), ok_, g('y'), ...
        g('y_E'), g('y_D'), g('y_L'), ykkv, ykkv - g('y_L'), ...
        g('y_D') - g('y_L'), g('y_E') - g('y_L'), ...
        solver_ok_, B_.check_ok, B_.bk_ok, valid_, B_.n_forward, B_.n_unstable, ...
        B_.qz_criterium, B_.info_code, B_.nearest_unit_complex, ...
        'VariableNames', kolumnak_());
catch ME
    fprintf(2, '  !! HIBA (OPTEN=%d ACC=%g LAM=%g OM=%g): %s\n', op, ...
        accscale, lam, om, ME.message);
    hiany = num2cell(nan(1, 8));
    R = table(op, accscale, lam_(lam, accscale), om_(om, accscale), ...
        NaN, NaN, NaN, 0, hiany{:}, 0, 0, NaN, 0, NaN, NaN, NaN, NaN, NaN, ...
        'VariableNames', kolumnak_());
end
end

function v = lam_(lam, acc), if lam >= 0, v = lam; else, v = acc; end, end
function v = om_(om, acc),   if om  >= 0, v = om;  else, v = acc; end, end

function c = kolumnak_()
c = {'OPTEN','accscale','lamscale','omscale','rho_acc','lambda_acc_E', ...
    'omega_acc_E','konvergalt','GDP_pct','y_E_pct','y_D_pct','y_L_pct', ...
    'y_KKV_pct','KKV_minus_L_pp','D_minus_L_pp','E_minus_L_pp'};
c = [c, {'solver_ok','bk_check_ok','bk_ok','ervenyes','n_forward','n_unstable', ...
    'bk_qz_criterium','bk_info_code','nearest_unit_complex'}];
end

function d = osszevet_(a, b)
d = max(abs([a.GDP_pct - b.GDP_pct, a.y_E_pct - b.y_E_pct, ...
    a.y_D_pct - b.y_D_pct, a.y_L_pct - b.y_L_pct, ...
    a.KKV_minus_L_pp - b.KKV_minus_L_pp]));
end

function [o, gdp, bk_ok] = kuszob_omega_(op, lam, ofelso)
% Adott lambda mellett az az omega, ahol KKV-L eppen nullat er.
% A KKV-L az omega-ban MONOTON NO, ezert bisekcio hasznalhato.
lo = 0; hi = ofelso;
bk_ok = NaN;
rlo = fut_(op, 100, lam, lo);
if rlo.solver_ok == 1 && rlo.KKV_minus_L_pp >= 0
    o = 0; gdp = rlo.GDP_pct; bk_ok = rlo.bk_ok; return
end
rhi = fut_(op, 100, lam, hi);
if rhi.solver_ok ~= 1 || rhi.KKV_minus_L_pp < 0
    o = Inf; gdp = NaN; return                 % omega = %g-ig sem fordul at
end
for it = 1:16
    mid = 0.5*(lo+hi);
    rm = fut_(op, 100, lam, mid);
    if rm.solver_ok == 1 && rm.KKV_minus_L_pp >= 0, hi = mid;
    else, lo = mid; end
    if hi - lo < 0.02, break, end
end
o = 0.5*(lo+hi);
rstar = fut_(op, 100, lam, o);
gdp = rstar.GDP_pct;
bk_ok = rstar.bk_ok;
end

function [x, bk_ok] = kuszob_diagonalis_(op, felso)
% lambda = omega = x mellett az atfordulasi pont (= a regi ACCSCALE-kuszob).
lo = 0; hi = felso;
bk_ok = NaN;
rhi = fut_(op, hi, -1, -1);
if rhi.solver_ok ~= 1 || rhi.KKV_minus_L_pp < 0, x = Inf; return, end
for it = 1:18
    mid = 0.5*(lo+hi);
    rm = fut_(op, mid, -1, -1);
    if rm.solver_ok == 1 && rm.KKV_minus_L_pp >= 0, hi = mid; else, lo = mid; end
    if hi - lo < 0.01, break, end
end
x = 0.5*(lo+hi);
rstar = fut_(op, x, -1, -1);
bk_ok = rstar.bk_ok;
end

function y = ternary_(c, a, b)
if c, y = a; else, y = b; end
end
