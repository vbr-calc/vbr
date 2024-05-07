function [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2, omega, etao, maxwell_time);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [eta_star, eta_star_bar, eta_app] = complex_viscosity(J1, J2, omega, etao, maxwell_time);
    %
    % calculate the complex viscosity
    %
    % Parameters
    % ----------
    % J1
    %   real part of complex compliance. Assumes frequency dependence is store
    %   in final index.
    % J2
    %   imaginary part of complex compliance. Assumes frequency dependence is store
    %   in final index.
    % omega
    %   angular frequency (2 * pi * f)
    % etao
    %   reference viscosity
    % maxwell_time
    %   the maxwell time
    %
    % Returns
    % -------
    % eta_star
    %   complex viscosity
    % eta_star_bar
    %   normalized complex viscosity
    % eta_app
    %   apparent viscosity
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    M1 = 1./J1;
    M2 = 1./J2;
%    Mstar = M1 + M2 * i;
    eta_star = zeros(size(M1));
    eta_app = zeros(size(M1));
    eta_star_bar = zeros(size(M1));

    sz = size(J1);
    nfreqs = sz(end);
    n_not_freq = prod(sz(1:end-1));

    for ifreq = 1:nfreqs

        om_i = omega(ifreq);

        i_start = (ifreq - 1) * n_not_freq + 1;
        i_end = i_start + n_not_freq - 1;
        % complex visc
        Mstar = M1(i_start:i_end) + M2(i_start:i_end) * i;
        eta_star_i = -i / om_i .* Mstar;

        % normalizing maxwell complex visc
        eta_star_mx_i = abs(-i ./ om_i .* (i * om_i * etao(1:n_not_freq) ./ (1 + i * om_i * maxwell_time(1:n_not_freq))));

        % apparent viscosity
        eta_app_i = abs(eta_star_i);

        % normalized complex viscosity
        eta_star_bar_i = eta_app_i ./ eta_star_mx_i;

        eta_star(i_start:i_end) = eta_star_i;
        eta_app(i_start:i_end) = eta_app_i;
        eta_star_bar(i_start:i_end) = eta_star_bar_i;
    end

end