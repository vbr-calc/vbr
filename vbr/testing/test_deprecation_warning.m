function TestResult = test_deprecation_warning()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_deprecation_warning()
%
% check that the deprecation warning works
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

    func_old = 'theoldfuncname';
    func_new = 'thenewfuncname';
    msg = print_func_deprecation_warning(func_old, func_new, 'renamed', false);
    TestResult.passed=true;
    TestResult.fail_message = '';
    if strfind(msg, func_old) == 0
        TestResult.passed=false;
        TestResult.fail_message = ["missing old function from ", msg];
    end

    if strfind(msg, func_new) == 0
        TestResult.passed=false;
        TestResult.fail_message = ["missing new function from ", msg];
    end

end
