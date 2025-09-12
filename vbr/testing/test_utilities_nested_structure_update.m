function TestResult = test_utilities_nested_structure_update()
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

    struct_1.a = 1;
    struct_1.b = 2;
    struct_1.c = 3;
    struct_1.d.a = 1;
    struct_1.d.b = 2;
    struct_1.nested_1.nested_2.a = 1;
    struct_1.nested_1.nested_2.b = 2;
    struct_1.nested_1.nested_2.c = 3;

    struct_2.b = 5;
    struct_2.d.a = 10;
    struct_2.not_in_1_struct.a = 1000;
    struct_2.not_in_1 = 100;
    struct_2.nested_1.nested_2.a = 2;
    struct_2.nested_1.nested_2.c = 6;

    new_struct = nested_structure_update(struct_1, struct_2);

    if new_struct.a ~= struct_1.a
        TestResult.passed = false;
        TestResult.fail_message = 'bad structure field: a';
    elseif new_struct.b ~= struct_2.b
        TestResult.passed = false;
        TestResult.fail_message = 'did not override b';
    elseif new_struct.d.a ~= 10
        TestResult.passed = false;
        TestResult.fail_message = 'did not override d.a';
    elseif new_struct.d.b ~= 2;
        TestResult.passed = false;
        TestResult.fail_message = 'did not copy over d.b';
    elseif new_struct.nested_1.nested_2.a ~= 2
        TestResult.passed = false;
        TestResult.fail_message = 'did not override nested_1.nested_2.a';
    elseif new_struct.nested_1.nested_2.b ~= 2
        TestResult.passed = false;
        TestResult.fail_message = 'did not copy over nested_1.nested_2.a';
    elseif new_struct.nested_1.nested_2.c ~= 6
        TestResult.passed = false;
        TestResult.fail_message = 'did not override nested_1.nested_2.c';
    elseif new_struct.not_in_1 ~= 100
        TestResult.passed = false;
        TestResult.fail_message = 'did not copy over not_in_1_struct';
    elseif new_struct.not_in_1_struct.a ~= 1000
        TestResult.passed = false;
        TestResult.fail_message = 'did not copy over not_in_1';
    end

end