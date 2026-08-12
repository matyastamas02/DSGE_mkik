/*
 * kkv_dsge_v06_3type.mod — explicit haromtípusos KKV/nagyvallalat vaz
 * =====================================================================
 *
 * Cel: a v05 EAGLE-vonal minimalis, futtathato tovabbontasa harom
 * vallalati tipusra:
 *
 *   E  = export-orientalt KKV
 *   D  = hazai orientacioju KKV
 *   L  = aggregalt nagyvallalat
 *
 * Ez a verzio szandekosan nem a jv_dsge_v05.mod atirasa. A JV-vonalban a
 * meretdimenzio (KKV/nagyvallalat) es a piacdimenzio (hazai/export) ossze
 * van csusztatva. Itt a vallalati tipusok kulon termeloegysegek, kulon
 * tokevel, beruhazassal, arral es penzugyi akceleratorral.
 *
 * Mi van benne:
 *   - harom tipus-specifikus termelesi blokk;
 *   - harom tipus-specifikus BGG-lite penzugyi blokk;
 *   - harom szektoralis arupiaci zaras: kulon hazai abszorpcio,
 *     kulon E/D/L exportkereslet es harom szektoralis output;
 *   - euro-szcenario: szuveren es banki premiumcsokkenes + kamatunio dummy;
 *   - v05 haztartasi es Calvo-ber blokkja.
 *
 * Mi nincs meg benne:
 *   - reszletes IO/Gamma beszallitoi matrix;
 *   - hiszterezis/beachhead modul;
 *   - nagyvallalat exportalo/nem exportalo altipus;
 *   - frissitett tranzakcios koltseg es szeigniorazs blokk.
 *
 * Futtatas:
 *   matlab -batch "cd('<repo>/src/model'); run_v06_3type"
 */

@#ifndef SCENARIO
  @#define SCENARIO = 1
@#endif
@#ifndef OMNR
  @#define OMNR = 75
@#endif
@#ifndef THETAW
  @#define THETAW = 75
@#endif
@#ifndef TSCEN
  @#define TSCEN = 3
@#endif
@#ifndef NUUNI
  @#define NUUNI = 0.25
@#endif

var
    c c_R c_N lam w nn r infl inflH y yd ii xx imp rer dep bstar piw mrs
    x_E x_D x_L
    y_E n_E k_E i_E q_E rr_E ret_E efp_E nw_E mc_E inflH_E p_E
    y_D n_D k_D i_D q_D rr_D ret_D efp_D nw_D mc_D inflH_D p_D
    y_L n_L k_L i_L q_L rr_L ret_L efp_L nw_L mc_L inflH_L p_L
    a gg ystar rstar
;

varexo
    sov bank uni
    e_a e_m e_g e_ystar e_rstar
;

parameters
    beta sigma habit sigma_n alpha delta phi_i kappa eps_ces
    sy_E sy_D sy_L sn_E sn_D sn_L si_E si_D si_L
    sx_E sx_D sx_L
    phi_E phi_D phi_L om_m eta_x eta_m c_y i_y g_y x_y m_y
    rho_r phi_pi phi_y phi_b nu_uni
    chi_E chi_D chi_L eps_q omega_nw lev_E lev_D lev_L
    tsov_E tsov_D tsov_L tbank_E tbank_D tbank_L zsov om_nr
    theta_w chiw kap_w eta_w
    rho_a rho_g rho_ystar rho_rstar
;

beta = 0.99; sigma = 0.4; habit = 0.7; sigma_n = 2.0;
alpha = 0.30; delta = 0.025; phi_i = 6.0;
kappa = 0.01; eps_ces = 6.0;
c_y = 0.61; i_y = 0.19; g_y = 0.20; x_y = 0.75; m_y = 0.75;
rho_r = 0.87; phi_pi = 1.70; phi_y = 0.10; phi_b = 0.01;
nu_uni = @{NUUNI};
om_m = 0.30; eta_x = 1.0; eta_m = 1.0;

