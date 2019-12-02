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
    save(vbrboxname,'VBR')
  end


end

function VBR = runVBR(SVs,VBRsettings);
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
  VBR.in.elastic.methods_list={'anharmonic','anh_poro'};
  VBR.in.viscous.methods_list={'HK2003'};
  VBR.in.anelastic.methods_list=VBRsettings.ane_meths;
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
  VBR.in.elastic.anharmonic.Gu_0_ol = 75.5; % olivine reference shear modulus [GPa]

  VBR.in.SV=SVs;
  VBR.in.SV.f=VBRsettings.freqs;
  disp('Calculating material properties....')
  [VBR] = VBR_spine(VBR) ;
end
