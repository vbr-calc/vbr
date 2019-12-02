function [Vars,Info,settings] = pullFromBox(Box,iBox)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [Vars,Info,settings] = pullFromBox(Box,iBox)
  %
  % pulls out a single run from a box, re-arranges output to match ThermalModel()
  % output.
  %
  % Parameters
  % ----------
  % Box    the box of runs (structure array)
  % iBox   the box index to pull out
  %
  % Output
  % ------
  % Vars      structure with 2d arrays for profiles, e.g., Vars.T(:,it) for T
  %           profile at timestep it
  % Info      structure with time dependent info and variables
  % settings  the settings structure for the run 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  Info=struct();

  % copy some fields
  vars2cp={'t','tMyrs','ssresid','zLAB','zSOL','final_message'};
  for iFie=1:numel(vars2cp)
    Info.(vars2cp{iFie})=Box(iBox).run_info.(vars2cp{iFie});
  end
  Info.z_km=Box(iBox).run_info.Z_km;

  settings=  Box(iBox).run_info.settings;

  % initialize 1D variables
  nt=numel(Box(iBox).Frames);
  nz=numel(Info.z_km);
  Fields = fieldnames(Box(iBox).Frames(1));
  for iFie = 1:numel(Fields);
    Vars.(Fields{iFie})=zeros(nz,nt);
  end

  % copy over this box into Vars from frames
  for it = 1:nt
    %  loop over variables in the Vars structure
    for iFie = 1:numel(Fields);
      Vars.(Fields{iFie})(:,it)=  Box(iBox).Frames(it).(Fields{iFie});
    end
  end

end
