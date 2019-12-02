function  [Box] = Put_in_Box(Box,Vars,Info,settings,iBox)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [Box] = Put_in_Box(Box,Vars,Info,settings,iBox)
  %
  % Stores a single forward model in the Box
  %
  % Parameters
  % ----------
  %   Box        the container for the runs, array-structure
  %   Vars       variables output struct from a single Thermal_Evolution model
  %              run
  %   Info       scalar time-dep vars, mesh and more, output struct from a
  %              single Thermal_Evolution model run
  %   settings   the settings struct used for the Thermal_Evolution run
  %   iBox       the box number
  %
  % Output
  % ------
  %   Box        updated Box, Box(iBox) is now set
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % stagger routine (output on nodes, not element center)
  stag=@(f) (f(2:end)+f(1:end-1))/2;

  % get infos!
  nt = numel(Info.t);
  zHigh = (Info.z_km);
  nz = numel(zHigh);
  meth = settings.Box.DownSampleMeth;
  DownFactor=settings.Box.DownSampleFactor;

  % store the Box Movie info
  vars2cp={'t','tMyrs','ssresid','zLAB','zSOL','final_message'};
  for iFie=1:numel(vars2cp)
    Box(iBox).run_info.(vars2cp{iFie})=Info.(vars2cp{iFie});
  end

% get downsampled depth bins or points
  if strcmp(meth,'interp')
      zLow = linspace(zHigh(1),zHigh(end),nz/DownFactor)';
  end
  Box(iBox).run_info.Z_km=zLow;
  Box(iBox).run_info.settings = settings;

% loop over time steps, store in Movie Frames
  for it = 1:nt

%  loop over variables in the Vars structure
   Fields = fieldnames(Vars);
   for iFie = 1:numel(Fields);
      LowRes = downsample((Vars.(Fields{iFie})(:,it)),zHigh,zLow,meth);
      Box(iBox).Frames(it).(Fields{iFie})=LowRes;
   end
  end

end

function Ylow = downsample(Yhigh,Xhigh,Xlow,meth)
 if strcmp(meth,'interp')
     Ylow = interp1(Xhigh,Yhigh,Xlow);
 elseif strcmp(meth,'averaging')
     disp('not implemented!')
 end
end
