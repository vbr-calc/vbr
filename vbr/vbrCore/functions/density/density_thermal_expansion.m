function [rho] = density_thermal_expansion(rho, T_K, FracFo, T_ref_K)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [rho] = density_thermal_expansion(rho, T_K, FracFo, T_ref_K)
    %
    % Corrects density for thermal expansion at fixed pressure
    %
    % Parameters
    % ----------
    % rho : scalar or array
    %     density in any units
    % T_K : scalar or array
    %     temperature in Kelvin
    % FracFo : scalar or array
    %     volume fraction of Forsterite
    % T_ref_K : optional scalar
    %     the reference temperature to use, default 273 K
    % Output
    % -------
    % rho : scalar or array
    %     density in same units as input density
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~exist('T_ref_K','var')
        T_ref_K = 273; % reference temperature [K]
    end

    al_int = thermal_expansion_coefficient(T_K, FracFo, T_ref_K);
    rho = rho .* exp(-al_int);

end
