function TestResult = test_vbrcore_005_san_carlos_den()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_005_san_carlos_den()
%
% test san_carlos_density_from_pressure
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

  % test the empirical interpolation
  rho = san_carlos_density_from_pressure(0.5);
  rho = san_carlos_density_from_pressure([0.8, 1.1, 11.]);
  if numel(rho) ~= 3
      TestResult.passed = false;
      msg = ["expected rho of length 3, found ", num2str(numel(rho))];
      TestResult.fail_message = msg;
      disp(msg)
  end
  isOctave = is_octave();
  if isOctave == 0
    rng(1);  % set random number seed
  end
  test_in = rand(4,5) * 17;

  rho = san_carlos_density_from_pressure(test_in);
  if size(test_in) ~= size(rho)
      TestResult.passed = false;
      msg = ["expected size of (4,5) found ", num2str(size(rho))];
      disp(msg)
      TestResult.fail_message = msg;
  end

  rho = san_carlos_density_from_pressure(1.9);
  expected = 3.404 * 1000;
  if rho ~= expected
      TestResult.passed = false;
      msg = ["exact density node not matching. Expected 3.404, found ", num2str(rho)];
      disp(msg)
      TestResult.fail_message = msg;
  end

end
