function FitData_YT16()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % FitData_YT16()
  %
  % Plots viscosity, modulus, Qinv for borneol near the solidus temperature
  % following premelting scaling of Yamauchi and Takei, 2016, JGR.
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

  plot_visc();
  plot_Q();

end

function plot_Q()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % builds plot of Q for sample 41
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % load data if it exists
  viscData = loadYT2016visc();
  Qdata=loadYT2016Q();

  figure('DefaultAxesFontSize',12)
  OutVBR=struct();
  if viscData.has_data && Qdata.Qinv.has_data

    experimental_Ts=unique(Qdata.Qinv.T_C); % the temp conditions at which f was varied
    N=numel(experimental_Ts); % number of experimental P/T conditions
    clrs={'k','r','b','c','m','g','y'};
    samp=41;

    % loop over exp. conditions (T is varied only), calculate Q
    for iexp=1:N

      This_T_C=experimental_Ts(iexp);
      VBR.in=struct();
      VBR.in.elastic.methods_list={'anharmonic';'anh_poro'};
      VBR.in.viscous.methods_list={'xfit_premelt'};
      VBR.in.anelastic.methods_list={'xfit_premelt'};

      % pull this sample's viscData
      dg=viscData.visc.dg_um(viscData.visc.sample==samp)(1);
      T_Cvisc=viscData.visc.T_C(viscData.visc.sample==samp);
      eta=viscData.visc.eta(viscData.visc.sample==samp);
      [T_Cvisc,I]=sort(T_Cvisc); eta=eta(I);

      % set this sample's viscosity parameters
      VBR.in.viscous.xfit_premelt=setBorneolParams();
      VBR.in.viscous.xfit_premelt.dg_um_r=dg;
      VBR.in.viscous.xfit_premelt.Tr_K=T_Cvisc(1)+273;
      VBR.in.viscous.xfit_premelt.eta_r=eta(1);

      % set anharmonic conditions
      VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');
      [Gu_o,dGdT,dGdT_ave]= YT16_E(This_T_C);
      Gu_o=Gu_o-0.05;

      % Gu_o is for a given T, set anharmonic derives to 0
      VBR.in.elastic.anharmonic.Gu_0_ol = Gu_o;
      VBR.in.elastic.anharmonic.dG_dT = 0;
      VBR.in.elastic.anharmonic.dG_dP = 0;
      disp(['Calculating for T=',num2str(This_T_C)])
      disp(sprintf('  Gu(T=%0.1f C)=%0.3f GPa',This_T_C,Gu_o))

      % adjust some anelastic settings
      VBR.in.anelastic.xfit_premelt.tau_pp=2*1e-5;

      % set experimental conditions
      VBR.in.SV.T_K = This_T_C+273 ;
      sz=size(VBR.in.SV.T_K);
      VBR.in.SV.dg_um= dg.* ones(sz);
      VBR.in.SV.P_GPa = 1.0132e-04 .* ones(sz); % pressure [GPa]
      VBR.in.SV.rho =1011 .* ones(sz); % density [kg m^-3]
      VBR.in.SV.sig_MPa =1000 .* ones(sz)./1e6; % differential stress [MPa]
      VBR.in.SV.phi = zeros(sz); % melt fraction
      VBR.in.SV.Tsolidus_K = 43.0 + 273 ;
      VBR.in.SV.Ch2o_0=zeros(sz);

      VBR.in.SV.f=logspace(-4,2,50);

      samp_field=['sample_',num2str(samp)];

      % The pre-melting scaling takes into account the change in activation volume.
      % only want to use the lt 23 value
      VBR.in.viscous.xfit_premelt.H=viscData.table3_H.(samp_field).lt23.H*1e3;

      [VBR_bysamp] = VBR_spine(VBR);
      VBR_Q_samp=VBR_bysamp.out.anelastic.xfit_premelt.Qinv;
      VBR_G_samp=VBR_bysamp.out.anelastic.xfit_premelt.M/1e9;
      OutVBR(iexp).sampleVBR=VBR_bysamp;

      Q_obs=Qdata.Qinv.Qinv(Qdata.Qinv.T_C==This_T_C);
      Q_obs_f=Qdata.Qinv.f(Qdata.Qinv.T_C==This_T_C);
      E_obs=Qdata.E.E(Qdata.E.T_C==This_T_C);
      E_obs_f=Qdata.E.f(Qdata.E.T_C==This_T_C);

      if iexp > numel(clrs)
        icolor=iexp-numel(clrs);
        lnsty='--';
      else
        icolor=iexp;
        lnsty='';
      end
      clr=clrs{icolor};

      subplot(2,1,2)
      hold on
      loglog(Q_obs_f,Q_obs,'.','color',clr,'displayname',[num2str(dg),',',num2str(samp)],'MarkerSize',12)
      loglog(VBR.in.SV.f,VBR_Q_samp,[lnsty,clr],'displayname',[num2str(dg),',',num2str(samp)],'LineWidth',1.5)

      subplot(2,1,1)
      hold on
      semilogx(E_obs_f,E_obs,'.','color',clr,'displayname',[num2str(dg),',',num2str(samp)],'MarkerSize',12)
      semilogx(VBR.in.SV.f,VBR_G_samp,[lnsty,clr],'displayname',[num2str(dg),',',num2str(samp)],'LineWidth',1.5)

    end
    subplot(2,1,2)
    xlabel('f [Hz]'); ylabel('Q^{-1}')
    box on

    subplot(2,1,1)
    xlabel('f [Hz]'); ylabel('M [GPa]')
    box on

    saveas(gcf,'./figures/YT16_MQ.eps','epsc')
  else
    disp('This function requires data!')
  end

