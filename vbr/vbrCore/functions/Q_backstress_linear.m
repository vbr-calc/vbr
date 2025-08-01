function [VBR] = Q_backstress_linear(VBR)

    % pull out some parameters
    params = VBR.in.anelastic.backstress_linear;
    if params.print_experimental_message == 1
        disp(params.experimental_message)
    end

    M_GPa = params.M_GPa;

    % pull out state variables
    P = VBR.in.SV.P_GPa;
    T = VBR.in.SV.T_K;
    G_Pa = VBR.out.elastic.anharmonic.Gu;
    K_Pa = VBR.out.elastic.anharmonic.Ku;
    omega = 2 * pi * VBR.in.SV.f ;
    d_nm = VBR.in.SV.dg_um * 1e3;

    % initial calulations
    if isfield(VBR.in.SV, 'sig_dc_MPa') && ~isfield(VBR.in.SV, 'sig_MPa')
        msg = ['!!! Deprecation Warning: sig_dc_MPa will be removed in favor of sig_MPa '...
               '(the same SV.sig_MPa used by other VBRc methods. To silence this '...
               'warning, set sig_MPa and not sig_dc_MPa !!!'];
        disp(msg)
        sig_MPa = VBR.in.SV.sig_dc_MPa;
    elseif isfield(VBR.in.SV, 'sig_dc_MPa') && isfield(VBR.in.SV, 'sig_MPa')
        msg = ['Both sig_dc_MPa and sig_MPa are defined in the SV structure, ' ...
        'using sig_MPa. Only set sig_MPa to silence this warning (sig_dc_MPa is ',...
        'no longer used).'];
        disp(msg)
        sig_MPa = VBR.in.SV.sig_MPa;
    else
        sig_MPa = VBR.in.SV.sig_MPa;
    end

    % initial calculations
    E_GPa = 9*K_Pa .* G_Pa ./(3*K_Pa+G_Pa) / 1e9; % Pa, Young's modulus
    eta1 = visc_calc_backstress_linear(VBR, sig_MPa, params); % Pa s, linear viscosity for dislocation glide


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


    sig_p_MPa = params.sig_p_sig_dc_factor * sig_MPa;

    sig_d_MPa = params.Beta .* (G_Pa / 1e6) .* params.burgers_vector_nm ./ d_nm;
    E_R_Pa = M_GPa .* (sig_p_MPa + sig_d_MPa) ./ sig_p_MPa * 1e9 ;

    % the main loop over state variables
    for i_sv = 1:n_th
        eta_i = eta1(i_sv);
        E_R_i = E_R_Pa(i_sv);
        E_U_i = E_GPa(i_sv)*1e9;
        rho_i = VBR.in.SV.rho(i_sv);

        omega_o(i_sv) = sqrt(E_R_i * (E_R_i + E_U_i)) ./ eta_i / 10;

        for iw = 1:n_freq
            i_glob = i_sv + (iw - 1) * n_th; % the linear index of the arrays with a frequency index
            E_star_inv = (1 ./ (E_R_i + eta_i .* omega(iw) .* i) + 1 ./ E_U_i);
            E_star_i = 1 ./ E_star_inv;

            J1(i_glob) = real(1./E_star_i);
            J2(i_glob) = imag(1./E_star_i);
            M(i_glob) = norm(E_star_i); % relaxed young's modulus

            denom = E_R_i.^2 + E_R_i.*E_U_i + eta_i*eta_i*omega(iw)*omega(iw);
            Qinv(i_glob) = eta_i * E_U_i * omega(iw) ./ (denom);

            % assume no attenuation for bulk modulus, calculate relaxed shear modulus
            % from the relaxed young's modulus
            E_i = M(i_glob);
            G_eff = 3 * K_Pa(i_sv) *  E_i / (9 * K_Pa(i_sv) - E_i);
            % J2_J1_frac=(1+sqrt(1+(J2(i_glob)./J1(i_glob)).^2))/2;
            V(i_glob) = sqrt(G_eff./ rho_i);
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
    out_s.omega_o = omega_o;

    out_s.units = Q_method_units();
    out_s.units.omega_o = 'rad/s';
    out_s.units.valid_f = '';
    VBR.out.anelastic.backstress_linear = out_s;

end


function eta_1 = visc_calc_backstress_linear(VBR,sig_MPa, params)

    Aprime_T = backstress_Aprime(VBR, params); % units: 1 / (s GPa^2)
    sig_ref_T_GPa = backstress_sig_ref_GPa(VBR, params);

    sig_p_GPa = params.sig_p_sig_dc_factor * sig_MPa / 1000;

    eta_1 = sig_ref_T_GPa ./ (Aprime_T .* sig_p_GPa.^2);
    eta_1 = eta_1 * 1e9; % Pa s

end


function A_prime_T = backstress_Aprime(VBR, params)
    % units will be: 1 / (s GPa^2)

    % parameters for convenience

    Q = params.Q_J_per_mol;
    A = params.A; % MPa−2 s−1
    R = 8.31446261815324; % J/mol/K

    % state variables
    T_K = VBR.in.SV.T_K;

    units_converter =  1e3 * 1e3 ;
    factor = A * units_converter; % MPa-2 s-1 to GPa-2 s -1
    A_prime_T = factor .* exp(-(Q ./ (R * T_K)));
end

function sig_ref_T_GPa = backstress_sig_ref_GPa(VBR, params)

    % parameters for convenience
    R = 8.31446261815324; % J/mol/K
    BigSigma = params.pierls_barrier_GPa;
    dF = params.Q_J_per_mol;
    T_K = VBR.in.SV.T_K;

    sig_ref_T_GPa = BigSigma .* R .* T_K ./ dF;
end
