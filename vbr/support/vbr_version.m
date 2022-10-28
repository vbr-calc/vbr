function Version = vbr_version()
    % return the current VBRc version
    Version.major = 0;
    Version.minor = 99;
    Version.patch = 5;
    Version.version = [num2str(Version.major), '.', ...
                       num2str(Version.minor), '.', ...
                       num2str(Version.patch)];
end
