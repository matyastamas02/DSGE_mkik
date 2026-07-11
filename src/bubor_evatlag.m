function atlag = bubor_evatlag(evek)
% BUBOR_EVATLAG  3 havi BUBOR éves átlagai (tizedes törtként).
%   A letöltött MNB fixing-történetből számol (data/raw/makro/
%   bubor_tortenet.xls, évenkénti lapok, 7. oszlop = 3 hónap).
%   Hiányzó fájlnál hibát dob — a hívó dönt a tartalék-értékekről.

repo = fileparts(fileparts(mfilename('fullpath')));
f = fullfile(repo, 'data', 'raw', 'makro', 'bubor_tortenet.xls');
assert(exist(f, 'file') == 2, 'bubor_evatlag: hiányzik a %s', f);

atlag = zeros(size(evek));
for i = 1:numel(evek)
    c = readcell(f, 'Sheet', num2str(evek(i)));
    oszlop = c(3:end, 7);   % 3 hónapos tenor; 1-2. sor fejléc
    ertek = nan(numel(oszlop), 1);
    for j = 1:numel(oszlop)
        if isnumeric(oszlop{j}) && ~ismissing(oszlop{j})
            ertek(j) = oszlop{j};
        end
    end
    atlag(i) = mean(ertek, 'omitnan') / 100;
end
end
