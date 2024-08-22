function VBR = genPullVBRData(SVs,vbrboxname,VBRsettings)
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
    save(vbrboxname,'VBR')
  end


end

function VBR = runVBR(SVs,VBRsettings)
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
  VBR.in.electric.methods_list=VBRsettings.ele_meths;
  VBR.in.SV=SVs;
  VBR = ec_vol2part(VBR, 'sifre2014','vol'); % Ch2o and Cco2 partitioning between ol & melt phases
  disp('Calculating material properties....')
  [VBR] = VBR_spine(VBR);
end
