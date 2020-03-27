function plot_Bayes(posterior, sweep, obs_name, q_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_Bayes(posterior, sweep, obs_name)
%
% Plot the posterior probability distribution across the parameter ranges
% in sweep.
%
% Parameters:
% -----------
%      posterior           (size(sweep.Box)) matrix of posterior
%                          probability for each parameter combination
%
%      sweep               structure with the following fields
%               state_names     cell of the names of the varied parameters
%               [param name]    vector of the range of values that were
%                               calculated
%               Box             output of VBR calculation
%               (also other fields recording values relevant to the
%               calculation)
%
%       obs_name            string of the observation name, e.g. Vs, Qinv
%                           Only used to label the figure.
%       
%       q_method            string of the method to use for calculating
%                           the anelastic effects on seismic properties
%                           Only used to label the figure.
%
% Output:
% -------
%       Plot of the posterior probability distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  figure()
  q_method = strrep(q_method, '_', '\_');
  
  max_val = max(posterior(:));
  i_best = find(posterior(:) == max_val);
  fields = sweep.state_names;
  
  fnames{length(fields)} = '';
  units{length(fields)} = '';
  for n = 1:length(fields)
      switch fields{n}
          case 'T'
              fnames{n} = 'Temperature';
              units{n} = '\circC';
          case 'phi'
              fnames{n} = 'Melt Fraction, \phi';
              units{n} = '';
          case 'gs'
              fnames{n} = 'Grain Size';
              units{n} = 'mm';
              sweep.(fields{n}) = sweep.(fields{n}) ./ 1e3; % convert to mm
      end
  end
  
              
      
  params = make_param_grid(fields, sweep);

  Y = params.(fields{1});
  X = params.(fields{2});
  fields_str = [fields{1}, ', ', fields{2}];

  if length(fields) == 3
      Z = params.(fields{3});
      fields_str = [fields_str ', ', fields{3}];
      xslice = X(i_best);
      yslice = Y(i_best);
      zslice = Z(i_best);
      slice(X, Y, Z, posterior, xslice, yslice, zslice)
      zlabel(fields{3},'FontSize', 14)
      
      title({sprintf('max(p) = %.2g at', max_val); ...
          sprintf('%s = %.2g %s', fnames{2}, X(i_best), units{2}); ...
          sprintf('%s = %.2g %s', fnames{1}, Y(i_best), units{1}); ...
          sprintf('%s = %.2g %s', fnames{3}, Z(i_best), units{3});
          ['using ', q_method]}, 'FontSize', 14)
      
  else
      imagesc(X(1,:), Y(:,1), posterior);
      title({sprintf('max(p) = %.2g at', max_val); ...
          sprintf('%s = %.2g %s', fnames{2}, X(i_best), units{2}); ...
          sprintf('%s = %.2g %s', fnames{1}, Y(i_best), units{1}); ...
          ['using ', q_method]}, 'FontSize', 14)
  end
  
  cblabel = ['P(', fields_str, ' | ', obs_name ')'];
  xlabel(sprintf('%s (%s)', fnames{2}, units{2}),'FontSize', 14)
  ylabel(sprintf('%s (%s)', fnames{1}, units{1}),'FontSize', 14)
  
  hcb = colorbar;
  ylabel(hcb,cblabel,'FontSize', 14)
end