function [VBR] = Q_xfit_premelt(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [VBR] = Q_xfit_premelt(VBR)
  % near-solidus anelastic scaling from [1]
  % Requires the solidus, VBR.in.SV.Tsolidus_K, as an additional state variable
  %
  % references:
  % [1] Yamauchi and Takei, JGR 2016, https://doi.org/10.1002/2016JB013316
  %     particularly Eqs. 13,14,15
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if isfield(VBR.in.SV,'Tsolidus_K')
    has_solidus=1;
  else
    has_solidus=0;
    disp('To use Q_xfit_premelt, you must provide VBR.in.SV.Tsolidus_K')
  end

  params=VBR.in.anelastic.xfit_premelt;

  mu_method = 'anharmonic';
  if has_solidus
    % state variables
    if params.include_direct_melt_effect == 1
        % in YT2024, all poroealstic effects are applied internally to J1, so
        % always use anharmonic as unrelaxed
        Gu_in = VBR.out.elastic.anharmonic.Gu;
    else
        if isfield(VBR.in.elastic,'anh_poro')
          Gu_in = VBR.out.elastic.anh_poro.Gu;
          mu_method = 'anh_poro';
        elseif isfield(VBR.in.elastic,'anharmonic')
          Gu_in = VBR.out.elastic.anharmonic.Gu;
        end
    end

    Ju_in  = 1./Gu_in ;
    rho = VBR.in.SV.rho ;
    phi = VBR.in.SV.phi ;
    Tn=VBR.in.SV.T_K./VBR.in.SV.Tsolidus_K ; % solidus-normalized temperature

    % maxwell time
    [tau_m,VBR]=MaxwellTimes(VBR,Gu_in);

    % calculate the Tn-dependent coefficients, A_p and sig_p
    [A_p,sig_p]=calcApSigp(Tn,phi,params);
    if params.include_direct_melt_effect == 1
      Beta_B = params.Beta_B * phi;
    else
      Beta_B = 0.0;
    end

    % poroelastic J1 effect if applicable
    if params.include_direct_melt_effect == 1
      % poroelastic effect added to J1, Delta_poro
      poro_elastic_factor = params.poro_Lambda * phi;
    else
      % no poroelastic effects outside of incoming unrelaxed modulus
      poro_elastic_factor = 0.0;
    end

    % set other constants
    alpha_B=params.alpha_B;
    A_B_plus_Beta_B= params.A_B + Beta_B;
    tau_pp=params.tau_pp;

    % set up frequency dependence
    period_vec = 1./VBR.in.SV.f ;
    pifac=sqrt(2*pi)/2;

    % frequency dependent vars
    n_freq = numel(VBR.in.SV.f);
    sz = size(Gu_in);
    J1 = proc_add_freq_indeces(zeros(sz),n_freq);
    J2 = J1; V = J1; f_norm_glob=J1;
    n_SVs=numel(Tn); % total elements in state variables

    % loop over frequencies, calculate J1,J2
    for i = 1:n_freq

      sv_i0=(i-1)*n_SVs + 1; % starting linear index of this freq
      sv_i1=sv_i0+n_SVs-1; % ending linear index of this freq
      f_norm_glob(sv_i0:sv_i1)=tau_m*VBR.in.SV.f(i);
      p_p=period_vec(i)./(2*pi*tau_m);
      % tau_eta^S= tau_s / (2 pi tau_m);, tau_s = seismic wave period, tau_m = ss maxwell time
      ABppa=A_B_plus_Beta_B .* (p_p.^alpha_B);
      lntaupp=log(tau_pp./p_p);

      J1(sv_i0:sv_i1)=Ju_in .* (1 + poro_elastic_factor + ABppa/alpha_B+ ...
           pifac*A_p.*sig_p.*(1-erf(lntaupp./(sqrt(2).*sig_p))));
      J2(sv_i0:sv_i1)=Ju_in*pi/2.*(ABppa+A_p.*(exp(-(lntaupp.^2)./(2*sig_p.^2)))) + ...
           Ju_in.*p_p;
    end

    % store and calculate other fields
    VBRout.J1 = J1;
    VBRout.J2 = J2;

    % J2_J1_frac=(1+sqrt(1+(J2./J1).^2))/2;
    J2_J1_frac=1;
    rho_f = proc_add_freq_indeces(rho,n_freq);
    VBRout.V=sqrt(1./(J1.*rho_f)).*(J2_J1_frac.^(-1/2));
    VBRout.M1 = 1./J1;
    VBRout.M2 = 1./J2;
    VBRout.Qinv = J2./J1.*(J2_J1_frac.^-1);
    VBRout.Q = 1./VBRout.Qinv;
    VBRout.M=1./sqrt(J1.^2+J2.^2);
    VBRout.f_norm = f_norm_glob;
    VBRout.tau_M = tau_m;

    % calculate mean velocity along frequency dimension
    VBRout.Vave = Q_aveVoverf(VBRout.V,VBR.in.SV.f);

    VBRout.units = Q_method_units();
    VBRout.units.M1 = 'Pa';
    VBRout.units.M2 = 'Pa';
    VBRout.units.tau_M = "s";
    VBRout.units.f_norm = '';

    % store the output structure
    VBR.out.anelastic.xfit_premelt=VBRout;

    method_settings.mu_method = mu_method;
    VBR.out.anelastic.xfit_premelt.method_settings = method_settings;

    if VBR.in.GlobalSettings.anelastic.include_complex_viscosity == 1
        VBR = complex_viscosity_VBR(VBR, "xfit_premelt");
    end

  end % end of has_solidus check
end

function [A_p,sig_p] = calcApSigp(Tn,phi,params);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [A_p,sig_p] = calcApSigp(Tn,phi,params);
  % Tn-dependent coefficients, A_p and sig_p
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Ap_Tn_pts=params.Ap_Tn_pts;
  sig_p_Tn_pts=params.sig_p_Tn_pts;
  if params.include_direct_melt_effect == 1
      Beta_p = params.Beta; % this depends on melt fraction in YT2024
  else
      Beta_p = 0; % no direct melt dependence
  end
  A_p=zeros(size(Tn));
  A_p(Tn >= Ap_Tn_pts(3))=params.Ap_fac_3+Beta_p*phi(Tn >= Ap_Tn_pts(3));
  A_p(Tn < Ap_Tn_pts(3))=params.Ap_fac_3;
  A_p(Tn < Ap_Tn_pts(2))=params.Ap_fac_1 + params.Ap_fac_2*(Tn(Tn < Ap_Tn_pts(2))-Ap_Tn_pts(1));
  A_p(Tn < Ap_Tn_pts(1))=params.Ap_fac_1;

  sig_p=zeros(size(Tn));
  sig_p(Tn < sig_p_Tn_pts(1))=params.sig_p_fac_1;

  msk=(Tn >= sig_p_Tn_pts(1)) & (Tn < sig_p_Tn_pts(2));
  sig_p(msk)=params.sig_p_fac_1 + params.sig_p_fac_2.*(Tn(msk)-sig_p_Tn_pts(1));
  sig_p(Tn >= sig_p_Tn_pts(2))=params.sig_p_fac_3;
end

function [tau_m,VBR] = MaxwellTimes(VBR,Gu_in)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [tau_m,VBR] = MaxwellTimes(VBR,Gu_in)
  % calculate the maxwell time for all state variables
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  tree={'out';'viscous';'xfit_premelt';'diff';'eta'};
  [field_exists,missing] = checkStructForField(VBR,tree,0);
  if field_exists == 0
    [VBR] = loadThenCallMethod(VBR,'viscous','xfit_premelt');
  end
  eta_diff = VBR.out.viscous.xfit_premelt.diff.eta;
  tau_m=eta_diff./Gu_in;

end
