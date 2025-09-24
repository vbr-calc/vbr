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
% obs_val
%     observed (seismic) property
% obs_std
%     standard deviation on the observed value
% predicted_vals
%     (size(parameter sweep)) matrix of calculated values
%     of the observed property at each of the different
%     parameter sweep combinations. i.e.,
%           size(parameter_sweep) = size(sweep.Box)
% Output:
% -------
% likelihood
%       (size(parameter sweep)) matrix of the probability of the
%       observation for each of the proposed parameter (state variable)
%       combinations - the LIKELIHOOD.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% chi^2 = sum( (observed - predicted)^2) / sigma ^ 2)
chi_squared = ((predicted_vals - obs_val) .^ 2 ...
               ./ (obs_std .^ 2));

likelihood = ((2 * pi * obs_std.^2).^-0.5 ...
              .* exp(-0.5 * chi_squared));

end