function VBR_list_methods(single_prop)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % VBR_list_methods
  %
  % prints available methods by property to screen
  %
  % Parameters:
  % -----------
  % single_prop: optional string, must be in 'anelastic', 'elastic' or 'viscous'
  %
  % VBR_list_methods() will print all methods
  % VBR_list_methods('viscous') will print only viscous methods 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  param_types={'anelastic';'elastic';'viscous';'electric'};
  if exist('single_prop', 'var')
    param_type=lower(single_prop);
    if any(strcmp(param_types,param_type))
      param_types={param_type};
    else
      disp(['provided property type, ',single_prop,' does not exist.'])
      disp(['possible types are:'])
      for iM = 1:numel(param_types)
        disp(['    ',param_types{iM}]);
      end
    end
  end

  for iP = 1:numel(param_types)
    property=param_types{iP};
    param_func=fetchParamFunction(property);
    params=feval(param_func,'');
    disp('')
    disp(['available ',property,' methods:'])
    for iM = 1:numel(params.possible_methods)
      disp(['    ',params.possible_methods{iM}]);
    end
  end
  disp('')
end