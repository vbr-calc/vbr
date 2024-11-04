function Version = vbr_version()
    % return the current VBRc version
    Version.major = 1;
    Version.minor = 1;
    Version.patch = 2;
    Version.version = [num2str(Version.major), '.', ...
                       num2str(Version.minor), '.', ...
                       num2str(Version.patch)];
    Version.is_development = 1;
    if Version.is_development == 1
        Version.version = [Version.version, 'dev'];
    end
end
