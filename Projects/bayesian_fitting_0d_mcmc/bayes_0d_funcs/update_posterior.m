function current_model = update_posterior(current_model);
    current_model.p_T_Vs_Q = current_model.p_T .* current_model.p_VsQ_T;
end