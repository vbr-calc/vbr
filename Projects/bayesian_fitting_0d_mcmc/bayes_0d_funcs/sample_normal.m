function samples = sample_normal(n, mean_val, std_val)
    % random sample from normal distrubiton
    u = rand(n);
    samples = inv_cdf_normal(u, mean_val, std_val);
end