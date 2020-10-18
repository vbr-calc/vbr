function plot_tradeoffs_posterior(posterior, sweep_in, obs_name, q_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot_tradeoffs_posterior(posterior, sweep, obs_name)
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
%                           the anelastic effects on seismic properties.
%                           Only used to label the figure.
%
% Output:
% -------
%       Plot of the posterior probability distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

q_method = strrep(q_method, '_', '\_');


f = figure('position', [400, 200, 1300, 700], 'color', 'w','paperunits','inches',...
           'paperposition',[0,0,14,6.5]);
posterior = posterior ./ sum(posterior(:));

% Write out names and units
sweep = sweep_in; 
fields = sweep.state_names;
fnames{length(fields)} = '';
fnames_short{length(fields)} = '';
for n = 1:length(fields)
    switch fields{n}
        case 'T'
            fnames{n} = 'Temperature (\circC)';
            fnames_short{n} = 'T';
        case 'phi'
            fnames{n} = 'Melt Fraction, \phi';
            fnames_short{n} = '\phi';
        case 'gs'            
            fnames_short{n} = 'd';
            if strcmp(sweep.gs_params.type,'log')
                sweep.(fields{n}) = log(sweep.(fields{n})/sweep.gs_params.gsref);
                fnames{n} = 'log(Grain Size)';
            else 
                fnames{n} = 'Grain Size (mm)';
                sweep.(fields{n}) = sweep.(fields{n}) ./ 1e3; % convert to mm
            end 
    end
end

sweep.fnames = fnames;

% Plot up panels to show the trade-offs

plot_box(posterior, sweep, 2, 3, 1);
plot_box(posterior, sweep, 1, 3, 2);
plot_box(posterior, sweep, 1, 2, 3);

titstr = '';
for nm = 1:length(fnames_short)
    titstr = [titstr, fnames_short{nm}, ', '];
end
titstr = [titstr(1:end-2), ' | ', obs_name];
tax = axes('position', [0, 0, 1, 1], 'visible', 'off');
text(0.37 - length(obs_name)/300, 0.96,...
    ['p(', titstr, '), using ', q_method], 'fontsize', 16, 'fontweight', 'bold')





end

function plot_box(posterior, sweep, i1, i2, i3)


    xpos = 0.09 + 0.31 * (i3 - 1);
    ax = axes('position', [xpos, 0.47, 0.225, 0.4]);

    sh = size(posterior);
    sh(i3) = 1;

    method=2;

    % Calculate limits for the color scales so all subplots will be on
    % the same scale
    marg_sc = max([...
        max(sum(sum(posterior, 1), 2)), ...
        max(sum(sum(posterior, 2), 3)), ...
        max(sum(sum(posterior, 1), 3))]);

    max_joint = max([...
        max(median(sum(posterior, 1))), ...
        max(median(sum(posterior, 2))), ...
        max(median(sum(posterior, 3))), ...
        ]);


    % the marginal of the var not plotted
    p_marginal = sum(sum(posterior, i1), i2);
    % disp(['sum of p_marginal:',num2str(sum(p_marginal(:)))])

    if method==1
       % For each pair of parameters, plot the joint probability
       % i.e. p(T, phi) = sum_over_g(p(T, phi | g) p(g))
       p_marginal_box = repmat(p_marginal, sh(1), sh(2), sh(3));
       p_joint = sum(posterior .* p_marginal_box, i3);
       joint_sc=max(p_joint(:));
    elseif method==2
       p_joint=sum(posterior,i3); % naive marginal
       p_joint_1=sum(posterior,i1);
       p_joint_2=sum(posterior,i2);
       %joint_sc = max([max(p_joint_1(:)),max(p_joint_2(:)),max(p_joint(:))]);
       joint_sc = max(p_joint(:));
    elseif method==3
       p_marginal_box = repmat(p_marginal, sh(1), sh(2), sh(3));
       p_joint = sum(posterior .* p_marginal_box, i3);
       p_joint = p_joint / sum(p_joint(:));
       joint_sc=max(p_joint(:));
    end
    % disp(['sum of p_joint after marginal:',num2str(sum(p_joint(:)))])

    % check if grain size is one and if we are logging it 
    if strcmp(sweep.gs_params.type,'log') 
      gs_unlogged = [0.0001, 0.001, 0.01]*1e6;% labels we want 
      gs_logged = log(gs_unlogged/sweep.gs_params.gsref); % where we want them 
      gs_unlogged = gs_unlogged/1e6*1e3; % the labels we want in mm
      gs_label = 'Grain Size (mm)'; 
      log_the_x = 0 ;
      log_the_y = 0 ;
      log_the_x2 = 0;
      if strcmp(sweep.state_names{i2},'gs') 
            log_the_x = 1 ;
      elseif strcmp(sweep.state_names{i1},'gs')             
            log_the_y = 1;    
      elseif strcmp(sweep.state_names{i3},'gs')
            log_the_x2 = 1;    
      end
    end 
    
    % 2D plot of p(var1,var2|measurement)
    imagesc(sweep.(sweep.state_names{i2}), sweep.(sweep.state_names{i1}), ...
        reshape(p_joint, sh(i1), sh(i2)));
 
    xlabel(sweep.fnames{i2})
    ylabel(sweep.fnames{i1});
    set(ax, 'ydir', 'normal')
    originalSize1 = get(ax,'Position'); 
    caxis([0, joint_sc])
    colorbar
    
    set(ax, 'Position', originalSize1); 
    if log_the_x || log_the_y 
      ax_extra= axes('Position', get(ax, 'Position'),'Color', 'none');
      set(ax,'Box','off')
      set(ax_extra, 'XAxisLocation', 'top','YAxisLocation','Right');
      set(ax_extra, 'XLim', get(ax, 'XLim'),'YLim', get(ax, 'YLim'));          
      if log_the_x
      % add second axis on top 
        set(ax_extra,'Xtick',gs_logged,'XtickLabel',gs_unlogged)      
        set(ax_extra,'Ytick',[],'YtickLabel',[])
        axes(ax_extra);
        xlabel(gs_label)
      elseif log_the_y
      % add second axis on right
        set(ax_extra,'Ytick',gs_logged,'YtickLabel',gs_unlogged)
        set(ax_extra,'Xtick',[],'XtickLabel',[])
        axes(ax_extra);
        ylabel(gs_label)
      end 
      set(ax_extra, 'Position', originalSize1); 
    end 
    
 

    % 1D marginal
    ax2 = axes('position', [xpos, 0.3, 0.225, 0.05]);
    plot(reshape(sweep.(sweep.state_names{i3}), 1, []), ...
        reshape(p_marginal, 1, []))
   
    %set(ax2, 'color', 'none', 'ycolor', 'none', 'box', 'off');
    xlabel(sweep.fnames{i3});
    ylim([0, marg_sc])
    
     if log_the_x2 
       % add the second x axis on top         
      ax_extra2= axes('Position', get(ax2, 'Position'),'Color', 'none');
      set(ax2,'Box','off')
      set(ax_extra2, 'XAxisLocation', 'top','YAxisLocation','Right');
      set(ax_extra2, 'XLim', get(ax2, 'XLim'),'YLim', get(ax2, 'YLim'));  
      set(ax_extra2,'Xtick',gs_logged,'XtickLabel',gs_unlogged)        
      set(ax_extra2, 'Ytick', get(ax2, 'Ytick'),'YtickLabel',[]);
      axes(ax_extra2)
      xlabel(gs_label);
    end 


    % the depth plot
    ax3 = axes('position', [xpos, 0.1, 0.225, 0.05]);
    patch(sweep.P_GPa(sweep.z_inds([1, end, end, 1, 1])), [0, 0, 1, 1, 0], 'b');
    xlim(sweep.P_GPa([1, end]))
    try
      set(ax3, 'color', 'none', 'ycolor', 'none', 'box', 'off', ...
          'xaxislocation', 'top');
    catch
      set(ax3, 'box', 'off','xaxislocation', 'top');
    end
    xlabel('Pressure (GPa)');
    ax4 = axes('position', [xpos, 0.1, 0.225, 0.01]);
    plot_z = zeros(size(sweep.P_GPa));
    plot(sweep.z./1000, plot_z, 'linestyle', 'none')
    try
      set(ax4, 'color', 'none', 'ycolor', 'none', 'box', 'off');
    catch
      set(ax4, 'box', 'off');
    end
    xlabel('Depth (km)')


end
