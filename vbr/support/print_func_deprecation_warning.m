function msg = print_func_deprecation_warning(func_old, func_new, dep_type, print_it)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  msg = print_func_deprecation_warning(func_old, func_new, dep_type)
%
%  print a deprecation warning for a function.
%
%  Parameters
%  ----------
%  func_old
%    the name of the old function, string
%  func_new
%    the name of the new function, string
%  dep_type
%    deprecation type, must match one of ['renamed', ]
%  print_it
%    Optional bool, if true (default), will print the message.
%
%  Returns
%  -------
%
%  str
%    the deprecation message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    msg = "";
    if strcmp(dep_type, 'renamed')
        msg = ['\nDEPRECATION WARNING:\n\n', func_old, ' has been renamed to ', ...
               func_new, ' and ' func_old, ...
               ' will be removed in a future version of the VBRc. Use ', ...
               func_new, ' to silence this warning.\n'];
    end

    if (~exist('print_it', 'var'))
        print_it = true;
    end

    if print_it
        fprintf(msg)
    end
end