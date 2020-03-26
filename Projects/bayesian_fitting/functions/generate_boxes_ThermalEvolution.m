function generate_boxes_ThermalEvolution(BoxName,Trange_C,zPlateRange_km)
% generate suite of solutions for thermal evolution of lithosphere. Plate model
% with variable thermal conductivity -- run to steady state. This is time
% consuming, only do this step when sweeping through Tpot and zPlate
% (other variables do not impact thermal evolution).

% Parameter sweep
%  define parameter sweep here. var1name must match EXACTLY a field in
%  settings structure. var1 must be defined, var2 lines can be
%  commented/deleted if desired.
settings.Box.var1range = Trange_C;
settings.Box.var1name = 'Tpot';
settings.Box.var1units =' C';

settings.Box.var2range = zPlateRange_km;
settings.Box.var2name = 'zPlate';
settings.Box.var2units =' km';

%  Overwrite any of the deafault settings (from init_settings) as desired
% Mesh
settings.dz0=3; % grid cell size [km]
settings.Zinfo.asthenosphere_max_depth = 350; % adiabatic T from zmax to here [km]
settings.Z_moho_km = 30; % Moho depth [km]

% Computational settings
settings.nt= 5000; % max number of time steps
settings.outk = settings.nt ; % frequency of output (output every outk steps)
% number of timesteps to save = outn = nt/outk
settings.t_max_Myrs=500; % max time to calculate [Myr]
settings.sstol = 1e-5; % steady state target residual
settings.Flags.T_init='continental'; % 'continental' 'oceanic' or 'adiabatic'

Box=drive_svfm_plate(settings);
save(BoxName,'Box')

end

function Box=drive_svfm_plate(settings)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script builds the initial settings to call Thermal_Evolution. Commonly
% changed parameters are set here, less frequently changed parameters are
% in initialize_settings. Anything set here can overwrite anything set in
% settings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   disp(' ');disp('--------------------------------------------------')

% %% --------------------------------------------------------------------- %%
% %%                       Problem Setup
% %% --------------------------------------------------------------------- %%

% settings common to all runs
%  Load Default Settings

   [settings]=init_settings(settings);

%  Specify data reduction method for Box storage
   settings.Box.DownSampleMeth='interp';
   settings.Box.DownSampleFactor=1;
   [Box,settings] = BuildBox(settings); %% Build The Box (do this once):

% %% --------------------------------------------------------------------- %%
% %% --------------  thermodynamic state forward model ------------------- %%
% %% --------------------------------------------------------------------- %%

   Work.nBox=settings.Box.nvar1 * settings.Box.nvar2;
   for iBox = 1:Work.nBox

      disp(' ');disp('--------------------------------------------------')
      disp(['Starting run ' num2str(iBox) ' of ' num2str(Work.nBox)])

% %% ---------------------------- %
% %%    set the Box parameters    %
% %% ---------------------------- %

      settings.(settings.Box.var1name) = Box(iBox).info.var1val;
      disp([settings.Box.var1name '=' num2str(settings.(settings.Box.var1name))...
           settings.Box.var1units]);
      if isfield(settings.Box,'var2name')
        settings.(settings.Box.var2name) = Box(iBox).info.var2val;
        disp([settings.Box.var2name '=' num2str(settings.(settings.Box.var2name))...
           settings.Box.var2units]);
      end

% %% ------------------------------ %%
% %%    Initialize Thermal Solve    %%
% %% ------------------------------ %%

%      build mesh and initial conditions
       settings.Zinfo.zmax=settings.zPlate;
       settings.Zinfo.dz0 = settings.dz0;
       settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
       [Info] = init_values(settings); % calculate initial values

%      set the boundary conditions
       [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);
       [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));

% %% ----------------------------- %%
% %%     Forward model solution    %%
% %% ----------------------------- %%

%     Lithosphere temperature evolution
       [Vars,Info]=Thermal_Evolution(Info,settings);

%     Add on adiabatic asthenosphere
       [Vars,Info]=postproc_append_astheno(Vars,Info,settings);

% %% ------------------- %%
% %%     Data Storage    %%
% %% ------------------- %%

%      Put the run in the Box.
       [Box] = Put_in_Box(Box,Vars,Info,settings,iBox);

%      update the user
       disp(['Completed Run ' num2str(iBox) ' of ' num2str(Work.nBox)])
   end

disp(' ');disp('--------------------------------------------------');disp(' ')

end
