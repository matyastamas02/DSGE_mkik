% run_all.m — teljes reprodukciós lánc egy paranccsal
% =====================================================================
% adat -> panel -> leíró stat -> modellek -> leképezés -> extenzív margó
% Futtatás a repo gyökeréből:  matlab -batch "cd('src'); run_all"
%
% Script-formában fut (nem függvényben), mert a Dynare az eredményeit
% (oo_, M_) a base munkaterületre teszi — függvénybe csomagolva a
% modell-lépések nem látnák. Ezért a lépés-segédek neve aláhúzásos,
% hogy ne ütközzenek a modell-változókkal.
%
% Előfeltételek: data/raw/opten.xlsx a helyén (lásd data-index.md),
% Python 3 (pandas, matplotlib, openpyxl) a korai 01-05 scriptekhez,
% Dynare (DYNARE_PATH env, alapértelmezés C:\dynare\6.5\matlab).

t_ossz_ = tic;

lep_('1/12:Panel-előkészítés (python)');
piton_('python 01_opten_panel_tisztitas.py');

lep_('2/12:Leíró statisztika (python)');
piton_('python 02_leiro_stat.py');

lep_('3/12:Modell v0.1 + IRF-export');
ide_ = pwd; cd('model'); run_v01; cd(ide_);

lep_('4/12:Modell v0.3 szcenáriók');
ide_ = pwd; cd('model'); run_v03; cd(ide_);

lep_('5/12:IRF-ábra (python)');
piton_('python 03_irf_abrak.py');

lep_('6/12:Szcenárió-ábra v0.3 (python)');
piton_('python 05_szcenario_abrak_v03.py');

lep_('7/12: Szegmens-leképezés');
s06_szegmens_lekepezes;

lep_('8/12: Extenzív margó');
s07_extenziv_margo;

lep_('9/12: Támogatott-hitel teszt + támogatási ék');
s08_tamogatott_hitel_teszt;
s09_tamogatasi_ek;

lep_('10/12: IRF-panelek + akcelerátor ki/be');
s10_irf_panelek;

lep_('11/12: Fázis-idővonal + csatorna-dekompozíció');
s11_fazis_es_dekompozicio;

lep_('12/12: Füstteszt');
smoke_test;

fprintf('\nTELJES LÁNC KÉSZ: %.1f perc\n', toc(t_ossz_)/60);

function lep_(cim)
    fprintf('\n===== [%s] =====\n', cim);
end

function piton_(parancs)
    setenv('PYTHONIOENCODING', 'utf-8');
    st_ = system(parancs);
    assert(st_ == 0, 'A parancs hibával tért vissza: %s', parancs);
end
