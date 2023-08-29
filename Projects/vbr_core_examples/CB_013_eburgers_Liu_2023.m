%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_013_eburgers_Liu_2023.m
%
% Uses the water-dependent eBurgers fit of Lau et al., 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% put VBR in the path %%
clear; close all;
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

%% write method list %%
VBR.in.elastic.methods_list={'anharmonic'};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp'};
% VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
VBR.in.anelastic.eburgers_psp.eBurgerFit='liu_water_2023';

tau = logspace(-1, 4, 100);
VBR.in.SV.f = 1./tau;
T_K = [1223, 1273, 1323, 1373];
Ch2o_ppm = [9, 77, 143];

[VBR.in.SV.T_K, VBR.in.SV.Ch2o] = meshgrid(T_K, Ch2o_ppm);
sz = size(VBR.in.SV.T_K);
VBR.in.SV.dg_um = 76 * ones(sz); % close to measured values in experiments
VBR.in.SV.P_GPa = 3 * ones(sz); % fixed experimetnal condition
VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction


%% Call VBR_spine again %%
[VBR] = VBR_spine(VBR) ;


figure

for i_H2o = 1:numel(Ch2o_ppm)

  i_plot_M = i_H2o * 2 - 1;
  i_plot_Q = i_plot_M + 1;
  for i_T = 1:numel(T_K)


     Qinv = VBR.out.anelastic.eburgers_psp.Qinv(i_H2o, i_T, :);
     M = VBR.out.anelastic.eburgers_psp.M(i_H2o, i_T, :);

     subplot(3,2, i_plot_M)
     hold all
     semilogx(tau, M/1e9)
     xlabel('period [s]')
     ylabel('Shear Modulus [GPa]')

     subplot(3,2, i_plot_Q)
     hold all
     loglog(tau, Qinv)
     xlabel('period [s]')
     ylabel('Q^{=-1}')


  end
end
