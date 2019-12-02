function vbr_init(varargin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % vbr_init(varargin)
  %
  % adds all relevant VBR paths to the matlab path
  %
  % if within the vbr top level directory, just call:
  %   vbr_init
  %
  % if elsewhere (or within scripts), you need to add the path to the top level
  % vbr directory first:
  %   addpath('/path/to/vbr')
  %   vbr_init
  %
  % Parameters
  % ----------
  % optional keyword-value pair inputs:
  %   'forwardModel','ThermalEvolution_1d'  to use a thermal model other than
  %   the default, e.g., vbr_init('forwardModel','ThermalEvolution_1d')
  %
  % Output
  % ------
  % Some screen printing, but just sets paths
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define available versions, defaults
  ValidOpts=struct();
  ValidOpts.forwardModel={'ThermalEvolution_1d','none'};
  Options=struct('forwardModel',ValidOpts.forwardModel{1});

% get full path to vbr, regardless of where vbr_init is called from
  p=mfilename('fullpath'); % full path of vbr_init without extension
  [filepath,name,ext] = fileparts([p,'.m']);
  vbr_dir=filepath; % remove filename from fullpath

% add the vbr/support directory and validate input options
  addpath(genpath(fullfile(vbr_dir,'vbr','support')));
  Options=validateStructOpts('vbr_init',varargin,Options,ValidOpts);

% collect all the subdirectories under ./vbr/ to add
  subDirs2add={'vbrCore';'fitting'};
  success=1;
  for i_fo = 1:numel(subDirs2add)
    fo=subDirs2add{i_fo};
    path2add=fullfile(vbr_dir,'vbr',fo);
    if exist(path2add,'dir')
     addpath(genpath(path2add));
    else
      disp('Warning, vbr path is missing:')
      disp(path2add)
      success=0;
    end
  end

  if success
   disp('VBR calculator added to working path');
  else
   disp('WARNING: VBR calculator (or its components) is not in path')
  end

  if ~strcmp(lower(Options.forwardModel),'none')
    path2add=fullfile(vbr_dir,'vbr','forwardModels',Options.forwardModel);
    if exist(path2add,'dir')
      addpath(genpath(path2add));
    else
      disp('Forward Model path does not exist, no forward model at this path:')
      disp(path2add)
      disp('Path is case sensitive.')
    end
  end

end
