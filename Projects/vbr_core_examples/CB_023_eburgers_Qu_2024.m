function VBR = CB_023_eburgers_Qu_2024()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CB_023_eburgers_Qu_2024.m
  %
  % Demonstrates how to enable the fitting parameters from Qu et al 2024
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %%  write method list %%
  VBR.in.elastic.methods_list={'anharmonic'};
  VBR.in.anelastic.methods_list={'eburgers_psp';};

  %%  load anharmonic parameters, adjust Gu_0_ol %%
  % all params in ../vbr/vbrCore/params/ will be loaded in call to VBR spine,
  % but you can load them here and adjust any one of them (rather than changing
  % those parameter files).

  VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');

  % use the single sample background only fit:
  VBR.in.anelastic.eburgers_psp.eBurgerFit='Qu2024'; % 'bg_only' or 'bg_peak' or 's6585_bg_only'

  % frequencies to calculate at
  VBR.in.SV.f = 1./logspace(-2,4,100);

  %% Define the Thermodynamic State %%
  VBR.in.SV.T_K=800:50:1200;
  VBR.in.SV.T_K=VBR.in.SV.T_K+273;
  sz=size(VBR.in.SV.T_K); % temperature [K]

  % remaining state variables
  VBR.in.SV.dg_um=3.1*ones(sz);
  VBR.in.SV.P_GPa = 0.2 * ones(sz); % pressure [GPa]
  VBR.in.SV.rho = 3300 * ones(sz); % density [kg m^-3]
  VBR.in.SV.sig_MPa = 10 * ones(sz); % differential stress [MPa]
  VBR.in.SV.phi = 0.0 * ones(sz); % melt fraction

  %% call VBR_spine %%
  [VBR] = VBR_spine(VBR) ;

  %% build figure %%
  if ~vbr_tests_are_running()
    figure('PaperPosition',[0,0,8.5,4],'PaperPositionMode','manual');
    for iTemp = 1:numel(VBR.in.SV.T_K)

      M_out=squeeze(VBR.out.anelastic.eburgers_psp.M(1,iTemp,:)/1e9);
      Q_out=squeeze(VBR.out.anelastic.eburgers_psp.Qinv(1,iTemp,:));

      logper=log10(1./VBR.in.SV.f);
      R=(iTemp-1) / (numel(VBR.in.SV.T_K)-1);
      B=1 - (iTemp-1) / (numel(VBR.in.SV.T_K)-1);
      T_i = VBR.in.SV.T_K(iTemp);
      lab = [num2str(T_i-273), ' C'];
      subplot(1,2,1)
      hold on

      plot(logper,M_out,'color',[R,0,B],'LineWidth',2, 'displayname', lab);


      subplot(1,2,2)
      hold on
      plot(logper,log10(Q_out),'color',[R,0,B],'LineWidth',2,  'displayname', lab);


    end
    subplot(1,2,1)
    title("Qu et al 2024", 'Interpreter', 'none')
    ylabel('M [GPa] ')
    ylim([20,80])

    subplot(1,2,2)
    ylabel('Q^-1');
    ylim([-2.5,0.5])
    legend('location', 'northwest', 'NumColumns', 2)


    for ip = 1:2
      subplot(1,2,ip); box on;
      xlabel('period [s]')
    end
    saveas(gcf,'./figures/CB_023_eburgers_Qu_2024.png')
  end
end