function running_tests = vbr_tests_are_running()
    env_var = getenv('VBRcTesting');
    if numel(env_var) == 0 
        running_tests = 0; 
    else 
        running_tests = strcmp(env_var, '1');
    end     
end 