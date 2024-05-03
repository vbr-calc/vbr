clear 
vbr_init

% set required state variables
VBR.in.SV.T_K = linspace(600,1500,19)'+273; % K, temperature
VBR.in.SV.Ch2o = [0, logspace(0,4,41)]; % ppm, water content
VBR.in.SV.phi = 0.1; % v_f, melt fraction
VBR.in.SV.P_GPa = 0; % GPa, Pressure


% add to electric methods list
VBR.in.electric.methods_list={'yosh2009_ol','SEO3_ol','poe2010_ol','wang2006_ol','UHO2014_ol','jones2012_ol','sifre2014_melt','ni2011_melt','gail2008_melt','HS1962'};

% call VBR_spine
[VBR] = VBR_spine(VBR);