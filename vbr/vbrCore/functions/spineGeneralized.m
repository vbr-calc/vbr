function [VBR,telapsed]=spineGeneralized(VBR,property)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [VBR,telapsed]=spineGeneralized(VBR,property)
%
% a generalized handler for calling the VBR methods for a given property
%
% Input:
%  VBR: The VBR structure
%  property: the property string ('anelastic','elastic','viscous')
%
% Ouput:
%  VBR: The VBR structure with new calculations attached
%  telapsed: elapised time structure with field for each method called
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % set the parameter function, load empty parameters and allowed methods
  param_func=fetchParamFunction(property);
  empty_params=feval(param_func,'');
  possible_methods=empty_params.possible_methods; % list of allowed methods

  % loop over methods set by user
  methods_list=VBR.in.(property).methods_list; % list of methods to use
  telapsed=struct(); % stores elapsed time for each method

  for i_method = 1:numel(methods_list)
    meth=methods_list{i_method}; % the current method
    if any(strcmp(possible_methods,meth))
      telapsed.(meth)=tic;
      VBR = loadThenCallMethod(VBR,property,meth);
      telapsed.(meth)=toc(telapsed.(meth));
    else
      disp('')
      disp('WARNING!!!!!')
      disp(['    ',meth,' is not a valid method for ',property])
      disp('    run vbrListMethods() for valid list')
      disp('')
    end
  end

end
