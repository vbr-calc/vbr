function [dcdt] = advection_driver(c,v,dz,dt,method)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [dcdt] = advection_driver(c,v,dz,dt,method)
  %
  % advection driver routine
  %
  % Parameters
  % ----------
  %   c   advected quantity, defined on cell center, array has ghost nodes
  %   v   staggered velocity field
  %   dz  mesh spacing (uniform!!)
  %   dt  time step (only used for conservative flux)
  %   method  string that sets which scheme to use. options:
  %           'VL'  for conservative van leer flux
  %           'CS'  for centerd space advection scheme (unstable without a
  %                 diffusion term!)
  %           'UW'  upwind advection (first order)
  %           'BM'  Beam-Warming (Second order upwind)
  % Output
  % ------
  %   dcdt advective flux of c
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if strcmp(method,'VL') % van leer conservative
      [dcdt]=advect_conservative(c,v,dz,dt)  ;
  elseif strcmp(method,'VL_nc') % van leer nonconservative
  %   v * grad(c) = div(cv) - c * div(v)
      [dcdt]=advect_conservative(c,v,dz,dt)  ;
      divV = (v(2:end) - v(1:end-1))/dz; % divergence
      dcdt(2:end-1)=dcdt(2:end-1) + c(2:end-1) .* divV; % add back divergence
  elseif strcmp(method,'CS') % centered space
      [dcdt] = centered_space(c,v,dz);
  elseif strcmp(method,'UW') % upwind
      [dcdt] = upwind(c,v,dz);
  elseif strcmp(method,'BW') % Beam-Warming
      [dcdt] = beamwarming(c,v,dz,dt);
  end

end


function [dcdt] = upwind(c,v,dz)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [dcdt] = upwind(c,v,dz)
  %
  % upwind advection calculation
  %
  % Parameters
  % ----------
  % c    advected quantity, defined on cell center, array has 2 ghosts
  % v    staggered velocity field
  % dz   the grid spacing
  %
  % Output
  % ------
  %   dcdt advective flux of c
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dcdt = zeros(size(c));
  n = numel(c);
   for in = 2:n-1
      if v(in)> 0
          dcdt(in) = v(in-1) * (c(in) - c(in-1))/dz;
      elseif v(in) < 0
          dcdt(in) = v(in) * (c(in+1) - c(in))/dz;
      end
   end
  dcdt(2:end-1) = - dcdt(2:end-1);
end

function [dcdt] = centered_space(c,v,dz)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [dcdt] = centered_space(c,v,dz)
  %
  % centered space advection  (unconditionally unstable for advection only)
  %
  % Parameters
  % ----------
  % c    advected quantity, defined on cell center, array has 2 ghosts
  % v    staggered velocity field
  % dz   the grid spacing
  %
  % Output
  % ------
  %   dcdt advective flux of c
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dcdt = zeros(size(c));
  Vc = (v(2:end)+v(1:end-1))/2;
  cs = (c(2:end)+c(1:end-1))/2;
  dcdz = (cs(2:end) - cs(1:end-1))/dz;
  dcdt(2:end-1) = - Vc.* dcdz;
end

function [dcdt] = beamwarming(c,v,dz,dt)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % [dcdt] = beamwarming(c,v,dz,dt)
  %
  % Beam-Warming (second order upwind)
  % Upwind Second-Order Difference Schemes and Applications in Aerodynamic
  % Flows, AIAA Journal, 1976.
  %
  % Nonsymmetric, adds back a numerical diffusion term.
  %
  % Parameters
  % ----------
  % c    advected quantity, defined on cell center, array has 2 ghosts
  % v    staggered velocity field (must be monotonic?)
  % dz   grid spacing
  % dt   time step
  %
  % Output
  % ------
  %   dcdt advective flux of c
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dcdt = zeros(size(c));

  n = numel(c);
   for in = 3:n-2
      if v(in)> 0
          artdiff = v(in-1)*v(in-1)*dt/2/dz/dz * (c(in) - 2*c(in-1) + c(in-2));
          dcdt(in) = -v(in-1)*(3*c(in)-4*c(in-1)+c(in-2))/2/dz + artdiff;
      elseif v(in) < 0
          artdiff = v(in)*v(in)*dt/2/dz/dz * (c(in) - 2*c(in+1) + c(in+2));
          dcdt(in) = v(in)*(3*c(in)-4*c(in+1)+c(in+2))/2/dz + artdiff;
      end
   end

% upwind on node 2 and n-1
   in = 2;
      if v(in)> 0
          dcdt(in) = -v(in-1) * (c(in) - c(in-1))/dz;
      elseif v(in) < 0
          dcdt(in) = -v(in) * (c(in+1) - c(in))/dz;
      end

   in = n-1;
      if v(in)> 0
          dcdt(in) = -v(in-1) * (c(in) - c(in-1))/dz;
      elseif v(in) < 0
          dcdt(in) = -v(in) * (c(in+1) - c(in))/dz;
      end

end

function [dcvldt]=advect_conservative(c,vs,dz,dt)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % [dphidt]=advect_conservative(c,vs,dz,dt)
  %
  % conservative advection using vanleer
  %
  % Parameters
  % ----------
  %  c     array of tracer (quantity being advected). c(1), c(n+2) are ghost
  %        cells.
  %  vs    velocities at edges. need to be n+1 elements (one less than c).
  %  dz    spacing between cells
  %  dt    time step
  %
  % Output
  % ------
  %  dcvldt the advective flux of the, to update to new values
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  dcvldt = [0 VanLeer1D(c',vs',dz,dt) 0];
  dcvldt(end-1) = dcvldt(end-2);
  dcvldt = dcvldt(1:end)';
end


function [dcvldt] = VanLeer1D(c,v,dz,dt)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % dcvldt = [0 VanLeer1D(c,v,dx,dt) 0]
  %
  % 1D van Leer advection
  %
  % Parameters
  % ----------
  %  c     array of tracer (quantity being advected). c(1), c(n+2) are ghost
  %        cells.
  %  v     velocities at edges. need to be n+1 elements (one less than c).
  %  dz    spacing between cells
  %  dt    time step
  %
  % Output
  % ------
  %  dcvldt the advective flux of the, to update to new values
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Internal slopes
  slopes = zeros(size(c));
  s_mask = ...
      find([0 ((c(2:end-1) > c(3:end) & c(2:end-1) <= c(1:end-2)) | ...
      (c(2:end-1) < c(3:end) & c(2:end-1) >= c(1:end-2))) 0] > 0);
  slopes(s_mask) = 2 .* ...
      (c(s_mask+1) - c(s_mask)) .* (c(s_mask) - c(s_mask-1)) ./ ...
      (c(s_mask+1) - c(s_mask-1));

  % Time-integrated fluxes
  fz_s = dt * v(1:end-1) / dz;
  fz_n = dt * v(2:end) / dz;

  % Van Leer face-centered values
  cvl_n = ...
      (fz_n > 0) .* (c(2:end-1) + 0.5 .* (1 - fz_n) .* slopes(2:end-1)) + ...
      (fz_n <= 0) .* (c(3:end) - 0.5 .* (1 + fz_n) .* slopes(3:end));
  cvl_s = ...
      (fz_s > 0) .* (c(1:end-2) + 0.5 .* (1 - fz_s) .* slopes(1:end-2)) + ...
      (fz_s <= 0) .* (c(2:end-1) - 0.5 .* (1 + fz_s) .* slopes(2:end-1));

  % Assemble Van Leer flux terms
  dcvldt = (cvl_s .* v(1:end-1) - cvl_n .* v(2:end)) / dz;

end
