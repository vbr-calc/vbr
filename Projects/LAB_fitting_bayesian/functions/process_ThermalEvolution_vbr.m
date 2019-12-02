function Work = process_ThermalEvolution_vbr(Files,freq)

disp(['Period range: ' num2str(round(10/freq(end))/10) ' - ' ...
    num2str(round(10/freq(1))/10) ' s']);

Work.Box_name_IN=Files.SV_Box;
VBR=drive_VBR(Work, freq);
save(Files.VBR_Box,'VBR')

end

function VBRBox=drive_VBR(Work, freq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRIVE_VBR.m
% calls VBR for input file in Box format
% uses VBR version 0pt95
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% ------------ %%%
%%% VBR settings %%%
%%% ------------ %%%

% input frequency band
VBR.in.SV.f = freq;

% write VBR methods lists (these are the things to calculate)
elastic = feval(fetchParamFunction('elastic'), '');
VBR.in.elastic.methods_list = elastic.possible_methods; 
viscous = feval(fetchParamFunction('viscous'), '');
VBR.in.viscous.methods_list = viscous.possible_methods;
anelastic = feval(fetchParamFunction('anelastic'), '');
VBR.in.anelastic.methods_list = anelastic.possible_methods; 

VBR.in.anelastic.eBurgers=Params_Anelastic('eburgers_psp');
%VBR.in.anelastic.eBurgers.method='FastBurger';
VBR.in.anelastic.eBurgers.nTauGlob=3000; % points for global Tau discretization

% load elastic parameters
VBR.in.elastic.anharmonic=Params_Elastic('anharmonic');
VBR.in.elastic.anharmonic.Gu_0_ol=73.6; %%%%%%%!!!!!!!!!%%%%%%%%
%%% ---------------- %%%
%%% VBR Calculations %%%
%%% ---------------- %%%

% load the Box
load(Work.Box_name_IN) ;

VBRBox(size(Box, 1),size(Box, 2))=struct('in', struct(), 'BoxParams', struct(),...
    'Z_km', zeros(110,1), 'status', 0, 'error_message','','out',struct());
% loop over box indeces, run VBR calculator on last frame of each run
Work.nBox = numel(Box); Work.tstart = cputime;
for iBox = 1:Work.nBox

    disp('-------------------------------------------------------- ')
    display(['Run ' num2str(iBox) ' of ' num2str(Work.nBox)])

    % pass along some of the Box settings
    VBR.BoxParams=Box(iBox).info;
    VBR.Z_km=Box(iBox).run_info.Z_km;

    sz_SV=size(Box(iBox).Frames(end).P);
    VBR.in.SV.P_GPa = (Box(iBox).Frames(end).P)./1e9 ;
    VBR.in.SV.T_K = Box(iBox).Frames(end).T +273;
    VBR.in.SV.rho = Box(iBox).Frames(end).rho ;
    VBR.in.SV.sig_MPa = 1 * ones(sz_SV) ; %Frames(ifr).sig_MPa ;
    VBR.in.SV.chi = Box(iBox).Frames(end).comp;
    VBR.in.SV.Ch2o = Box(iBox).Frames(end).Cs_H2O;
    VBR.in.SV.phi =  Box(iBox).Frames(end).phi;
    VBR.in.SV.dg_um = Box(iBox).Frames(end).dg_um;
    solidus_C = SoLiquidus(VBR.in.SV.P_GPa, zeros(sz_SV),zeros(sz_SV),...
        'hirschmann');
    VBR.in.SV.Tsolidus_K = solidus_C.Tsol + 273;
    
    % VBR time!
    VBRBox(iBox)=VBR_spine(VBR) ;

end
Work.tend = cputime;

% save the new VBR box

disp('-------------------------------------------------------- ')
disp(' VBR Computations complete!')
disp([' Total VBR Time: ' num2str(( Work.tend- Work.tstart)/60) ' min']);


end
