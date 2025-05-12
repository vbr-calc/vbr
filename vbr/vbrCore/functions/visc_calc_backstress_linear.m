function [VBR] = visc_calc_backstress_linear(VBR)

    params = VBR.in.viscous.backstress_linear; 
            
    Aprime_T = backstress_Aprime(VBR); % units: 1 / (s GPa^2)    
    sig_ref_T_GPa = backstress_sig_ref_GPa(VBR);       

    sig_p_GPa = params.sig_p_sig_dc_factor * VBR.in.SV.sig_dc_MPa / 1000; 
    
    eta_1 = sig_ref_T_GPa ./ (Aprime_T .* sig_p_GPa.^2);
    eta_1 = eta_1 * 1e9; % Pa s

    VBR.out.viscous.backstress_linear.eta_total = eta_1;     
end 


function A_prime_T = backstress_Aprime(VBR)
    % units will be: 1 / (s GPa^2)

    % parameters for convenience
    params = VBR.in.viscous.backstress_linear;    
    Q = params.Q_J_per_mol; 
    A = params.A; % m2/s ? no... MPa−2 s−1   
    R = 8.31446261815324; % J/mol/K

    % state variables 
    T_K = VBR.in.SV.T_K; 

    units_converter =  1e3 * 1e3 ;
    factor = A * units_converter; % MPa-2 s-1 to GPa-2 s -1
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
