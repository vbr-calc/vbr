%% put VBR in the path %%
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

VBR.in.viscous.methods_list = {'backstress_linear';};
VBR.in.anelastic.methods_list = {'backstress_linear'};
% set state variables

VBR.in.SV.T_K = [1300, 1400, 1500] + +273;
sz = size(VBR.in.SV.T_K);
VBR.in.SV.sig_dc_MPa = full_nd(3., sz);
VBR.in.SV.dg_um = full_nd(0.001 * 1e6, sz);
VBR.in.SV.P_GPa = full_nd(5., sz);

VBR.in.SV.f = logspace(-8, 0, 500);%[0.001, 0.01]; 

VBR = VBR_spine(VBR); 

% disp(VBR.out.viscous.backstress_linear.eta_total)
% disp(VBR.out.anelastic.backstress_linear.Qinv)

Qinv = VBR.out.anelastic.backstress_linear.Qinv;
disp(size(Qinv))

for itemp = 1:sz(2)    
    loglog(VBR.in.SV.f, squeeze(Qinv(1, itemp, :)), 'displayname', num2str(VBR.in.SV.T_K(itemp)))
    hold all
end 
ylim([1e-4, 1e2])
