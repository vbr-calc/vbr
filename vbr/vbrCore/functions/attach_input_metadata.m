function VBR = attach_input_metadata(VBR)

    sv_metadata = SV_input_units();
    flds = fieldnames(sv_metadata);
    units = struct();
    for ifld = 1:numel(flds)
        if isfield(VBR.in.SV, flds{ifld})
            units.(flds{ifld}) = sv_metadata.(flds{ifld});
        end
    end
    
    VBR.in.SV.units = units;
    
    
end
