function TestResult = test_utilities_vbr_categorical_cmap()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_utilities_vbr_categorical_cmap()
%
% test the categorical colormap
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

    x = vbr_categorical_cmap_array();
    if max(x) > 1
        msg = 'colormap rgb values contain value > 1';
        TestResult.passed = false;
        TestResult.fail_message = msg;
    end

    rgb_1 = vbr_categorical_color(1);
    rgb_n1 = vbr_categorical_color(numel(x)+1);
    if all(rgb_1==rgb_n1) == 0
        msg = 'categorical colormap sample incorrectly wrapped';
        TestResult.passed = false;
        TestResult.fail_message = msg;
    end

end