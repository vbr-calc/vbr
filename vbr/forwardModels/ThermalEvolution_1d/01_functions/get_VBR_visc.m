function eta = get_VBR_visc(Vark)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % eta = get_VBR_visc(Vark)
  %
  % calculates steady state viscosity via VBR calculator
  %
  % Parameters
  % ----------
  % Vark         current variables structure
  %
  % Output
  % ------
  % eta        steady state effective viscosity [Pa s]
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % write VBR methods lists (these are the things to calculate)
  visc_method='HK2003';
  VBR.in.viscous.methods_list={visc_method};

  % set relevant state variables
  VBR.in.SV.P_GPa = Vark.P./1e9 ;
  VBR.in.SV.T_K = Vark.T +273;
  VBR.in.SV.phi =  Vark.phi ;
  VBR.in.SV.dg_um = Vark.dg_um ;
  VBR.in.SV.sig_MPa = Vark.sig_MPa ;
  VBR.in.SV.Ch2o = Vark.Cs_H2O;

  % calculate viscosity
  [VBR] = VBR_spine(VBR) ;

  % return viscosity
  eta=VBR.out.viscous.(visc_method).eta_total;
  eta(eta>1e26)=1e26;

end
