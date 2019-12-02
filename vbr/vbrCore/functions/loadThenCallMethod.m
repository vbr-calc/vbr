function [VBR] = loadThenCallMethod(VBR,property,meth)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = loadThenCallMethod(VBR,property,param_func,meth)
  %
  % loads the parameters, runs the method
  %
  % Parameters:
  % ----------
  %  VBR: the VBR structure
  %  property: the property string ('anelastic','elastic','viscous')
  %  meth: the method string
  %
  % Output:
  % ------
  %  VBR: modified VBR structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  param_func = fetchParamFunction(property);

  % make sure this property exists
  tree={'in';property};
  [field_exists,missing] = checkStructForField(VBR,tree,0);
  if field_exists==0
    VBR.in.(property)=struct();
  end

  VBR.in.(property).(meth)=loadTheParams(VBR,property,param_func,meth);
  [VBR] = feval(VBR.in.(property).(meth).func_name,VBR);

end


function meth_params = loadTheParams(VBR,property,param_func,meth)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % meth_params=loadTheParams(VBR,property,param_func,meth)
  %
  % loads the parameter file for this property and method, keeps user-defined
  % parameter fields
  %
  % Parameters:
  % ----------
  %  VBR: the VBR structure
  %  property: the property string ('anelastic','elastic','viscous')
  %  param_func: the function to use to pull parameters (e.g., 'Params_Viscous')
  %  meth: the method string
  %
  % Output:
  % ------
  %  meth_params: the parameter structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  meth_params=feval(param_func,meth); % the default values for this property and method
  if isfield(VBR.in.(property),meth)
    % user set parameters, check which they set
    fldz=fieldnames(meth_params); % only propagate param-defined fields
    for ifield=1:numel(fldz)
      if isfield(VBR.in.(property).(meth),fldz{ifield})
        % user set this parameter,keep it!
        meth_params.(fldz{ifield})=VBR.in.(property).(meth).(fldz{ifield});
      end
    end
  end

end