// Meret- es felhasznalasi sulyok. Ezek indulok: empirikus ujrakalibracio
// kell, amint a t27a/t27d es az IO/Gamma ellenorzes lezarul.
sy_E = 0.18; sy_D = 0.37; sy_L = 0.45;
sn_E = 0.20; sn_D = 0.50; sn_L = 0.30;
si_E = 0.15; si_D = 0.35; si_L = 0.50;

// Exportkitettség. A KKV aggregatum phi~0.218 ugy all elo, hogy az E tipus
// erosen exportalt, a D tipus alig. L az aggregalt nagyvallalati phi.
phi_E = 0.56; phi_D = 0.05; phi_L = 0.365;
sx_E = 0.356; sx_D = 0.065; sx_L = 0.579;

// Penzugyi akcelerator. E es D egyelore azonos KKV-parametereket kapnak;
// a hozzaferesi kulonbseget a tanulmany fo empirikus allitasa hordozza,
// a kamat/felar szintet nem eroltetjuk tul nyers panelatlagbol.
chi_E = 0.06; chi_D = 0.06; chi_L = 0.02;
eps_q = 0.96; omega_nw = 0.95;
lev_E = 1.6; lev_D = 1.6; lev_L = 1.85;

// Premium-transzmisszio. TSCEN=3 a semleges alap: nincs adatbol eros
// E/D/L rangsor kenyszeritve; TSCEN=1/2 erzekenysegi savnak valo.
@#if TSCEN == 1
tsov_E = 0.30; tsov_D = 0.25; tsov_L = 0.10;
tbank_E = 0.65; tbank_D = 0.60; tbank_L = 0.30;
@#elseif TSCEN == 2
tsov_E = 0.10; tsov_D = 0.15; tsov_L = 0.25;
tbank_E = 0.30; tbank_D = 0.35; tbank_L = 0.60;
@#else
tsov_E = 0.175; tsov_D = 0.175; tsov_L = 0.175;
tbank_E = 0.45; tbank_D = 0.45; tbank_L = 0.45;
@#endif

zsov = 0.5;
om_nr = @{OMNR}/100;
theta_w = @{THETAW}/100;
chiw  = 0.75;
eta_w = 4.33;
kap_w = (1-theta_w)*(1-beta*theta_w)/(theta_w*(1+sigma_n*eta_w));
rho_a = 0.90; rho_g = 0.85; rho_ystar = 0.85; rho_rstar = 0.85;

model;

// --- Haztartasok: Ricardianus + nem-Ricardianus
lam = -sigma/(1-habit)*(c_R - habit*c_R(-1));
lam = lam(+1) + (r - infl(+1));
c_N = w + nn;
c   = om_nr*c_N + (1-om_nr)*c_R;
mrs = sigma_n*nn - lam;
piw - chiw*infl(-1) = beta*(piw(+1) - chiw*infl) + kap_w*(mrs - w);
w   = w(-1) + piw - infl;

// --- E tipus: export-orientalt KKV
y_E  = a + alpha*k_E(-1) + (1-alpha)*n_E;
w    = p_E + mc_E + y_E - n_E;
rr_E = p_E + mc_E + y_E - k_E(-1);
ret_E = (1-eps_q)*rr_E + eps_q*q_E - q_E(-1);
ret_E(+1) = r - infl(+1) + efp_E;
efp_E = chi_E*(q_E + k_E - nw_E) + tsov_E*sov + tbank_E*bank;
nw_E  = omega_nw*(nw_E(-1) + lev_E*(ret_E - (r(-1) - infl)));
q_E   = phi_i*(i_E - k_E(-1));
k_E   = (1-delta)*k_E(-1) + delta*i_E;
inflH_E = beta*inflH_E(+1) + kappa*mc_E;
p_E   = p_E(-1) + inflH_E - inflH;
y_E   = (1-phi_E)*(yd - eps_ces*p_E) + phi_E*x_E;

