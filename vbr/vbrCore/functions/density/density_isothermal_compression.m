function rho = density_isothermal_compression(P_Pa, rho_0 , K_o, dK_dP, P_Pa_ref)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rho = density_isothermal_compression(P_Pa, rho_0, K_o, dK_dP, P_Pa_ref)
    %
    % calculates density under isothermal compression for a bulk modulus with linear pressure dependence.
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