function plot_EnsemblePDFs(EnsemblePDF,EnsemblePDF_no_mxw,locs,names,location_colors,fname_prefix)

  % plot ensemble PDFs
  disp('building ensemble plots')
  f_en = figure('color', 'w','paperunits','inches','paperposition',[0,0,6,3]);  
  ax1 = plot_panel(EnsemblePDF,locs,names,location_colors,1,'Full Ensemble');
  ax2 = plot_panel(EnsemblePDF_no_mxw,locs,names,location_colors,2,'Excluding xfit\_mxw');

  disp('    saving ensemble plots to plots/')
  saveas(f_en, ['plots/',fname_prefix,'_ensemble_fits.eps'],'epsc');
  saveas(f_en, ['plots/',fname_prefix,'_ensemble_fits.png'],'png');
  close all

end

function ax = plot_panel(EnsemblePDF,locs,names,location_colors,iplt,titlename)
  ax = subplot(1,2,iplt);
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
         contour(phi_ax, T_ax, PDF, levs, 'linewidth', sz,'color',this_clr,'displayname',locname)
       catch
         contour(phi_ax, T_ax, PDF, levs, 'linewidth', sz,'linecolor',this_clr,'displayname',locname)
       end
     end
  end
end 
