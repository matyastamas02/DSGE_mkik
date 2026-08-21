% ellenorzes_3type.m — A 2. ES 3. LEPCSO FUGGETLEN ELLENORZESE
% =====================================================================
% MIERT KELL. A BK-stresszteszt csak azt mondja meg, hogy a modell
% MEGOLDHATO -- nem azt, hogy HELYES. Egy elgepelt suly, egy felcserelt
% index vagy egy rossz elojel mellett is lehet 18/18 konvergencia.
% Ez a script MAS IRANYBOL ellenoriz: olyan azonossagokat tesztel, amiknek
% a szerkezetbol KOVETKEZNIUK kell, fuggetlenul attol, hogy a modell
% megoldodik-e.
%
% NEGY ELLENORZES:
%
% (1) SZIMMETRIA. Ha minden tipus-specifikus parameter azonos (-DSYM=1),
%     a harom tipusnak DEFINICIO SZERINT azonosan kell viselkednie.
%     Ha y_E =/= y_D =/= y_L szimmetrikus parameterek mellett, akkor
%     valahol elirtam egy indexet vagy egy sulyt. Ez a legerosebb teszt.
%
% (2) AGGREGACIOS AZONOSSAGOK. A reszek osszegenek ki kell adnia az egeszet:
%       v07_3type:  sum(wd_j*mc_j) == mc_d
%       v08_arak :  sum(wd_j*d_j)  == y_d   es  sum(wx_j*x_j) == xx
%                   sum(wd_j*p_j)  == 0     (normalizacio)
%     Ezek NEM egyenletek a modellben (kiveve a normalizaciot), hanem a
%     konstrukciobol KOVETKEZNEK -- tehat valodi fuggetlen ellenorzesek.
%
% (3) NULLA-SOKK TESZT. Ha nincs sokk (sov=bank=0 vegig, uni=0), minden
%     valtozonak vegig 0-nak kell lennie. Ha nem, valahol konstans szivarog
%     be, vagy a steady state nem 0-ban van.
%
% (4) A KET LEPCSO OSSZEVETESE. A v08 (tipusonkenti ar) eps_ces -> 0
%     hataresetben kozelitenie kell a v07-hez a HAZAI keresletben
%     (d_j = y_d - eps_ces*p_j -> y_d). Nem exakt egyezes (az export
%     oldal tipusonkenti marad), de az elteresnek CSOKKENNIE kell, ahogy
%     eps_ces -> 0. Ha no, akkor a ket lepcso nem ugyanazt a modellt
%     altalanositja.
%
% Kimenet: output/tables/t43_ellenorzes_3type.csv
% Futtatas: matlab -batch "cd('<repo>/src/modell/1_fo_vonal_jv/futtato'); ellenorzes_3type"

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

R = table();

fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('A 2. ES 3. LEPCSO FUGGETLEN ELLENORZESE\n');
fprintf('%s\n', repmat('=', 1, 92));

% =====================================================================
% (1) SZIMMETRIA-TESZT
% =====================================================================
fprintf('\n--- (1) SZIMMETRIA: azonos parameterek -> azonos tipusok? ---\n');
for mod_ = {'jv_dsge_v07_3type', 'jv_dsge_v08_3type_arak'}
    nev = mod_{1};
    lep = "2. lepcso"; if contains(nev, 'v08'), lep = "3. lepcso"; end
    dynare(nev, '-DSCENARIO=1', '-DTSCEN=3', '-DSYM=1', 'console', 'nograph');
    n = cellstr(M_.endo_names);
    g = @(v) 100 * oo_.steady_state(strcmp(n, v));
    dy = max([abs(g('y_E')-g('y_D')), abs(g('y_D')-g('y_L'))]);
    di = max([abs(g('i_E')-g('i_D')), abs(g('i_D')-g('i_L'))]);
    de = max([abs(g('efp_E')-g('efp_D')), abs(g('efp_D')-g('efp_L'))]);
    fprintf('  %-24s y_j elteres=%.2e  i_j=%.2e  efp_j=%.2e\n', nev, dy, di, de);
    R = jegyez(R, lep, "szimmetria: y_E==y_D==y_L", dy, 1e-8, nev);
    R = jegyez(R, lep, "szimmetria: i_E==i_D==i_L", di, 1e-8, nev);
    R = jegyez(R, lep, "szimmetria: efp_E==efp_D==efp_L", de, 1e-8, nev);
    if contains(nev, 'v08')
        dp = max([abs(g('p_E')), abs(g('p_D')), abs(g('p_L'))]);
        fprintf('  %-24s |p_j| max=%.2e (szimmetrianal 0 kell)\n', nev, dp);
        R = jegyez(R, lep, "szimmetria: p_j == 0", dp, 1e-8, nev);
    end
end

