

function TestResult = test_vbrcore_density_from_vbrc()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_density_from_vbrc()
%
% test the density and adiabat helper functions
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

    P_Pa = 1e9; 
    T_K = 1200 + 273; 
    rho_TP = density_from_vbrc(P_Pa, T_K); 

    P_Pa = linspace(1, 3, 20)*1e9; 
    T_K = linspace(800, 1300, 20) + 273; 
    rho_TP = density_from_vbrc(P_Pa, T_K); 

    rho_TP = density_from_vbrc(P_Pa, T_K, ...
                              'reference_scaling',  'upper_mantle', ...
                              'pressure_scaling', 'upper_mantle'); 

    rho_TP = density_from_vbrc(P_Pa, T_K, 'rho_o', 3310);

end
    