function [sr] = sr_flow_law_calculation(T,P,sig_MPa,d,phi,fH2O,FLP)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calculates strain rates at the given thermodynamic conditions using
  % standard flow law formulation.
  %
  % Parameters:
  % ----------
  %    T             temperature in Kelvins
  %    P             pressure in Pa
  %    sig           stress in MPa
  %    d             grain size in microns
  %    phi           melt fraction (i.e. 0<phi<1)
  %    fH2O          water fugacity in MPa
  %    FLP.           structure with flow law parameters
  %       .A
  %       .Q
  %       .n
  %       .V
  %       .p
  %       .r
  %       .alf
  %       .phi_c
  %       .x_phi_c
  %
  % Output:
  % ------
  %    sr           strain rate [1/s]
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % initialization
  R = 8.314 ; % gas constant

  % truly melt-free strain rate
  sr = FLP.A .* (sig_MPa.^FLP.n) .* (d.^(-FLP.p)) ...
            .* exp(-(FLP.Q + P .* FLP.V)./(R.*T)).* fH2O.^FLP.r; % nominally melt free
  sr = sr./FLP.x_phi_c; % correction to truly melt free

  % melt enhanced strain rate
  [enhance] = sr_melt_enhancement(phi,FLP.alf,FLP.x_phi_c,FLP.phi_c);
  sr = sr .* enhance; 

end
