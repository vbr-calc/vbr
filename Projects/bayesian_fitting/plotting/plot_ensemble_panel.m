function ax = plot_ensemble_panel(ax,EnsemblePDF,locs,names,location_colors,iplt,titlename,linesty)
  if ax == 0 
      if iplt == 0 
         ax = subplot(1,1,1);
      else 
         ax = subplot(1,2,iplt);
      end 
  end 
  axes(ax)
  title(titlename)
  set(gca,'box','on')
  hold on
  ylabel('Temperature (^\circC)');
  xlabel('Melt Fraction \phi');  
  for il = 1:length(locs)
     locname = names{il};
     PDF=EnsemblePDF.(locname).p_joint;
     [targ_cutoffs,confs,cutoffs] = calculateLevels(PDF,[0.7,0.8,0.9,0.95]);
     szs=fliplr([.75,1.,1.5,2,2.5]);

     T_ax=EnsemblePDF.(locname).post_T;
     phi_ax=EnsemblePDF.(locname).post_phi;
     for icutoff=1:numel(targ_cutoffs)
       levs=[targ_cutoffs(icutoff),targ_cutoffs(icutoff)];
       sz=szs(icutoff);
       this_clr=location_colors{il};
       try         
         contour(phi_ax, T_ax, PDF, levs, 'linewidth', sz,'color',this_clr,'displayname',locname,'linestyle',linesty)
       catch
         contour(phi_ax, T_ax, PDF, levs, 'linewidth', sz,'linecolor',this_clr,'displayname',locname,'linestyle',linesty)
       end
     end
  end
end 

