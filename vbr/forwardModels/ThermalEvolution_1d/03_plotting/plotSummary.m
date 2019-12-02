function plotSummary(Vars,Info,varargin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % fig = plotSummary(Vars,Info,varargin)
  %
  % builds summary plot for single run results
  %
  % Parameters
  % ----------
  %   Vars    vars structure from thermal model
  %   Info    Info structure from thermal model
  %
  %   optional keyword parameters:
  %   'plot_every_k',N    integer value to plot every N timesteps (default s.t. 10 steps plotted)
  %   'plot_every_dt',dt  scalar value for time in Myrs, will plot every dt.
  %   'depth_range',[zmin,zmax]   the depth range to plot, 2 element array (default is whole domain)
  %
  % Output
  % ------
  %   none     the figure handle
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % default options
  ValidOpts=struct('plot_every_k',[],'depth_range',[],'plot_every_dt',[],...
    'savename',[]);
  Options=struct('plot_every_k',floor(numel(Info.tMyrs)/10),...
    'depth_range',[min(Info.z_km),max(Info.z_km)],...
    'plot_every_dt',0,'savename','none');
  Options=validateStructOpts('plotSummary',varargin,Options,ValidOpts);

  % initial plots over whole time range
  zSOL=Info.zSOL/1000;
  zSOL(zSOL==Info.z_km(end))=nan;

  fig=figure();
  subplot(2,3,[1,4])
  plot(Vars(:,end).Tsol,Info.z_km,'--k','linewidth',1.5)

  subplot(2,3,3)
  plot(Info.tMyrs,zSOL,'k','linewidth',1.5,'displayname','z_{SOL}')
  hold on
  plot(Info.tMyrs,Info.zLAB/1000,'--k','linewidth',1.5,'displayname','z_\eta')
  legend('location','southwest')

  subplot(2,3,6)
  plot(sqrt(Info.tMyrs),zSOL,'k','linewidth',1.5)
  hold on
  plot(sqrt(Info.tMyrs),(Info.zLAB)/1000,'--k','linewidth',1.5)

  % build array of timesteps to plot
  if Options.plot_every_dt > 0
    times_to_plot=0:Options.plot_every_dt:Info.tMyrs(end);
    it_range=zeros(size(times_to_plot));
    for tim_k=1:numel(times_to_plot);
      [val,indx]=min(abs(times_to_plot(tim_k)-Info.tMyrs));
      it_range(tim_k)=indx;
    end
  else
    it_range=1:Options.plot_every_k : numel(Info.tMyrs);
  end

  % plot those time step profiles
  for it0 = 1:numel(it_range)
    it=it_range(it0);
    cf=(it - 1) / (numel(Info.tMyrs)-1);

    subplot(2,3,[1,4])
    hold on
    plot(Vars.T(:,it),Info.z_km,'color',[0,0,cf],'linewidth',1.5)
    set(gca,'ydir','reverse')
    xlabel('T [^oC]')
    ylim(Options.depth_range)
    box on

    subplot(2,3,[2,5])
    hold on
    plot(log10(Vars.eta(:,it)),Info.z_km,'color',[0,0,cf],'linewidth',1.5)
    set(gca,'ydir','reverse')
    xlabel('log10(\eta) [Pa s]')
    box on
    ylim(Options.depth_range)

    subplot(2,3,3)
    hold on
    plot(Info.tMyrs(it),zSOL(it),'color',[0,0,cf],'markersize',10)
    plot(Info.tMyrs(it),Info.zLAB(it)/1000,'color',[0,0,cf],'markersize',10)
    set(gca,'ydir','reverse')
    xlabel('model time [Myr]')
    xlim([0,max(Info.tMyrs)])
    box on

    subplot(2,3,6)
    hold on
    plot(sqrt(Info.tMyrs(it)),zSOL(it),'color',[0,0,cf],'markersize',10)
    plot(sqrt(Info.tMyrs(it)),(Info.zLAB(it))/1000,'color',[0,0,cf],'markersize',10)
    set(gca,'ydir','reverse')
    xlabel('sqrt(model time) [Myr]')
    xlim([0,sqrt(max(Info.tMyrs))])
    box on

  end

  if ~strcmp(Options.savename,'none')
    saveas(fig,Options.savename)
  end

end
