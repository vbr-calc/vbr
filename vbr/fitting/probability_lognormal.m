function lognormal_pdf = probability_lognormal(x, mu, sigma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% lognormal_pdf = probability_lognormal(x, mu, sigma)
%
% Calculate the probability of having an observed value x given
% a log normal distribution with mean mu and standard deviation sigma.
%
% Parameters
% ----------
% x: scalar
%   observed value(s), must be dimensionless and > 0.
% mu: scalar
%   mean value of distribution in log-space
% sigma: scalar
%   standard deviation of the distribution in log-space
%
% Returns
% -------
% lognormal_pdf: array
%   prior probability of being at the observed value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

denom = x .* sigma * sqrt(2*pi);
lognormal_pdf = exp(-(log(x)-mu).^2 ./ (2 * sigma.^2)) ./ denom;

end