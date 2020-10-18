function [f_en,ax1,ax2] = plot_EnsemblePDFs(EnsemblePDF,EnsemblePDF_no_mxw,locs,names,location_colors,fname_prefix,f_en,ax1,ax2,linesty,save_dir)

  % plot ensemble PDFs
  disp('building ensemble plots')
  if f_en == 0 
    f_en = figure('color', 'w','paperunits','inches','paperposition',[0,0,6,3]);  
  end 
  
  if linesty == 0 
    linesty = '-';
  end 
  if isstruct(EnsemblePDF_no_mxw)
      iplt = 1; 
  else
      iplt = 0;
  end 
  ax1 = plot_ensemble_panel(ax1,EnsemblePDF,locs,names,location_colors,iplt,'Full Ensemble',linesty);
  if isstruct(EnsemblePDF_no_mxw)
      ax2 = plot_ensemble_panel(ax2,EnsemblePDF_no_mxw,locs,names,location_colors,2,'Excluding xfit\_mxw',linesty);
  end 
  if save_dir == 0 
    save_dir = 'plots/';
  end 
  disp(['    saving ensemble plots to ',save_dir])
  saveas(f_en, [save_dir,fname_prefix,'_ensemble_fits.eps'],'epsc');
  saveas(f_en, [save_dir,fname_prefix,'_ensemble_fits.png'],'png');
  % close all

end
