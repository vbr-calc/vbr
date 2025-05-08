function [VBR] = visc_calc_backstress_linear(VBR)

    params = VBR.in.viscous.backstress_linear; 
    if strcmp(params.G_method, 'fixed') 
        G_GPa = params.G_UR;         
    else         
        G_GPa  = VBR.in.elastic.anharmonic.Gu;         
    end 
    
    disp("calculating viscosity")
    Aprime_T = backstress_Aprime(G_GPa, VBR); % units: 1 / (s GPa^2)    
    sig_ref_T_GPa = backstress_sig_ref_GPa(VBR);    

    sig_p_GPa = params.sig_p_sig_dc_factor * VBR.in.SV.sig_dc_MPa / 1000; 
    
    eta_1 = sig_ref_T_GPa ./ (Aprime_T .* sig_p_GPa.^2);
    eta_1 = eta_1 * 1e9; % Pa s

    VBR.out.viscous.backstress_linear.eta_total = eta_1;     
    disp("done")
end 


function A_prime_T = backstress_Aprime(G_GPa, VBR)
    % units will be: 1 / (s GPa^2)

    % parameters for convenience
    params = VBR.in.viscous.backstress_linear;     
    alpha = params.taylor_constant_alpha; 
    bvec_m = params.burgers_vector_nm * 1e-9;
    Q = params.Q_J_per_mol; 
    A = params.A; % m2/s    
    R = 8.31446261815324; % J/mol/K

    % state variables 
    T_K = VBR.in.SV.T_K; 

    % the calculation
    factor = A ./ ((alpha * G_GPa * bvec_m).^2); 

    % units are wrong I think    
    A_prime_0 = 10^6.94 * 1e6; % 1 / (GPa^2 * s)    
    factor = A_prime_0 
    A_prime_T = factor .* exp(-(Q ./ (R * T_K)));     
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
