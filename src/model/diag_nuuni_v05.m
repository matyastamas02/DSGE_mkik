% diag_nuuni_v05.m — DIAGNOSZTIKA: az unió-rezsim zárásának (nu_uni)
% erőssége hogyan hat a hosszú távú steady state-re.
% Kérdés: mekkora nu_uni kell ahhoz, hogy a reálárfolyam (rer) plauzibilis
% maradjon egy euró-belépésnél, ÉS a link nélküli eset konzisztens legyen
% a v03-mal (y ~ +1.09%)?
% Futtatás: matlab -batch "cd('<repo>/src/model'); diag_nuuni_v05"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

nuk = [0.01 0.05 0.10 0.25 0.50];
valt = {'y','y_d','y_x','rer','c','i_S','i_L','bstar'};

for mode = [1 0]   % 1 = link nelkul (validacio), 0 = linkkel
    if mode == 1
        fprintf('\n=== LINK NELKUL (NOVERT=1) — validacio a v03-hoz (+1.09%%) ===\n');
    else
        fprintf('\n=== LINKKEL (NOVERT=0) — a tenyleges modell ===\n');
    end
    fprintf('%-8s', 'nu_uni');
    for v = 1:numel(valt), fprintf('%9s', valt{v}); end
    fprintf('\n');
    for nu = nuk
        dynare('jv_dsge_v05', '-DSCENARIO=1', ...
            sprintf('-DNOVERT=%d', mode), ...
            sprintf('-DNUUNI=%g', nu), 'console');
        n = cellstr(M_.endo_names);
        fprintf('%-8.3g', nu);
        for v = 1:numel(valt)
            ss = oo_.steady_state(strcmp(n, valt{v}));
            fprintf('%+9.3f', 100*ss);
        end
        fprintf('\n');
    end
end

fprintf(['\nOlvasat: a rer (realarfolyam) hosszu tavu erteke egy euro-\n' ...
    'belepesnel NEM lehet 30%%+ — plauzibilis savnak nagysagrendileg\n' ...
    '0-10%% tekintheto. Keressuk a legkisebb nu_uni-t, ahol ez teljesul\n' ...
    'es a link nelkuli y kozel marad a v03 +1.09%%-hoz.\n']);
