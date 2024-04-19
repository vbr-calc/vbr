function [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2, omega, etao, maxwell_time);



    M1 = 1./J1;
    M2 = 1./J2;
    Mstar = M1 + M2 * i;
    eta_star = zeros(size(M1));
    eta_star_mx = zeros(size(M1));

    for ifreq = 1:numel(omega)

        % TODO: actually store the frequency dependence
        om_i = omega(ifreq);

        % complex visc
        eta_star = -i / om_i * Mstar;

        % normalizing maxwell complex visc
        eta_star_mx = abs(-i / om_i * (i * om_i * etao / (1 + i * om_i * maxwell_time)));


        % apparent viscosity
        eta_app = abs(eta_star);

        % normalized complex viscosity
        eta_star_bar = eta_app ./ eta_star_mx;


    end



end