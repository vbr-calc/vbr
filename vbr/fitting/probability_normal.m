function normal_pdf = probability_normal(x, mu, sigma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% normal_pdf = probability_normal(x, mu, sigma)
%
% Calculate the probability of having an observed value x given
% a normal distribution with mean mu and standard deviation sigma.
% (The same as normpdf in the stats package).
%
% Parameters
% ----------
% x: array
%   observed value(s), must be dimensionless and > 0.
% mu: scalar
%   mean value of distribution in log-space
% sigma: scalar
%   standard deviation of the distribution in log-space
%
% Returns
% -------
% normal_pdf: array
%   prior probability of being at the observed value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

normal_pdf = (2 * pi * sigma .^ 2)^-0.5 ...
             * exp(-(x - mu) .^ 2 ./ (2 * sigma .^ 2));

end