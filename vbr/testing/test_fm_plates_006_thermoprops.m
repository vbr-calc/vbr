function TestResult = test_fm_plates_006_thermoprops()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % TestResult = test_fm_plates_006_thermoprops()
  %
  % code check for ThermodynamicProps(), which calls MaterialProperties()
  %
  % Parameters
  % ----------
  % none
  %
  % Output
  % ------
  % TestResult  struct with fields:
  %           .passed         True if passed, False otherwise.
  %           .fail_message   Message to display if false
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  TestResult.passed =true;
  TestResult.fail_message = '';

  z=transpose(linspace(0,400,100)*1e3);
  P0=1e5;
  Rho_o=3300*ones(numel(z),1);
  Kc_o = 4.17*ones(numel(z),1); % thermal conductivity [W/m/K]
  Cp_o = 1100*ones(numel(z),1); % heat capacity [J/kg/K]
  dTdz_ad = 0.5*1e-3; % adiabatic gradient [K/m]
  z_L=150*1e3;
  T=1400*z/z_L;
  T(z>z_L)=(z(z>z_L)-z_L) * dTdz_ad + max(T(z<=z_L));
  T=T+273;
  PropTypes= {'con';'P_dep';'T_dep';'PT_dep'};
  P1=zeros(numel(z),4);
  P2=zeros(numel(z),4);

  for iPro=1:numel(PropTypes)
    PropType=PropTypes{iPro};

    [P1(:,1),P1(:,2),P1(:,3),P1(:,4)] = ThermodynamicProps(Rho_o,Kc_o,Cp_o,T,z,P0,dTdz_ad,PropType);
    [P2(:,1),P2(:,2),P2(:,3),P2(:,4)] = MaterialProperties(Rho_o,Kc_o,Cp_o,T,z,P0,dTdz_ad,PropType);
% [Rho,Cp,Kc,P]
    diff=sum(abs(P1(:)-P2(:))./P1(:));
    if diff > 0
      TestResult.passed=false;
      msg = '        ThermodynamicProps not matching MaterialProperties';
      TestResult.fail_message = msg;
      disp(msg)
    elseif sum(isnan(P1))>0
      TestResult.passed=false;
      msg = '        ThermodynamicProps solution contains nans';
      disp(msg)
      TestResult.fail_message = msg;
    % elseif sum(isnan(P2))>0
  else 
      TestResult.passed=false;
      msg = '        MaterialProperties solution contains nans';
      disp(msg)
      TestResult.fail_message = msg;
    end
  end

end
