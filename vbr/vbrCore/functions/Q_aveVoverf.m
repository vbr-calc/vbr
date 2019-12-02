function Vave=Q_aveVoverf(V_f,f_vec)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Q_aveVoverf(V_f)
  %
  % averages velocity matrix over the frequency dimension
  %
  % Parameters:
  % ----------
  % V_f the frequency-dependent velocity matrix
  %
  % Output:
  % ------
  % Vave the frequency-averaged velocity matrix
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if numel(f_vec)==1
    Vave=V_f;
  else
    sz=size(V_f); % total size
    freq_dim=numel(sz); % frequency is last dimension
    Vave=mean(V_f,freq_dim);
  end

end
