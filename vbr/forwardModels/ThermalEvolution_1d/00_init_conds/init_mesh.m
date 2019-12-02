function Zinfo = init_mesh(Zinfo)

% uniform mesh
  nz = (Zinfo.zmax - Zinfo.zmin)/Zinfo.dz0;
  Zinfo.z_m = linspace(Zinfo.zmin,Zinfo.zmax,nz)'*1e3;
  Zinfo.z_km = Zinfo.z_m * 1e-3; 
  Zinfo.nz = nz; 

% recaculate and store dz due to rounding when calculating nz
% THIS IS IMPORTANT FOR STABILITY FOR ADVECTIVE SCHEMES
  Zinfo.dz = (Zinfo.z_m(2) - Zinfo.z_m(1))/1e3; 
  Zinfo.dz_m = Zinfo.dz*1e3;

end
