function [field_exists,missing] = checkStructForField(StructA,FieldTree,Verb);
% checks structure for existence of nested fields.
%
% input:
%   StructA   the structure to look at
%   FieldTree a cell array of the nested fields to look for
%
% output:
%   field_exists  boolean, 1 if StructA contains all subfields, 0 else
%   missing  string of nested location that failed
%
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
