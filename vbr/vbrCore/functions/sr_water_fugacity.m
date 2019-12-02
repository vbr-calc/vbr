function fH2O=sr_water_fugacity(H2O_PPM,H2O_o,P_Pa,T_K)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % fH2O=sr_water_fugacity(H2O_PPM,H2O_o,P_Pa,T_K)
  %
  % calculates water fugacity following
  %
  %          H2O = A_o * exp(-(E + P * V)/(R*T)) * fH2O
  %
  % equation 6 in Hirth and Kohlstedt, 2003, In Inside the Subduction
  % Factory, J. Eiler (Ed.). https://doi.org/10.1029/138GM06
  %
  % Parameters:
  % -----------
  %        P_Pa      pressure [Pa]
  %        T_K       temperature [K]
  %        H2O_PPM   water concentration [PPM]
  %        H2O_o     min water concentration [PPM], H2O_PPM<H2O_o has no effect.
  %
  % Output:
  % -------
  %        fH2O  water fugacity [MPa]
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % define constants
  E = 40 * 1e3; % activation energy [J/mol]
  V = 10 * 1e-6; % activation volum [m3/mol]
  R = 8.314; % gas constant [J/mol/K]
  A_o = 26; % pre-expondential [PPM/MPa]

  % calculate fugacity
  fH2O = (H2O_PPM>=H2O_o).*(H2O_PPM/A_o).*exp((E+P_Pa*V)./(R*T_K));
end