% =====================================================================
% (2) AGGREGACIOS AZONOSSAGOK (aszimmetrikus, valos kalibracioval)
% =====================================================================
fprintf('\n--- (2) AGGREGACIO: a reszek osszege == az egesz? ---\n');
dynare('jv_dsge_v07_3type', '-DSCENARIO=1', '-DTSCEN=3', 'console', 'nograph');
n = cellstr(M_.endo_names); pn = cellstr(M_.param_names);
g = @(v) oo_.steady_state(strcmp(n, v));
p = @(v) M_.params(strcmp(pn, v));
d1 = abs(p('wd_E')*g('mc_E') + p('wd_D')*g('mc_D') + p('wd_L')*g('mc_L') - g('mc_d'));
fprintf('  v07: |sum(wd_j*mc_j) - mc_d|            = %.2e\n', d1);
R = jegyez(R, "2. lepcso", "aggregacio: sum(wd*mc)==mc_d", d1, 1e-10, "");
% a mechanikus y_j azonossag (a dokumentalt KORLAT visszaigazolasa)
d2 = abs((1-p('phi_E'))*g('y_d') + p('phi_E')*g('y_x') - g('y_E'));
fprintf('  v07: |(1-phi_E)*y_d+phi_E*y_x - y_E|    = %.2e  (a KORLAT: 0 kell)\n', d2);
R = jegyez(R, "2. lepcso", "y_E MECHANIKUS (dok. korlat)", d2, 1e-10, "0 = a korlat fennall");

dynare('jv_dsge_v08_3type_arak', '-DSCENARIO=1', '-DTSCEN=3', 'console', 'nograph');
n = cellstr(M_.endo_names); pn = cellstr(M_.param_names);
g = @(v) oo_.steady_state(strcmp(n, v));
p = @(v) M_.params(strcmp(pn, v));
d3 = abs(p('wd_E')*g('d_E') + p('wd_D')*g('d_D') + p('wd_L')*g('d_L') - g('y_d'));
d4 = abs(p('wx_E')*g('x_E') + p('wx_D')*g('x_D') + p('wx_L')*g('x_L') - g('xx'));
d5 = abs(p('wd_E')*g('p_E') + p('wd_D')*g('p_D') + p('wd_L')*g('p_L'));
d6 = abs((1-p('phi_E'))*g('d_E') + p('phi_E')*g('x_E') - g('y_E'));
fprintf('  v08: |sum(wd_j*d_j) - y_d|              = %.2e\n', d3);
fprintf('  v08: |sum(wx_j*x_j) - xx|               = %.2e\n', d4);
fprintf('  v08: |sum(wd_j*p_j)|  (normalizacio)    = %.2e\n', d5);
fprintf('  v08: |(1-phi_E)*d_E+phi_E*x_E - y_E|    = %.2e\n', d6);
R = jegyez(R, "3. lepcso", "aggregacio: sum(wd*d)==y_d", d3, 1e-10, "");
R = jegyez(R, "3. lepcso", "aggregacio: sum(wx*x)==xx", d4, 1e-10, "");
R = jegyez(R, "3. lepcso", "normalizacio: sum(wd*p)==0", d5, 1e-10, "v01 egyseggyok");
R = jegyez(R, "3. lepcso", "y_E == (1-phi)d_E+phi*x_E", d6, 1e-10, "");
% ES a KULONBSEG: a v08-ban y_E MAR NEM a mechanikus keverek
d7 = abs((1-p('phi_E'))*g('y_d') + p('phi_E')*g('y_x') - g('y_E'));
fprintf('  v08: |mechanikus jóslat - y_E|          = %.2e  (a KORLAT FELOLDVA: >0 kell)\n', d7);
R = jegyez(R, "3. lepcso", "y_E MAR NEM mechanikus", 1e-3 - min(d7,1e-3), 1e-9, ...
    sprintf("elteres=%.4f (nagy = jo)", 100*d7));

% --- SZEGMENS-KIBOCSATAS vs AGGREGALT GDP (kulso biralat, 2026-08-21) ---
% MIERT KELL. Egy kulso birado eszrevette, hogy a modellben NINCS
%   y = om_E*y_E + om_D*y_D + om_L*y_L
% azonossag (a k es az ii van om_j-vel aggregalva, a y nem). Ez NEM hiba:
% a y_j BRUTTO kibocsatas, ami importalt koztes inputot hasznal
% (aa_E=0.45 vs aa_D=0.80), a y viszont KIADASI OLDALI GDP. Importalt input
% mellett a ketto definicio szerint nem egyenlo, es ha rakotnenk az
% azonossagot, AZ lenne a hiba.
% Ami VISZONT teljesul, es eddig nem volt tesztelve: az om_j-vel sulyozott
% szegmens-kibocsatas a KET JOSZAG mennyisegenek sulyozott kombinacioja,
%   sum(om_j*y_j) = [sum om_j(1-phi_j)]*y_d + [sum om_j*phi_j]*y_x
% ami a wd_j/wx_j sulyok definiciojabol kovetkezik. Ez az or azt vedi, hogy
% a szegmens-kibocsatasok es a joszag-szintu mennyisegek ne csuszhassanak
% szet — es egyben dokumentalja, hogy a y_j NEM GDP-komponens.
om = @(j) p("om_" + j); ph = @(j) p("phi_" + j);
sum_omy = 0; sum_d = 0; sum_x = 0;
for jj = ["E" "D" "L"]
    sum_omy = sum_omy + om(jj)*g("y_" + jj);
    sum_d   = sum_d   + om(jj)*(1-ph(jj));
    sum_x   = sum_x   + om(jj)*ph(jj);
