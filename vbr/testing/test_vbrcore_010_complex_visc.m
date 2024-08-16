function TestResult = test_vbrcore_010_complex_visc()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TestResult = test_vbrcore_010_complex_visc()
    %
    % test for include_complex_visc
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

    nfreqs = 4;
    n1 = 3;
    n2 = 5;
    expected_sz = [n1, n2, nfreqs];

    VBR = get_init_VBR(nfreqs, n1, n2);
    VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
    VBR.in.GlobalSettings.anelastic.include_complex_viscosity = 1;
    VBR = VBR_spine(VBR);
    TestResult = check_result(VBR, expected_sz, TestResult);

    VBR = get_init_VBR(nfreqs, n1, n2);
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.GlobalSettings.anelastic.include_complex_viscosity = 1;
    VBR = VBR_spine(VBR);
    TestResult = check_result(VBR, expected_sz, TestResult);

    VBR = get_init_VBR(nfreqs, n1, n2);
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR = VBR_spine(VBR);
    for imeth = 1:numel(VBR.in.anelastic.methods_list)
        methname = VBR.in.anelastic.methods_list{imeth};
        if isfield(VBR.out.anelastic.(methname), 'eta_star') == 1
                TestResult.passed=false;
                msg = [cvisc, ' should not contain complex visc fields.'];
                TestResult.fail_message = msg;
        end
    end

end

function TestResult = check_result(VBR, expected_sz, TestResult)
    complex_visc_names = {'eta_star'; 'eta_star_bar'; 'eta_apparent'};

    for imeth = 1:numel(VBR.in.anelastic.methods_list)
        methname = VBR.in.anelastic.methods_list{imeth};
        for icv = 1:3
            cvisc = complex_visc_names{icv};
            if isfield(VBR.out.anelastic.(methname), cvisc) == 0
                TestResult.passed=false;
                msg = [cvisc, ' is missing from ', methname];
                TestResult.fail_message = msg;
            else
                sz = size(VBR.out.anelastic.(methname).eta_apparent);
                if all(sz == expected_sz) == 0
                    TestResult.passed=false;
                    msg = [cvisc, ' output has unexpected size for ', methname, ...
                           ': ', num2str(sz), ' , expected ', num2str(expected_sz)];
                    TestResult.fail_message = msg;
                end
            end
        end
    end
end

function VBR = get_init_VBR(nfreqs, n1, n2)

    VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw';'xfit_premelt'};
    VBR.in.viscous.methods_list={'HZK2011'};

    %  frequencies to calculate at
    VBR.in.SV.f = logspace(-2.2,-1.3,nfreqs);


    % Define the Thermodynamic State
    VBR.in.SV.P_GPa = 2 * ones(n1,n2); % pressure [GPa]
    VBR.in.SV.T_K = 1473 * ones(n1,n2); % temperature [K]
    VBR.in.SV.rho = 3300 * ones(n1,n2); % density [kg m^-3]
    VBR.in.SV.sig_MPa = 10 * ones(n1,n2); % differential stress [MPa]
    VBR.in.SV.phi = 0.0 * ones(n1,n2); % melt fraction
    VBR.in.SV.dg_um = 0.01 * 1e6 * ones(n1,n2); % grain size [um]
    VBR.in.SV.Tsolidus_K=1200*ones(n1,n2); % solidus
end