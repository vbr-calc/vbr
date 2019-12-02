%% ===================================================================== %%
%%                     CB_001_0D_scalar.m
%% ===================================================================== %%
%  Calls VBR using a single thermodynamic state
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
   VBR.in.elastic.methods_list={'anharmonic';'anh_poro';'SLB2005'};
   VBR.in.viscous.methods_list={'HK2003'};
   VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};

%  load anharmonic parameters, adjust Gu_0_ol
%  all paramss in ../4_VBR/VBR_version/params/ will be loaded in call to VBR spine,
%  but you can load them here and adjust any one of them (rather than changing those
%  parameter files).
   VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
   VBR.in.elastic.anharmonic.Gu_0_ol = 75.5; % olivine reference shear modulus [GPa]

%  frequencies to calculate at
   VBR.in.SV.f = logspace(-2.2,-1.3,4);

%% ====================================================
%% Define the Thermodynamic State =====================
%% ====================================================

%  size of the state variable arrays. arrays can be any shape
%  but all arays must be the same shape.
   n1 = 1;

%  state variables (ISV)
   VBR.in.SV.P_GPa = 2 * ones(n1,1); % pressure [GPa]
   VBR.in.SV.T_K = 1473 * ones(n1,1); % temperature [K]
   VBR.in.SV.rho = 3300 * ones(n1,1); % density [kg m^-3]
   VBR.in.SV.sig_MPa = 10 * ones(n1,1); % differential stress [MPa]
   VBR.in.SV.phi = 0.0 * ones(n1,1); % melt fraction
   VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,1); % grain size [um]

%% ====================================================
%% CALL THE VBR CALCULATOR ============================
%% ====================================================

   [VBR] = VBR_spine(VBR) ;

%% ====================================================
%% Display some things ================================
%% ====================================================
   disp(['Unrelaxed Vs = ' num2str(VBR.out.elastic.anharmonic.Vsu/1e3) ' km/s'])
   disp('eBurgers Pseudo Period results:')
   for iFq = 1:numel(VBR.in.SV.f)
       disp(['Vs(' num2str(VBR.in.SV.f(iFq)) ' Hz)=' ...
           num2str(VBR.out.anelastic.eburgers_psp.V(iFq)/1e3) ' km/s'])
   end
