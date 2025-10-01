function throw_error_oct_mat(error_message)
    if is_octave()
        error(error_message)
    else
        ME = MException(error_message);
        throw(ME)
    end
end