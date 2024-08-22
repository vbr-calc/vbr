function data_dir = get_data_dir()

    current_dir = pwd;
    fsep = filesep;
    sep_path = strsplit(current_dir, fsep);
    path_els = numel(sep_path);

    % backwards search up the path to VBRc_2024_workshop
    found_it = 0;
    i_el = path_els;
    while found_it == 0 && i_el >= 1
        if strcmp(sep_path{i_el}, 'VBRc_2024_workshop') == 1
            found_it = i_el;
        end
        i_el = i_el - 1;
    end

    if found_it > 0
        % now concatenate up to found_it
        data_dir = [strjoin(sep_path(1:found_it), fsep), fsep, 'data'];
    else
        disp("Could not find the data directory!!!!!!!!")
    end

end