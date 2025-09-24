function TestResult = test_probability_funcs()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TestResult = test_probability_funcs()
%
% test the probability functions
%
% Parameters
% ----------
% none
%
% Output
% ------
% TestResult  struct with fields:
%           .passed         True if passed, False otherwise.
%           .fail_message   Message to display if false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  TestResult.passed = true;
  TestResult.fail_message = '';

  % just test that some functions run
  x = rand(10,10);
  pdf1 = probability_lognormal(x, .5, .1);
  pdf2 = probability_normal(x, .5, .1);
  pdf3 = probability_uniform(x, 0, 1);
  pdf_joint = joint_independent_probability({pdf1, pdf2, pdf3});

  states.Vs = rand(10,10);
  states.Vs_mean = 0.5;
  states.Vs_std = 0.1;
  states.Vs_pdf_type = 'normal';
  states.Q = rand(10, 10);
  states.Q_mean = 0.65;
  states.Q_std = 0.1;
  states.Q_pdf_type = 'normal';
  states_fields = {'Vs', 'Q'};
  [prior_statevars, sigmaPreds] = priorModelProbs(states, states_fields);

  likelihood_Vs = probability_distributions('likelihood from residuals', ...
        states.Vs_mean, states.Vs_std, states.Vs);
  likelihood_Q = probability_distributions('likelihood from residuals', ...
        states.Q_mean, states.Q_std, states.Q);

  posterior_S_given_Vs = probability_distributions('A|B', ...
        likelihood_Vs, prior_statevars, 1);
  posterior_S_given_Q = probability_distributions('A|B', ...
        likelihood_Q, prior_statevars, 1);
  posterior_S_given_Vs_and_Q = probability_distributions(...
        'C|A,B conditionally independent', likelihood_Vs, likelihood_Q, ...
        prior_statevars, 1);

end
