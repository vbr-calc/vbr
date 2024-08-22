function [SVs,Ranges] = genSVranges()
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [SVs,Ranges] = genSVranges()
  %
  % builds state variable structure and ranges varied.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Ranges.T_K=[1100:5:1700] + 273; % K, temperature
  Ranges.Ch2o=[0 logspace(0,4,101)]; % ppm, water content
  Ranges.mf=[0 logspace(-6,0,141)]; % mf, mass fraction of melt

  % get length of each range
  flds=fieldnames(Ranges);
  for ifld=1:numel(flds)
    N.(flds{ifld})=numel(Ranges.(flds{ifld}));
  end

  % build SVs for each var
  flds=fieldnames(Ranges);
  for ifld=1:numel(flds)
    SVs.(flds{ifld})=zeros(N.T_K,N.Ch2o,N.mf);
  end
  for iT=1:N.T_K
    SVs.T_K(iT,:,:)=Ranges.T_K(iT);
  end
  for iCh2o=1:N.Ch2o
    SVs.Ch2o(:,iCh2o,:)=Ranges.Ch2o(iCh2o);
  end
  for imf=1:N.mf
    SVs.mf(:,:,imf)=Ranges.mf(imf);
  end
end