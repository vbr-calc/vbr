%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CB_013_G_K_inputs.m
%
%  Specify unrelaxed shear and bulk moduli.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% put the VBRc in the path %
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

% specify state variables as usual
VBR = struct();
VBR.in.SV.T_K = linspace(800, 1000, 4);
sz_T = size(VBR.in.SV.T_K);
VBR.in.SV.P_GPa = linspace(2, 3, 4);
VBR.in.SV.rho = 3300 * ones(sz_T);
VBR.in.SV.phi = 0.01 * ones(sz_T);
VBR.in.SV.sig_MPa = 1 * ones(sz_T);
VBR.in.SV.dg_um = 1e4 * ones(sz_T);
VBR.in.SV.f = [0.01, 0.1];

% specify methods as usual
VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};
VBR.in.viscous.methods_list={'HZK2011'};

% also specify the unrelaxed moduli at elevated temperature, pressure.
% you could, instead, load these from a file!
VBR.in.elastic.Gu_TP = linspace(50, 60, 4) * 1e9; % shear modulus
VBR.in.elastic.Ku_TP = VBR.in.elastic.Gu_TP * 1.5; % bulk modulus

% call the VBRc
VBR = VBR_spine(VBR);
