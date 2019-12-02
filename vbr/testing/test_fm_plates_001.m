function TestResult = test_fm_plates_001()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_fm_plates_001()
%
% simply check that the forward model (fm) code runs cleanly
%
% Parameters
% ----------
% none
%
% Output
% ------
% TestResult   True if passed, False otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('    **** Running test_fm_plates_001 ****')

  %  Load Default Settings
  [settings]=init_settings;

  % Computational settings
  settings.dz0=3; % grid cell size [km]
  settings.Z_moho_km = 30; % Moho depth [km]
  settings.Flags.verbosity_level = 0; % quiet!

  % time
  settings.nt= 10; % max number of time steps
  settings.outk = 2 ; % frequency of output (output every outk steps)
  settings.t_max_Myrs=1; % max time to calculate [Myr]

  settings.Flags.T_init='continental'; % 'continental' 'oceanic' or 'adiabatic'

  % build mesh and initial conditions
  settings.Zinfo.zmax=settings.zPlate;
  settings.Zinfo.dz0 = settings.dz0;
  settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
  [Info] = init_values(settings); % calculate initial values

  % set the boundary conditions
  [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);
  [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));

  % Lithosphere temperature evolution
  [Vars,Info]=Thermal_Evolution(Info,settings);

  TestResult=true;
end
