function input_args = varargin_keyvals_to_structure(outer_varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % convert key-value pair varargin to a structure
    %
    % for example,
    %
    %     disp(varargin_keyvals_to_structure('first_arg', 0, 'x', 100, 'last_arg', 'hello'))
    %
    %     prints
    %
    %        first_arg = 0
    %        x = 100
    %        last_arg = hello
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    n_varargs = numel(outer_varargin);
    n_keywords = n_varargs / 2;

    if mod(n_varargs, 2) ~= 0
        throw_error_oct_mat('a key and value pair must be provided for each argument.')
    end

    input_args = struct();
    for i_arg = 1:n_keywords
        i_kw = (i_arg - 1) * 2 + 1;
        i_val = i_kw + 1;
        input_args.(outer_varargin{i_kw}) = outer_varargin{i_val};
    end
end