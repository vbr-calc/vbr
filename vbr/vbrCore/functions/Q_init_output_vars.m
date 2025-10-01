function [J1, J2, Qinv, Ma, Va] = Q_init_output_vars(SV_size, n_freq)
  % frequency dependent vars
  J1 = proc_add_freq_indeces(zeros(SV_size),n_freq);
  J2 = J1; Qinv = J1; Ma = J1; Va = J1;
end