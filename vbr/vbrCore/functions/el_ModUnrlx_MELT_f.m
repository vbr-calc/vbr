function [VBR] = el_ModUnrlx_MELT_f(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = el_ModUnrlx_MELT_f(VBR)
  %
  % Poro-elastic effect of melt.
  % reference:
  % Takei, 2002, JGR Solid Earth, https://doi.org/10.1029/2001JB000522,
  % see Appendix A
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.elastic.anh_poro structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % check that anharmonic method was run, run it if not
  [field_exists,missing] = checkStructForField(VBR,{'out','elastic','anharmonic'},0);
  if field_exists==0
    VBR=loadThenCallMethod(VBR,'elastic','anharmonic');
  end

  anharm=VBR.out.elastic.anharmonic; % anharmonic moduli, velocities, uncertainty
  Gu = anharm.Gu ;
  Ku = anharm.Ku;
  phi = VBR.in.SV.phi ;
  rho = VBR.in.SV.rho;

  % read in parameters
  poro_p = VBR.in.elastic.anh_poro; anharm_p= VBR.in.elastic.anharmonic;
  A  = poro_p.Melt_A  ; % wetting angle factor (1:2.3, Yoshino)
  Km = poro_p.Melt_Km; % bulk modulus of the melt [Pa]
  nu = anharm_p.nu; % Poisson's ratio

  % calculate effective moduli and standard deviations
  [Gu_eff,Gamma_G]=melt_shear_moduli(Gu,phi,A,nu) ;
  [Ku_eff,Gamma_K]=melt_bulk_moduli(Ku,phi,A,Km,nu);

  % save moduli and poroelastic coefficient to local structure
  poro.Gu = Gu_eff;
  poro.Ku = Ku_eff;

  % calculate effective velocities and standard deviations
  [Vp,Vs] = Vp_Vs_calc(phi,Gu,nu,Gamma_G,Gamma_K,rho,Km);

  % save velocities to local structure
  poro.Vpu = Vp;
  poro.Vsu = Vs;

  % save to global VBR structure
  VBR.out.elastic.anh_poro=poro;
end

function [Vp,Vs] = Vp_Vs_calc(phi,Gu,nu,Gamma_G,Gamma_K,rho,K_m)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [Vp,Vs] = Vp_Vs_calc(phi,Gu,nu,Gamma_G,Gamma_K,rho,K_m)
  %
  % calculates Vp and Vs, accouting for poro-elastic effects. Reduces to
  % pure phase calculation when phi = 0.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % unrelaxed bulk mod
  nu_fac = 2/3*(1+nu)./(1-2*nu);
  Ku = Gu.*nu_fac;

  % the poroelastic factors
  K1 = (1-Gamma_K).^2;
  K2 = 1 - phi - Gamma_K + phi.*Ku./K_m; % equals 0 if phi = 0;

  % effective bulk and shear modulus
  delta = 1e-20; % small number to avoid division by 0.
  bulk_mod = Ku .* (Gamma_K + K1./(K2 + delta));
  shear_mod = Gu .* Gamma_G;

  % calculate Vp, Vs
  [Vp,Vs] = el_VpVs_unrelaxed(bulk_mod,shear_mod,rho);

end

function [Kb_eff,Gamma_k]=melt_bulk_moduli(k,phi,A,Km,nu)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % melt_bulk_moduli
  % calculates the bulk moduli, accounting for poro-elastic effect of melt.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % calculate the contiguity as a function of the melt fraction
  Psi =  1-A.*sqrt(phi) ;

  % exponents n and m in Takei, 2002 (functions of contiguity)
  % coefficients:
  a = zeros(3,4); % this will look like the transpose of what Takei has in table A1:
  a(1,:) = [1.8625 0.52594 -4.8397 0 ];
  a(2,:) = [4.5001 -6.1551 -4.3634 0 ];
  a(3,:) = [-5.6512 6.9159 29.595 -58.96];

  sz_a = size(a);
  a_vec=zeros(1,sz_a(1));
  for i = 1:sz_a(1)
      a_vec(i) = sum(a(i,:).*nu.^(0:1:3));
  end

  % eqns A5, A6, Takei 2002
  n_k = a_vec(1).*Psi + a_vec(2).*(1-Psi) + a_vec(3).*(1-Psi).^1.5 ;

  % normalized skeleton properties as functions of Psi
  Gamma_k = (1-phi).*(1-(1-Psi).^n_k).*ones(size(k));
  k_sk_prime = 1-(1-Psi).^n_k ; % eqn A3
  K_sk = k_sk_prime.*k ; % eqn A3

  % the effective laws with melt:
  delta =1e-20 ; % small number to avoid dividing by zero at phi=0;
  top = (1-K_sk./k).^2 ;
  bot = (1-phi-K_sk./k + phi.*k./Km) + delta.*(phi==0) ;
  Kb_eff_prime = K_sk./k + top./bot ;
  Kb_eff = Kb_eff_prime.*k;

end


function [Mu_eff,Gamma_Mu]=melt_shear_moduli(mu,phi,A,nu)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [Mu_eff,Gamma_Mu]=melt_shear_moduli(mu,phi,A,nu)
  %
  % calculates the shear moduli, accounting for poro-elastic effect of melt.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % calculate the contiguity as a function of the melt fraction
  Psi =  1-A.*sqrt(phi) ;

  % exponents n and m in Takei, 2002 (functions of contiguity)
  % coefficients:
  b = zeros(3);
  b(1,:) = [1.6122 0.13572 0] ;
  b(2,:) = [4.5869 3.6086 0] ;
  b(3,:) = [-7.5395 -4.8676 -4.3182] ;

  sz_b = size(b);
  b_vec=zeros(1,sz_b(1));
  for i = 1:sz_b(1)
      b_vec(i) = sum(b(i,:).*nu.^(0:1:2));
  end

  % eqns A6, Takei 2002
  n_mu = b_vec(1).*Psi + b_vec(2).*(1-Psi) + b_vec(3).*(1-Psi).^2 ;

  % normalized skeleton properties as functions of Psi
  Gamma_Mu=(1-phi).*(1-(1-Psi).^n_mu).*ones(size(mu));
  mu_sk_prime = 1-(1-Psi).^n_mu  ; % eqn A4
  Mu_sk = (1-phi).*mu_sk_prime.*mu ; % eqn A4

  % the effective laws with melt:
  Mu_eff = Mu_sk ; % effective shear modulus

end
