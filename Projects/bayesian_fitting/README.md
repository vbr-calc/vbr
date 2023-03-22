# bayesian_fitting

This Project contains the example workflow of a Bayesian inference following Havlin, Holtzman and Hopper (2020, in review).

At present, `run_bayes.m` runs separate and joint Bayesian inferences of state variables beneath 4 representative locations in the U.S. The primary function is  `fit_seismic_observations.m`. See above reference for more background (contact authors for a pre-print if the paper is not yet in press by the time you're reading this).

When running `run_bayes.m` for the first time, the code will attempt fetch the needed example data (184 Mb of data) and save it in `Projects/LAB_fitting_bayesian/data/`. If the download fails, contact the authors to get the example data or visit https://github.com/vbr-calc/vbrPublicData/ and download a zip file of the repo and copy over `LAB_fitting_bayesian/data` to this directory.

Note that while the code runs in Octave, the formatting of the figures will be slightly off.
