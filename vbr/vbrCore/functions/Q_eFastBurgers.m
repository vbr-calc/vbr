function [VBR] = Q_eFastBurgers(VBR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [VBR]=Q_eFastBurgers(VBR)
% calculates material properties for extended burgers model using the
% FastBurger integration algorithm. Rather than integrate over relaxation
% period for every thermodynamic state (as in Q_eBurgers_f.m), the
% FastBurger algorithm first integrates over the entire range of relaxation
% periods of all input thermodynamic states, then extracts the relevant
% range for each thermodynamic state. See Notes for detailed description.
%
% For High Temp Background only. To include peak, must use Q_eBurgers_f().
%
% reference:
% Jackson & Faul, "Grainsize-sensitive viscoelastic relaxation in
% olivine: Towards a robust laboratory-based model for seismological
% application," Physics of the Earth and Planetary Interiors 183 (2010) 151–163
%
% Parameters:
% ----------
% VBR.   VBR structure with state variables and eBurger settings
%
% Output:
% ------
% VBR.eBurgers.
%             .J1     J1 comliance [1/Pa]
%             .J2     J2 compliance [1/Pa]
%             .Q      (J1/J2)
%             .Qinv   attenuation (Q^{-1})
%             .M      modulus [Pa]
%             .V      relaxed soundspeed [m/s]
%             .Vave   averaged V over all frequencies [m/s]
%
% A note on dimensions: arrays for frequency dependent variables will have
% an extra dimension for each frequency supplied. i.e., V(4,5,2) will be
% the velocity at thermodynamic point (4,5) and frequency freq_vec(2). Vave
% is the only output variable that is not frequency dependent, thus has the
% same size as incoming thermodynamic state variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% ===========================
  %% read in thermodynamic state
  %% ===========================
  f_vec = VBR.in.SV.f ;
  if isfield(VBR.in.elastic,'anh_poro')
    Mu = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
    Mu = VBR.out.elastic.anharmonic.Gu ;
  end
  rho_mat = VBR.in.SV.rho ;
  w_vec = 2*pi.*f_vec ; % period
  Ju_mat = 1./Mu ; % unrelaxed compliance

  %  allocate matrices
  nfreq = numel(f_vec);
  sz=size(Ju_mat);
  Jz=zeros(sz);
  J1 = proc_add_freq_indeces(Jz,nfreq);
  J2 = J1; Q = J1; Qinv = J1; M = J1; V = J1;

  % read in reference values
  Burger_params=VBR.in.anelastic.eburgers_psp;
  bType=Burger_params.eBurgerFit;
  if strcmp(bType,'bg_peak')
    wrn='WARNING: FastBurger method for eBurgers only works for bg_only, ';
    wrn=[wrn,'switch eBurgerMethod to PoinstWise to include peak.'];
    wrn=[wrn,' Continuing with bg_only.'];
    disp(wrn)
    btype='bg_only';
  end
  alf = Burger_params.(bType).alf ;
  DeltaB = Burger_params.(bType).DeltaB ; % relaxation strength of background
  DeltaP=Burger_params.(bType).DeltaP; % relaxation strength of peak
  sig=Burger_params.(bType).sig; % for peak

% calculate maxwell times
  tau=Q_eBurgers_mxwll(VBR,Mu);

% build look-up table for integration
  nglobvec0=Burger_params.nTauGlob;
  minTau_L=min(tau.L(:));
  maxTau_H=max(tau.H(:));
  nTau = numel(tau.L);
  Tau_glob_vec0(1:nglobvec0) = logspace(log10(minTau_L),log10(maxTau_H),nglobvec0);

% make sure each Tau_L, Tau_H appears in vector exactly
  for i_th = 1:nTau;
       Tau_L0 = tau.L(i_th);
       Tau_H0 = tau.H(i_th);

       if isempty(find(Tau_glob_vec0==Tau_L0));
           Tau_glob_vec0 = [Tau_glob_vec0 Tau_L0];
       end
       if isempty(find(Tau_glob_vec0==Tau_H0));
           Tau_glob_vec0 = [Tau_glob_vec0 Tau_H0];
       end
  end

  % sort the new vector, track indeces
  [Tau_glob_vec,TauIndx]=sort(Tau_glob_vec0);
  nglobvec=numel(Tau_glob_vec);

  % integrate the portions that depend only on frequency, cumulatively
  ints=repmat(struct('J1', nglobvec,'J2', nglobvec), nfreq, 1 );
  for iw = 1:nfreq
   w = w_vec(iw); % for now

   ints(iw).J1= cumtrapz(Tau_glob_vec,Tau_glob_vec.^(alf-1)./(1+w^2.*Tau_glob_vec.^2)) ;
   ints(iw).J2 = cumtrapz(Tau_glob_vec,Tau_glob_vec.^alf./(1+w^2.*Tau_glob_vec.^2)) ;
  end

  % now go through each i_th, find the interval of interest for each and
  % calculate the modulus
  for i_th = 1:nTau
    % get current i_th values
    Tau_M = tau.maxwell(i_th);
    Ju = Ju_mat(i_th) ;
    rho = rho_mat(i_th) ;

    % the bounds to find
    Tau_L0 = tau.L(i_th);
    Tau_H0 = tau.H(i_th);

    % find the bounds
    iLow = find(Tau_glob_vec==Tau_L0);
    iHigh = find(Tau_glob_vec==Tau_H0);

    % loop over frequency
    for iw=1:nfreq
      i_glob = i_th + (iw - 1) * nTau; % the linear index of the arrays with
                                       % a frequency index
      w = w_vec(iw) ;

      int_J1 = ints(iw).J1;
      d_integral=alf*(int_J1(iHigh)-int_J1(iLow))./(Tau_H0^alf - Tau_L0^alf);
      J_int_1_0 = (1+DeltaB*d_integral) ;

      int_J2 = ints(iw).J2;
      d_integral=alf*(int_J2(iHigh)-int_J2(iLow))./(Tau_H0^alf - Tau_L0^alf);
      J_int_2_0 = (w*DeltaB*d_integral + 1/(w*Tau_M)) ;

      J1(i_glob)=Ju * J_int_1_0;
      J2(i_glob)=Ju * J_int_2_0;

      Q(i_glob) = J1(i_glob)./J2(i_glob) ;
      Qinv(i_glob) = 1./Q(i_glob) ;
      M(i_glob) = (J1(i_glob).^2 + J2(i_glob).^2).^(-0.5) ;
      V(i_glob) = sqrt(M(i_glob)./rho) ;
    end
  end

  %% WRITE VBR
  onm='eburgers_psp';
  VBR.out.anelastic.(onm).J1 = J1;
  VBR.out.anelastic.(onm).J2 = J2;
  VBR.out.anelastic.(onm).Q = Q;
  VBR.out.anelastic.(onm).Qinv = Qinv;
  VBR.out.anelastic.(onm).M=M;
  VBR.out.anelastic.(onm).V=V;

  % calculate mean velocity along frequency dimension
  VBR.out.anelastic.(onm).Vave = Q_aveVoverf(V,f_vec);

end
