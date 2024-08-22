function P = normal_likelihood(VQ_pred, VQ_obs, std_VQ)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % P = normal_likelihood_(VQ_pred, VQ_obs, std_VQ)
  %
  % likelihood of observing a predicted value
  %
  % parameters
  % VQ_pred : the predicted value or values
  % VQ_obs : the observed mean value
  % std_VQ : standard deviation of observed mean value
  %
  % returns:
  % P : the likelihood distribution
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    chisq = ((VQ_pred - VQ_obs)/std_VQ).^2;
    P = 1./(std_VQ * sqrt(2*pi)) .* exp( - 0.5 * chisq);
end
