function FitData_McCT11()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % generates figures following McCarthy, Takei, Hiraga, 2011 JGR (McCT11).
  %
  % Parameters
  % ----------
  % None
  %
  % Output
  % ------
  % figures to screen and to Projects/1_LabData/1_Attenuation/figures/
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % put VBR in the path
  path_to_top_level_vbr='../../../';
  addpath(path_to_top_level_vbr)
  vbr_init
  out_dir='./figures';

  % viscosity vs grain size plot
  Fig1=compare_viscosity(out_dir);

  % normalized relaxation spectrum plot
  Fig2=plot_relaxSpectrum(out_dir);

  % normalized J1, J2 plots
  Fig3 = plot_J1J2(out_dir);

  % temp dependence of M, Qinv vs freq
  Fig4 = plot_MQ_T_Fits('fit2',out_dir);
  Fig5 = plot_MQ_T_Fits('fit1',out_dir);

  % grain dependence of M, Qinv vs freq
  Fig6 = plot_MQ_dg_Fits('fit1',out_dir);
  Fig7 = plot_MQ_dg_Fits('fit2',out_dir);

end

function fig = plot_MQ_T_Fits(fit1_fit2,out_dir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plots M, Qinv vs frequency for temperatures of 23.7 and 45.4 C, fixed grain
  % size of 22 um. see figure 9 of McCT11.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % get data, VBR calculation
  [VBRs,Data] = calculate_MQ_T_Fits(fit1_fit2);

  % plotting
  include_E=1;

  fig=figure();
  fitval=VBRs(1).VBR.in.anelastic.xfit_mxw.fit;

  if include_E==1
    ax_E=subplot(2,2,1);
    ax_E_norm=subplot(2,2,2);
    ax_Qinv=subplot(2,2,3);
    ax_Qinv_norm=subplot(2,2,4);
  else
    ax_Qinv=subplot(1,2,1);
    ax_Qinv_norm=subplot(1,2,2);
  end

  clrs={'k';'r';'b';'c';'m';'y';'g'};

  % plot the VBR
  for iT=1:numel(VBRs)

    VBR=VBRs(iT).VBR;
    This_T_C=VBR.in.SV.T_K-273;
    fld=['T_',num2str(round(This_T_C))];
    clr=clrs{iT};
    ClrStruct.(fld)=clr;

    fd=VBR.in.SV.f;
    M=VBR.out.anelastic.xfit_mxw.M/1e9;
    Mnorm=VBR.out.anelastic.xfit_mxw.M./VBR.out.elastic.anharmonic.Gu;
    Qinv=VBR.out.anelastic.xfit_mxw.Qinv;
    fnorm=VBR.out.anelastic.xfit_mxw.f_norm;

    if include_E==1
      set(fig,'CurrentAxes',ax_E)
      hold on
      semilogx(fd,M,clr,'linewidth',1.5);

      set(fig,'CurrentAxes',ax_E_norm)
      hold on
      semilogx(fnorm,Mnorm,clr,'linewidth',1.5);
    end

    set(fig,'CurrentAxes',ax_Qinv)
    hold on
    loglog(fd,Qinv,clr,'linewidth',1.5);

    set(fig,'CurrentAxes',ax_Qinv_norm)
    hold on
    loglog(fnorm,Qinv,clr,'linewidth',1.5);
  end

  % plot the data
  if Data.fig9.has_data && Data.visc.has_data
    data=Data.fig9;
    ViscData=Data.visc;
    for iT=1:numel(data.T_list)
      This_T_C=data.T_list(iT);

      fld=['T_',num2str(round(This_T_C))];
      clr=ClrStruct.(fld);

      fd=data.f_Hz(data.T_C==This_T_C);
      fd(fd<1e-4)=1e-4; % correction for the data grab
      M=data.E_GPa(data.T_C==This_T_C);
      Qinv=data.Qinv(data.T_C==This_T_C);

      iVisc=find(ViscData.T_C==This_T_C);
      mxwll=ViscData.tau_m_s(iVisc);
      fnorm=1./mxwll;
      Gfac=1./ViscData.GU_at_T_GPa(iVisc);

      if include_E==1
        set(fig,'CurrentAxes',ax_E)
        hold on
        semilogx(fd,M,['.',clr],'displayname','none','MarkerSize',10);

        set(fig,'CurrentAxes',ax_E_norm)
        hold on
        semilogx(fd/fnorm,M*Gfac,['.',clr],'displayname','none','MarkerSize',10);
      end

      set(fig,'CurrentAxes',ax_Qinv)
      hold on
      loglog(fd,Qinv,['.',clr],'MarkerSize',10);

      set(fig,'CurrentAxes',ax_Qinv_norm)
      hold on
      loglog(fd/fnorm,Qinv,['.',clr],'MarkerSize',10);
    end
  end

  if include_E==1
    set(fig,'CurrentAxes',ax_E)
    box on
    xlabel('f [Hz]'); ylabel('E [GPa]')
    ylim([.5,3])
    xlim([1e-4,10])
    set(gca,'XMinorTick','on')

    set(fig,'CurrentAxes',ax_E_norm)
    box on
    xlabel('f_N'); ylabel('E / E_U')
    ylim([0,1])
    xlim([1e-1,1e5])
    set(gca,'XMinorTick','on')
  end

  set(fig,'CurrentAxes',ax_Qinv)
  box on
  xlabel('f [Hz]'); ylabel('Qinv')
  xlim([1e-4,10])
  ylim([1e-2,2])
  set(gca,'XMinorTick','on','YMinorTick','on')

  set(fig,'CurrentAxes',ax_Qinv_norm)
  box on
  xlabel('f_N'); ylabel('Qinv')
  xlim([1e-1,1e5])
  ylim([1e-2,2])
  set(gca,'XMinorTick','on','YMinorTick','on')

  saveas(gcf,[out_dir,'/McCT11_MQ_v_T_',fit1_fit2,'.eps'],'epsc')
end

function [VBRs,Data] = calculate_MQ_T_Fits(fit1_fit2)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calculations for temperatures of 23.7 and 45.4 C, fixed grain size of 22 um.
  % see figure 9 of McCT11.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % load the data
  Data.visc = tryDataLoadVisc();
  Data.fig9 = tryDataLoadFig9();

  % calculate VBR for expt conditions
  if Data.fig9.has_data
    T_list=Data.fig9.T_list;
  else
    T_list=[23.7,45.4];
  end

  for iT=1:numel(T_list)
    This_T_C=T_list(iT);

    % anharmonic parameters
    VBR.in.elastic.methods_list={'anharmonic'};
    VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');

    if Data.visc.has_data
      % pull ref modulus at elevated T directly from table 1
      iVisc=find(Data.visc.T_C==This_T_C);
      VBR.in.elastic.anharmonic.Gu_0_ol = Data.visc.GU_at_T_GPa(iVisc);
      VBR.in.elastic.anharmonic.dG_dT = 0;
    else
      % estimate from figure 9 Eu lines
      Gu_40=2.4;
      Gu_20=2.5;
      dGdT=(Gu_40-Gu_20)/20*1e9;
      Tref=20;
      VBR.in.elastic.anharmonic.Gu_0_ol = Gu_40;
      VBR.in.elastic.anharmonic.dG_dT = dGdT;
      VBR.in.elastic.anharmonic.T_K_ref = 20+273;
    end
    VBR.in.elastic.anharmonic.dG_dP = 0;

    % viscous parameters
    VBR.in.viscous.methods_list={'xfit_premelt'}; % far enough from solidus, A terms will go to 1
    VBR.in.viscous.xfit_premelt=SetBorneolParamsMcCT_gt7();

    % anelastic parameters
    VBR.in.anelastic.methods_list={'xfit_mxw'};
    VBR.in.anelastic.xfit_mxw.fit=fit1_fit2;

    % set state variables
    VBR.in.SV.T_K = This_T_C +273 ; % temperature [K]
    VBR.in.SV.dg_um = 22; % grain size
    VBR.in.SV.P_GPa = 1000 / 1e9 ; % pressure [GPa] (does not affect this calc)
    VBR.in.SV.rho = 1000; % density [kg m^-3] (does not affect this calc)
    VBR.in.SV.phi = 0; % melt fraction
    VBR.in.SV.Tsolidus_K = (204.5 + 273) ; % solidus of pure borneol
    VBR.in.SV.f=logspace(-4,1,50);
    [VBR] = VBR_spine(VBR);
    VBRs(iT).VBR=VBR;
  end

end

function [VBRs] = calculate_J1J2Fits()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calculations for sample 15, fixed grain size of 8 um at exp. conditions
  % given by table 1 of McCT11. for figure 15 of McCT11
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % anharmonic parameters
  VBR.in.elastic.methods_list={'anharmonic'};
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticit
  VBR.in.elastic.anharmonic.Gu_0_ol = 1.87; % from table 1 maxwell time / visc
  VBR.in.elastic.anharmonic.dG_dT = 0;
  VBR.in.elastic.anharmonic.dG_dP = 0;

  % viscous parameters
  VBR.in.viscous.methods_list={'xfit_premelt'}; % far enough from solidus, A terms will go to 1
  VBR.in.viscous.xfit_premelt=SetBorneolParamsMcCT_lt7();

  % anelastic parameters
  VBR.in.anelastic.methods_list={'xfit_mxw'};

  % set state variables
  VBR.in.SV.T_K = 22.4 +273 ; % temperature [K], table 1
  VBR.in.SV.dg_um = 8; % grain size
  VBR.in.SV.P_GPa = 1000 / 1e9 ; % pressure [GPa] (does not affect this calc)
  VBR.in.SV.rho = 1000; % density [kg m^-3] (does not affect this calc)
  VBR.in.SV.phi = 0; % melt fraction
  VBR.in.SV.Tsolidus_K = (204.5 + 273) ; % solidus of pure borneol
  VBR.in.SV.f=logspace(-6,10,50);
  [VBR] = VBR_spine(VBR);
  VBRs.fit1.VBR=VBR;

  VBR.in.anelastic.xfit_mxw.fit='fit2';
  [VBR] = VBR_spine(VBR);
  VBRs.fit2.VBR=VBR;

end

function fig = plot_relaxSpectrum(out_dir)

  fig = figure();

  tau_norm=logspace(-14,1,100);
  % plot the relexation spectrum
  params=Params_Anelastic('xfit_mxw');
  [X_tau] = Q_xfit_mxw_xfunc(tau_norm,params);
  hold all
  loglog(tau_norm,X_tau,'LineWidth',1.5,'r');

  params.fit='fit2';
  [X_tau] = Q_xfit_mxw_xfunc(tau_norm,params);
  loglog(tau_norm,X_tau,'LineWidth',1.5,'b');

  relaxData=tryDataLoadRelax();
  if relaxData.has_data
    loglog(relaxData.relax_fit1_pts.tau_norm,relaxData.relax_fit1_pts.relax_fit1_pts,'.r')
    loglog(relaxData.relax_fit2_pts.tau_norm,relaxData.relax_fit2_pts.relax_fit2_pts,'.b')
    p1=relaxData.relax_PREM_pts.relax_PREM_pts(1);
    loglog(relaxData.relax_PREM_pts.tau_norm,[p1,p1],'k','linewidth',5)
    loglog(relaxData.relax_data_dg3to8.tau_norm,relaxData.relax_data_dg3to8.relax_data_dg3to8,'.k','MarkerSize',10)
  end

  xlabel('normalized time scale')
  ylabel('normalized relaxation spectrum')
  ylim([1e-4,2])
  xlim([1e-14,1e1])
  set(gca,'Xdir','reverse','XMinorTick','on','YMinorTick','on')
  saveas(gcf,[out_dir,'/McCT11_relaxation_spectrum.eps'],'epsc')
end


function fig = plot_MQ_dg_Fits(fit1_fit2,out_dir)
  % plot of modulus, Qinv vs freq at different grain sizes
  [VBR,data]=calculate_MQ_dg_Fits(fit1_fit2);
  ViscData=tryDataLoadVisc();
  % plot
  % plotting
  include_E=1;

  fig=figure();
  fitval=VBR.in.anelastic.xfit_mxw.fit;

  if include_E==1
    ax_E=subplot(2,2,1);
    ax_E_norm=subplot(2,2,2);
    ax_Qinv=subplot(2,2,3);
    ax_Qinv_norm=subplot(2,2,4);
  else
    ax_Qinv=subplot(1,2,1);
    ax_Qinv_norm=subplot(1,2,2);
  end

  clrs={'k';'r';'b';'c';'m';'y';'g'};

  % plot the VBR
  for idg=1:numel(VBR.in.SV.dg_um)

    This_dg=VBR.in.SV.dg_um(idg);
    fld=['dg_',num2str(round(This_dg))];
    clr=clrs{idg};
    ClrStruct.(fld)=clr;

    fd=VBR.in.SV.f;
    M=squeeze(VBR.out.anelastic.xfit_mxw.M(1,idg,:))/1e9;
    Mnorm=M;%squeeze(VBR.out.anelastic.xfit_mxw.M(1,idg,:)./VBR.out.elastic.anharmonic.Gu(1,idg,:));
    Qinv=squeeze(VBR.out.anelastic.xfit_mxw.Qinv(1,idg,:));
    fnorm=squeeze(VBR.out.anelastic.xfit_mxw.f_norm(1,idg,:));

    if include_E==1
      set(fig,'CurrentAxes',ax_E)
      hold on
      semilogx(fd,M,clr,'linewidth',1.5);

      set(fig,'CurrentAxes',ax_E_norm)
      hold on
      semilogx(fnorm,Mnorm,clr,'linewidth',1.5);
    end

    set(fig,'CurrentAxes',ax_Qinv)
    hold on
    loglog(fd,Qinv,clr,'linewidth',1.5);

    set(fig,'CurrentAxes',ax_Qinv_norm)
    hold on
    loglog(fnorm,Qinv,clr,'linewidth',1.5);
  end

  % plot the data
  if data.has_data && ViscData.has_data
    for idg=1:numel(data.d_vec)

      This_dg=data.d_vec(idg);
      This_T_C=data.McCT11(idg).exptCond.T_C;
      fd=data.McCT11(idg).exptCond.f;
      M=data.McCT11(idg).Results.E;
      Qinv=data.McCT11(idg).Results.Qinv;

      iVisc=find((ViscData.sample==16) & (ViscData.dg_um==This_dg));
      mxwll=ViscData.tau_m_s(iVisc);
      fnorm=1./mxwll;
      Gfac=1;%1./2.47;

      fld=['dg_',num2str(round(This_dg))];
      clr=ClrStruct.(fld);
      if include_E==1
        set(fig,'CurrentAxes',ax_E)
        hold on
        semilogx(fd,M,['.',clr],'displayname','none','MarkerSize',10);

        set(fig,'CurrentAxes',ax_E_norm)
        hold on
        semilogx(fd/fnorm,M*Gfac,['.',clr],'displayname','none','MarkerSize',10);
      end

      set(fig,'CurrentAxes',ax_Qinv)
      hold on
      loglog(fd,Qinv,['.',clr],'MarkerSize',10);

      set(fig,'CurrentAxes',ax_Qinv_norm)
      hold on
      loglog(fd/fnorm,Qinv,['.',clr],'MarkerSize',10);
    end
  end

  if include_E==1
    set(fig,'CurrentAxes',ax_E)
    box on
    xlabel('f [Hz]'); ylabel('E [GPa]')
    ylim([.5,3])
    xlim([1e-4,10])
    set(gca,'XMinorTick','on')

    set(fig,'CurrentAxes',ax_E_norm)
    box on
    xlabel('f_N'); ylabel('E [GPa]')
    ylim([.5,3])
    xlim([1e-1,1e5])
    set(gca,'XMinorTick','on')
  end

  set(fig,'CurrentAxes',ax_Qinv)
  box on
  xlabel('f [Hz]'); ylabel('Qinv')
  xlim([1e-4,10])
  ylim([1e-2,2])
  set(gca,'XMinorTick','on','YMinorTick','on')

  set(fig,'CurrentAxes',ax_Qinv_norm)
  box on
  xlabel('f_N'); ylabel('Qinv')
  xlim([1e-1,1e5])
  ylim([1e-2,2])
  set(gca,'XMinorTick','on','YMinorTick','on')

  saveas(gcf,[out_dir,'/McCT11_MQ_v_dg_',fit1_fit2,'.eps'],'epsc')

end

function [VBR,data] = calculate_MQ_dg_Fits(fit1_fit2)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plots J1 / Ju, J2 / Ju vs frequcny for grain size of 8 um, see figure 15 of
  % McCT11
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  data = tryDataLoad_MQdg();

  if data.has_data
    d_vec=data.d_vec;
    This_T_C=data.McCT11(1).exptCond.T_C;
  else
    d_vec=[4.3,6.3];
    This_T_C=23;
  end

  % set anharmonic
  VBR.in.elastic.methods_list={'anharmonic'};
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
  Gu_40=2.4;
  Gu_20=2.5;
  dGdT=(Gu_40-Gu_20)/20*1e9;
  Tref=20;
  VBR.in.elastic.anharmonic.Gu_0_ol = Gu_40;
  VBR.in.elastic.anharmonic.dG_dT = dGdT;
  VBR.in.elastic.anharmonic.T_K_ref = 20+273;

  VBR.in.elastic.anharmonic.Gu_0_ol = 2.9;
  VBR.in.elastic.anharmonic.dG_dT = 0;
  VBR.in.elastic.anharmonic.T_K_ref = 300;

  % set viscous
  VBR.in.viscous.methods_list={'xfit_premelt'}; %VBR.in.viscous.methods_list={'xfit_premelt'};
  VBR.in.viscous.xfit_premelt=SetBorneolParamsMcCT_lt7();
  VBR.in.viscous.xfit_premelt.Tr_K=23.5+273; %
  VBR.in.viscous.xfit_premelt.eta_r=4.09*1e12; %
  VBR.in.viscous.xfit_premelt.H=85.4*1e3; % activation energy [J/mol], figure 20 of YT2016
  VBR.in.viscous.xfit_premelt.m=3; % grain size exponent
  VBR.in.viscous.xfit_premelt.dg_um_r=4.3 ; % caption of Fig 9. % 24.4; % reference grain size [um]

  % set mxw
  VBR.in.anelastic.methods_list={'xfit_mxw'};

  VBR.in.SV.f = logspace(-4,1,50);
  VBR.in.SV.dg_um= d_vec ; %data.McCT11(1).exptCond.dg_0 .* ones(sz) ;
  VBR.in.SV_vectors.d_vec_dim1 = VBR.in.SV.dg_um ;
  sz=size(VBR.in.SV.dg_um) ;

  %  remaining state variables (ISV)
  VBR.in.SV.T_K = This_T_C +273 .* ones(sz); % pressure [GPa]
  VBR.in.SV.P_GPa = zeros(sz); % pressure [GPa] (no effect)
  VBR.in.SV.rho = 1000 .* ones(sz); % density [kg m^-3] (no effect on M, Q)
  VBR.in.SV.phi =zeros(sz); % melt fraction
  VBR.in.SV.Tsolidus_K = 204.5 + 273 ;

  [VBR] = VBR_spine(VBR) ;

end

function fig = plot_J1J2(out_dir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plots J1 / Ju, J2 / Ju vs frequcny for grain size of 8 um, see figure 15 of
  % McCT11
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % get the fit!
  [VBRs] = calculate_J1J2Fits();
  data=tryDataLoadRelax();

  % plotting
  fig=figure('Position', [10 10 600 300],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual');
  ax_j1=subplot(1,2,1);
  ax_j2=subplot(1,2,2);

  set(gcf,'CurrentAxes',ax_j1)
  JU=1./VBRs.fit1.VBR.out.elastic.anharmonic.Gu;
  Fn=VBRs.fit1.VBR.out.anelastic.xfit_mxw.f_norm;
  semilogx(Fn,VBRs.fit1.VBR.out.anelastic.xfit_mxw.J1/JU,'r','linewidth',1.5)

  hold on;
  semilogx(Fn,VBRs.fit2.VBR.out.anelastic.xfit_mxw.J1/JU,'--r','linewidth',1.5)

  set(gcf,'CurrentAxes',ax_j2)
  loglog(Fn,VBRs.fit1.VBR.out.anelastic.xfit_mxw.J2/JU,'b','linewidth',1.5)
  hold on
  loglog(Fn,VBRs.fit2.VBR.out.anelastic.xfit_mxw.J2/JU,'--b','linewidth',1.5)


  if data.has_data
    set(gcf,'CurrentAxes',ax_j1)
    hold on;
    semilogx(data.j1_data.fnorm,data.j1_data.j1_data,'.k','MarkerSize',10)

    set(gcf,'CurrentAxes',ax_j2)
    hold on
    loglog(data.j2_data.fnorm,data.j2_data.j2_data,'.k','MarkerSize',10)
  end

  xticks=-1:1:11;
  xlabs={};
  for ix = 1:numel(xticks);
    if mod(xticks(ix),2)~=0
      xlabs{ix}=['1e',num2str(xticks(ix))];
    else
      xlabs{ix}='';
    end
  end

  set(gcf,'CurrentAxes',ax_j1)
  xlabel('normalized frequency')
  ylabel('J1 / Ju')
  xlim([1e-1,1e11])
  ylim([1,3])
  set(gca,'XMinorTick','on','YMinorTick','on','xticklabel',xlabs)

  set(gcf,'CurrentAxes',ax_j2)
  xlabel('normalized frequency')
  ylabel('J2 / Ju')
  xlim([1e-1,1e11])
  ylim([1e-4,2])
  set(gca,'XMinorTick','on','YMinorTick','on','xticklabel',xlabs)

  saveas(gcf,[out_dir,'/McCT11_normalized_J1J2.eps'],'epsc')

end

function fig = compare_viscosity(out_dir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plots viscosity vs. grain size, figure 8 of McCT11
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % pull the data
  data = tryDataLoadVisc();

  if data.has_data
    eta=data.eta_a((data.T_C>=22.3)&(data.T_C<=23.7));
    dg=data.dg_um((data.T_C>=22.3)&(data.T_C<=23.7));
    dg=dg(eta>0);
    eta=eta(eta>0);

    etab=data.eta_b((data.T_C>=22.3)&(data.T_C<=23.7));
    dgb=data.dg_um((data.T_C>=22.3)&(data.T_C<=23.7));
    dgb=dgb(etab>0);
    etab=etab(etab>0);
  end

  % VBR calc for dg_um > 7
  T_C=mean([22.3,23.7]);
  % viscous parameters
  VBR.in.viscous.methods_list={'xfit_premelt'}; %VBR.in.viscous.methods_list={'xfit_premelt'};
  VBR.in.viscous.xfit_premelt=SetBorneolParamsMcCT_gt7();
  VBR.in.SV.dg_um = logspace(0,2,100); % grain size
  VBR.in.SV.T_K = (T_C +273 ); % temperature [K]
  VBR.in.SV.P_GPa = 1000 / 1e9 ; % pressure [GPa] (does not affect this calc)
  VBR.in.SV.phi = 0; % melt fraction
  VBR.in.SV.Tsolidus_K = (204.5 + 273) ; % solidus of pure borneol
  [VBR_gt7] = VBR_spine(VBR) ;

  % VBR calc for dg_um < 7
  VBR.in.viscous.xfit_premelt=SetBorneolParamsMcCT_lt7();
  [VBR] = VBR_spine(VBR) ;

  % plot it
  fig=figure();
  loglog(VBR_gt7.in.SV.dg_um,VBR_gt7.out.viscous.xfit_premelt.diff.eta,'b','LineWidth',1.5)
  hold on
  loglog(VBR.in.SV.dg_um,VBR.out.viscous.xfit_premelt.diff.eta,'r','LineWidth',1.5)
  if data.has_data
    loglog(dgb(dgb>=7),etab(dgb>=7),'.b','MarkerSize',10);
    loglog(dgb(dgb<7),etab(dgb<7),'.r','MarkerSize',10);
  end

  ylim([1e12,1e15])
  xlim([1e0,1e2])
  xlabel('Grain Size [um]')
  ylabel('Viscosity [Pa s]')
  title('T between 22.3, 23.7 C')

  saveas(gcf,[out_dir,'/McCT11_viscosity.eps'],'epsc')
end

function data = tryDataLoad_MQdg()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads experimental data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  dataDir='../../../../vbrWork/expt_data/3_attenuation/';
  if ~exist([dataDir,'ExptData.mat'],'file')
    data.has_data=0;
  else
    load([dataDir,'ExptData.mat']);
    data = Data ;
    data.has_data=1;
    for i=1:length(data.McCT11)
      d_vec(i) = data.McCT11(i).exptCond.dg  ;
    end
    data.d_vec=d_vec;
  end
end

function data = tryDataLoadVisc()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads experimental data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataDir='../../../../vbrWork/expt_data/3_attenuation/McCT11/McCT11_new/';
  data=struct();
  if exist([dataDir,'McCT11_table1.csv'],'file')
    d=csvread([dataDir,'McCT11_table1.csv']);
    d=d(2:end,:);
    % sample	dg_um	T_C	eta_Pas_a	eta_Pas_b	eta_ave_Pas	tau_m_s	strain	GU_at_T_Gpa
    flds={'sample';'dg_um';'T_C';'eta_a';'eta_b';'eta_Pas';'tau_m_s';'strain';'GU_at_T_GPa'};
    for ifld=1:numel(flds)
      if ~strcmp(flds{ifld},'skip')
        data.(flds{ifld})=d(:,ifld);
      end
    end
    data.T_list=unique(data.T_C);
    data.dg_list=unique(data.dg_um);
    data.sample_list=unique(data.sample);
    data.has_data=1;
  else
    data.has_data=0;
  end

end

function data = tryDataLoadRelax();
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads experimental data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data=struct();

  dataDir='../../../../vbrWork/expt_data/3_attenuation/McCT11/McCT11_new/';
  fi_list={'j1_data';'j1_fit1';'j1_fit2';'j2_data';'j2_fit1';'j2_fit2';...
           'relax_fit1_pts';'relax_fit2_pts';'relax_PREM_pts';'relax_data_dg3to8'};
  data.has_data=1;
  for ifi=1:numel(fi_list)
    fl=fi_list{ifi};
    if exist([dataDir,fl,'.csv'])
      d=csvread([dataDir,fl,'.csv']);
      if numel(strfind(fl,'relax')>0)
        data.(fl).tau_norm=d(:,1);
        data.(fl).(fl)=d(:,2);
      else
        data.(fl).fnorm=d(:,1);
        data.(fl).(fl)=d(:,2);
      end
    else
      data.has_data=0;
    end
  end

end

function data = tryDataLoadFig9()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads experimental data if available from fig 9: Qinv, E vs freq at constant
  % grain size, varying T
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  dataDir='../../../../vbrWork/expt_data/3_attenuation/McCT11/McCT11_new/';
  data=struct();
  if exist([dataDir,'sample_15_Tdependence_fig9.csv'],'file')
    d=csvread([dataDir,'sample_15_Tdependence_fig9.csv']);
    d=d(2:end,:);
    data.T_C=d(:,1);
    data.f_Hz=d(:,4);
    data.Qinv=d(:,5);
    data.E_GPa=d(:,6);
    data.T_list=unique(data.T_C);
    data.has_data=1;
  else
    data.has_data=0;
  end

end

function params = SetBorneolParamsMcCT_gt7()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % params = SetBorneolParamsMcCT_gt7()
  % loads borneol flow law constants for grain sizes greater than 7 um
  %
  % the viscosity is calculated using form of YT16, but the solidus of pure
  % borneol in McCT is sufficiently high compared to experimental conditions
  % that the melt term reduces to 1.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % near-solidus and melt effects
  params.alpha=0;
  params.T_eta=0.94; % eqn 17,18- T at which homologous T for premelting.
  params.gamma=5;

  % flow law constants for YT2016
  params.Tr_K=22.5+273; %
  params.Pr_Pa=1000; % p7817 of YT2016, second paragraph
  params.eta_r=5.25*1e13; %
  params.H=85.4*1e3; % activation energy [J/mol], figure 20 of YT2016
  params.V=0; % activation vol [m3/mol], figure 20 of YT2016
  params.R=8.314; % gas constant [J/mol/K]
  params.m=1; % grain size exponent
  params.dg_um_r=21.4 ; % reference grain size [um]
end

function params = SetBorneolParamsMcCT_lt7()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % params = SetBorneolParamsMcCT_lt7()
  % loads borneol flow law constants for grain sizes less than 7 um
  %
  % the viscosity is calculated using form of YT16, but the solidus of pure
  % borneol in McCT is sufficiently high compared to experimental conditions
  % that the melt term reduces to 1.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % near-solidus and melt effects
  params.alpha=0;
  params.T_eta=0.94; % eqn 17,18- T at which homologous T for premelting.
  params.gamma=5;
  % flow law constants for YT2016
  params.Tr_K=23.6+273; %
  params.Pr_Pa=1000; % p7817 of YT2016, second paragraph
  params.eta_r=2.04*1e12; %
  params.H=85.4*1e3; % activation energy [J/mol], figure 20 of YT2016
  params.V=0; % activation vol [m3/mol], figure 20 of YT2016
  params.R=8.314; % gas constant [J/mol/K]
  params.m=3; % grain size exponent
  params.dg_um_r=3.35 ; % caption of Fig 9. % 24.4; % reference grain size [um]
end
