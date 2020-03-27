function plot_RegionalFits(RegionalFits,locs,names,location_colors)

  f = figure('color', 'w');

  % initial plots
  meth_order={'andrade_psp';'eburgers_psp';'xfit_mxw';'xfit_premelt'};
  for i_meth = 1:numel(meth_order);
    q_method=meth_order{i_meth};
    subplot(2,2,i_meth)
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
          contour(post_phi,post_T, p_joint, levs, 'linewidth', sz,'color',this_clr,'displayname',locname)
        catch
          contour(post_phi,post_T, p_joint, levs, 'linewidth', sz,'linecolor',this_clr,'displayname',locname)
        end
      end
    end

    title(strrep(q_method, '_', ' '));

  end

  % pretty them up
  subplot(2,2,1);
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


  subplot(2,2,2);
    set(gca,xlabelname,{},ylabelname,{},'box','on')

  subplot(2,2,3);
    ylabel('Temperature (^\circC)');
    xlabel('Melt Fraction \phi');
    set(gca,'box','on')

  subplot(2,2,4);
    ylabel('Temperature (^\circC)');
    xlabel('Melt Fraction \phi');
    set(gca,ylabelname,{},'box','on')

  disp('    saving regional fits to plots/')
  saveas(f, ['plots/regional_fits.eps'],'epsc');
  saveas(f, ['plots/regional_fits.png'],'png');
  close all

end
