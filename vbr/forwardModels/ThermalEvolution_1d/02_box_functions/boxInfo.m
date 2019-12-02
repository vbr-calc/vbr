function boxInfo(Box)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % boxInfo(Box)
  %
  % displays information about the loaded box
  %
  % Parameters
  % ----------
  % Box    the box of runs (structure array)
  %
  % Output
  % ------
  % none, prints to screen
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if isfield(Box(1).info,'var2name')
    disp(['this Box contains a sweep over ', Box(1).info.var1name,' and ', Box(1).info.var2name ])
    disp('');
    disp(['iBox,',Box(1).info.var1name,Box(1).info.var1units,',',Box(1).info.var2name,Box(1).info.var2units])
  else
    disp(['this Box contains a sweep over ', Box(1).info.var1name ])
    disp('');
    disp(['iBox,',Box(1).info.var1name,Box(1).info.var1units])
  end


  for iBox=1:numel(Box)
    if isfield(Box(1).info,'var2name')
      disp([num2str(iBox),',',num2str(Box(iBox).info.var1val),',',num2str(Box(iBox).info.var2val)])
    else
      disp([num2str(iBox),',',num2str(Box(iBox).info.var1val)])
    end
  end

end
