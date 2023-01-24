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
% TestResult   True if passed, False otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  TestResult=true;
  disp('    **** Running test_vbrcore_005_san_carlos_den ****')

  % test the empirical interpolation
  rho = san_carlos_density_from_pressure(0.5);
  rho = san_carlos_density_from_pressure([0.8, 1.1, 11.]);
  if numel(rho) ~= 3
      TestResult = false;
      disp(["expected rho of length 3, found ", num2str(numel(rho))])
  end
  rng(1);  % set random number seed
  test_in = rand(4,5) * 17;

  rho = san_carlos_density_from_pressure(test_in);
  if size(test_in) ~= size(rho)
      TestResult = false;
      disp(["expected size of (4,5) found ", num2str(size(rho))])
  end

  rho = san_carlos_density_from_pressure(1.9);
  expected = 3.404 * 1000;
  if rho ~= expected
      TestResult = false;
      disp(["exact density node not matching. Expected 3.404, found ", num2str(rho)])
  end

end
