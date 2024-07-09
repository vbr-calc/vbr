%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mantle_extrap.m
%
% - generates a range of mantle conditions
% - calculates mechnaical properties from the thermal models
% - compares mechanical properties between methods for mantle conditions
% - pulls values out of look up table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

% put VBR in the path
% path_to_top_level_vbr='../../';
% addpath(path_to_top_level_vbr)
vbr_init

% % put local functions in path
% addpath('./functions')

% generate mantle conditions from thermal model (or load if it exists)
% ThermalSettings.Tpots=[1400];
fprintf('\nBuilding State Variable Ranges\n')
[SVs, Ranges] = genSVranges();

% run Box through VBR calculator (or load if it exists)
VBR = genPullVBRdata(SVs,fullfile(pwd,'VBR_Box.mat'),VBRsettings);

    % Hashin-Shtrikman for melt mixing model
    VBR = ec_HS1962(VBR,VBR.out.electric.SEO3_ol.esig,VBR.out.electric.sifre2014_melt.esig);
    VBR.out.electric.sifre2014_melt.esig = VBR.out.electric.HSup.esig;
    VBR = ec_HS1962(VBR,VBR.out.electric.SEO3_ol.esig,VBR.out.electric.ni2011_melt.esig);
    VBR.out.electric.ni2011_melt.esig = VBR.out.electric.HSup.esig;
    VBR = ec_HS1962(VBR,VBR.out.electric.SEO3_ol.esig,VBR.out.electric.gail2008_melt.esig);
    VBR.out.electric.gail2008_melt.esig = VBR.out.electric.HSup.esig;

    % Remove HS fieldnames
    VBR.out.electric = rmfield(VBR.out.electric, {'HS','HSup','HSlo'});

% build figures and comparisons
% buildComparisons(VBR,Ranges,fullfile(pwd,'figures/'));

% freq_target=0.01;
esigtarget=0.1; % S/m
% scale_fac=1/1000; % search for km/s rather than m/s
cutoffperc=5;

Ranges=VarRange(VBR,esigtarget,'esig',cutoffperc);
% PossibleRanges=VarRange(VBR,esigtarget,'esig',cutoffperc);

% Serpent Data
Serpent = LoadSerp();
for id = 1:size(Serpent,1)
SerpRanges = zeros(size(SVs.mf,1), size(SVs.mf,2), size(SVs.mf,3), 100);
end

% 
% 
% SerpRanges = zeros(size(SVs.mf) 10);
for id = 1:numel(Serp)
esigtarget=Serp(id); % S/m
Ranges=VarRange(VBR,esigtarget,'esig',cutoffperc); 
end
%%

function [SVs,Ranges] = genSVranges()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [SVs,Ranges] = genSVranges()
  %
  % builds state variable structure and ranges varied.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Ranges.T_K=1100:5:1600 + 273; % K, temperature
  Ranges.phi=logspace(-6,0,141); % v_f, melt fraction
  Ranges.Ch2o=logspace(0,4,101); % ppm, water content
  Constants.Tsolidus_K=1200+273;

  % get length of each range
  flds=fieldnames(Ranges);
  for ifld=1:numel(flds)
    N.(flds{ifld})=numel(Ranges.(flds{ifld}));
  end

  % build SVs for each var
  flds=fieldnames(Ranges);
  for ifld=1:numel(flds)
    SVs.(flds{ifld})=zeros(N.T_K,N.phi,N.Ch2o);
  end
  for iT=1:N.T_K
    SVs.T_K(iT,:,:)=Ranges.T_K(iT);
  end
  for iphi=1:N.phi
    SVs.phi(:,iphi,:)=Ranges.phi(iphi);
  end
  for iCh2o=1:N.Ch2o
    SVs.Ch2o(:,:,iCh2o)=Ranges.Ch2o(iCh2o);
  end

  % % fill in the other constants
  % flds=fieldnames(Constants);
  % onz=ones(size(SVs.T_K));
  % for ifld=1:numel(flds)
  %   SVs.(flds{ifld})=Constants.(flds{ifld}) * onz;
  % end
  % 
  % SVs.phi(SVs.T_K<SVs.Tsolidus_K)=0;

  den_p = 3.3; % g/cm^3, density peridotite
  den_m = 2.8; % g/cm^3, density dry mantle [Sifre et al, 2014]
  mf = (((1-SVs.phi)./SVs.phi).*(den_p./den_m)+1).^-1; % mass fraction test value
  SVs.mf = mf;

