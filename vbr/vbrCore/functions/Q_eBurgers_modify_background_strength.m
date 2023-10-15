function DeltaB = Q_eBurgers_modify_background_strength(DeltaB0, Ch2o, Burger_params)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % apply any modifications to the strength of the high temp background
  %
  % output DeltaP may be an array or not depending on the input values.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  bType=Burger_params.eBurgerFit;
  if strcmp(bType, 'liu_water_2023')
    r = Burger_params.(bType).r;
    c_ref = Burger_params.(bType).c_ref;
    DeltaB = DeltaB0 .* ((Ch2o ./c_ref).^ r);
  else
    DeltaB = DeltaB0;
  end

end
