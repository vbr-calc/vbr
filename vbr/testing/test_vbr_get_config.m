function TestResult = test_vbr_get_config()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that the save function works
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    test_config = get_config();

    expected_fields = {"matlab_only"; "vbr_test_data_dir";};
    for ifield = 1:numel(expected_fields)
        if ~isfield(test_config, expected_fields{ifield})
            msg = ['         test_config is missing ', expected_fields{ifield}, ' field'];
            TestResult.passed = false;
            TestResult.fail_message = msg;
            disp(msg)
        end
    end

end
