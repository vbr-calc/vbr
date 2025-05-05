function [VBR] = visc_calc_backstress_linear(VBR)

    params = VBR.in.viscous.backstress_linear; 
    if strcmp(params.G_method, 'fixed') 
        G_GPa = params.G_UR;         
    else         
        G_GPa  = VBR.in.elastic.anharmonic.Gu;         
    end 
    

    
    Aprime_T = backstress_Aprime(G_GPa, VBR); 
    % Aprime units = (units(taylor_constant_alpha) * GPa * m) ^ -2
    sig_ref_T_GPa = backstress_sig_ref_GPa(VBR);

    sig_p_GPa = params.sig_p_sig_dc_factor * VBR.in.SV.sig_dc_MPa * 1e9; 
    
    eta_1 = sig_ref_T_GPa ./ (Aprime_T .* sig_p_GPa.^2);
    eta_1 = eta_1 * 1e9; 

    VBR.out.viscous.backstress_linear.eta_total = eta_1; 
    
    
end 


function A_prime_T = backstress_Aprime(G_GPa, VBR)
    % units will be (units(taylor_constant_alpha) * GPa * m) ^ -2


    % parameters for convenience
    params = VBR.in.viscous.backstress_linear;     
    alpha = params.taylor_constant_alpha; 
    bvec = params.burgers_vector_nm * 1e-9;
    Q = params.Q_J_per_mol; 
    V = params.V; 
    R = 8.31446261815324; % J/mol/K

    % state variables 
    if isfield(VBR.in.SV, 'P_GPa')
        P_Pa = 1e9.*(VBR.in.SV.P_GPa) ; % [GPa] to [Pa]
    else 
        P_Pa = 0.0; 
    end 
    T_K = VBR.in.SV.T_K; 

    % the calculation
    factor = 1./((alpha * G_GPa * bvec).^2);         
    A_prime_T = factor .* exp(-((Q+P_Pa*V )./ (R * T_K)));     
end 

function sig_ref_T_GPa = backstress_sig_ref_GPa(VBR)

    % parameters for convenience
    params = VBR.in.viscous.backstress_linear;             
    R = 8.31446261815324; % J/mol/K
    BigSigma = params.pierls_barrier_GPa; 
    dF = params.Q_J_per_mol; 
    T_K = VBR.in.SV.T_K;     
    
    sig_ref_T_GPa = BigSigma .* R .* T_K ./ dF; 
end 
