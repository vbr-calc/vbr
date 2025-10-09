function VBR= sr_visc_calc_BKHK2023(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% VBR= sr_visc_calc_BKHK2023(VBR)
%
% calculates strain rates and viscosities for input state variables.
%
% reference:
% Breithaupt, T., Katz, R. F., Hansen, L. N., & Kumamoto, K. M. (2023). Dislocation theory of steady and transient creep of crystalline solids: Predictions for olivine. Proceedings of the National Academy of Sciences, 120(8), e2203448120.
% https://doi.org/10.1073/pnas.2203448120
%
% Parameters:
% -----------
% VBR   the VBR structure, with state variables in VBR.in.SV. and parameters
%       loaded in VBR.in.viscous.BKHK2023
%
% Ouptut:
% -------
% VBR   the VBR structure with new fields
%       VBR.out.viscous.BKHK2023.sr and .eta.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract state variables and parameters
T_K = VBR.in.SV.T_K ; % [K], temperature
sig = VBR.in.SV.sig_MPa.*1e6; % deviatoric stress [Pa]
d = VBR.in.SV.dg_um/1e6 ; % [m], grain size
params=VBR.in.viscous.BKHK2023;
SV_shape = size(T_K);
n_SVs = numel(T_K);

% pre-allocate
sr_ss = zeros(SV_shape);
eta = zeros(SV_shape);

% looping over state variables - new version
for i_SV = 1:n_SVs
    % calculate temperature and grainsize dependent
    % model-specific parameters
    s_d   = params.beta.*VBR.out.elastic.anharmonic.Gu(i_SV).*params.b./d(i_SV); %Pa, Grain-size dependent threshold stress to operate a Frank-Read Source
    Rp    = params.A_p*exp(-(params.DeltaF)/8.314/T_K(i_SV))*10^-30; %recovery rate pipe, Pa^-5/s
    Rgb   = params.A_gb*exp(-(params.DeltaF)/8.314/T_K(i_SV))*10^-24; %recovery rate grain boundaries, Pa^-4/s
    A_ltp = params.A*exp(-(params.DeltaF)/8.314/T_K(i_SV))*10^-12; %preexponent in plasticity law, m^2s^-1
    s_ref = 8.314*T_K(i_SV)/(params.DeltaF)*params.Sigma; %reference stress in Pa

    % find Taylorstress for which its rate is zero
    % and its acceleration is negative
    s_rho_0 = [sig(i_SV)]; %Initial guess of Taylor stress near which to search for negative-slope zero crossing of Taylor stress rate as a function of Taylor stress
    eqn = @(s_rho) (s_rho + s_d)/s_rho*A_ltp*s_rho^2*sinh((sig(i_SV)-s_rho-s_d)/s_ref) - s_rho/params.s_rho_max*abs(A_ltp*s_rho^2*sinh((sig(i_SV)-s_rho-s_d)/s_ref)) - Rp*s_rho^5 - Rgb*s_rho^3*s_d;
    s_rho_ss = fzero(eqn,s_rho_0); %find zero crossing near s_rho_0

    % calculate steady-state strain rate
    sr = A_ltp*s_rho_ss^2*sinh((sig(i_SV)-s_rho_ss-s_d)/s_ref); %calculate steady-state strain rate
    
    % convert strain rate to shear-strain rate
    sr_ss(i_SV) = sr * sqrt(3); %s^-1, plastic shear-strain rate calculated through LTP law of the backstress model

    % Calculating shear viscosity
    eta(i_SV) = sig(i_SV) ./ sr_ss(i_SV) / sqrt(3); %Pas, steady-state shear viscosity

    if s_d > sig(i_SV) %throw error if grain stress exceeds applied stress and set viscosity and strainrate to NaN
        warning(['Grain-size dependent threshold stress exceeds deviatoric stress, no steady-state solution for deviatoric stress = ' num2str(sig(i_SV)/1e6) ' MPa and d = ' num2str(d(i_SV)*1e6) ' um. Setting steady-state viscosity and strainrate to NaN. Pick a larger deviatoric stress or larger grain size to resolve this issue.'])
        sr_ss(i_SV) = NaN;
        eta(i_SV)   = NaN;
    end

end

%outputs
VBR.out.viscous.BKHK2023.gbnp.sr = sr_ss; %s-1, steady-state strain rate
VBR.out.viscous.BKHK2023.gbnp.eta = eta; %Pas, steady-state viscosity
 VBR.out.viscous.BKHK2023.sr_tot=sr_ss; % total strain rate
 VBR.out.viscous.BKHK2023.eta_total = eta ; % total viscosity
% store total composite strain rate and effective viscosity
units.sr = "1/s";
units.eta = "Pa*s";
units.eta_total = "Pa*s";
units.sr_tot = "1/s";
VBR.out.viscous.BKHK2023.units = units;

end