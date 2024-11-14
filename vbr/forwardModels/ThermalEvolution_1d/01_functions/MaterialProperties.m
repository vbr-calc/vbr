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
     [Rho,P] = density_adiabatic_compression(Rho_o,z,P0);
      Kc = Kc_o;
      Cp = Cp_o;
    elseif strcmp(PropType,'T_dep')
      Rho = Density_NonAdiabatic_Thermal_Expansion(Rho_o,T,z,dTdz_ad,FracFo);
      P = cumtrapz(z,Rho*9.8)+P0;
      Kc = ThermalConductivity(Kc_o,T,P);
      Cp = SpecificHeat(T,FracFo);
    elseif strcmp(PropType,'PT_dep')
      Rho = Density_NonAdiabatic_Thermal_Expansion(Rho_o,T,z,dTdz_ad,FracFo);
     [Rho,P] = density_adiabatic_compression(Rho,z,P0);
      Kc = ThermalConductivity(Kc_o,T,P);
      Cp = SpecificHeat(T,FracFo);
    elseif strcmp(PropType,'Prescribed_P')
      P = P0;
      Rho = Rho_o;
      Cp = Cp_o;
      Kc = ThermalConductivity(Kc_o,T,P);
    end
end



function [Rho] = Density_NonAdiabatic_Thermal_Expansion(Rho_o,T,Z,dTdz_ad,FracFo)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % corrects density for nonadiabatic thermal expansion
    %
    % rho = rho(P)*(1 + drho(T)) where rho(P) is the adiabatic density profile
    % and drho(T) is the nonadiabatic thermal expansion/contraction.
    %
    % Parameters
    % ----------
    % Rho_o   initial density [kg m^-3], can be an array to cover
    %         compositional changes
    % T       temperature [K], can be an array or scalar
    % dTdz_ad adiabatic temperature gradient [K m^-1]
    % FracFo  volume fraction Forsterite
    %
    % Output
    % -------
    % Rho     density [kg m^-3]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Rho = Rho_o.*ones(size(Z)); % make sure Rho is an array
    Tpot_z = T - dTdz_ad * Z; % the non-adibatic temperature difference
    Rho = density_thermal_expansion(Rho, Tpot_z, FracFo);

end
