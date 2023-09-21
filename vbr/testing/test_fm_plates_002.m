function TestResult = test_fm_plates_002()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_fm_plates_002()
%
% comparison to halfspace cooling solution
%
% Parameters
% ----------
% none
%
% Output
% ------
% TestResult   True if passed, False otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('    **** Running test_fm_plates_002 ****')
  disp('         (takes a few minutes)')
  TestResult=true;
  %  Load Default Settings
  [settings]=init_settings;

  % Computational settings
  settings.dz0=2; % grid cell size [km]
  settings.Flags.verbosity_level = 0; % quiet!
  settings.Z_moho_km = -100; % set negative so that whole domain is astheno
  settings.Flags.PropType='con'; % constant rho, Cp, k --> constant diffusivity
  settings.dTdz_ad=0; % do it in potential temp, set adiabat grad to 0
  settings.T_init_diff_steps=0;

  % time
  settings.nt= 5000; % max number of time steps
  settings.outk = 50 ; % frequency of output (output every outk steps)
  settings.t_max_Myrs=100; % max time to calculate [Myr]

  settings.Flags.T_init='oceanic'; % 'continental' 'oceanic' or 'adiabatic'
  settings.age0 = 1e-16; % [Myrs] only used if T_init is oceanic.

  % build mesh and initial conditions
  settings.Zinfo.zmax=300;
  settings.Zinfo.dz0 = settings.dz0;
  settings.Zinfo = init_mesh(settings.Zinfo); % build the mesh!
  [Info] = init_values(settings); % calculate initial values

  % set the boundary conditions
  [Info.BCs]=init_BCs(struct(),'T','zmin','dirichlet',0);
  [Info.BCs]=init_BCs(Info.BCs,'T','zmax','dirichlet',Info.init.T(end));

  % Lithosphere temperature evolution
  [Vars,Info]=Thermal_Evolution(Info,settings);


  % calculate the analytical solution for each time step

  % get the diffusivity (make sure it's constant)
  kappa=Vars.Kc ./ (Vars.rho .* Vars.cp);
  if min(kappa(:))<max(kappa(:))
    TestResult=false;
    disp('    diffusivity is not constant!!!!!')
  end
  kappa=min(kappa(:));

  % calculate residual of numerical, analytical soln
  max_err=zeros(size(Info.t));
  for it = 1:numel(Info.t)
    t_now=Info.t(it)+settings.age0; % model time, seconds
    T_hs=Info.init.T(end) * erf( Info.z / (2*sqrt(kappa * t_now)));
    T_num=Vars.T(:,it);
    rel_err=abs(T_hs-T_num)./T_hs;
    max_err(it)=max(rel_err(:));
  end

  % check if it passes (ignore first 5 Myrs due to grid resolution)
  max_err_tol=1e-2; %
  t_cutoffs=[5,Info.tMyrs(end)]; % min/max for transient h space soln
  tmask=(Info.tMyrs>=t_cutoffs(1))&(Info.tMyrs<=t_cutoffs(2));
  if sum(max_err(tmask)>max_err_tol)
    disp('     half space cooling solution incorrect!!!!!')
    TestResult=false;
  end

end
