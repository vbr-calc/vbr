function rgb = vbr_categorical_color(iclr)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  rgb = vbr_categorical_color(iclr)
    %
    %  return a single rgb value from the vbr_categorical_cmap_array.
    %
    % Parameters
    % ----------
    % iclr
    %     the index to sample from the colormap. Will be wrapped to be within
    %     the bounds of the colormap.
    %
    % Output
    % ------
    % rgb
    %     3-element array of floating point rgb values in (0,1) range
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rgbs = vbr_categorical_cmap_array();
    ncolors = size(rgbs);
    ncolors = ncolors(1);
    iclr = ncolors - mod(iclr, ncolors);
    rgb = rgbs(iclr, :);
end