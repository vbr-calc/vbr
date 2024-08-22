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

meths = fieldnames(VBR.out.electric);
for imeth = 1:numel(meths)
    sz = size(VBR.out.electric.(imeth));
    for id = 1:numel(sz(1))
        itemp = num2str(VBR.in.SV.T_K(id,1,1));
        figure(Name, 'Temp = ' + itemp)
        contourf(VBR.in.SV.Ch2o, VBR.in.SV.phi, dvar)
        saveas(gcf,[figDir,imeth,'_',itemp,'.png'])
    end
end

end