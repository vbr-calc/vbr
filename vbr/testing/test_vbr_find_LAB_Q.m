function TestResult = test_vbr_find_LAB_Q()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbr_find_LAB_Q()
%
% test find_LAB_Q
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

  TestResult.passed = true;
  TestResult.fail_message = '';

  % Z_LAB_Q = find_LAB_Q(Q_z,Z_km,varargin)
  z_km = linspace(0, 200, 50);
  Q_z = 100 * exp(- (z_km/50).^2);

  Z_LAB_Q_1 = find_LAB_Q(Q_z,z_km,'method', 'Q_value', 'value', 90);
  Z_LAB_Q_2 = find_LAB_Q(Q_z,z_km,'method', 'Q_factor', 'value', 1, 'z_min_km', 150);

  if Z_LAB_Q_2 < Z_LAB_Q_1
      TestResult.passed = false;
      TestResult.fail_message = 'Z_LAB_Q_2 should be > Z_LAB_Q_1';
  end

end
