function [input_data] = get_data()

    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic';};
    VBR.in.viscous.methods_list={'HK2003'};
    VBR.in.anelastic.methods_list={'eburgers_psp';};

    % state variables: get a range of T values about a mean
    % with std of 25
    T_K = randn(1000,1) * 25 + 1473;
    VBR.in.SV.T_K = T_K; % temperature [K]

    n1 = size(T_K);
    VBR.in.SV.P_GPa = full_nd(2, n1);
    rho = san_carlos_density_from_pressure(VBR.in.SV.P_GPa);
    rho = Density_Thermal_Expansion(rho, VBR.in.SV.T_K, 0.9);
    VBR.in.SV.rho = rho; % density [kg m^-3]
    VBR.in.SV.sig_MPa = full_nd(0.1, n1); % differential stress [MPa]
    VBR.in.SV.phi = full_nd(0, n1); % melt fraction
    VBR.in.SV.dg_um = full_nd(0.01 * 1e6, n1); % grain size [um]
    VBR.in.SV.f = 1 / 50.; % frequency [Hz]


    VBR = VBR_spine(VBR);
    input_data.VBR = VBR;

    % store the mean and std of T_K, and the result
    Vs = VBR.out.anelastic.eburgers_psp.V;
    Q = VBR.out.anelastic.eburgers_psp.Q;
    input_data.Vs_mean = mean(Vs);
    input_data.Vs_std = std(Vs);
    input_data.Q_std = std(Q);
    input_data.Q_mean = mean(Q);
    input_data.T_mean = mean(T_K);
    input_data.T_std = std(T_K);

    fixed_values.P_GPa = VBR.in.SV.P_GPa(1);
    fixed_values.sig_MPa = VBR.in.SV.sig_MPa(1);
    fixed_values.phi = VBR.in.SV.phi(1);
    fixed_values.dg_um = VBR.in.SV.dg_um(1);
    fixed_values.f = VBR.in.SV.f(1);
    fixed_values.rho = VBR.in.SV.rho(1);
    fixed_values.T_K_mean = 1473;
    fixed_values.T_K_std = 25;
    input_data.fixed_values = fixed_values;
end