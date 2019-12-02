function buildComparisons(VBR,Ranges,figDir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % buildComparisons(Box,Ranges,figDir)
  %
  % compares anelastic methods, generates some figures
  %
  % Parameters
  % ----------
  % VBR          the VBR structure
  % Ranges       the parameter ranges
  % figDir       directory to save figures to
  %
  % Output
  % ------
  % none         (figures written to file)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  close all

  Fixed_indx.iphi=1;
  [val,Fixed_indx.iT]=min(abs(Ranges.T_K-(1250+273)));
  [val,Fixed_indx.id]=min(abs(Ranges.dg_um-(0.005*1e6)));
  Fixed_indx.freq=1;

  % Q
  labs.scl=1;
  labs.lg10=1;
  labs.ylab='log(Q)';
  plotFreqDepPanel(VBR,Ranges,'Q',labs,figDir,Fixed_indx); % Q panels
  close all
  plotComparisons(VBR,Ranges,'Q',labs,figDir,Fixed_indx)
  close all

  labs.scl=1/1000;
  labs.lg10=0;
  labs.ylab='Vs [km/s]';
  plotFreqDepPanel(VBR,Ranges,'V',labs,figDir,Fixed_indx); % Vs panels
  close all
  plotComparisons(VBR,Ranges,'V',labs,figDir,Fixed_indx)
  close all

  labs.scl=1/(1e9);
  labs.lg10=0;
  labs.ylab='M [GPa]';
  plotFreqDepPanel(VBR,Ranges,'M',labs,figDir,Fixed_indx); % M panels
  close all
  plotComparisons(VBR,Ranges,'M',labs,figDir,Fixed_indx)
  close all


end


function plotFreqDepPanel(VBR,Ranges,fld,labs,figDir,Fixed_indx)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotFreqDepPanel(VBR,Ranges,fld,labs,figDir)
  %
  % plots a contour of fld for each method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  meths=meths=fieldnames(VBR.out.anelastic);
  Nmeths=numel(meths);
  Nfreqs=numel(VBR.in.SV.f);


  for imeth=1:Nmeths
    meth=meths{imeth};
    fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,7,4],'PaperPositionMode','manual','DefaultAxesFontSize',8);
    for ifreq=1:Nfreqs

      % pull out this frequency
      var=squeeze(VBR.out.anelastic.(meth).(fld)(:,:,:,ifreq));
      labti=fld;
      if labs.lg10==1
        var=log10(var);
        labti=['log10(',fld,')'];
      end
      var=var*labs.scl;

      ax_fixedphi=subplot(Nfreqs,3,(ifreq-1)*3+1);
      contourf(Ranges.T_K-273,log10(Ranges.dg_um),squeeze(var(:,Fixed_indx.iphi,:))',20,'LineStyle','none')
      colormap(hot)
      colorbar()
      xlabel('T [C]');ylabel('log10(dg) [um]')
      title([labti,' at phi=',num2str(Ranges.phi(Fixed_indx.iphi)),', f=',num2str(VBR.in.SV.f(ifreq))])

      ax_fixedT=subplot(Nfreqs,3,(ifreq-1)*3+2);
      contourf(Ranges.T_K-273,log10(Ranges.phi),squeeze(var(:,:,Fixed_indx.id))',20,'LineStyle','none')
      colormap(hot)
      colorbar()
      xlabel('T [C]');ylabel('log10(phi)')
      title([labti,' at d=',num2str(Ranges.dg_um(Fixed_indx.id)),' um, f=',num2str(VBR.in.SV.f(ifreq))])

      ax_fixeddg=subplot(Nfreqs,3,(ifreq-1)*3+3);
      contourf(log10(Ranges.phi),log10(Ranges.dg_um),squeeze(var(Fixed_indx.iT,:,:))',20,'LineStyle','none')
      colormap(hot)
      colorbar()
      xlabel('phi');ylabel('log10(dg) [um]')
      title([labti,' at T=',num2str(Ranges.T_K(Fixed_indx.iT)-273),' C, f=',num2str(VBR.in.SV.f(ifreq))])

    end

    saveas(gcf,[figDir,fld,'_',meth,'.eps'],'epsc')

  end

end

function plotComparisons(VBR,Ranges,fld,labs,figDir,Fixed_indx)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % plotFreqDepPanel(VBR,Ranges,fld,labs,figDir)
  %
  % plots a contour of fld for each method
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  meths=fieldnames(VBR.out.anelastic);
  Nmeths=numel(meths);
  Nfreqs=numel(VBR.in.SV.f);
  ifreq=Fixed_indx.freq;
  phival=Ranges.phi(Fixed_indx.iphi); dval=Ranges.dg_um(Fixed_indx.id);
  Tval=Ranges.T_K(Fixed_indx.iT)-273;
  fval=VBR.in.SV.f(ifreq);

  fig=figure('Position', [10 10 700 400],'PaperPosition',[0,0,7,4],'PaperPositionMode','manual','DefaultAxesFontSize',8);



  ax_vsT=subplot(1,3,1);
  ax_vsphi=subplot(1,3,2);
  ax_vsd=subplot(1,3,3);

  for imeth=1:Nmeths
    meth=meths{imeth};
    var=squeeze(VBR.out.anelastic.(meth).(fld)(:,:,:,ifreq));
    labti=fld;
    if labs.lg10==1
      var=log10(var);
      labti=['log10(',fld,')'];
    end
    var=var*labs.scl;

    % plot of fld vs each free var
    set(fig,'CurrentAxes',ax_vsT)
    hold all
    plot(Ranges.T_K-273,squeeze(var(:,Fixed_indx.iphi,Fixed_indx.id)),'linewidth',1.5,'DisplayName',strrep(meth,'_','\_'))
    title(['phi=',num2str(phival),', d=',num2str(dval),' um, f=',num2str(fval)])
    xlabel('T [C]')
    ylabel(labs.ylab)

    set(fig,'CurrentAxes',ax_vsphi)
    hold all
    plot(log10(Ranges.phi),squeeze(var(Fixed_indx.iT,:,Fixed_indx.id)),'linewidth',1.5)
    title(['T=',num2str(Tval),' C, d=',num2str(dval),' um, f=',num2str(fval)])
    xlabel('log10(phi)')

    set(fig,'CurrentAxes',ax_vsd)
    hold all
    plot(log10(Ranges.dg_um),squeeze(var(Fixed_indx.iT,Fixed_indx.iphi,:)),'linewidth',1.5)
    title(['phi=',num2str(phival),', T=',num2str(Tval),' C, f=',num2str(fval)])
    xlabel('log10(d) [um]')
  end

  set(fig,'CurrentAxes',ax_vsT)
  legend('location','northeast')
  box on
  set(fig,'CurrentAxes',ax_vsd)
  box on
  set(fig,'CurrentAxes',ax_vsphi)
  box on

  saveas(gcf,[figDir,fld,'_compare','.eps'],'epsc')

end
