clear all
% parms
mantle_mineralogy = 'pyrolite';
T_K_ref   = 1300 + 273;
P_GPa_ref = 3.0;

dT = 1;
dP = 1e-6;


%% paths
addpath('~/Dropbox/MATLAB/seis_tools/ABERSHACKER16/')

% Load mineral database
[minpropar, compar]=ah16_loaddb('AbersHackerMacroJan2016.txt');
%  mantle composition
switch mantle_mineralogy
    case 'lherzolite' % mantle = lherzolite
        ma_mins ={'fo' ,'fa','en' ,'fs','di','sp'}; 
        ma_modes=[45.51,5.07,22.48,2.5,20.03,4.5];       % These are volume fraction modes
        
    case 'pyrolite' % mantle = pyrolite
        ma_mins ={'alm' ,'gr','py' ,'fo','fa','en','fs','di','hed'}; 
        ma_modes=[2.1   ,1.1 ,10.8 ,54.5,6.7 ,14.7,1.5 ,7.4 ,1.2];       % These are volume fraction modes
        
    case 'harzburgite' % mantle = harzburgite
        ma_mins ={'fo', 'fa', 'en','fs'}; 
        ma_modes=[72.48,7.52,18.24,1.76];       % These are volume fraction modes    
end

% calculate rock moduli
% modu=ah16_rockvel(0,1e-5, minpropar, ma_mins,ma_modes);

%% calculate moduli and other properties 
modu_TP=ah16_rockvel(T_K_ref-273,P_GPa_ref, minpropar, ma_mins,ma_modes);
Gu_ref = modu_TP.g*1e9; % in Pa (NOT GPA)
Ku_ref = modu_TP.k*1e9; % in Pa (NOT GPA)

modu_TP_t=ah16_rockvel(T_K_ref-273+dT,P_GPa_ref, minpropar, ma_mins,ma_modes);
modu_TP_p=ah16_rockvel(T_K_ref-273,P_GPa_ref+dP, minpropar, ma_mins,ma_modes);

dGdT = (modu_TP_t.g - modu_TP.g)*1e-9./dT;
dGdP = (modu_TP_p.g - modu_TP.g)./dP;

dKdT = (modu_TP_t.k - modu_TP.k)*1e-9./dT;
dKdP = (modu_TP_p.k - modu_TP.k)./dP;

Gu_ref
Ku_ref
dGdT
dGdP
dKdT
dKdP