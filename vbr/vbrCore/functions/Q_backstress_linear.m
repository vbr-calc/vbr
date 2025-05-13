function [VBR] = Q_backstress_linear(VBR)

    params = VBR.in.anelastic.backstress_linear;    
    
    % Pressure and temperature derivatives from Abramson et al., 1997 and Isaak, 1992 (9% fayalite)
    P = VBR.in.SV.P_GPa;
    T = VBR.in.SV.T_K;

    % following hein et al, should update anharmonic calculation rather than do this here.    
    % T0 = 273;
    G_Pa = VBR.out.elastic.anharmonic.Gu; 
    K_Pa = VBR.out.elastic.anharmonic.Ku;    
    E_GPa = 9*K_Pa .* G_Pa ./(3*K_Pa+G_Pa) / 1e9; % Pa, Young's modulus 
    
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
    V = proc_add_freq_indeces(zeros(sz),n_freq);
    valid_f = proc_add_freq_indeces(zeros(sz),n_freq);
    omega_o = zeros(sz); 

    % initial calulations     
    sig_dc_MPa = VBR.in.SV.sig_dc_MPa; 
    sig_p_MPa = params.sig_p_sig_dc_factor * sig_dc_MPa; 
     
    sig_d_MPa = params.Beta .* (G_Pa / 1e9) .* params.burgers_vector_nm ./ d_nm;
    E_R_Pa = M_GPa .* (sig_p_MPa + sig_d_MPa) ./ sig_p_MPa * 1e9 ;    
    
        
    % the main loop over state variables
    for i_sv = 1:n_th
        eta_i = eta1(i_sv);
        E_R_i = E_R_Pa(i_sv); 
        E_U_i = E_GPa(i_sv)*1e9;
        
        omega_o(i_sv) = sqrt(E_R_i * (E_R_i + E_U_i)) ./ eta_i / 10; 

        for iw = 1:n_freq
            i_glob = i_sv + (iw - 1) * n_th; % the linear index of the arrays with a frequency index
            E_star_inv = (1 ./ (E_R_i + eta_i .* omega(iw) .* i) + 1 ./ E_U_i);             
            E_star_i = 1 ./ E_star_inv;             
            J1(i_glob) = real(E_star_i); 
            J2(i_glob) = imag(E_star_i); 
            M(i_glob) = norm(E_star_i); 
            denom = E_R_i.^2 + E_R_i.*E_U_i + eta_i*eta_i*omega(iw)*omega(iw);
            Qinv(i_glob) = eta_i * E_U_i * omega(iw) ./ (denom);
            
            V(i_glob) = sqrt(1./(J1(i_glob)) * VBR.in.SV.rho(i_sv));
            valid_f(i_glob) = omega(iw) >= omega_o(i_sv);
        end 
    end 
    
    % put it all int he output structure
    out_s = struct();    
    out_s.Qinv = Qinv; 
    out_s.J1 = J1; 
    out_s.J2 = J2;
    out_s.M = M; 
    out_s.V = V;
    out_s.Vave = Q_aveVoverf(out_s.V, VBR.in.SV.f);  
    out_s.valid_f = valid_f; 
    out_s.omega_o = omega_o(i_sv); 

    out_s.units = Q_method_units(); 
    out_s.units.omega_o = 'rad/s'; 
    out_s.units.valid_f = ''; 
    VBR.out.anelastic.backstress_linear = out_s; 

end 