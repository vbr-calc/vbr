function VBR = CB_019_uppermantle_reference_values()
        
    VBR = struct();
    VBR.in.SV.T_K = linspace(800, 1000, 4);
    sz_T = size(VBR.in.SV.T_K);
    VBR.in.SV.P_GPa = linspace(2, 3, 4);
    VBR.in.SV.rho = 3300 * ones(sz_T);
    VBR.in.SV.phi = 0.01 * ones(sz_T);
    
    VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
    
    VBR.in.elastic.anharmonic.reference_scaling = 'upper_mantle';
    VBR = VBR_spine(VBR);
  
end