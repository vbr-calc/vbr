function eta_ss = select_steady_state_viscosity(VBR, method_settings, method_name)
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
      sz = size(VBR.in.SV.T_K);
      eta_ss = method_settings.eta_ss .* ones(sz);
  else
      msg = ["VBR.in.anelastic.", method_name, ".viscosity_method must be", ...
             " one of 'calculated' or 'fixed', but found ", ...
             method_settings.viscosity_method]
      error(msg)
  end
end