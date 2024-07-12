function [VBR] = Q_andrade_analytical(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [VBR]=Q_andrade_simple(VBR)
  %
  % the analytical andrade model. See supplement of Lau and Holtzman, 2019,
  % https://doi.org/10.1029/2019GL083529, for a nice, succinct formulation.
  %
  %
  % Parameters:
  % ----------
  % VBR    the VBR structure
  %
  % Output:
  % ------
  % VBR    the VBR structure, with VBR.out.anelastic.MTH2011 structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  method_settings = VBR.in.anelastic.andrade_analytical;

  % state variables
  rho_in = VBR.in.SV.rho ;
  if isfield(VBR.in.elastic,'anh_poro')
   Mu_in = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
   Mu_in = VBR.out.elastic.anharmonic.Gu ;
  end
  Ju_in = 1./Mu_in;
  % Frequency
  f_vec = VBR.in.SV.f;  % frequency

  % Andrade parameters, set in params file
  alf = method_settings.alpha  ; % andrade exponent
  beta =  method_settings.Beta  ; % pre-factor
  % allocation of Qstruct and V
  n_freq = numel(f_vec);
  sz = size(Mu_in);

  % frequency dependent vars
  J1 = proc_add_freq_indeces(zeros(sz),n_freq);
  J2 = J1; Qinv = J1; Ma = J1; Va = J1;

  % vectorized rho
  n_th = numel(Mu_in); % total elements

  % maxwell time:
  % get the steady state viscosity
  if strcmp(method_settings.viscosity_method, 'calculated')
      visc_method=VBR.in.viscous.methods_list{1};
      mech = method_settings.viscosity_method_mechanism; % e.g., 'diff'
      if strcmp(mech, 'eta_total')
          eta_ss = VBR.out.viscous.(visc_method).(mech);
      else
          eta_ss = VBR.out.viscous.(visc_method).(mech).eta ;
      end
  elseif strcmp(method_settings.viscosity_method, 'fixed')
      eta_ss = method_settings.eta_ss .* ones(sz);
  else
      msg = ["VBR.in.anelastic.andrade_analytical.viscosity_method must be", ...
             " one of 'calculated' or 'fixed', but found ", ...
             method_settings.viscosity_method]
      error(msg)
  end
  tau.maxwell = eta_ss ./ Mu_in ; % maxwell relaxation time

  % loop over frequency
  tau_m = tau.maxwell(1:n_th);
  Ju_in = Ju_in(1:n_th);
  for i_f = 1:n_freq
    w = 2*pi*f_vec(i_f) ;
    % get linear index of J1, J2, etc.
    ig1 = 1+(i_f - 1) * n_th; % the first linear index in current frequency
    ig2 = (ig1-1)+ n_th; % the last linear index in current frequency

    % pure andrade model
    MJ_real = 1 + beta * gamma(1+alf) * cos(alf * pi /2) ./ (w.^alf);
    MJ_imag = 1. ./ (w .* tau_m) + beta * gamma(1+alf)*sin(alf*pi/2)./(w.^alf);

    J1(ig1:ig2) = Ju_in .* MJ_real;
    J2(ig1:ig2) = Ju_in .* MJ_imag;
    J1J2_fac = (1 + sqrt(1+(J2(ig1:ig2)./J1(ig1:ig2)).^2)) / 2;
    Qinv(ig1:ig2) = (J2(ig1:ig2)./J1(ig1:ig2)) .* J1J2_fac;
    Ma(ig1:ig2) = (J1(ig1:ig2).^2 + J2(ig1:ig2).^2).^(-1/2) ;

    % velocities [m/s]
    Va(ig1:ig2) = sqrt(Ma(ig1:ig2)./rho_in(1:n_th)) ; % andrade Vs [m/s]
  end

  % Store output in VBR structure
  VBR.out.anelastic.andrade_analytical.J1 = J1;
  VBR.out.anelastic.andrade_analytical.J2 = J2;
  VBR.out.anelastic.andrade_analytical.Q = 1./Qinv;
  VBR.out.anelastic.andrade_analytical.Qinv = Qinv;
  VBR.out.anelastic.andrade_analytical.M=Ma;
  VBR.out.anelastic.andrade_analytical.V=Va;
  VBR.out.anelastic.andrade_analytical.tau_M=tau.maxwell;

  % calculate mean velocity along frequency dimension
  VBR.out.anelastic.andrade_analytical.Vave = Q_aveVoverf(Va,f_vec);

  VBR.out.anelastic.andrade_analytical.units = Q_method_units();
  VBR.out.anelastic.andrade_analytical.units.tau_M = 's';

end