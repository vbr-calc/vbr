function TestResult = test_vbr_anharmonic_refs()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbr_anharmonic_refs()
%
% test the Gu, Ku logic and parameter set choices
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

  TestResult.passed=true;
  TestResult.fail_message = '';


  VBR = get_init_VBR();
  VBR.in.elastic.anharmonic.reference_scaling = 'upper_mantle';
  VBR = VBR_spine(VBR);

  params_ela = Params_Elastic('anharmonic');
  Gu_0 = VBR.out.elastic.anharmonic.Gu_0;
  Ku_0 = VBR.out.elastic.anharmonic.Ku_0;

  if Gu_0(1) ~= params_ela.upper_mantle.Gu_0 * 1e9
    msg = 'Gu_0 does not match expected Gu_0';
    TestResult.passed = false;
    TestResult.fail_message = msg;
    disp(msg)
  end

  if Ku_0(1) ~= params_ela.upper_mantle.Ku_0 * 1e9
    msg = 'Ku_0 does not match expected Ku_0';
    TestResult.passed = false;
    TestResult.fail_message = msg;
    disp(msg)
  end

  % also check that only supplying G_TP works
  VBR = get_init_VBR();
  VBR.in.elastic.anharmonic.Gu_0_ol = 77;
  VBR.in.elastic.anharmonic.Ku_0_ol = 127;
  VBR = VBR_spine(VBR);

  Gu_0 = VBR.out.elastic.anharmonic.Gu_0;
  Ku_0 = VBR.out.elastic.anharmonic.Ku_0;

  expected = VBR.in.elastic.anharmonic.Gu_0_ol * 1e9;
  if Gu_0(1) ~= expected
    msg = 'default Gu_0 does not match expected Gu_0';
    TestResult.passed = false;
    TestResult.fail_message = msg;
    disp(msg)
    disp([Gu_0(1), expected])
  end

  expected = VBR.in.elastic.anharmonic.Ku_0_ol * 1e9;
  if Ku_0(1) ~= expected
    msg = 'default Ku_0 does not match expected Ku_0';
    TestResult.passed = false;
    TestResult.fail_message = msg;
    disp(msg)
    disp([Ku_0(1), expected])
  end
end


function VBR = get_init_VBR()
  VBR = struct();
  VBR.in.SV.T_K = linspace(800, 1000, 4);
  sz_T = size(VBR.in.SV.T_K);
  VBR.in.SV.P_GPa = linspace(2, 3, 4);
  VBR.in.SV.rho = 3300 * ones(sz_T);
  VBR.in.SV.phi = 0.01 * ones(sz_T);

  VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
  VBR.in.elastic.quiet = 1;
end
