addpath('bayes_1d_funcs')
path_to_top_level_vbr=getenv('vbrdir');
addpath(path_to_top_level_vbr)
vbr_init

settings.z_min_km = 0.;
settings.z_plate_km = 150.;
settings.z_max_km = 250.;
settings.nz = 50;
settings.dTdz_ad = 0.3; % deg/km
settings.phi_0 = 0.01;
settings.T_sol_K_surf = 1200 + 273;
settings.T_sol_dTdz = settings.dTdz_ad*2.5;
settings.P0_GPa = 0.1; % pressure at z_min
settings.z_crust_km = 30;
T_K_pot = 1300+273;

[SVs, settings] = depth_model(T_K_pot, settings);

figure()
subplot(1,4,1)
plot(SVs.T_K, settings.z_km,'k', 'linewidth',2)
hold on
plot(SVs.Tsolidus_K, settings.z_km,'--r', 'linewidth',2)
set(gca(), 'ydir', 'reverse')
set(gca(), 'xlabel', 'T [K]')
set(gca(), 'ylabel', 'depth [km]')

subplot(1,4,2)
plot(SVs.phi, settings.z_km,'k', 'linewidth',2)
set(gca(), 'ydir', 'reverse')
set(gca(), 'xlabel', '\phi')

subplot(1,4,3)
plot(SVs.P_GPa, settings.z_km,'k', 'linewidth',2)
set(gca(), 'ydir', 'reverse')
%set(gca(), 'xlabel', 'P [GPa]')

subplot(1,4,4)
plot(SVs.rho/1e3, settings.z_km,'k', 'linewidth',2)
set(gca(), 'ydir', 'reverse')
%set(gca(), 'xlabel', '\rho [g/m3]')
