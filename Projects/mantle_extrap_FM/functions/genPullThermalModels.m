function Box = genPullThermalModels(boxname,ThermalSettings)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Box = genPullThermalModels()
  %
  % generates or loads the Box
  %
  % Parameters
  % ----------
  % boxname   the box to save (or load from )
  % ThermalSettings  structure with some settings, Tpots most important
  %
  % Output
  % ------
  % Box   the structure array of results
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if exist(boxname,'file')
    disp(['Loading thermal models from ',boxname,'. (Delete it to re-run)'])
    load(boxname);
    if ~exist('Box','var')
      disp([boxname,' is missing Box'])
    end
  else
    Box = runSweep(ThermalSettings);
    save(boxname,'Box')
  end

end

function Box = runSweep(ThermalSettings)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Box = runSweep()
  %
  % runs the sweep
  %
  % Parameters
  % ----------
  % ThermalSettings  structure with some settings, Tpots most important
  %
  % Output
  % ------
  % Box   the structure array of results
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Parameter sweep settings
  %  define parameter sweep here. var1name must match EXACTLY a field in
  %  settings structure. var1 must be defined, var2 lines can be
  %  commented/deleted if desired.
  settings.Box.var1range = ThermalSettings.Tpots;
  settings.Box.var1name = 'Tpot';
  settings.Box.var1units =' C';

  % overwrite/set any of the parameters
  % Mesh
  settings.dz0=2; % grid cell size [km]
  settings.Zinfo.zmax = 200; % max z depth to model [km]
  settings.Zinfo.asthenosphere_max_depth = 300; % adiabatic T from zmax to here [km]
  settings.Z_moho_km = 10; % Moho depth [km]

  % Computational settings
  settings.nt= 500; % max number of time steps
  settings.outk = 10 ; % frequency of output (output every outk steps)
  settings.t_max_Myrs=50; % max time to calculate [Myr]
  settings.sstol = 1e-5; % steady state target residual
  settings.Flags.verbosity_level = 0; % shhhhh!

  % initial temperature condition
  settings.Flags.T_init='oceanic'; % 'continental' 'oceanic' or 'adiabatic'

  %  Specify data reduction method for Box storage
  settings.Box.DownSampleMeth='interp';
  settings.Box.DownSampleFactor=1;
  [Box,settings] = BuildBox(settings); %% Build The Box (do this once):

  % Load Default Settings for the forward model runs
  [settings]=init_settings(settings);

  % loop over Parameter sweep settings settings, run forward model for each permuatation
  Work.nBox=settings.Box.nvar1 * settings.Box.nvar2;
  for iBox = 1:Work.nBox

    disp(' ');disp('--------------------------------------------------')
    disp(['Starting run ' num2str(iBox) ' of ' num2str(Work.nBox)])

    % update the current settings for this permutation
    settings.(settings.Box.var1name) = Box(iBox).info.var1val;
    disp([settings.Box.var1name '=' num2str(settings.(settings.Box.var1name))...
         settings.Box.var1units]);
    if isfield(settings.Box,'var2name')
      settings.(settings.Box.var2name) = Box(iBox).info.var2val;
      disp([settings.Box.var2name '=' num2str(settings.(settings.Box.var2name))...
         settings.Box.var2units]);
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

end
