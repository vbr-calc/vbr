function [VBR] = ec_layers(VBR, phase1, phase2, ~) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = layer( VBR )
  %
  % LAYERS geophysical mixing model for electrical conductivity of 2 phases
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.layers.esig()
  %              & VBR.out.electric.layer.method{}
  %           
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % read in electric parameters
  phi = VBR.in.SV.phi; % v_f

  % Calculations
  Xs = 1-phi; % solid phase vol_ f
    
  aa = ((Xs.^(2/3))-1).*phase2;
  ab = (Xs.^(1/3)).*phase1;
  a = aa-ab;
    
  b = (Xs-(Xs.^(2/3))).*phase2;
  c = ((Xs.^(2/3))-Xs-1).*phase1;
    
  esig = a.*((b+c).^-1).*phase2;
  layers.esig = esig; 

  % Store in VBR structure
  VBR.out.electric.layers = layers;

end