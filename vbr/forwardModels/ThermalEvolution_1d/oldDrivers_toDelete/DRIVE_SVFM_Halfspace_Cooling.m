%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this script builds the initial settings to call TwoPhase. Commonly
% changed parameters are set here, less frequently changed parameters are
% in initialize_settings.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   disp(' ');disp('--------------------------------------------------')
   clear; %close all
   
   addpath ./00_init_conds ./02_box_functions ./01_functions
   
%% --------------------------------------------------------------------- %%
%%                       Problem Setup      
%% --------------------------------------------------------------------- %%

   disp('Setting up the calculation')

%  Save settings
   cwd=pwd; cd ~; hmdir=pwd; cd(cwd);
   savedir0=[hmdir '/Dropbox/Research/0_Boxes']; % the closet to store the box in 
   savebase = '2016-06-13-prem_test'; % boxes end up named ['Box_' savebase]   
   saveindi = 'yes'; % save all output? yes or no. 
   
%  Load Default Settings  
   [settings]=init_settings;
   
%  Overwrite any of the deafault settings as desired
%    material properties     
     settings.Z_moho_km = 10; % Moho depth [km] 
     
%    Mesh
     settings.dz0=3; % grid cell size [km]
     settings.Zinfo.zmin =0; % min depth for model domain [km]
     settings.Zinfo.zmax = 200; % max z depth [km]
     
%    Computational settings 
%    time
     settings.nt= 150; % max time steps 
     settings.outk =10; % output frequency
     settings.t_max_Myrs=500; % max time to calculate [Myr]     
     
%    for melt fraction calc               
     settings.dt_max = 10;  % max step for advection [Myrs] if advective velo is 0       
     settings.sstol = 1e-5; % steady state target residual
     settings.Flags.T_init='oceanic'; % 'continental' 'oceanic' or 'adiabatic'
     settings.T_init_Zlab=settings.Zinfo.zmax; % [km]
     settings.age0 = 10; % for initial error function [km]
     
%  Box settings
%  define parameter sweep here. var1name must match EXACTLY a field in 
%  settings structure. var1 must be defined (for now - change this?),
%  var2 lines can be commented/deleted if desired.
% 
    settings.Box.var1range = [0];
    settings.Box.var1name = 'Tpot_excess';
    settings.Box.var1units =' C';
     
%     settings.Box.var2range = [5 10];
%     settings.Box.var2name = 'Vbg';
%     settings.Box.var2units =' cm/yr';
%      
%   Specify data reduction method for Box storage     
    settings.Box.DownSampleMeth='interp';
    settings.Box.DownSampleFactor=1;      
   
%% --------------------------------------------------------------------- %%   
%%                        Data Storage   
%% --------------------------------------------------------------------- %% 
       savedir = [savedir0 '/' savebase];
       if exist(savedir,'dir')~=7
           disp('Save directory does not exist, creating it...')
           mkdir(savedir);
       end  
       currentD = pwd; cd(savedir); savedirfull = pwd; cd(currentD); 
       disp(' ')
       disp(['Saving data in directory ' savedirfull])
       
       mfile_name = [mfilename('fullpath') '.m'];       
       system(['04_scripts/sh_source_copy.sh ' savedir ' ' mfile_name])
       
%% --------------------------------------------------------------------- %%
%% --------------------  thermodynamic state --------------------------- %%
%% --------------------------------------------------------------------- %%
    
  
  
   [Box,settings] = BuildBox(settings); %% Build The Box (do this once):  
   nvar1=settings.Box.nvar1; nvar2=settings.Box.nvar2;    
   for iBox = 1:nvar1*nvar2
      disp(' ');disp('--------------------------------------------------')        
      disp(['Starting run ' num2str(iBox) ' of ' num2str(nvar1*nvar2)])  
      
%     set the parameters        
      settings.(settings.Box.var1name) = Box(iBox).info.var1val;
      disp([settings.Box.var1name '=' num2str(settings.(settings.Box.var1name))...
           settings.Box.var1units]);
      if isfield(settings.Box,'var2name');
        settings.(settings.Box.var2name) = Box(iBox).info.var2val;
        disp([settings.Box.var2name '=' num2str(settings.(settings.Box.var2name))...
           settings.Box.var2units]);
      end   
      
%%    ------------------------------------------------------------- %%   
%%                   Solution   
%%    ------------------------------------------------------------- %% 

 
%      calculate initial conditions
       settings.Zinfo.dz0 = settings.dz0; 
       settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
       [Info] = init_values(settings); % for T, phi, Vbg
%      set the boundary conditions             
       [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);       
       [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));
       

       [Vars,Info]=Thermal_Evolution(Info,settings);
       disp(Info.final_message)       
                     
       
%      Put the run in the Box.
       [Box] = Put_in_Box(Box,Vars,Info,settings,iBox);
       
       
%      Put the box in the closet (could do this once at the end, doing it 
%      here in case of crashes -- at least get a partial Box if something
%      goes wrong)
       savename = [savedir '/Box_' savebase];
       save(savename,'Box')   
       
       disp(['Completed Run ' num2str(iBox) ' of ' num2str(nvar1*nvar2)])
       disp(['Box name: ' savedirfull '/Box_' savebase])
       
%      save individual run       
       if strcmp(saveindi,'yes')
         if exist([savedir '/individual_runs'],'dir')~=7
             mkdir([savedir '/individual_runs']);
         end
         indifile=[savebase '_' num2str(iBox)];
         savename = [savedir '/individual_runs/' indifile];
         save(savename,'Vars','settings','Info')
         disp(['Run name: ' savedirfull '/individual_runs/' indifile])
       end                        
                    
    
   end
   
   savename = [savedir '/Box_' savebase];
   save(savename,'Box')
   
disp(' ');disp('--------------------------------------------------');disp(' ')
