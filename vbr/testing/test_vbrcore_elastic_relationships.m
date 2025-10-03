
function TestResult = test_vbrcore_elastic_relationships()
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
    

    E = youngs(1, 1);
    if E != 9 / 4
        TestResult.passed=false;
        TestResult.fail_message = ['incorrect youngs modulus. Expected 9/4, found ', num2str(E)];  
    end 

    K = rand(5,5) * 20 + 100; 
    G = rand(5,5) * 20 + 60; 

    E = youngs(K, G); 
    if sum(E<=0) > 0
        TestResult.passed=false;
        TestResult.fail_message = 'E cannot be negative';  
    end 

end
        
