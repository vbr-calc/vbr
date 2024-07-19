function current_model = update_model_predictions(current_model, settings)
    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic';};
    VBR.in.viscous.methods_list={'HK2003'};
    VBR.in.anelastic.methods_list={settings.anelastic_method;};

    T_K = current_model.T_K;
    VBR.in.SV.T_K = T_K; % temperature [K]

    n1 = size(T_K);
    VBR.in.SV.P_GPa = full_nd(settings.fixed_SVs.P_GPa, n1);
    rho = san_carlos_density_from_pressure(VBR.in.SV.P_GPa);
    rho = Density_Thermal_Expansion(rho, VBR.in.SV.T_K, 0.9);
    VBR.in.SV.rho = rho; % density [kg m^-3]
    VBR.in.SV.sig_MPa = full_nd(settings.fixed_SVs.sig_MPa, n1); % differential stress [MPa]
    VBR.in.SV.phi = full_nd(settings.fixed_SVs.phi, n1); % melt fraction
    VBR.in.SV.dg_um = full_nd(settings.fixed_SVs.dg_um, n1); % grain size [um]
    VBR.in.SV.f = settings.fixed_SVs.f; % frequency [Hz]

    VBR = VBR_spine(VBR);

    current_model.VBR = VBR;
    current_model.Vs = VBR.out.anelastic.(settings.anelastic_method).V;
    current_model.Q = VBR.out.anelastic.(settings.anelastic_method).Q;
end
