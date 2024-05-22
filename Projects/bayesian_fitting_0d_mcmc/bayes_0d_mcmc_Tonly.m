%% put VBR in the path %%
clear
path_to_top_level_vbr='../../';
addpath(path_to_top_level_vbr)
addpath('bayes_0d_funcs')
vbr_init

input_data = get_data();  % the synthetic data we want to fit

disp("Synthetic observations to fit are:")
disp(['Vs = ', num2str(input_data.Vs_mean), ' with stand. dev. ' num2str(input_data.Vs_std)])
disp(['Q = ', num2str(input_data.Q_mean), ' with stand. dev. ' num2str(input_data.Q_std)])


