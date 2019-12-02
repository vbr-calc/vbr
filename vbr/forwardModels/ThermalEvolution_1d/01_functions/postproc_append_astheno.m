function [Vars,Info]=postproc_append_astheno(Vars,Info,settings)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [Vars,Info]=postproc_append_astheno(Vars,Info,settings)
  %
  % post proccessing step to append an adiabatic asthenosphere beneath model domain
  %
  % Parameters
  % ----------
  %   Vars    the variables array output from a model run
  %   Info    the info structure from a model run
  %   settings the settings strcuture for the model run, requires
  %            settings.Zinfo.asthenosphere_max_depth
  % Output
  % ------
  %   Vars,Info  updated Vars and Info structures
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  nt = numel(Info.t);
  nz_lith = numel(Info.z_km);
  zPlate = Info.z_km(end);
  zAsth = settings.Zinfo.asthenosphere_max_depth;

  z=Info.z_km;
  nz0 = numel(z);

  dz=z(2)-z(1);
  z_new=(z(end):dz:zAsth)';
  z_new = [z; z_new(2:end)]*1e3; % the new Z
  nz = numel(z_new);
  Info.z_km = z_new/1e3;
  Info.z = z_new;


  [Var_new,Info] = init_new_Var(Vars,Info,nz,nz0,nt);
  for it = 1:nt
    % first, just copy LAB value into asthenosphere nodes, then overwrite the
    % variables that will be different in asthenosphere
    fields = fieldnames(Vars);
    for ifi = 1:numel(fields(:,1));
        Var_new.(fields{ifi})(1:nz0,it) = Vars.(fields{ifi})(1:nz0,it);
        Var_new.(fields{ifi})(nz0+1:nz,it) = Vars.(fields{ifi})(nz0,it);
    end

    % temperature is adiabatic below the boundary
    Tad = settings.Tpot + settings.dTdz_ad * z_new(nz0+1:nz);
    Tlith=Vars.T(:,it);
    Var_new.T(:,it) = [Tlith; Tad];

    % now recalculate dependent material properties (P,cp,kc,rho)
    rho = Info.init.Rho_0;  kc = Info.init.Kc_0; cp = Info.init.Cp_0;
    T_K = Var_new.T(:,it) + 273;
    [rho,cp,kc,P_hyd]=MaterialProperties(rho,kc,cp,T_K,z_new,settings.P0,...
                     settings.dTdz_ad,settings.Flags.PropType);
    Var_new.rho(:,it) = rho; Var_new.cp(:,it)=cp; Var_new.Kc(:,it)=kc;
    Var_new.P(:,it)=P_hyd;

    % and recalculate solidus, phi
    Var_new = convertVolatilePPMwt(Var_new,'to_wt');
    Solidus = SoLiquidus(P_hyd,Var_new.Cf_H2O(:,it),Var_new.Cf_CO2(:,it),'katz');
    Var_new = convertVolatilePPMwt(Var_new,'to_PPM');
    Var_new.Tsol(:,it)=Solidus.Tsol;
    Var_new.phi(:,it) = ones(nz,1) * settings.phi_min;
    % conditional statement: if T > Tsol, ()==1
    Var_new.phi(:,it) = Var_new.phi(:,it) .* (Var_new.T(:,it) > Var_new.Tsol(:,it));

    % recalc viscosity
    Vark.T = Var_new.T(:,it); Vark.P = P_hyd;
    Vark.sig_MPa = Var_new.sig_MPa(:,it);
    Vark.dg_um = Var_new.dg_um(:,it);
    Vark.phi = Var_new.phi(:,it);
    Vark.Cs_H2O = Var_new.Cs_H2O(:,it);
    Var_new.eta(:,it) = get_VBR_visc(Vark);

    % recalc composition weighting function
    Zm=settings.Z_moho_km*1e3;
    dzMoho = settings.Moho_thickness_km * 1e3;
    Grade = 0.5 * (1 + erf( (z_new - Zm) / dzMoho));
    Var_new.comp(:,it) = Grade;

    % recalc LAB
    Vark.Tsol=Var_new.Tsol(:,it);
    Vark.eta = Var_new.eta(:,it);
    [LABInfo] = find_LAB(Vark,z_new,settings,struct());
    fields = fieldnames(LABInfo);
    for ifi = 1:numel(fields(:,1))
        Info.(fields{ifi})(it) = LABInfo.(fields{ifi});
    end
  end
  Vars = Var_new;
end

function [Var_new,Info_new] = init_new_Var(Vars,Info,nz,nz0,nt)
  fields = fieldnames(Vars);
  for ifi = 1:numel(fields(:,1));
      Var_new.(fields{ifi}) = zeros(nz,nt);
  end

  fields = {'Rho_0'; 'Kc_0'; 'Cp_0'};
  Info_new = Info;
  for ifi = 1:numel(fields(:,1));
      Info_new.init.(fields{ifi}) = zeros(nz,1);
      Info_new.init.(fields{ifi})(1:nz0) = Info.init.(fields{ifi});
      Info_new.init.(fields{ifi})(nz0+1:nz) = Info.init.(fields{ifi})(nz0);
  end
end
