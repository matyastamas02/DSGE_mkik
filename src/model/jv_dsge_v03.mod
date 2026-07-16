/*
 * jv_dsge_v03.mod — Euró-belépési szcenárió a Jakab–Világi alapon
 * =====================================================================
 * A jv_dsge_v02 (JV-mag + kétszektoros BGG) szcenárió-változata:
 *  - a két hitelköltség-csatorna anticipált, permanens exogén pálya:
 *    szuverén prémium (sov) és banki forrásköltség (bank), a pitch
 *    transzmissziós súlyaival (tsov_S=0.25/tsov_L=0.10; tbank 0.60/0.30);
 *  - a szuverén konvergencia zsov=0.5 súllyal az UIP-be is belép
 *    (kockázatmentes görbe / árfolyam-oldal);
 *  - kamatunió-rezsimváltás a belépéskor (uni dummy): Taylor+UIP ->
 *    r = euró-kamat (+ NFA-rugalmas felár), dep = 0.
 * Időzítés (mint az EAGLE-vonalon): bejelentés q1, ERM-II q1-12
 * (szuverén 60%-ig), belépés q13, teljes hatás q16, tartós: endval.
 *
 * A JV-vonal előnye itt: a mag magyar adaton BECSÜLT, és a 25%-os
 * kézről-szájra arány is becslés/survey-alapú (nem kalibrált 75%).
 *
 * Szcenáriók: -DSCENARIO=1 (alap, -200bp/-45bp) | 2 (opt) | 3 (pessz)
 * Futtatás:   run_jv_v03.m
 */

@#ifndef SCENARIO
  @#define SCENARIO = 1
@#endif

var
    c_o c_no c ii k
    rk w piw infl pix px
    wz_d wz_x mc_d mcx_rel
    y_d y_x z_d z_x l_d l_x ll im xx y
    r dep rer bstar
    k_S k_L i_S i_L q_S q_L ret_S ret_L efp_S efp_L nw_S nw_L
    a g e_c_ar e_x_ar e_w_ar e_i_ar e_pr_ar e_mx_ar
;

varexo
    sov bank uni
    eps_a eps_x eps_c eps_md eps_mx eps_w eps_i eps_q eps_r eps_pr eps_g
;

parameters
    beta delta sigma habit fii
    zeta_d zeta_x a_d a_x rho_kz rho_z
    xi_p vth_p xi_x vth_x xi_w vth_w theta_w
    lam_p lam_x lam_w
    psi_i hx mu_x
    gam_i phi_pi nu_b
    om_no
    sc si sg sx sm
    sh_ld sh_kd sh_imd sh_yd
    chi_S chi_L eps_qw omega_nw lev_S lev_L om_S
    tsov_S tsov_L tbank_S tbank_L zsov nu_uni
    rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g
;

beta = 0.99; delta = 0.025;
zeta_d = 0.17; zeta_x = 0.14; rho_kz = 0.80; rho_z = 0.50;
theta_w = 3.0; psi_i = 13.0; nu_b = 0.001; om_no = 0.25; fii = 2.0;
a_d = 0.80; a_x = 0.45;
sigma = 1.814; habit = 0.646;
xi_p = 0.921; vth_p = 0.431;
xi_x = 0.810; vth_x = 0.494;
xi_w = 0.657; vth_w = 0.185;
mu_x = 0.534; hx = 0.507; gam_i = 0.761; phi_pi = 1.379;
lam_p = (1-xi_p)*(1-beta*xi_p)/xi_p;
lam_x = (1-xi_x)*(1-beta*xi_x)/xi_x;
lam_w = (1-xi_w)*(1-beta*xi_w)/(xi_w*(1+theta_w*fii));
sc = 0.54; si = 0.23; sg = 0.10; sx = 0.60; sm = 0.47;
sh_yd = 0.60; sh_ld = 0.70; sh_kd = 0.65; sh_imd = 0.30;
chi_S = 0.06; chi_L = 0.02;
eps_qw = 0.96; omega_nw = 0.95;
lev_S = 1.6; lev_L = 1.85; om_S = 0.50;
tsov_S = 0.25; tsov_L = 0.10; tbank_S = 0.60; tbank_L = 0.30;
zsov = 0.5;
// Az unió-rezsim zárása: a JV becsült nu_b=0.001-e a belépés ELŐTTI
// UIP-dinamikára való; az unió-ági kamategyenletben túl gyenge horgony
// (bstar_ss = zsov*sov/nu -> -250% GDP-nél állna be). Ezért az unió-ágon
// külön, erősebb TECHNIKAI zárást használunk (mint az EAGLE-vonalon):
nu_uni = 0.01;
rho_a = 0.552; rho_x = 0.625; rho_c = 0.767; rho_w = 0.661;
rho_i = 0.488; rho_pr = 0.820; rho_mx = 0.318; rho_g = 0.80;

model;

c_o = habit/(1+habit)*c_o(-1) + 1/(1+habit)*c_o(+1)
      - (1-habit)/((1+habit)*sigma)*(r - infl(+1)) + e_c_ar;
c_no = w + ll;
c = (1-om_no)*c_o + om_no*c_no;

ret_S = (1-eps_qw)*rk + eps_qw*q_S - q_S(-1);
ret_L = (1-eps_qw)*rk + eps_qw*q_L - q_L(-1);
ret_S(+1) = r - infl(+1) + efp_S + eps_q;
ret_L(+1) = r - infl(+1) + efp_L + eps_q;
efp_S = chi_S*(q_S + k_S - nw_S) + tsov_S*sov + tbank_S*bank;
efp_L = chi_L*(q_L + k_L - nw_L) + tsov_L*sov + tbank_L*bank;
nw_S = omega_nw*(nw_S(-1) + lev_S*(ret_S - (r(-1) - infl)));
nw_L = omega_nw*(nw_L(-1) + lev_L*(ret_L - (r(-1) - infl)));
i_S = 1/(1+beta)*i_S(-1) + beta/(1+beta)*i_S(+1)
      + 1/((1+beta)*psi_i)*q_S + e_i_ar;
