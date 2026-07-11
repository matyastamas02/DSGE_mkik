% s10_irf_panelek.m — A1+A2 kulcsábrák a modellfejezethez
% =====================================================================
% A1: teljes IRF-panelek (3x3) a három fő sokkra: szuverén prémium,
%     banki forrásköltség, monetáris — KKV/nagyvállalat overlay-jel.
%     (Minta: MNB WP 2017/7 és BGG ábra-konvenciói.)
% A2: "akcelerátor ki/be" — ugyanaz a banki sokk chi=0 mellett vs.
%     kalibrált chi-vel (BGG 1999 klasszikus ábrája).
%
% A v0.1 modellt futtatja kétszer (normál + -DNOACCEL).
% Kimenet:  output/figures/f10_irf_sov.png, f11_irf_bank.png,
%           f12_irf_monetaris.png, f13_akcelerator_kibe.png
% Futtatás: matlab -batch "cd('src'); s10_irf_panelek"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

ide_ = pwd; cd('model');
dynare('kkv_dsge_v01', 'console');
irf_be = oo_.irfs;
dynare('kkv_dsge_v01', '-DNOACCEL', 'console');
irf_ki = oo_.irfs;
cd(ide_);

repo = fileparts(pwd);
abrak = fullfile(repo, 'output', 'figures');

% --- A1: 3x3 panelek sokkonként (euró-iránynak megfelelő előjellel) ----
sokkok  = {'e_sov', 'e_bank', 'e_m'};
cimek   = {'Szuverén prémium-csökkenés (euró-irány)', ...
           'Banki forrásköltség-csökkenés (euró-irány)', ...
           'Monetáris lazítás (validációs sokk)'};
fajlok  = {'f10_irf_sov.png', 'f11_irf_bank.png', 'f12_irf_monetaris.png'};
elojel  = [-1 -1 -1];   % tárolt IRF-ek +1 szórásra; euró-irány = csökkenés

% panelenként: {változó-alap, cím, szektorális-e, skála}
valtozok = { ...
    'y',    'Kibocsátás (%)',            true,  100; ...
    'c',    'Fogyasztás (%)',            false, 100; ...
    'ii',   'Beruházás (%)',             true,  100; ...
    'infl', 'Infláció (évesített bp)',   false, 40000; ...
    'r',    'Kamat (évesített bp)',      false, 40000; ...
    'rer',  'Reálárfolyam (%)',          false, 100; ...
    'efp_S','EFP (évesített bp)',        true,  40000; ...
    'nw_S', 'Nettó vagyon (%)',          true,  100; ...
    'xx',   'Export (%)',                false, 100};

kek = [42 120 214]/255; aqua = [27 175 122]/255;
tinta = [0.04 0.04 0.04]; masod = [0.32 0.31 0.29];
felulet = [0.988 0.988 0.984];

for s = 1:3
    fig = figure('Visible', 'off', 'Position', [50 50 1180 900], ...
        'Color', felulet);
    for v = 1:9
        ax = subplot(3, 3, v); hold(ax, 'on');
        alap = valtozok{v, 1}; szekt = valtozok{v, 3}; sk = valtozok{v, 4};
        if szekt
            % szektorpáros változók: _S/_L; aggregáltak: y_S/y_L, i_S/i_L
            switch alap
                case 'y',  nS = 'y_S';  nL = 'y_L';
                case 'ii', nS = 'i_S';  nL = 'i_L';
                otherwise
                    nS = alap; nL = strrep(alap, '_S', '_L');
            end
            hS = plot(ax, elojel(s)*sk*irf_be.([nS '_' sokkok{s}]), ...
                '-', 'Color', kek, 'LineWidth', 1.8);
            hL = plot(ax, elojel(s)*sk*irf_be.([nL '_' sokkok{s}]), ...
                '-', 'Color', aqua, 'LineWidth', 1.8);
            if v == 1
                legend(ax, [hS hL], {'KKV', 'nagyvállalat'}, ...
                    'Box', 'off', 'FontSize', 8, 'Location', 'best');
            end
        else
            plot(ax, elojel(s)*sk*irf_be.([alap '_' sokkok{s}]), ...
                '-', 'Color', kek, 'LineWidth', 1.8);
        end
        yline(ax, 0, 'Color', masod, 'LineWidth', 0.6);
        set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
            'YColor', masod, 'FontSize', 8);
        grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
        title(ax, valtozok{v, 2}, 'FontSize', 9.5, 'Color', tinta, ...
            'FontWeight', 'normal');
    end
    sgtitle(fig, sprintf('%s — IRF-ek, 24 negyedév (v0.1)', cimek{s}), ...
        'FontSize', 12, 'Color', tinta);
    exportgraphics(fig, fullfile(abrak, fajlok{s}), 'Resolution', 180);
    fprintf('Kiírva: %s\n', fajlok{s});
end

% --- A2: az akcelerátor két arca (ki/be összehasonlítás) ---------------
% Monetáris sokknál a nettóvagyon-csatorna ERŐSÍT (klasszikus BGG,
% a KKV-beruházási válasz ~2,4-szeres); exogén prémium-sokknál viszont
% az endogén tőkeáttétel-válasz részben TOMPÍT (a fellendülésben a
% cégek eladósodnak, a prémium visszapattan). Mindkettő strukturális
% tulajdonság, a tanulmányban együtt kommunikálandó.
fig = figure('Visible', 'off', 'Position', [50 50 1040 430], ...
    'Color', felulet);
panelek = {'e_m',    -1, 'Monetáris lazítás: ERŐSÍT (nettóvagyon-csatorna)';
           'e_bank', -1, 'Prémium-csökkenés: részben TOMPÍT (tőkeáttétel)'};
for v = 1:2
    ax = subplot(1, 2, v); hold(ax, 'on');
    nev = ['i_S_' panelek{v, 1}];
    h1 = plot(ax, panelek{v,2}*100*irf_be.(nev), '-', 'Color', kek, ...
        'LineWidth', 2);
    h2 = plot(ax, panelek{v,2}*100*irf_ki.(nev), '--', 'Color', masod, ...
        'LineWidth', 1.8);
    yline(ax, 0, 'Color', masod, 'LineWidth', 0.6);
    set(ax, 'Box', 'off', 'Color', felulet, 'XColor', masod, ...
        'YColor', masod, 'FontSize', 9);
    grid(ax, 'on'); ax.GridColor = [0.9 0.9 0.87]; ax.GridAlpha = 1;
    title(ax, panelek{v, 3}, 'FontSize', 10, 'Color', tinta);
    xlabel(ax, 'negyedév', 'FontSize', 9);
    ylabel(ax, 'KKV-beruházás, %', 'FontSize', 9);
    legend(ax, [h1 h2], {'akcelerátorral (\chi kalibrált)', ...
        'akcelerátor nélkül (\chi=0)'}, 'Box', 'off', 'FontSize', 9, ...
        'Location', 'northeast');
end
sgtitle(fig, ['A pénzügyi akcelerátor két arca — KKV-beruházási válasz ' ...
    '\chi-vel és \chi=0-val (v0.1)'], 'FontSize', 12, 'Color', tinta);
exportgraphics(fig, fullfile(abrak, 'f13_akcelerator_kibe.png'), ...
    'Resolution', 180);
fprintf('Kiírva: f13_akcelerator_kibe.png\n');
