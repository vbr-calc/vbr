function phiinv = inv_cdf_normal(x, mean_val, std_val)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % phiinv = inv_cdf_normal(x, mean_val, std_val)
    %
    % Evaluate the inverse cumulative distribution function for a
    % normal distribution.
    %
    % note: this is mainly for demo purposes to avoid
    % needing the octave statistics package of matlab
    % statistics toolbox installed.
    %
    % Parameters
    % ----------
    % x
    %    the value or values to calculate the CDF value for
    % mean_val
    %    the mean value of the normal distribution
    % std_val
    %    the standard deviation of the normal distribution
    %
    % Returns
    % -------
    % inverseCDF(x)
    %     the value of the inverse cumulative distribution function
    %     for a normal disribution evaluated at x.
    %
    % Notes
    % -----
    % See https://www.johndcook.com//erf_and_normal_cdf.pdf
    %
    % To sample from a normal distribution:
    %;
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phiinv = sqrt(2) * std_val * erfinv(2*x -1) + mean_val;

end