function TestResult = test_vbrcore_006_density()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_006_density()
%
% test the density helper functions
%
% Parameters
% ----------
% none
%
% Output
% ------
% TestResult   True if passed, False otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  TestResult=true;
  disp('    **** Running test_vbrcore_006_density ****')

  % just checking that it runs with different argument shapes
  rho_o = 3300;
  T_K = 1473;
  FracFo = 1.0;
  rho = Density_Thermal_Expansion(rho_o, T_K, FracFo);

  rho_o = ones(4, 3) * 3300;
  rho = Density_Thermal_Expansion(rho_o, T_K, FracFo);

  FracFo = ones(4, 3) - 0.2;
  rho = Density_Thermal_Expansion(rho_o, T_K, FracFo);

  rho_o = 3300;
  T_K = linspace(1000, 1400, 4) + 273;
  FracFo = 1.0;
  rho = Density_Thermal_Expansion(rho_o, T_K, FracFo);
  
end
