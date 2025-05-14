
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
vbr_init

VBR.in.anelastic.methods_list = {'backstress_linear'};
VBR.in.elastic.methods_list = {'anharmonic'};
VBR.in.elastic.anharmonic = Params_Elastic('anharmonic'); 
VBR.in.elastic.anharmonic.temperature_scaling = 'isaak';
VBR.in.elastic.anharmonic.pressure_scaling = 'abramson';

% set state variables
T_1d = linspace(800, 1500, 50) + 273; 
dg_1d = logspace(-6, -1, 30) * 1e6;
sig_dc_1d = logspace(-1, 2, 15);

[T_3d, dg_3d, sig_dc_3d] = meshgrid(T_1d, dg_1d, sig_dc_1d);
sz = size(T_3d);

VBR.in.SV.T_K = T_3d;
VBR.in.SV.dg_um = dg_3d;
VBR.in.SV.sig_dc_MPa = sig_dc_3d;

% following are needed for anharmonic calculation
VBR.in.SV.P_GPa = full_nd(5., sz);
VBR.in.SV.rho = full_nd(3300, sz);
VBR.in.SV.f = [0.001, 0.01]; 

% calculations
VBR = VBR_spine(VBR); 

% plotting
Qinv = VBR.out.anelastic.backstress_linear.Qinv;
Vs = VBR.out.anelastic.backstress_linear.V / 1e3;

i_sigs = [1, 8, numel(sig_dc_1d), ];
i_freq = 1; 

for i_sig_i = 1:numel(i_sigs)
    i_sig = i_sigs(i_sig_i);

    Vplot = squeeze(Vs(:, :, i_sig, i_freq));
    Qinvplot = squeeze(Qinv(:, :, i_sig, i_freq));
    x_ax = T_1d-273;
    y_ax = log10(dg_1d/1e6);
    titlestr = [num2str(VBR.in.SV.f(i_freq)), ' Hz with ', ... 
                '\sigma_{dc} =', num2str(sig_dc_1d(i_sig)), ' MPa'];

    figure()
    subplot(1,2,1)
    contourf(x_ax, y_ax, log10(Qinvplot))
    xlabel('T [C]')
    ylabel('grain size [m]')
    title(['log_{10}(Q^{-1}) at ', titlestr])
    colorbar()

    subplot(1,2,2)
    contourf(x_ax, y_ax, Vplot)
    xlabel('T [C]')
    ylabel('grain size [m]')
    title(['V_s at ', titlestr])
    colorbar()
end 