end

function plot_visc()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % builds plot of viscosity with parameters set by individual sample and
  % with a global fit of viscosity parameters
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  data = loadYT2016visc();
  figure('DefaultAxesFontSize',12)
  OutVBR=struct();
  if isfield(data,'visc')
    N=numel(data.visc.sample_list);
    dg_range=max(data.visc.dg_um)-min(data.visc.dg_um);

    clrs={'k','r','b','c','m','g','p'}
    for isamp=1:N

      VBR.in=struct();
      VBR.in.viscous.methods_list={'xfit_premelt'};

      % pull this sample's data
      samp=data.visc.sample_list(isamp);
      dg=data.visc.dg_um(data.visc.sample==samp)(1);
      T_C=data.visc.T_C(data.visc.sample==samp);
      eta=data.visc.eta(data.visc.sample==samp);

      [T_C,I]=sort(T_C); eta=eta(I);
      VBR.in.viscous.xfit_premelt=setBorneolParams();


      VBR.in.SV.T_K = T_C+273 ;
      sz=size(VBR.in.SV.T_K);
      VBR.in.SV.dg_um= dg * ones(sz);
      VBR.in.SV.P_GPa = zeros(sz); % pressure [GPa]
      VBR.in.SV.phi = zeros(sz); % melt fraction
      VBR.in.SV.Tsolidus_K = 43.0 + 273 ;

      samp_field=['sample_',num2str(samp)];
      disp(['Calculating ',samp_field])
      VBR.in.viscous.xfit_premelt.dg_um_r=dg;
      VBR.in.viscous.xfit_premelt.Tr_K=T_C(1)+273;
      VBR.in.viscous.xfit_premelt.eta_r=eta(1);

      % The pre-melting scaling takes into account the change in activation volume.
      % only want to use the lt 23 value
      VBR.in.viscous.xfit_premelt.H=data.table3_H.(samp_field).lt23.H*1e3;
      disp([samp_field,' lt: ',num2str(VBR.in.viscous.xfit_premelt.H)])
      [VBR_bysamp] = VBR_spine(VBR);
      VBReta=VBR_bysamp.out.viscous.xfit_premelt.diff.eta;
      OutVBR(isamp).sampleVBR=VBR_bysamp;

      VBR.in.viscous.xfit_premelt=setBorneolParams();
      [VBR] = VBR_spine(VBR);
      OutVBR(isamp).fullVBR=VBR;
      VBRetaGlob=VBR.out.viscous.xfit_premelt.diff.eta;

      clr=clrs{isamp};

      subplot(1,2,1)
      hold on
      semilogy(T_C,eta,'.','color',clr,'displayname',[num2str(dg),',',num2str(samp)],'MarkerSize',12)
      semilogy(T_C,VBReta,'color',clr,'displayname',[num2str(dg),',',num2str(samp)],'LineWidth',1.5)


      subplot(1,2,2)
      hold on
      semilogy(T_C,eta,'.','color',clr,'displayname',[num2str(dg),',',num2str(samp)],'MarkerSize',12)
      semilogy(T_C,VBRetaGlob,'color',clr,'displayname',[num2str(dg),',',num2str(samp)],'LineWidth',1.5)
    end
    subplot(1,2,1)
    title('H, dg\_ref, T\_ref, eta\_r set by sample')
    xlabel('T [C]'); ylabel('eta [Pa s]')
    legend('location','southwest')
    box on

    subplot(1,2,2)
    title('H=147 kJ/mol, dg\_ref=34.2 um, T\_ref=23 C, eta\_r=7e13 Pas')
    xlabel('T [C]'); ylabel('eta [Pa s]')
    box on

    saveas(gcf,'./figures/YT16_visc.eps','epsc')
  else
    disp('This function requires data!')
  end

