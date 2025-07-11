function field_val = get_nested_field_from_struct(my_struct, field_tree_cell);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_nested_field_from_struct
% 
% attempts to fetch a potentially nested field from a structure. Important to 
% note that this function does not check for existence of the field:  
% use checkStructForField before calling this function if you are not sure 
% whether or not the field will exist.
%
% Parameters
% ----------
% my_struct: Struct
%    a structrue
% field_tree_cell: cell array 
%    a cell array containing the path to the field name in the structure, 
%    for example {'out'; 'elastic'; 'anharmonic'; 'Gu'}
%
% Example
% -------
% Gu = get_nested_field_from_struct(VBR, {'out'; 'elastic'; 'anharmonic'; 'Gu'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    n_subs = numel(field_tree_cell);
    field_val = my_struct;
    for i_level = 1:n_subs
        field_val = getfield(field_val, field_tree_cell{i_level});
    end 

end 