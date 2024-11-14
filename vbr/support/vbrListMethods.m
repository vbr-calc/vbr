function vbrListMethods(single_prop)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % vbrListMethods
  %
  % DEPRECATED FUNCTION: This function is has been renamed to 
  %     VBR_list_methods() and vbrListMethods will be removed in a 
  %     future version of the VBRc.
  %
  % 
  % prints available methods by property to screen
  %
  % Parameters:
  % -----------
  % single_prop: optional string, must be in 'anelastic', 'elastic' or 'viscous'
  %
  % vbrListMethods() will print all methods
  % vbrListMethods('viscous') will print only viscous methods 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    print_func_deprecation_warning('vbrListMethods', 'VBR_list_methods', 'renamed');
    if exist('single_prop', 'var')
        VBR_list_methods(single_prop)
    else
        VBR_list_methods()
    end 
end 