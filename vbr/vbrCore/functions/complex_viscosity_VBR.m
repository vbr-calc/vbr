function VBR = complex_viscosity(VBR, method)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    omega = 2 * pi * VBR.in.SV.f;

    ane_results = VBR.out.anelastic.(method);
    J1 = ane_results.J1;
    J2 = ane_results.J2;
    mxw_time = ane_results.tau_M;

    mu_method = ane_results.method_settings.mu_method;
    Gu = VBR.out.elastic.(mu_method).Gu;
    etao = mxw_time ./ Gu;
    [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2, omega, etao, mxw_time);

    VBR.out.anelastic.(onm).units.eta_star = 'Pa*s';
    VBR.out.anelastic.(onm).units.eta_app = 'Pa * s';
    VBR.out.anelastic.(onm).units.eta_star_bar = '';
    VBR.out.anelastic.(onm).eta_star = eta_star;
    VBR.out.anelastic.(onm).eta_apparent = eta_star;
    VBR.out.anelastic.(onm).eta_star_bar = eta_star_bar;

end