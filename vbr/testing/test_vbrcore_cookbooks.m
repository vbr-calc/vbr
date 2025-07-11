function TestResult = test_vbrcore_cookbooks()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check that most of the cookbooks run
    % TestResult  struct with fields:
    %           .passed         True if passed, False otherwise.
    %           .fail_message   Message to display if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    TestResult.passed = true;
    TestResult.fail_message = '';

    % assumes we are running from top level directory
    file_list = dir(["Projects", filesep, "vbr_core_examples"]);

    n_files = numel(file_list);

    if isfolder('figures') == 0
        mkdir('figures')
    end 
    disp('    Testing cookbook examples')
    for ifile = 1:n_files
        fname = file_list(ifile).name;
        if strfind(fname, 'CB_') > 0
            
            funccall = ['VBR = ', fname(1:end-2), '();'];
            disp(['        ', funccall])
            eval(funccall)  

            TestResult = check_some_VBR_values(VBR, TestResult, funccall);
            close all
        end 
    end 


end

function TestResult = check_some_VBR_values(VBR, TestResult, funccall)
    % some checks to always run if certain fields exist. e.g., 
    % if VBR.out.anelastic.andrade_psp exists, it will check that J1 
    % and J2 are nonzero. Does not fail if the field is missing though, 
    % so that could result in quiet failures if structure field names are 
    % changed. 

    nonzero_fields = struct();
    n_fields = 1; 

    pe = Params_Elastic('');
    el_fields = {'Gu', 'Ku'};
    for imeth = 1:numel(pe.possible_methods)
        meth = pe.possible_methods{imeth};
        for ifield = 1:numel(el_fields)
            fld = el_fields{ifield};
            nonzero_fields(n_fields).field_loc= {'out'; 'elastic'; meth; fld};
            n_fields = n_fields + 1;
        end
    end 

    pa = Params_Anelastic('');
    ane_fields = {'V'; 'M'; 'Q';};
    
    for imeth = 1:numel(pa.possible_methods)
        meth = pa.possible_methods{imeth};
        for ifield = 1:numel(ane_fields)
            fld = ane_fields{ifield};
            nonzero_fields(n_fields).field_loc= {'out'; 'anelastic'; meth; fld};
            n_fields = n_fields + 1;
        end
    end 
    
    for ifield = 1:numel(nonzero_fields)

        loc_struct = {};
        for iloc = 1:numel(nonzero_fields(ifield).field_loc)
            loc_struct(iloc) = nonzero_fields(ifield).field_loc(iloc);
        end
        [field_exists,missing] = checkStructForField(VBR, loc_struct, 0);
        struct_loc_str = ['VBR', concat_cell_strs(loc_struct,'.')];
        
        if field_exists            
            val = get_nested_field_from_struct(VBR, loc_struct);
            n_negs = sum(val(:) <= 0);        
            if n_negs > 0
                TestResult.passed = false;
                
                msg = ['        the function call ', funccall, 'resulted in ', ...
                        'negative or 0 values for ', struct_loc_str,
                        ];
                TestResult.fail_message = msg;
            end
        end 

    end
end    
