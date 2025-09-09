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
d = VBR.in.SV.dg_um ; % [um], grain size

params=VBR.in.viscous.BKHK2023;

% looping over state variables
for ii = 1:length(T_K)
    for jj = 1: length(sig)
        for kk = 1:length(d)
            
            %calculate temperature and grainsize dependent
            %model-specific parameters
            s_d = params.beta.*params.mu.*params.b./(d(kk)*1e-6); %effectively a FR source, Pa
            Rp = params.A_p*exp(-(params.DeltaF)/8.314/T_K(ii))*10^-30; %recovery rate pipe, Pa^-5/s
            Rgb = params.A_gb*exp(-(params.DeltaF)/8.314/T_K(ii))*10^-24; %recovery rate grain boundaries, Pa^-4/s
            A_ltp = params.A*exp(-(params.DeltaF)/8.314/T_K(ii))*10^-12; %preexponent in plasticity law, m^2s^-1
            s_ref = 8.314*T_K(ii)/(params.DeltaF)*params.Sigma; %reference stress in Pa

            % Calculate Taylor stresses and their time-derivatives for
            % for feasible ranges of backstress and strain
            % rate at the specified stress
            s_rho_range = 0.01*sig(jj):0.01*sig(jj):sig(jj);%Pa, Taylor-stress range to explore, from 1% of deviatoric stress to the deviatoric stress in increments 1% of the deviatoric stress
            sr_range    = logspace(-20,0,21e3); %s^-1, strain rates to explore
            
            % pre-allocate
            stresses = zeros(1,length(s_rho_range));
            s_rho_rates = zeros(1,length(s_rho_range));
            s_rho_at_sig = zeros(1,length(sr_range));
            s_rho_rate_at_sig = zeros(1,length(sr_range));

            % loop over strain rates and Taylor stresses
            % and solve for stress and Taylor-stress rate
            for i = 1:length(sr_range)
                for j = 1:length(s_rho_range)
                    stresses(j)    = s_ref.*asinh(sr_range(i)./(A_ltp.*s_rho_range(j).^2))+s_rho_range(j)+s_d; %Pa, deviatoric stress for given Taylor stress
                    s_rho_rates(j) = params.M.*((s_rho_range(j)+s_d)./s_rho_range(j).*sr_range(i)-Rp.*s_rho_range(j).^5-Rgb.*s_rho_range(j).^3.*s_d); %Pa s^-1, Taylor stress rate
                end

                % find the index for which
                % stresses(j) matches the
                % target deviatoric stress
                [difference,ind] = min(abs(stresses-sig(jj)));
                if difference>0.1e6 %toss the result if calculated stress strays too far from target deviatoric stress
                    s_rho_at_sig(i) = NaN;
                    s_rho_rate_at_sig(i) = NaN;
                else
                    s_rho_at_sig(i) = s_rho_range(ind);      % make array with feasible Taylor stresses for target deviatoric stress
                    s_rho_rate_at_sig(i) = s_rho_rates(ind); % make array with associated Taylor-stress rates
                end
            end

            % sort s_rho_rate_at_sig based on order of ascending s_rho_at_sig
            [s_rho_at_sig,sortedInd] = sort(s_rho_at_sig); 
            s_rho_rate_at_sig = s_rho_rate_at_sig(sortedInd);

            % remove NaNs
            s_rho_at_sig(isnan(s_rho_at_sig)) = [];
            s_rho_rate_at_sig(isnan(s_rho_rate_at_sig)) = [];

            % remove non-unique solutions of s_rho_at_sig
            [~, indunique] = unique(s_rho_at_sig);
            s_rho_at_sig = s_rho_at_sig(indunique);
            s_rho_rate_at_sig = s_rho_rate_at_sig(indunique);

            % Find Taylor stress at which the
            % Taylor stress rate is stable at zero 
            % (i.e., the steady-state Taylor stress)
            [~,ind_max] = max(s_rho_rate_at_sig); %find peak in Taylor stress rate
            xq = s_rho_at_sig(ind_max):0.001e6:sig(jj); %Pa, query range for interpolation at 0.01 MPa intervals (The interval of Taylor stresses for which Taylor-stress acceleration is negative)
            vq = interp1(s_rho_at_sig,s_rho_rate_at_sig,xq,"makima"); %Pa s^-1, interpolated Taylor-stress rates
            [~, ind_ss] = min(abs(vq)); %index of Taylor stress at which Taylor-stress rate is closest to 0 (i.e., index of steady-state Taylor stress)
            s_rho_ss = xq(ind_ss); %Pa, Steady-state Taylor stress

            % Calculate steady-state strainrate
            % using steady-state Taylor stress
            sr_ss = A_ltp.*s_rho_ss.^2.*sinh((sig(jj)-s_rho_ss-s_d)./s_ref); %s^-1, plastic strain rate calculated through LTP law of the backstress model

            %outputs (needs fixing to be compatible with arbitrary SV meshgrids)
            VBR.out.viscous.BKHK2023.gbnp.sr(ii,jj,kk) = sr_ss; %s-1, steady-state strain rate
            VBR.out.viscous.BKHK2023.gbnp.eta(ii,jj,kk) = sig(jj)./sr_ss; %Pas, steady-state viscosity
        end
    end
end

% store total composite strain rate and effective viscosity
units.sr = "1/s";
units.eta = "Pa*s";
VBR.out.viscous.BKHK2023.units = units;

end