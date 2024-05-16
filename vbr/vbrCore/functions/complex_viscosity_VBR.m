function VBR = complex_viscosity_VBR(VBR, method)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % VBR = complex_viscosity_VBR(VBR, method)
    %
    % Calculate the complex viscosity for a specified anelastic method
    %
    % Parameters
    % ----------
    % VBR
    %   the VBR structure output by VBR_spine() with anelastic results
    % method
    %   the anelastic method to calculate the complex viscosity for. Must
    %   be present in the VBR.out.anelastic structure.
    %
    % Returns
    % -------
    % VBR
    %   the VBR structure, with additional complex viscosity fields in
    %   the VBR.out.anelastic.{method} structure, including the following
    %   fields:
    %       eta_star
    %           complex viscoscity (imaginary number)
    %       eta_app
    %           apparent viscosity
    %       eta_star_bar
    %           normalized complex viscosity (imaginary number)
    %   all the fields will be frequency dependent arrays, with the same size
    %   as the frequency dependent anelastic properties (Q, J1, J2, etc.) with
    %   frequency dependence stored in the final array index.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    omega = 2 * pi * VBR.in.SV.f;

    ane_results = VBR.out.anelastic.(method);
    J1 = ane_results.J1;
    J2 = ane_results.J2;
    mxw_time = ane_results.tau_M;

    mu_method = ane_results.method_settings.mu_method;
    Gu = VBR.out.elastic.(mu_method).Gu;
    etao = mxw_time ./ Gu;
    [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2, omega, etao, mxw_time);

    VBR.out.anelastic.(method).units.eta_star = 'Pa*s';
    VBR.out.anelastic.(method).units.eta_app = 'Pa * s';
    VBR.out.anelastic.(method).units.eta_star_bar = '';
    VBR.out.anelastic.(method).eta_star = eta_star;
    VBR.out.anelastic.(method).eta_apparent = eta_app;
    VBR.out.anelastic.(method).eta_star_bar = eta_star_bar;

end