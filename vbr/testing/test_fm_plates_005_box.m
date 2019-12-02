function TestResult = test_fm_plates_005_box()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % TestResult = test_fm_plates_005_box()
  %
  % code check for box storage
  %
  % Parameters
  % ----------
  % none
  %
  % Output
  % ------
  % TestResult   True if passed, False otherwise.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('    **** Running test_fm_plates_005_box ****')
  TestResult=true;
  % Parameter sweep settings
  %  define parameter sweep here. var1name must match EXACTLY a field in
  %  settings structure. var1 must be defined, var2 lines can be
  %  commented/deleted if desired.
  settings.Box.var1range = [1200,1400];
  settings.Box.var1name = 'Tpot';
  settings.Box.var1units =' C';

  settings.Box.var2range = [0,150,300];
  settings.Box.var2name = 'Cs0_H2O';
  settings.Box.var2units =' PPM';

  % overwrite/set any of the parameters
  % Mesh
  settings.dz0=2; % grid cell size [km]
  settings.Zinfo.zmax = 200; % max z depth to model [km]
  settings.Zinfo.asthenosphere_max_depth = 300; % adiabatic T from zmax to here [km]
  settings.Z_moho_km = 10; % Moho depth [km]
  settings.Flags.verbosity_level = 0; % quiet!
  % Computational settings
  settings.nt= 6; % max number of time steps
  settings.outk = 2 ; % frequency of output (output every outk steps)
  settings.t_max_Myrs=50; % max time to calculate [Myr]
  settings.sstol = 1e-5; % steady state target residual

  % initial temperature condition
  settings.Flags.T_init='oceanic'; % 'continental' 'oceanic' or 'adiabatic'

  %  Specify data reduction method for Box storage
  settings.Box.DownSampleMeth='interp';
  settings.Box.DownSampleFactor=4;
  [Box,settings] = BuildBox(settings); %% Build The Box (do this once):

  % Load Default Settings for the forward model runs
  [settings]=init_settings(settings);

  % loop over Parameter sweep settings settings, run forward model for each permuatation
  Work.nBox=settings.Box.nvar1 * settings.Box.nvar2;
  for iBox = 1:Work.nBox
    % update the current settings for this permutation
    settings.(settings.Box.var1name) = Box(iBox).info.var1val;
    if isfield(settings.Box,'var2name')
      settings.(settings.Box.var2name) = Box(iBox).info.var2val;
    end

    % build the initial conditions for this permutation
    settings.Zinfo.zmax=settings.zPlate;
    settings.Zinfo.dz0 = settings.dz0;
    settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
    [Info] = init_values(settings); % calculate initial values

    % initalize  the boundary conditions
    [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);
    [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));

    % Lithosphere temperature evolution (the actual calculation)
    [Vars,Info]=Thermal_Evolution(Info,settings);

    % Add on adiabatic asthenosphere
    [Vars,Info]=postproc_append_astheno(Vars,Info,settings);

    % Put the run in the Box.
    [Box] = Put_in_Box(Box,Vars,Info,settings,iBox);
  end
