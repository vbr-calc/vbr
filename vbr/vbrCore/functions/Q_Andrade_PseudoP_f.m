function [VBR] = Q_Andrade_PseudoP_f(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR]=Q_Andrade_PseudoP_f(VBR)
  %
  % Andrade Pseudo-Period Anelastic Model.
  % References:
  % [1] Jackson and Faul, 2010, PEPI https://doi.org/10.1016/j.pepi.2010.09.005
  % [2] Bellis and Holtzman, 2014, JGR http://dx.doi.org/10.1002/2013JB010831
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, now with VBR.out.anelastic.andrade_psp structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % State Variables
  if isfield(VBR.in.elastic,'anh_poro')
   Mu_in = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
   Mu_in = VBR.out.elastic.anharmonic.Gu ;
  end
  Ju_in = 1./Mu_in ; % compliance
  rho_in = VBR.in.SV.rho ;
  f_vec = VBR.in.SV.f;  % frequency [this, however, is not a mat -- is a 1D vector]
  w_vec = 2*pi.*f_vec ; % angular frequency
  Tau0_vec = 1./f_vec ; % period

  % Andrade parameters, set in params file
  andrade_nm='andrade_psp';
  n = VBR.in.anelastic.(andrade_nm).n  ; % andrade exponent
  Tau_MR = VBR.in.anelastic.(andrade_nm).Tau_MR ; %
  Beta = VBR.in.anelastic.(andrade_nm).Beta ; %

  % Elastic-GBS relaxation peak parameters, set in params file
  Te = VBR.in.anelastic.(andrade_nm).Te ; %
  Tgbs = VBR.in.anelastic.(andrade_nm).Tgbs ; % sec
  Delta = VBR.in.anelastic.(andrade_nm).Delta ;% relaxation strength

  % pseudo-period master variable independent of period/freqency
  Xtilde = calculateXtilde(VBR);

  % allocation of Qstruct and V
  n_freq = numel(f_vec);
  sz = size(Mu_in);

  % frequency dependent vars
  J1 = proc_add_freq_indeces(zeros(sz),n_freq);
  J2 = J1; Qa = J1; Qinv = J1; Ma = J1; Va = J1;
  J1_gbs = J1; J2_gbs = J1; Q_gbs = J1; M_gbs = J1;
  J1_comp = J1; J2_comp = J1; Q_comp = J1; M_comp = J1; Va_comp = J1;

  % vectorized rho
  n_th = numel(Ju_in); % total elements
  rho_vec = reshape(rho_in,size(Ma(1:n_th)));

  %% =============================
  %% calculate material properties
  %% =============================

  % scalar values
  param1 = Beta*gamma(1+n)*cos(n*pi/2);
  param2 = Beta.*gamma(1+n)*sin(n*pi/2);

  % loop over frequency
  for f = 1:n_freq
    % get linear index of J1, J2, etc.
    ig1 = 1+(f - 1) * n_th; % the first linear index in current frequency
    ig2 = (ig1-1)+ n_th; % the last linear index in current frequency

    % pseudoperiod master variable
    wX_mat = 2*pi./(Tau0_vec(f).*Xtilde) ;
    w = w_vec(f);

    % pure andrade model
    J1(ig1:ig2) = Ju_in.*(1 + param1 * (wX_mat.^-n)) ;
    J2(ig1:ig2) = Ju_in.*(param2 * (wX_mat.^-n) + 1./(Tau_MR.*wX_mat));
    Qa(ig1:ig2) = J1(ig1:ig2)./J2(ig1:ig2) ;
    Qinv(ig1:ig2) = 1./Qa(ig1:ig2);
    Ma(ig1:ig2) = (J1(ig1:ig2).^2 + J2(ig1:ig2).^2).^(-1/2) ;

    % gbs relaxation bump
    J1_gbs(ig1:ig2) = Ju_in.*Delta./(1+Tgbs.^2.*w.^2) ;
    J2_gbs(ig1:ig2) = Ju_in.*Delta.*(w.*Te)./(1+Tgbs.^2.*w.^2) ;
    Q_gbs(ig1:ig2) = J1_gbs(ig1:ig2)./J2_gbs(ig1:ig2) ;
    M_gbs(ig1:ig2) = (J1_gbs(ig1:ig2).^2 + J2_gbs(ig1:ig2).^2).^(-1/2) ;

    % composite
    J1_comp(ig1:ig2) = J1(ig1:ig2) + J1_gbs(ig1:ig2) ;
    J2_comp(ig1:ig2) = J2(ig1:ig2) + J2_gbs(ig1:ig2) ;
    Q_comp(ig1:ig2) = J1_comp(ig1:ig2)./J2_comp(ig1:ig2) ;
    M_comp(ig1:ig2) = (J1_comp(ig1:ig2).^2 + J2_comp(ig1:ig2).^2).^(-1/2);

    % velocities [m/s]
    Va(ig1:ig2) = sqrt(Ma(ig1:ig2)./rho_vec) ; % andrade Vs [m/s]
    Va_comp(ig1:ig2) = sqrt(M_comp(ig1:ig2)./rho_vec) ; % composite Vs [m/s]
  end

  % Store output in VBR structure
  VBR.out.anelastic.(andrade_nm).J1 = J1;
  VBR.out.anelastic.(andrade_nm).J2 = J2;
  VBR.out.anelastic.(andrade_nm).Q = Qa;
  VBR.out.anelastic.(andrade_nm).Qinv = Qinv;
  VBR.out.anelastic.(andrade_nm).M=Ma;
  VBR.out.anelastic.(andrade_nm).V=Va;
  VBR.out.anelastic.(andrade_nm).J1_gbs = J1_gbs;
  VBR.out.anelastic.(andrade_nm).J2_gbs = J2_gbs;
  VBR.out.anelastic.(andrade_nm).Q_gbs = Q_gbs;
  VBR.out.anelastic.(andrade_nm).M_gbs=M_gbs;
  VBR.out.anelastic.(andrade_nm).J1_comp = J1_comp;
  VBR.out.anelastic.(andrade_nm).J2_comp = J2_comp;
  VBR.out.anelastic.(andrade_nm).Q_comp = Q_comp;
  VBR.out.anelastic.(andrade_nm).M_comp=M_comp;
  VBR.out.anelastic.(andrade_nm).Va_comp=Va_comp;

  % calculate mean velocity along frequency dimension
  VBR.out.anelastic.(andrade_nm).Vave = Q_aveVoverf(Va,f_vec);

