function params = Params_Global()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % params = Params_Global()
  %
  % loads the global parameters. Intended for parameters used across functions,
  % these parameters may be loaded by the other parameter files. Also includes
  % flags.
  %
  % Parameters:
  % ----------
  % None
  %
  % Output:
  % ------
  % params    the Global parameter structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % flags
  params.melt_enhancement=0; % turns melt enhacement on/off

  % melt enhancement factors
  params.phi_c = [1e-5 1e-5 1e-5]; % [diff, disl., gbs]
  params.x_phi_c = [5 1 5/2]; % [diff, disl., gbs]


end