i_L = 1/(1+beta)*i_L(-1) + beta/(1+beta)*i_L(+1)
      + 1/((1+beta)*psi_i)*q_L + e_i_ar;
k_S = (1-delta)*k_S(-1) + delta*i_S;
k_L = (1-delta)*k_L(-1) + delta*i_L;
k  = om_S*k_S + (1-om_S)*k_L;
ii = om_S*i_S + (1-om_S)*i_L;

wz_d = a_d*w + (1-a_d)*rer;
wz_x = a_x*w + (1-a_x)*rer;
mc_d = zeta_d*rk + (1-zeta_d)*wz_d - a;
mcx_rel = zeta_x*rk + (1-zeta_x)*wz_x - a - px;
z_d = rho_kz*zeta_d*(rk - wz_d) + y_d - a;
z_x = rho_kz*zeta_x*(rk - wz_x) + y_x - a;
l_d = z_d - rho_z*(w - wz_d);
l_x = z_x - rho_z*(w - wz_x);
ll  = sh_ld*l_d + (1-sh_ld)*l_x;
im  = sh_imd*(z_d - rho_z*(rer - wz_d)) + (1-sh_imd)*(z_x - rho_z*(rer - wz_x));
k(-1) = sh_kd*(z_d - rho_kz*(rk - wz_d)) + (1-sh_kd)*(z_x - rho_kz*(rk - wz_x));

infl = beta/(1+beta*vth_p)*infl(+1) + vth_p/(1+beta*vth_p)*infl(-1)
       + lam_p/(1+beta*vth_p)*mc_d + eps_md;
pix  = beta/(1+beta*vth_x)*pix(+1) + vth_x/(1+beta*vth_x)*pix(-1)
       + lam_x/(1+beta*vth_x)*mcx_rel + e_mx_ar;
piw  = beta/(1+beta*vth_w)*piw(+1) + vth_w/(1+beta*vth_w)*piw(-1)
       + lam_w/(1+beta*vth_w)*(sigma/(1-habit)*(c - habit*c(-1))
                                + fii*ll - w) + e_w_ar;
w  = w(-1) + piw - infl;
px = px(-1) + pix - infl;

xx = hx*xx(-1) + (1-hx)*(-mu_x*(px - rer)) + e_x_ar;
y_x = xx;
y_d = (sc*c + si*ii + sg*g)/(sc+si+sg);
y  = sc*c + si*ii + sg*g + sx*xx - sm*im;
bstar = (1/beta)*bstar(-1) + sx*(px + xx) - sm*(rer + im);

// --- REZSIMFÜGGŐ monetáris blokk (mint kkv_dsge_v04) ---
(1-uni)*(r - gam_i*r(-1) - (1-gam_i)*phi_pi*infl - eps_r)
    + uni*(r - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - dep(+1) + nu_b*bstar - zsov*sov - e_pr_ar) + uni*dep = 0;
rer = rer(-1) + dep - infl;

a       = rho_a*a(-1) + eps_a;
e_x_ar  = rho_x*e_x_ar(-1) + eps_x;
e_c_ar  = rho_c*e_c_ar(-1) + eps_c;
e_w_ar  = rho_w*e_w_ar(-1) + eps_w;
e_i_ar  = rho_i*e_i_ar(-1) + eps_i;
e_pr_ar = rho_pr*e_pr_ar(-1) + eps_pr;
e_mx_ar = rho_mx*e_mx_ar(-1) + eps_mx;
g       = rho_g*g(-1) + eps_g;

end;

initval;
sov = 0; bank = 0; uni = 0;
end;

@#if SCENARIO == 1
endval;
sov = -0.005; bank = -0.001125; uni = 1;
end;
@#elseif SCENARIO == 2
endval;
sov = -0.00625; bank = -0.00175; uni = 1;
end;
@#else
endval;
sov = -0.00375; bank = -0.0005; uni = 1;
end;
@#endif

steady;

@#if SCENARIO == 1
shocks;
var uni;  periods 1:12; values 0;
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.00025 -0.0005 -0.00075 -0.001 -0.00125 -0.0015 -0.00175 -0.002
       -0.00225 -0.0025 -0.00275 -0.003 -0.0035 -0.004 -0.0045 -0.005;
var bank;
periods 1:12 13 14 15 16;
values 0 -0.00028125 -0.0005625 -0.00084375 -0.001125;
end;
@#elseif SCENARIO == 2
shocks;
var uni;  periods 1:12; values 0;
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.0003125 -0.000625 -0.0009375 -0.00125 -0.0015625 -0.001875
       -0.0021875 -0.0025 -0.0028125 -0.003125 -0.0034375 -0.00375
       -0.004375 -0.005 -0.005625 -0.00625;
var bank;
periods 1:12 13 14 15 16;
values 0 -0.0004375 -0.000875 -0.0013125 -0.00175;
end;
@#else
shocks;
var uni;  periods 1:12; values 0;
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.0001875 -0.000375 -0.0005625 -0.00075 -0.0009375 -0.001125
       -0.0013125 -0.0015 -0.0016875 -0.001875 -0.0020625 -0.00225
       -0.002625 -0.003 -0.003375 -0.00375;
var bank;
periods 1:12 13 14 15 16;
values 0 -0.000125 -0.00025 -0.000375 -0.0005;
end;
@#endif

perfect_foresight_setup(periods=120);
perfect_foresight_solver;
