/*
 * kkv_dsge_v02.mod — Euró-belépési szcenárió, determinisztikus szimuláció
 * =====================================================================
 * A v0.1 modellmag (kkv_dsge_v01.mod) változatlan egyenletekkel, DE:
 *  - a sov és bank prémium-változó itt EXOGÉN DETERMINISZTIKUS pálya
 *    (varexo), nem AR(1)-sokk: az euró-szcenárió anticipált, permanens
 *    prémium-csökkenés;
 *  - perfect foresight szimuláció fut stoch_simul helyett.
 *
 * Időzítés (a modell-vázlat 5-szakaszos pályája szerint):
 *   q1      : hiteles bejelentés (az anticipáció innen hat)
 *   q1–q12  : ERM-II / konvergencia — a szuverén prémium fokozatosan
 *             a végső csökkenés 60%-áig süllyed
 *   q13     : euró-belépés — a banki csatorna (swap-bázis) itt nyílik ki
 *   q13–q16 : normalizálódás — mindkét prémium eléri a végső szintet
 *   q17–    : tartós szakasz (új steady state, endval)
 *
 * Szcenáriók (futtatás: run_v02.m, vagy kézzel -DSCENARIO=1|2|3):
 *   1 = alap:       szuverén −200 bp/év primer; banki −45 bp/év,
 *                   transzmisszió a tbank paraméterek szerint (60%)
 *   2 = optimista:  szuverén −250 bp; banki −60 bp és 70%-os transzmisszió
 *   3 = pesszimista: szuverén −150 bp; banki −30 bp és 40%-os transzmisszió
 * A banki transzmisszió szcenárió-eltérése a bank-pálya skálázásába van
 * beolvasztva (a tbank_S/tbank_L paraméter mindhárom futásban a bázis),
 * így nincs kettős számbavétel. Negyedéves abszolút eltérések: 200 bp/év
 * = 0.005/negyedév.
 */

@#ifndef SCENARIO
  @#define SCENARIO = 1
@#endif

// ---------------------------------------------------------------------
// 1. Változók — mint v0.1, de sov/bank exogén
// ---------------------------------------------------------------------

var
    c lam w nn r infl inflH y ii xx imp rer dep bstar
    y_S n_S k_S i_S q_S rr_S ret_S efp_S nw_S mc_S inflH_S p_S
    y_L n_L k_L i_L q_L rr_L ret_L efp_L nw_L mc_L inflH_L p_L
    a gg ystar rstar
;

varexo
    sov         // szuverén prémium pálya (negyedéves eltérés)
    bank        // banki forrásköltség-prémium pálya
    e_a e_m e_g e_ystar e_rstar
;

// ---------------------------------------------------------------------
// 2. Paraméterek — azonosak a v0.1-gyel
// ---------------------------------------------------------------------

parameters
    beta sigma habit sigma_n alpha delta phi_i kappa eps_ces
    sy_S sn_S si_S om_m eta_x eta_m c_y i_y g_y x_y m_y
    rho_r phi_pi phi_y phi_b
    chi_S chi_L eps_q omega_nw lev_S lev_L
    tsov_S tsov_L tbank_S tbank_L
    rho_a rho_g rho_ystar rho_rstar
;

beta = 0.9925; sigma = 1.5; habit = 0.7; sigma_n = 2.0;
alpha = 0.33; delta = 0.025; phi_i = 2.5;
kappa = 0.085; eps_ces = 6.0;
sy_S = 0.55; sn_S = 0.70; si_S = 0.50;
om_m = 0.35; eta_x = 1.0; eta_m = 1.0;
c_y = 0.55; i_y = 0.22; g_y = 0.20; x_y = 0.80; m_y = 0.77;
rho_r = 0.80; phi_pi = 1.50; phi_y = 0.125; phi_b = 0.01;
chi_S = 0.06; chi_L = 0.02; eps_q = 0.96; omega_nw = 0.95;
lev_S = 1.6; lev_L = 1.85;
tsov_S = 0.25; tsov_L = 0.10; tbank_S = 0.60; tbank_L = 0.30;
rho_a = 0.90; rho_g = 0.85; rho_ystar = 0.85; rho_rstar = 0.85;

// ---------------------------------------------------------------------
// 3. Modell — a v0.1 egyenletei (sov/bank AR nélkül)
// ---------------------------------------------------------------------

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
r - rstar = dep(+1) - phi_b*bstar;
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

// ---------------------------------------------------------------------
// 4. Szcenárió-pályák
// ---------------------------------------------------------------------
// Végső szintek (negyedéves eltérés; éves bp / 40000):
//   1 alap:        sov_fin = -0.005     (-200 bp/év), bank_fin = -0.001125
//   2 optimista:   sov_fin = -0.00625   (-250 bp/év), bank_fin = -0.00175
//                  (60 bp primer × 0.7/0.6 transzmisszió-korrekció)
//   3 pesszimista: sov_fin = -0.00375   (-150 bp/év), bank_fin = -0.0005
//                  (30 bp primer × 0.4/0.6 transzmisszió-korrekció)

initval;
sov = 0; bank = 0;
end;

@#if SCENARIO == 1
endval;
sov = -0.005; bank = -0.001125;
end;
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

perfect_foresight_setup(periods=80);
perfect_foresight_solver;
