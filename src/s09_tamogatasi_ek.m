% s09_tamogatasi_ek.m — az implicit kamattámogatási ék nagyságrendje
% =====================================================================
% Kérdés: mekkora fiskális/implicit ék tartja fenn a mai KKV-hitelárazást?
% Cég-évenként: ék_i = max(0, referencia − tényleges ráta_i) × hitelállomány_i
% ahol tényleges ráta = kamatráfordítás / hitelállomány (0 is lehet).
%
% Két referencia (érzékenység):
%   - konzervatív: 3 havi BUBOR éves átlaga (a bank forrásköltsége)
%   - piaci proxy: BUBOR + 200 bp (tipikus KKV-felár nagyságrend)
% BUBOR: közelítő éves átlagok (mint s08) — letöltött idősorral pótolandó.
%
% FIGYELEM: ez NEM költségvetési tétel pontos becslése (az ék egy részét
% fix vintage-árazás adja, nem támogatás), hanem a piaci és a tényleges
% árazás közti rés nagyságrendje: mennyibe kerülne MA piaci áron ugyanez
% az állomány. A minta a 10+ fős cégek köre (37 805 cég), nem a teljes
% KKV-szektor.
%
% Kimenet:  output/tables/t14_tamogatasi_ek.csv
% Futtatás: matlab -batch "cd('src'); s09_tamogatasi_ek"

repo = fileparts(pwd);
panel_f = fullfile(repo, 'data', 'processed', 'opten_panel.csv');

opts = detectImportOptions(panel_f);
opts.SelectedVariableNames = {'ev', 'meret_kategoria', 'hitelallomany', ...
    'kamatraforditas'};
p = readtable(panel_f, opts);
p = p(p.ev >= 2021 & p.ev <= 2024 & p.hitelallomany > 0, :);
kkv_e = ismember(string(p.meret_kategoria), ["10-49", "50-249"]);

evek = [2021 2022 2023 2024];
try
    bubor = bubor_evatlag(evek);   % letöltött MNB-idősorból
    fprintf('BUBOR éves átlagok (MNB): %s%%\n', ...
        mat2str(round(100*bubor, 2)));
catch
    bubor = [0.017 0.099 0.136 0.074];   % tartalék-közelítés
    warning('BUBOR-fájl hiányzik — közelítő éves átlagok!');
end

rata = max(0, p.kamatraforditas) ./ p.hitelallomany;
rata(isnan(rata)) = 0;

T = table();
for e = 1:4
    m = p.ev == evek(e) & kkv_e;
    allomany_mrd = sum(p.hitelallomany(m)) / 1e6;   % ezer Ft -> Mrd Ft
    ek1 = sum(max(0, bubor(e) - rata(m)) .* p.hitelallomany(m)) / 1e6;
    ek2 = sum(max(0, bubor(e) + 0.02 - rata(m)) .* p.hitelallomany(m)) / 1e6;
    arany_alul = mean(rata(m) < bubor(e) - 0.02);
    uj = table(evek(e), sum(m), allomany_mrd, 100*bubor(e), ...
        ek1, ek2, 100*ek1/allomany_mrd, 100*arany_alul, ...
        'VariableNames', {'ev', 'kkv_ceg_ev_hitellel', ...
        'kkv_hitelallomany_MrdFt', 'bubor_pct', ...
        'ek_bubor_MrdFt', 'ek_bubor200_MrdFt', ...
        'ek_allomany_aranyaban_pct', 'alularazott_cegek_pct'});
    T = [T; uj]; %#ok<AGROW>
end
writetable(T, fullfile(repo, 'output', 'tables', 't14_tamogatasi_ek.csv'));
disp(T);

fprintf(['\nOlvasat: az ék azt méri, mennyivel kerülne többe ugyanez az\n' ...
    'állomány piaci (BUBOR / BUBOR+200bp) áron. A 2023-as csúcsérték a\n' ...
    '"mennyibe kerül az euró hiánya" headline-szám alapja (mintabeli,\n' ...
    '10+ fős kör — a teljes KKV-szektorra ennél nagyobb).\n']);
