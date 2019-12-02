function mat_out = proc_add_freq_indeces(mat_in,nfreq)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % mat_out = proc_add_freq_indeces(mat_in,nfreq)
  %
  % replicates n-dimensional matrix into new dimension
  %
  % Parameters:
  % ----------
  % mat_in   input matrix
  % nfreq    length to extend mat_in into the new dimension
  %
  % Output:
  % ------
  % mat_out  output matrix
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  sz = size(mat_in); % size of incoming matrix
  if sz(end)==1
     sz = sz(1:end-1); % remove trailing singleton dimensions
  end
  sz = sz > 0; % set all nonzero values to one
  new_indeces = [sz nfreq]; % replicate nfreq times into new dimension
  mat_out = repmat(mat_in,new_indeces) ;

end
