function [eta_star, eta_star_bar, eta_app] = complex_viscosity_from_method(VBR, anelastic_method, Gu_method);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [eta_star, eta_star_bar, eta_app] = complex_viscosity_from_method(VBR, anelastic_method, Gu_method);
    %
    % calculate the complex viscosity for an existing anelastic output 
    %
    % Parameters
    % ----------
    % VBR
    %   a VBR structure with output anelastic resuls
    % anelastic_method
    %   the anelastic method to calculate complex viscosity for
    % Gu_method
    %   the elastic method to pull the unrelaxed modulus from (default is "anharmonic")
    %
    % Returns
    % -------
    % eta_star
    %   complex viscosity
    % eta_normalized
    %   maxwell-normalized complex viscosity
    % eta_app
    %   apparent viscosity
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ane = VBR.out.anelastic.(anelastic_method);    
    J1 = VBR.out.anelastic.(anelastic_method).J1;
    J2 = VBR.out.anelastic.(anelastic_method).J2;
    tau_M = VBR.out.anelastic.(anelastic_method).tau_M;
    f_Hz = VBR.in.SV.f; 

    Gu = VBR.out.elastic.(Gu_method).Gu; 
    [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2,f_Hz, Gu, tau_M);

end