function [phi_c,x_phi_c] = setGlobalMeltEffects(GlobalParams)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [phi_c,x_phi_c] = setGlobalMeltEffects(GlobalParams)
  %
  % sets the small melt affect parameter values, allows consistency across
  % methods where these parameters appear.
  %
  % set VBR.in.GlobalSettings.melt_enhancement=0 to turn off
  % see Holtzman, G-cubed, 2016 http://dx.doi.org/10.1002/2015GC006102
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  GlobalDefauls=Params_Global();

  needThese={'phi_c';'x_phi_c';'melt_enhancement'};
  for ifld = 1:numel(needThese)
    if ~isfield(GlobalParams,needThese{ifld})
      GlobalParams.(needThese{ifld})=GlobalDefauls.(needThese{ifld});
    end
  end

  phi_c=GlobalParams.phi_c;
  if GlobalParams.melt_enhancement==0
    x_phi_c=[1 1 1];
  else
    x_phi_c=GlobalParams.x_phi_c;
  end

end
