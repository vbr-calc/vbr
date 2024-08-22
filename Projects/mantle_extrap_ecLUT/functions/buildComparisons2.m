function buildComparisons2(VBR,Ranges,figDir)
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

meths = fieldnames(VBR.out.electric);
for imeth = 1:numel(meths)
    meth=meths{imeth};
    sz = size(VBR.out.electric.(meth).esig);
    for id = 1:numel(sz(1))
        itemp = num2str(VBR.in.SV.T_K(id,1,1));
        figure(Name=['Temp = ', itemp])
        x = VBR.in.SV.phi(1,1,:);
        x = reshape(x,142,1);
        y = VBR.in.SV.Ch2o(1,:,1);
        [X,Y]=meshgrid(x,y);
        a=Ranges.(meth).dvar(1,:,:);
        b=reshape(a,102,142);
        contourf(X, Y, b)
        % saveas(gcf,[figDir,meth,'_',itemp,'.png'])
    end
end

end