end
d8 = abs(sum_omy - (sum_d*g('y_d') + sum_x*g('y_x')));
fprintf('  v08: |sum(om_j*y_j) - [w_d*y_d + w_x*y_x]| = %.2e\n', d8);
R = jegyez(R, "3. lepcso", "sum(om*y_j) == w_d*y_d + w_x*y_x", d8, 1e-10, ...
    "a y_j BRUTTO kibocsatas, NEM GDP-komponens");

% =====================================================================
% (3) NULLA-SOKK TESZT
% =====================================================================
fprintf('\n--- (3) NULLA-SOKK: sokk nelkul minden 0? ---\n');
for mod_ = {'jv_dsge_v07_3type', 'jv_dsge_v08_3type_arak'}
    nev = mod_{1};
    lep = "2. lepcso"; if contains(nev, 'v08'), lep = "3. lepcso"; end
    dynare(nev, '-DSCENARIO=4', '-DTSCEN=3', 'console', 'nograph');
    mx = max(abs(oo_.endo_simul(:)));
    fprintf('  %-24s max|barmely valtozo| = %.2e\n', nev, mx);
    R = jegyez(R, lep, "nulla-sokk: minden valtozo 0", mx, 1e-9, nev);
end

% =====================================================================
% (4) A KET LEPCSO OSSZEVETESE: eps_ces -> 0 hatareset
% =====================================================================
fprintf('\n--- (4) eps_ces -> 0: kozelit-e a v08 a v07-hez? ---\n');
dynare('jv_dsge_v07_3type', '-DSCENARIO=1', '-DTSCEN=3', 'console', 'nograph');
n7 = cellstr(M_.endo_names);
y7 = [oo_.steady_state(strcmp(n7,'y_E')), oo_.steady_state(strcmp(n7,'y_D')), ...
      oo_.steady_state(strcmp(n7,'y_L'))];
elt = [];
for e_ = [6 3 1 0.25]
    dynare('jv_dsge_v08_3type_arak', '-DSCENARIO=1', '-DTSCEN=3', ...
        sprintf('-DEPSCES=%g', e_), 'console', 'nograph');
    n8 = cellstr(M_.endo_names);
    y8 = [oo_.steady_state(strcmp(n8,'y_E')), oo_.steady_state(strcmp(n8,'y_D')), ...
          oo_.steady_state(strcmp(n8,'y_L'))];
    elt(end+1) = max(abs(y8 - y7)); %#ok<SAGROW>
    fprintf('  eps_ces=%5.2f -> max|y_j(v08) - y_j(v07)| = %.4f pp\n', e_, 100*elt(end));
end
csokken = all(diff(elt) < 0);
fprintf('  monoton csokken? %s\n', string(csokken));
R = jegyez(R, "2+3 osszevetes", "eps_ces->0 kozelit a v07-hez", ...
    double(~csokken), 0.5, sprintf("elteres 6.0-nal %.3f pp, 0.25-nel %.3f pp", ...
    100*elt(1), 100*elt(end)));

% =====================================================================
% [a repo-t a fejlec mar beallitotta]
writetable(R, fullfile(repo, 'output', 'tables', 't43_ellenorzes_3type.csv'));

fprintf('\n%s\n', repmat('=', 1, 92));
fprintf('OSSZEGZES\n');
fprintf('%s\n', repmat('=', 1, 92));
for i = 1:height(R)
    jel = 'OK  '; if ~R.rendben(i), jel = 'HIBA'; end
    fprintf('  [%s] %-13s %-36s elteres=%.2e  %s\n', jel, R.lepcso(i), ...
        R.teszt(i), R.elteres(i), R.megjegyzes(i));
end
nb = sum(~R.rendben);
fprintf('%s\n', repmat('=', 1, 92));
if nb == 0
    fprintf('MIND A %d ELLENORZES ATMENT. A ket lepcso szerkezetileg helyes.\n', height(R));
else
    fprintf('!! %d ELLENORZES MEGBUKOTT -- a szerkezetben hiba van, javitando.\n', nb);
end
fprintf('%s\n', repmat('=', 1, 92));

function R = jegyez(R, lepcso, teszt, ertek, tur, megj)
    R = [R; table(string(lepcso), string(teszt), ertek, tur, ...
        ertek <= tur, string(megj), 'VariableNames', ...
        {'lepcso','teszt','elteres','turhatar','rendben','megjegyzes'})];
end
