function buildComparisons(VBR,HS,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % buildComparisons(Box,figDir)
  %
  % compares anelastic methods, generates some figures
  %
  % Parameters
  % ----------
  % VBR          the VBR structure
  % HS           halfspace cooling structure
  % figDir       directory to save figures to
  %
  % Output
  % ------
  % none         (figures written to file)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  close all
  profile_ts=0:2.5:50;
  plotProfiles(VBR,HS,figDir,profile_ts); % depth profiles
  close all

  % Q profiles
  labs.x='log10(Q)';
  labs.y='depth [km]';
  labs.xlim=[1,6];
  labs.ylim=[0,200];
  labs.scl=1;
  labs.lg10=1;
  labs.svnm='Qprofiles.png';
  plotFreqDepProfs(VBR,HS,'Q',labs,figDir,profile_ts); % Q depth profiles
  close all

  % Vs profiles
  labs.x='Vs [km/s]';
  labs.y='depth [km]';
  labs.xlim=[3.8,5];
  labs.ylim=[0,200];
  labs.scl=1/1000;
  labs.lg10=0;
  labs.svnm='Vsprofiles.png';
  plotFreqDepProfs(VBR,HS,'V',labs,figDir,profile_ts);
  close all

  % comparisons of anelastic methods at ~50 km vs t
  plotComparisons(VBR,HS,figDir);
  close all
end


function plotFreqDepProfs(VBR,HS,fld,labs,figDir,ts)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotFreqDepProfs(VBR,HS,figDir)
  %
  % plots grid of depth profiles over time for every frequency-method permuation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  z=HS.z_km;

  fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8);

  meths=meths=fieldnames(VBR.out.anelastic);
  Nmeths=numel(meths);
  Nfreqs=numel(VBR.in.SV.f);
  for ifreq=1:Nfreqs
    for imeth=1:Nmeths
      iplt=imeth+Nmeths*(ifreq-1);
      ax_container(imeth,ifreq)=subplot(Nfreqs,Nmeths,iplt);
    end
  end

  tMyr=HS.t_Myr;
  for t_indx=1:numel(ts)
    [val,indx]=min(abs(ts(t_indx)-tMyr));

    R=tMyr(indx) / max(tMyr);
    R=R*(R<=1)+1*(R>1);
    RGB=[R,0,1-R];

    for ifreq=1:Nfreqs
      for imeth=1:Nmeths
        meth=meths{imeth};
        iplt=imeth+Nmeths*(ifreq-1);
        set(fig,'currentaxes',ax_container(imeth,ifreq))
        hold on
        if labs.lg10
          xvar=log10(VBR.out.anelastic.(meth).(fld)(:,indx,ifreq));
        else
          xvar=VBR.out.anelastic.(meth).(fld)(:,indx,ifreq);
        end
        plot(xvar*labs.scl,z,'color',RGB)
      end
    end
  end

  for ifreq=1:Nfreqs
    for imeth=1:Nmeths
      meth=meths{imeth};
      iplt=imeth+Nmeths*(ifreq-1);
      set(fig,'currentaxes',ax_container(imeth,ifreq))
      xlabel(labs.x)
      ylabel(labs.y)
      title([strrep(meth,'_','\_'),' ',num2str(VBR.in.SV.f(ifreq))])
      set(gca,'ydir','reverse','box','on')
      xlim(labs.xlim)
      ylim(labs.ylim)
    end
  end

  saveas(gcf,[figDir,labs.svnm])

end

function plotProfiles(VBR,HS,figDir,ts)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plots depth profiles of T,phi,eta,average Vs
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  z=HS.z_km;
  tMyr=HS.t_Myr;

  fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8);
  ax_T=subplot(1,4,1);
  ax_phi=subplot(1,4,2);
  ax_eta=subplot(1,4,3);
  ax_V=subplot(1,4,4);

  set(fig,'currentaxes',ax_T)
  plot(VBR.in.SV.Tsolidus_K(:,1)-273,z,'k')


  for t_indx=1:numel(ts)
    [val,indx]=min(abs(ts(t_indx)-tMyr));

    R=tMyr(indx) / max(tMyr);
    R=R*(R<=1)+1*(R>1);
    RGB=[R,0,1-R];

    % temperature v depth
    set(fig,'currentaxes',ax_T)
    hold on
    plot(VBR.in.SV.T_K(:,indx)-273,z,'color',RGB)

    % phi v depth
    set(fig,'currentaxes',ax_phi)
    hold on
    plot(VBR.in.SV.phi(:,indx),z,'color',RGB)

    % eta v depth
    set(fig,'currentaxes',ax_eta)
    hold on
    plot(log10(VBR.out.viscous.HK2003.eta_total(:,indx)),z,'color',RGB)

    % Vs averaged over methods and frequencies
    meths=fieldnames(VBR.out.anelastic);
    Vave=zeros(size(VBR.in.SV.phi(:,indx)));
    for imeth =1:numel(meths)
      meth=meths{imeth};
      Vave=Vave+VBR.out.anelastic.(meth).Vave(:,indx);
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
  xlim([19,26])
  xtcks={};
  xticlocs=19:1:26;
  for itck=1:numel(xticlocs)
    if mod(xticlocs(itck),2)==0
      xtcks{itck}=num2str(xticlocs(itck));
    else
      xtcks{itck}='';
    end
  end
  set(ax_eta,'xtick',xticlocs,'xticklabel',xtcks)
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
  Tmajor=0:500:1500;
  set(ax_T,'xtick',Tmajor,'xticklabel',Tmajor)
  set(ax_T,'ydir','reverse')
  xlim([0,1700])
  box on


  saveas(gcf,[figDir,'/HS_profiles.png'])

end

function plotComparisons(VBR,HS,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plots Q at ~50 km depth vs time for all methods, frequencies
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % close all
  meths=fieldnames(VBR.out.anelastic);
  ref_meth=meths{1};
  BadLines(numel(VBR.in.SV.f)*numel(meths))=struct();


  figure('Position', [10 10 700 400],'PaperPosition',[0,0,6,3],'PaperPositionMode','manual','DefaultAxesFontSize',8)

  t=HS.t_Myr;
  z=HS.z_km;
  f=VBR.in.SV.f;

  % methods at every depth, time, frequency
  dV=struct();
  dQinv=struct();
  for imeth =1:numel(meths)
    meth=meths{imeth};
    dV.(meth)=VBR.out.anelastic.(meth).V/1e3;
    dQinv.(meth)=VBR.out.anelastic.(meth).Q;
  end

  % loop over time, plot differences by method, frequency
  z_mask=(z >= 45)&(z <= 55);
  lnsty='-';
  NCs=numel(meths);
  clrs={'k','r','b','m','c'};
  ax_V=subplot(3,3,[1,2]);
  ax_Q=subplot(3,3,[4,5]);
  ax_leg=subplot(3,3,[3,6]); % trickery to give the legend its own axis
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
  T=mean(VBR.in.SV.T_K(z_mask,:)-273,1);
  Tsol=mean(VBR.in.SV.Tsolidus_K(z_mask,:)-273,1);
  plot(t,T./Tsol,'k')
  hold on
  plot([min(t),max(t)],[1,1],'--k')
  plot([min(t),max(t)],[.9,.9],'--k')
  xlabel('t [Myrs]')
  box on
  ylabel('T / Tsol')

  saveas(gcf,[figDir,'/method_comparison.png'])
end
