function FitData_FJ10_Andrade()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % FitData_FJ10_Andrade()
  %
  % Reproduces figures 1e-1f from Jackson and Faul, PEPI 2010 (JF10):
  % moduli and Qinv vs period for a single sample, #6585, using coefficients for
  % the single sample fit in table 1 of JF10, for 900 to 1200 deg. C for
  % andrade pseudoperiod fit.
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
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); %
  VBR.in.anelastic.methods_list={'andrade_psp'};
  VBR.in.anelastic.andrade_psp=Params_Anelastic('andrade_psp');

  % JF10 have Gu_0=62.2 GPa, but that's at 900 Kelvin and 0.2 GPa,
  % so set Gu_0_ol s.t. it ends up at 62.2 at those conditions
  dGdT=VBR.in.elastic.anharmonic.dG_dT;
  dGdP=VBR.in.elastic.anharmonic.dG_dP;
  Tref=VBR.in.elastic.anharmonic.T_K_ref;
  Pref=VBR.in.elastic.anharmonic.P_Pa_ref/1e9;
  GUJF10=VBR.in.anelastic.andrade_psp.G_UR;
  VBR.in.elastic.anharmonic.Gu_0_ol = GUJF10 - (900+273-Tref) * dGdT/1e9 - (0.2-Pref)*dGdP; % olivine reference shear modulus [GPa]

  % frequencies to calculate at
  VBR.in.SV.f = 1./logspace(0,3,100);

  % set T range
  VBR.in.SV.T_K=900:50:1200;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;
  sz=size(VBR.in.SV.T_K); % temperature [K]

  % other SV's are constant
  VBR.in.SV.dg_um=3.1*ones(sz);
  VBR.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
  VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
  VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

  % run it
  [VBR] = VBR_spine(VBR) ;

  % load data if it exists
  data = tryDataLoad();

  %% ====================================================
  %% Display some things ================================
  %% ====================================================

  close all;
  fig=figure('Position', [10 10 600 200],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual');

  for iTemp = 1:numel(VBR.in.SV.T_K)

    M_bg=squeeze(VBR.out.anelastic.andrade_psp.M(1,iTemp,:)/1e9);
    Q_bg=squeeze(VBR.out.anelastic.andrade_psp.Qinv(1,iTemp,:));
    logper=log10(1./VBR.in.SV.f);
    R=(iTemp-1) / (numel(VBR.in.SV.T_K)-1);
    B=1 - (iTemp-1) / (numel(VBR.in.SV.T_K)-1);

    subplot(1,2,1)
    hold on
    plot(logper,M_bg,'color',[R,0,B],'LineWidth',1.5);
    ylabel('M [GPa] (bg only) '); xlabel('log10 period [s]')
    ylim([0,80])
    xlim([-2,4])

    subplot(1,2,2)
    hold on
    plot(logper,log10(Q_bg),'color',[R,0,B],'LineWidth',1.5);
    ylabel('log10 Q^-1 (bg only)'); xlabel('log10 period [s]')
    ylim([-2.5,0.5])
    xlim([-2,4])

    if isfield(data,'Qinv')
      theT=VBR.in.SV.T_K(iTemp);
      disp(['plotting data for T=',num2str(theT-273)])
      expQinvPer=log10(data.period_s(data.T_K==theT));
      expQinv=log10(data.Qinv(data.T_K==theT));
      expGPer=log10(data.period_s(data.T_K==theT));
      expG=data.G(data.T_K==theT);

      subplot(1,2,1)
      hold on
      plot(expGPer,expG,'.','color',[R,0,B],'markersize',6);


      subplot(1,2,2)
      hold on
      plot(expQinvPer,expQinv,'.','color',[R,0,B],'markersize',6);
    end
  end

  for ip=1:2
    subplot(1,2,ip)
    box on
  end
  saveas(gcf,'./figures/FJ10_Andrade.eps','epsc')
end

function data = tryDataLoad()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataDir='../../../../vbrWork/expt_data/3_attenuation/FJ2010_data/';
  data=struct();
  if exist([dataDir,'andrade_organized.csv'],'file')
    disp('loading')
    d=csvread([dataDir,'andrade_organized.csv']);
    d=d(2:end,:);
    data.T_K=d(:,1)+273;
    data.period_s=d(:,5);
    data.G=d(:,6);
    data.Qinv=d(:,8);
    data.T_list=unique(data.T_K);
    data.has_data=1;
  else
    data.has_data=0;
  end
end
