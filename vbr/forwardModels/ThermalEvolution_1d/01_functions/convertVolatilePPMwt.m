function Var = convertVolatilePPMwt(Var,direction)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Var = convertVolatilePPMwt(Var,direction)
  %
  % converts volatile variables between PPM and wt %
  %
  % Parameters
  % ----------
  %   Vars    the variables structure
  %   direction   'to_PPM' to go from wt % to PPM, 'to_wt' to go the other way
  %
  % Output
  % ------
  %   Vars    modified variables structure with volatile fields now in PPM or wt %
  %
  % the volatile fields that will be converted are: 'Cs_H2O','Cs_CO2','Cf_H2O','Cf_CO2'
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if strcmp(direction,'to_PPM')
    fact=1e4; % wt % to PPM factor
  else
    fact=1e-4; % PPM to wt % factor
  end
  Cconv={'Cs_H2O','Cs_CO2','Cf_H2O','Cf_CO2'};
  for iFie=1:numel(Cconv)
    if isfield(Var,Cconv{iFie})
      Var.(Cconv{iFie})=  Var.(Cconv{iFie}) * fact;
    end
  end

end
