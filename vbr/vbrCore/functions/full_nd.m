function X = full_nd(fill_val, varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % X = full_nd(fill_val, N)
    %
    % returns an N-D array filled with a constant. After fill_val, all arguments
    % are forwarded to ones().
    %
    % Parameters:
    % ----------
    % fill_val
    %     the number to fill the array (or matrix) with
    %
    % remaining arguments are forwarded to ones().
    %
    %
    % Output:
    % ------
    % matrix
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    X = ones(varargin{:}) * fill_val;
end