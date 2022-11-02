function units = SV_input_units()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % returns a structure with expected units for all possible 
    % input state variables 
    % 
    % Parameters:
    % ----------
    % None
    %
    % Output:
    % ------
    % units    a structure with a field for each VBR.in.SV field
    %          containing the units label for each field.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    units.T_K = 'Kelvin';
    units.phi = '';
    units.rho = 'kg/m**3';
    units.sig_MPa = 'MPa';
    units.dg_um = 'micrometer';
    units.P_GPa = 'GPa';
    units.f = '1/s';
    units.Tsolidus_K = 'Kelvin';
    units.Ch2o = 'ppm';
    units.chi = '';

end 
