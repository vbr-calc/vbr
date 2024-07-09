function [VBR] = ec_tubes(VBR, phase1, phase2, ~) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_tube( VBR )
  %
  % TUBES geophysical mixing model for electrical conductivity of 2 phases
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.tubes.esig()
  %              & VBR.out.electric.tubes.method{}
  %           
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % read in electric parameters
  phi = VBR.in.SV.phi; % v_f

  % Calculations
  esig = (1/3)*phi.*phase2 + (1-phi).*phase1; % S/m
  tubes.esig = esig; 

  % Store in VBR structure
  VBR.out.electric.tubes = tubes;

end

  