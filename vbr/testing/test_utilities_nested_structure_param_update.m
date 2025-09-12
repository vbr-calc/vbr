function TestResult = test_utilities_nested_structure_param_update()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_utilities_nested_structure_update()
%
% test nested_structure_update
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

    anh_1 = Params_Elastic('anharmonic');
    anh_2.Gu_0_ol=40; %[GPa]

    % set shear modulus anharmonic T, P derivatives
    my_custom_scaling.dG_dT = -100 *1e6; % Pa/K
    my_custom_scaling.dG_dP = 20; % Pa/Pa
    my_custom_scaling.dG_dP2 = 0;

    my_custom_scaling.dK_dT = 1.2 * my_custom_scaling.dG_dT;
    my_custom_scaling.dK_dP = 3 *  my_custom_scaling.dG_dP;
    my_custom_scaling.dK_dP2 = 0;

    anh_2.my_custom_scaling = my_custom_scaling;
    anh_2.temperature_scaling = 'my_custom_scaling';
    anh_2.pressure_scaling = 'my_custom_scaling';

    anh_new = nested_structure_update(anh_1, anh_2);


    if anh_new.Gu_0_ol ~= anh_2.Gu_0_ol
        TestResult.passed = false;
        TestResult.fail_message = 'did not copy over new Gu_0_0l';
    elseif ~isfield(anh_new, 'my_custom_scaling')
        TestResult.passed = false;
        TestResult.fail_message = 'did not copy over my_custom_scaling';
    elseif ~strcmp(anh_new.temperature_scaling, 'my_custom_scaling')
        TestResult.passed = false;
        TestResult.fail_message = 'did not set temperature_scaling from new';
    end

end