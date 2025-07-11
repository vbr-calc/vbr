---
permalink: /examples/CB_010_depthProfiles/
title: ""
---

# CB_010_depthProfiles.m
## output figures

!['CB_010_depthProfiles'](/vbr/assets/images/CBs/CB_010_depthProfiles.png){:class="img-responsive"}
## contents
```matlab
function [VBR,HF] = CB_010_depthProfiles()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [VBR,HF] = CB_010_depthProfiles()
  %
  %   Calculate seismic properties for a half space cooling profile at 30 Myrs
  %   Assumes constant density for thermal profile (analytical half space
  %   cooling), re-calculates density for the seismic properties.
  %
  %   Output
  %   ------
  %   VBR    the VBR structure
  %   HF     halfspace model structure
  %   figures to screen
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% build thermal model %%
  HF = HalfspaceModel(30); % analytical half-space cooling
  HF = correctHF(HF); % adjust solution (variable density, etc.)
  [Solidus] = SoLiquidus(HF.P,5,0,'katz');
  Tsolidus_C=Solidus.Tsol;

  %% Load and set VBR parameters and stave variables %%
  VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
  VBR.in.viscous.methods_list={'HK2003'};
  VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'; 'xfit_premelt'};
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
  VBR.in.elastic.anharmonic.Gu_0_ol = 75.5; % olivine reference shear modulus [GPa]
  VBR.in.SV.f = [0.01, 0.02, 0.04, 0.1];%  frequencies to calculate at

  % store thermal model in VBR state variables
  VBR.in.SV.T_K = HF.T_C+273; % set HF temperature, convert to K
  VBR.in.SV.P_GPa = HF.P/1e9; % pressure [GPa]
  VBR.in.SV.rho=HF.rho; % density [kg m^-3]
  VBR.in.SV.chi=HF.chi;

  % set the other state variables as matrices of same size
  sz=size(HF.T_C);
  VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
  VBR.in.SV.Tsolidus_K = Tsolidus_C+273;
  VBR.in.SV.phi = 0.01 * (HF.T_C > Tsolidus_C); % melt fraction
  VBR.in.SV.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]

  %% CALL THE VBR CALCULATOR %%  
  [VBR] = VBR_spine(VBR) ;

  %% Build figures %%  
  if (getenv('VBRcTesting') ~= '1')
    figure('PaperPosition',[0,0,14,4],'PaperPositionMode','manual')
    ax1=subplot(1,5,1);
    plot(HF.T_C,HF.z_km)
    hold on
    plot(Tsolidus_C,HF.z_km,'--k')
    xlabel('T [C]')
    ylabel('Depth [km]')
    set(gca,'ydir','reverse')

    ax2=subplot(1,5,2);
    plot(HF.P/1e9,HF.z_km)
    xlabel('P [GPa]')
    ylabel('Depth [km]')
    set(gca,'ydir','reverse')

    ax3=subplot(1,5,3);
    plot(HF.rho/1e3,HF.z_km)
    xlabel('\rho [g/m3]')
    ylabel('Depth [km]')
    set(gca,'ydir','reverse')

    for imeth = 1:numel(VBR.in.anelastic.methods_list)
      meth=VBR.in.anelastic.methods_list{imeth};
      
      ax4=subplot(1,5,4);
      hold all
      plot(squeeze(VBR.out.anelastic.(meth).V(:,1))/1e3,HF.z_km,'displayname',meth)
      xlabel('ave. Vs [km/s]')
      ylabel('Depth [km]')
      xlim([4.2,4.7])
      box on
      set(gca,'ydir','reverse')

      ax5=subplot(1,5,5);
      hold all
      plot(squeeze(log10(VBR.out.anelastic.(meth).Q(:,1))),HF.z_km,'displayname',meth)
      xlabel('log10(Q)')
      ylabel('Depth [km]')
      box on
      set(gca,'ydir','reverse')
      xlim([0,8])
    end

    saveas(gcf,'./figures/CB_010_depthProfiles.png')
  end
end

function HF = HalfspaceModel(age_Myrs)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % HF = HalfspaceModel(age_Myrs)
  %
  % Half Space Cooling Model, analytical solution
  %    T(z,t)=T_surf + (T_asth - T_surf) * erf(z / (2sqrt(Kappa * t)))
  %
  % Parameters
  % ----------
  % age_Myrs  plate age in Myrs
  %
  % Output
  % ------
  % HF    half-space cooling structure with settings and variables
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% HF settings %%
    HF.Tsurf_C=0; % surface temperature [C]
    HF.Tasth_C=1350; % asthenosphere temperature [C]
    HF.V_cmyr=8; % half spreading rate [cm/yr]
    HF.Kappa=1e-6; % thermal diffusivity [m^2/s]
    HF.rho=3300; % density [kg/m3]
    HF.t_Myr=age_Myrs; % seaflor age [Myrs]
    HF.z_km=transpose(linspace(0,200,50)); % depth [km]

  %% HF calculations %%
    HF.s_in_yr=(3600*24*365); % seconds in a year [s]
    HF.t_s=HF.t_Myr*1e6*HF.s_in_yr; % plate age [s]
    HF.x_km=HF.t_s / (HF.V_cmyr / HF.s_in_yr / 100) / 1000; % distance from ridge [km]

  %% calculate HF cooling model T profile %%
    HF.dT=HF.Tasth_C-HF.Tsurf_C;
    HF.erf_arg=HF.z_km*1000/(2*sqrt(HF.Kappa*HF.t_s));
    HF.T_C=HF.Tsurf_C+HF.dT * erf(HF.erf_arg);
end


function HF = correctHF(HF)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calculates a better density profile, adds on adiabat to temp
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  HF.dTdz_ad = 0.5 * 1e-3; % adiabat deg C/m
  HF.T_C = HF.T_C + HF.dTdz_ad*HF.z_km*1e3;

  HF.Z_moho_km = 20; % Moho depth [km]
  HF.rhos_olv = 3300; % solid density [kg/m3]
  HF.rhos_crust = 2800; % crustal density [km/m3]

  % thermal properties at reference state
  HF.Kc_olv = 4.17; % thermal conductivity [W/m/K], from Xu et al (see MaterialProperties.m)
  HF.Kc_crust = 2; % thermal conductivity [W/m/K]
  HF.Cp_olv = 1100; % heat capacity [J/kg/K]
  HF.Cp_crust = 800; % heat capacity [J/kg/K]

  fldz={'rhos';'Kc';'Cp'};
  for ifl = 1:numel(fldz)
    fld=fldz{ifl};
    HF.(fld) = HF.([fld, '_olv'])* ones(size(HF.z_km));
    HF.(fld)(HF.z_km<HF.Z_moho_km)=HF.([fld, '_crust']);
  end
  P0=1e5; % surf pressure, [Pa]
  z=HF.z_km*1e3;
  T_K=HF.T_C+273;
  [rho,cp,kc,P] = ThermodynamicProps(HF.rhos,HF.Kc,HF.Cp,T_K,z,P0,HF.dTdz_ad,'PT_dep');
  HF.rho=rho;
  HF.P=P;

  HF.chi=HF.z_km>HF.Z_moho_km;
end
```
