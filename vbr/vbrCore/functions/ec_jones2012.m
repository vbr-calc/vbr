function [ VBR ] = ec_jones2012( VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [ VBR ] = ec_jones2012( VBR )
  %
  %'Jones et al. calibration of hydrous electrical conductivity from previous labratory experiments to South African Jagersfontein and Gibeon Xenolith in situ
  % Constable 2006(SEO3) used as the anhydrous component';
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.electric.jones2012_ol structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % read in electric parameters
  ele = VBR.in.electric.jones2012_ol;
  T = VBR.in.SV.T_K; % K (Temmperature)
  Ch2o = VBR.in.SV.Ch2o; % ppm (water content)
  P = VBR.in.SV.P_GPa * 1e9; % Pa (Pressure)
  Ch2o = Ch2o./1d4; % ppm => wt_f

      % Jones et al., 2012
        S = ele.S; % S/m
        r = ele.r; % unitless
        H = ele.H; % eV
        a = ele.a; % unitless
        Va = ele.Va; % cc/mol
        k = ele.k; % eV/(mol*K)
        H = H + Va.*P; % eV

  % Hydrous Conduction
  esig_H = arrh_wet(S,H,k,T,Ch2o,a,r);

  % Anhydrous Conduction (SEO3)
    % calculate oxygen fugacity from SV.T
      fO2 = OxF(T); % Pa
    % calculation of conductivity 
    esig_A = SEO3_ne(T, fO2);
     
  % summation of conduction mechanisms
  esig = esig_H + esig_A; % S/m

   % store in VBR structure
   jones2012_ol.esig_A = esig_A;
   jones2012_ol.esig_H = esig_H;
   jones2012_ol.esig = esig;
   VBR.out.electric.jones2012_ol = jones2012_ol;
end

function sig = arrh_wet(S,H,k,T,w,a,r)
 exponent = -(H-a.*(w.^(1/3)))./(k.*T);
    sig = (S).*(w.^r).*exp(exponent);
end

function fO2 = OxF(T)
qfm = -24441.9./(T) + 13.296; %revised QFM-fO2 from Jones et al 2009
fO2 = 10.^qfm;
end

function sT = SEO3_ne(T, fO2)
    e = 1.602e-19;
    k = 8.617e-5;
    kT = k*(T);
    bfe = (5.06e24)*exp((-0.357)./kT);
    bmg = (4.58e26)*exp((-0.752)./kT);
    ufe = (12.2e-6)*exp((-1.05)./kT);
    umg = (2.72e-6)*exp((-1.09)./kT);
    concFe = bfe + (3.33e24)*exp((-0.02)./kT).*fO2.^(1/6); 
    concMg = bmg + (6.21e30)*exp((-1.83)./kT).*fO2.^(1/6); 
    sT = concFe.*ufe*e + 2*concMg.*umg*e;
    return 
end
