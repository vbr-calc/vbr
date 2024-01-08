function VBR_save(VBR, fname, exclude_SVs)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save a VBR structure to disk.
    %
    % Parameters
    % ----------
    % VBR
    %     the VBR structure to save
    % fname
    %     the filename, will append .mat if not present
    % exclude_SVs
    %     set to 1 to exclue VBR.in.SV from save file. Useful for
    %     reducing disk-space when saving multiple results.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exist('exclude_SVs','var') && exclude_SVs == 1
        VBRout = struct();

        % copy input fields except for VBR.in.SV
        flds = fieldnames(VBR.in);
        for ifield = 1:numel(flds)
            if ~strcmp(flds{ifield}, 'SV')
                VBRout.in.(flds{ifield}) = VBR.in.(flds{ifield});
            end
        end

        % copy remaining
        flds = fieldnames(VBR);
        for ifield = 1:numel(flds)
            if ~strcmp(flds{ifield}, 'in')
                VBRout.(flds{ifield}) = VBR.(flds{ifield});
            end
        end
    else
        VBRout = VBR;
    end

    isOctave = is_octave();
    if isOctave
        save(fname, "-struct", "VBRout", "-mat-binary");
    else
        save(fname, "-struct", "VBRout");
    end
end