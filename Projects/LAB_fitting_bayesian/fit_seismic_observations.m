function posterior = fit_seismic_observations(filenames, location, q_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% fit_seismic_observations
%
% Fit an input shear velocity profile (and LAB depth, if given) to state
% variables using VBR.
%
% Parameters:
% -----------
%       filenames   structure with the paths to observational data saved
%                   as .mat files in the required format.  Depending on
%                   the fields in filenames, this code will return a 
%                   posterior given Vs, Q, or Vs and Q.
%       
%
%       location    structure with the following required fields
%           lat         latitude [degrees North]
%           lon         longitude - assumed to be positive [degrees East]
%           z_min       minimum depth for observation range [km]
%           z_max       maximum depth for observation range [km]
%          (smooth_rad  radius (in degrees) to smooth over observations)
%
% Hardwired variables most worth playing with:
% -------------------------------------------
%       sweep_params        lines 91-97
%                           structure with the following required fields
%               T               vector of temperature values [deg C]
%               phi             vector of melt fractions [vol fraction]
%               gs              vector of grain sizes [micrometres]
%               per_bw_max      maximum period (min. freq.) considered [s]
%               per_bw_min      minimum period (max. freq.) considered [s]
%
%       pdf_type            line 121
%                           shape of prior distribution assumed for 
%                           (independent priors) - can be set to 
%                               'uniform' (currently hardwired)
%                               'normal' (mean, std calculated from range)
%                               'input' (assumes there is a field in
%                                        params, [varname]_pdf)
%
% Output:
% -------
%       posterior           structure with the following fields
%               pS              posterior probability of S
%               state_names     as state_names in sweep - that is, a list
%                               of the state variables that have been 
%                               varied in this calculation
%               [SV name]       for each state variable listed in 
%                               state_names, a vector of the values used
%      
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup path structure
% put top level of VBR in the path
addpath('../../'); vbr_init

% put Project-specific paths in the path
addpath(genpath('./functions'))
buildProjectDirectories()
addpath(genpath('./'))

%% %%%%%%%%%%%%%%%% Get data for Vs(x, f) and Q(x, f) %%%%%%%%%%%%%%%%% %%
% Vs(x, f) and Q(x, f) are constrained by seismic observations and their %
% uncertainties.                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
ifplot = 1;
if isfield(filenames, 'Vs')
    [obs_Vs, sigma_Vs] = process_SeismicModels('Vs', ...
        location, filenames.Vs, ifplot);
end

if isfield(filenames, 'Q')
    [obs_Q, sigma_Q] = process_SeismicModels('Q', ...
        location, filenames.Q, ifplot);
end


%% %%%%%%%%%%%%%%%%%% Get prior for State Variables %%%%%%%%%%%%%%%%%%% %%
% The prior probability distribution for the state variables can be      %
% assumed to be either uniform or normal across the input range given.   %
% The probability that the given state variable is actually correct.     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preferably, load in a large, pre-calculated box
fname = 'data/plate_VBR/sweep_longperiod.mat';
if ~exist(fname, 'file')
    sweep_params.T = 1000:50:1700; %[degrees C]
    sweep_params.phi = (0.0:0.005:0.03); % melt fraction
    sweep_params.gs = linspace(0.001,0.03,10)*1e6; % grain size [micrometres]
    % Set period range for the mask - used to define which calculated
    % velocities go into the returned average Vs for those conditions
    sweep_params.per_bw_max = 150; % max period of range of mask (s)
    sweep_params.per_bw_min = 50; % min period of range of mask (s)

    sweep = generate_parameter_sweep(sweep_params);
    clear sweep_params
    save(fname, 'sweep')
end

load(fname, 'sweep');
if isfield(filenames, 'Vs')
    [sweep.meanVs, sweep.z_inds] = extract_calculated_values_in_depth_range(...
        sweep, 'Vs', q_method, [location.z_min, location.z_max]);
end
if isfield(filenames, 'Q')
    sweep.meanQ = extract_calculated_values_in_depth_range(sweep, ...
        'Q', q_method, [location.z_min, location.z_max]);
end

% For each of the variables in sweep, set the mean and std
% Default is to calculate these based on the ranges set in sweep_params
params = make_param_grid(sweep.state_names, sweep);
% Note - can manually set the expected value and standard deviation for
% each of your variables, e.g. params.T_mean = 1500; params.gs_std = 300;

% Calculate the prior for either a normal or uniform distribution
pdf_type = {'uniform'};
prior_statevars = priorModelProbs(params, sweep.state_names, pdf_type);


%% %%%%%%%%%%%%%%%%%%%%% Get likelihood for Vs, Q %%%%%%%%%%%%%%%%%%%%%% %%
% The likelihood p(D|A), e.g., P(Vs | T, phi, gs), is calculated using    %
% the residual (See manual, Menke book Ch 11):                            %
%       p(D|A) = 1 / sqrt(2 * pi * residual) * exp(-residual / 2)         %
% residual(k) here is a chi-squared residual. Given chi-square, the PDF   %
% of data with a normal distribution:                                     %
%       P = 1 / sqrt(2 * pi * sigma^2) * exp(-0.5 * chi-square)           %
% where sigma = std of data, chi-square=sum((x_obs - x_preds)^2 / sigma^2)%
% e.g. www-cdf.fnal.gov/physics/statistics/recommendations/modeling.html  %
% The probability of getting the observed Vs or Q given the assumed state %
% variable values.                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(filenames, 'Vs')
    likelihood_Vs = probability_distributions('likelihood from residuals', ...
        obs_Vs, sigma_Vs, sweep.meanVs);
end
   
if isfield(filenames, 'Q')
    likelihood_Q = probability_distributions('likelihood from residuals', ...
        obs_Q, sigma_Q, sweep.meanQ);
end
    
%% %%%%%%%%%%%%%%%% Get posterior for State Variables %%%%%%%%%%%%%%%%%% %%
% The posterior probability distribution is calculated in a Bayesian way  %
%       p(S | D)    proportional to    p(D | S) * p(S)                    %
% The probability of the state variables given the observed Q and Vs.     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(filenames, 'Vs')
    posterior_S_given_Vs = probability_distributions('A|B', ...
        likelihood_Vs, prior_statevars, 1);
    vs_str = sprintf(['Vs = %.3g ', 177, ' %.2g km/s'], obs_Vs, sigma_Vs);
    plot_Bayes(posterior_S_given_Vs, sweep, vs_str, q_method)
    plot_tradeoffs_posterior(posterior_S_given_Vs, sweep, vs_str, q_method)
    posterior.pS = posterior_S_given_Vs;
end

if isfield(filenames, 'Q')
    posterior_S_given_Q =  probability_distributions('A|B', ...
        likelihood_Q, prior_statevars, 1);
    q_str = sprintf(['Q = %.2g ', 177, ' %.2g '], obs_Q, sigma_Q);
    plot_Bayes(posterior_S_given_Q, sweep, q_str, q_method)
    plot_tradeoffs_posterior(posterior_S_given_Q, sweep, q_str, q_method)
    posterior.pS = posterior_S_given_Q;
end



%% %%%%%%% Get posterior for State Variables given both Vs and Q %%%%%%% %%
% The measurement uncertainties in Vs and Q are assumed to be             %
% uncorrelated.  As such, we can simplify                                 %
%    p(S | (Vs, Q))    proportional to    (p(Vs | S) * p(Q | S) * p(S))   %
% The probability of the state variables being correct given constraints  %
% from both Vs and Q.                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(filenames, 'Vs') && isfield(filenames, 'Q')
    posterior_S_given_Vs_and_Q = probability_distributions(...
        'C|A,B conditionally independent', likelihood_Vs, likelihood_Q, ...
        prior_statevars, 1);
    
    vs_q_str = [vs_str, ', ', q_str];
    plot_Bayes(posterior_S_given_Vs_and_Q, sweep, vs_q_str, q_method)
    
    plot_tradeoffs_posterior(posterior_S_given_Vs_and_Q, sweep, ...
        vs_q_str, q_method)
    
    posterior.pS = posterior_S_given_Vs_and_Q;
    
end

posterior.state_names = sweep.state_names;
for nm = sweep.state_names
    posterior.(nm{1}) = sweep.(nm{1});
end


end
