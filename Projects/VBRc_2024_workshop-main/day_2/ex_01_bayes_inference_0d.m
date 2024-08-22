%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Pick a spot in the western U.S., find possible temperature, melt fraction
% ranges constrained by Vs, Q measurements
%

% initialize vbr
clear; close all;
vbr_path=getenv('vbrdir');
addpath(vbr_path)
vbr_init

% going to use some helper functions in bayesian_fitting example
addpath(genpath([vbr_path, '/Projects/bayesian_fitting']))
addpath("bayes_inference_funcs")

% inspect the data
filenames.Q = get_data_file_path('Q_models', 'Dalton_Ekstrom_2008.mat');
filenames.Vs = get_data_file_path('vel_models', 'Shen_Ritzwoller_2016.mat');

shen_ritzwoller = load(filenames.Vs);
Vs_Model = shen_ritzwoller.Vs_Model;

size(Vs_Model.Depth)
size(Vs_Model.Latitude)
size(Vs_Model.Longitude)
size(Vs_Model.Vs)

pcolor(Vs_Model.Vs(:,:,50))
colorbar()

dalton_ekstrom = load(filenames.Q);
Q_Model = dalton_ekstrom.Q_Model;
size(Q_Model.Qinv)
size(Q_Model.Depth)
pcolor(Q_Model.Longitude, Q_Model.Latitude, Q_Model.Qinv(:,:,10))
colorbar()

% extract a spot measurement for lat/lon point and a depth range
help process_SeismicModels  % note: plotting arg may be funky, longitude should be 0 to 360

%
% b_and_r = [40.7, -117.5];
location.lat = 40.7;
location.lon = 360-117.5;
location.z_min = 75;
location.z_max = 105;
location.smooth_rad = 0.5;

[obs_Vs, sigma_Vs] = process_SeismicModels('Vs', location, filenames.Vs, 0);

obs_Vs
sigma_Vs

[obs_Q, sigma_Q] = process_SeismicModels('Q', location, filenames.Q, 0);
obs_Q
sigma_Q

% what is the probability distribution of Vs, Q for this spot ? plot them!
% use the probability_distributions function with a normal distribution

help probability_distributions

% in case the varargin descprtion is confusing, your calls should look like:
% P = probability_distributions('normal', test_values_array, observed_value, std_of_observed)

vs_range = linspace(obs_Vs-4*sigma_Vs,obs_Vs+4*sigma_Vs,50);
P_obs_Vs = probability_distributions('normal', vs_range, obs_Vs, sigma_Vs);

Q_range = linspace(obs_Q-4*sigma_Q,obs_Q+4*sigma_Q,50);
P_obs_Q = probability_distributions('normal', Q_range, obs_Q, sigma_Q);

figure
subplot(1,2,1)
plot(vs_range, P_obs_Vs)
xlabel('Vs')
ylabel('P(Vs)')

subplot(1,2,2)
plot(Q_range, P_obs_Q)
xlabel('Q')
ylabel('P(Q)')

