function p_C_given_AB = conditionally_independent_C_given_AB( ...
    p_A_given_C, p_B_given_C, p_C, p_A_and_B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% p_C_given_AB = conditionally_independent_C_given_AB( ...
%    p_A_given_C, p_B_given_C, p_C, p_A_and_B)
%
% Calculate the conditional probability of C given A and B, assuming that
% A and B are dependent but conditionally independent given C
% As such, we can calculate:
%           P(C | A, B) = P(A, B, C) / P(A, B)
%                       = P(A, B | C) P(C)  /  P(A, B)
%                       = P(A | C) P(B | C) P(C) / P(A, B)
%
% Parameters
% ----------
% p_A_given_C: array | scalar
%     conditional probability of A given C
% p_B_given_C: array | scalar
%     conditional probability of B given C
% p_C: array | scalar
%     prior probability of C
% p_A_and_B: array | scalar
%     joint probability of A and B
%     Note that A and B are dependent (but only conditionally independent
%     given C!) so p(A, B) != p(A) * p(B)
%
% Returns
% -------
% p_C_given_AB: array | scalar
%     conditional probability of C given both A and B
%
% Note: ALL inputs and outputs should be the same size (or scalars).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_C_given_AB = p_A_given_C .* p_B_given_C .* p_C ./ p_A_and_B;

end
