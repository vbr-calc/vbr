function EnsemblePDF = storeEnsemble(EnsemblePDF,locname,q_method,p_joint,posterior_A,include_mxw)
    if strcmp(q_method,'xfit_mxw') && include_mxw == 0 
        EnsemblePDF  = EnsemblePDF; 
    else 
        if ~isfield(EnsemblePDF,locname)
          EnsemblePDF.(locname).p_joint=p_joint;
          EnsemblePDF.(locname).post_T=posterior_A.T;
          EnsemblePDF.(locname).post_phi=posterior_A.phi;
        else
          EnsemblePDF.(locname).p_joint=EnsemblePDF.(locname).p_joint+p_joint;
        end
    end
end 
