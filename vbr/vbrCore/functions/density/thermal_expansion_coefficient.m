function al_int = thermal_expansion_coefficient(T_K, FracFo)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculates the thermal expansion coefficent at a given temperature and
    % volume fraction of forsterite following Xu et al., 2004
    %
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
    %
    % References
    % ----------
    % Xu, Yousheng, et al."Thermal diffusivity and conductivity of olivine,
    % wadsleyite and ringwoodite to 20 GPa and 1373 K." Physics of the Earth
    % and Planetary Interiors 143 (2004): 321-336.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % mean values for coefficients: a*(1) is forsterite, a*(2) is fayalite.
    a0(1) = mean([0.0663 0.1201 0.1172 0.3034 0.2635 0.3407 0.2854]*1e-4);
    a1(1) =mean([0.3898 0.2882 0.0649 0.0722 1.4036 0.8674 1.0080]*1e-8);
    a2(1) =mean(-[0.0918 0.2696 0.1929 0.5381 0.0 0.7545 0.3842]);
    a0(2) = mean([0.1050 0.0819 0.1526 0.2386]*1e-4);
    a1(2) =mean([0.0602 0.1629 -0.1217 1.1530]*1e-8);
    a2(2) =mean(-[0.4958 0.0694 0.4594 0.0518]);
    a_1 = (FracFo*a0(1)+(1-FracFo)*a0(2));
    a_2 = (FracFo*a1(1) + (1-FracFo)*a1(2));
    a_3 = (FracFo*a2(1) + (1-FracFo)*a2(2));

    % integrate alpha(T) analytically, calculate new density
    Tref = 273; % reference temperature [K]
    al_int = a_1.*(T_K-Tref)+a_2./2*(T_K.^2-Tref^2) - a_3.*(1./T_K - 1/Tref);
end
