function params = make_param_grid(s_names, sweep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% params = make_param_grid(s_names, sweep)
%
% Given the ranges of state variables in sweep, make the parameters into
% a grid of size (n_var1, n_var2, n_var3 ...).  Also calculate the mean
% and standard deviation of the range of values.
%
% Parameters:
% -----------
%       s_names     names of all of the state varaibles we are varying 
%                   - explicitly coded for one to four different variables
%
%       sweep       structure with the following required fields
%               s_names{1}      vector of the values for first variable
%               ...
%               s_names{end}    vector of values for the last variable
%
% Output:
% -------
%       states          structure with the following fields for each state
%                       in the list states_fields
%           [field]         matrix of size (n_var1, n_var2, n_var3 ...)
%                           for all values of that state variable
%           [field]_mean    mean of the input values for that variable
%           [field]_std     standard deviation of the input values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(s_names) == 1
    params.(s_names{1}) = sweep.(s_names{1});
    
elseif length(s_names) == 2
    [params.(s_names{1}), params.(s_names{2})] = ...
        ndgrid(sweep.(s_names{1}), sweep.(s_names{2}));
    
elseif length(s_names) == 3
    [params.(s_names{1}), params.(s_names{2}), params.(s_names{3})] = ...
        ndgrid(sweep.(s_names{1}), sweep.(s_names{2}), sweep.(s_names{3}));
    
elseif length(s_names) == 4
    [params.(s_names{1}), params.(s_names{2}), params.(s_names{3}),...
        params.(s_names{4})] = ndgrid(sweep.(s_names{1}), ...
        sweep.(s_names{2}), sweep.(s_names{3}), sweep.(s_names{4}));
    
end

for ifn = 1:length(s_names)
    fname = s_names{ifn};
    params.([fname '_mean']) = mean(sweep.(fname));
    params.([fname '_std']) = std(sweep.(fname));
end


end