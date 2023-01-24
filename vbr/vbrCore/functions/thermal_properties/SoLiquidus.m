function [Solidus] = SoLiquidus(P,H2O,CO2,solfit)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [Solidus] = SoLiquidus(P,H2O,CO2,solfit)
  %
  % calculates peridotite solidus and related properties
  %
  %
  % Parameters
  % ----------
  % P         Pressure in Pa
  % H2O       wt % of water in the melt phase
  % CO2       wt % of CO2 in the melt phase
  % solfit    which dry solidus to use, either 'katz' or 'hirschmann'

  % Output
  % ------
  % Solidus.  structure with following fields
  %        .Tsol       the effective solidus [C]
  %        .Tsol_dry   the volatile free solidus [C]
  %
  % if using 'katz' parametrization, Solidus will also include:
  %
  % Solidus.
  %        .Tliq   effective liquidus [C]
  %        .Tlherz idealized lherzolite solidus [C]
  %        .dTdPsol  productivity [C/GPa]
  %        .dTdPlherz  lherzolite productivity [C/Gpa]
  %        .dTdPliq  liquidis productivity [C/Gpa]
  %        .dTdH2O   dependence of solidus on water content [C / wt %]
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get solidus info
   P_GPa = P * 1e-9;

   [dTH2O,dTdH2O] = depression_katz(H2O,P_GPa);  % H2O in melt phase [wt%]
   dTCO2 = depression_dasgupta(CO2); % CO2 in melt phase [wt%]

   if strcmp(solfit,'katz')
       Solidus = solidus_katz(P_GPa);
       Solidus.Tsol = Solidus.Tsol_dry - dTH2O - dTCO2;
       Solidus.Tliq = Solidus.Tliq_dry - dTH2O - dTCO2;
       Solidus.Tlherz = Solidus.Tlherz_dry - dTH2O - dTCO2;
       Solidus.dTdPlherz=Solidus.dTdPlherz/1e9;
       Solidus.dTdPliq = Solidus.dTdPliq /1e9;
       Solidus.dTdPsol = Solidus.dTdPsol /1e9;
       Solidus.dTdH2O = -dTdH2O; % [C / wt%]
   elseif strcmp(solfit,'hirschmann')
       Solidus = solidus_hirschmann(P_GPa);
       Solidus.Tsol = Solidus.Tsol_dry - dTH2O -dTCO2;
   end


end

function [Sols] = solidus_katz(P)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                     [Sols]=solidus_katz(P,T)
  % Dry peridotie solidus from Katz et al, A new parametrization of hydrous
  % mantle melting, G3, 2003, DOI: 10.1029/2002GC000433
  %
  % Parameters
  % ----------
  %    P    	pressure [GPa]
  %
  % Output
  % ----------
  %    Sols.           structure with solidi temperatures
  %            .Tsol_dry       dry solidus [C]
  %            .Tliq_dry        dry liquidus [C]
  %            .Tlherz_dry   lherzolite solidus [C]
  %            .dTdPliq
  %            .dTdPsol
  %            .dTdPlherz[Solidus] = SoLiquidus(P,H2O,CO2,solfit)
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Parameterization Constants
  % for solidus
    A1 = 1085.7; % [C]
    A2 = 132.9; % [C/GPa]
    A3 = -5.1; % [C/GPa^2]
  % for lherzolite liquidus
    B1 = 1475; % [C]
    B2 = 80; % [C/GPa]
    B3 = -3.2; % [C/GPa^2]
  % for true liquidus
    C1 = 1780; % [C]
    C2 = 45; % [C/GPa]
    C3 = -2.0; % [C/GPa^2]

  % Calculate Solidii
    Sols.Tsol_dry = A1+A2*P+A3*P.^2; % solidus
    Sols.Tlherz_dry=B1+B2*P+B3*P.^2; % lherzolite liquidus
    Sols.Tliq_dry = C1+C2*P+C3*P.^2; % true liquidus

  % Calculate Solidii Derivatives w.r.t. P
    Sols.dTdPsol = A2+2*A3*P; % solidus
    Sols.dTdPlherz=B2+2*B3*P; % lherzolite liquidus
    Sols.dTdPliq = C2+2*C3*P; % true liquidus
end

function [Sols] = solidus_hirschmann(P)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [Sols]=solidus_hirschmann(P)
  %
  % Mantle solidus: Experimental constraints and the effects of peridotite
  %  composition, G3, 2000
  %
  % Parameters
  % ----------
  %    P    	pressure [GPa]
  %
  % Output
  % ------
  %    Sols.           structure with solidi temperatures
  %            .Tsol_dry       dry solidus [C]
  %            .Tliq_dry        dry liquidus [C]
  %            .Tlherz_dry   lherzolite solidus [C]
  %            .dTdPliq
  %            .dTdPsol
  %            .dTdPlherz
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Parameterization Constants
    A1 = 1108.08; % [C]
    A2 = 139.44; % [C/GPa]
    A3 = -5.904; % [C/GPa^2]

  % Calculate Dry Solidus
    Sols.Tsol_dry = A1+A2*P+A3*P.^2; % solidus
end



function [dT,dTdH2O] = depression_katz(H2O,P)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [dT,dTdH2O] = depression_katz(H2O,P)
  %
  % depression of peridotite solidus due to water from  Katz et al, A new
  % parametrization of hydrous mantle melting, G3, 2003,
  % DOI: 10.1029/2002GC000433
  %
  % Parameters
  % ----------
  % P       pressure in GPa
  % H2O     wt % H2O IN MELT (Katz sets bulk H2O, calculates H2O in melt)
  %
  % Output
  % ------
  % dT      the freezing point depression [C]
  % dTdH2O  derivative of dT with respect to H2O wt % [C/wt%]
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % constants
    gamma = 0.75; % temperature depression exponent
    K = 43; % [C/wt%/gamma]
  % H2O Saturation
    H2Osat = 12*P.^0.6 + P;
    H2O = H2O.*(H2O<=H2Osat)+H2Osat.*(H2O>H2Osat);
  % calculate freezing point depression
    dT = K * (H2O).^gamma;
    dTdH2O = gamma * K * (H2O.^(gamma - 1)); % [C / wt%]
end

function [dTz] = depression_dasgupta(CO2_z)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [dTz] = depression_dasgupta(CO2_z)
  %
  % Water follows carbon: CO 2 incites deep silicate melting and dehydration
  % beneath mid-ocean ridges, Geology, 2007
  % DOI: 10.1130/G22856A
  %
  %
  % Parameters
  % ----------
  % CO2     wt % CO2 IN MELT
  %
  % Output
  % ------
  % dTz      the freezing point depression [C]
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dTz = zeros(size(CO2_z));
  for iz = 1:numel(CO2_z)
     CO2 = CO2_z(iz);
     if CO2 <= 25
         dT = 27.04 * CO2 +  1490.75 * log((100-1.18 * CO2)/100);
     elseif CO2 > 25 && CO2 < 37;
         dTmax = 27.04 * 25 +  1490.75 * log((100-1.18 * 25)/100);
         dT = dTmax +  (160 - dTmax)/(37 - 25) * (CO2-25);
     elseif CO2 > 37
         dTmax = 27.04 * 25 +  1490.75 * log((100-1.18 * 25)/100);
         dTmax = dTmax +  (160 - dTmax);
         dT = dTmax + 150;
     end
     dTz(iz)=dT;
  end
end
