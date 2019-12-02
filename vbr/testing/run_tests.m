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

  % initialize VBR
  addpath('../..')
  vbr_init

  % run test functions
  disp(['Starting ',test_file_string]); disp(' ')
  if strcmp(test_file_string,'all')
    % runs all test functions in this directory
    mfiles=dir('*.m');
  else
    mfiles=dir(['*',test_file_string,'*.m']);
  end

  if numel(mfiles)>0
    [TestResults,failedCount] = runTheMfiles(mfiles);
  end

  % display the failed test functions
  disp('Testing complete.')
  disp(' ')
  if failedCount>0
    disp('Displaying failed test functions. Please run each one and debug:')
    fldz=fieldnames(TestResults);
    for ifi = 1:numel(fldz)
      fld=TestResults.(fldz{ifi});
      if fld==0
        disp(['    ',fldz{ifi}])
      end
    end
  else
    disp('all test functions ran successfully')
  end

end

function [TestResults,failedCount] = runTheMfiles(mfiles)
  TestResults=struct();
  failedCount=0;
  for ifile = 1:numel(mfiles)
    fname=mfiles(ifile).name;
    if ~strcmp('run_tests.m',fname)
      [fdir,funcname,ext]=fileparts(fname);
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
