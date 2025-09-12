function TestResult = test_vbrcore_custom_anharmonic_scaling()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_vbrcore_custom_anharmonic_scaling()
%
% test that we can do an aharmonic calculation with custom scaling values
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

    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.elastic.anharmonic = Params_Elastic('anharmonic');
    VBR.in.elastic.anharmonic.Gu_0_ol=70; %[GPa]
    VBR.in.elastic.anharmonic.Ku_0_ol=130; %[GPa]

    % set shear modulus anharmonic T, P derivatives
    my_custom_scaling.dG_dT = -50 * 1e6; % Pa/K
    my_custom_scaling.dG_dP = 10; % Pa/Pa or GPa/GPa
    my_custom_scaling.dG_dP2 = 0;

    my_custom_scaling.dK_dT = 1.2 * my_custom_scaling.dG_dT;
    my_custom_scaling.dK_dP = 3 *  my_custom_scaling.dG_dP;
    my_custom_scaling.dK_dP2 = 0;

    VBR.in.elastic.anharmonic.my_custom_scaling = my_custom_scaling;
    VBR.in.elastic.anharmonic.temperature_scaling = 'my_custom_scaling';
    VBR.in.elastic.anharmonic.pressure_scaling = 'my_custom_scaling';

    %% Define the Thermodynamic State %%
    Tref = VBR.in.elastic.anharmonic.T_K_ref;
    VBR.in.SV.T_K=[Tref, Tref + 1, Tref, Tref+1];
    Pref = VBR.in.elastic.anharmonic.P_Pa_ref / 1e9;
    VBR.in.SV.P_GPa = [Pref, Pref, Pref + 1, Pref+1]; % pressure [GPa]
    sz=size(VBR.in.SV.T_K); % temperature [K]
    VBR.in.SV.rho = full_nd(3300, sz); % density [kg m^-3]


    [VBR] = VBR_spine(VBR) ;

    Gu_out = VBR.out.elastic.anharmonic.Gu;
    expected_2 = [VBR.in.elastic.anharmonic.Gu_0_ol*1e9, ...
                  Gu_out(1) + my_custom_scaling.dG_dT * 1, ...
                  Gu_out(1) + my_custom_scaling.dG_dP * 1e9,
    ];
    expected_2(4) = expected_2(3) + expected_2(2) - Gu_out(1);
    if max(abs(Gu_out - expected_2)) > 1e-20
        TestResult.passed = false;
        TestResult.fail_message = 'Gu_out does not match expected';
    end

end