function [VBR] = Q_xfit_mxw(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [VBR]=Q_xfit_mxw(VBR)
  %
  % master curve maxwell scaling
  %
  % references:
  % [1] McCarthy, Takei, Hiraga, 2011 JGR http://dx.doi.org/10.1029/2011JB008384
  % [2] McCarthy and Takei Y, 2011, Geophys. Res. Lett.,
  %     https://doi.org/10.1029/2011GL048776'
  % [3] Takei, 2017 Annu. Rev. Earth Planet. Sci,
  %     https://doi.org/10.1146/annurev-earth-063016-015820
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.anelastic.MTH2011 structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % state variables
  rho_in = VBR.in.SV.rho ;
  if isfield(VBR.in.elastic,'anh_poro')
   Mu_in = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
   Mu_in = VBR.out.elastic.anharmonic.Gu ;
  end
  Ju_in  = 1./Mu_in ;

  % Frequency
  f_vec = VBR.in.SV.f;  % frequency
  period_vec = 1./f_vec ;
  omega_vec = f_vec.*(2*pi) ;
  tau_vec = 1./omega_vec ;

  % The scaling function (maxwell time):
  visc_method=VBR.in.viscous.methods_list{1};
  eta_diff = VBR.out.viscous.(visc_method).diff.eta ; % viscosity for maxwell relaxation time
  tau.maxwell = eta_diff./ Mu_in ; % maxwell relaxation time

  % allocation of new matrixes
  n_freq = numel(f_vec);
  sz = size(Mu_in);
  n_th = numel(Mu_in); % total elements

  % frequency dependent vars
  J1 = proc_add_freq_indeces(zeros(sz),n_freq);
  J2 = J1; Q = J1; Qinv = J1; M1 = J1; M2 = J1; M = J1; V = J1;
  f_norm_glob=J1; tau_norm_glob=J1;

  % vectorized rho and Vave
  rho_vec = reshape(rho_in,size(Mu_in(1:n_th)));
  Vave=reshape(zeros(sz),size(Mu_in(1:n_th)));

  % ====================================================
  % LOOP over the DOMAIN of the state variables
  % ====================================================
  for x1 = 1:n_th  % loop using linear index!
    % pull out variables at current index
    tau_mxw = tau.maxwell(x1);
    Ju = Ju_in(x1) ;
    rho = rho_in(x1) ;
    tau_norm = tau_vec ./ tau_mxw ; % vector ./ scalar

    % loop over frequency
    for i=1:n_freq
      i_glob = x1 + (i - 1) * n_th; % the linear index of the arrays with a frequency index
      freq=f_vec(i); % current frequency
      f_norm=tau_mxw*freq; % normalized frequency
      max_tau_norm=1./(2*pi*f_norm); % maximum normalized tau

      tau_norm_f = max_tau_norm;      
      tau_norm_vec_local = logspace(-30,log10(max_tau_norm),100);
      X_tau = Q_xfit_mxw_xfunc(tau_norm_vec_local,VBR.in.anelastic.xfit_mxw) ;

      %FINT1 = trapz(X_tau) ;  %@(taup) (X_tau, taup
      %int1 = Tau_fac.*quad(FINT1, 0, tau_norm_i);
      int1 = trapz(tau_norm_vec_local,X_tau./tau_norm_vec_local) ; % eq 18 of [1]

      J1(i_glob) = Ju.*(1 + int1);

      % XJ2= Q_xfit_mxw_xfunc(J2tau_norm,VBR.in.anelastic.xfit_mxw) ;
      J2(i_glob) = Ju.*((pi/2)*X_tau(end) + tau_norm(i)); % eq 18  of [1]

      % See McCarthy et al, 2011, Appendix B, Eqns B6 !
      % J2_J1_frac=(1+sqrt(1+(J2(i_glob)./J1(i_glob)).^2))/2;
      J2_J1_frac=1;
      Qinv(i_glob) = J2(i_glob)./J1(i_glob).*(J2_J1_frac.^-1);
      Q(i_glob) = 1./Qinv(i_glob);
      M(i_glob) = 1./sqrt(J1(i_glob).^2+J2(i_glob).^2);
      V(i_glob) = sqrt(1./(J1(i_glob)*rho)).*(J2_J1_frac.^(-1/2));

      f_norm_glob(i_glob)=f_norm;
      tau_norm_glob(i_glob)=tau_norm_f;
    end % end loop over frequency
  end % end the loop(s) over spatial dimension(s)

  %% WRITE VBR
  onm='xfit_mxw';
  VBR.out.anelastic.(onm).J1 = J1;
  VBR.out.anelastic.(onm).J2 = J2;
  VBR.out.anelastic.(onm).Q = Q;
  VBR.out.anelastic.(onm).Qinv = Qinv;
  VBR.out.anelastic.(onm).M=M;
  VBR.out.anelastic.(onm).V=V;
  VBR.out.anelastic.(onm).f_norm=f_norm_glob;
  VBR.out.anelastic.(onm).tau_norm=tau_norm_glob;
  VBR.out.anelastic.(onm).tau_M = tau.maxwell;

  % calculate mean velocity along frequency dimension
  VBR.out.anelastic.(onm).Vave = Q_aveVoverf(V,VBR.in.SV.f);

end
