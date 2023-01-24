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
        [TestResults, failedCount, SkippedTests] = runTheMfiles(mfiles, test_config);
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
        disp('Displaying failed test functions. Please run each one and debug:')
        fldz=fieldnames(TestResults);
        for ifi = 1:numel(fldz)
            fld=TestResults.(fldz{ifi});
            if fld==0
                disp(['    ',fldz{ifi}])
            end
        end
    elseif TestResults.n_tests == 0
        disp('found no tests to run')
    else
        skfields = fieldnames(SkippedTests);
        if numel(skfields) > 0
            for ifield = 1:numel(skfields)
                reason = SkippedTests.(skfields{ifield});
                disp('Displaying Skipped tests and reason for skipping:')
                disp(['    ', skfields{ifield}, " : ", reason])
            end
        else
            disp('all test functions ran successfully')
        end
    end

end

function [TestResults,failedCount, SkippedTests] = runTheMfiles(mfiles, test_config)
    TestResults=struct();
    SkippedTests = struct();
    failedCount=0;
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    for ifile = 1:numel(mfiles)
        fname=mfiles(ifile).name;
        if ~strcmp('run_tests.m',fname)
            [fdir,funcname,ext]=fileparts(fname);

            if any(strcmp(test_config.matlab_only, funcname)) && isOctave
                SkippedTests.(funcname) = "MATLAB Only";
            else

                try
                    testResult=feval(funcname);
                    if testResult>0
                        disp('    test passed :D'); disp(' ')
                    else
                        failedCount=failedCount+1;
                        disp('    test failed :('); disp(' ')
                    end
                catch
                    disp(['    ',funcname,' failed :('])
                    disp(['    please run ',funcname,'() and debug.']); disp(' ')
                    testResult=false;
                    failedCount=failedCount+1;
                end
                TestResults.(funcname)=testResult;
            end
        end
    end
end
