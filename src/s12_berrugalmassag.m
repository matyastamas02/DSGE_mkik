% s12_berrugalmassag.m — bérrugalmasság: mit mutat a saját panelünk?
% =====================================================================
% Cégszintű átlagbér = bérköltség / létszám; a létszám csak 2023-ra és
% 2024-re ismert (statikus Alap lista mezők), ezért EGY átmenet mérhető:
% a 2023->2024 nominális átlagbér-változás cégszintű eloszlása.
%
% Amit keresünk (a bér-merevség klasszikus mikro-lenyomatai):
%   - csomósodás nulla körül (befagyasztott bérek)  -> nominális merevség
%   - hiányzó tömeg a negatív tartományban (kevés bércsökkentés)
%   - a medián viszonya az inflációhoz/országos bérdinamikához
% KORLÁTOK (a tanulmányban jelzendők): egyetlen év-pár; magas inflációs
% környezet (a lefelé-merevség kevésbé köt); átlagbér = összetétel-hatás
% (fluktuáció, bónuszok — Kézdi-Kónya: az alapbér merev, a bónusz rugalmas).
%
% Kimenet: output/tables/t17_beralkalmazkodas.csv
% Futtatás: matlab -batch "cd('src'); s12_berrugalmassag"

repo = fileparts(pwd);
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');

opts = detectImportOptions(panel_f);
opts.SelectedVariableNames = {'opten_id', 'ev', 'berkoltseg', ...
    'letszam_2023', 'letszam_2024', 'meret_kategoria'};
p = readtable(panel_f, opts);

b23 = p(p.ev == 2023 & p.berkoltseg > 0 & p.letszam_2023 >= 10, ...
    {'opten_id', 'berkoltseg', 'letszam_2023', 'meret_kategoria'});
b24 = p(p.ev == 2024 & p.berkoltseg > 0 & p.letszam_2024 >= 10, ...
    {'opten_id', 'berkoltseg', 'letszam_2024'});
m = innerjoin(b23, b24, 'Keys', 'opten_id');

w23 = m.berkoltseg_b23 ./ m.letszam_2023;   % ezer Ft / fő / év
w24 = m.berkoltseg_b24 ./ m.letszam_2024;
% plauzibilitás: évi 2,4-60 M Ft/fő bérköltség (kb. minimálbér-től felsővezetőig)
ok = w23 > 2400 & w23 < 60000 & w24 > 2400 & w24 < 60000;
g = w24(ok) ./ w23(ok) - 1;

sorok = {};
csop = {"osszes", true(size(m.meret_kategoria(ok)))};
kat = string(m.meret_kategoria(ok));
csoportok = {"összes", true(size(g)); ...
             "10-49", kat == "10-49"; ...
             "50-249", kat == "50-249"; ...
             "250+", kat == "250+"};
fprintf('Cégszintű nominális átlagbér-változás, 2023->2024 (n=%d)\n', numel(g));
T = table();
for i = 1:size(csoportok, 1)
    gi = g(csoportok{i, 2});
    uj = table(string(csoportok{i,1}), numel(gi), 100*median(gi), ...
        100*mean(gi < 0), 100*mean(abs(gi) <= 0.01), ...
        100*mean(gi < -0.01), 100*quantile(gi, 0.10), ...
        100*quantile(gi, 0.90), ...
        'VariableNames', {'csoport', 'n', 'median_pct', ...
        'nominalis_csokkentes_pct', 'befagyasztas_pm1_pct', ...
        'ersemi_csokkentes_pct', 'p10_pct', 'p90_pct'});
    T = [T; uj]; %#ok<AGROW>
end
writetable(T, fullfile(repo, 'output', 'tables', 't17_beralkalmazkodas.csv'));
disp(T);
fprintf(['Viszonyítás: a nemzetgazdasági bruttó átlagkereset-növekedés ' ...
    '2024-ben ~13%% volt (KSH).\n']);
