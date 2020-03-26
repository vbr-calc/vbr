function buildProjectDirectories()
  % build file tree for this project
  p=mfilename('fullpath'); % full path of this file without extension
  [filepath,name,ext] = fileparts([p,'.m']);
  this_dir=filepath; % remove filename from fullpath

  dirs_to_check={'../data','../data/plate_VBR'};

  for dir_i = 1:numel(dirs_to_check)
      dir = dirs_to_check{dir_i};
      dir = [this_dir,'/',dir];
      if ~exist(dir,'dir')
          mkdir(dir);
      end
  end

end
