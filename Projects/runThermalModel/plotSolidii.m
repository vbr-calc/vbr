function plotSolidii(legend_on)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotSolidii(legend_on)
  %
  % calls the Soliquidus function and makes some illustrative plots for a range
  % of water and carbon contents
  %
  %
  % Parameters
  % ----------
  % legend_on  0/1 to turn on/off legend (default on)
  %
  % Output
  % ------
  % None
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist('legend_on','var')
      legend_on=1;
    end
    path_to_top_level_vbr='../../';
    addpath(path_to_top_level_vbr)
    vbr_init

  % set some state variables
    z = linspace(0,200,100)*1e3; % depth [m]
    P = 3300*9.8*z; % pressure [Pa]
    T = 1325  + 0.4 *1e-3 * z; % temperature [C]
    F = 0.0001; % thermodynamic melt fraction (depletion)

  %--- no carbon ---%
    Cs_H2O = [0 100 200 300 400 500] * 1e-4; % weight percent in unmelted solid
    Cs_CO2 = 0 * 1e-4; % weight percent in unmelted solid
    Tsol = zeros(numel(P),numel(Cs_H2O));
    for iH2O = 1:numel(Cs_H2O)
      Solidus = get_Solidus(Cs_H2O(iH2O),Cs_CO2,P,F);
      Tsol(:,iH2O) = Solidus.Tsol;
    end
    figure('Position', [10 10 900 600])
    subplot(1,3,1)
    plot(Tsol,z/1e3);
    if legend_on
      legendCell=strcat(strtrim(cellstr(num2str(Cs_H2O(:)*1e4))),' ppm H_2O');
      legend(legendCell,'location','southwest')
    end
    hold on
    plot(T,z/1e3,'--k')

  %--- no water ---%
    Cs_H2O = 0* 1e-4; % weight percent in unmelted solid
    Cs_CO2 = [0 25 50 75 100 150] * 1e-4; % weight percent in unmelted solid
    Tsol = zeros(numel(P),numel(Cs_CO2));
    for iCO2 = 1:numel(Cs_CO2)
      Solidus = get_Solidus(Cs_H2O,Cs_CO2(iCO2),P,F);
      Tsol(:,iCO2) = Solidus.Tsol;
    end
    subplot(1,3,2)
    plot(Tsol,z/1e3);
    if legend_on
      legendCell=strcat(strtrim(cellstr(num2str(Cs_CO2(:)*1e4))),' ppm CO_2');
      legend(legendCell,'location','southwest')
    end
    hold on
    plot(T,z/1e3,'--k')

  %--- both ---%
    Cs_H2O = [0 100 0 100]* 1e-4; % weight percent in unmelted solid
    Cs_CO2 = [0 0 100 100] * 1e-4; % weight percent in unmelted solid
    Tsol = zeros(numel(P),numel(Cs_CO2));
    for iCO2 = 1:numel(Cs_CO2)
      Solidus = get_Solidus(Cs_H2O(iCO2),Cs_CO2(iCO2),P,F);
      Tsol(:,iCO2) = Solidus.Tsol;
    end

    subplot(1,3,3)
    plot(Tsol,z/1e3);
    if legend_on
      legendCell=strcat(strtrim(cellstr(num2str(Cs_CO2(:)*1e4))),' ppm CO_2,',...
                  strtrim(cellstr(num2str(Cs_H2O(:)*1e4))),' ppm H_2O');
      legend(legendCell,'location','southwest')
    end
    hold on
    plot(T,z/1e3,'--k')

    for iplt=3:-1:1
      subplot(1,3,iplt)
      xlabel('T [C]')
      set(gca,'ydir','reverse');
    end
    ylabel('depth [km]')

end

function Solidus = get_Solidus(Cs_H2O,Cs_CO2,P,F)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Solidus = get_Solidus(Cs_H2O,Cs_CO2,P,F)
  %
  % calls the Soliquidus function after calculating melt volatile content, assumes
  % equilibrium bulk partitioning of volatiles in solid-melt
  %
  %
  % Parameters
  % ----------
  % H2O       wt % of water in the solid phase
  % CO2       wt % of CO2 in the solid phase
  % P         Pressure in Pa
  % F         thermodynamic melt fraction
  %
  % Output
  % ------
  % Solidus The solidus structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % calculate volatile fractions in melt
  kd_H2O = 1e-2;
  kd_CO2 = 1e-4;
  Cf_H2O = Cs_H2O / (kd_H2O + F * (1-kd_H2O));
  Cf_CO2 = Cs_CO2 ./ (kd_CO2+ F * (1-kd_CO2));
  [Solidus] = SoLiquidus(P,Cf_H2O,Cf_CO2,'hirschmann');
end
