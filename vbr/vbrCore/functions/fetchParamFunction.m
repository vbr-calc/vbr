function param_func = fetchParamFunction(property)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % param_func = fetchParamFunction(property)
  %
  % fetches the file name of the parameter file for a given property
  %
  % Parameters:
  % ----------
  %  property: string ('elastic','anelastic','viscous','electric')
  %
  % Output:
  % ------
  %  the parameter file name
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  possible = {'elastic'; 'anelastic'; 'viscous'; 'electric'};
  if any(strcmp(possible,property))
    param_func = ['Params_', upper(property(1)), property(2:end)];
  else
    msg = 'Unexpected property type in fetchParamFunction';
    error(msg)
  end
end
