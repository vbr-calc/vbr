function VBR = CB_018_backstress_model_LUT()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VBR = CB_018_backstress_model_LUT();
    %
    % a more thorough exploration of the parameter space for the 
    % linearized backstress model of Hein et al., 2025
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    if ~vbr_tests_are_running()
        i_sigs = [1, 8, numel(sig_dc_1d), ];
        i_freq = 1; 
        contour_plots(VBR, i_sigs, i_freq, T_1d, dg_1d, sig_dc_1d)

        line_plots(VBR, T_1d, dg_1d, sig_dc_1d);
    end
end 

function line_plots(VBR, T_1d, dg_1d, sig_dc_1d)
    Qinv = VBR.out.anelastic.backstress_linear.Qinv;
    Vs = VBR.out.anelastic.backstress_linear.V / 1e3;    
    valid_f = VBR.out.anelastic.backstress_linear.valid_f;

    i_sig = numel(sig_dc_1d);     
    i_freq = 1;
    figure(); 
    dg_ids = 1:5:numel(dg_1d);
    for i_dg = 1:numel(dg_ids)
        dg_val = dg_1d(dg_ids(i_dg)) / 1e6;
        dg_name = [num2str(dg_val), 'm'];
        clr = [i_dg / numel(dg_ids), 0, i_dg / numel(dg_ids)];
        Qplot = squeeze(Qinv(dg_ids(i_dg), :, i_sig, i_freq));
        Vplot = squeeze(Vs(dg_ids(i_dg), :, i_sig, i_freq));
        above_cutoff = squeeze(valid_f(dg_ids(i_dg), :, i_sig, i_freq));
                        
        semilogy(T_1d(above_cutoff==1)-273, Qplot(above_cutoff==1), ... 
                 'displayname', dg_name, 'color', clr, 'linewidth', 2);
        hold on
    end 
    title('fixed sig_{dc}, freq')
    legend('location', 'northwest')
    xlabel('T [C]')
    ylabel('Q^{-1}')

    i_dg = 25;
    figure(); 
    temp_ids = 1:5:numel(T_1d);
    for i_temp = 1:numel(temp_ids)
        T_val = T_1d(temp_ids(i_temp));
        T_name = [num2str(round(T_val - 273)), ' C'];
        clr = [i_temp / numel(temp_ids), 0, 0];
        Qplot = squeeze(Qinv(:, temp_ids(i_temp), i_sig, i_freq));
        Vplot = squeeze(Vs(:, temp_ids(i_temp), i_sig, i_freq));
        above_cutoff = squeeze(valid_f(:, temp_ids(i_temp), i_sig, i_freq));
                        
        loglog(dg_1d(above_cutoff==1)/1e6, Qplot(above_cutoff==1), ... 
                 'displayname', T_name, 'color', clr, 'linewidth', 2);
        hold on
    end 
    title('fixed sig_{dc} , freq')
    legend('location', 'eastoutside')
    xlabel('grain size [m]')
    ylabel('Q^{-1}')



end 

function contour_plots(VBR, i_sigs, i_freq, T_1d, dg_1d, sig_dc_1d)
    Qinv = VBR.out.anelastic.backstress_linear.Qinv;
    Vs = VBR.out.anelastic.backstress_linear.V / 1e3;

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
end 