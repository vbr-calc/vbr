%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [VBR] = VBR_spine(VBR)
%
% calculates mechanical properties for specified methods and thermodynamic
% states.
%
% Parameters
% ----------
% VBR    the VBR structure
%
% Required fields in VBR structure:
%    VBR.in.SV.
%        structure with field for each state variable. Required state
%        variables vary with methods, but generally the following fields
%        will be required:
%
%             .P_GPa   pressure in GPa
%             .T_k     temperature in K
%             .rho     density in kg/m^3
%             .sig_MPa differential stress in MPa
%             .phi     melt fraction, 0 <= phi <= 1
%             .dg_um   grain size, micrometers
%
%        the anelastic methods require frequency as well
%
%             .f       frequency in Hz
%
%        Except frequency, all state variables can be arrays of any dimensions
%        as long as they are all the same shape. Frequency dependence is
%        appended into a new dimension.
%
%    VBR.in.(property).methods_list
%        cell array of the methods to calculate for the property, where
%        (property) is replaced by 'anelastic','viscous' or 'elastic'.
%        For example:
%            VBR.in.anelastic.methods_list={'AndradePsP';'YT_maxwell'};
%
% Output
% ------
% VBR    the VBR structure with output in VBR.out
%
% see README.md and Projects/vbr_core_examples for examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [VBR] = VBR_spine(VBR)

%% =====================================================================
%% Check VBR Input
%% =====================================================================
  VBR = checkInput(VBR);
  telapsed=struct();
  if VBR.status==0
     fprintf(VBR.error_message)
     return
  end

%% =====================================================================
%% ELASTIC properties ==================================================
%% =====================================================================
if isfield(VBR.in,'elastic')
  [VBR,telapsed.elastic]=spineGeneralized(VBR,'elastic');
end

%% =====================================================================
%% VISCOUS properties ==================================================
%% =====================================================================

if isfield(VBR.in,'viscous')
  if isfield(VBR.in.viscous,'methods_list')
   [VBR,telapsed.visc]=spineGeneralized(VBR,'viscous');
  end
end

%% =====================================================================
%% ATTENUATION ! =======================================================
%% =====================================================================
if isfield(VBR.in,'anelastic')
   [VBR,telapsed.anelastic]=spineGeneralized(VBR,'anelastic');
end

%% ========================================================================
   VBR.out.computation_time=telapsed; % store elapsed time for each

end
