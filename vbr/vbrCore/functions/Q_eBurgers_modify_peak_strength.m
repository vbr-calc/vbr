function DeltaP = Q_eBurgers_modify_peak_strength(DeltaP0, Ch2o, Burger_params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % apply any modifications to the strength of the dissipation peak.
  %
  % output DeltaP may be an array or not depending on the input values.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  bType=Burger_params.eBurgerFit;
  if strcmp(bType, 'liu_water_2023')
    r_p = Burger_params.(bType).r_p;
    c_ref = Burger_params.(bType).c_ref;
    DeltaP = DeltaP0 .* ((Ch2o ./c_ref).^ r_p);
  else
    DeltaP = DeltaP0;
  end

end
