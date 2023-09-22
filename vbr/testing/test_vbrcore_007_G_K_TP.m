function TestResult = test_vbrcore_007_G_K_TP()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_007_G_K_TP()
%
% test that we can supply G_TP and K_TP
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
  disp('    **** Running test_vbrcore_007_G_K_TP ****')

  % arbitrary values here, just making sure we execute correctly
  VBR = get_init_VBR();
  VBR.in.elastic.Gu_TP = linspace(50, 60, 4) * 1e9;
  VBR.in.elastic.Ku_TP = VBR.in.elastic.Gu_TP * 1.5;
  VBR = VBR_spine(VBR);

  Gu = VBR.out.elastic.anharmonic.Gu;
  if sum(Gu == VBR.in.elastic.Gu_TP) ~= 4
    disp('anharmonic.Gu does not match input G_TP')
    TestResult = false;
  end

  Ku = VBR.out.elastic.anharmonic.Ku;
  if sum(Ku == VBR.in.elastic.Ku_TP) ~= 4
    disp('anharmonic.Ku does not match input K_TP')
    TestResult = false;
  end

  % also check that only supplying G_TP works
  VBR = get_init_VBR();
  VBR.in.elastic.Gu_TP = linspace(50, 60, 4) * 1e9;
  VBR = VBR_spine(VBR);

  Gu = VBR.out.elastic.anharmonic.Gu;
  if sum(Gu == VBR.in.elastic.Gu_TP) ~= 4
    disp('anharmonic.Gu does not match input G_TP (only G_TP supplied)')
    TestResult = false;
  end

end


function VBR = get_init_VBR()
  VBR = struct();
  VBR.in.SV.T_K = linspace(800, 1000, 4);
  sz_T = size(VBR.in.SV.T_K);
  VBR.in.SV.P_GPa = linspace(2, 3, 4);
  VBR.in.SV.rho = 3300 * ones(sz_T);
  VBR.in.SV.phi = 0.01 * ones(sz_T);
  VBR.in.SV.sig_MPa = 1 * ones(sz_T);
  VBR.in.SV.dg_um = 1e4 * ones(sz_T);
  VBR.in.SV.f = [0.01, 0.1];

  VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
  VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'};
  VBR.in.viscous.methods_list={'HZK2011'};
end
