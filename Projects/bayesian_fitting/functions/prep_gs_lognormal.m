function params = prep_gs_lognormal(params,sweep)
  
  % pull out values, copy to new fields to save 
  gs_mean = params.gs_mean; % this will be in units, [micrometers]
  gs_std = params.gs_std;% non-dimensional! 
  params.gs_mean_units = gs_mean; 
  params.gs_std_units = gs_std; 
  
  % nondimensionalize our mean and calculate in log space 
  gs_params = sweep.gs_params;
  params.gs_mean = log(gs_mean / gs_params.gsref);  
  
end 
