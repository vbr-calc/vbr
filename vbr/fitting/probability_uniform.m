function uniform_pdf = probability_uniform(x, min_val, max_val)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% uniform_pdf = probability_uniform(x, min_val, max_val)
%
% Calculate the probability of having an observed value x given
% a uniform distribution between min_val and max_val.
% (The same as unifpdf in the stats package).
%
%
% Parameters
% ----------
% x: array
%   observed value(s)
% min_val: scalar
%   minimum for uniform distribution
% max_val: scalar
%   maximum for uniform distribution
%
% Returns
% -------
% uniform_pdf: array
%   prior probability of being at the observed value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


uniform_pdf = ones(size(x)) ./ (max_val - min_val);

end