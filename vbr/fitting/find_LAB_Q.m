function Z_LAB_Q = find_LAB_Q(Q_z,Z_km,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% finds seismic LAB using Q. LAB defined either as an absolute value of Q or
% as the depth where Q = Q_factor * ave Asthenosphere Q.
% Reminder low Q = high attenuation (Q^-1), so LAB Q will be > astheno Q.
%
% Parameters
% ----------
% Q_z: 1d array
%     Q as a function of z
% Z_km: 1d array
%     depth, same size as Q_z
% varargin: optional key-value arguments
%
%     'method', 'Q_factor' or 'Q_value'
%       if 'Q_factor' (the default), the LAB is identified as the point closest to
%       where Q_z equals a factor above the asthenosphere mean Q.
%       if 'Q_value', the LAB is identified as the point closes to the
%       supplied Q value.
%     'value', scalar
%       if 'method'=='Q_factor', this is the factor that multiplies the
%       asthenosphere Q to find the target LAB Q (default 20).
%       if 'method'=='Q_value', this is the target LAB Q to find.
%     'z_min_km', scalar
%       only used if 'method'=='Q_factor`, this value (default 80 km) defines the
%       depth above which Q values are averaged to find the mean asthenosphere Q
%
% Returns
% -------
% Z_LAB_Q: scalar
%     the seismic LAB depth from Q.
%
% Examples
% --------
% The following finds the depth at which Q is a factor of 20 higher than the
% mean asthenospheric Q. The mean asthenospheric Q will be calculated by
% averaging Q_z at depths greater than 150 km ('z_min', 150):
%
%    Z_LAB_Q = find_LAB_Q(Q_z,Z_km,'method','Q_factor','value',20,'z_min_km',150)
%
% To find the depth closest to an absolute value of Q:
%
%    Z_LAB_Q = find_LAB_Q(Q_z,Z_km,'method','Q_value',800)
%
% Notes
% -----
% Default behavior is to use
%
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
