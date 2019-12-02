function pdf = probability_distributions(distribution_flag, varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% posterior_pdf = bayes(a, b, c, dependence_flag)
%
% Calculates probability in a Bayesian sense given constraints.
%
% Parameters:
% -----------
%       distribution_flag   string
%                               Shape of distribution: 
%                                   'normal', 'uniform'
%                               Probability given other constraints:
%                                   'likelihood from residuals'
%                               Combo of pdfs: 
%                                   'joint independent'
%                                   'A|B'
%                                   'C|A,B conditionally independent'
%                           description of the desired probability
%                           distribution
%
%       varargin            parameters describing the distribution
%                               'normal'    - {x*, mean, standard deviation}
%                               'uniform'   - {x*, min, max}
%
%                               'likelihood from residuals'
%                                           - {obs val, obs std, predicted}
%
%                               'joint independent' 
%                                           - {marginals}
%                               'A|B'       - {p_B_given_A, p_A, p_B}
%                               'C|A,B conditionally independent'
%                                           - {p_A_given_C, p_B_given_C,
%                                              p_C, p_A_and_B}
%
% Where 
%       x                   values of random variable for which to find
%                           the probability in the given pdf
%
% Output:
% -------
%       pdf         probability for each of the values in x
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch distribution_flag
    case 'uniform'
        x = varargin{1};
        min_val = varargin{2};
        max_val = varargin{3};
        pdf = uniform_probability(x, min_val, max_val);
        
    case 'normal'
        x = varargin{1};
        mu = varargin{2};
        sigma = varargin{3};
        pdf = normal_probability(x, mu, sigma);
        
    case 'likelihood from residuals'
        obs_val = varargin{1};
        obs_std = varargin{2};
        predicted = varargin{3};
        pdf = likelihood_from_residuals(obs_val, obs_std, predicted);
        
    case 'joint independent'
        marginals = varargin{1};
        pdf = joint_independent_probability(marginals);
        
    case 'A|B'
        likelihood_B_given_A = varargin{1};
        prior_A = varargin{2};
        prior_B = varargin{3};
        pdf = conditional_Bayes(likelihood_B_given_A, prior_A, prior_B);
    
    case 'C|A,B conditionally independent'
        p_A_given_C = varargin{1};
        p_B_given_C = varargin{2};
        p_C = varargin{3};
        p_A_and_B = varargin{4};
        pdf = conditionally_independent_C_given_AB(p_A_given_C, ...
            p_B_given_C, p_C, p_A_and_B);
        
    otherwise
        disp('Invalid probability distribution: ', distribution_flag)
end

end

function uniform_pdf = uniform_probability(x, min_val, max_val)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% uniform_pdf = uniform_probability(x, min_val, max_val)
%
% Calculate the probability of having an observed value x given 
% a uniform distribution between min_val and max_val.
% (The same as unifpdf in the stats package).
%
%
% Parameters:
% -----------
%       x           observed value(s)
%
%       min_val     minimum for uniform distribution
%
%       max_val     maximum for uniform distribution
%
% Output:
% -------
%       uniform_pdf     prior probability of being at the observed value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


uniform_pdf = ones(size(x)) ./ (max_val - min_val);

end

function normal_pdf = normal_probability(x, mu, sigma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% normal_pdf = normal_probability(x, mu, sigma)
%
% Calculate the probability of having an observed value x given 
% a normal distribution with mean mu and standard deviation sigma.
% (The same as normpdf in the stats package).
%
%
% Parameters:
% -----------
%       x       observed value(s)
%
%       mu      mean value of distribution
%
%       sigma   standard deviation of the distribution
%
% Output:
% -------
%       normal_pdf  prior probability of being at the observed value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


normal_pdf = (2 * pi * sigma .^ 2)^-0.5 ...
             * exp(-(x - mu) .^ 2 ./ (2 * sigma .^ 2));

end

function likelihood = likelihood_from_residuals(obs_val, obs_std, predicted_vals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pdf = likelihood_from_residuals(obs_val, obs_std, predicted_vals)
%
% Calculate the likelihood (pdf) of the observed value at each of the given
% combination of state variables by comparing the observed value to the
% calculated value, scaled by the observed standard deviation.
%
% The likelihood p(D|A), e.g., P(Vs | T, phi, gs), is calculated using    
% the residual (See manual, Menke book Ch 11):                            
%       p(D|A) = 1 / sqrt(2 * pi * residual) * exp(-residual / 2)         
% residual(k) here is a chi-squared residual. Given chi-square, the PDF   
% of data with a normal distribution:                                     
%       P = 1 / sqrt(2 * pi * sigma^2) * exp(-0.5 * chi-square)           
% where sigma = std of data, chi-square=sum((x_obs - x_preds)^2 / sigma^2)
% e.g. www-cdf.fnal.gov/physics/statistics/recommendations/modeling.html  
%
% Parameters:
% -----------
%       obs_val          observed (seismic) property
%
%       obs_std         standard deviation on the observed value
%
%       predicted_vals  (size(parameter sweep)) matrix of calculated values
%                       of the observed property at each of the different 
%                       parameter sweep combinations
%                       n.b. size(parameter_sweep) = size(sweep.Box)
% Output:
% -------
%       likelihood     (size(parameter sweep)) matrix of the probability
%                       of the observation for each of the proposed
%                       parameter (state variable) combinations
%                       - the LIKELIHOOD.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% chi^2 = sum( (observed - predicted)^2) / sigma ^ 2)
chi_squared = ((predicted_vals - obs_val) .^ 2 ...
               ./ (obs_std .^ 2));

likelihood = ((2 * pi * obs_std.^2).^-0.5 ...
              .* exp(-0.5 * chi_squared));
          
          



end

function joint_independent_pdf = joint_independent_probability(marginals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% joint_independent_pdf = joint_independent_probability(marginals)
%
% Calculate the joint probability (assuming independent) of two or more
% marginal probabilities, {p(A), p(B), ...}.  As we are assuming all
% of these are independent, this is a simple product.
%
%
% Parameters:
% -----------
%       marginals       structure containing the marginal probabilities
%                       p(A), p(B), ...
%                       All marginal probabilities must be the same size.
%
% Output:
% -------
%       joint_independent_pdf       p(A, B), assuming independent
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% As independent, joint pdf is a product:
%       p(A, B, ..., N) =  p(A) * p(B) * ... * p(N)

joint_independent_pdf = ones(size(marginals{1}));

for k = 1:length(marginals)
    joint_independent_pdf = joint_independent_pdf .* marginals{k};
end



end

function p_A_given_B = conditional_Bayes(p_B_given_A, p_A, p_B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% p_A_given_B = conditional_Bayes(p_B_given_A, p_A, p_B)
%
% Calculate the conditional probability using Bayes' Theorem:
%       p(A | B) = p(B | A) * p(A) / p(B)
%
%
% Parameters:
% -----------
%       p_B_given_A         probability of B given A (likelihood)
%
%       p_A                 prior probability of A 
%
%       p_B                 prior probability of B
%
% Output:
% -------
%       p_A_given_B       	posterior probability of A given B
%
% N.B. ALL inputs and outputs should be the same size (or scalars).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_A_given_B = p_B_given_A .* p_A ./ p_B;



end

function p_C_given_AB = conditionally_independent_C_given_AB( ...
    p_A_given_C, p_B_given_C, p_C, p_A_and_B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% p_C_given_AB = conditionally_independent_C_given_AB( ...
%    p_A_given_C, p_B_given_C, p_C, p_A_and_B)
%
% Calculate the conditional probability of C given A and B, assuming that
% A and B are dependent but conditionally independent given C.
% As such, we can calculate:
%           P(C | A, B) = P(A, B, C) / P(A, B)
%                       = P(A, B | C) P(C)  /  P(A, B)
%                       = P(A | C) P(B | C) P(C) / P(A, B)
%
%
% Parameters:
% -----------
%       p_A_given_C         conditional probability of A given C
%
%       p_B_given_C         conditional probability of B given C
%
%       p_C                 prior probability of C
%
%       p_A_and_B           joint probability of A and B
%                           Note that A and B are dependent (only 
%                           conditionally independent given C!)
%                           so p(A, B) != p(A) * p(B)
%
% Output:
% -------
%       p_C_given_AB        conditional probability of C given both A and B
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_C_given_AB = p_A_given_C .* p_B_given_C .* p_C ./ p_A_and_B;

end
