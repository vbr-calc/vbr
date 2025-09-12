function VBR= sr_visc_calc_BKHK2023(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% VBR= sr_visc_calc_BKHK2023(VBR)
% DH 9/8/2025, work in progress
%
% calculates strain rates and viscosities for input state variables.
%
% reference:
% Breithaupt, T., Katz, R. F., Hansen, L. N., & Kumamoto, K. M. (2023). Dislocation theory of steady and transient creep of crystalline solids: Predictions for olivine. Proceedings of the National Academy of Sciences, 120(8), e2203448120.
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
    s_d = params.beta.*params.mu.*params.b./d(i_SV); %Pa, Grain-size dependent threshold stress to operate a Frank-Read Source
    if s_d > sig(i_SV)
        error(['Grain-size dependent threshold stress exceeds deviatoric stress, no steady-state solution for deviatoric stress = ' num2str(sig(i_SV)/1e6) ' MPa and d = ' num2str(d(i_SV)*1e6) ' um, pick a larger deviatoric stress or larger grain size.'])
    end
    Rp    = params.A_p*exp(-(params.DeltaF)/8.314/T_K(i_SV))*10^-30; %recovery rate pipe, Pa^-5/s
    Rgb   = params.A_gb*exp(-(params.DeltaF)/8.314/T_K(i_SV))*10^-24; %recovery rate grain boundaries, Pa^-4/s
    A_ltp = params.A*exp(-(params.DeltaF)/8.314/T_K(i_SV))*10^-12; %preexponent in plasticity law, m^2s^-1
    s_ref = 8.314*T_K(i_SV)/(params.DeltaF)*params.Sigma; %reference stress in Pa

    % Calculate Taylor stresses and their time-derivatives for
    % for feasible ranges of backstress and strain
    % rate at the specified stress
    s_rho_rate = -1; %pre-allocate 
    ind_wl = 1; %index of while-loop
    % figure; hold on
    while s_rho_rate < 1e6 || isnan(s_rho_rate) % s_rho_rate is zero at steady state and negative when backstress exceeds the steady-state backstress. This loop iteratively decreases the backstress from near the applied stress to find the steady-state backstress.  In addition, s_rho_rate == NaN results when s_rho == 0, which may occur when s_d is large (i.e., at v. fine grain sizes).
        s_rho = (sig(i_SV) - ind_wl*params.Resolution); %Pa, backstress
        if (sig(i_SV)-s_rho-s_d) < 0 % can happen when s_d is larger than ind_wl*resolution
            ind_wl = ind_wl + 1; %add to counter
            ind_wl_1stsuccess = ind_wl;
            continue %move to next iteration
        end
        if ind_wl == 1
            ind_wl_1stsuccess = ind_wl;
        end
        sr    = A_ltp*s_rho^2*sinh((sig(i_SV)-s_rho-s_d)/s_ref); %s^-1, strain rate for given combination of deviatoric stress and backstress
        s_rho_rate = params.M*((s_rho+s_d)/s_rho*sr-(s_rho/params.sigb_max)*abs(sr)-Rp.*s_rho.^5-Rgb.*s_rho.^3.*s_d); %Pa s^-1, Taylor stress rate
        % scatter(s_rho, s_rho_rate)
        if ind_wl == ind_wl_1stsuccess && s_rho_rate > 0
            warning(['Backstress rate exceeds 0 for first successful iteration for T = ' num2str(T_K(i_SV)) 'K, sig = ' num2str(sig(i_SV)/1e6) ' MPa, and d = ' num2str(d(i_SV)*1e6) ' um, please set VBR.in.viscous.BKHK2023.Resolution to a finer resolution to improve the steady-state viscosity estimate.'])
        end
        ind_wl = ind_wl + 1;
    end
    
    % steady-state strainrate
    % using steady-state Taylor stress
    sr_ss(i_SV) = sr; %s^-1, plastic strain rate calculated through LTP law of the backstress model

    % Calculating viscosity
    eta(i_SV) = sig(i_SV)./sr_ss(i_SV); %Pas, steady-state viscosity
end

%outputs 
VBR.out.viscous.BKHK2023.gbnp.sr = sr_ss; %s-1, steady-state strain rate
VBR.out.viscous.BKHK2023.gbnp.eta = eta; %Pas, steady-state viscosity

% store total composite strain rate and effective viscosity
units.sr = "1/s";
units.eta = "Pa*s";
VBR.out.viscous.BKHK2023.units = units;

end