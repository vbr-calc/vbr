function [Box,settings] = BuildBox(settings)

% calculate number of compartments in box
  settings.Box.nvar1=numel(settings.Box.var1range); % store it in external
  nvar1 = settings.Box.nvar1;  % local name for ease of use below
  
% check for second variable  
  if isfield(settings.Box,'var2range')
      settings.Box.nvar2=numel(settings.Box.var2range);
      nvar2 = settings.Box.nvar2;      
  else
       settings.Box.nvar2 = 1;
       nvar2=1; 
  end

% total compartments in box  
  settings.Box.nvars= (nvar1>1) + (nvar2>1);   
  
% organize the box  
  Box = struct(); 
  for ivar1 = 1:nvar1
    for ivar2 = 1:nvar2
      Box(ivar1,ivar2).info.var1range = settings.Box.var1range;
      Box(ivar1,ivar2).info.var1units = settings.Box.var1units;
      Box(ivar1,ivar2).info.var1name = settings.Box.var1name;
      Box(ivar1,ivar2).info.var1val = settings.Box.var1range(ivar1);
      
      if isfield(settings.Box,'var2range')
          Box(ivar1,ivar2).info.var2range = settings.Box.var2range;
          Box(ivar1,ivar2).info.var2units = settings.Box.var2units;
          Box(ivar1,ivar2).info.var2name = settings.Box.var2name;
          Box(ivar1,ivar2).info.var2val = settings.Box.var2range(ivar2);
      else
          Box(ivar1,ivar2).info.var2range = [];
          Box(ivar1,ivar2).info.var2units = '';
          Box(ivar1,ivar2).info.var2name = '';
          Box(ivar1,ivar2).info.var2val = [];
      end
      
    end    
  end

end
