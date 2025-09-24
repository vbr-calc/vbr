function p_A_given_B = conditional_Bayes(p_B_given_A, p_A, p_B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% p_A_given_B = conditional_Bayes(p_B_given_A, p_A, p_B)
%
% Calculate the conditional probability using Bayes' Theorem:
%       p(A | B) = p(B | A) * p(A) / p(B)
%
%
% Parameters
% ----------
% p_B_given_A: array | scalar
%     probability of B given A (likelihood)
% p_A: array | scalar
%     prior probability of A
% p_B: array | scalar
%     prior probability of B
%
% Returns
% -------
% p_A_given_B: array | scalar
%     posterior probability of A given B
%
% Note: ALL inputs and outputs should be the same size (or scalars).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_A_given_B = p_B_given_A .* p_A ./ p_B;



end
