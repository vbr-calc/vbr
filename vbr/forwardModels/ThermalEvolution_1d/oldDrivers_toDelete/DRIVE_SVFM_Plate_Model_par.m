%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   disp(' ');disp('--------------------------------------------------')
   clear; close all
   addpath ./00_init_conds ./02_box_functions ./01_functions

%% --------------------------------------------------------------------- %%
%%                       Problem Setup
%% --------------------------------------------------------------------- %%

%% settings common to all runs
%  Save settings
   Work.cwd=pwd; cd ~; Work.hmdir=pwd; cd(Work.cwd);
   Work.savedir0=[Work.hmdir '/Dropbox/0_VBR_WORK/0_y17_Projects/Boxes']; % the closet to store the box in
   %Work.savebase = '2017-07-20-SNA_forGIA'; % boxes end up named ['Box_' savebase]
   Work.savebase = '2017-08-15-TNA_forGIA'; % boxes end up named ['Box_' savebase]

%  Load Default Settings
   [settings]=init_settings;

%  Overwrite any of the default settings as desired
%    Mesh
     settings.dz0=3; % grid cell size [km]
     settings.Zinfo.asthenosphere_max_depth = 350; % adiabatic T from zmax to here [km]
     settings.Z_moho_km = 20; % Moho depth [km]

%    Computational settings
%    parallel settings
     par_settings.procs_to_use = 1; % number of processors to use
     par_settings.future_jobs = 'no'; % will leave parallel pool open if 'yes'

%    time
     settings.nt= 10000; % max time steps
     settings.outk =2000; % output frequency
     settings.t_max_Myrs=1000; % max time to calculate [Myr]

%    for melt fraction calc
     settings.sstol = 1e-6; % steady state target residual
     settings.Flags.T_init='continental'; % 'continental' 'oceanic' or 'adiabatic'

%    state variables [that you want to overwrite from ./00_init_conds/init_settings.m]
     %settings.sig_MPa = 0.1; % [MPa] %0.1 MPa also reasonable for asthenosphere focused study
     %settings.grain0 = 0.01; % grain size [m]

%% settings for parameter variations
%  Box settings
%  define parameter sweep here. var1name must match EXACTLY a field in
%  settings structure. var1 must be defined, var2 lines can be
%  commented/deleted if desired.
  % for SNA
    %settings.Box.var1range = 50:25:225;
    % for TNA:
    settings.Box.var1range = 20:20:200;

    settings.Box.var1name = 'zPlate';
    settings.Box.var1units =' km';

    settings.Box.var2range = 1325:25:1625;
    settings.Box.var2name = 'Tpot';
    settings.Box.var2units =' C';

%   Specify data reduction method for Box storage
    settings.Box.DownSampleMeth='interp';
    settings.Box.DownSampleFactor=1;

%% --------------------------------------------------------------------- %%
%%                        Data Storage
%% --------------------------------------------------------------------- %%
    Work.savedir = [Work.savedir0 '/' Work.savebase];
    if exist(Work.savedir,'dir')~=7
        disp('Save directory does not exist, creating it...')
        mkdir(Work.savedir);
    end
    Work.cwd = pwd; cd(Work.savedir);
    Work.savedirfull = pwd; cd(Work.cwd);
    disp(' ')
    disp(['Saving data in directory ' Work.savedirfull])

    Work.mfile_name = [mfilename('fullpath') '.m'];
    Work.cp_src = system(['04_scripts/sh_source_copy.sh ' Work.savedir ' ' Work.mfile_name]);

%% --------------------------------------------------------------------- %%
%%                     initialize parallel pool
%% --------------------------------------------------------------------- %%
   if isempty(gcp('nocreate'))
       par_settings.c = parcluster('local'); % build the 'local' cluster object
       par_settings.nw = par_settings.c.NumWorkers; % get the number of workers
       if par_settings.procs_to_use > par_settings.nw;
           par_settings.procs_to_use = par_settings.nw;
           disp(['specificed processors exceeds max (' ...
                 num2str(par_settings.nw) '), using max']);
       end
       par_settings.pool = parpool(par_settings.procs_to_use);
   end
   if exist('parallel_monitor','dir')~=7
       mkdir('parallel_monitor');
   else
       delete parallel_monitor/*
   end

%% --------------------------------------------------------------------- %%
%% --------------  thermodynamic state forward model ------------------- %%
%% --------------------------------------------------------------------- %%

   [Box,settings] = BuildBox(settings); %% Build The Box (do this once):
   Work.nBox = numel(Box);
   Box0 = Box; % save this guy for parfor
   settings0=settings; % save it so each proc can modify it
   BoxVec(Work.nBox)=struct();

   parfor iBox = 1:Work.nBox;

      disp(' ');disp('--------------------------------------------------')
      disp(['Starting run ' num2str(iBox) ' of ' num2str(Work.nBox)])

%% ---------------------------- %
%%    set the Box parameters    %
%% ---------------------------- %

      settings = settings0;
      settings.(settings.Box.var1name) = Box0(iBox).info.var1val;
      disp([settings.Box.var1name '=' num2str(settings.(settings.Box.var1name))...
           settings.Box.var1units]);
      if isfield(settings.Box,'var2name');
        settings.(settings.Box.var2name) = Box0(iBox).info.var2val;
        disp([settings.Box.var2name '=' num2str(settings.(settings.Box.var2name))...
           settings.Box.var2units]);
      end

%% ------------------------------ %%
%%    Initialize Thermal Solve    %%
%% ------------------------------ %%

%      build mesh and initial conditions
       settings.Zinfo.zmax=settings.zPlate;
       settings.Zinfo.dz0 = settings.dz0;
       settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
       [Info] = init_values(settings); % calculate initial values

%      set the boundary conditions
       [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);
       [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));

%% ----------------------------- %%
%%     Forward model solution    %%
%% ----------------------------- %%

%%     Lithosphere temperature evolution
       [Vars,Info]=Thermal_Evolution(Info,settings);

%%     Add on adiabatic asthenosphere
       [Vars,Info]=postproc_append_astheno(Vars,Info,settings);

%% ------------------- %%
%%     Data Storage    %%
%% ------------------- %%

%      Put the run in the temporary Box.
       BoxVec(iBox).Info=Info;
       BoxVec(iBox).settings=settings;
       BoxVec(iBox).Vars=Vars;

%      monitor progress
       disp(['Completed Run ' num2str(iBox) ' of ' num2str(Work.nBox)])
       ThisFile=fopen(['parallel_monitor/Run' num2str(iBox) '.txt'],'w');
       fwrite(ThisFile,['Completed Run ' num2str(iBox)]);
       fclose(ThisFile);

       D = dir('parallel_monitor');
       Num = length(D(not([D.isdir])));

       disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\')
       disp(['TOTAL PROGRESS ---> ' num2str(Num) ' of ' num2str(Work.nBox)])
       disp('/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\')
   end


%  empty and remove the parallel monitoring folder
   delete parallel_monitor/*
   rmdir('parallel_monitor')

%  close up parallel
   if strcmp(par_settings.future_jobs,'no')
       par_settings.poolobj = gcp('nocreate');
       delete(par_settings.poolobj);
   end

%  store the temp box in a real box
   [Box] = par_Put_in_Box(BoxVec,Box);

%  put the box in the closet
   Work.savename = [Work.savedir '/Box_' Work.savebase];
   save(Work.savename,'Box')

%  clean up workspace
   clear Box0 BoxVec settings0

disp(' ');disp('--------------------------------------------------');disp(' ')
