function [VBR] = Q_andrade_analytical(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [VBR]=Q_andrade_analytical(VBR)
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
  % VBR    the VBR structure, with VBR.out.anelastic.analytical structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  method_settings = VBR.in.anelastic.andrade_analytical;

  % get inputs
  [rho_in, Mu_in, Ju_in, f_vec] = Q_get_state_vars(VBR);
  n_th = numel(Mu_in); % total elements
  n_freq = numel(f_vec);
  sz = size(Mu_in);

  % initialize outputs
  [J1, J2, Qinv, Ma, Va] = Q_init_output_vars(sz, n_freq);

  % Andrade parameters, set in params file
  alf = method_settings.alpha  ; % andrade exponent
  beta =  method_settings.Beta  ; % pre-factor

  % maxwell time:
  eta_ss = select_steady_state_viscosity(VBR, method_settings, 'andrade_analytical');
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
    Qinv(ig1:ig2) = Qinv_from_J1_J2(J1(ig1:ig2), J2(ig1:ig2));
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
