function VBR = attach_input_metadata(VBR)
    VBR.in.sv_metadata = struct();
    
    sv_metadata = SV_input_units();
    flds = fieldnames(sv_metadata);
    
    for ifld = 1:numel(flds)
        if isfield(VBR.in.SV, flds{ifld})
            VBR.in.sv_metadata.(flds{ifld}) = sv_metadata.(flds{ifld});
        end
    end 
    
    
end
