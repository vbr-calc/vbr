% visual check that the inv_cdf_normal function works as expected.
% compares to the normrnd function from octave statistics package
% so this script requires that package. (`pkg install statistics`)
%
% also uses the probability_distributions function in vbr, so
% vbr is initialized here

addpath('../../../')
vbr_init % to use probability_distributions
pkg load 'statistics'

n = [1000,1];
mean_val = 50;
std_val = 5;
u = rand(n);
samples = inv_cdf_normal(u, mean_val, std_val);
samples_2 = normrnd (mean_val, std_val, n);

x = linspace(0,100,200);
% get the pdf using vbrc function
p_x = probability_distributions('normal', x, mean_val, std_val);
% also get the pdf using statistics package
p_x_2 =normpdf(x, mean_val, std_val);

% do it once to get bin width
n_bins = 20;
[binned_vals, bin_centers] = hist(samples, n_bins, 1);
bin_wid = mean(diff(bin_centers));

subplot(1,2,1)
hold off
hist(samples, n_bins, 1 ./ bin_wid);
hold on
plot(x,p_x,'b','linewidth',2)
plot(x,p_x_2,'--r','linewidth',2)
title(mean(samples))
set(gca,'ylim',[0,.1])

subplot(1,2,2)
hold off
hist(samples_2, n_bins, 1 ./ bin_wid)
hold on
plot(x,p_x,'b','linewidth',2)
plot(x,p_x_2,'--r','linewidth',2)
title(mean(samples_2))
set(gca,'ylim',[0,.1])