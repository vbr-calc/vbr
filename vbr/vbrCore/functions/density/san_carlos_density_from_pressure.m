function rho = san_carlos_density_from_pressure(P_GPa)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho = san_carlos_density_from_pressure(P_GPa)
    %
    % calculates density of olivine at given pressure values
    % using an interpolation of Abramson et al 1997 (at Fo90)
    %
    %
    % Parameters
    % ----------
    % P_GPa: scalar or array
    %     the pressure(s) of interest in GPa
    %
    % Output
    % -------
    % rho : scalar
    %     density in kg/m3
    %
    % References
    % ----------
    % E. H. Abramson, J. M. Brown, L. J. Slutsky, J. Zaug, 1997,
    % The elastic constants of San Carlos olivine to 17 GPa,
    % JGR,  https://doi.org/10.1029/97JB00682
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    P_i = [0., 1.9, 3.1, 3.7, 5.2, 7.2, 9.0, 10.3, 12.0, 17.0];
    rho_i = [3.355, 3.404, 3.434, 3.449, 3.485, 3.531, 3.570, 3.598, 3.633, 3.731];


    rho = interp1(P_i,rho_i,P_GPa);
    rho = rho * 1e3;
end
