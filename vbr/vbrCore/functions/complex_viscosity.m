function [eta_star, eta_normalized, eta_app] = complex_viscosity(J1, J2, f_Hz, Gu, maxwell_time);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [eta_star, eta_normalized, eta_app] = complex_viscosity(J1, J2, f_Hz, Gu, maxwell_time);
    %
    % calculate the complex viscosity
    %
    % Parameters
    % ----------
    % J1
    %   real part of complex compliance. Assumes frequency dependence is store
    %   in final index. Can be matrix of any size, but frequency index assumed to be
    %   the final dimension. 
    % J2
    %   imaginary part of complex compliance. Assumes frequency dependence is store
    %   in final index. Same sie as J1
    % f_Hz
    %   frequency (NOT angular frequency). If a matrix, should be the same 
    %   size as the final dimension of J1 and J2.
    % Gu
    %   unrelaxed modulus. If a matrix, should be the same size as the non-frequency 
    %   indices of J1, J2 (i.e., if J1 is of size (10, 10, 5), Gu should be size (10, 10))
    % maxwell_time
    %   the maxwell time. If a matrix, should be the same size as the non-frequency 
    %   indices of J1, J2 (i.e., if J1 is of size (10, 10, 5), maxwell_time should be size (10, 10))
    %
    % Returns
    % -------
    % eta_star
    %   complex viscosity
    % eta_normalized
    %   maxwell-normalized complex viscosity
    % eta_app
    %   apparent viscosity
    %
    %
    % Introduced in VBRc version: 2.2.0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    etao = maxwell_time .* Gu;    
    omega = 2 * pi * f_Hz; 
    % allocate output arrays
    full_size = size(J1);
    eta_star = zeros(full_size);
    eta_app = zeros(full_size);
    eta_star_bar = zeros(full_size);
    eta_maxwell = zeros(full_size);

    sz = size(J1);
    nfreqs = sz(end);
    n_not_freq = prod(sz(1:end-1));

    % allocate intermediate arrays for frequency loop
    eta_star_mx_i = zeros(n_not_freq,1);
    eta_star_i = zeros(n_not_freq,1);
    eta_app_i = zeros(n_not_freq,1);
    

    for ifreq = 1:nfreqs

        om_i = omega(ifreq); % the current angular frequency

        % linear index range for this frequency
        i_start = (ifreq - 1) * n_not_freq + 1;
        i_end = i_start + n_not_freq - 1;
        
        % get complex modulus for this frequency range
        J = J1(i_start:i_end) - J2(i_start:i_end) * i;
        Mstar = 1./J;        

        % full complex viscosity
        eta_star_i = -i .* Mstar ./ om_i ;

        % complex maxwell viscosity
        M_maxwell = i * om_i * etao ./(1.+i*om_i * maxwell_time);
        eta_maxwell(i_start:i_end) = -i * M_maxwell ./ om_i;
        
        % store in output arrays
        eta_star(i_start:i_end) = eta_star_i;
        eta_app(i_start:i_end) = abs(eta_star_i);
    end

    % maxwell-normalized apparent viscosity
    eta_normalized = abs(eta_star) ./ abs(eta_maxwell);

end