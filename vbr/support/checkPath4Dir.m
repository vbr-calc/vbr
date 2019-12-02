function folder_in_path=checkPath4Dir(folder_to_search_for)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % folder_in_path=checkPath(folder_to_search_for)
  %
  % Parameters
  % ----------
  %   folder_to_search_for   string, the folder to check
  %
  % Output
  % ----------
  %   folder_int_path    1 if in path, 0 if not in path
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % create a cell array with each folder as a cell
  p_array=strsplit(path(),pathsep);

  % search the cell array for your folder_to_search_for
  if any(strcmp(p_array,folder_to_search_for))
     folder_in_path=1;
  else
     folder_in_path=0;
  end
end
