function dTdz_s = adiabatic_gradient(T_K, rho, FracFo)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculates the adiabatic gradient (dT/dz at constant
    % entropy) given temperature and density for the upper
    % mantle (g = 9.8 m/s^2)
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
    % dTdz_s
    %     adiabatic gradient in K/m
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Cp = SpecificHeat(T_K, FracFo);
    al = thermal_expansion_coefficient(T_K, FracFo);
    dTdz_s = al .* 9.8 .* T_K ./ Cp;
end
