function [best_vars, posterior_var1] = ...
    find_best_state_var_combo(posterior, sweep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [best_vars, posterior_var1] = ...
%    find_best_state_var_combo(posterior, sweep)
%
% Loop through the posterior grid by each value of var1 (i.e. temp) and
% record the values of var2 (i.e. melt fraction) and var3 (i.e. grain size)
% that maximise the posterior pdf.  I have generalised the variable names
% to var1, var2, var3 - but still require there to be three state variables
% that we are testing over.
%
% Parameters:
% -----------
%      posterior           (size(sweep.Box)) matrix of posterior
%                          probability for each parameter combination
%
%      sweep               structure with the following fields
%            state_names     cell of the names of the varied parameters
%            [param name]    vector of the range of values that were
%                            calculated
%            Box             output of VBR calculation
%            (also other fields recording values relevant to the
%            calculation)
%
% Output:
% -------
%        best_vars      (n_var1, 3) matrix of values recording the 
%                       combination of state variables with the maximum
%                       posterior pdf
%  
%        posterior_var1     the maximum posterior probability for each 
%                           value of var1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var1 = sweep.state_names{1};
var2 = sweep.state_names{2};
var3 = sweep.state_names{3};

best_vars = zeros(length(sweep.(var1)), 3);
[var3_grid, var2_grid] = meshgrid(sweep.(var3), sweep.(var2));
posterior_var1 = zeros(size(sweep.(var1)));



for i_var1 = 1:length(sweep.(var1))
    [posterior_var1(i_var1), i_pmax] = max(...
        reshape(posterior(i_var1,:,:), 1, []) ...
    );
    best_vars(i_var1, :) = [sweep.(var1)(i_var1), ...
        var2_grid(i_pmax), var3_grid(i_pmax)];
    
end

end
