function current_model = update_model_predictions(current_model, settings)
    VBR = struct();
    VBR.in.elastic.methods_list={'anharmonic';};
    VBR.in.viscous.methods_list={'HK2003'};
    VBR.in.anelastic.methods_list={settings.anelastic_method;};

    T_K_pot = current_model.T_K;  % mantle potential temperature

    % plate model
    [SVs, model_settings] = depth_model(T_K_pot, settings.model);
    VBR.in.SV = SVs;
    n1 = settings.model.nz;
    VBR.in.SV.sig_MPa = full_nd(settings.fixed_SVs.sig_MPa, [n1,1]); % differential stress [MPa]
    VBR.in.SV.dg_um = full_nd(settings.fixed_SVs.dg_um, [n1,1]); % grain size [um]
    VBR.in.SV.f = settings.fixed_SVs.f; % frequency [Hz]

    VBR = VBR_spine(VBR);

    current_model.VBR = VBR;
    current_model.Vs = VBR.out.anelastic.(settings.anelastic_method).V;
    current_model.Q = VBR.out.anelastic.(settings.anelastic_method).Q;
end
