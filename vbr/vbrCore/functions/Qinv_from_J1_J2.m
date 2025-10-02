function Qinv = Qinv_from_J1_J2(J1, J2, use_correction)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Qinv_from_J1_J2(J1, J2, use_correction)
    %
    % calculate attenuation from J1 and J2 with optional
    % correction factor.
    %
    % Parameters
    % ----------
    % J1
    %    real part of complex compliance (same shape as J2)
    % J2
    %    imaginary part of complex compliance (same shape as J1)
    % use_correction
    %    optional integer flag (default is 0). If set to 1, will
    %    use the small Q (large Qinv) factor from equation B6
    %    of McCarthy et al 2011 (https://doi.org/10.1029/2011JB008382)
    %
    % Returns
    % %%%%%%%
    % Qinv
    %     attenuation, same shape as J1 and J2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Qinv = J2./J1;
    if ~exist("use_correction", "var")
        use_correction = 0;
    end
    if use_correction == 1
        % see appended B equation B6 of McCarthy et al 2011
        Qinv = Qinv ./ ((1 + sqrt(1+Qinv.^2)) / 2);
    end
end