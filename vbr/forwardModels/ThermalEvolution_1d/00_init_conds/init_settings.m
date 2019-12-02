function [settings]=init_settings(settings_in)

%  all the flags with default settings
%  Flags
%    .PropType  specifies dependencies of Kc, rho and Cp.
%               'con'     Constant rho, Cp and Kc
%               'P_dep'   pressure dependent rho, constant Cp and Kc
%               'T_dep'   temperature dependent rho, Cp and Kc
%               'PT_dep'  temperature and pressure dependent rho, Cp and Kc

   settings.Flags.PropType='PT_dep';  % for density, thermal exp., conductivity
   settings.Flags.VbzFlag = 'constant';
   settings.Flags.T_init='continental'; % 'continental' 'oceanic' or 'adiabatic'
   settings.Flags.ModelDomain='asth_lith'; % 'asth_lith' or 'lith'
   settings.Flags.verbosity_level=1; % verbosity level, 1 or 0. Runs silent if 0.

% thermal
  settings.Tpot = 1325; % potential temperature of lithosphere
  settings.Tpot_excess = 0; % excess potential temperature of asthenosphere
  settings.DBL_m = 10e3; % [m] mechancial boundary layer thickness at base of lith
                         % controls how quickly Tpot_asth approached Tpot_lith

  if exist('settings_in','var')
    if isstruct(settings_in)&&isfield(settings_in,'Flags')&&isfield(settings_in.Flags,'T_init')
      if strcmp(settings_in.Flags.T_init,'oceanic')
          settings.age0 = 5; % [Myrs] only used if T_init is oceanic.
      end
    end
  end

  settings.T_init_diff_steps = 0; % initial diffusion steps for smoothing init condition
  settings.cfl = 0.4;  % advection stability criteria

% uniform state variables
  settings.phi_min = 0.0 ; % 1e-4; % the minimum retained melt fraction
  % use 0.0 when adding melt later using DRIVE_AddMelt.m
  settings.grain0 = 0.01; % grain size [m]

% crustal thickness
  settings.Z_moho_km = 20; % Moho depth [km]
  settings.Moho_thickness_km = 6; % lengthscale for the gradient from crust to mantle [km]

% density settings
  settings.rhos = 3300; % solid density [kg/m3]
  settings.rhos_crust = 2800; % crustal density [km/m3]

% composition (uniform values for now)
  settings.kd_H2O = 1e-2; % partition coefficent for H2O, kd = Cs / Cf
  settings.kd_CO2 = 1e-4; % partition coefficent for CO2, kd = Cs / Cf
  settings.Cs0_H2O = 0; % initial water concentration [PPM]
  settings.Cs0_CO2 = 0; % initial water concentration [PPM]
  settings.F = 0.0; % the thermodynamic melt fraction to calculate fluid wt % at

% thermal properties at reference state
  settings.Kc_olv = 4.17; % thermal conductivity [W/m/K], from Xu et al (see MaterialProperties.m)
  settings.Kc_crust = 2; % thermal conductivity [W/m/K]
  settings.Cp_olv = 1100; % heat capacity [J/kg/K]
  settings.Cp_crust = 800; % heat capacity [J/kg/K]
  settings.L = 500 * 1e3; % latent heat of crystallization [J/kg]

% other physics
  settings.g = 9.8; % gravtational acceleration [m/s2]
  settings.P0 = 1e5; % pressure at surface [Pa]

% adiabat (could be calculated self consistently...)
  settings.dTdz_ad = 0.5*1e-3; % adiabatic gradient [K/m] % should calculate self-consistently

% used for other things....
  settings.sig_MPa = 0.1; % [MPa] %0.1 MPa reasonable for asthenosphere focused study

%  Mesh settings
   settings.Zinfo.dz = .5; % node spacing in [km]
   settings.Zinfo.zmin =0; % min depth for model domain [km]
   settings.Zinfo.zmax = 100; % max z depth [km]
   settings.zPlate = settings.Zinfo.zmax;

   if strcmp(settings.Flags.ModelDomain,'lith')
     settings.Zinfo.asthenosphere_max_depth = 300;
   end
%  Computational settings
   settings.nt = 20; % max time steps (switch to a max time)
   settings.outk = 5; % output frequency
   settings.sstol = 1e-16; % steady state target residual
   settings.dt_max = 10;  % max step for advection [Myrs] if advective velo is 0

   settings.Vbg = 0; % [cm/yr]
%    settings.Q_LAB = -40 / 1e3; % LAB heat flux [ W / m2]

%  copy over settings_in (will overwrite any of the above)
   if exist('settings_in','var')
      ovwr_set = fieldnames(settings_in);
      for is = 1:length(ovwr_set)
          if isstruct(settings_in.(ovwr_set{is}))
             ovwr_set2 = fieldnames(settings_in.(ovwr_set{is}));
             for iss = 1:length(ovwr_set2)
                 settings.(ovwr_set{is}).(ovwr_set2{iss}) ...
                     = settings_in.(ovwr_set{is}).(ovwr_set2{iss});
             end
          else
              settings.(ovwr_set{is}) = settings_in.(ovwr_set{is});
          end
      end
    end

end
