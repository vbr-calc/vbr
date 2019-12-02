function [SVs,Ranges] = genSVranges()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [SVs,Ranges] = genSVranges()
  %
  % builds state variable structure and ranges varied.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Ranges.T_K=800:10:1500 + 273;
  Ranges.phi=logspace(-8,-2,20);
  Ranges.dg_um=logspace(-3,-2,21)*1e6;

  Constants.sig_MPa=0.1;
  Constants.P_GPa=2.5;
  Constants.rho=3300;
  Constants.Tsolidus_K=1200+273;

  % get length of each range
  flds=fieldnames(Ranges);
  for ifld=1:numel(flds)
    N.(flds{ifld})=numel(Ranges.(flds{ifld}));
  end

  % build SVs for each var
  flds=fieldnames(Ranges);
  for ifld=1:numel(flds)
    SVs.(flds{ifld})=zeros(N.T_K,N.phi,N.dg_um);
  end
  for iT=1:N.T_K
    SVs.T_K(iT,:,:)=Ranges.T_K(iT);
  end
  for iphi=1:N.phi
    SVs.phi(:,iphi,:)=Ranges.phi(iphi);
  end
  for idg=1:N.dg_um
    SVs.dg_um(:,:,idg)=Ranges.dg_um(idg);
  end

  % fill in the other constants
  flds=fieldnames(Constants);
  onz=ones(size(SVs.T_K));
  for ifld=1:numel(flds)
    SVs.(flds{ifld})=Constants.(flds{ifld}) * onz;
  end

  SVs.phi(SVs.T_K<SVs.Tsolidus_K)=0;
end
