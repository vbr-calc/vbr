function [Rho,P] = density_adiabatic_compression(Rho_o,Z,P0)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [Rho,P] = density_adiabatic_compression(Rho_o,Z,P0)
    %
    % Adiabatic Compression along a profile following Turcotte and Schubert
    % should be ok for upper mantle, shallower than the 410 km phase change.
    %
    % Parameters
    % ----------
    % Rho_o
    %     reference density in kg/m^3
    % Z
    %     depth in m
    % P0
    %     reference pressure in Pa
    %
    % Output
    % -------
    % [Rho, P]
    %    Rho : adiabatic-corrected density in kg/m^3
    %    P   : pressure profile in Pa
    % see page ~190 in 1st edition, 185 in 2nd edition.                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Rho = Rho_o.*ones(size(Z)); % make sure Rho is an array

    % integrate the reference density profile
    RhoGZ = cumtrapz(Z,Rho*9.8); % [Pa]

    % adiabatic compressibility (values from Turcotte and Schubert)
    Beta_Surf = 8.7*1e-12; % at surface [Pa^-1]
    Beta_CMB = 1.6*1e-12; % at CMB [Pa^-1]
    Beta_wt = 1; % choose a weighting (1 = use surface Beta)
    Beta = Beta_wt*Beta_Surf + (1-Beta_wt) * Beta_CMB; % use this value

    % calculate pressure gradient
    P = -1/Beta * log(1 - Beta * RhoGZ) + P0; % pressure [Pa]

    % calculate Rho(P)
    Rho = Rho.*exp(Beta * (P-P0));
end
