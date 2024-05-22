clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
addpath('bayes_0d_funcs')
vbr_init

settings.fixed_SVs.P_GPa = 2;
settings.fixed_SVs.sig_MPa = 0.1;
settings.fixed_SVs.phi = 0;
settings.fixed_SVs.dg_um = 0.01 * 1e6;
settings.fixed_SVs.f = 1. / 50.;
settings.anelastic_method = 'eburgers_psp';

max_mcmc_iters = 1000;
mcmc_burnin_iters = round(0.2 * max_mcmc_iters);

priors.T_K_mean = 1200 + 273;
priors.T_K_std = 200;
mcmc_jump_std = priors.T_K_std * .05;

input_data = get_data(settings);  % the synthetic data we want to fit

% make an initial draw for the modeled temperature, calculate
current_model.T_K = draw_temperature(1, priors.T_K_mean, priors.T_K_std*2);
current_model = update_model_predictions(current_model, settings);
current_model = update_likelihood(current_model, input_data);
current_model = update_prior_probability(current_model, priors);
current_model = update_posterior(current_model);

% output some info
disp("")
disp("Synthetic observations to fit are:")
disp(['    Vs = ', num2str(input_data.Vs_mean), ' with stand. dev. ' num2str(input_data.Vs_std)])
disp(['    Q = ', num2str(input_data.Q_mean), ' with stand. dev. ' num2str(input_data.Q_std)])
disp("Synthetic observations were calculated at:")
disp(['    T = ', num2str(input_data.T_mean), ' with stand. dev. ', num2str(input_data.T_std)])

disp("")
disp(["Initial temeprature guess = ", num2str(current_model.T_K)])
disp("  with predictions:")
disp(["   Vs = ", num2str(current_model.Vs)])
disp(["   Q = ", num2str(current_model.Q)])


mcmc_samples_T_K = zeros(max_mcmc_iters,1);
mcmc_sample_i = 1;
current_iter = 1;
while current_iter <= max_mcmc_iters

    if rem(current_iter, 100) == 0
        disp(["mcmc step ", num2str(current_iter)])
        disp(current_model.T_K)
    end
    % get a new model near the old by sampling from normal distribution near
    % current T_K guess
    new_model.T_K = draw_temperature(1, current_model.T_K, mcmc_jump_std);

    % update stats of new model
    new_model = update_model_predictions(new_model, settings);
    new_model = update_likelihood(new_model, input_data);
    new_model = update_prior_probability(new_model, priors);
    new_model = update_posterior(new_model);

    % check model acceptence
    accept_threshold = rand();

    if current_model.p_T_Vs_Q > 0 && new_model.p_T_Vs_Q > 0
        accept_criteria = new_model.p_VsQ_T / (current_model.p_VsQ_T);
    elseif current_model.p_T_Vs_Q == 0 && new_model.p_T_Vs_Q > 0
        % take the new
        accept_criteria = 1.0;
    elseif current_model.p_T_Vs_Q > 0
        % take the old
        accept_criteria = 0.0;
    else
%        disp("both 0, yikes")
        accept_criteria = 0.5;
    end

    if accept_criteria > accept_threshold
        current_model = new_model;
    end

%    if current_iter > mcmc_burnin_iters
    mcmc_samples_T_K(mcmc_sample_i) = current_model.T_K;
    mcmc_sample_i = mcmc_sample_i + 1;
%    end

    current_iter = current_iter + 1;
end

% pull out the after_burn for analysis
after_burn = mcmc_samples_T_K(mcmc_burnin_iters:end);
x_after = 1:numel(after_burn);
x_after = x_after+mcmc_burnin_iters-1 ;


subplot(1,2,1)
plot(mcmc_samples_T_K,'b')  % full
hold on
plot(x_after, after_burn, 'r') % just after burn
plot([1, mcmc_sample_i],[input_data.T_mean, input_data.T_mean],'--k')

subplot(1,2,2)
hist(after_burn)
title(mean(after_burn))

disp('final mean:')
disp(['   T_K = ', num2str(mean(after_burn))])
disp('actual:')
disp(['   T_K_input = ', num2str(input_data.T_mean)])




