function ec_struct = ec_method_units(ec_struct)
    fields = fieldnames(ec_struct);
    units = struct();
    for ifield =1 :numel(fields)
        fld = fields{ifield};
        units.(fld) = 'S/m';
    end
    ec_struct.units = units;
end