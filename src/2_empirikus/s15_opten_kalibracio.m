% s15_opten_kalibracio.m - AZ 1. PRIORITAS: 13 PARAMETER UJRAKALIBRALASA
% ES 1 LEIRO HITELSTATUSZ-DIAGNOSZTIKA AZ OPTEN-PANELBOL
% =====================================================================
% MIERT EZ A KOVETKEZO LEPES. A fo modell (jv_dsge_v09_access) 13
% parametere ATVETT INDULO ertek a csapattars kkv_dsge_v07_access-ebol --
% a sajat .mod-juk is igy jeloli: "Ezek indulok: empirikus ujrakalibracio
% kell." A docs/kalibracio_teendok_csapatnak.md 1. prioritasa szerint
% mind a 13 KOZVETLENUL szamolhato a mar meglevo Opten-panelbol, kulso
% adatkeres nelkul:
%
%   om_E/om_D/om_L    kibocsatas-reszesedes    netto_arbevetel
%   shl_E/shl_D/shl_L foglalkoztatas-reszesedes letszam
%   phi_E/phi_D/phi_L exportarbevetel-arany    export_arbevetel/netto_arbevetel
%   lev_E/lev_D/lev_L tokeattetel (BGG: K/N)   eszkozok_osszesen/sajat_toke
%   delta             ertekcsokkenesi rata     ertekcsokkenes/targyi_eszkozok
%   rho_acc           csak LEIRO cegszintu statuszmutato; nem kalibracio
%
% A SZEGMENSDEFINICIO AZONOS az s14-evel (E = exportalo KKV, D = hazai
% KKV, L = nagyvallalat), hogy a hozzaferesi eredmenyek (61.9% / 4.8% /
% 43.4%) es ezek a sulyok UGYANARRA a populaciora vonatkozzanak.
%
% NEGY KORLAT, AMIT A TABLA IS VISZ (ne hivatkozz ra ezek nelkul):
%  (1) A panel a 10+ fos kort fedi -- a MIKROCEGEK (<10 fo) NINCSENEK
%      benne. Az om_D es shl_D ezert ALULBECSULT, az om_L/shl_L
%      FELULBECSULT. A sulyok a 10+ populacion BELULI reszesedesek.
%  (2) Az s14 exportor-definicioja (barmilyen pozitiv export) mellett a
%      phi_D DEFINICIO SZERINT PONTOSAN 0 -- ez nem eredmeny, hanem a
%      definicio mechanikus kovetkezmenye. Ezert fut egy KUSZOB-VARIANS
%      is (E = export_arany >= 25%), ahol a phi_D ertelmes szam.
%  (3) A lev_j konyv szerinti (kotelezettsegek + sajat toke) mennyiseg;
%      a BGG lev a piaci ertekelesu K/N. A konyv szerinti ertek a
%      szokasos kozelites, de nem azonos a modell fogalmaval.
%  (4) A 0.9673 CEG-SZINTU, pooled statusz-perzisztencia. A cegek 92.4%-a
%      negy ev alatt egyszer sem valtott, ezert a mutato foleg allando
%      heterogenitast tukroz. Nem a modell dinamikus SZEGMENS-szintu
%      rho_acc becslese, nem also korlat; a rho_acc horgonyzatlan marad.
%
% Kimenet: output/tables/t46_opten_kalibracio.csv         (fo tabla)
%          output/tables/t46b_opten_kalibracio_evenkent.csv (stabilitas)
% Futtatas: matlab -batch "cd('<repo>/src/2_empirikus'); s15_opten_kalibracio"

repo = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(repo, 'CLAUDE.md')), repo = fileparts(repo); end
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');
assert(exist(panel_f, 'file') == 2, 'Hianyzik: %s', panel_f);

fprintf('Panel betoltese...\n');
o = detectImportOptions(panel_f, 'VariableNamingRule', 'preserve');
kell = {'opten_id', 'ev', 'netto_arbevetel', 'export_arbevetel', ...
    'letszam', 'meret_kategoria', 'exportor', 'van_hitel', ...
    'eszkozok_osszesen', 'sajat_toke', 'kotelezettsegek', ...
    'ertekcsokkenes', 'targyi_eszkozok', 'anyagjellegu_raforditasok'};
o.SelectedVariableNames = kell;
P = readtable(panel_f, o);
fprintf('  %d sor betoltve\n', height(P));

