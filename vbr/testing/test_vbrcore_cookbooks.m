function TestResult = test_vbrcore_cookbooks()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that most of the cookbooks run
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    % assumes we are running from top level directory
    file_list = dir(["Projects", filesep, "vbr_core_examples"]);

    n_files = numel(file_list);

    if isdir('figures') == 0
        mkdir('figures')
    end 
    disp('    Testing cookbook examples')
    for ifile = 1:n_files
        fname = file_list(ifile).name;
        if strfind(fname, 'CB_') > 0
            
            funccall = ['outputs = ', fname(1:end-2), '();'];
            disp(['        ', funccall])
            eval(funccall)            
            close all
        end 
    end 


end
