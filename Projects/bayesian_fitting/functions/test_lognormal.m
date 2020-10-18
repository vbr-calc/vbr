

gs_mean = .03 * 1e6; % [micrometres]
gs_std = .1; % dimensionless.0005 * 1e6; % [micrometers] 
gs_pdf_type = 'lognormal'; 

gsmin = 0.0001*1e6; gsmax = 0.03*1e6; gsref = 0.001*1e6; 
gs = gsref * exp(linspace(log(gsmin/gsref),log(gsmax/gsref),100));


gs_norm = gs /gsref; 


gs_norm_mean = gs_mean / gsref; 

log_pdf = probability_distributions('lognormal',gs_norm,log(gs_norm_mean),gs_std);


% close all
figure 
subplot(1,3,1)
plot(gs_norm,log_pdf)
hold 
plot([gs_mean/gsref,gs_mean/gsref],[min(log_pdf),max(log_pdf)],'--k')

subplot(1,3,2)
plot(log(gs_norm),log_pdf)
hold 
plot(log([gs_mean/gsref,gs_mean/gsref]),[min(log_pdf),max(log_pdf)],'--k')

subplot(1,3,3)
plot(gs,log_pdf)
hold
plot([gs_mean,gs_mean],[min(log_pdf),max(log_pdf)],'--k')
