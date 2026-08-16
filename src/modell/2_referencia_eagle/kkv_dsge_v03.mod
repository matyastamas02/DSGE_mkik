/*
 * kkv_dsge_v03.mod — Euró-szcenárió + UIP-országprémium csatorna
 * =====================================================================
 * Változások a v0.2-höz képest:
 *
 * 1. ÚJ CSATORNA: a szuverén prémium az UIP-egyenletbe (országprémium)
 *    is belép zsov súllyal. Dekompozíció (nincs kettős számbavétel):
 *      - UIP-csatorna  = a kockázatmentes hozamgörbe konvergenciája
 *        (háztartási, állami, teljes gazdasági finanszírozás);
 *      - EFP-csatorna  = a VÁLLALATI HITELFELÁR szűkülése a kockázat-
 *        mentes fölött (tsov/tbank súlyok, mint eddig).
 *    zsov = 0.5: a szuverén spread-csökkenés fele gyűrűzik át a belföldi
 *    kockázatmentes finanszírozási feltételekbe — érzékenységi paraméter.
 *
 * 2. KALIBRÁCIÓ-FRISSÍTÉS a Békési–Kaszab–Szentmihályi (MNB WP 2017/7)
 *    appendix-tábláiból (HU oszlop):
 *      beta 0.99 | sigma 0.4 (1/IES=0.4) | habit 0.7 | 1/Frisch 2
 *      alpha 0.30 | delta 0.025 | beruh. kiig. 6.0 | kötvény-kiig. 0.01
 *      Calvo-ár (T/NT) 0.92 -> kappa ~0.01 | Taylor: 0.87 / 1.70 / 0.10
 *      nagy arányok: C/Y 0.61, I/Y 0.19, G/Y 0.20, X/Y 0.75, M/Y 0.75
 *    A szektorális pénzügyi blokk (chi, lev) az Opten-panelből, változatlan.
 *
 * Szcenáriók és időzítés: mint a v0.2-ben (run_v03.m, -DSCENARIO=1|2|3).
 */

@#ifndef SCENARIO
  @#define SCENARIO = 1
@#endif

// -DCHANNEL=1: csak a szuverén csatorna fut (bank-pálya nulla);
// -DCHANNEL=2: csak a banki csatorna. Alapértelmezés (0): mindkettő.
// A modell lineáris, ezért a két csatorna-futás összege kiadja a teljes
// pályát — ez a csatorna-dekompozíciós ábra (s11) alapja. Csak az
// alap szcenárióval (SCENARIO=1) értelmezett.
@#ifndef CHANNEL
  @#define CHANNEL = 0
@#endif

var
    c lam w nn r infl inflH y ii xx imp rer dep bstar
    y_S n_S k_S i_S q_S rr_S ret_S efp_S nw_S mc_S inflH_S p_S
    y_L n_L k_L i_L q_L rr_L ret_L efp_L nw_L mc_L inflH_L p_L
    a gg ystar rstar
;

varexo
    sov bank
    e_a e_m e_g e_ystar e_rstar
;

parameters
    beta sigma habit sigma_n alpha delta phi_i kappa eps_ces
    sy_S sn_S si_S om_m eta_x eta_m c_y i_y g_y x_y m_y
    rho_r phi_pi phi_y phi_b
    chi_S chi_L eps_q omega_nw lev_S lev_L
    tsov_S tsov_L tbank_S tbank_L zsov
    rho_a rho_g rho_ystar rho_rstar
;

// --- MNB WP 2017/7 appendix (HU oszlop) ---
beta = 0.99; sigma = 0.4; habit = 0.7; sigma_n = 2.0;
alpha = 0.30; delta = 0.025; phi_i = 6.0;
kappa = 0.01;               // Calvo 0.92 -> (1-xi)(1-beta*xi)/xi
eps_ces = 6.0;              // markup-tabla: elaszticitas 6.0
c_y = 0.61; i_y = 0.19; g_y = 0.20; x_y = 0.75; m_y = 0.75;
rho_r = 0.87; phi_pi = 1.70; phi_y = 0.10; phi_b = 0.01;
om_m = 0.30; eta_x = 1.0; eta_m = 1.0;