end

function VBR = genPullVBRdata(SVs,vbrboxname,VBRsettings)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Box = genPullVBRdata(SVs,vbrboxname,VBRsettings)
  %
  % generates or loads the Box
  %
  % Parameters
  % ----------
  % SVs          the state variables
  % vbrboxname   the box to save with vbr data (or load from )
  % VBRsettings  structure of some VBR settings
  %
  % Output
  % ------
  % Box          the box with VBR attached
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if exist(vbrboxname,'file')
    disp(['Loading VBR calculations from ',vbrboxname,'. (Delete it to re-run)'])
    load(vbrboxname);
    if ~exist('VBR','var')
      disp([vbrboxname,' is missing VBR'])
    end
  else
    VBR = runVBR(SVs,VBRsettings);
    % save(vbrboxname,'VBR')
  end


end

function VBR = runVBR(SVs)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Box = runVBR(Box,VBRsettings)
  %
  % generates or loads the Box
  %
  % Parameters
  % ----------
  % SVs          the state variables
  % VBRsettings  structure of some VBR settings
  %
  % Output
  % ------
  % VBR          the VBR structure
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Load and set shared VBR parameters
  VBR.in.electric.methods_list={'yosh2009_ol','SEO3_ol','poe2010_ol','wang2006_ol','UHO2014_ol','jones2012_ol','sifre2014_melt','ni2011_melt','gail2008_melt'};

  VBR.in.SV=SVs;
  disp('Calculating material properties....')
  [VBR] = VBR_spine(VBR) ;
end

function Ranges=VarRange(VBR,target_val,target_var,cutoff)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Ranges=getVarRange(VBR,target_val,target_var,cutoff)
  %
  % finds parameter ranges within cutoff percent of target_val. Only a simple
  % gridsearch, does not account for co-varying parameters. 
  %
  % Parameters
  % ----------
  % VBR          the VBR structure
  % target_val
  % target_var
  % cutoff
  %
  % Output
  % ------
  % Ranges       structure with resulting ranges for each method.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  meths=fieldnames(VBR.out.electric);
  Nmeths=numel(meths);

SVflds={'T_K';'Ch2o';'phi'};
  for imeth=1:Nmeths
    meth=meths{imeth};
    var=squeeze(VBR.out.electric.(meth).(target_var));
    dvar=abs(var-target_val)./target_val*100;

    for ifl=1:numel(SVflds)
      goodvals=VBR.in.SV.(SVflds{ifl})(dvar<=cutoff);
      fldn=SVflds{ifl};
      if strcmp(fldn,'T_K')
        fldn='T_C';
        offset=-273;
      else
        offset=0;
      end
      Ranges.(meth).(fldn).N=numel(goodvals);
      Ranges.(meth).(fldn).min=min(goodvals+offset);
      Ranges.(meth).(fldn).max=max(goodvals+offset);
      Ranges.(meth).(fldn).std=std(goodvals+offset);
      if Ranges.(meth).(fldn).N > 1
        Ranges.(meth).(fldn).meanval=mean(goodvals+offset);
      end

    end

  end

  fprintf(['Possible Ranges in T,Ch2o,phi for ',target_var,' within ',num2str(cutoff),' perc. of ',num2str(target_val),' S/m :\n'])
  fprintf('\n method,T min [C], T max [C], Ch2o min [ppm], Ch2o max [ppmm], phi min, phi max \n')
  SVflds={'T_C';'Ch2o';'phi'};
  for imeth=1:Nmeths
    meth=meths{imeth};
    thisline=meths{imeth};
    for ifl=1:numel(SVflds)
      fldn=SVflds{ifl};
      thisline=[thisline,',',num2str(Ranges.(meth).(fldn).min),',',num2str(Ranges.(meth).(fldn).max)];
    end
    thisline=[thisline,'\n'];
    fprintf(thisline)
  end
end
