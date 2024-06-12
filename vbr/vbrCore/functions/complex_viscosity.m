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

    % allocate output arrays
    full_size = size(J1);
    eta_star = zeros(full_size);
    eta_app = zeros(full_size);
    eta_star_bar = zeros(full_size);

    sz = size(J1);
    nfreqs = sz(end);
    n_not_freq = prod(sz(1:end-1));

    % allocate intermediate arrays for frequency loop
    eta_star_mx_i = zeros(n_not_freq,1);
    eta_star_i = zeros(n_not_freq,1);
    eta_star_bar_i = zeros(n_not_freq,1);
    eta_app_i = zeros(n_not_freq,1);

    for ifreq = 1:nfreqs

        om_i = omega(ifreq); % the current angular frequency

        % linear index range for this frequency
        i_start = (ifreq - 1) * n_not_freq + 1;
        i_end = i_start + n_not_freq - 1;

        % get complex modulus for this frequency range
        M1 = 1./J1(i_start:i_end);
        M2 = 1./J2(i_start:i_end);
        Mstar = M1 + M2 * i;

        % full complex viscosity
        eta_star_i(:) = -i / om_i .* Mstar;

        % normalizing maxwell complex visc
        denom = 1.0 + i * om_i * maxwell_time(1:n_not_freq);
        eta_star_mx_i(:) = abs(etao(1:n_not_freq) ./ denom);

        % apparent viscosity
        eta_app_i(:) = abs(eta_star_i);

        % normalized complex viscosity
        eta_star_bar_i(:) = eta_app_i ./ eta_star_mx_i;

        % store in output arrays
        eta_star(i_start:i_end) = eta_star_i;
        eta_app(i_start:i_end) = eta_app_i;
        eta_star_bar(i_start:i_end) = eta_star_bar_i;
    end

end