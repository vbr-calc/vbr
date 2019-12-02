function [VBR] = Q_eBurgers_f(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = Q_eBurgers_f(VBR)
  %
  % extended burgers model after JF2010
  %
  % reference:
  % Jackson & Faul, "Grainsize-sensitive viscoelastic relaxation in
  % olivine: Towards a robust laboratory-based model for seismological
  % application," Physics of the Earth and Planetary Interiors 183 (2010) 151–163
  %
  % includes high temperature background, optional dissipation peak.
  % see Projects/vbr_core_examples/CB_test_tmep.m for using with/without peak
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with new VBR.out.anelastic.eburgers_psp structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % angular frequency
  f_vec = VBR.in.SV.f ;
  w_vec = 2*pi.*f_vec ;

  % unrelaxed compliance and density
  if isfield(VBR.in.elastic,'anh_poro')
   Mu = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
   Mu = VBR.out.elastic.anharmonic.Gu ;
  end
  Ju_mat = 1./Mu ;
  rho_mat = VBR.in.SV.rho ; % density

  % allocation (frequency is added as a new dimension at end of array.)
  nfreq = numel(f_vec);
  J1 = proc_add_freq_indeces(zeros(size(Ju_mat)),nfreq);
  J2 = J1; Q = J1; Qinv = J1; M = J1; V = J1;
  sz=size(Ju_mat);

  % Calculate maxwell time, integration limits and location of peak:
  % tau=MaxwellTimes(VBR,Mu);
  tau=Q_eBurgers_mxwll(VBR,Mu);

  % Read in parameters needed for integration
  Burger_params=VBR.in.anelastic.eburgers_psp;
  bType=Burger_params.eBurgerFit;
  alf = Burger_params.(bType).alf ;
  DeltaB = Burger_params.(bType).DeltaB ; % relaxation strength of background
  DeltaP=Burger_params.(bType).DeltaP; % relaxation strength of peak
  sig=Burger_params.(bType).sig;
  HTB_int_meth=Burger_params.integration_method ; % (trapezoidal, 0; quadrature, 1)
  ntau = Burger_params.tau_integration_points ;

  if DeltaP>0
    orig_state = warning;
    warning('off','all'); % suppress quadgk warning
  end

  % ============================================================================
  % loop over state varialbes, calculate anelatic effects at every frquency
  % ============================================================================

  n_th = numel(Ju_mat); % number of thermodynamic states
  for x1 = 1:n_th;

    Ju = Ju_mat(x1) ; % unrelaxed compliance
    rho = rho_mat(x1) ; % density

    % maxwell times
    Tau_M = tau.maxwell(x1);
    Tau_L = tau.L(x1);
    Tau_H = tau.H(x1);
    Tau_P = tau.P(x1);
    if HTB_int_meth == 0
      Tau_X_vec = logspace(log10(Tau_L),log10(Tau_H),ntau) ;
    end

    % loop over frequency
    for i=1:nfreq
      i_glob = x1 + (i - 1) * n_th; % the linear index of the arrays with a frequency index
      w = w_vec(i);

      if HTB_int_meth==0 %% trapezoidal integration --
          D_vec = (alf.*Tau_X_vec.^(alf-1))./(Tau_H^alf - Tau_L^alf);

          int_J1 = trapz(Tau_X_vec,(D_vec./(1+w^2.*Tau_X_vec.^2)));
          J1(i_glob) = (1+DeltaB.*int_J1);

          int_J2 = trapz(Tau_X_vec,((Tau_X_vec.*D_vec)./(1+w^2.*Tau_X_vec.^2)));
          J2(i_glob) = (w*DeltaB*int_J2 + 1/(w*Tau_M));

      elseif HTB_int_meth==1 % use quadl

          Tau_fac = alf.*DeltaB./(Tau_H.^alf - Tau_L.^alf);

          FINT1 = @(x) (x.^(alf-1))./(1+(w.*x).^2);
          int1 = Tau_fac.*quadl(FINT1, Tau_L, Tau_H);

          FINT2 = @(x) (x.^alf)./(1+(w.*x).^2);
          int2 = w.*Tau_fac.*quadl(FINT2, Tau_L, Tau_H);

          J1(i_glob) = (1 + int1);
          J2(i_glob) = (int2 + 1./(w.*Tau_M));
        elseif HTB_int_meth==2 % use quadgk
            Tau_fac = alf.*DeltaB./(Tau_H.^alf - Tau_L.^alf);

            FINT1 = @(x) (x.^(alf-1))./(1+(w.*x).^2);
            int1 = Tau_fac.*quadgk(FINT1, Tau_L, Tau_H);

            FINT2 = @(x) (x.^alf)./(1+(w.*x).^2);
            int2 = w.*Tau_fac.*quadgk(FINT2, Tau_L, Tau_H);

            J1(i_glob) = (1 + int1);
            J2(i_glob) = (int2 + 1./(w.*Tau_M));
      end

      % add on peak if it's being used.
      % May trigger warning, this integral is not easy.
      if DeltaP>0
        FINT2 = @(x) (exp(-(log(x./Tau_P)/sig).^2/2)./(1+(w.*x).^2));
        int2a = quadgk(FINT2, 0, inf);
        J2(i_glob)=J2(i_glob)+DeltaP*w*(int2a)/(sig*sqrt(2*pi));

        FINT1 = @(x) ( 1./x .* exp(-(log(x./Tau_P)/sig).^2/2)./(1+(w.*x).^2));
        int1 = quadgk(FINT1, 0, inf);
        J1(i_glob)=J1(i_glob)+DeltaP*int1 / (sig*sqrt(2*pi)) ;
      end

      % multiply on the unrelaxed compliance
      J1(i_glob)=Ju.*J1(i_glob);
      J2(i_glob)=Ju.*J2(i_glob);

      % See McCarthy et al, 2011, Appendix B, Eqns B6 !
      % J2_J1_frac=(1+sqrt(1+(J2(i_glob)./J1(i_glob)).^2))/2;
      J2_J1_frac=1;
      Qinv(i_glob) = J2(i_glob)./J1(i_glob).*(J2_J1_frac.^-1);
      Q(i_glob) = 1./Qinv(i_glob);

      M(i_glob) = (J1(i_glob).^2 + J2(i_glob).^2).^(-0.5) ;
      V(i_glob) = sqrt(M(i_glob)./rho) ;
    end % end loop over frequency
  end % end the loop(s) over spatial dimension(s)
  % ============================================================================

  if DeltaP>0
    warning(orig_state);
  end

  % Store relevant values
  onm='eburgers_psp';
  VBR.out.anelastic.(onm).J1 = J1;
  VBR.out.anelastic.(onm).J2 = J2;
  VBR.out.anelastic.(onm).Q = Q;
  VBR.out.anelastic.(onm).Qinv = Qinv;
  VBR.out.anelastic.(onm).M=M;
  VBR.out.anelastic.(onm).V=V;
  VBR.out.anelastic.(onm).tau_M=tau.maxwell;

  % calculate mean velocity along frequency dimension
  VBR.out.anelastic.(onm).Vave = Q_aveVoverf(V,f_vec);

end
