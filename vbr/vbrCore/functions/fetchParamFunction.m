function param_func = fetchParamFunction(property)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % param_func = fetchParamFunction(property)
  %
  % fetches the file name of the parameter file for a given property
  %
  % Parameters:
  % ----------
  %  property: string ('elastic','anelastic','viscous')
  %
  % Output:
  % ------
  %  the parameter file name
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if strcmp(property,'elastic')
    param_func='Params_Elastic';
  elseif strcmp(property,'anelastic')
    param_func='Params_Anelastic';
  elseif strcmp(property,'viscous')
    param_func='Params_Viscous';
  end
end
