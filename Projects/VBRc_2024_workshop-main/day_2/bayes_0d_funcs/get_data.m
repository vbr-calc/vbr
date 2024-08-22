function [input_data] = get_data(settings)

    if settings.fit_a_fixed_TK == 1
        % set exact T, calculate Vs, Q and set arbitary standard deviations
        current_model.T_K = 1673;
        current_model = update_model_predictions(current_model, settings);

        input_data.VBR = current_model.VBR;
        input_data.Vs_mean = mean(current_model.Vs);
        input_data.Q_mean = mean(current_model.Q);
        input_data.T_mean = mean(current_model.T_K);
        % arbitrary standard deviations
        input_data.Vs_std = 15;
        input_data.Q_std = 6;
        input_data.T_std = 25;
    else
        % get a range of T values about a mean with std of 25
        current_model.T_K = randn(1000,1) * 25 + 1673;
        current_model = update_model_predictions(current_model, settings);

        % store the mean and std of T_K, and the result
        input_data.VBR = current_model.VBR;
        input_data.Vs_mean = mean(current_model.Vs);
        input_data.Vs_std = std(current_model.Vs);
        input_data.Q_std = std(current_model.Q);
        input_data.Q_mean = mean(current_model.Q);
        input_data.T_mean = mean(current_model.T_K);
        input_data.T_std = std(current_model.T_K);
    end

end