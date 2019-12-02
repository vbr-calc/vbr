function [Rho,Cp,Kc,P] = MaterialProperties(Rho_o,Kc_o,Cp_o,T,z,P0,dTdz_ad,PropType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Rho,Cp,Kc,P] = MaterialProperties(Rho_o,Kc_o,Cp_o,T,z,P0,dTdz_ad,PropType)
%
% calculates density, specific heat and thermal conductivity as a function
% of temperature (and pressure). Also outputs the hydrostatic pressure.
%
%
% Parameters
% ----------
%  Rho_o   reference density at STP (array or scalar)
%  Kc_o    reference conductivity at STP (array or scalar)
%  Cp_o    reference heat capacity at STP (only used for constant values)
%  T       temperature [K]
%  z       depth array [m]
%  P0      pressure at z=0 [Pa]
%  dTdz_ad adiabatic temperature gradient [K m^-1]
%  PropType  a string flag that specifies dependencies of Kc, rho and Cp.
%            possible flags:
%            'con'      Constant rho, Cp and Kc
%            'con_cm'   Constant rho, Cp and Kc in crust and in mantle
%            'P_dep'    pressure dependent rho, constant Cp and Kc
%            'T_dep'    temperature dependent rho, Cp and Kc
%            'PT_dep'   temperature and pressure dependent rho, Cp and Kc
%
% Output
% ------
%  Rho     density [kg m^-3]
%  Cp      specific heat [J kg^-1 K^-1]
%  Kc      thermal conductivity [W m^-1 K^-1]
%  P       hydrostatic pressure [Pa]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set volume fraction forsterite (1 = all forsterite, 0 = all fayalite)
% Reminder, Forsterite = Mg2SiO4, Fayalite = Fe2Si04.
  FracFo = 0.9; %

 if strcmp(PropType,'con') == 1
      Rho = Rho_o;
      P = cumtrapz(z,Rho*9.8)+P0;
      Kc = Kc_o;
      Cp = Cp_o;
 elseif strcmp(PropType,'P_dep')
     [Rho,P] = Density_P(Rho_o,z,P0);
      Kc = Kc_o;
      Cp = Cp_o;
 elseif strcmp(PropType,'T_dep')
      Rho = Density_T(Rho_o,T,z,dTdz_ad,FracFo);
      P = cumtrapz(z,Rho*9.8)+P0;
      Kc = Conductivity(Kc_o,T,P);
      Cp = SpecificHeat(T,FracFo);
 elseif strcmp(PropType,'PT_dep')
      Rho = Density_T(Rho_o,T,z,dTdz_ad,FracFo);
     [Rho,P] = Density_P(Rho,z,P0);
      Kc = Conductivity(Kc_o,T,P);
      Cp = SpecificHeat(T,FracFo);
 elseif strcmp(PropType,'Prescribed_P')
      P = P0;
      Rho = Rho_o;
      Cp = Cp_o;
      Kc = Conductivity(Kc_o,T,P);
 end


end

