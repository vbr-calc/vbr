function input_args = varargin_keyvals_to_structure(outer_varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % input_args = varargin_keyvals_to_structure(outer_varargin)
    %
    % convert key-value pair varargin to a structure. useful for function input validation
    %
    % Parameters
    % ----------
    % outer_varargin
    %     the varargin values from a different function
    %
    % Returns
    % -------
    % input_args: structure
    %     a structure containing fields and values for each key-value pair in outer_varargin
    %
    % Examples
    % --------
    %
    % basic usage:
    %
    %     disp(varargin_keyvals_to_structure('first_arg', 0, 'x', 100, 'last_arg', 'hello'))
    %
    %     prints
    %
    %        first_arg = 0
    %        x = 100
    %        last_arg = hello
    %
    % To use in other functions for validation:
    %
    %   function result = my_new_function(a, b, varargin)
    %        defaults.x = 1;
    %        defaults.y = 0;
    %        input_args= varargin_keyvals_to_structure(varargin);
    %
    %        % update the structure to include defaults
    %        input_args = nested_structure_update(defaults, input_args);
    %
    %        result = a * input_args.x + b * input_args.y;
    %   end
    %
    % where my_new_function is designed to accept 'x' and 'y' key-value arguments like
    %   my_new_function(a, b, 'x', 10, 'y', 100)
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