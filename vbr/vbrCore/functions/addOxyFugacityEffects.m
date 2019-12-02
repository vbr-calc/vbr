function tau = addOxyFugacityEffects(tau,fO2_bar,params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % tau = addOxyFugacityEffects(tau,fO2_bar,params)
  %
  % adds on oxygen fugacity effects to maxwell time
  %
  % Parameters:
  % ----------
  %      tau.  structure with maxwell time fields
  %         .maxwell normal maxwell time
  %         .L , .H , .P  maxwell times for eBurgers (low, high, peak)
  %      fO2_bar  array of fO2 in bar
  %      params   the parameter structure for the current anelastic method
  %
  % Output:
  % ------
  %     tau.  structure with maxwell time fields adjusted for fO2
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % call sr_oxygen_fugacity for possible permuations of parameters
  if isfield(params,'m_fO2') && ~isfield(params,'fO2_ref')
    m_fO2=params.m_fO2;
    fugAdj=sr_oxygen_fugacity(fO2_bar,'m_fO2',m_fO2);
  elseif isfield(params,'fO2_ref') && ~isfield(params,'m_fO2')
    fO2_ref=params.fO2_ref;
    fugAdj=sr_oxygen_fugacity('fO2_ref',fO2_ref);
  elseif isfield(params,'fO2_ref') && isfield(params,'m_fO2')
    fO2_ref=params.fO2_ref;
    m_fO2=params.m_fO2;
    fugAdj=sr_oxygen_fugacity(fO2_bar,'m_fO2',m_fO2,'fO2_ref',fO2_ref);
  else
    fugAdj=sr_oxygen_fugacity(fO2_bar);
  end

  % calculate adjusted maxwell time for available fields
  possible_fields={'maxwell','L','H','P'};
  for ifi =1:numel(possible_fields)
    fldnme=possible_fields{ifi};
    if isfield(tau,fldnme)
      tau.(fldnme)=fugAdj.eta .* tau.(fldnme);
    end
  end

end
