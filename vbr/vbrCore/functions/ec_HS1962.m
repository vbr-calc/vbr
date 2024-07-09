function [VBR] = ec_HS1962(VBR, phase1, phase2, ~) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_HS1962( VBR )
  %
  % Hashin_Shtrikman Lower and upper bound 
  % geophysical mixing model for electrical conductivity of 2 phases
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.HSup.esig()
  %              & VBR.out.electric.HSlo.esig()
  %              & VBR.out.electric.HS.method{} 
  %           
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % read in electric parameters
  phi = VBR.in.SV.phi; % v_f
  p1 = phase1; %S/m
  p2 = phase2; % S/m

  if mean(phase1,"all") > mean(phase2,"all")
      phase1 = p2; % S/m
      phase2 = p1; % S/m

      disp(" \n ")
      disp(" mean(Phase2) less than mean(phase1), where phase2 should be greater than phase1 \n ")
      disp(" Therefore phase2 and phase1 values exchanged for one another \n ")
      disp(" \n ")
  end

  tf = phase1 < phase2; % logic array

  %Calculations
  esigUP = HS1962_up(phase1, phase2, phi); % HS upper bound 
  esigLO = HS1962_lo(phase1, phase2, phi); % HS lower bound

  HSup.esig = esigUP;
  HSlo.esig = esigLO;
  HS.tf = tf;

  % Store in VBR structure
  VBR.out.electric.HSup = HSup;
  VBR.out.electric.HSlo = HSlo;
  VBR.out.electric.HS = HS;
end

    function esig = HS1962_up(esig_1, esig_2,phi) % Hashin-Shtrikman Upper
    num = 3.*(1-phi).*(esig_2-esig_1); % numerator
    den = 3.*esig_2-phi.*(esig_2-esig_1); % denominator
    esig = esig_2.*(1-(num./den));
    end

    function esig = HS1962_lo(esig_1, esig_2,phi) % Hashin-Shtrikman Lower
    num = 3.*(phi).*(esig_2-esig_1); % numerator
    den = 3.*esig_1+(1-phi).*(esig_2-esig_1); % denominator
    esig = esig_1.*(1+(num./den));
    end