% --- numerikus kenyszerites (a panelben tobb oszlop szovegkent jon) ------
P.ev                = num(P.ev);
P.netto_arbevetel   = num(P.netto_arbevetel);
P.export_arbevetel  = num(P.export_arbevetel);
P.letszam           = num(P.letszam);
P.eszkozok_osszesen = num(P.eszkozok_osszesen);
P.sajat_toke        = num(P.sajat_toke);
P.kotelezettsegek   = num(P.kotelezettsegek);
P.ertekcsokkenes    = num(P.ertekcsokkenes);
P.targyi_eszkozok   = num(P.targyi_eszkozok);
P.anyagjellegu_raforditasok = num(P.anyagjellegu_raforditasok);

% FIGYELEM: a van_hitel es az exportor SZOVEGES "True"/"False" a panelben,
% nem szam -- a str2double NaN-t adna rajuk (ezt az s14 diagnosztikaja
% fogta el annak idejen).
P.hozzafer = double(strcmpi(string(P.van_hitel), "True"));
exportal   = strcmpi(string(P.exportor), "True");

meret = string(P.meret_kategoria);
nagy  = meret == "250+";
kkv   = meret == "10-49" | meret == "50-249";

% export-arany ujraszamolva (a panel oszlopa helyett, hogy a szurest
% egyertelmuen lassuk): export / netto arbevetel
exp_arany = nan(height(P), 1);
pozarb = P.netto_arbevetel > 0;
exp_arany(pozarb) = fillzero(P.export_arbevetel(pozarb)) ./ ...
    P.netto_arbevetel(pozarb);
P.exp_arany = exp_arany;

% --- ervenyes minta: 2021-2024, besorolt meretkategoria ------------------
% (2021-2024 az s14 mintaja is; a panel 2025-os sorai reszlegesek)
EVEK = (2021:2024)';
ok = ismember(P.ev, EVEK) & (nagy | kkv);
P = P(ok, :); nagy = nagy(ok); kkv = kkv(ok); exportal = exportal(ok);
fprintf('  ervenyes minta: %d ceg-ev, %d ceg (2021-2024, 10+ fo)\n', ...
    height(P), numel(unique(P.opten_id)));

szg = ["E_export_KKV"; "D_hazai_KKV"; "L_nagyvallalat"];

% =========================================================================
% KET SZEGMENSDEFINICIO
%   (A) ALAP     : E = KKV es exportor (barmilyen pozitiv export) -- s14
%   (B) KUSZOB25 : E = KKV es export_arany >= 25%
% A (B) azert kell, mert az (A)-ban a phi_D definicio szerint 0, es mert a
% modell "export-orientalt KKV" tipusa nem azonos a "barmennyit exportalo"
% ceggel. A ketto elteresebol latszik, mennyire definicio-fuggo a sulyozas.
% =========================================================================
DEF = struct('nev', {'ALAP', 'KUSZOB25'}, 'kuszob', {0, 0.25});
FO = struct();          % a fo (ALAP) definicio eredmenyei
Rs = table();           % osszesito sorok
Evs = table();          % evenkenti stabilitas

