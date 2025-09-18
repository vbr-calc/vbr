function Kc = ThermalConductivity(Kc_o, T, P)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Kc = ThermalConductivity(Kc_o, T, P)
    %
    % calculates thermal conductivity using Xu et al 2004.
    %
    % Parameters
    % ----------
    %  Kc_o   scalar or array of reference values for thermal conductivity
    %         in units of [W / m / K]
    %  T      temperature (scalar or array) [K]
    %  P      pressure (scalar or array) [Pa]
    %
    % Returns
    % -------
    % Kc      thermal conductivity in [W / m / K]
    %
    % References
    % ----------
    % Xu, Y., T. J. Shankland, S. Linhardt, D. C. Rubie, F. Langenhorst, and K.
    %   Klasinski (2004), Thermal diffusivity and conductivity of olivine,
    %   wadsleyite and ringwoodite to 20 GPa and 1373 K, Phys Earth Planet In,
    %   143-144, 321?336, doi:10.1016/j.pepi.2004.03.005.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % method 1, P-dependent
    Kc = Kc_o.*(298./T).^(0.5) .* (1 + 0.032 * P /1e9);

end
