function VBR= sr_visc_calc_HK2003(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % VBR= sr_visc_calc_HK2003(VBR)
  %
  % calculates strain rates and viscosities for input state variables.
  %
  % reference:
  % Hirth, G. and Kohlstedt, D. (2013). Rheology of the Upper Mantle and the
  % Mantle Wedge: A View from the Experimentalists. In Inside the Subduction
  % Factory, J. Eiler (Ed.). doi:10.1029/138GM06
  %
  % Parameters:
  % -----------
  % VBR   the VBR structure, with state variables in VBR.in.SV. and parameters
  %       loaded in VBR.in.viscous.HK2003
  %
  % Ouptut:
  % -------
  % VBR   the VBR structure with new fields
  %       VBR.out.viscous.HK2003.(mech).sr and (mech).eta for each deformation
  %       mechanism, e.g., VBR.out.viscous.HK2003.diff.sr for diffusion creep.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % extract state variables and parameters
  T_K = VBR.in.SV.T_K ; % [K]
  P_Pa = 1e9.*(VBR.in.SV.P_GPa) ; % [GPa] to [Pa]
  sig = VBR.in.SV.sig_MPa; % deviatoric stress [MPa]
  d = VBR.in.SV.dg_um ; % [um]
  phi = VBR.in.SV.phi ;
  Ch2o=VBR.in.SV.Ch2o; % in [PPM]!
  params=VBR.in.viscous.HK2003;
  ch2o=params.ch2o_o; % effectively dry below this [PPM]

  % pressure dependent calculation?
  P_Pa = P_Pa.*(strcmp(params.P_dep_calc,'yes'));

  % calculate water fugacity
  fH2O=sr_water_fugacity(Ch2o,ch2o,P_Pa,T_K); % [MPa]
  VBR.in.SV.Fh2o=fH2O;

  %calculate strain rate [1/s]
  sr_tot = 0;
  possible_mechs=params.possible_mechs;

  for ip = 1:numel(possible_mechs)
     mech=possible_mechs{ip};
     if isfield(VBR.in.viscous.HK2003,mech)
        % prep the flow law parameters
        FLP=prep_constants(fH2O,T_K,params.(mech),mech);
        if VBR.in.GlobalSettings.melt_enhancement==0
           FLP.x_phi_c=1;
        end
        % calculate strain rate
        sr = sr_flow_law_calculation(T_K,P_Pa,sig,d,phi,fH2O,FLP);
        sr_tot=sr_tot+sr;

        VBR.out.viscous.HK2003.(mech).sr=sr;
        VBR.out.viscous.HK2003.(mech).eta = sig*1e6./sr; % viscosity
     end
  end

  % store total composite strain rate and effective viscosity
  VBR.out.viscous.HK2003.sr_tot=sr_tot; % total strain rate
  VBR.out.viscous.HK2003.eta_total = sig*1e6./sr_tot ; % total viscosity
end

function FLP=prep_constants(fH2O,T_K,params,mech)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % FLP=prep_constants(fH2O,T_K,params,mech)
  %
  % builds the flow law parameters (FLP) structure
  %
  % Parameters:
  % ----------
  % fH2O    oxygen fugacity [MPa]
  % T_K     temperature [K]
  % params  the parameter structure
  % mech    the current deformation mechanism
  %
  % Output:
  % ------
  % FLP    flow law parameter structure with flow law constants
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  FLP = struct();
  fields={'A';'n';'p';'r';'Q';'V';'phi_c';'alf';'x_phi_c'};
  for ifi = 1:numel(fields(:,1))
    name=char(fields(ifi,:)); % current fieldname
    if strcmp(mech,'diff') || strcmp(mech,'disl')
      % diffusion/dislocaiton creep with different parameters depending on
      % the water content
      name_wet = [name '_wet'];
      dry = params.(name);
      wet = params.(name_wet);
      wet_dry=dry .* (fH2O == 0) + wet .* (fH2O > 0);
      FLP.(name) =  wet_dry;
    elseif strcmp(mech,'gbs')
      % grain boundary sliding mechanism has different parameters for above
      % and below 1250 C
      name_gt = [name '_gt1250'];
      name_lt = [name '_lt1250'];
      gt1250 = params.(name_gt);
      lt1250 = params.(name_lt);
      val = gt1250 .* (T_K-273 >= 1250) + lt1250 .* (T_K-273<1250);
      FLP.(name) =  val;
    end
  end
end
