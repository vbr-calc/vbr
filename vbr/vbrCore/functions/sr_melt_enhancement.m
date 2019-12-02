function [SR_phi_enh] = sr_melt_enhancement(phi,alpha,x_phi_c,phi_c)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [SR_phi_enh] = sr_melt_enhancement(phi,alpha,x_phi_c,phi_c)
  %
  % calculates a reduction factor for strain rate following Holtzman, 2016,
  % Geochem. Geophys. Geosyst., https://doi.org/10.1002/2015GC006102
  %
  % Parameters
  % ----------
  % phi      melt fraction, 0<=phi<=1
  % alpha    steady-state melt fraction dependence
  % x_phi_c  controls steepness of step
  % phi_c    critical melt fraction
  %
  % Ouput
  % -----
  % SR_phi_enh strain rate enhancement factor
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % error function for step = log(x_phi_c) * exp(-alpha*phi)
  % with a variable parameter for the amplitude of the step.
  a = log(x_phi_c) ;
  ratefac = 1./(phi_c) ;
  step = a.*erf(phi.*ratefac) ;
  slope = alpha.*phi;
  ln_SR_phi_enh = slope + step ;
  SR_phi_enh = exp( ln_SR_phi_enh ) ;

end
