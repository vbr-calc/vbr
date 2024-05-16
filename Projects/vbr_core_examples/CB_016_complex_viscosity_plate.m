%% put VBR in the path %%
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

VBR.in.elastic.methods_list={'anharmonic';};
VBR.in.viscous.methods_list={'HZK2011'};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw';'xfit_premelt'};

VBR.in.GlobalSettings.anelastic.include_complex_viscosity = 1;

%  frequencies to calculate at
nfreqs = 50;
VBR.in.SV.f = logspace(-15,0,nfreqs);

% Define the Thermodynamic State
nT = 100;
z = transpose(linspace(0, 350, nT));

Tpot = 1300;
dTdz_ad = 0.5; % deg/km
zLAB = 235;
Tpot_z = Tpot + dTdz_ad * z;

[zv, zi] = min(abs(z-zLAB));
T_LAB = Tpot_z(zi);
T = T_LAB * z / zLAB;
T(zi+1: end) = Tpot_z(zi+1:end);

plot(T, z)

VBR.in.SV.T_K = T + 273;
VBR.in.SV.dg_um = full_nd(0.01*1e6, nT, 1);
VBR.in.SV.P_GPa = full_nd(2, nT, 1); % pressure [GPa]
VBR.in.SV.rho = full_nd(3300, nT, 1); % density [kg m^-3]
VBR.in.SV.sig_MPa = full_nd(10, nT, 1); % differential stress [MPa]
VBR.in.SV.phi = full_nd(0, nT, 1); % melt fraction
VBR.in.SV.Tsolidus_K=full_nd(1200+273, nT, 1); % solidus

VBR = VBR_spine(VBR);
meth = 'xfit_mxw';
eta_a = VBR.out.anelastic.(meth).eta_apparent;
eta_star_bar = VBR.out.anelastic.(meth).eta_star_bar;

%contourf(log10(VBR.in.SV.f), z,  log10(eta_a))
contourf(log10(VBR.in.SV.f), z,  eta_star_bar)
set(gca(), 'ydir', 'reverse')
colorbar()


