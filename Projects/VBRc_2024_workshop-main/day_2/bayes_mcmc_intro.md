## `bayesian_fiting_0d_mcmc` 

A single-parameter bayesian markov-chain monte carlo (mcmc) simulation with 
Metropolis-Hastings sampling to invert a spot measurements of shear wave velocity 
and attenuation for the underlying temperature. 

### A brief overview of MCMC + Metropolis-Hastings

insert notes 

### Overview of the code 

```matlab
% prior distribution settings
priors.T_K_mean = 1200 + 273;  % mean of T_K prior distribution
priors.T_K_std = 200;  % standard deviation of T_K prior distribution
``` 
```matlab
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
``` 

**IMPORTANT**: the version of the code sets `mcmc_max_iters` to a **very** small number in order to 
easily check that the code runs. You'll want to increase this number. How much is up to you :) 

```matlab
% set the fixed state variables and single anelastic method
settings.fixed_SVs.P_GPa = 2;
settings.fixed_SVs.sig_MPa = 0.1;
settings.fixed_SVs.phi = 0;
settings.fixed_SVs.dg_um = 0.01 * 1e6;
settings.fixed_SVs.f = 1. / 50.;
settings.fit_a_fixed_TK = 1; % 1 to fixed hidden T_K, 0 to draw from distribution about a hidden mean
settings.anelastic_method = 'eburgers_psp';
``` 

### Explorations 


#### Understanding MCMC-MH

The following are a number of ideas for getting a better handle on how different 
settings affect the inferred result. 

1. what temperature was used to generate the synthetic observations? (check your answer by looking at `bayes_0d_funcs/get_data.m`)
2. how does increasing the number of iterations affect convergence?
3. how does the jump magnitude affect convergence?
4. how does the initial guess affect convergence? 
5. how does the uncertainty of the observations affect convergence? (go edit `bayes_0d_funcs/get_data.m`)
6. what is the difference in the resulting temperature with different averaging methods:
   * taking a single value from the final model
   * taking an average of values after burn-in 
   * averaging single values from multiple runs 
   * averaging values after burn-in across multiple runs 

#### Extending 

Here are some coding exercises that would be interesting! 

1. Add frequency-dependence
2. Add more parameters (like melt fraction or grain size)
3. Re-write the code as a function and then write a script to run and store results from multiple chains. For more of a challenge, parallelize it.



### A note on `sample_normal`
 
The functions in `bayes_0d_funcs` include a drop-in replacement for `normrnd`, called 
`sample_normal` in order to avoid extra dependencies. It's probably a little slow. You
could instead replace it with calls to `normrnd` in the following ways:

For octave, install the [Statistics package](https://wiki.octave.org/Statistics_package)
from octave terminal with 
```matlab
> pkg install -forge statistics
> pkg load statistics
```

For MATLAB, you'll need to install the [statistics and ML toolbox](https://www.mathworks.com/products/statistics.html) (normally included in educational licenses).

### additional reading 

The following are nice introductions to writing an mcmc sampler from scratch:

* https://exowanderer.medium.com/metropolis-hastings-mcmc-from-scratch-in-python-c21e53c485b7
* https://twiecki.io/blog/2015/11/10/mcmc-sampling/
 

 