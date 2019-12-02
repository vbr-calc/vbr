function buildComparisons(Box,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % buildComparisons(Box,figDir)
  %
  % compares anelastic methods, generates some figures
  %
  % Parameters
  % ----------
  % Box          the VBR box
  % figDir       directory to save figures to
  %
  % Output
  % ------
  % none         (figures written to file)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  close all
  plotBoxes(Box,figDir); % depth profiles
  plotQBoxes(Box,figDir); % Q depth profiles
  plotVsBoxes(Box,figDir); % Vs depth profiles
  plotComparisons(Box,figDir); % comparisons of anelastic methods
  close all
end

function plotQBoxes(Box,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotQBoxes(Box,figDir)
  %
  % plots Qinv profiles for each box
  %
  % Parameters
  % ----------
  % Box          the VBR box
  % figDir       directory to save figures to
  %
  % Output
  % ------
  % none         (figures to screen, written to file)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  close all
  ts=0:1:40;

  for iBox=1:numel(Box)
    B=Box(iBox);
    z=B.run_info.Z_km;

    fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8);

    meths=meths=fieldnames(B.VBR.out.anelastic);
    Nmeths=numel(meths);
    Nfreqs=numel(B.VBR.in.SV.f);
    for ifreq=1:Nfreqs
      for imeth=1:Nmeths
        iplt=imeth+Nmeths*(ifreq-1);
        ax_container(imeth,ifreq)=subplot(Nfreqs,Nmeths,iplt);
      end
    end

    tMyr=B.run_info.tMyrs;
    for t_indx=1:numel(ts)
      [val,indx]=min(abs(ts(t_indx)-tMyr));

      R=tMyr(indx) / max(ts);
      R=R*(R<=1)+1*(R>1);
      RGB=[R,0,1-R];

      for ifreq=1:Nfreqs
        for imeth=1:Nmeths
          meth=meths{imeth};
          iplt=imeth+Nmeths*(ifreq-1);
          set(fig,'currentaxes',ax_container(imeth,ifreq))
          hold on
          plot(log10(B.VBR.out.anelastic.(meth).Q(:,indx,ifreq)),z,'color',RGB)
        end
      end
    end

    for ifreq=1:Nfreqs
      for imeth=1:Nmeths
        meth=meths{imeth};
        iplt=imeth+Nmeths*(ifreq-1);
        set(fig,'currentaxes',ax_container(imeth,ifreq))
        xlabel('log10(Q)')
        ylabel('depth [km]')
        title([strrep(meth,'_','\_'),' ',num2str(B.VBR.in.SV.f(ifreq))])
        set(gca,'ydir','reverse','box','on')
        xlim([1,6])
        ylim([0,200])
      end
    end

    saveas(gcf,[figDir,'/Box_',num2str(iBox),'_Qprofiles.png'])
  end
end

function plotVsBoxes(Box,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotVsBoxes(Box,figDir)
  %
  % plots Vs profiles for each box, method, freq
  %
  % Parameters
  % ----------
  % Box          the VBR box
  % figDir       directory to save figures to
  %
  % Output
  % ------
  % none         (figures to screen, written to file)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  close all
  ts=0:1:40;

  for iBox=1:numel(Box)
    B=Box(iBox);
    z=B.run_info.Z_km;

    fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8);

    meths=meths=fieldnames(B.VBR.out.anelastic);
    Nmeths=numel(meths);
    Nfreqs=numel(B.VBR.in.SV.f);
    for ifreq=1:Nfreqs
      for imeth=1:Nmeths
        iplt=imeth+Nmeths*(ifreq-1);
        ax_container(imeth,ifreq)=subplot(Nfreqs,Nmeths,iplt);
      end
    end

    tMyr=B.run_info.tMyrs;
    for t_indx=1:numel(ts)
      [val,indx]=min(abs(ts(t_indx)-tMyr));

      R=tMyr(indx) / max(ts);
      R=R*(R<=1)+1*(R>1);
      RGB=[R,0,1-R];

      for ifreq=1:Nfreqs
        for imeth=1:Nmeths
          meth=meths{imeth};
          iplt=imeth+Nmeths*(ifreq-1);
          set(fig,'currentaxes',ax_container(imeth,ifreq))
          hold on
          plot((B.VBR.out.anelastic.(meth).V(:,indx,ifreq))/1e3,z,'color',RGB)
        end
      end
    end

    for ifreq=1:Nfreqs
      for imeth=1:Nmeths
        meth=meths{imeth};
        iplt=imeth+Nmeths*(ifreq-1);
        set(fig,'currentaxes',ax_container(imeth,ifreq))
        xlabel('Vs [km/s]')
        ylabel('depth [km]')
        title([strrep(meth,'_','\_'),' ',num2str(B.VBR.in.SV.f(ifreq))])
        set(gca,'ydir','reverse','box','on')
        xlim([4,5])
        ylim([0,200])
      end
    end

    saveas(gcf,[figDir,'/Box_',num2str(iBox),'_Vsprofiles.png'])
  end
end

function plotBoxes(Box,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotBoxes(Box,figDir)
  %
  % plots profiles for each box
  %
  % Parameters
  % ----------
  % Box          the VBR box
  % figDir       directory to save figures to
  %
  % Output
  % ------
  % none         (figures to screen, written to file)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  close all
  ts=0:1:40;

  for iBox=1:numel(Box)
    B=Box(iBox);
    z=B.run_info.Z_km;

    fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8);
    ax_T=subplot(1,4,1);
    ax_phi=subplot(1,4,2);
    ax_eta=subplot(1,4,3);
    ax_V=subplot(1,4,4);

    set(fig,'currentaxes',ax_T)
    plot(B.VBR.in.SV.Tsolidus_K(:,1)-273,z,'k')

    tMyr=B.run_info.tMyrs;

    for t_indx=1:numel(ts)
      [val,indx]=min(abs(ts(t_indx)-tMyr));

      R=tMyr(indx) / max(ts);
      R=R*(R<=1)+1*(R>1);
      RGB=[R,0,1-R];

      % temperature v depth
      set(fig,'currentaxes',ax_T)
      hold on
      plot(B.VBR.in.SV.T_K(:,indx)-273,z,'color',RGB)

      % phi v depth
      set(fig,'currentaxes',ax_phi)
      hold on
      plot(B.VBR.in.SV.phi(:,indx),z,'color',RGB)

      % eta v depth
      set(fig,'currentaxes',ax_eta)
      hold on
      plot(log10(B.VBR.out.viscous.HK2003.eta_total(:,indx)),z,'color',RGB)

      % Vs averaged over methods and frequencies
      meths=fieldnames(B.VBR.out.anelastic);
      Vave=zeros(size(B.VBR.in.SV.phi(:,indx)));
      for imeth =1:numel(meths)
        meth=meths{imeth};
        Vave=Vave+B.VBR.out.anelastic.(meth).Vave(:,indx);
      end
      Vave=Vave / numel(meths);

      set(fig,'currentaxes',ax_V)
      hold on
      plot(Vave/1e3,z,'color',RGB)

    end

    set(fig,'currentaxes',ax_phi)
    xlim([0,0.015])
    phiticks=[0,0.005,0.01];
    set(ax_phi,'xtick',phiticks,'xticklabel',phiticks,'yticklabel',{})
    xlabel('\phi')
    set(ax_phi,'ydir','reverse')
    box on

    set(fig,'currentaxes',ax_eta)
    set(ax_eta,'ydir','reverse','yticklabel',{})
    xlabel('log10(\eta) [Pa s]')
    xlim([17,26])
    box on

    set(fig,'currentaxes',ax_V)
    set(ax_V,'ydir','reverse','yticklabel',{})
    xlabel('V_s [km/s]')
    xlim([3.8,4.8])
    title('freq-method average')
    box on

    set(fig,'currentaxes',ax_T)
    xlabel('T [C]')
    ylabel('Depth [km]')
    title([B.info.var1name,'=',num2str(B.info.var1val),B.info.var1units])
    Tmajor=0:500:1500;
    set(ax_T,'xtick',Tmajor,'xticklabel',Tmajor)
    set(ax_T,'ydir','reverse')
    xlim([0,1700])
    box on


    saveas(gcf,[figDir,'/Box_',num2str(iBox),'_profiles.png'])
  end
end

function plotComparisons(Box,figDir)
  ts=0:.5:40;
  close all
  meths=fieldnames(Box(1).VBR.out.anelastic);
  ref_meth=meths{1};
  BadLines(numel(Box(1).VBR.in.SV.f)*numel(meths))=struct();

  for iBox=1:numel(Box)
    figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8)
    B=Box(iBox);
    t=B.run_info.tMyrs;
    z=B.run_info.Z_km;
    f=B.VBR.in.SV.f;
    % diff between methods at every depth, time, frequency
    dV=struct();
    dQinv=struct();
    for imeth =1:numel(meths)
      meth=meths{imeth};
      dV.(meth)=B.VBR.out.anelastic.(meth).V/1e3;
      dQinv.(meth)=B.VBR.out.anelastic.(meth).Q;
    end

    % loop over time, plot differences by method, frequency
    z_mask=(z >= 45)&(z <= 55);
    lnsty='-';
    NCs=numel(meths);
    clrs={'k','r','b','m','c'};
    ax_V=subplot(3,3,[1,2]);
    ax_Q=subplot(3,3,[4,5]);
    ax_leg=subplot(3,3,[3,6]);
    ax_T=subplot(3,3,[7,8]);
    iBad=1;
    for ifreq=1:numel(f)

      for imeth =1:numel(meths)
        meth=meths{imeth};
        dV_t=mean(dV.(meth)(z_mask,:,ifreq),1);
        dQinv_t=mean(dQinv.(meth)(z_mask,:,ifreq),1);

        lab=strrep([meth,', ',num2str(f(ifreq))],'_','\_');

        set(gcf,'currentaxes',ax_V);
        hold all
        plot(t,dV_t,'DisplayName',lab,'LineStyle',lnsty,'color',clrs{imeth},'linewidth',2)

        set(gcf,'currentaxes',ax_Q);
        hold all
        plot(t,log10(dQinv_t),'DisplayName',lab,'LineStyle',lnsty,'color',clrs{imeth},'linewidth',2)

        set(gcf,'currentaxes',ax_leg);
        hold all
        BadLines(iBad).ln=plot(t,log10(dQinv_t),'DisplayName',lab,'LineStyle',lnsty,'color',clrs{imeth},'linewidth',2);
        iBad=iBad+1;

      end
      lnsty='--';
    end

    % add the legend
    set(gcf,'currentaxes',ax_V);
    title([B.info.var1name,'=',num2str(B.info.var1val),B.info.var1units])
    set(ax_V,'xticklabel',{});
    box on
    ylabel(['Vs [km/s]'])

    set(gcf,'currentaxes',ax_Q);
    ylabel('log10(Q)')
    box on

    set(gcf,'currentaxes',ax_leg);
    pos=get(ax_leg,'position');
    L=legend('location','north');
    set(L,'linewidth',0,'position',pos,'edgecolor',[1,1,1])
    set(ax_leg,'visible','off')
    for iBad=1:numel(BadLines)
      set(BadLines(iBad).ln,'visible','off')
    end

    set(gcf,'currentaxes',ax_T)
    T=mean(B.VBR.in.SV.T_K(z_mask,:)-273,1);
    Tsol=mean(B.VBR.in.SV.Tsolidus_K(z_mask,:)-273,1);
    plot(t,T./Tsol,'k')
    hold on
    plot([min(t),max(t)],[1,1],'--k')
    plot([min(t),max(t)],[.9,.9],'--k')

    % hold on
    % plot(t,Tsol,'r','DisplayName','Tsol')
    xlabel('t [Myrs]')
    box on
    ylabel('T / Tsol')


    saveas(gcf,[figDir,'/Box_',num2str(iBox),'_comparison.png'])
  end
end
