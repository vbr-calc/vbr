function current_model = update_likelihood(current_model, input_data)

    Vs_predicted = current_model.Vs;
    Q_predicted = current_model.Q;
    p_Vs_T = probability_distributions('likelihood from residuals', ...
                                       input_data.Vs_mean,
                                       input_data.Vs_std,
                                       Vs_predicted);

    p_Q_T = probability_distributions('likelihood from residuals', ...
                                       input_data.Q_mean,
                                       input_data.Q_std,
                                       Q_predicted);

    p_VsQ_T = p_Vs_T .* p_Q_T;

    current_model.p_Q_T = p_Q_T;
    current_model.p_Vs_T = p_Vs_T;
    current_model.p_VsQ_T = p_VsQ_T;

end