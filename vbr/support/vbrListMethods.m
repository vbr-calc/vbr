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
    msg = ['DEPRECATION WARNING: vbrListMethods has been renamed to VBR_list_methods',
       ' vbrListMethods will be removed soon from ',
       'future version of the VBRc. Use VBR_list_methods to silence ',
       'this warning.'];
    disp(msg)
    if exist('single_prop', 'var')
        VBR_list_methods(single_prop)
    else
        VBR_list_methods()
    end 
end 