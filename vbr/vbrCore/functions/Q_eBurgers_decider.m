function [VBR] = Q_eBurgers_decider(VBR)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [VBR] = Q_eBurgers(VBR)
  %
  % wrapper for eBurger methods. decides which eBurgers method to call: either
  % PointWise or FastBurger method. FastBurger only works with the high temp
  % background, use PointWise if using a peak.
  %
  % Parameters:
  % ----------
  % VBR   the VBR structure
  %
  % Output:
  % -----
  % VBR   the VBR structure, with VBR.out.anelastic.eBurgers structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if strcmp(lower(VBR.in.anelastic.eburgers_psp.method),'pointwise')
    VBR=Q_eBurgers_f(VBR);
  elseif strcmp(lower(VBR.in.anelastic.eburgers_psp.method),'fastburger')
    [VBR]=Q_eFastBurgers(VBR) ;
  else
    meth=[VBR.in.anelastic.eburgers_psp.method, 'does not exist'];
    disp(['WARNING: eBurgers method ',meth,'. Must be PointWise or FastBurger'])
  end
end
