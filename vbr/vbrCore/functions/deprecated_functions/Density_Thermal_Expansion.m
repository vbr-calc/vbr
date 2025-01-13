function [Rho] = Density_Thermal_Expansion(Rho, T_K, FracFo)
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
    %
    % Output 
    % -------
    % Rho : scalar or array
    %     density in same units as input density
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    print_func_deprecation_warning('Density_Thermal_Expansion', ...
                                   'density_thermal_expansion', 'renamed');
    al_int = thermal_expansion_coefficient(T_K, FracFo);
    Rho = Rho .* exp(-al_int);

end