end

function data = loadYT2016visc()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads experimental data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataDir='../../../../vbrWork/expt_data/3_attenuation/Yamauchi2016/';
  data=struct();
  if exist([dataDir,'table3.mat'],'file')
    disp('loading')
    load([dataDir,'table3.mat'])
    data.table3_H=table3_H;
  end

  if exist([dataDir,'viscosity_table2subset.csv'],'file')
    d=csvread([dataDir,'viscosity_table2subset.csv']);
    d=d(2:end,:);
    data.visc=struct();
    data.visc.sample=d(:,1);
    data.visc.dg_um=d(:,2);
    data.visc.T_C=d(:,3);
    data.visc.T_C_pm=d(:,4);
    data.visc.eta=d(:,5)*1e12;
    data.visc.sample_list=unique(data.visc.sample);
    data.has_data=1;
  else
    data.has_data=0;
  end

end

function data = loadYT2016Q()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % loads experimental data if available
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dataDir='../../../../vbrWork/expt_data/3_attenuation/Yamauchi2016/';
  data=struct();

  if exist([dataDir,'YT16_41_fQinv_allT.csv'],'file')
    d=csvread([dataDir,'YT16_41_fQinv_allT.csv']);
    d=d(2:end,:);
    data.Qinv=struct();
    data.Qinv.sample=d(:,1);
    data.Qinv.T_C=d(:,2);
    data.Qinv.f=d(:,3);
    data.Qinv.Qinv=d(:,4);
    data.Qinv.sample_list=unique(data.Qinv.sample);
    data.Qinv.has_data=1;
  else
    data.Qinv.has_data=0;
  end


  if exist([dataDir,'YT16_41_fE_allT.csv'],'file')
    d=csvread([dataDir,'YT16_41_fE_allT.csv']);
    d=d(2:end,:);
    data.E=struct();
    data.E.sample=d(:,1);
    data.E.T_C=d(:,2);
    data.E.f=d(:,3);
    data.E.E=d(:,4);
    data.E.sample_list=unique(data.E.sample);
    data.E.has_data=1;
  else
    data.E.has_data=0;
  end
end

function params = setBorneolParams()
  % set the general viscous parameters for borneol.
  % near-solidus and melt effects
  params.alpha=25;
  params.T_eta=0.94; % eqn 17,18- T at which homologous T for premelting.
  params.gamma=5;
  % flow law constants for YT2016
  params.Tr_K=23+273; % reference temp [K]
  params.Pr_Pa=0; % reference pressure [Pa]
  params.eta_r=7e13;% reference eta (eta at Tr_K, Pr_Pa)
  params.H=147*1e3; % activation energy [J/mol]
  params.V=0; % activation vol [m3/mol]
  params.R=8.314; % gas constant [J/mol/K]
  params.m=2.56; % grain size exponent
  params.dg_um_r=34.2 ; % eference grain size [um]
end

function [G,dGdT,dGdT_ave] = YT16_E(T_C)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [G,dGdT,dGdT_ave]= YT16_E(T_C)
  %
  % YT2016 Figure 6 caption polynomial fit of E vs T, T in degrees C
  %
  % parameters
  % ----------
  % T_C   temperature in deg C, any size array
  %
  % output
  % ------
  % G          modulus, GPa. same size as T_C
  % dGdT       temperature derivative of G at T_C, same size as T_C. [GPa/C]
  % dGdT_ave   average temp derivative over range of T_C given, scalar. [GPa/C].
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  a0=2.5943;
  a1=2.6911*1e-3;
  a2=-2.9636*1e-4;
  a3 =1.4932*1e-5;
  a4 =-2.9351*1e-7;
  a5 =1.8997*1e-9;
  a = [a5,a4,a3,a2,a1,a0];

  G=zeros(size(T_C));
  dGdT=zeros(size(T_C));
  for iTC=1:numel(T_C)
    Gpoly = polyval(a,T_C(iTC));
    dGdTpoly = polyval(a(1:end-1),T_C(iTC));
    G(iTC)=sum(Gpoly(:));
    dGdT(iTC)=sum(dGdTpoly(:));
  end
  dGdT_ave=mean(dGdT);

end
