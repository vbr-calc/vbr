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

  if has_solidus
    % state variables
    if isfield(VBR.in.elastic,'anh_poro')
      Gu_in = VBR.out.elastic.anh_poro.Gu;
    elseif isfield(VBR.in.elastic,'anharmonic')
      Gu_in = VBR.out.elastic.anharmonic.Gu;
    end
    Ju_in  = 1./Gu_in ;
    rho = VBR.in.SV.rho ;
    phi = VBR.in.SV.phi ;
    Tn=VBR.in.SV.T_K./VBR.in.SV.Tsolidus_K ; % solidus-normalized temperature
    params=VBR.in.anelastic.xfit_premelt;

    % maxwell time
    [tau_m,VBR]=MaxwellTimes(VBR,Gu_in);

    % calculate the Tn-dependent coefficients, A_p and sig_p
    [A_p,sig_p]=calcApSigp(Tn,phi,params);

    % set other constants
    alpha_B=params.alpha_B;
    A_B=params.A_B;
    tau_pp=params.tau_pp;

    % set up frequency dependence
    period_vec = 1./VBR.in.SV.f ;
    pifac=sqrt(2*pi)/2;

    % frequency dependent vars
    n_freq = numel(VBR.in.SV.f);
    sz = size(Gu_in);
    J1 = proc_add_freq_indeces(zeros(sz),n_freq);
    J2 = J1; V = J1;
    n_SVs=numel(Tn); % total elements in state variables

    % loop over frequencies, calculate J1,J2
    for i = 1:n_freq
      sv_i0=(i-1)*n_SVs + 1; % starting linear index of this freq
      sv_i1=sv_i0+n_SVs-1; % ending linear index of this freq

      p_p=period_vec(i)./(2*pi*tau_m);
      % tau_eta^S= tau_s / (2 pi tau_m);, tau_s = seismic wave period, tau_m = ss maxwell time
      ABppa=A_B*(p_p.^alpha_B);
      lntaupp=log(tau_pp./p_p);

      J1(sv_i0:sv_i1)=Ju_in .* (1 + ABppa/alpha_B+ ...
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

    % calculate mean velocity along frequency dimension
    VBRout.Vave = Q_aveVoverf(VBRout.V,VBR.in.SV.f);

    % store the output structure
    VBR.out.anelastic.xfit_premelt=VBRout;

  end % end of has_solidus check
end

function [A_p,sig_p] = calcApSigp(Tn,phi,params);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [A_p,sig_p] = calcApSigp(Tn,phi,params);
  % Tn-dependent coefficients, A_p and sig_p
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Ap_Tn_pts=params.Ap_Tn_pts;
  sig_p_Tn_pts=params.sig_p_Tn_pts;
  Beta=params.Beta; %
  A_p=zeros(size(Tn));
  A_p(Tn>=Ap_Tn_pts(3))=params.Ap_fac_3+Beta*phi(Tn>=Ap_Tn_pts(3));
  A_p(Tn<Ap_Tn_pts(3))=params.Ap_fac_3;
  A_p(Tn<Ap_Tn_pts(2))=(params.Ap_fac_1 +params.Ap_fac_2*(Tn(Tn<Ap_Tn_pts(2))-Ap_Tn_pts(1)));
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
