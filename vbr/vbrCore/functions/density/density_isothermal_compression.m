function rho = density_isothermal_compression(P_Pa, rho_0 , K_o, dK_dP, P_Pa_ref)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho = density_isothermal_compression(P_Pa, rho_0, K_o, dK_dP, P_Pa_ref)
    %
    % calculates density under isothermal compression for a bulk modulus with linear pressure dependence.
    %
    % Parameters
    % ----------
    % P_Pa: scalar or array
    %   pressure in Pa. if array must be same size as other arrays
    % rho_0: scalar or array
    %   reference density in any units. if array must be same size as other arrays
    % K_o: scalar or array
    %   reference bulk modulus in Pa. if array must be same size as other arrays
    % dK_dP: scalar
    %   anharmonic pressure derivative of bulk modulus in Pa/Pa
    % P_Pa_ref: scalar
    %   reference pressure in Pa
    %
    % Returns
    % -------
    % rho: scalar or array
    %   the density at supplied pressure, same units as input rho_0.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % for compressibility beta, bulk modulus K
    %
    % solve:
    %   beta = 1 / rho * drho/dP (compressibilty definition, see https://en.wikipedia.org/wiki/Compressibility)
    %   beta = 1 / K
    %   K = Ko + dK/dP (P - P_ref)
    %
    % where rho is density.
    %
    % separation of variables, integrate both sides to get:
    ln_fac = 1 + 1./K_o * dK_dP .* (P_Pa - P_Pa_ref);
    rho = rho_0 .* exp(1./dK_dP .* log(ln_fac));

end