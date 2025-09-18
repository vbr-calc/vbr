function [field_exists,missing] = checkStructForField(StructA,FieldTree,Verb);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [field_exists,missing] = checkStructForField(StructA,FieldTree,Verb);
%
% checks structure for existence of nested fields. Useful for validation in
% functions that accept the VBR structure.
%
% Parameters
% ----------
%   StructA: structure
%     the structure to inspect
%   FieldTree: cell array of strings
%     a cell array of the nested fields to look for, e.g., {'in';'SV';'T_K'}
%   Verb: 0/1 flag
%     verbosity flag: set to 0 to suppress messages
%
% Returns
% -------
% [field_exists, missing]
%     field_exists:  boolean
%       1 if StructA contains all subfields, 0 else
%     missing
%       string of nested location that failed
%
% Examples
% --------
% To check a VBR structure for the existence of a state variable field:
%
% [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,0);
%
% for example:
%
%   VBR = struct();
%   [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,1)
%
% displays:
%   structure missing field:  .in
%   field_exists = 0
%   missing = .in
%
% indicating that the field does not exist because VBR.in does not exist.
% adding a SV field (but not T_K):
%
%   VBR.in.SV.phi = 0;
%   [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,1)
%
% displays:
%   structure missing field:  .in.SV.T_K
%   field_exists = 0
%   missing = .in.SV.T_K
%
% indicating that the field does not exist in VBR.in.SV.
%
% Finally,
%
%   VBR.in.SV.T_K = 273;
%   [field_exists,missing] = checkStructForField(VBR, {'in';'SV';'T_K'} ,1)
%
% will result in:
%   field_exists = 1
%   missing =
%
% indicating that the field was found.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  field_exists=1;
  current_loc='';
  missing='';
  found_missing=0;
  Stemp=StructA;

  iT=1;
  for iT=1:numel(FieldTree)
    current_loc=[current_loc,'.',FieldTree{iT}];
    if ~isfield(Stemp,FieldTree{iT}) && found_missing==0
      found_missing=1;
      field_exists=0;
      missing=current_loc;
      if Verb > 0
         disp(['structure missing field:  ',missing])
      end
    elseif found_missing==0
      Stemp=Stemp.(FieldTree{iT});
    end
  end

end
