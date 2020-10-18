function [f,ax_struct] = plot_RegionalFits(RegionalFits,locs,names,location_colors,fname_prefix,f,ax_struct,linesty)

  if f == 0
    f = figure('color', 'w');
    ax_struct = struct() ;
  end 
  
  if linesty == 0 
    linesty = '-';
  end 

  % initial plots
  meth_order={'andrade_psp';'eburgers_psp';'xfit_mxw';'xfit_premelt'};
  for i_meth = 1:numel(meth_order);
    q_method=meth_order{i_meth};
    
    if isfield(ax_struct,q_method) == 0 
      ax_struct.(q_method) = subplot(2,2,i_meth);
    end 
    axes(ax_struct.(q_method))
    hold on
    for il = 1:length(locs)
      locname = names{il};
      p_joint=RegionalFits.(q_method).(locname).p_joint;
      post_phi=RegionalFits.(q_method).(locname).phi_post;
      post_T=RegionalFits.(q_method).(locname).T_post;

      [targ_cutoffs,confs,cutoffs] = calculateLevels(p_joint,[0.7,0.8,0.9,0.95]);
      szs=fliplr([.75,1.,1.5,2,2.5]);
      for icutoff=1:numel(targ_cutoffs)
        levs=[targ_cutoffs(icutoff),targ_cutoffs(icutoff)];
        sz=szs(icutoff);
        hold all
        this_clr=location_colors{il};
        try
          contour(post_phi,post_T, p_joint, levs, 'linewidth', sz,'color',this_clr,'displayname',locname,'linestyle',linesty)
        catch
          contour(post_phi,post_T, p_joint, levs, 'linewidth', sz,'linecolor',this_clr,'displayname',locname,'linestyle',linesty)
        end
      end
    end

    title(strrep(q_method, '_', ' '));

  end

  % pretty them up  
  axes(ax_struct.(meth_order{1}))  
  xlabelname='xticklabels';
  ylabelname='yticklabels';
  try
    set(gca,xlabelname,{},'box','on')
  catch
    xlabelname='xticklabel';
    ylabelname='yticklabel';
    set(gca,xlabelname,{},'box','on')
  end
  ylabel('Temperature (^\circC)');

  axes(ax_struct.(meth_order{2}))
  set(gca,xlabelname,{},ylabelname,{},'box','on')

  axes(ax_struct.(meth_order{3}))
  ylabel('Temperature (^\circC)');
  xlabel('Melt Fraction \phi');
  set(gca,'box','on')

  axes(ax_struct.(meth_order{4}))
  ylabel('Temperature (^\circC)');
  xlabel('Melt Fraction \phi');
  set(gca,ylabelname,{},'box','on')

  disp('    saving regional fits to plots/')
  saveas(f, ['plots/',fname_prefix,'_regional_fits.eps'],'epsc');
  saveas(f, ['plots/',fname_prefix,'_regional_fits.png'],'png');
  % close all

end
