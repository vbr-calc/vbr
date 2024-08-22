function phi = cdf_normal(x, mean_val, std_val)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % phi = cdf_normal(x, mean_val, std_val)
    %
    % Evaluate the cumulative distribution function for a
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
    % CDF(x)
    %     the value of the cumulative distribution function for a
    %     normal disribution evaluated at x.
    %
    % Notes
    % -----
    % See https://www.johndcook.com//erf_and_normal_cdf.pdf
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phi = .5 * (1 + erf( (x - mean_val) / (sqrt(2) * std_val)));
end