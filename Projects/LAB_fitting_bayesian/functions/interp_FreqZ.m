function [ D_interp, freq_interp, Z_interp ] = interp_FreqZ( D,freq,fnn_pts,Z,Znn_pts )
% Interpolate Vs and Q across depth and frequency
%
% === INPUT ===
% D:        input that will be interpolated (Vs or Q)
% freq:     original frequency vector
% fnn_pts:  number of points to interpolate to on frequency axis
% Z:        original depth vector
% Znn_pts:  number of points to interpolate to on depth axis
%
% === OUTPUT ===
% D_interp:    final interpolated values in frequency and depth
% freq_interp: interpolated frequency vector
% Z_interp:    interpolated depth vector
%

% Build interplated vectors
freq_interp = linspace(freq(1),freq(end),fnn_pts);
Z_interp = linspace(Z(1),Z(end),Znn_pts);

% Mesh grid for original vectors
[freq_mesh, Z_mesh] = meshgrid(freq,Z);

% Mesh grid for interpolated vectors
[freqint_mesh, Zint_mesh] = meshgrid(freq_interp,Z_interp);

% 2D interpolation over freqency and depth mesh
D_interp = interp2(freq_mesh,Z_mesh,D,freqint_mesh,Zint_mesh);

end

