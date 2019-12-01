function [defaults] = polly_first_read_defaults()
%pollyxt_ift_read_defaults read default settings for pollyxt_ift
%   Example:
%       [defaults] = pollyxt_ift_read_defaults(file)
%   Inputs:
%       file: char
%   Outputs:
%       defaults:
%           default settings for polly lidar system. More detailed information can be found in doc/polly_defaults.md
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

defaultFile = 'polly_first_defaults.json';

if exist(defaultFile, 'file') ~= 2
    error('Default file for polly_first does not exist!\n%s\n', defaultFile);
end

defaults = loadjson(defaultFile);

end