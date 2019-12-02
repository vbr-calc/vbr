function LABInfo = find_LAB(Vark,z,settings,LABInfo)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % LABInfo = find_LAB(Vark,z,settings,LABInfo)
  %
  % finds the current LAB depth
  %
  % Parameters
  % ----------
  % Vark         current variables structure
  % z            depth array [m]
  % settings     settings structure
  % LABInfo      current LABInfo structure
  %
  % Output
  % ------
  % LABInfo.     updated LABInfo structure
  %        .zMO, .zMOid     depth and node of melting onset
  %        .zSOL, .zSOLid   depth and node of geotherm-solidus intersection
  %        .zLAB, .zLABid    depth and node of viscous LAB
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % initialize
  zSOL = max(z);zSOLid=numel(z); % shallowest solidus-geotherm intersection
  zMO = max(z);zMOid=numel(z);   % deepest solidus-geotherm intersection (Melting Onset, MO)
  zLAB = max(z);zLABid=numel(z); % the LAB defined as an order of magnitude drop in
                                % viscosity relative to convecting interior
  % solidus zLAB
  izLAB = 3; LAB_success = 'failed';
  while izLAB < numel(Vark.T)
     if Vark.T(izLAB) > Vark.Tsol(izLAB)% && Vark.phi(izLAB) > 1e-5;%settings.phimin
         zSOLid = izLAB; % first one below boundary
         izLAB = numel(Vark.T) * 2;
         zSOL = z(zSOLid);
         LAB_success = 'succeeded';
     else
         izLAB = izLAB + 1;
     end
  end

  % vicsous zLAB: ratio based on average eta below
  viscLABid='looking'; iz = 5; nz = numel(Vark.T);
  while strcmp(viscLABid,'found')==0 && iz < nz-1;
     zrange=[nz-iz:nz];
     eta = Vark.eta(zrange);
     zeta = z(zrange);
     eta_ave=cumtrapz(zeta,eta)./(max(zeta)-min(zeta));
     eta_ave=eta_ave(end);


     if eta(1)/eta_ave>=10;
         viscLABid='found';
         zLAB=z(nz-iz);
         zLABid=nz-iz;
     end
     iz = iz+1;
  end
  if strcmp(viscLABid,'looking')==1
     zLAB=zSOL;
     zLABid=zSOL;
  end

  % melting onset
  izMO = numel(Vark.T)-2;
  zMOid = izMO; zMO=z(zMOid);
  while izMO > 5
     if Vark.T(izMO) > Vark.Tsol(izMO)% && phi(izLAB) > settings.phimin
         zMOid = izMO; % first one below boundary
         zMO=z(zMOid);
         izMO = 1;
     else
         izMO = izMO - 1;
     end
  end

  % store it all
  LABInfo.zMOid=zMOid;
  LABInfo.zMO=zMO;
  LABInfo.zLAB=zLAB;
  LABInfo.zLABid=zLABid;
  LABInfo.zSOL=zSOL;
  LABInfo.zSOLid=zSOLid;
end
