function TestResult = test_vbrcore_complexvisc()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that complex viscosity runs
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    J1 = 60 * 1e9;
    J2 = J1*0.95;
    f_Hz = 0.00001; 
    Gu = 62 * 1e9; 
    maxwell_time = 365 * 24 * 3600 * 1000; 
    [eta_star, eta_normalized, eta_app] = complex_viscosity(J1, J2, f_Hz, Gu, maxwell_time);


    n_freq = 5; 
    n_th = 10;
    J1in = transpose(linspace(60,80,n_th) * 1e9);
    J1 = proc_add_freq_indeces(J1in,n_freq);    
    J2 = J1*0.95;
    f_Hz = logspace(-6,-1,n_freq); 
    Gu = J1in * 1.05; 
    maxwell_time = 1e18 ./ Gu; 
    [eta_star, eta_normalized, eta_app] = complex_viscosity(J1, J2, f_Hz, Gu, maxwell_time);

end
