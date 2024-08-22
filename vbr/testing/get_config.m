function test_config = get_config()
    % configuration for tests

    % add test function names to the following cell array to identify the test function
    % as a matlab-only test.
    test_config.matlab_only = {'test_matlab_only_test_trigger';};

    % directory for temporary files generated by tests
    vbr_test_data_dir = getenv("VBR_TEST_DATA_DIR");
    if numel(vbr_test_data_dir) == 0
        vbr_test_data_dir = fullfile(".", ".vbr_test_data_dir");
    else
        vbr_test_data_dir = fullfile(vbr_test_data_dir, ".vbr_test_data_dir");
    end
    if exist(vbr_test_data_dir, 'dir') == 0
        mkdir(vbr_test_data_dir)
    end
    test_config.vbr_test_data_dir = vbr_test_data_dir;

end
