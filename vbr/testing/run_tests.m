function TestResults = run_tests(test_file_string)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TestResults = run_tests(test_file_string)
    %
    % runs all the test functions
    %
    % Parameters
    % ----------
    % test_file_string    optional string to select which test functions to run.
    %                     will only run functions with matching string. Set to 'all'
    %                     or do not provide to run everything.
    %
    %
    % Output
    % ------
    % TestResults   Structure with test results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist('test_file_string','var')
        test_file_string='all';
    end

    disp(['Running tests for test_file_string: ',test_file_string]); disp('')

    file_path = fileparts(mfilename('fullpath'));
    test_config = get_config();

    % run test functions
    disp(['Starting ', test_file_string]); disp(' ')
    if strcmp(test_file_string, 'all')
        % runs all test functions in this directory
        srchstr = fullfile(file_path, 'test_*.m');
        mfiles=dir(srchstr);
    else
        srchstr = fullfile(file_path, ['*', test_file_string,'*.m']);
        mfiles=dir(srchstr);
    end

    if numel(mfiles) > 0
        [TestResults, failedCount, SkippedTests, ErrorMessages] = runTheMfiles(mfiles, test_config);
        TestResults.failedCount = failedCount;
        TestResults.n_tests = numel(mfiles);
    else
        TestResults.failedCount = 0;
        TestResults.n_tests = 0;
        SkippedTests = struct();
    end

    % display the failed test functions
    disp('Testing complete.')
    disp(' ')
    if TestResults.failedCount > 0
        disp('Displaying failed test functions:')
        fldz=fieldnames(TestResults);
        for ifi = 1:numel(fldz)
            fld=TestResults.(fldz{ifi});
            if fld==0
                disp(['    ',fldz{ifi}])
                ei = ErrorMessages.(fldz{ifi});
                disp(['        ', ei.identifier, ': ', ei.message])

            end
        end
    elseif TestResults.n_tests == 0
        disp('found no tests to run')
    else
        disp('Test functions ran successfully')
    end

    skfields = fieldnames(SkippedTests);
    if numel(skfields) > 0
        for ifield = 1:numel(skfields)
            reason = SkippedTests.(skfields{ifield});
            disp(' ')
            disp('Displaying Skipped tests and reason for skipping:')
            disp(['    ', skfields{ifield}, " : ", reason])
            disp(' ')
        end
    end


end

function [TestResults,failedCount, SkippedTests, ErrorMessages] = runTheMfiles(mfiles, test_config)
    TestResults=struct();
    SkippedTests = struct();
    ErrorMessages = struct();
    failedCount=0;
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    for ifile = 1:numel(mfiles)
        fname=mfiles(ifile).name;
        if ~strcmp('run_tests.m',fname)

            [fdir,funcname,ext]=fileparts(fname);
            disp(['    **** Running ', funcname, ' ****'])
            if any(strcmp(test_config.matlab_only, funcname)) && isOctave
                SkippedTests.(funcname) = "MATLAB Only";
            else

                try
                    testResult=feval(funcname);
                    test_error.message = testResult.fail_message;
                    test_error.identifier = 'VBRc_TEST_ERROR';
                    if testResult.passed>0
                        disp('    test passed :D'); disp(' ')
                    else
                        failedCount=failedCount+1;
                        disp('    test failed :('); disp(' ')
                    end
                catch ME
                    err_id = ME.identifier;
                    err_msg = ME.message;
                    test_error = ME;
                    disp(['    ',funcname,' failed :('])
                    disp(' ')
                    disp(['        ', err_id, ': ', err_msg])
                    disp(' ')
                    testResult.passed=false;
                    failedCount=failedCount+1;
                end
                TestResults.(funcname)=testResult.passed;
                ErrorMessages.(funcname) = test_error;
            end
        end
    end
end
