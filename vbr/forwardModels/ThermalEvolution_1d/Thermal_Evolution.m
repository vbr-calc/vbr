%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%                        Thermal_Evolution.m
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1D finite-volume solution to heat equation
%
% Many initial conditions and material settings are controlled by the
% functions in 01_functions/ and 01_init_conds_and_material.
% These functions are all called by driver.m before calling TwoPhase.
%
% For finite volume, scalar quantities (pressure, melt fraction) are
% solved at cell centers while velocities are defined on cell edges.
%
% Initial conditions are given as input on cell edges.
%
% Final Output is output on cell edges in 2D arrays where each column
% corresponds to a single timestep. i.e., T(:,3) is the temperature
% profile at time step 3. Variables are stored in the Vars structure:
%
%%% Input
%
%
%%% Output
%
% Vars.       output structure, Vars.variable(depth,time)
%     .P        solid pressure [Pa]
%     .phi      porosity
%     .Vbgz     solid velocity [m s^-1]
%     .T        temperature [C]
%     .cp       specific heat capacity [J kg^-1 K^-1]
%     .rho      density (solid?) [kg m^-3]
%     .Kc       thermal conductivity [W m^-2]
%     .dg_um    grain size [micrometers]
%     .sig_MPa  stress [MPa]
%     .eta      shear viscosity [Pa s] (calculated via VBR, max 1e26)
%     .Cs_CO2   carbon dioxide concentration in solid [PPM]
%     .Cf_CO2   carbon dioxide concentration in fluid [PPM]
%     .Cs_H2O   water concentration in solid [PPM]
%     .Cf_H2O   water concentration in fluid [PPM]
%     .comp     compositional weighting function [crust = 0, mantle = 1]
%
% Info.       structure with all the settings, 1D results (e.g., LAB depth)
%     .z        depth array [m]
%     .z_km     depth array [km]
%     .t        array with times corresponding to the columns in
%             the solution arrays [s]
%     .t_Myr    same as t except [Myr]
%     .init.    structure containing initial conditions
%     .ssresid  final max residual
%
%%% Definitions for variables of note that are not output
%    Vark: structure with current time step values of variables
%    InitVals: structure with reference state for material properties
%    LABInfo: structure with LAB and solidus-geotherm intersection depths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vars,Info] = Thermal_Evolution(Info,settings)

%%% --------------------------------------------------------------------- %%
%%% ----------               Initialization                      -------- %%
%%% --------------------------------------------------------------------- %%
  tinit = tic; % initialize time counter
  % addpath ./01_functions % load in functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% load in settings and things %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% space
  dz = settings.Zinfo.dz_m; % mesh spacing
  zs = settings.Zinfo.z_m; % vertical coordinate of cell edges
  % time
  nt = settings.nt; % time steps to go!
  outk = settings.outk; % frequency of output (output every outk steps)
  outn = nt/outk; % number of timesteps to save
  % solution settings
  ss_tol = settings.sstol; % steady state tolerance
  verbose=settings.Flags.verbosity_level; % 1 for everything
  % Initialize flags and counters
  k = 1;         % time step count
  tnow_s = 0;      % current model time
  t_max_Myrs = settings.t_max_Myrs; % max time [Myrs]
  % Boundary Conditions
  BCs = Info.BCs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mesh and initial values %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % input z is the staggered (cell edge) z, need cell-centered
  z = stag(zs);
  z = [z(1)-dz; z(:); z(end)+dz];

  % initialize output structures:
  [Vars,Info,kk]=var_struct(Info,zs,outn);

  % read in initial values to working structures
  [Vark,InitVals] = var_init(Info,BCs,dz);
  keepgoing = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initial calculations and output %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % initial calculation of LAB, SOL and MO depth
  LABInfo = find_LAB(Vark,z,settings,struct());

  % run some diffusion iterations on T to smooth out initial condition if desired
  for it_k0 = 1:settings.T_init_diff_steps
    settings.Flags.TempUpdate='DiffusionOnly'; tnow_init = 0;
    [Vark,resid] = timestep(Vark,tnow_init,LABInfo,settings,z,dz,InitVals,BCs);
  end
  settings.Flags.TempUpdate='FullCalc';

  % save initial step
  [Vars,Info,kk]=var_save(Vars,Vark,Info,tnow_s,k,kk,LABInfo);

