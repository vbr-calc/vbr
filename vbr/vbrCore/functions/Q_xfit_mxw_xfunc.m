function [X_tau] = Q_xfit_mxw_xfunc(tau_norm_vec,params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [X_tau] = X_func(tau_norm_vec,params)
  % the relaxation spectrum function of xfit_mxw (McCarthy et al 2011)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if strcmp(params.fit,'fit2')
    params.tau_cutoff=params.tau_cutoff_fit2;
    params.beta2=params.beta2_fit2;
  end

  Beta  = params.beta1 .* ones(size(tau_norm_vec));
  Alpha = params.Alpha_a - params.Alpha_b./(1+params.Alpha_c*(tau_norm_vec.^params.Alpha_taun));

  Beta(tau_norm_vec<params.tau_cutoff)=params.beta2;
  Alpha(tau_norm_vec<params.tau_cutoff)=params.alpha2;
  X_tau = Beta .* tau_norm_vec.^Alpha;

end
