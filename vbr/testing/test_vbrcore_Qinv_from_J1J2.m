function TestResult = test_vbrcore_Qinv_from_J1J2()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that Qinv_from_J1J2 works
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    J1 = 1 ;
    J2 = 1 ;
    result = Qinv_from_J1_J2(J1, J2);
    if result ~= 1
        TestResult.passed = false;
        TestResult.fail_message = strcat('Qinv_from_J1J2(1,1) should equal 1, but it equals ', num2str(result));
    end

    result = Qinv_from_J1_J2(J1, J2, 1);
    if result ~= 1
        TestResult.passed = false;
        TestResult.fail_message = strcat('Qinv_from_J1J2(1,1,1) should equal 1, but it equals ', num2str(result));
    end

    J1 = logspace(-4,4, 10);
    J2 = logspace(-4,4, 10);
    result = Qinv_from_J1_J2(J1, J2, 0);
    result = Qinv_from_J1_J2(J1, J2, 1);

    [J1, J2] = meshgrid(J1, J2);
    result = Qinv_from_J1_J2(J1, J2);
    result = Qinv_from_J1_J2(J1, J2, 1);
end
