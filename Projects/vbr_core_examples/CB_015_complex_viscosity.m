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
VBR.in.SV.f = logspace(-16,5,nfreqs);

% Define the Thermodynamic State
%nT = 100;
%VBR.in.SV.T_K = transpose(linspace(700+273,1400+273, nT));

nT = 1;
VBR.in.SV.T_K = 1200+273;

VBR.in.SV.dg_um = full_nd(0.01*1e6, nT, 1);
VBR.in.SV.P_GPa = full_nd(2, nT, 1); % pressure [GPa]
VBR.in.SV.rho = full_nd(3300, nT, 1); % density [kg m^-3]
VBR.in.SV.sig_MPa = full_nd(10, nT, 1); % differential stress [MPa]
VBR.in.SV.phi = full_nd(0, nT, 1); % melt fraction
VBR.in.SV.Tsolidus_K=full_nd(1200+273, nT, 1); % solidus

VBR = VBR_spine(VBR);
meth = 'andrade_psp';
eta_a = VBR.out.anelastic.(meth).eta_apparent;
Qinv = VBR.out.anelastic.(meth).Qinv;
eta_star_bar = VBR.out.anelastic.(meth).eta_star_bar;

subplot(3,1,1)
loglog(VBR.in.SV.f, eta_a)

subplot(3,1,2)
loglog(VBR.in.SV.f, Qinv)

subplot(3,1,3)
loglog(VBR.in.SV.f, eta_star_bar)


%contourf(log10(VBR.in.SV.f),VBR.in.SV.T_K,  log10(eta_star_bar))
%contourf(log10(VBR.in.SV.f),VBR.in.SV.T_K,  log10(eta_a))
%colorbar()


