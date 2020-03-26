# bayesian_fitting

This Project contains the example workflow of a Bayesian inference following Havlin, Holtzman and Hopper (2020, in review). The code requires MATLAB (not Octave compatible yet).

At present, `run.m` runs separate and joint Bayesian inferences of state variables beneath 4 representative locations in the U.S. The primary function is  `fit_seismic_observations.m`. See above reference for more background (contact authors for a pre-print if the paper is not yet in press by the time you're reading this).

When running `run.m`, the code will fetch the needed example data (184 Mb of data) and save it in `Projects/LAB_fitting_bayesian/data/`.
