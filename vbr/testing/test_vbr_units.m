function TestResult = test_vbr_units()
    ################################################################
    # check that attach_input_metadata works as expected
    ################################################################
    
    units = SV_input_units(); # check that it runs
    
    VBR = struct();
    VBR.in = struct();
    VBR.in.SV = struct();
    VBR.in.SV.T_K = 1; 
    VBR.in.SV.phi = 0.01; 
    VBR.in.SV.P_GPa = 1;
    VBR.in.SV.not_a_field = 0;
    VBR = attach_input_metadata(VBR);
    TestResult = true;
    if isfield(VBR.in, 'sv_metadata')
        if isfield(VBR.in.sv_metadata, "not_a_field")
            disp("unknown field should not be in sv_metadata")
            TestResult = false;
        else
            if strcmp(VBR.in.sv_metadata.T_K, "Kelvin") == 0 
                disp("Incorrect units.")
                TestResult = false;
            end
        end 
    else
        TestResult = false;
    end
    
end 
