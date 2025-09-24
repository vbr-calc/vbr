function [rho_in, Mu_in, Ju_in, f_vec] = Q_get_state_vars(VBR)
  % state variables
  rho_in = VBR.in.SV.rho ;
  if isfield(VBR.in.elastic,'anh_poro')
   Mu_in = VBR.out.elastic.anh_poro.Gu ;
  elseif isfield(VBR.in.elastic,'anharmonic')
   Mu_in = VBR.out.elastic.anharmonic.Gu ;
  end
  Ju_in = 1./Mu_in;
  % Frequency
  f_vec = VBR.in.SV.f;  % frequency
end