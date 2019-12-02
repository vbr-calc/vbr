function Fs = stag(F)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Fs = stag(F)
  %
  % staggers a quantity defined on uniform mesh
  %
  % Fs = (F(1:end-1)+F(2:end))/2;
  %
  % Parameters
  % ----------
  % F         the quantity to stagger
  %
  % Output
  % ------
  % Fs        the quantity on the staggered grid
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Fs = (F(1:end-1)+F(2:end))/2; % stagger by average
end
