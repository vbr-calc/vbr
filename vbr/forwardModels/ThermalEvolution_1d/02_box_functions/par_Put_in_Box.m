function  [Box] = par_Put_in_Box(Box0,Box)

% stagger routine (output on nodes, not element center)
  stag=@(f) (f(2:end)+f(1:end-1))/2; 

  for iBox = 1:numel(Box)
          
          Info=Box0(iBox).Info;
          Vars=Box0(iBox).Vars;
          settings=Box0(iBox).settings;
          
          % get infos!
          nt = numel(Info.t);
          zHigh = (Info.z_km);
          nz = numel(zHigh);
          meth = settings.Box.DownSampleMeth;
          DownFactor=settings.Box.DownSampleFactor;
                              
          % store the Box Movie info       
            Box(iBox).run_info.timesteps=Info.t; 
            Box(iBox).run_info.timesteps_myrs=Info.tMyrs;
            Box(iBox).run_info.ssresid=Info.ssresid;
            Box(iBox).run_info.zLAB=Info.zLAB;
            Box(iBox).run_info.zSOL=Info.zSOL;
            Box(iBox).run_info.zMO=Info.zMO;
            Box(iBox).run_info.end_of_run=Info.final_message;
          
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
                  LowRes = downsample(Vars.(Fields{iFie})(:,it),zHigh,zLow,meth);
                  Box(iBox).Frames(it).(Fields{iFie})=LowRes;
              end
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

