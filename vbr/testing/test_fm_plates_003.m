  function TestResult = test_fm_plates_003()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_fm_plates_003()
%
% compares steady state solution to analytical solution (linear geotherm)
%
% Parameters
% ----------
% none
%
% Output
% ------
% TestResult   True if passed, False otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('    **** Running test_fm_plates_003 ****')
  disp('         (takes <1 minute)')
  TestResult=true;
  %  Load Default Settings
  [settings]=init_settings;

  % Computational settings
  settings.dz0=10; % grid cell size [km]
  settings.Flags.verbosity_level = 0; % quiet!
  settings.Z_moho_km = -100; % set negative so that whole domain is astheno
  settings.Flags.PropType='con'; % constant rho, Cp, k --> constant diffusivity
  settings.dTdz_ad=0; % do it in potential temp, set adiabat grad to 0
  settings.T_init_diff_steps=0;

  % time
  settings.nt= 5000; % max number of time steps
  settings.outk = 50 ; % frequency of output (output every outk steps)
  settings.t_max_Myrs=1500; % max time to calculate [Myr]

  settings.Flags.T_init='oceanic'; % 'continental' 'oceanic' or 'adiabatic'
  settings.age0 = 1e-16; % [Myrs] only used if T_init is oceanic.

  % build mesh and initial conditions
  settings.Zinfo.zmax=200;
  settings.Zinfo.dz0 = settings.dz0;
  settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
  [Info] = init_values(settings); % calculate initial values

  % set the boundary conditions
  [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);
  [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));

  % Lithosphere temperature evolution
  [Vars,Info]=Thermal_Evolution(Info,settings);

  % compare to steady state plate model w no radiogenic heat production
  FinalT=Vars.T(:,end);
  T_ss=Info.init.T(end) * Info.z / Info.z(end);
  rel_err=abs(T_ss-FinalT)./T_ss;
  max_err=max(rel_err(:));

  % check if it passes
  max_err_tol=1e-5;
  if max_err_tol>max_err_tol
    disp('     steady state plate solution incorrect!!!!!')
    TestResult=false;
  end
end
