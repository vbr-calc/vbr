function plot_combo_ensembles(ensemble_files,locs,names,location_colors) 
  % e.g., 
  % locs = [40.7, -117.5; 39, -109.8; 37.2, -100.9];
  % names = {'BasinRange', 'ColoradoPlateau', 'Interior'};
  % location_colors={[1,0.6,0];[0,0.8,0];[0,0.3,0]};
  % ens_fils = {'gsLogNormal_1cm_ensembles.mat';'gsLogNormal_1mm_ensembles.mat'};
  % plot_combo_ensembles(ens_fils,locs,names,location_colors)
  
  % load them in! 
  flds_to_cp = {'EnsemblePDF';'RegionalFits';'EnsemblePDF_no_mxw'};
  for i_fi = 1:numel(ensemble_files)
    the_fi = ensemble_files{i_fi};
    load(['./data/',the_fi,'.mat'],'AllEnsemble')    
    Ens.(the_fi) = struct(); 
    for i_fld = 1:numel(flds_to_cp)
      flnm = flds_to_cp{i_fld}; 
      Ens.(the_fi).(flnm) = AllEnsemble.(flnm); 
    end 
  end 
  
  % plot the Ensembles (multiple regions, ensemble of Q methods)
  line_styles = {'-';'--'};
  
  for i_fi = 1:numel(ensemble_files)
    the_fi = ensemble_files{i_fi};
    if i_fi == 1 
      f_en = 0 ; ax1 = 0; ax2 = 0;
      f_en1 = 0 ; ax11 = 0; ax21 = 0;
      f_en2 = 0 ; ax12 = 0; ax22 = 0;
    end 
    lsty = line_styles{i_fi}; 
    E_pdf = Ens.(the_fi).EnsemblePDF;
    E_pdf_nomx = Ens.(the_fi).EnsemblePDF_no_mxw;
    fname_prefix = 'comboEnsemble';
    [f_en,ax1,ax2]= plot_EnsemblePDFs(E_pdf,E_pdf_nomx,locs,names,location_colors,fname_prefix,f_en,ax1,ax2,lsty,0);  
    fname_prefix = 'comboEnsemble_all';
    [f_en1,ax11,ax21]= plot_EnsemblePDFs(E_pdf,0,locs,names,location_colors,fname_prefix,f_en1,ax11,ax21,lsty,0);  
    fname_prefix = 'comboEnsemble_no_mxw';
    [f_en2,ax12,ax22]= plot_EnsemblePDFs(E_pdf_nomx,0,locs,names,location_colors,fname_prefix,f_en2,ax12,ax22,lsty,0);  
  end 
  close all 
  
  
  ff = figure('position', [400, 200, 800, 400],'color', 'w','paperunits',...
              'inches','paperposition',[0,0,8,3]);
  for i_fi = 1:numel(ensemble_files)
    the_fi = ensemble_files{i_fi};
    E_pdf = Ens.(the_fi).EnsemblePDF;
    titlename = the_fi; 
    lsty = line_styles{i_fi};
    ax = subplot(1,numel(ensemble_files),i_fi); 
    ax = plot_ensemble_panel(ax,E_pdf,locs,names,location_colors,i_fi,titlename,lsty);
  end 
  saveas(ff, ['./plots/','combo_ensemble_fits_by_prior.eps'],'epsc');
  saveas(ff, ['./plots/','combo_ensemble_fits_by_prior.png'],'png');
  
  
  % plot regional fits (multiple regions, single Q method per panel)
  fname_prefix = 'comboRegion';
  for i_fi = 1:numel(ensemble_files)
    the_fi = ensemble_files{i_fi};
    if i_fi == 1 
      f_R = 0 ; ax_struct = 0; 
    end 
    lsty = line_styles{i_fi};
    RegFt = Ens.(the_fi).RegionalFits; 
    [f_R,ax_struct] = plot_RegionalFits(RegFt,locs,names,location_colors,fname_prefix,f_R,ax_struct,lsty);
  end 
  close all 
end 
