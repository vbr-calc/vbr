function [SVs,HF] = genThermalModels()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % SVs = genThermalModels(ThermalSettings)
  %
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  disp('Generating halfspace cooling profiles...')
  HF.Tsurf_C=0; % surface temperature [C]
  HF.Tasth_C=1400; % asthenosphere temperature [C]
  HF.V_cmyr=8; % half spreading rate [cm/yr]
  HF.Kappa=1e-6; % thermal diffusivity [m^2/s]
  HF.rho=3300; % density [kg/m3]
  HF.t_Myr=linspace(1,50,50); % seaflor age [Myrs]
  HF.z_km=linspace(0,200,100)'; % depth, opposite vector orientation [km]
  dTdz_ad=0.3; % C/km

% HF calculations
  HF.s_in_yr=(3600*24*365); % seconds in a year [s]
  HF.t_s=HF.t_Myr*1e6*HF.s_in_yr; % plate age [s]
  HF.x_km=HF.t_s / (HF.V_cmyr / HF.s_in_yr / 100) / 1000; % distance from ridge [km]

% calculate HF cooling model for each plate age
  HF.dT=HF.Tasth_C-HF.Tsurf_C;
  HF.T_C=zeros(numel(HF.z_km),numel(HF.x_km));
  for HFi_t = 1:numel(HF.t_s)
    HF.erf_arg=HF.z_km*1000/(2*sqrt(HF.Kappa*HF.t_s(HFi_t)));
    HF.T_C(:,HFi_t)=HF.Tsurf_C+HF.dT * erf(HF.erf_arg)+dTdz_ad*HF.z_km;
  end

  % state variables
  SVs.T_K = HF.T_C+273; % set HF temperature, convert to K

  % construct pressure as a function of z, build matrix same size as T_K:
  HF.P_z=HF.rho*9.8*HF.z_km*1e3/1e9; %
  SVs.P_GPa = repmat(HF.P_z,1,numel(HF.t_s)); % pressure [GPa]

  % set the other state variables as matrices of same size
  sz=size(HF.T_C);
  SVs.rho = HF.rho * ones(sz); % density [kg m^-3]
  SVs.sig_MPa = 0.1 * ones(sz); % differential stress [MPa]
  SVs.phi = 0.0 * ones(sz); % melt fraction
  SVs.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]

  [Solidus] = SoLiquidus(SVs.P_GPa*1e9,zeros(sz),zeros(sz),'hirschmann');
  SVs.Tsolidus_K=Solidus.Tsol+273;

end