end

function Xtilde = calculateXtilde(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Xtilde = calculateXtilde(VBR)
  %
  % the andrade psuedo-period master variable, independent of frequency/period.
  %
  % full master variable:
  % X_B = T_o * ((d_mat./dR).^-m).*exp((-E/R).*(1./T_K_mat-1/TR)) ...
  %                         .*exp(-(Vstar/R).*(P_Pa_mat./T_K_mat-PR/TR));
  % where T_o = period.
  %
  % X_B = T_o * Xtilde
  %
  % Xtilde = ((d_mat./dR).^-m).*exp((-E/R).*(1./T_K_mat-1/TR)) ...
  %                         .*exp(-(Vstar/R).*(P_Pa_mat./T_K_mat-PR/TR));
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % Xtilde    the master variable
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % state variables
  T_K_mat = VBR.in.SV.T_K ; % temperature [K]
  d_mat = VBR.in.SV.dg_um ; % microns grain size
  P_Pa_mat = VBR.in.SV.P_GPa.*1e9 ; % convert pressure GPa to Pa = GPa*1e9
  phi =  VBR.in.SV.phi ;

  % pull out andrade master-variable parameters
  Andrade_params=VBR.in.anelastic.andrade_psp;
  TR = Andrade_params.TR; % reference temperature in K
  PR = Andrade_params.PR *1e9 ; % reference pressure in Pa
  dR = Andrade_params.dR ; % reference grain size, microns
  E = Andrade_params.E ; % J/mol
  R = Andrade_params.R ; % gas constant
  Vstar = Andrade_params.Vstar ; % m^3/mol (Activation Volume? or molar volume?)
  m = Andrade_params.m ; % grain size exponent

  Xtilde = ((d_mat./dR).^-m).*exp((-E/R).*(1./T_K_mat-1/TR)) ...
                           .*exp(-(Vstar/R).*(P_Pa_mat./T_K_mat-PR/TR));

  % melt enhancement correction to trully melt-free
  alpha = Andrade_params.melt_alpha ;
  phi_c = Andrade_params.phi_c ;
  x_phi_c = Andrade_params.x_phi_c ;
  if VBR.in.GlobalSettings.melt_enhancement==0
    x_phi_c=1;
  else
    Xtilde = Xtilde / x_phi_c ;
  end

  % apply melt enhancement
  [Xtilde_prime] = sr_melt_enhancement(phi,alpha,x_phi_c,phi_c) ;
  Xtilde = Xtilde_prime.*Xtilde ;
end
