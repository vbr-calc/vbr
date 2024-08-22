function current_model = update_posterior(current_model);
    current_model.p_T_Vs_Q_z = current_model.p_T .* current_model.p_VsQ_T;
    % reduce to a single value
    current_model.p_T_Vs_Q = sum(current_model.p_T_Vs_Q_z);
end
