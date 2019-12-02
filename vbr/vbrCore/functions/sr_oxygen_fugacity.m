function OxFgctyFctr = sr_oxygen_fugacity(fO2,varargin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % OxFgctyFctr = sr_oxygen_fugacity(fO2,varargin)
  %
  % calculates an oxygen fugacity enchancement factor.
  % based on Cline et al. Nature 2019 doi:10.1038/nature25764
  %
  % log(tau_M) ~ -1.2 log(f_O2)
  %
  % this function assumes that the dependence of maxwell time
  % on oxygen fugacity is through the effective viscosity:
  %
  % tau_M ~ f_O2 ^ -1.2
  % tau_M = eta / Gu
  % eta ~ f_O2 ^ -1.2
  % sr = sigma / eta ~ f_O2^1.2
  %
  % sr_fug = f_O2^1.2  : the adjustment factor for oxygen fugacity
  %
  % Parameters:
  % ----------
  %   fO2     oxygen fugacity [bar]
  %   optional varargin parameters:
  %         'fO2_ref' ref value for oxygen fugacity (default 10^-1 for Cline et al)
  %         'm_fO2' oxygen fugacity exponent (default -1.2 for Cline et al)
  %
  % Output:
  % ----------
  %   OxFgctyFctr.  structure with adjustment factors for sr and eta:
  %              .sr strain rate adjustment factor
  %              .eta viscosity adjustment factor
  %
  % to call with defaults:
  %   OxFgctyFctr = sr_oxygen_fugacity(f_O2);
  %
  % to call without defaults:
  %   OxFgctyFctr = sr_oxygen_fugacity(f_O2,'m_fO2',-1.0);
  %
  % to use for adjusting sr, eta or maxwell time:
  %   sr = sr .* OxFgctyFctr.sr;
  %   eta = eta .* OxFgctyFctr.eta;
  %   tau_m = eta / Gu;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % process varargin args
  ValidOpts=struct();
  ValidOpts.fO2_ref={}; % allow any reference value
  ValidOpts.m_fO2={}; % allow any m_o2 value
  % set defaults
  Options=struct('fO2_ref',1e-1,'m_fO2',-1.2);

  % overwrite with input
  Options=validateStructOpts('sr_oxygen_fugacity',varargin,Options,ValidOpts,0);

  % calculate oxygen fugacity factors
  OxFgctyFctr.eta = (fO2 ./ Options.fO2_ref) .^ Options.m_fO2;
  OxFgctyFctr.sr = (fO2 ./ Options.fO2_ref) .^ -Options.m_fO2;
end
