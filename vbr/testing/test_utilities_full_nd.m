function TestResult = test_utilities_full_nd()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_utilities_full_nd()
%
% test full_nd
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
    x = full_nd(1.0, 2);
    if all(size(x)==2)
        msg = 'full_nd failed full_nd(1.0, 2) check.';
        TestResult.passed = false;
        TestResult.fail_message = msg;
    end

    x = full_nd(1.0, 2, 4, 3);
    sh = size(x);
    if sh(1) ~= 2 or sh(2) ~= 4 or sh(3) ~= 3
        msg = 'full_nd failed full_nd(1.0, 2, 4, 3) check.';
        TestResult.passed = false;
        TestResult.fail_message = msg;
    end

end