function [Rho,P] = Density_Adiabatic_Compression(Rho_o,Z,P0)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Adiabatic Compression                                             %
    % following Turcotte and Schubert -- should be ok for upper mantle, %
    % shallower than the 410 km phase change.                           %
    % see page ~190 in 1st edition, 185 in 2nd edition.                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Rho = Rho_o.*ones(size(Z)); % make sure Rho is an array

    % adiabatic compressibility (values from Turcotte and Schubert)
    Beta_Surf = 8.7*1e-12; % at surface [Pa^-1]
    Beta_CMB = 1.6*1e-12; % at CMB [Pa^-1]
    Beta_wt = 1; % choose a weighting (1 = use surface Beta)
    Beta = Beta_wt*Beta_Surf + (1-Beta_wt) * Beta_CMB; % use this value

    % integrate the reference density profile
    RhoGZ = cumtrapz(Z,Rho*9.8); % [Pa]

    % calculate pressure gradient
    P = -1/Beta * log(1 - Beta * RhoGZ) + P0; % pressure [Pa]

    % calculate Rho(P)
    Rho = Rho.*exp(Beta * (P-P0));
end
