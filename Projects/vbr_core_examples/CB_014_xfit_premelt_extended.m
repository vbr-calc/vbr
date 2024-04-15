%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_004_xfit_premelt.m
%
%  Calls VBR using xfit_premelt method from:
%    Hatsuki Yamauchi and Yasuko Takei, JGR 2024, "Effect of Melt on Polycrystal
%    Anelasticity", https://doi.org/10.1029/2023JB027738
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% put VBR in the path %%
  clear; close all
  path_to_top_level_vbr='../../';
  addpath(path_to_top_level_vbr)
  vbr_init

%% write method list %%
  VBR.in.elastic.methods_list={'anharmonic'};
  VBR.in.anelastic.methods_list={'xfit_premelt'};
  VBR.in.anelastic.xfit_premelt.include_direct_melt_effect = 1;

  % load anharmonic parameters, adjust Gu_0_ol and derivatives to match YT2016
  VBR.in.elastic.anharmonic.Gu_0_ol=72.45; %[GPa]
  VBR.in.elastic.anharmonic.dG_dT = -10.94*1e6; % Pa/C    (equivalent ot Pa/K)
  VBR.in.elastic.anharmonic.dG_dP = 1.987; % GPa / GPa


  %% Define the Thermodynamic State %%
  VBR.in.SV.T_K=1200:5:1500;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;
  sz=size(VBR.in.SV.T_K); % temperature [K]
  VBR.in.SV.P_GPa = full_nd(2.5, sz); % pressure [GPa]

  Tn_cases = [.96, .98, 1.0, 1.1, 1.1, 1.1, 1.1];
  phi_cases = [0., 0., 0., 0.1, 1, 2, 4]*0.01;

  % remaining state variables (ISV)
  VBR.in.SV.dg_um=full_nd(.004*1e6, sz); % grain size [um]
  VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = full_nd(1, sz); % differential stress [MPa]
  VBR.in.SV.f = 1; % 1 Hz


  f1=figure();
  nTn = numel(Tn_cases);
  VBR_results = struct();

  for iTn = 1:nTn
        VBRi = VBR;
        VBRi.in.SV.phi = full_nd(phi_cases(iTn), sz);
        VBRi.in.SV.Tsolidus_K = VBR.in.SV.T_K / Tn_cases(iTn);
        [VBRi] = VBR_spine(VBRi) ;

        results.Q = VBRi.out.anelastic.xfit_premelt.Q;
        VBR_results(iTn) = results;

        dname = [num2str(Tn_cases(iTn)), ', ', num2str(phi_cases(iTn))];
        figure(f1)
        if iTn > 1
            hold all
        end
        plot(VBR.in.SV.T_K - 273, results.Q, 'displayname', dname, 'linewidth', 1.5)
        legend('Location','eastoutside','title', '(Tn, phi)')
        xlabel('Temperature [C]', 'fontsize', 12)
        ylabel('Qs', 'fontsize', 12)
        ylim([0, 200])


  end

