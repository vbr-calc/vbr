function [Rho] = density_thermal_expansion(Rho, T_K, FracFo, T_K_ref)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Corrects density for thermal expansion at fixed pressure
    %
    % Parameters
    % ----------
    % Rho : scalar or array
    %     density in any units
    % T_K : scalar or array
    %     temperature in Kelvin
    % FracFo : scalar or array
    %     volume fraction of Forsterite
    % T_ref_K : optional scalar
    %     the reference temperature to use
    % Output
    % -------
    % Rho : scalar or array
    %     density in same units as input density
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~exist('T_ref_K')
        T_ref_K = 273; % reference temperature [K]
    end

    al_int = thermal_expansion_coefficient(T_K, FracFo, T_K_ref);
    Rho = Rho .* exp(-al_int);

end
