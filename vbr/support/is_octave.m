function is_octave_bool = is_octave()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % is_octave()
    %
    % returns 1 if running in Octave, 0 if running in MATLAB 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    is_octave_bool = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end
