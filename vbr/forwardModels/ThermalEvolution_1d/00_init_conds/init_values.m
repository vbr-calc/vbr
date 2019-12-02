function [Info] = init_values(settings)

% read in depth array
   z = settings.Zinfo.z_m;

% temperature [C]
  Tpot = settings.Tpot;
  dTdz_ad = settings.dTdz_ad;

  if strcmp(settings.Flags.T_init,'oceanic')
%    halfspace cooling with uniform properties
     age = settings.age0*1e6*365*24*3600;
     Diff0 = settings.Kc_olv / settings.Cp_olv / settings.rhos;
     Info.init.T = Tpot * erf( z / sqrt(age * Diff0)) + z*dTdz_ad;
  elseif strcmp(settings.Flags.T_init,'adiabatic')
%    adiabatic
     Info.init.T = Tpot + z*dTdz_ad;
  elseif strcmp(settings.Flags.T_init,'continental')
%    linear
     TLAB = Tpot + z(end)*dTdz_ad;
     Info.init.T = TLAB * z/z(end);
  end


   Info.init.dg_um=1e6*settings.grain0 * ones(size(z));
   Info.init.sig_MPa=settings.sig_MPa*ones(size(z));
   Info.init.Cs_H2O=settings.Cs0_H2O*ones(size(z))*1e-4; % PPM to wt %
   Info.init.Cs_CO2=settings.Cs0_CO2*ones(size(z))*1e-4; % PPM to wt %
   Info.init.Cf_H2O = Info.init.Cs_H2O / (settings.kd_H2O + settings.F * (1-settings.kd_H2O));
   Info.init.Cf_CO2 = Info.init.Cs_CO2 / (settings.kd_CO2 + settings.F * (1-settings.kd_CO2));
   
%  composition-dependent properties
%     calculate the weighting function
      Zm=settings.Z_moho_km*1e3;
      dzMoho = settings.Moho_thickness_km * 1e3;
      Grade = 0.5 * (1 + erf( (z - Zm) / dzMoho));
%     initialize properties with crustal values
      Rho_0 = settings.rhos_crust * ones(size(z)); % density [kg/m3]
      Cp_0 = settings.Cp_crust * ones(size(z)); % specific heat [J/kg/K]
      Kc_0 = settings.Kc_crust * ones(size(z)); % conductiviy [W/m/K]

%     add on the difference via weighting
      Rho_z_0 = Rho_0 + (settings.rhos - settings.rhos_crust)*Grade;
      Cp_z_0 = Cp_0 + (settings.Cp_olv - settings.Cp_crust)*Grade;
      Kc_z_0 = Kc_0 + (settings.Kc_olv - settings.Kc_crust)*Grade;
      Info.init.Rho_0 = Rho_z_0;
      Info.init.Cp_0 = Cp_z_0;
      Info.init.Kc_0 = Kc_z_0;
      Info.init.comp = Grade;

%   start with no phi
    Info.init.phi = zeros(size(z));

%   thermal properties at elevated P,T
    dz = z(2)-z(1);
    Info.init = call_MaterialProps(Info.init,Rho_z_0,Kc_z_0,Cp_z_0,settings,z,dz);

%   Calculate solidus at initial Cf guess
    Solidus = SoLiquidus(Info.init.P,Info.init.Cf_H2O,Info.init.Cf_CO2,'katz');
    Info.init.Tsol=Solidus.Tsol;

%   get initial LAB
%   initial viscosity
    Info.init.eta = get_VBR_visc(Info.init);
%   LAB location
    LABInfo.zLAB=0; % initialize the structure to avoid warning...
    LABInfo = find_LAB(Info.init,z,settings,LABInfo);
%   add on "plume" excess
    dTex=settings.Tpot_excess;
    zLAB=LABInfo.zLAB;
    dTex = dTex * (1+erf((z-zLAB)/(settings.DBL_m*2)))/2;
    Info.init.T = Info.init.T + dTex;

%   thermal properties at elevated P,T
    Info.init = call_MaterialProps(Info.init,Rho_z_0,Kc_z_0,Cp_z_0,settings,z,dz);


%   recalculate T and P dependent properties

%   actual solidus calc (and Gdot initialization)
    Solidus = SoLiquidus(Info.init.P,Info.init.Cf_H2O,Info.init.Cf_CO2,'katz');
    Info.init.Tsol=Solidus.Tsol;
    Info.init.phi = ones(size(Info.init.T)) * settings.phi_min;
    Info.init.phi(Info.init.T<Info.init.Tsol)=0;


% background upwelling velocity
  Vbgs=-settings.Vbg/(1e2 * 365 * 24 * 3600); % [m/s]
  Info.init.Vbgzs = Vbgs.*ones(size(z));

%   zLAB_Vbg=LABInfo.zLABeta;
%   if strcmp(VbgFlag,'variable') || strcmp(VbgFlag,'var_z_con_t')
%       Info.init.Vbgzs=upwelling_velocity(Vbgs,zs,zLAB_Vbg,settings.DBL_m);
%   elseif strcmp(VbgFlag,'con_asthen')
%       Info.init.Vbgzs(zs<zLAB_Vbg)=0;
%   end
%   Info.init.Vbgz = addghosts(stag(Info.init.Vbgzs));

end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function Vbgz = upwelling_velocity(Vbgz0,zs,zLAB,DBL_m)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % construct vertical solid velocity. This is a trick... only using this to
% % calculate decompression melting, thermal advection terms. Strictly speaking,
% % this will violate mass conservation. But maybe that's ok.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Vbgz = Vbgz0 * 0.5 * (1 + erf((zs - zLAB - 2*DBL_m)./DBL_m));
%    Vbgz(zs<zLAB) = 0;
% end
