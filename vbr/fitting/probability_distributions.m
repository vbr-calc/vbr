function pdf = probability_distributions(distribution_flag, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pdf = probability_distributions(distribution_flag, varargin)
%
% Calculates probability in a Bayesian sense given constraints.
%
% Parameters
% ----------
% distribution_flag:   string
%   A string that specifies the calculation to be done options are:
%        Evaluate a distribution, supply one of:
%            'normal', 'uniform', 'lognormal'
%        Calculate a probability given other constraints, provide:
%            'likelihood from residuals'
%        Combining pdfs, provide one of:
%            'joint independent'
%            'A|B'
%            'C|A,B conditionally independent'
%
%  varargin: parameters describing the distribution, values depend on
%    the distribution flag value.
%
%    When evaluating distributions:
%       'normal'    - {x*, mean, standard deviation}
%       'uniform'   - {x*, min, max}
%       'lognormal' - {x*, mean, standard deviation}
%    where
%       x: matrix
%           values of random variable for which to find the probability
%           in the given pdf
%    expected varargin values for the other distribution_flag
%    values are:
%       'likelihood from residuals' - {obs val, obs std, predicted}
%       'joint independent' - {marginal p_A, p_B, ...}
%        'A|B' - {p_B_given_A, p_A, p_B}
%        'C|A,B conditionally independent' - {p_A_given_C, p_B_given_C,
%                                             p_C, p_A_and_B}
%
% Returns
% ------
% pdf: matrix
%   probability for each of the values in x
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch distribution_flag
    case 'uniform'
        x = varargin{1};
        min_val = varargin{2};
        max_val = varargin{3};
        pdf = probability_uniform(x, min_val, max_val);
    case 'normal'
        x = varargin{1};
        mu = varargin{2};
        sigma = varargin{3};
        pdf = probability_normal(x, mu, sigma);
    case 'lognormal'
        x = varargin{1};
        mu = varargin{2};
        sigma = varargin{3};
        pdf = probability_lognormal(x, mu, sigma);
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

