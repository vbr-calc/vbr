function TestResult = test_vbr_PiezometerWH2006()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbr_PiezometerWH2006()
%
% test that PiezometerWH2006 returns array with
% same dimensions as input and the largest stress
% returns the smallest grain size
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
    
    TestResult.passed=true;
    TestResult.fail_message = '';

    % check that PiezometerWH2006 returns array
    % with same dimensions as input array and the
    % largest stress produces the smallest grain
    % size
    
    nDim = randi([1 10]); Dims = zeros(1,nDim);
    for i = 1:nDim
        Dims(i)=randi([1 10]); 
    end 
    sig_MPa = ones(Dims)*randn(); % create nD array filled with randnormally distributed values with n between 1 and 10

    dg_um = PiezometerWH2006(sig_MPa); %Calculate grain size in um using piezometer for sig_MPa
    
    [~, ind_max_sig_MPa] = max(sig_MPa(:)); % find index of largest stress
    [~, ind_min_dg_um] = min(dg_um(:)); % find index of smallest grain size
    
    if size(dg_um) ~= size(sig_MPa)
        TestResult.passed = false;
        msg = ['Returned dg_um array does not match the dimensions of input sig_MPa array.', ...
               ' Found: ', size(dg_um), ...
               ' Expected: ', size(sig_MPa)];
        TestResult.fail_message = msg;
    elseif ind_max_sig_MPa ~= ind_min_dg_um
        TestResult.passed = false;
        msg = 'Largest stress did not produce smallest grain size.';
        TestResult.fail_message = msg;        
    end
end