%%% --------------------------------------------------------------------- %%
%%% ---------- Solve Forward Problem (time stepping starts here) -------- %%
%%% --------------------------------------------------------------------- %%
  LABInfo.lag_steps=0;
  while keepgoing == 1 && k <= nt
      k = k + 1;

  %%%%%%%%%%%%%%%%
  %%% Time step %%
  %%%%%%%%%%%%%%%%

    [Vark,resid,tnow_s,LABInfo] = timestep(Vark,tnow_s,LABInfo,settings,...
                                                          z,dz,InitVals,BCs);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Output and error/ss check %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if mod(k,outk)==0;
        if verbose > 0
          tMyrs=tnow_s/3600/24/365/1e6;
          fprintf('\n   Storing data at step %i, %0.3f Myrs',k,tMyrs);
          disp(' '); disp(['     T residual: ' num2str(resid.T)])
          disp(['     zsol [km]: ' num2str(LABInfo.zSOL/1e3)])
          disp(['     zLAB [km]: ' num2str(LABInfo.zLAB/1e3)])
        end
        [Vars,Info,kk]=var_save(Vars,Vark,Info,tnow_s,k,kk,LABInfo);
    end

    [keepgoing,Info] = check_stop_run(keepgoing,Info,resid,ss_tol,tnow_s,...
                                    t_max_Myrs,k <= nt);

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % final save and cleanup %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%

  % final variable save
  if verbose > 0
    disp(' '); disp('Calculations complete, wrapping up...')
  end
  [Vars,Info,kk]=var_save(Vars,Vark,Info,tnow_s,k,kk,LABInfo);
  [Vars,Info]=var_finalize(Vars,Info,kk); % removes unfilled columns
  Info.tMyrs=Info.t/3600/24/365/1e6;
  Info.ssresid=resid.T;
  % elapsed time
  t_elapsed=toc(tinit);
  if verbose > 0
    disp(' ');disp(['Elapsed CPU time is ' num2str(t_elapsed/60) ' minutes'])
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  END OF TwoPhase
%   internal functions related to output are here. Other functions are in
%    ./02_functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vars,Info,kk] = var_struct(Info,zs,outn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              var_struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initializes the variable structure (Vars), output counter (kk) and
% settings and single-valued time-variables (Info).
% Add new variables for output here!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nz = numel(zs);
        Info = var_populate(Info,1,outn,'t','zLAB','LABid','zSOL',...
               'zSOLid','zMO','zMOid');
        Info.z = zs;
        Info.z_km = zs/1e3;

        Vars = var_populate([],nz,outn,'Vbgz','phi',...
               'eta','P','T','cp','rho','Kc','dg_um','sig_MPa',...
               'Tsol','Cs_H2O','Cs_CO2','Cf_H2O','Cf_CO2','comp');
        kk = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  Vars = var_populate(Vars,nz,outn,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% takes list of variables and places them in a structure with initial value
% of zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iV = 1:nargin-3
       Vars.(varargin{iV})=zeros(nz,outn);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vars,Info,kk] = var_save(Vars,Vark,Info,tnow_s,k,kk,LABinfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              var_save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updates the output structure with current time step values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [Vark]=stagger_all(Vark,Vars);
%   loop through the structure fields and store in the big output structure
    Fields = fieldnames(Vars);
    for iFie = 1:numel(Fields);
      Vars.(Fields{iFie})(:,kk)= stag(Vark.([Fields{iFie}]));
    end
    Info.t(kk) = tnow_s;
    Info.zLAB(kk) = LABinfo.zLAB; Info.zLABid(kk) = LABinfo.zLABid;
    Info.zSOL(kk) = LABinfo.zSOL; Info.zSOLid(kk) = LABinfo.zSOLid;
    Info.zMO(kk) = LABinfo.zMO; Info.zMOid(kk) = LABinfo.zMOid;

    kk = kk+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vars,Info] = var_finalize(Vars,Info,kk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              var_finalize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removes unfilled cells in output variable arrays.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    kk = kk -1;
    Fields = fieldnames(Vars);
    for iFie = 1:numel(Fields);
      Vars.(Fields{iFie})=Vars.(Fields{iFie})(:,1:kk);
    end
    Info.t = Info.t(1:kk);
    Info.zLAB = Info.zLAB(1:kk);Info.zLABid = Info.zLABid(1:kk);
    Info.zSOL = Info.zSOL(1:kk);Info.zSOLid = Info.zSOLid(1:kk);
    Info.zMO = Info.zMO(1:kk);Info.zMOid = Info.zMOid(1:kk);

    Vars = convertVolatilePPMwt(Vars,'to_PPM');  

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Vark,InitVals] = var_init(Info,BCs,dz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loads initial conditions, moves variables to cell centers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % read in initial values for all variables, move values from cell edges
  % to cell centers.
  fields = fieldnames(Info.init);
  for ifi = 1:numel(fields(:,1));

      field_cc = fields{ifi}; % cell centered field name
      if strcmp(fields{ifi},'Vbgzs')
          field_cc = 'Vbgz';
          Vark.Vbgzs=Info.init.Vbgzs;
      end
      Vark.(field_cc)=addghosts(stag(Info.init.(fields{ifi})));
  end

  % apply BCs on T
  Vark.T = BC_setghosts(Vark.T,BCs.val_T,BCs.type_T,dz);

  % save thermal properties at reference state
  Cp_0 = addghosts(stag(Info.init.Cp_0)); % specific heat [J/kg/K]
  Rho_0 = addghosts(stag(Info.init.Rho_0)); % density [kg/m3]
  Kc_0 = addghosts(stag(Info.init.Kc_0)); % conductiviy [W/m/K]
  InitVals.Cp_0=Cp_0;InitVals.Rho_0=Rho_0;InitVals.Kc_0=Kc_0;
  Vark=rmfield(Vark,'Cp_0');Vark=rmfield(Vark,'Rho_0'); Vark=rmfield(Vark,'Kc_0');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [keepgoing,Info] = check_stop_run(keepgoing,Info,resid,ss_tol,tnow_s,...
                                    t_max_Myrs,kt_test)

  t_s_to_Myrs = 3600*24*365*1e6; % seconds --> Myr factor
  if resid.T<=ss_tol;
      Info.final_message='Reached Steady State';
      keepgoing = 0;
  end
  if tnow_s/t_s_to_Myrs > t_max_Myrs
     keepgoing = 0;
     Info.final_message=['Reached desired t: ' num2str(tnow_s/t_s_to_Myrs) '[Myr]'];
  end

  if kt_test == 0
      Info.final_message='reached maximum time steps';
  end

end
