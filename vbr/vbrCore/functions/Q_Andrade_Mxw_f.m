function [VBR]=Q_Andrade_Mxw_f(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR]=Q_Andrade_Mxw_f(VBR)
  %
  % Andrade Model scaled by Maxwell time, based on Bunton thesis.
  % References:
  % [1] Joseph Bunton's Thesis (Reid Cooper advisor)
  % [2] Sundberg and Cooper, 2010, Philosophical Magazine
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, now with VBR.out.anelastic.AndradePsP structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Bringing in mechanical properties
  % Modulus:
  if isfield(VBR.in.elastic,'anh_poro')
    Mu_in = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
    Mu_in = VBR.out.elastic.anharmonic.Gu ;
  end
  % Steady state viscosity (diffusion creep)
  if isfield(VBR.in.viscous,'LH2011')
    eta_ss_in = VBR.out.viscous.LH2011.diff.eta ;
  elseif isfield(VBR.in.viscous,'HK2003')
    eta_ss_in = VBR.out.viscous.HK2003.diff.eta ;
  end

  % =====================================================
  % State vars (only for local calculation of eta_ss).
  T_K = VBR.in.SV.T_K ;
  dg_um = VBR.in.SV.dg_um ;
  R = 8.314 ;
  eta0_local = 1.2e-11; % VBR.in.anelastic.andrade_mxw.eta0_local ; % no idea !
  p = 2.2 ;% add this to params file !
  U_local = 629e3 ; %[J/mol] % add this to params file !
  R = 8.314 ;  % J / mol. K
  eta_ss_local = eta0_local.*dg_um.^p.*exp(U_local./R./T_K) ;

  rho_in = VBR.in.SV.rho ;
  f_vec = VBR.in.SV.f;  % frequency [this, however, is not a mat -- is a 1D vector]
  w_vec = 2*pi.*f_vec ; % angular frequency
  Tau0_vec = 1./f_vec ; % period
  % =====================================================

  % Andrade parameters, set in params file
  alf = VBR.in.anelastic.andrade_mxw.alf  ; % andrade exponent

  % allocation of Qstruct and V
  n_freq = numel(f_vec);
  sz = size(Mu_in);

  % frequency dependent vars
  J1 = proc_add_freq_indeces(zeros(sz),n_freq);
  J2 = J1; Qa = J1; Qinv = J1; Ma = J1; Va = J1;
  %J1_gbs = J1; J2_gbs = J1; Q_gbs = J1; M_gbs = J1;
  %J1_comp = J1; J2_comp = J1; Q_comp = J1; M_comp = J1; Va_comp = J1;

  % vectorized rho
  n_th = numel(Mu_in); % total elements
  rho_vec = reshape(rho_in,size(Ma(1:n_th)));

  %% =============================
  %% calculate material properties
  %% =============================
  %eta_ss = eta_ss_in ;
  eta_ss = eta_ss_local;
  %eta_ss = 2*eta_ss ;

  Mu_in = 0.65.*Mu_in ; % compliance
  Ju_in = 1./Mu_in ;

  % Andrade beta factor (transient creep)
  % Bunton's scaling, based on Raj model for transient diffusion creep:
  BetaA = (1/alf).*(eta_ss.^(-alf)).*(Mu_in./3).^(alf-1) ;
  BetaA = 0.5*BetaA ; % when eta_ss = 2*eta_ss ; and Mu_in = 0.65.*Mu_in
  %BetaA = 0.7*BetaA



  % loop over frequency
  for i_f = 1:n_freq
    w = w_vec(i_f) ;
    % get linear index of J1, J2, etc.
    ig1 = 1+(i_f - 1) * n_th; % the first linear index in current frequency
    ig2 = (ig1-1)+ n_th; % the last linear index in current frequency

    % pure andrade model
    J1(ig1:ig2) = Ju_in + BetaA.*gamma(1+alf).*w^(-alf)*cos(alf*pi/2)  ;
    J2(ig1:ig2) =  1./(w.*eta_ss) + BetaA.*gamma(1+alf)*w^(-alf)*sin(alf*pi/2) ; %why a (-) in there before?

    Qa(ig1:ig2) = J1(ig1:ig2)./J2(ig1:ig2) ;
    Qinv(ig1:ig2) = 1./Qa(ig1:ig2);
    Ma(ig1:ig2) = (J1(ig1:ig2).^2 + J2(ig1:ig2).^2).^(-1/2) ;

    % % gbs relaxation bump
    % J1_gbs(ig1:ig2) = Ju_in.*Delta./(1+Tgbs.^2.*w.^2) ;
    % J2_gbs(ig1:ig2) = Ju_in.*Delta.*(w.*Te)./(1+Tgbs.^2.*w.^2) ;
    % Q_gbs(ig1:ig2) = J1_gbs(ig1:ig2)./J2_gbs(ig1:ig2) ;
    % M_gbs(ig1:ig2) = (J1_gbs(ig1:ig2).^2 + J2_gbs(ig1:ig2).^2).^(-1/2) ;
    %
    % % composite
    % J1_comp(ig1:ig2) = J1(ig1:ig2) + J1_gbs(ig1:ig2) ;
    % J2_comp(ig1:ig2) = J2(ig1:ig2) + J2_gbs(ig1:ig2) ;
    % Q_comp(ig1:ig2) = J1_comp(ig1:ig2)./J2_comp(ig1:ig2) ;
    % M_comp(ig1:ig2) = (J1_comp(ig1:ig2).^2 + J2_comp(ig1:ig2).^2).^(-1/2);

    % velocities [m/s]
    Va(ig1:ig2) = sqrt(Ma(ig1:ig2)./rho_vec) ; % andrade Vs [m/s]
    % Va_comp(ig1:ig2) = sqrt(M_comp(ig1:ig2)./rho_vec) ; % composite Vs [m/s]

  end

  % Store output in VBR structure
  VBR.out.anelastic.andrade_mxw.J1 = J1;
  VBR.out.anelastic.andrade_mxw.J2 = J2;
  VBR.out.anelastic.andrade_mxw.Q = Qa;
  VBR.out.anelastic.andrade_mxw.Qinv = Qinv;
  VBR.out.anelastic.andrade_mxw.M=Ma;
  VBR.out.anelastic.andrade_mxw.V=Va;

  % calculate mean velocity along frequency dimension
  VBR.out.anelastic.andrade_mxw.Vave = Q_aveVoverf(Va,f_vec);

end
