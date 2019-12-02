function Z_LAB_Q = find_LAB_Q(Q_z,Z_km,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% finds seismic LAB using Q. LAB defined either as an absolute value of Q or
% as the depth where Q = Q_factor * ave Asthenosphere Q.
% Reminder low Q = high attenuation (Q^-1), so LAB Q will be > astheno Q.
%
% Input:
%  Q_z, Z_km : Q and depth. 1d arrays.
%  varargin : optional arguments (see below)
%
% varargin options:
%    'method': 'Q_factor' or 'Q_value'
%  if 'method'=='Q_factor':
%    Z_LAB_Q = find_LAB_Q(Q_z,Z_km,'method','Q_factor','value',20,'z_min',150)
%    'value': LAB Q = value * ave Astheno Q
%    'z_min_km':  z_min > Z_plate is averaged to get Astheno Q
%  if 'method'=='Q_value'
%    Z_LAB_Q = find_LAB_Q(Q_z,Z_km,'method','Q_value',800)
%    'value': absolute value of Q. LAB Q = Q_value
%
% Output:
%  Z_LAB_Q : the seismic LAB depth from Q. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% process varargin args
  ValidOpts=struct();
  ValidOpts.method={'Q_factor','Q_value'}; % allow two methods
  ValidOpts.value={}; % allow any value
  ValidOpts.z_min_km={}; % allow any z_min
  % set defaults
  Options=struct('method','Q_factor','value',20,'z_min_km',80);
  Options=validateStructOpts('fit_Qprofile_zLAB',varargin,Options,ValidOpts,0);

  if strcmp(Options.method,'Q_factor')
    Q_LAB = Options.value * mean(Q_z(Z_km>=Options.z_min_km));
  else
    Q_LAB = Options.value;
  end

  % Find the position of the nearest Q_z value to Q_LAB
  ind_Qlab = find(Q_z<=Q_LAB,1);
  Z_LAB_Q = Z_km(ind_Qlab);

end
