function save_ensembles(fig_prefix_dir,AllEnsemble)
  fname = ['./data/',fig_prefix_dir,'_ensembles.mat'];
  try
      save(fname, 'AllEnsemble','-mat7-binary')
  catch ME
      if strcmp(ME.identifier,'MATLAB:badopt')
          save(fname, 'AllEnsemble')
      else
          rethrow(ME)
      end
  end   
end 