for dd = 1:numel(DEF)
    if DEF(dd).kuszob == 0
        eE = kkv & exportal;
    else
        eE = kkv & (P.exp_arany >= DEF(dd).kuszob);
    end
    sz = strings(height(P), 1);
    sz(eE)         = szg(1);
    sz(kkv & ~eE)  = szg(2);
    sz(nagy)       = szg(3);

    fprintf('\n%s\n', repmat('=', 1, 78));
    fprintf('SZEGMENSDEFINICIO: %s%s\n', DEF(dd).nev, ...
        ternary(DEF(dd).kuszob > 0, sprintf('  (E: export_arany >= %.0f%%)', ...
        100*DEF(dd).kuszob), '  (E: barmilyen pozitiv export -- s14)'));
    fprintf('%s\n', repmat('=', 1, 78));

    % --- om_j: kibocsatas-reszesedes (netto arbevetel) -------------------
    om  = zeros(3, 1); omva = zeros(3, 1);
    shl = zeros(3, 1); phi  = zeros(3, 1);
    lev = zeros(3, 1); levn = zeros(3, 1); levalt = zeros(3, 1);
    nsz = zeros(3, 1);
    % hozzaadott ertek: netto arbevetel - anyagjellegu raforditasok
    va = P.netto_arbevetel - fillzero(P.anyagjellegu_raforditasok);
    for i = 1:3
        m = sz == szg(i);
        nsz(i) = sum(m);
        om(i)   = nansum0(P.netto_arbevetel(m));
        omva(i) = nansum0(va(m & va > 0));
        shl(i)  = nansum0(P.letszam(m));
        arb = nansum0(P.netto_arbevetel(m));
        phi(i) = ternary(arb > 0, nansum0(P.export_arbevetel(m)) / arb, 0);
    end
    om   = om   / sum(om);
    omva = omva / sum(omva);
    shl  = shl  / sum(shl);

    % --- lev_j: BGG tokeattetel = eszkozok / sajat toke -------------------
    % A modell lev_j-je a K/N arany (BGG 1999). A panel tokeattetel oszlopa
    % kotelezettsegek/eszkozok -- ez a KETTO monoton kapcsolatban all:
    %   lev = 1/(1-d).  Mindkettot kiszamoljuk keresztellenorzeskent.
    levr = P.eszkozok_osszesen ./ P.sajat_toke;
    dr   = fillzero(P.kotelezettsegek) ./ P.eszkozok_osszesen;
    jolev = isfinite(levr) & P.sajat_toke > 0 & P.eszkozok_osszesen > 0 & ...
        levr >= 1 & levr < 100;
    for i = 1:3
        m = jolev & sz == szg(i);
        lev(i)  = median(levr(m));
        levn(i) = sum(m);
        md = median(dr(m));
        levalt(i) = 1 / (1 - md);
    end

    fprintf('\n%-16s %8s %10s %10s %10s %10s %10s\n', 'szegmens', 'n(ceg-ev)', ...
        'om (arb.)', 'om (HE)', 'shl', 'phi', 'lev (med)');
    for i = 1:3
        fprintf('%-16s %8d %10.4f %10.4f %10.4f %10.4f %10.3f\n', szg(i), ...
            nsz(i), om(i), omva(i), shl(i), phi(i), lev(i));
    end
    fprintf('%-16s %8s %10s %10s %10s %10s %10.3f  <- 1/(1-med(kotelez/eszkoz)) keresztprobaja\n', ...
        '', '', '', '', '', '', levalt(1));
    fprintf('%-16s %8s %10s %10s %10s %10s %10.3f\n', '', '', '', '', '', '', levalt(2));
    fprintf('%-16s %8s %10s %10s %10s %10s %10.3f\n', '', '', '', '', '', '', levalt(3));

    % --- evenkenti stabilitas (csak a sulyokra) ---------------------------
    for j = 1:numel(EVEK)
        me = P.ev == EVEK(j);
        o2 = zeros(3,1); s2 = zeros(3,1); f2 = zeros(3,1);
        for i = 1:3
            m = me & sz == szg(i);
            o2(i) = nansum0(P.netto_arbevetel(m));
            s2(i) = nansum0(P.letszam(m));
            arb = nansum0(P.netto_arbevetel(m));
            f2(i) = ternary(arb > 0, nansum0(P.export_arbevetel(m))/arb, 0);
        end
        o2 = o2/sum(o2); s2 = s2/sum(s2);
        for i = 1:3
            Evs = [Evs; table(string(DEF(dd).nev), EVEK(j), szg(i), ...
                o2(i), s2(i), f2(i), 'VariableNames', {'definicio', 'ev', ...
                'szegmens', 'om', 'shl', 'phi'})]; %#ok<AGROW>
        end
    end

    for i = 1:3
        p = char(extractBefore(szg(i), 2));   % E / D / L
        Rs = [Rs; table( ...
            repmat(string(DEF(dd).nev), 4, 1), ...
            ["om_" + p; "shl_" + p; "phi_" + p; "lev_" + p], ...
            [om(i); shl(i); phi(i); lev(i)], ...
            [omva(i); NaN; NaN; levalt(i)], ...
            [nsz(i); nsz(i); nsz(i); levn(i)], ...
            'VariableNames', {'definicio', 'parameter', 'ertek', ...
            'alternativ', 'n'})]; %#ok<AGROW>
    end

    if dd == 1
        FO.om = om; FO.shl = shl; FO.phi = phi; FO.lev = lev;
        FO.omva = omva; FO.levalt = levalt; FO.sz = sz;
    else
        FO.om_k = om; FO.shl_k = shl; FO.phi_k = phi; FO.lev_k = lev;
    end
end

