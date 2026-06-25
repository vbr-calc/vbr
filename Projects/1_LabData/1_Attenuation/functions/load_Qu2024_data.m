function data = load_Qu2024_data()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loads data if available
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dataDir = getenv('vbrPublicData');

    fi = [dataDir, filesep, 'Qu_etal_2024', filesep, 'Qu_2024_data.mat'];
    if exist(fi,'file')
      disp(['found Qu et al 2024 file at:', fi])
      data = load(fi);
    else
      msg = ['Qu et al 2024 data not found. ', ...
             'Clone https://github.com/vbr-calc/vbrPublicData (outside the vbr repo dir) ',...
             ' and set the vbrPublicData environment variable to point to /the/path/to/vbrPublicData'];
      disp(msg)
      data = struct();
    end
  end
  