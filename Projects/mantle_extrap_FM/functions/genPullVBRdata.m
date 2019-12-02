function Box = genPullVBRdata(Box,vbrboxname,VBRsettings)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Box = genPullVBRdata(Box,vbrboxname,VBRsettings)
  %
  % generates or loads the Box
  %
  % Parameters
  % ----------
  % Box          the box from the thermal models
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
    if ~exist('Box','var')
      disp([vbrboxname,' is missing Box'])
    end
  else
    Box = runVBR(Box,VBRsettings);
    save(vbrboxname,'Box')
  end


end

function vbrBox = runVBR(Box,VBRsettings)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Box = runVBR(Box,VBRsettings)
  %
  % generates or loads the Box
  %
  % Parameters
  % ----------
  % Box          the box from the thermal models
  % VBRsettings  structure of some VBR settings
  %
  % Output
  % ------
  % vbrBox       the box with VBR attached
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Load and set shared VBR parameters
  VBR.in.elastic.methods_list={'anharmonic','anh_poro'};
  VBR.in.viscous.methods_list={'HK2003'};
  VBR.in.anelastic.methods_list=VBRsettings.ane_meths;
  VBR.in.elastic.anharmonic=Params_Elastic('anharmonic'); % unrelaxed elasticity
  VBR.in.elastic.anharmonic.Gu_0_ol = 75.5; % olivine reference shear modulus [GPa]

% params.alpha
  % Initialize box
  vbrBox(numel(Box))=struct();

  % run VBR for each Box
  for iBox = 1:numel(Box)
    vbrBox(iBox).info=Box(iBox).info;
    vbrBox(iBox).run_info=Box(iBox).run_info;
    disp(['Running VBR calculator on run ',num2str(iBox),' of ',num2str(numel(Box))])
    VBR.in.SV=buildSVs(Box,iBox,VBRsettings.phi0,VBRsettings.freqs);
    [VBR] = VBR_spine(VBR) ;
    vbrBox(iBox).VBR=VBR;
  end
end

function SVs = buildSVs(Box,iBox,phi0,freqs);

  % pull vars from this box
  [Vars,Info,settings] = pullFromBox(Box,iBox);

  % store in VBR state variables
  SVs.T_K = Vars.T+273; % set HF temperature, convert to K
  SVs.P_GPa = Vars.P/1e9; % pressure [GPa]
  SVs.Ch2o = Vars.Cs_H2O; % water in solid [PPM]
  SVs.rho = Vars.rho; % density [kg m^-3]
  SVs.sig_MPa = Vars.sig_MPa; % differential stress [MPa]
  SVs.dg_um = Vars.dg_um; % grain size [um]
  SVs.Tsolidus_K=Vars.Tsol+273; % solidus [K]
  SVs.phi = phi0 * (SVs.T_K>=SVs.Tsolidus_K); % melt fraction
  SVs.chi=Vars.comp;
  SVs.f = freqs;%  frequencies to calculate at

end
