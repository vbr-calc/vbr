%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot grain size dependence of Q, Vs for all the anelastic methods
%
% (but note xfit_premelt grain size dependence
%  https://vbr-calc.github.io/vbr/vbrmethods/visc/xfitpremelt/#grain-size-dependence )
%
% pick your own preferred state variables!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all;
path_to_top_level_vbr=getenv('vbrdir');
addpath(path_to_top_level_vbr)
vbr_init

VBR.in.elastic.methods_list={'anharmonic'; };
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp'; 'xfit_premelt'};
VBR.in.anelastic.eburgers_psp=Params_Anelastic('eburgers_psp');
VBR.in.anelastic.eburgers_psp.eBurgerFit = 'bg_peak'; % 'bg_only' (default) or 'bg_peak'

VBR.in.SV = ???