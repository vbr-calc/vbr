function dTdP_s = adiabatic_coefficient(T_K, rho, FracFo)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dTdP_s = adiabatic_coefficient(T_K, rho, FracFo)
    %
    % calculates the adiabatic coefficient (dT/dP at constant
    % entropy) given temperature and density
    %
    % Parameters
    % ----------
    % T_K
    %     temperature in K
    % rho
    %     density in kg/m^3
    % FracFo
    %     volume fraction forsterite
    %
    % Output
    % -------
    % dTdP_s
    %     adiabatic coefficient in K/Pa
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Cp = SpecificHeat(T_K, FracFo);
    al = thermal_expansion_coefficient(T_K, FracFo);
    dTdP_s = al .* T_K ./ (rho .* Cp);
end
