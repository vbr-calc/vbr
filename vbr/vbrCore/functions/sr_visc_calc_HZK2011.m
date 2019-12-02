function VBR= sr_visc_calc_HZK2011(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % VBR= sr_visc_calc_HZK2011(VBR)
  %
  % calculates strain rates and viscosities following Hansen, Zimmerman and
  % Kohlstedt, 2011, J. Geophys. Res., https://doi.org/10.1029/2011JB008220
  %
  % Parameters:
  % -----------
  % VBR   the VBR structure, with state variables in VBR.in.SV. and parameters
  %       loaded in VBR.in.viscous.HZK2011
  %
  % Ouptut:
  % -------
  % VBR   the VBR structure with new fields
  %       VBR.out.viscous.HZK2011.(mech).sr and (mech).eta for each deformation
  %       mechanism, e.g., VBR.out.viscous.HZK2011.diff.sr for diffusion creep.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % extract state variables and parameters
  T_K = VBR.in.SV.T_K ; % [K]
  P_Pa = 1e9.*(VBR.in.SV.P_GPa) ; % [GPa] to [Pa]
  sig = VBR.in.SV.sig_MPa; % deviatoric stress [MPa]
  d = VBR.in.SV.dg_um ; % [um]
  phi = VBR.in.SV.phi ;
  fH2O=zeros(size(T_K)); % this is a dry flow law
  params=VBR.in.viscous.HZK2011;

  % pressure dependent calculation?
  P_Pa = P_Pa.*(strcmp(params.P_dep_calc,'yes'));

  % calculate strain rate [1/s]
  sr_tot = 0;
  possible_mechs=params.possible_mechs;

  for ip = 1:numel(possible_mechs)
     mech=possible_mechs{ip};
     if isfield(VBR.in.viscous.HZK2011,mech)
        % pull out the flow law parameters
        FLP=params.(mech);
        % check for globalsettings, melt_enhacement fieldnames
        if VBR.in.GlobalSettings.melt_enhancement==0
           FLP.x_phi_c=1;
        end
        % calculate strain rate
        sr = sr_flow_law_calculation(T_K,P_Pa,sig,d,phi,fH2O,FLP);
        sr_tot=sr_tot+sr;

        % store it
        VBR.out.viscous.HZK2011.(mech).sr=sr;
        VBR.out.viscous.HZK2011.(mech).eta = sig*1e6./sr; % viscosity
     end
  end

  % store total composite strain rate and effective viscosity
  VBR.out.viscous.HZK2011.sr_tot=sr_tot; % total strain rate
  VBR.out.viscous.HZK2011.eta_total = sig*1e6./sr_tot ; % total viscosity

end
