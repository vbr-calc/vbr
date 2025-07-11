function VBR = CB_007_SLB2005()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CB_007_SLB2005.m
  %
  %   Calculates SLB parametrization
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Load and set VBR parameters %%
  VBR.in.elastic.methods_list={'SLB2005'};

  %% Define the Thermodynamic State %%
  rho=3300;
  z=linspace(0,300,100)*1e3;
  VBR.in.SV.P_GPa = rho*9.8*z / 1e9;

  zPlate=100*1e3;
  dTdz=0.6 / 1000 ; % deg/m
  VBR.in.SV.T_K = z/zPlate * 1300;
  VBR.in.SV.T_K(z>zPlate)=1300+(z(z>zPlate)-zPlate)*dTdz;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;

  %% CALL THE VBR CALCULATOR %%
  [VBR] = VBR_spine(VBR) ;

  if ~vbr_tests_are_running()
    %% Plot output
    figure()
    subplot(1,3,1)
    plot(VBR.in.SV.P_GPa,z/1e3)
    set(gca,'Ydir','reverse')
    xlabel('P [GPa]'); ylabel('z [km]')

    subplot(1,3,2)
    plot(VBR.in.SV.T_K-273,z/1e3)
    set(gca,'Ydir','reverse')
    xlabel('T [C]'); ylabel('z [km]')

    subplot(1,3,3)
    plot(VBR.out.elastic.SLB2005.Vs,z/1e3)
    set(gca,'Ydir','reverse')
    xlabel('Vs [km/s]'); ylabel('z [km]')
    saveas(gcf,'./figures/CB_007_SLB2005.png')
  end
end