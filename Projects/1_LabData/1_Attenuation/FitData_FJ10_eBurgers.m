function FitData_FJ10_eBurgers()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % FitData_FJ10_eBurgers()
  %
  % Reproduces figures 1a-1d from Jackson and Faul, PEPI 2010 (JF10):
  % moduli and Qinv vs period for a single sample, #6585, using coefficients for
  % the single sample fit in table 1 of JF10, for 700 to 1200 deg. C
  %
  % Parameters
  % ----------
  % None
  %
  % Output
  % ------
  % figures to screen and to Projects/1_LabData/1_Attenuation/figures/
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  clear

  path_to_top_level_vbr='../../../';
  addpath(path_to_top_level_vbr)
  vbr_init

  % set elastic, anelastic methods, load parameters
  VBR.in.elastic.methods_list={'anharmonic'};
  VBR.in.anelastic.methods_list={'eburgers_psp'};

  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); %
  VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
  VBR.in.anelastic.eburgers_psp.eBurgerMethod='s6585_bg_only'; % 'bg_only' or 'bg_peak' or 's6585_bg_only'

  % JF10 have Gu_0=62.5 GPa, but that's at 900 Kelvin and 0.2 GPa,
  % so set Gu_0_ol s.t. it ends up at 62.5 at those conditions
  dGdT=VBR.in.elastic.anharmonic.dG_dT;
  dGdP=VBR.in.elastic.anharmonic.dG_dP;
  Tref=VBR.in.elastic.anharmonic.T_K_ref;
  Pref=VBR.in.elastic.anharmonic.P_Pa_ref/1e9;
  GUJF10=VBR.in.anelastic.eburgers_psp.s6585_bg_only.G_UR;
  VBR.in.elastic.anharmonic.Gu_0_ol = GUJF10 - (900+273-Tref) * dGdT/1e9 - (0.2-Pref)*dGdP; % olivine reference shear modulus [GPa]

  % frequencies to calculate at
  VBR.in.SV.f = 1./logspace(-2,4,100);

  % temperature range
  VBR.in.SV.T_K=700:50:1200;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;
  sz=size(VBR.in.SV.T_K); % temperature [K]

  %  remaining state variables
  VBR.in.SV.dg_um=3.1*ones(sz);
  VBR.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
  VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
  VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

  % run it initially (eburgers_psp uses high-temp background only by default)
  [VBR] = VBR_spine(VBR) ;

  % adjust VBR input and get out eburgers_psp with background + peak
  % VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
  VBR.in.anelastic.eburgers_psp.eBurgerFit='s6585_bg_peak';
  GUJF10=VBR.in.anelastic.eburgers_psp.s6585_bg_peak.G_UR;
  VBR.in.elastic.anharmonic.Gu_0_ol = GUJF10 - (900+273-Tref) * dGdT/1e9 - (0.2-Pref)*dGdP;
  [VBR_with_peak] = VBR_spine(VBR) ;

  % load data if it exists
  data = tryDataLoad();

  %% ====================================================
  %% Display some things ================================
  %% ====================================================
  
  figure;

  for iTemp = 1:numel(VBR.in.SV.T_K)

    M_bg=squeeze(VBR.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);
    M_bg_peak=squeeze(VBR_with_peak.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);
    Q_bg=squeeze(VBR.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));
    Q_bg_peak=squeeze(VBR_with_peak.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));
    logper=log10(1./VBR.in.SV.f);
    R=(iTemp-1) / (numel(VBR.in.SV.T_K)-1);
    B=1 - (iTemp-1) / (numel(VBR.in.SV.T_K)-1);

    subplot(2,2,1)
    hold on
    plot(logper,M_bg,'color',[R,0,B],'LineWidth',2);
    ylabel('M [GPa] (bg only) '); xlabel('log10 period [s]')
    ylim([0,80])


    subplot(2,2,2)
    hold on
    plot(logper,log10(Q_bg),'color',[R,0,B],'LineWidth',2);
    ylabel('log10 Q^-1 (bg only)'); xlabel('log10 period [s]')
    ylim([-2.5,0.5])

    subplot(2,2,3)
    hold on
    plot(logper,M_bg_peak,'color',[R,0,B],'LineWidth',2);
    ylabel('M [GPa] (bg + peak) '); xlabel('period [s]')
    ylim([0,80])

    subplot(2,2,4)
    hold on
    plot(logper,log10(Q_bg_peak),'color',[R,0,B],'LineWidth',2);
    ylabel('log10 Q^-1 (bg + peak)'); xlabel('period [s]')
    ylim([-2.5,0.5])

    if isfield(data,'Qinv')
      theT=VBR.in.SV.T_K(iTemp);
      disp(['plotting data for T=',num2str(theT-273)])
      expQinvPer=log10(data.Qinv.period_s(data.Qinv.T_K==theT));
      expQinv=log10(data.Qinv.Qinv(data.Qinv.T_K==theT));
      expGPer=log10(data.G.period_s(data.G.T_K==theT));
      expG=data.G.G(data.G.T_K==theT);

      subplot(2,2,1)
      hold on
      plot(expGPer,expG,'.','color',[R,0,B],'markersize',10);
      subplot(2,2,3)
      hold on
      plot(expGPer,expG,'.','color',[R,0,B],'markersize',10);

      subplot(2,2,2)
      hold on
      plot(expQinvPer,expQinv,'.','color',[R,0,B],'markersize',10);
      subplot(2,2,4)
      hold on
      plot(expQinvPer,expQinv,'.','color',[R,0,B],'markersize',10);
    end
  end

  for ip=1:4
    subplot(2,2,ip)
    box on
  end
  saveas(gcf,'./figures/FJ10_eBurgers.eps','epsc')
end

function data = tryDataLoad()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataDir='../../../../vbrWork/expt_data/3_attenuation/FJ2010_data/';
  data=struct();
  if exist([dataDir,'eBurgersFig1.mat'],'file')
    disp('loading')
    load([dataDir,'eBurgersFig1.mat'])
    data.Qinv=Qinv;
    data.G=G;
  else
    disp('not loading')
  end
end
