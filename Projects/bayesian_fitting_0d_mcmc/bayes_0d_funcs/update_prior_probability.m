function current_model = update_prior_probability(current_model, priors)

    mean_val = priors.T_K_mean;
    std_val = priors.T_K_std;
    T_K = current_model.T_K;
    p_T = probability_distributions('normal', T_K, mean_val, std_val);
    current_model.p_T = p_T;
end