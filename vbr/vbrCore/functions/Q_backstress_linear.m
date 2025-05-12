function [VBR] = Q_backstress_linear(VBR)

    params = VBR.in.anelastic.backstress_linear;
    G_GPa = params.G_UR;
    
    % Pressure and temperature derivatives from Abramson et al., 1997 and Isaak, 1992 (9% fayalite)
    P = VBR.in.SV.P_GPa;
    T = VBR.in.SV.T_K;

    % following hein et al, should update anharmonic calculation rather than do this here.    
    % T0 = 273;
    G_GPa = 78    +1.71*P-0.027*P.^2-0.0136 * T;  %GPa, Hashin-Shtrikman bound shear modulus
    K_GPa = 129.4 +4.29*P          -0.018 * T;  %GPa, Hashin-Shtrikman bound bulk modulus
    E_GPa = 9*K_GPa .* G_GPa ./(3*K_GPa+G_GPa);%GPa, Young's modulus 
    
    M_GPa = params.M_GPa;

    omega = 2 * pi * VBR.in.SV.f ; 

    if isfield(VBR.out.viscous, 'backstress_linear')
        eta1 = VBR.out.viscous.backstress_linear.eta_total;
    else
        VBRtemp = visc_calc_xfit_premelt(VBR);
        eta1 = VBRtemp.out.viscous.backstress_linear.eta_total;
    end
    d_nm = VBR.in.SV.dg_um * 1e3; 
    
    % allocation of new matrixes
    n_freq = numel(omega);
    sz = size(VBR.in.SV.T_K);    
    n_th = numel(VBR.in.SV.T_K); % total elements    
    J1 = proc_add_freq_indeces(zeros(sz),n_freq);
    J2 = proc_add_freq_indeces(zeros(sz),n_freq);    
    M = proc_add_freq_indeces(zeros(sz),n_freq);    
    Qinv = proc_add_freq_indeces(zeros(sz),n_freq);

    % initial calulations     
    sig_dc_MPa = VBR.in.SV.sig_dc_MPa; 
    sig_p_MPa = params.sig_p_sig_dc_factor * sig_dc_MPa; 

    hardcoded_G_GPa = 65;
    G_GPa = hardcoded_G_GPa;
    sig_d_MPa = params.Beta .* G_GPa .* params.burgers_vector_nm ./ d_nm;
    E_R_Pa = M_GPa .* (sig_p_MPa + sig_d_MPa) ./ sig_p_MPa * 1e9 ;    
    

    % the main loop over state variables
    for i_sv = 1:n_th
        eta_i = eta1(i_sv);
        E_R_i = E_R_Pa(i_sv); 
        E_U_i = E_GPa(i_sv)*1e9;
        for iw = 1:n_freq
            i_glob = i_sv + (iw - 1) * n_th; % the linear index of the arrays with a frequency index
            E_star_inv = (1 ./ (E_R_i + eta_i .* omega(iw) .* i) + 1 ./ E_U_i);             
            E_star_i = 1 ./ E_star_inv;             
            J1_i(i_glob) = real(E_star_i); 
            J2_i(i_glob) = imag(E_star_i); 
            M(i_glob) = norm(E_star_i); 
            denom = E_R_i.^2 + E_R_i.*E_U_i + eta_i*eta_i*omega(iw)*omega(iw);
            Qinv(i_glob) = eta_i * E_U_i * omega(iw) ./ (denom);             
        end 
    end 
    
    % put it all int he output structure
    out_s = struct();    
    out_s.Qinv = Qinv; 
    out_s.J1 = J1; 
    out_s.J2 = J2;
    out_s.M = M; 

    if isfield(VBR.in.SV, 'rho')
        out_s.V = sqrt(1./(out_s.J1) * VBR.in.SV.rho);        
        out_s.Vave = Q_aveVoverf(out_s.V, VBR.in.SV.f);  
    end 

    out_s.units = Q_method_units(); 
    VBR.out.anelastic.backstress_linear = out_s; 

end 