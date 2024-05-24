clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
addpath('bayes_0d_funcs')
vbr_init

% prior distribution settings
priors.T_K_mean = 1200 + 273;  % mean of T_K prior distribution
priors.T_K_std = 200;  % standard deviation of T_K prior distribution

% mcmc settings:
% for testing, the following are set to small numbers. they should be increased,
% which will be obvious when you run this with small numbers...
settings.mcmc_max_iters = 100; % max iterations for this chain
settings.mcmc_info_very_N = 10; % print info every N steps
settings.mcmc_burnin_iters = round(0.2 * settings.mcmc_max_iters); % burn in iterations
settings.mcmc_jump_std = priors.T_K_std * .05; % the jump magnitude for updating T_K
settings.mcmc_initial_T_K = 0; % set to 0 to draw initial guess from distribution
settings.mcmc_initial_guess_jump_std = priors.T_K_std; % jump magnitude for the initial guess
settings.mcmc_acceptance_sc = 1; % acceptance threshold = sc * rand()

% set the fixed state variables and single anelastic method
settings.fixed_SVs.P_GPa = 2;
settings.fixed_SVs.sig_MPa = 0.1;
settings.fixed_SVs.phi = 0;
settings.fixed_SVs.dg_um = 0.01 * 1e6;
settings.fixed_SVs.f = 1. / 50.;
settings.fit_a_fixed_TK = 1; % 1 to fixed hidden T_K, 0 to draw from distribution about a hidden mean
settings.anelastic_method = 'eburgers_psp';

% get the synthetic data we want to fit
input_data = get_data(settings);  % includes a hidden T_K value ...

% make an initial draw for the modeled temperature, calculate
if settings.mcmc_initial_T_K == 0
    current_model.T_K = draw_temperature(1, priors.T_K_mean, settings.mcmc_initial_guess_jump_std);
else
    current_model.T_K = settings.mcmc_initial_T_K;
end
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

% start the itreations
results.mcmc_samples_T_K = zeros(settings.mcmc_max_iters,1);
mcmc_sample_i = 1;
current_iter = 1;

disp("")
disp("Starting chain iterations")
disp("")

while current_iter <= settings.mcmc_max_iters

    if rem(current_iter, settings.mcmc_info_very_N) == 0
        if current_iter >= settings.mcmc_burnin_iters + 1
            mean_T = mean(results.mcmc_samples_T_K(settings.mcmc_burnin_iters:current_iter));
            msg = ["    mcmc step ", num2str(current_iter), ...
                   ", model T_K=", num2str(current_model.T_K), ...
                   "  mean T_K (after burn-in) = ", num2str(mean_T)];
        else
            msg = ["    mcmc step ", num2str(current_iter), ...
                   ", model T_K=", num2str(current_model.T_K)];
        end
        disp(msg)

    end
    % mcmc step 1: get a new model near the old by sampling from normal distribution near
    % current T_K guess
    new_model.T_K = draw_temperature(1, current_model.T_K, settings.mcmc_jump_std);

    % mcmc step 2: update model predictions, update the likelihood, prior and posterior
    new_model = update_model_predictions(new_model, settings);
    new_model = update_likelihood(new_model, input_data);
    new_model = update_prior_probability(new_model, priors);
    new_model = update_posterior(new_model);

    % check model acceptance
    accept_threshold = settings.mcmc_acceptance_sc * rand();

    % note: due to log scaling of Q, can have identically 0 probabilities for
    % some values. could improve this by computing probabilities in log space,
    % but we can just check for those special cases.
    if current_model.p_T_Vs_Q > 0 && new_model.p_T_Vs_Q > 0
        % the standard metropolis-hastings criteria
        accept_criteria = new_model.p_VsQ_T / current_model.p_VsQ_T;
    elseif current_model.p_T_Vs_Q == 0 && new_model.p_T_Vs_Q > 0
        % take the new
        accept_criteria = 1.0;
    elseif current_model.p_T_Vs_Q > 0
        % take the old
        accept_criteria = 0.0;
    else
        % both have 0 probability, flip a coin.
        accept_criteria = 0.5;
    end

    % compare to the random acceptance threshold
    if accept_criteria > accept_threshold
        current_model = new_model;
    end

    % store current model temperature: note that this includes the burn-in
    % iterations, which should be removed for the final analysis.
    results.mcmc_samples_T_K(mcmc_sample_i) = current_model.T_K;
    mcmc_sample_i = mcmc_sample_i + 1;
    current_iter = current_iter + 1;
end

% pull out the after_burn for analysis
results.after_burn = results.mcmc_samples_T_K(settings.mcmc_burnin_iters:end);
results.after_iters = 1:numel(results.after_burn);
results.after_iters = results.after_iters+settings.mcmc_burnin_iters-1 ;
results.mcmc_sample_i = mcmc_sample_i;

% plot the result
subplot(1,2,1)
% first plot the full series
plot(results.mcmc_samples_T_K)  % full
hold all
% plot only the iterations after the burn in
plot(results.after_iters, results.after_burn)
xlabel("iterations")
ylabel("T_K")

subplot(1,2,2)
hist(results.after_burn)
results.mean_T_K = mean(results.after_burn);
ttl_str = ["mean T_K = ", num2str(mean(results.after_burn))];
title(ttl_str)

disp('')
disp('final mean:')
disp(['   T_K = ', num2str(results.mean_T_K)])
