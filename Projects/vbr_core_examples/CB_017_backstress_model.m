%% put VBR in the path %%
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

VBR.in.viscous.methods_list = {'backstress_linear';};
VBR.in.anelastic.methods_list = {'backstress_linear'};
% set state variables
VBR.in.SV.T_K = linspace(1000, 1400, 5) + 273; 
VBR.in.SV.sig_dc_MPa = [3., 3., 3., 3., 3];
VBR.in.SV.dg_um = [1e3, 1e3, 1e3, 1e3, 1e3]; 

VBR.in.SV.f = logspace(-8, 0, 1000);%[0.001, 0.01]; 

VBR = VBR_spine(VBR); 

% disp(VBR.out.viscous.backstress_linear.eta_total)
% disp(VBR.out.anelastic.backstress_linear.Qinv)

Qinv = VBR.out.anelastic.backstress_linear.Qinv;
disp(size(Qinv))
loglog(VBR.in.SV.f, Qinv(1, 5, :))