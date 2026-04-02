function [eta_star, eta_star_bar, eta_app] = complex_viscosity_from_method(VBR, anelastic_method, Gu_method);

    ane = VBR.out.anelastic.(anelastic_method);    
    J1 = VBR.out.anelastic.(anelastic_method).J1;
    J2 = VBR.out.anelastic.(anelastic_method).J2;
    tau_M = VBR.out.anelastic.(anelastic_method).tau_M;
    f_Hz = VBR.in.SV.f; 

    Gu = VBR.out.elastic.(Gu_method).Gu; 
    [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2,f_Hz, Gu, tau_M);

end