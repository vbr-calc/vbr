function Kc = ThermalConductivity(Kc_o,T,P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculates thermal conductivity using Xu et al.
%   
% Input
%   
%  Kc_o   scalar or array of reference values for thermal conductivity
%         (an array would be useful for compositional changes with depth)
%  T      temperature (scalar or array) [K]
%  P      pressure [Pa] (only used if using method 1 below
%   
% Reference:
% Xu, Y., T. J. Shankland, S. Linhardt, D. C. Rubie, F. Langenhorst, and K.
% Klasinski (2004), Thermal diffusivity and conductivity of olivine,
% wadsleyite and ringwoodite to 20 GPa and 1373 K, Phys Earth Planet In,
% 143-144, 321?336, doi:10.1016/j.pepi.2004.03.005.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% method 1, P-dependent
  Kc = Kc_o.*(298./T).^(0.5) .* (1+0.032*P/1e9);

% % method 2, P-independent
%   Kc = Kc_o.*(298./T).^0.5;

end

