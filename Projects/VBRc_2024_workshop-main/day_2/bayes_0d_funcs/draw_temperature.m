function [T_K] = draw_temperature(n,T_K_mean, T_K_std)

    % random sample from normal distrubiton
    T_K = sample_normal(n, T_K_mean, T_K_std);
    T_K(T_K < 10) = 10;

    % if statistics package (octave) or statistics toolbox (matlab)
    % were installed, could do:
    % T_K_= normrnd(T_K_mean, T_K_std, n);
end