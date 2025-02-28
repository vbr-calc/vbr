function TestResult = test_vbrcore_012_eburgers_method_params()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TestResult = test_vbrcore_012_eburgers_method_params()
    %
    % Checks that all the parameter sets for eburgers run.
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
    
    TestResult.passed = true;
    TestResult.fail_message = '';

    eburg = Params_Anelastic('eburgers_psp');

    fits = eburg.available_fits;

    for ifit = 1:numel(fits)
        fit = fits{ifit}; 
        if isfield(eburg, fit) == 0
            TestResult.passed = false;
            TestResult.fail_message = ['missing fitting parameter set: ', fit];
        end 
    end 


    for ifit = 1:numel(fits)
        VBR = struct() ;
        VBR.in.elastic.methods_list={'anharmonic';};      
        VBR.in.anelastic.methods_list={'eburgers_psp';};
                
        %  frequencies to calculate at
        nfreq = 3;
        VBR.in.SV.f = logspace(-2.2,-1.3,3);
        
        % Define the Thermodynamic State
        n1 = 3;
        n2 = 5;
        VBR.in.SV.P_GPa = 2 * ones(n1,n2); % pressure [GPa]
        VBR.in.SV.T_K = 1473 * ones(n1,n2); % temperature [K]
        VBR.in.SV.rho = 3300 * ones(n1,n2); % density [kg m^-3]
        VBR.in.SV.sig_MPa = 10 * ones(n1,n2); % differential stress [MPa]
        VBR.in.SV.phi = 0.0 * ones(n1,n2); % melt fraction
        VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,n2); % grain size [um]    
        
        VBR.in.anelastic.eburgers_psp.eBurgerFit = fits{ifit};

        VBR = VBR_spine(VBR);

        len_output = numel(VBR.out.anelastic.eburgers_psp.Qinv);
        expected = n1*n2*nfreq;
        if len_output ~= expected
            TestResult.passed = false;
            TestResult.fail_message = 'outputs are the wrong shape';
        end 

        fields_to_check = {'Qinv'; 'V'; 'M'};
        eburgs_out = VBR.out.anelastic.eburgers_psp;
        for ifield = 1:numel(fields_to_check)
            fld = fields_to_check{ifield};
            values = eburgs_out.(fld);
            if min(values(:)) < 0. 
                TestResult.passed = false;
                TestResult.fail_message = [fits{ifit}, ' resulted in negative', fld, ' values'];
            end      
            
            if sum(isinf(values(:))) > 0
                TestResult.passed = false;
                TestResult.fail_message = [fits{ifit}, ' resulted in infinite ', fld,' values'];
            end 
        end 
        
        
    end 


end
