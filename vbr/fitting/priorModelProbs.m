function [Prior_mod, sigmaPreds] = priorModelProbs( ...
    states, states_fields, pdf_types)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [Prior_mod, sigmaPreds] = priodModelProbs( ...
%       States, states_fields, ifnormal)
%
% Loop over the fields in States and calculate probabilities for each field
% to get total prior model pdf.  Each field (listed in states_fields) is
% a state variable name that we are varying.
%
% Assuming that the state variables are all independent of each other
%   p(var1, var2, ...) = p(var1) * p(var2) * ...
%
% Parameters:
% -----------
%       states          structure with the following fields for each state
%                       in the list states_fields
%           [field]         matrix of size (n_var1, n_var2, n_var3 ...)
%                           for all values of that state variable
%           [field]_mean    mean (expected value) for that variable
%           [field]_std     standard deviation for that variable
%
%           ([field]_pdf)   If there is a field [var_name]_pdf, then use
%                           that probability as the prior for that variable
%                           instead of assuming a normal or uniform pdf.
%
%       states_fields   names of all of the state varaibles we are varying
%
%       pdf_type        cell array of strings set to either
%                           'input' - use states.[var]_pdf
%                           'normal' - assume a Gaussian distribution
%                           anything else - uniform distribution
%                       If of length 1, will assume the same for all vars.
%
% Output:
% -------
%        Prior_mod      joint probability of all combinations of the state
%                       variables
%  
%        sigmaPreds     joint standard deviation for all combinations of 
%                       the state variables
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  sigmaPreds = 1;
  marginals{numel(states_fields)} = 1;
  
  for i_field = 1:numel(states_fields)
    this_field=states_fields{i_field};
    std_field=[this_field,'_std']; % e.g., Tpot_std
    mn_field=[this_field,'_mean']; % e.g., Tpot_mean
    
    if length(pdf_types) > 1
        pdf_type = pdf_types{i_field};
    else
        pdf_type = pdf_types{1};
    end
    
    switch pdf_type
        case 'input'
            marginals{i_field} = states.([this_field, '_pdf']);
            sigma = states.(std_field);
        case 'normal'
            % assume a normal distribution
            sigma =  states.(std_field); % standard deviation
            mu     = states.(mn_field); % mean value
            x      = states.(this_field); % measurements
            marginals{i_field} = probability_distributions(...
                'normal', x, mu, sigma);
        otherwise
            % uniform PDF over total range
            sigma = 1;
            minv = min(states.(this_field)(:));
            maxv = max(states.(this_field)(:));
            x = states.(this_field); % measurements
            marginals{i_field} = probability_distributions(...
                'uniform', x, minv, maxv);
    end
    
    % Propagation of uncertainty for product of two real variables, 
    %       f = A * B
    % sigma_f = |f| * sqrt((sigma_A/A)^2) + (sigma_B/B)^2 + 2(cov_AB/A/B))
    % from https://en.wikipedia.org/wiki/Propagation_of_uncertainty
    % cov_AB is the covariance of A and B, which is zero for our
    % (assumed) independent state variables
    sigmaPreds = sigmaPreds .* sigma;
  end
  
  Prior_mod = probability_distributions('joint independent', marginals);
end