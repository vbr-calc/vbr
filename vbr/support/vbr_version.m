function Version = vbr_version()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Version = vbr_version()
    %
    % return the VBRc Version structure
    %
    % Returns
    % -------
    % Version.  : structure with the following fields
    %        .major : int
    %           the major version number
    %        .minor : int
    %           the minor version number
    %        .patch : int
    %           the patch version number
    %        .version: string
    %            the version string (e.g., '2.0.1')
    %
    % Notes
    % -----
    % Version.version will include a 'dev' if you are
    % running a development version.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Version.major = 2;
    Version.minor = 1;
    Version.patch = 0;
    Version.version = [num2str(Version.major), '.', ...
                       num2str(Version.minor), '.', ...
                       num2str(Version.patch)];
    Version.is_development = 0;
    if Version.is_development == 1
        Version.version = [Version.version, 'dev'];
    end
end