// --- szektorsúlyok, pénzügyi blokk: Opten-panel (változatlan) ---
sy_S = 0.55; sn_S = 0.70; si_S = 0.50;
chi_S = 0.06; chi_L = 0.02; eps_q = 0.96; omega_nw = 0.95;
lev_S = 1.6; lev_L = 1.85;
tsov_S = 0.25; tsov_L = 0.10; tbank_S = 0.60; tbank_L = 0.30;
zsov = 0.5;                 // szuverén -> UIP-országprémium átgyűrűzés

rho_a = 0.90; rho_g = 0.85; rho_ystar = 0.85; rho_rstar = 0.85;

model(linear);

lam = -sigma/(1-habit)*(c - habit*c(-1));
lam = lam(+1) + (r - infl(+1));
w   = sigma_n*nn - lam;

y_S  = a + alpha*k_S(-1) + (1-alpha)*n_S;
w    = p_S + mc_S + y_S - n_S;
rr_S = p_S + mc_S + y_S - k_S(-1);
ret_S = (1-eps_q)*rr_S + eps_q*q_S - q_S(-1);
ret_S(+1) = r - infl(+1) + efp_S;
efp_S = chi_S*(q_S + k_S - nw_S) + tsov_S*sov + tbank_S*bank;
nw_S  = omega_nw*(nw_S(-1) + lev_S*(ret_S - (r(-1) - infl)));
q_S   = phi_i*(i_S - k_S(-1));
k_S   = (1-delta)*k_S(-1) + delta*i_S;
inflH_S = beta*inflH_S(+1) + kappa*mc_S;
p_S   = p_S(-1) + inflH_S - inflH;
y_S   = y - eps_ces*p_S;

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
0     = sy_S*p_S + (1-sy_S)*p_L;
y_L   = y - eps_ces*p_L;

inflH = sy_S*inflH_S + (1-sy_S)*inflH_L;
infl  = (1-om_m)*inflH + om_m*dep;
rer   = rer(-1) + dep - infl;
// UIP országprémiummal: a szuverén konvergencia a teljes belföldi
// kockázatmentes finanszírozási feltételt javítja (zsov súllyal)
r - rstar = dep(+1) - phi_b*bstar + zsov*sov;
xx    = ystar + eta_x*rer;
imp   = c_y/(c_y+i_y)*c + i_y/(c_y+i_y)*ii - eta_m*rer;
ii    = si_S*i_S + (1-si_S)*i_L;
nn    = sn_S*n_S + (1-sn_S)*n_L;
y     = c_y*c + i_y*ii + g_y*gg + x_y*xx - m_y*imp;
bstar = (1/beta)*bstar(-1) + x_y*xx - m_y*imp;

r = rho_r*r(-1) + (1-rho_r)*(phi_pi*infl + phi_y*y) + e_m;

a     = rho_a*a(-1) + e_a;
gg    = rho_g*gg(-1) + e_g;
ystar = rho_ystar*ystar(-1) + e_ystar;
rstar = rho_rstar*rstar(-1) + e_rstar;

end;

initval;
sov = 0; bank = 0;
end;

@#if SCENARIO == 1
  @#if CHANNEL == 1
endval;
sov = -0.005; bank = 0;
end;
  @#elseif CHANNEL == 2
endval;
sov = 0; bank = -0.001125;
end;
  @#else
endval;
sov = -0.005; bank = -0.001125;
end;
  @#endif
@#elseif SCENARIO == 2
endval;
sov = -0.00625; bank = -0.00175;
end;
@#else
endval;
sov = -0.00375; bank = -0.0005;
end;
@#endif

steady;

@#if SCENARIO == 1
shocks;
@#if CHANNEL != 2
var sov;
periods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
values -0.00025 -0.0005 -0.00075 -0.001 -0.00125 -0.0015 -0.00175 -0.002
       -0.00225 -0.0025 -0.00275 -0.003 -0.0035 -0.004 -0.0045 -0.005;
@#endif
@#if CHANNEL != 1
var bank;
periods 1:12 13 14 15 16;
values 0 -0.00028125 -0.0005625 -0.00084375 -0.001125;
@#endif
end;
@#elseif SCENARIO == 2
shocks;
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