% show that the probability distributions sum to 1
trapz(vs_range, P_obs_Vs)  % close to 1 :D
trapz(Q_range, P_obs_Q)  % close to 1 :D

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% using the VBRc, conduct a grid search to find the T and phi that explain the
% observed values for all of the anelastic methods.
%
% steps:
%
% 1. build a lookup table (LUT) of VBRc values for parameter range of interest
% 2. find the best fit using a chi-squared misfit
%    (https://en.wikipedia.org/wiki/Reduced_chi-squared_statistic)
%
% hints/simplifications:
%
% pick sensible values for other state variables.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set ranges for the state variables we want to search for
test_T = linspace(1000,1500,100)+273;
test_phi = linspace(0, 0.05, 50);

% build a grid
[T, phi] = meshgrid(test_T, test_phi);

% prep for VBRc
VBR = struct();
VBR.in.SV.T_K = T;
VBR.in.SV.phi = phi;

% make remainder of vars same shape
sz = size(T);
VBR.in.SV.P_GPa = 2 * ones(sz); % pressure [GPa]
VBR.in.SV.sig_MPa = .1 * ones(sz); % differential stress [MPa]
VBR.in.SV.dg_um = 0.01 * 1e6 * ones(sz); % grain size [um]
VBR.in.SV.Tsolidus_K = 1200 * ones(sz);
rho = san_carlos_density_from_pressure(VBR.in.SV.P_GPa);
rho = Density_Thermal_Expansion(rho, VBR.in.SV.T_K, 0.9);

VBR.in.SV.rho = rho; % density [kg m^-3]

% pick a frequency
VBR.in.SV.f = [0.01, 0.1];

% what method to use? lets do them all
VBR.in.elastic.methods_list={'anharmonic';'anh_poro';};
VBR.in.anelastic.methods_list={'eburgers_psp';'andrade_psp';'xfit_mxw'; 'xfit_premelt'};

% call the VBRc
VBR = VBR_spine(VBR);

% plot the look up table (LUT).
% contour plots of V, Q vs T and phi for a method of your choice
figure()
subplot(1,2,1)
contourf(test_T, test_phi, VBR.out.anelastic.eburgers_psp.V(:,:,1))
xlabel('T')
ylabel('phi')
title('Vs VBRc LUT (for one method)')
subplot(1,2,2)
contourf(test_T, test_phi, VBR.out.anelastic.eburgers_psp.Q(:,:,1))
xlabel('T')
ylabel('phi')
title('Q VBRc LUT (for one method)')

% for a single method, calculate the chi-squared misfit for Q and V separately
% and together for a single anelastic method
method_name = 'eburgers_psp';

V = VBR.out.anelastic.(method_name).V(:,:,1)/1e3;
chi_sq_V = ((V-obs_Vs)/sigma_Vs).^2;
Q = VBR.out.anelastic.(method_name).Q(:,:,1);
chi_sq_Q = ((Q-obs_Q)/sigma_Q).^2;

% plot 3 contours of chi-squared misfit:
% Vs misfit vs T and phi
% Q misfit vs T and phi
% joint misfit vs T and phi
figure()
subplot(1,3,1)
contourf(test_T-273, test_phi, log10(chi_sq_V))
xlabel('T')
ylabel('phi')
title('log10(chi^2 of Vs) for one method')
colorbar()

subplot(1,3,2)
contourf(test_T-273, test_phi, log10(chi_sq_Q))
xlabel('T')
ylabel('phi')
title('log10(chi^2 of Q) for one method')
colorbar()

subplot(1,3,3)
contourf(test_T-273, test_phi, log10(chi_sq_Q+chi_sq_V))
title('log10(chi^2 of Vs, Q)')
xlabel('T')
ylabel('phi')
colorbar()

% extract the best fitting values of T, phi for each anelastic method
best_T_phi_chi = struct();
for imeth = 1:numel(VBR.in.anelastic.methods_list)
  method_name = VBR.in.anelastic.methods_list{imeth};
  V = VBR.out.anelastic.(method_name).V(:,:,1)/1e3;
  chi_sq_V = ((V-obs_Vs)/sigma_Vs).^2;
  Q = VBR.out.anelastic.(method_name).Q(:,:,1);
  chi_sq_Q = ((Q-obs_Q)/sigma_Q).^2;

  joint = chi_sq_Q+chi_sq_V;
  minval = min(joint(:));
  i = find(joint(:) == minval);

  best_T = VBR.in.SV.T_K(i);
  best_phi = VBR.in.SV.T_K(i);
  best_T_phi_chi.(method_name) = struct();
  best_T_phi_chi.(method_name).T = best_T;
  best_T_phi_chi.(method_name).phi = best_phi;
  best_T_phi_chi.(method_name).misfit = minval;
end
best_T_phi_chi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% say that you have some prior information from some xenoliths that the
% temperature range is close to 1350... and there might be some melt...
%
% use a pure bayesian inference to incorporate these prior constraints and plot a
% posterior distribtuion showing the likely T and phi ranges for a single method
%
% For a bayes intro, see the intro in the following:
% https://github.com/vbr-calc/pyVBRc/blob/main/examples/ex_003_vbr_bayes_intro.ipynb
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. build prior model distributions of T, phi and plot them
%
% use a uniform distribtuion for phi and a normal distribution for T. You can
% again use the probability_distributions function.
%
% pick your preferred range of phi and your preferred mean and standard deviation
% for T.
%
% plot both distributions
%
% do this for both the 1D distributions defining the range of phi, T that went into
% the VBRc LUT as well as the 2D matrices used in the VBRc calculations (VBR.in.SV.T_K,
% VBR.in.SV.phi).

% calcualte distributions with 1D phi, T ranges
min_phi = 0;
max_phi = 0.05;
phi_dist = probability_distributions('uniform', test_phi, min_phi, max_phi);

meanT = 1350+273;
T_std = 50;
T_dist = probability_distributions('normal', test_T, meanT, T_std);

% plot them
figure()
subplot(1,2,1)
plot(test_phi, phi_dist)
xlabel('phi')
ylabel('P(phi)')
title('phi prior probability')

subplot(1,2,2)
plot(test_T,T_dist)
xlabel('T')
ylabel('P(T)')
title('T prior probability')

% recalculate priors as matrices using the T and phi inputs to the VBRc LUT
prior_phi = probability_distributions('uniform', phi, min_phi, max_phi);
prior_T = probability_distributions('normal', T, meanT, T_std);

% plot them!
figure()
contourf(test_T-273, test_phi, prior_T.*prior_phi)
title('joint priors')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. calculate the likelihood of observing the Vs and Q in your VBRc LUT for
% a single anelastic method.
% use the normal_likelihood in this directory (or write your own)
%
% make contour plots of the independent and joint likelihoods

method_name = 'eburgers_psp';
V = VBR.out.anelastic.(method_name).V(:,:,1)/1e3;
Q = VBR.out.anelastic.(method_name).Q(:,:,1);

PV = normal_likelihood(V, obs_Vs, sigma_Vs);
PQ = normal_likelihood(Q, obs_Q, sigma_Q);
joint_likeli = PV .* PQ;

figure()
subplot(1,3,1)
contourf(test_T-273, test_phi, PV)
title('P(V|T,phi)')
subplot(1,3,2)
contourf(test_T-273, test_phi, PQ)
title('P(Q|T,phi)')
subplot(1,3,3)
contourf(test_T-273, test_phi, joint_likeli)
title('joint likelihood')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. calculate and plot the final posterior distribution
Pjoint = joint_likeli .* prior_T .* prior_phi;
figure()
contourf(test_T-273, test_phi, Pjoint)
title('posterior distribution')

%%%%%%%%%%%%%%%%%%
% 4. still going?
%
% you love all anelastic methods equally... so calculate the ensemble mean
% distribution over all anelastic methods
% (ensemble mean is a weighted sum of distribtuions... equal love = equal weights)