% =========================================================================
% delta kalibracio es a LEIRO hitelstatusz-mutato -- egyszer szamoljuk
% A szamitasokhoz rendezes (ceg, ev) szerint es csak a SZOMSZEDOS evek
% (t-1 -> t) parjai hasznalhatok. A statuszmutato nem rho_acc-becsles.
% =========================================================================
[Ps, ord] = sortrows(P, {'opten_id', 'ev'});
szF = FO.sz(ord);
n = height(Ps);
elozo = [false; Ps.opten_id(2:end) == Ps.opten_id(1:end-1) & ...
    Ps.ev(2:end) == Ps.ev(1:end-1) + 1];
idx = find(elozo);

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('delta -- ERTEKCSOKKENESI RATA\n');
fprintf('%s\n', repmat('=', 1, 78));
% delta_eves = sum(ertekcsokkenes_t) / sum(targyi_eszkozok_{t-1})
% A NYITO allomanyhoz viszonyitunk, mert a zaro allomany mar levonta az
% adott evi ecs-t -> a kortars arany felfele torzitana.
ecs  = Ps.ertekcsokkenes(idx);
tel  = Ps.targyi_eszkozok(idx - 1);
joD  = isfinite(ecs) & isfinite(tel) & tel > 0 & ecs >= 0 & ecs < tel;
delta_a = sum(ecs(joD)) / sum(tel(joD));
delta_q = 1 - (1 - delta_a)^(1/4);
delta_a_med = median(ecs(joD) ./ tel(joD));
fprintf('  eves (aggregalt, sum/sum): %.4f   -> negyedeves: %.4f\n', ...
    delta_a, delta_q);
fprintf('  eves (ceg-szintu median) : %.4f   -> negyedeves: %.4f\n', ...
    delta_a_med, 1 - (1 - delta_a_med)^(1/4));
fprintf('  n = %d ceg-ev par | jelenlegi modellertek: 0.0250 (negyedeves)\n', ...
    sum(joD));

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('LEIRO CEGSZINTU HITELSTATUSZ-PERZISZTENCIA (NEM rho_acc-BECSLES)\n');
fprintf('%s\n', repmat('=', 1, 78));
% Ketallapotu Markov-lanc: az indikator AR(1)-egyutthatoja rho = p11 - p01,
% ahol p11 = P(hitel_t=1 | hitel_{t-1}=1), p01 = P(hitel_t=1 | hitel_{t-1}=0).
h  = Ps.hozzafer(idx);
hl = Ps.hozzafer(idx - 1);
joR = isfinite(h) & isfinite(hl);
fprintf('%-16s %8s %8s %8s %10s %12s\n', 'szegmens', 'n', 'p11', 'p01', ...
    'rho(eves)', 'rho(negyedev)');
rho_sor = table();
for i = 0:3
    if i == 0
        m = joR; nev = "OSSZES";
    else
        m = joR & szF(idx) == szg(i); nev = szg(i);
    end
    p11 = mean(h(m & hl == 1));
    p01 = mean(h(m & hl == 0));
    ra  = p11 - p01;
    rq  = ternary(ra > 0, real(ra)^(1/4), NaN);
    fprintf('%-16s %8d %8.4f %8.4f %10.4f %12.4f\n', nev, sum(m), p11, p01, ra, rq);
    rho_sor = [rho_sor; table(nev, sum(m), p11, p01, ra, rq, ...
        'VariableNames', {'szegmens', 'n', 'p11', 'p01', 'rho_eves', ...
        'rho_negyedeves'})]; %#ok<AGROW>
end
rho_acc_uj = rho_sor.rho_negyedeves(1);
fprintf(['  jelenlegi modellertek: 0.8500 (negyedeves)\n' ...
    '  ERTELMEZES: a 0.9673 leiro cegszintu mutato; a cegek 92.4%%-a\n' ...
    '  negy ev alatt sosem valtott, foleg allando heterogenitas miatt.\n' ...
    '  Nem dinamikus szegmens-rho-becsles, nem also korlat; rho_acc\n' ...
    '  horgonyzatlan. A lenti rho_acc sor csak erzekenysegi pont.\n']);

% =========================================================================
% OSSZEVETES: 13 KALIBRALHATO PARAMETER + 1 LEIRO ERZEKENYSEGI PONT
% A 14 soros kimeneti sema kompatibilitasi okbol megmarad; a rho_acc sora
% diagnosztika, nem kalibracios ajanlas.
% =========================================================================
par_nev = {'om_E','om_D','om_L','shl_E','shl_D','shl_L', ...
    'phi_E','phi_D','phi_L','lev_E','lev_D','lev_L','delta','rho_acc'};
jelen = [0.18 0.37 0.45  0.20 0.50 0.30  0.56 0.05 0.365 ...
    1.60 1.60 1.85  0.025 0.85];