// --- D tipus: hazai orientacioju KKV
y_D  = a + alpha*k_D(-1) + (1-alpha)*n_D;
w    = p_D + mc_D + y_D - n_D;
rr_D = p_D + mc_D + y_D - k_D(-1);
ret_D = (1-eps_q)*rr_D + eps_q*q_D - q_D(-1);
ret_D(+1) = r - infl(+1) + efp_D;
efp_D = chi_D*(q_D + k_D - nw_D) + tsov_D*sov + tbank_D*bank;
nw_D  = omega_nw*(nw_D(-1) + lev_D*(ret_D - (r(-1) - infl)));
q_D   = phi_i*(i_D - k_D(-1));
k_D   = (1-delta)*k_D(-1) + delta*i_D;
inflH_D = beta*inflH_D(+1) + kappa*mc_D;
p_D   = p_D(-1) + inflH_D - inflH;
y_D   = (1-phi_D)*(yd - eps_ces*p_D) + phi_D*x_D;

// --- L tipus: aggregalt nagyvallalat
y_L  = a + alpha*k_L(-1) + (1-alpha)*n_L;
w    = p_L + mc_L + y_L - n_L;
rr_L = p_L + mc_L + y_L - k_L(-1);
ret_L = (1-eps_q)*rr_L + eps_q*q_L - q_L(-1);
ret_L(+1) = r - infl(+1) + efp_L;
efp_L = chi_L*(q_L + k_L - nw_L) + tsov_L*sov + tbank_L*bank;
nw_L  = omega_nw*(nw_L(-1) + lev_L*(ret_L - (r(-1) - infl)));
q_L   = phi_i*(i_L - k_L(-1));
k_L   = (1-delta)*k_L(-1) + delta*i_L;
inflH_L = beta*inflH_L(+1) + kappa*mc_L;
y_L   = (1-phi_L)*(yd - eps_ces*p_L) + phi_L*x_L;

// --- Arak, nyitott gazdasag, aggregalas
0     = sy_E*p_E + sy_D*p_D + sy_L*p_L;
inflH = sy_E*inflH_E + sy_D*inflH_D + sy_L*inflH_L;
infl  = (1-om_m)*inflH + om_m*dep;
rer   = rer(-1) + dep - infl;
yd    = c_y*c + i_y*ii + g_y*gg;
x_E   = ystar + eta_x*rer - eps_ces*p_E;
x_D   = ystar + eta_x*rer - eps_ces*p_D;
x_L   = ystar + eta_x*rer - eps_ces*p_L;
xx    = sx_E*x_E + sx_D*x_D + sx_L*x_L;
imp   = c_y/(c_y+i_y)*c + i_y/(c_y+i_y)*ii - eta_m*rer;
ii    = si_E*i_E + si_D*i_D + si_L*i_L;
nn    = sn_E*n_E + sn_D*n_D + sn_L*n_L;
y     = sy_E*y_E + sy_D*y_D + sy_L*y_L;
bstar = (1/beta)*bstar(-1) + x_y*xx - m_y*imp;

// --- Rezsimfuggo monetaris blokk
// Lebego rezsimben a regi kis SOE-zaras (phi_b) marad. Unio rezsimben
// kulon, erosebb horgony kell, kulonben a terminalis NFA mechanikusan
// nagyra ugrik: SCENARIO=1 mellett phi_b=0.01 -> bstar=-25% GDP.
(1-uni)*(r - rho_r*r(-1) - (1-rho_r)*(phi_pi*infl + phi_y*y) - e_m)
    + uni*(r - rstar - zsov*sov + nu_uni*bstar) = 0;
(1-uni)*(r - rstar - dep(+1) + phi_b*bstar - zsov*sov) + uni*dep = 0;

// --- Exogen folyamatok
a     = rho_a*a(-1) + e_a;
gg    = rho_g*gg(-1) + e_g;
ystar = rho_ystar*ystar(-1) + e_ystar;
rstar = rho_rstar*rstar(-1) + e_rstar;

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
check;

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
