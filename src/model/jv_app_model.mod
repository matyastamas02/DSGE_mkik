/*
 * jv_app_model.mod — a Streamlit-app által vezérelt JV+BGG modell
 * =====================================================================
 * A jv_dsge_v02 (Jakab–Világi mag + kétszektoros BGG) változata, ahol a
 * felhasználó által állítható paraméterek @#define-ből jönnek, így az app
 * egyetlen `dynare jv_app_model -DSIGMA=... -DHABIT=... console` hívással
 * újraparaméterezhető. A -D-vel nem felülírt paraméterek a JV becsült
 * poszterior-átlagát veszik fel (alapértelmezés).
 *
 * NE ezt szerkeszd a modellezéshez — ez az app futtató-változata; a
 * kanonikus modell a jv_dsge_v02.mod.
 */

@#ifndef SIGMA
  @#define SIGMA = 1.814
@#endif
@#ifndef HABIT
  @#define HABIT = 0.646
@#endif
@#ifndef XIP
  @#define XIP = 0.921
@#endif
@#ifndef XIW
  @#define XIW = 0.657
@#endif
@#ifndef PHIPI
  @#define PHIPI = 1.379
@#endif
@#ifndef GAMI
  @#define GAMI = 0.761
@#endif
@#ifndef MUX
  @#define MUX = 0.534
@#endif
@#ifndef PSII
  @#define PSII = 13.0
@#endif
@#ifndef CHIS
  @#define CHIS = 0.06
@#endif
@#ifndef CHIL
  @#define CHIL = 0.02
@#endif
@#ifndef LEVS
  @#define LEVS = 1.6
@#endif
@#ifndef LEVL
  @#define LEVL = 1.85
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
    rho_a rho_x rho_c rho_w rho_i rho_pr rho_mx rho_g
;

beta = 0.99; delta = 0.025;
zeta_d = 0.17; zeta_x = 0.14; rho_kz = 0.80; rho_z = 0.50;
theta_w = 3.0; nu_b = 0.001; om_no = 0.25; fii = 2.0;
a_d = 0.80; a_x = 0.45;
xi_x = 0.810; vth_x = 0.494; vth_p = 0.431; vth_w = 0.185;
hx = 0.507;
// --- app-vezérelt paraméterek (@#define) ---
sigma  = @{SIGMA};
habit  = @{HABIT};
xi_p   = @{XIP};
xi_w   = @{XIW};
phi_pi = @{PHIPI};
gam_i  = @{GAMI};
mu_x   = @{MUX};
psi_i  = @{PSII};
chi_S  = @{CHIS};
chi_L  = @{CHIL};
lev_S  = @{LEVS};
lev_L  = @{LEVL};
lam_p = (1-xi_p)*(1-beta*xi_p)/xi_p;
lam_x = (1-xi_x)*(1-beta*xi_x)/xi_x;
lam_w = (1-xi_w)*(1-beta*xi_w)/(xi_w*(1+theta_w*fii));
sc = 0.54; si = 0.23; sg = 0.10; sx = 0.60; sm = 0.47;
sh_yd = 0.60; sh_ld = 0.70; sh_kd = 0.65; sh_imd = 0.30;
eps_qw = 0.96; omega_nw = 0.95; om_S = 0.50;
rho_a = 0.552; rho_x = 0.625; rho_c = 0.767; rho_w = 0.661;
rho_i = 0.488; rho_pr = 0.820; rho_mx = 0.318; rho_g = 0.80;

model(linear);

c_o = habit/(1+habit)*c_o(-1) + 1/(1+habit)*c_o(+1)
      - (1-habit)/((1+habit)*sigma)*(r - infl(+1)) + e_c_ar;
c_no = w + ll;
c = (1-om_no)*c_o + om_no*c_no;

ret_S = (1-eps_qw)*rk + eps_qw*q_S - q_S(-1);
ret_L = (1-eps_qw)*rk + eps_qw*q_L - q_L(-1);
ret_S(+1) = r - infl(+1) + efp_S + eps_q;
ret_L(+1) = r - infl(+1) + efp_L + eps_q;
efp_S = chi_S*(q_S + k_S - nw_S);
efp_L = chi_L*(q_L + k_L - nw_L);
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
r = dep(+1) - nu_b*bstar + e_pr_ar;
rer = rer(-1) + dep - infl;
r = gam_i*r(-1) + (1-gam_i)*phi_pi*infl + eps_r;

a       = rho_a*a(-1) + eps_a;
e_x_ar  = rho_x*e_x_ar(-1) + eps_x;
e_c_ar  = rho_c*e_c_ar(-1) + eps_c;
e_w_ar  = rho_w*e_w_ar(-1) + eps_w;
e_i_ar  = rho_i*e_i_ar(-1) + eps_i;
e_pr_ar = rho_pr*e_pr_ar(-1) + eps_pr;
e_mx_ar = rho_mx*e_mx_ar(-1) + eps_mx;
g       = rho_g*g(-1) + eps_g;

end;

shocks;
var eps_a;  stderr 0.02152;
var eps_x;  stderr 0.02464;
var eps_c;  stderr 0.00203;
var eps_md; stderr 0.00420;
var eps_mx; stderr 0.02182;
var eps_w;  stderr 0.00932;
var eps_i;  stderr 0.01003;
var eps_q;  stderr 0.00393;
var eps_r;  stderr 0.00247;
var eps_pr; stderr 0.00666;
var eps_g;  stderr 0.01;
end;

stoch_simul(order=1, irf=24, nograph, noprint) y c ii i_S i_L efp_S efp_L
    nw_S nw_L xx infl piw r rer w rk;
