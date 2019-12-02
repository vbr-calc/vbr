%% ===================================================================== %%
%%                     CB_006_viscosity.m
%% ===================================================================== %%
%  Calculates viscosity
%% ===================================================================== %%
   clear

%% ====================================================
%% Load and set VBR parameters ========================
%% ====================================================

% put VBR in the path
  path_to_top_level_vbr='../../';
  addpath(path_to_top_level_vbr)
  vbr_init

%  write method list (these are the things to calculate)
%  all methods will end up as output like:
%      VBR.out.elastic.anharmonic, VBR.out.anelastic.eBurgers, etc.
   VBR.in.viscous.methods_list={'HK2003','HZK2011'};

%% ====================================================
%% Define the Thermodynamic State =====================
%% ====================================================

%  size of the state variable arrays. arrays can be any shape
%  but all arays must be the same shape.
   phi=logspace(-10,-1,100);
   dg_um=logspace(-4,-1.3,80)*1e6;
   [VBR.in.SV.phi,VBR.in.SV.dg_um] =meshgrid(phi,dg_um) ;
   sz=size(VBR.in.SV.phi);

%  remaining state variables (ISV)
   VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
   VBR.in.SV.T_K = 1473 * ones(sz); % temperature [K]
   VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
   VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]


%% ====================================================
%% CALL THE VBR CALCULATOR ============================
%% ====================================================

   [VBR] = VBR_spine(VBR) ;
