% diag_yd_v04.m — DIAGNOSZTIKA: miért fordul negatívba a y_d (KKV-kibocsátás)
% hosszú távon, miközben a h_dx (export-input kereslet) tartósan magas marad?
% Tagonként bontja: y_d = shd_c*c + shd_i*i_S + shd_g*g + shd_v*h_dx
% Futtatás: matlab -batch "cd('<repo>/src/model'); diag_yd_v04"

dynare_path = getenv('DYNARE_PATH');
if isempty(dynare_path), dynare_path = 'C:\dynare\6.5\matlab'; end
addpath(dynare_path);

dynare jv_dsge_v04 console
irf = oo_.irfs;

shd_c = 0.55; shd_i = 0.15; shd_g = 0.12; shd_v = 0.18;

sokk = 'eps_r';
c_   = irf.(['c_' sokk]);
i_S_ = irf.(['i_S_' sokk]);
g_   = irf.(['g_' sokk]);
h_dx_ = irf.(['h_dx_' sokk]);
y_d_ = irf.(['y_d_' sokk]);

tag_c = shd_c * c_;
tag_i = shd_i * i_S_;
tag_g = shd_g * g_;
tag_v = shd_v * h_dx_;
osszeg = tag_c + tag_i + tag_g + tag_v;

fprintf('Azonossag-ellenorzes (max |y_d - szamolt|): %.2e (~0 kell)\n', ...
    max(abs(y_d_ - osszeg)));

H = [1 2 4 6 8 12 16 20 24];
fprintf('\n%-3s %8s | %8s %8s %8s %8s | %8s\n', ...
    'h', 'y_d', 'c-tag', 'i_S-tag', 'g-tag', 'h_dx-tag', 'osszeg');
for h = H
    fprintf('%-3d %8.3f | %8.3f %8.3f %8.3f %8.3f | %8.3f\n', h, ...
        -100*y_d_(h), -100*tag_c(h), -100*tag_i(h), -100*tag_g(h), ...
        -100*tag_v(h), -100*osszeg(h));
end

fprintf(['\nOszlopok: az egyes tagok HOZZAJARULASA szazalekpontban a\n' ...
    'y_d-hez (elojel forditva, "lazitas"-kent mutatva, mint az abrakon).\n' ...
    'Ha egy tag idovel elojelet valt vagy dominansa valik negativba,\n' ...
    'az a felelos a y_d hosszu tavu visszaesesert.\n']);

% melyik tag mozog a legtavolabb a nullatol h=24-nel?
h24 = 24;
tags = [tag_c(h24) tag_i(h24) tag_g(h24) tag_v(h24)];
nevek = {'c (fogyasztas)', 'i_S (KKV-beruhazas)', 'g (kormanyzat)', ...
    'h_dx (export-input)'};
[~, idx] = max(abs(tags));
fprintf('A h=24-nel legnagyobb (abszolut) hozzajarulasu tag: %s (%.3f%%)\n', ...
    nevek{idx}, -100*tags(idx));
