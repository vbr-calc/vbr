%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct a 3D lookup table (LUT) of results for asthenospheric-ish
% conditions for a single anelastic method.
%
% Initially set up to use andrade_psp for speed.
%
% Suggested Explorations:
% * how does frequency dependence change at lab-scale grain sizes?
% * how does Q and Vs dependence on melt fraction change when the
%   poroelastic effect is not used?
% * try swapping out another method (xfit_mxw will be fast, eburgers_psp
%   will be slower, xfit_premelt will error initially)
% * try adjusting the viscosity that is used by the andrade_psp method:
%   set VBR.in.anelastic.andrade_psp.useJF10visc = 0 and adding at
%   viscous method -- this will make andrade_psp pull the steady state
%   diffusion creep values from one a different flow law.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all;
% 1. initialize the VBRc
path_to_top_level_vbr=getenv('vbrdir');
addpath(path_to_top_level_vbr)
% use the VBRc a lot? add the above to
% startup.m for matlab (https://www.mathworks.com/help/matlab/ref/startup.html)
% or ~/.octaverc for octave (https://docs.octave.org/interpreter/Startup-Files.html)
vbr_init


%  build 3D grid of temeprature, grain size, melt fraction
T_K_1d = linspace(1300,1700,45);
grain_size_1d = logspace(-6, -1, 55) * 1e6; % um
melt_1d = logspace(-10, log10(0.03), 50);
[T_K, grain, melt] = meshgrid(T_K_1d, grain_size_1d, melt_1d);

% set state variable arrays
VBR.in.SV.dg_um = grain;
VBR.in.SV.phi = melt;
VBR.in.SV.T_K = T_K;

sz = size(melt);
VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]

rho = san_carlos_density_from_pressure(VBR.in.SV.P_GPa);
rho = Density_Thermal_Expansion(rho, VBR.in.SV.T_K, 0.9);
VBR.in.SV.rho = rho; % density [kg m^-3]
VBR.in.SV.sig_MPa = 0.1 * ones(sz); % differential stress [MPa]

%  frequencies to calculate at
VBR.in.SV.f = logspace(-4,1,20); % [Hz]

% set anharmonic methods
VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};

% NOTE: if you want to set your own anharmonic moduli:
% VBR.in.elastic.Gu_TP = ...
% VBR.in.elastic.Ku_TP = ...
% see Josh's talk on Wednesday (using perple_x)
% or blog post about coupling to abers & hacker: https://chrishavlin.github.io/post/vbrc_moduli/
%   (both of these also set density)

method = 'andrade_psp';
VBR.in.anelastic.methods_list={method;};

% 3. call the VBRc
VBR = VBR_spine(VBR);

disp(fieldnames(VBR.out.anelastic.(method)))

V = VBR.out.anelastic.(method).V;
Q = VBR.out.anelastic.(method).Q;
disp(size(V))  % note frequency dependence!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iPhi = numel(melt_1d);
[mindiff, iGrain] = min(abs(grain_size_1d-0.01*1e6));
[mindiff, ifreq] = min(abs(VBR.in.SV.f-0.01));
[mindiff, iTemp] = min(abs(T_K_1d-1400));
vs_lims = [3.4, 4.6];
Q_lims = [.01, 2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot frequency dependence
% fixed grain size, melt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()

for iTemp = 1:numel(T_K_1d)
    Qinv = VBR.out.anelastic.(method).Qinv(iGrain,iTemp,iPhi,:);
    subplot(1,2,1)
    hold on
    loglog(VBR.in.SV.f, Qinv,'color', [iTemp/numel(T_K_1d), 0, 0,])
    ylabel('Q^{-1}')

    subplot(1,2,2)
    hold on
    Vplot = VBR.out.anelastic.(method).V(iGrain,iTemp,iPhi,:)/1e3;
    semilogx(VBR.in.SV.f, Vplot,'color', [iTemp/numel(T_K_1d), 0, 0,])
    ylabel('V_s [km/s]')
end
xlabel('f [Hz]')
title('frequency depedence')

log_melt = log10(melt_1d);
log_g = log10(grain_size_1d/1e6); % m

%%%%%%%%%%%%%%%%%%%%
% plot Vs
%%%%%%%%%%%%%%%%%%%%

figure()
% fix temperature
subplot(1,3,1)
V2d = V(:, iTemp,:, ifreq) / 1e3; % km/s
contourf(log_melt, log_g, squeeze(V2d))
title(["V_s at T = ", num2str(T_K_1d(iTemp)), ' [K]'])
ylabel('log10(grain size [m])')
xlabel('log10(phi)')
colorbar()
caxis(vs_lims) % clim in MATLAB < R2022a, octave < ?

subplot(1,3,2)
V2d = V(iGrain,:,:, ifreq) / 1e3; % km/s
contourf(log_melt, T_K_1d, squeeze(V2d))
title(["V_s at grain size = ", num2str(grain_size_1d(iGrain)/1e6), ' m'])
xlabel('log10(phi)')
ylabel('T [K]')
colorbar()
caxis(vs_lims) % clim in MATLAB < R2022a, octave < ?

subplot(1,3,3)
V2d = V(:,:,iPhi, ifreq) / 1e3; % km/s
contourf(T_K_1d, log_g,squeeze(V2d))
title(["V_s at phi = ", num2str(melt_1d(iPhi))])
ylabel('log10(grain size [m])')
xlabel('T [K]')

colorbar()
caxis(vs_lims) % clim in MATLAB < R2022a, octave < ?

%%%%%%%%%%%%%%%%%%%%%
%% plot Q
%%%%%%%%%%%%%%%%%%%%%

figure()
% fix temperature
subplot(1,3,1)
Q2d = log10(Q(:,iTemp,:, ifreq));
contourf(log_melt, log_g, squeeze(Q2d))
title(["log10(Q) at T = ", num2str(T_K_1d(iTemp)), ' [K]'])
ylabel('log10(grain size [m])')
xlabel('log10(phi)')

colorbar()
caxis(Q_lims) % clim in MATLAB < R2022a, octave < ?

subplot(1,3,2)
Q2d = log10(Q(iGrain,:,:, ifreq)); % km/s
contourf(log_melt, T_K_1d, squeeze(Q2d))
title(["log10(Q) at grain size = ", num2str(grain_size_1d(iGrain)/1e6), ' m'])
xlabel('log10(phi)')
ylabel('T [K]')

colorbar()
caxis(Q_lims) % clim in MATLAB < R2022a, octave < ?

subplot(1,3,3)
Q2d = log10(Q(:,:,iPhi, ifreq) );
contourf(T_K_1d, log_g,squeeze(Q2d))
title(["log10(Q) at phi = ", num2str(melt_1d(iPhi))])
ylabel('log10(grain size [m])')
xlabel('T [K]')

colorbar()
caxis(Q_lims) % clim in MATLAB < R2022a, octave < ?

