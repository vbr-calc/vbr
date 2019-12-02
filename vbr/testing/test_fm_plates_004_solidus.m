function TestResult = test_fm_plates_004_solidus()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % TestResult = test_fm_plates_004_solidus()
  %
  % test of solidus calculation in forward model
  %
  % Parameters
  % ----------
  % none
  %
  % Output
  % ------
  % TestResult   True if passed, False otherwise.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  disp('    **** Running test_fm_plates_004_solidus ****')
  TestResult=true;

  F = 0.05;
  z = linspace(0,200,100)*1e3;
  P = 3300*9.8*z;

  Cs_H2O = [0 100 0 100]* 1e-4; % weight percent in solid
  Cs_CO2 = [0 0 100 100] * 1e-4; % weight percent in solid

  kd_H2O = 1e-2; % water solid-melt eq. partition coefficent
  kd_CO2 = 1e-4; % CO2 solid-melt eq. partition coefficent

  for iH2O = 1:numel(Cs_H2O)
      for iCO2 = 1:numel(Cs_CO2)
        Cf_H2O = Cs_H2O(iH2O) ./ (kd_H2O + F * (1-kd_H2O));% wt percent in liquid
        Cf_CO2 = Cs_CO2(iCO2) ./ (kd_CO2+ F * (1-kd_CO2)); % wt percent in liquid
        Solidus_k = SoLiquidus(P,Cf_H2O,Cf_CO2,'katz');
        Solidus_h = SoLiquidus(P,Cf_H2O,Cf_CO2,'hirschmann');
      end
  end
end
