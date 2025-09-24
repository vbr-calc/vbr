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
% Parameters
% ----------
%  marginals: cell array
%    A cell array containing the marginal probabilities p(A), p(B), etc.
%    All marginal probabilities must be the same size.
%
% Returns
% -------
% joint_independent_pdf: array
%     joint independent probability, p(A, B , ...)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% As independent, joint pdf is a product:
%       p(A, B, ..., N) =  p(A) * p(B) * ... * p(N)

joint_independent_pdf = ones(size(marginals{1}));

for k = 1:length(marginals)
    joint_independent_pdf = joint_independent_pdf .* marginals{k};
end

end