function [Rho,P] = Density_P(Rho_o,Z,P0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adiabatic Compression                                             %
% following Turcotte and Schubert -- should be ok for upper mantle, %
% shallower than the 410 km phase change.                           %
% see page ~190 in 1st edition, 185 in 2nd edition.                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Rho = Rho_o.*ones(size(Z)); % make sure Rho is an array

% adiabatic compressibility (values from Turcotte and Schubert)
  Beta_Surf = 8.7*1e-12; % at surface [Pa^-1]
  Beta_CMB = 1.6*1e-12; % at CMB [Pa^-1]
  Beta_wt = 1; % choose a weighting (1 = use surface Beta)
  Beta = Beta_wt*Beta_Surf + (1-Beta_wt) * Beta_CMB; % use this value

% integrate the reference density profile
  RhoGZ = cumtrapz(Z,Rho*9.8); % [Pa]

% calculate pressure gradient
  P = -1/Beta * log(1 - Beta * RhoGZ) + P0; % pressure [Pa]

% calculate Rho(P)
  Rho = Rho.*exp(Beta * (P-P0));
end

function [Rho] = Density_T(Rho_o,T,Z,dTdz_ad,FracFo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculates pressure and temperature dependent density, with a couple of
% options for the coefficient of thermal expansion.
%
% rho = rho(P)*(1 + drho(T)) where rho(P) is the adiabatic density profile
% and drho(T) is the nonadiabatic thermal expansion/contraction.
%
% Input
%
%  Rho_o   initial density [kg m^-3], can be an array to cover
%          compositional changes
%  T       temperature [K], can be an array or scalar
%  dTdz_ad adiabatic temperature gradient [K m^-1]
%  FracFo  volume fraction Forsterite
%
% Output
%
%  Rho     density [kg m^-3]
%
%
% Papers referred to in this function:
%
% [Ref 1] M.A. Bouhifid, D. Ardrault, G. Fiquet, P. Richet, Thermal
% expansion of forsterite up to the melting point, Geophys. Res.
% Lett. 10 (1996) 1143 – 1146.
%
% [Ref 2] Xu, Yousheng, et al."Thermal diffusivity and conductivity of olivine,
% wadsleyite and ringwoodite to 20 GPa and 1373 K." Physics of the Earth
% and Planetary Interiors 143 (2004): 321-336.
%
% [Ref 3]  Fei, Yingwei. "Thermal expansion." Mineral physics and
% crystallography: a handbook of physical constants 2 (1995): 29-44.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Rho = Rho_o.*ones(size(Z)); % make sure Rho is an array

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contributation due to thermal expansion/contraction %
% only depends on the nonadiabatic portion!           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Tpot_z = T - dTdz_ad * Z; % get potential temp

%%%%%%%%%%%%%%%%%
% "Good" Method %
%%%%%%%%%%%%%%%%%

%% coefficients from Ref [1]
%  a0 = 2.832 *1e-5;
%  a1 = 3.79 *1e-8;
%  a2 = 0;
%  a = [a0 a1 a2];

 % mean values for coefficients from Ref [2]. a*(1) is forsterite, a*(2) is
 % fayalite. (This one is a bit better I think).
   a0(1) = mean([0.0663 0.1201 0.1172 0.3034 0.2635 0.3407 0.2854]*1e-4);
   a1(1) =mean([0.3898 0.2882 0.0649 0.0722 1.4036 0.8674 1.0080]*1e-8);
   a2(1) =mean(-[0.0918 0.2696 0.1929 0.5381 0.0 0.7545 0.3842]);
   a0(2) = mean([0.1050 0.0819 0.1526 0.2386]*1e-4);
   a1(2) =mean([0.0602 0.1629 -0.1217 1.1530]*1e-8);
   a2(2) =mean(-[0.4958 0.0694 0.4594 0.0518]);
   a(1) = (FracFo*a0(1)+(1-FracFo)*a0(2));
   a(2) = (FracFo*a1(1) + (1-FracFo)*a1(2));
   a(3) = (FracFo*a2(1) + (1-FracFo)*a2(2));

% integrate alpha(T), calculate new density
  Tref = 273; % reference temperature [K]
  al_int = a(1)*(Tpot_z-Tref)+a(2)/2*(Tpot_z.^2-Tref^2) - a(3)*(1./Tpot_z - 1/Tref);
  Rho = Rho .* exp(-al_int);


% Below are the bad methods -- they use the linear approximation, which isn't good
% since we're modeling T from the surface to the convecting interior.
% %%%%%%%%%%%%
% % Method 3 %
% %%%%%%%%%%%%
%
% % Following the approach of Ref [2]: linear expansion with a coeff. of
% % thermal expansion calculated using Ref [3]. Ref [2] doesn't explain which
% % values they use from Ref [3]'s table, so I'm just taking the mean value
% % of the coefficients across the experiments.
%   a0 = mean([0.0663 0.1201 0.1172 0.3034 0.2635 0.3407 0.2854]*1e-4);
%   a1 =mean([0.3898 0.2882 0.0649 0.0722 1.4036 0.8674 1.0080]*1e-8);
%   a2 =mean(-[0.0918 0.2696 0.1929 0.5381 0.0 0.7545 0.3842]);
%   a_Fo = a0 + a1*Tpot_z + a2*Tpot_z.^(-2);
%
%   a0 = mean([0.1050 0.0819 0.1526 0.2386]*1e-4);
%   a1 =mean([0.0602 0.1629 -0.1217 1.1530]*1e-8);
%   a2 =mean(-[0.4958 0.0694 0.4594 0.0518]);
%   a_Fa = a0 + a1*Tpot_z + a2*Tpot_z.^(-2);
%
%   a = a_Fo * FracFo + a_Fa*(1-FracFo);  % effective coefficient of thermal expansion  [K^-1]
%   Tref = 273; % reference temperature [K]
%   Rho = Rho_o.*(1 - (Tpot_z - Tref).*a);

% %%%%%%%%%%%%
% % Method 1 %
% %%%%%%%%%%%%
%
%  % linear expansion, constant coeff. of thermal expansion
%    a0 = 3*1e-5; % [1/K] Turcotte and Schubert value
%    Tref = 273; % reference temperature [K]
%    Rho = Rho_o.*(1 - (Tpot_z - Tref).*a0);
end

function Kc = Conductivity(Kc_o,T,P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculates thermal conductivity using Xu et al.
%
% Input
%
%  Kc_o   scalar or array of reference values for thermal conductivity
%         (an array would be useful for compositional changes with depth)
%  T      temperature (scalar or array) [K]
%  P      pressure [Pa] (only used if using method 1 below
%
% Reference:
% Xu, Y., T. J. Shankland, S. Linhardt, D. C. Rubie, F. Langenhorst, and K.
% Klasinski (2004), Thermal diffusivity and conductivity of olivine,
% wadsleyite and ringwoodite to 20 GPa and 1373 K, Phys Earth Planet In,
% 143-144, 321?336, doi:10.1016/j.pepi.2004.03.005.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% method 1, P-dependent
  Kc = Kc_o.*(298./T).^(0.5) .* (1+0.032*P/1e9);

% % method 2, P-independent
%   Kc = Kc_o.*(298./T).^0.5;

end

function Cp = SpecificHeat(T,FracFo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates specific heat as a function of temperature using a polynomial.
%
% Input
%
%   T       temperature [K], array or scalar
%   FracFo  volume fraction forsterite
%
% Output
%
%   Cp      Specific Heat [J kg^-1 K^-1]
%
% Papers report heat capacity (J/mol/K) as polynomial functions of
% temperature with coefficients determined by fitting. To get to specific
% heat (J/kg/K), I divide the reported coefficients by molecular weight of
% the minerals. The function form is typically:
%
%  Cp = B(1) + B(2)*T + B(3)*T^2 + B(4)*T^-2 + B(5)*T^-3 + ...
%       B(6)*T^-0.5 + B(7)/T
%
% In this implementation, the array B initially has two rows, with values
% for forsterite (Fo) in the first row and fayalite (Fa) in the second row.
% The two are then linearly weighted by the fraction of forsterite in the
% mantle before calculating Cp.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Need molecular weights of forsterite (Mg2Si04) and fayalite (Fe2SiO4):
% (reminder, 1 atomic unit = 1 g / mol = 1e-3 kg / mol)
  wt_Fo = (24.305*2+28.085 + 15.999*4)/1000; % [kg/mol]
  wt_Fa = (55.845*2+28.085 + 15.999*4)/1000; % [kg/mol]

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHOOSE WHICH FIT TO USE %
% (pretty much the same)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
% Fitting 1: Saxena, S. K. "Earth mineralogical model: Gibbs free energy %
% minimization computation in the system MgO-FeO-SiO2." Geochimica et    %
% cosmochimica acta 60.13 (1996): 2379-2395.                             %
%                                                                        %
% Fitting 2: Berman, R. G., and L. Ya Aranovich. "Optimized standard     %
% state and solution properties of minerals." Contributions to Mineralogy%
% and Petrology 126.1-2 (1996): 1-24.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % FITTING 1
%    B = [165.80 0.1855*1e-1 0.0 -3971000 0.28161*1e9 0.0 -5610.0; ...
%         104.45 0.4032*1e-2 0.0 2947000 -.3941*1e9 0.0 -173330.0];

% FITTING 2: Berman and Aranovich, Contrib. Mineral. Petrol. 1996
   B = zeros(2,7);
   B(1,1)=233.18; B(1,6)=-1801.6;B(1,5)=-26.794*1e7;
   B(2,1)=252;B(2,6)=-2013.7; B(2,5)=-6.219*1e7;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert from heat capacity to specific heat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   B(1,:) = B(1,:) / wt_Fo; % [J/mol/K to J/kg/K]
   B(2,:) = B(2,:) / wt_Fa; % [J/mol/K to J/kg/K]
   B = B(1,:)*FracFo + B(2,:)*(1-FracFo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate heat capacity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Cp = B(1) + B(2)*T + B(3)*T.^2 + B(4)*T.^(-2) + B(5)*T.^(-3) + ...
       B(6)*T.^(-0.5) + B(7)./T;

end
