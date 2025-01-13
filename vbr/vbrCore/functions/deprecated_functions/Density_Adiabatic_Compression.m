function [Rho,P] = Density_Adiabatic_Compression(Rho_o,Z,P0)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Adiabatic Compression along a profile following Turcotte and Schubert
    % should be ok for upper mantle, shallower than the 410 km phase change.
    %
    % Parameters
    % ----------
    % Rho_o
    %     reference density in kg/m^3
    % Z
    %     depth in m
    % P0
    %     reference pressure in Pa
    %
    % Output 
    % -------
    % [Rho, P]
    %    Rho : adiabatic-corrected density in kg/m^3
    %    P   : pressure profile in Pa
    % see page ~190 in 1st edition, 185 in 2nd edition.                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    print_func_deprecation_warning('Density_Adiabatic_Compression', ...
                                   'density_adiabatic_compression', ...
                                   'renamed');
    [Rho, P] = density_adiabatic_compression(Rho_o, Z, P0);
end