ujA = [FO.om(:)'  FO.shl(:)'  FO.phi(:)'  FO.lev(:)'  delta_q rho_acc_uj];
ujB = [FO.om_k(:)' FO.shl_k(:)' FO.phi_k(:)' FO.lev_k(:)' delta_q rho_acc_uj];

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('OSSZEVETES -- 13 KALIBRALHATO PARAMETER + 1 LEIRO ERZEKENYSEGI PONT\n');
fprintf('%s\n', repmat('=', 1, 78));
fprintf('%-10s %12s %12s %12s %10s\n', 'parameter', 'jelenlegi', ...
    'uj (ALAP)', 'uj (KUSZOB25)', 'elteres%');
for i = 1:numel(par_nev)
    fprintf('%-10s %12.4f %12.4f %12.4f %9.1f%%\n', par_nev{i}, jelen(i), ...
        ujA(i), ujB(i), 100*(ujA(i)/jelen(i) - 1));
end

T = table(string(par_nev)', jelen', ujA', ujB', ...
    'VariableNames', {'parameter', 'jelenlegi', 'uj_ALAP', 'uj_KUSZOB25'});
T.elteres_pct = 100*(T.uj_ALAP ./ T.jelenlegi - 1);
writetable(T, fullfile(repo, 'output', 'tables', 't46_opten_kalibracio.csv'));
writetable(Evs, fullfile(repo, 'output', 'tables', ...
    't46b_opten_kalibracio_evenkent.csv'));
writetable(rho_sor, fullfile(repo, 'output', 'tables', ...
    't46c_rho_acc_atmenet.csv'));

% =========================================================================
% ERTELMEZES ES KORLATOK
% =========================================================================
fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('KORLATOK -- EZEK NELKUL A SZAMOKRA NE HIVATKOZZ\n');
fprintf('%s\n', repmat('=', 1, 78));
fprintf(['(1) MIKROCEGEK. A panel a 10+ fos kort fedi. A magyar\n' ...
    '    vallalati szektor foglalkoztatasanak nagy resze a <10 fos korben\n' ...
    '    van, tehat az om_D/shl_D ALULBECSULT, az om_L/shl_L\n' ...
    '    FELULBECSULT. Ezek a 10+ populacion BELULI reszesedesek.\n']);
fprintf(['(2) phi_D. Az ALAP definicioban (barmilyen pozitiv export) a\n' ...
    '    phi_D = %.4f -- ez DEFINICIO SZERINTI nulla, nem meres. A\n' ...
    '    KUSZOB25 variansban phi_D = %.4f, ami ertelmes szam.\n'], ...
    FO.phi(2), FO.phi_k(2));
fprintf(['(3) lev_j. Konyv szerinti eszkoz/sajat toke; a BGG lev piaci\n' ...
    '    ertekelesu K/N. A negativ sajat tokeju cegek kiestek (n-ek a\n' ...
    '    tablaban).\n']);
fprintf(['(4) rho_acc. A 0.9673 LEIRO CEG-SZINTU statusz-perzisztencia.\n' ...
    '    A cegek 92.4%%-a negy ev alatt egyszer sem valtott, ezert a mutato\n' ...
    '    foleg allando heterogenitast tukroz. Nem dinamikus SZEGMENS-rho\n' ...
    '    becsles es nem also korlat; a rho_acc horgonyzatlan marad.\n']);
fprintf(['(5) delta. Konyv szerinti ertekcsokkenes (adotorvenyi kulcsok),\n' ...
    '    nem gazdasagi amortizacio -- a ketto rendszerint eltero.\n']);

fprintf('\n%s\n', repmat('=', 1, 78));
fprintf('KIMENET\n');
fprintf('  output/tables/t46_opten_kalibracio.csv\n');
fprintf('  output/tables/t46b_opten_kalibracio_evenkent.csv\n');
fprintf('  output/tables/t46c_rho_acc_atmenet.csv\n');
fprintf('%s\n', repmat('=', 1, 78));

% --- lokalis fuggvenyek (a MATLAB-script VEGEN kell legyenek) ------------
function y = num(x)
if isnumeric(x), y = double(x); else, y = str2double(string(x)); end
end

function y = fillzero(x)
y = x; y(~isfinite(y)) = 0;
end

function s = nansum0(x)
s = sum(x(isfinite(x)));
end

function y = ternary(c, a, b)
if c, y = a; else, y = b; end
end
