function videoName = extractVideoName(filename)

% ========================================================================
% EXTRACTVIDEONAME
%
% Finds a MELD video name anywhere inside a filename.
%
% Example:
%   res_dia23_utt6_20260801_060246_full.txt
%   -> dia23_utt6
%
% Example:
%   res_final_videos_testdia27_utt0_20260801_full.txt
%   -> dia27_utt0
%
% ========================================================================

[~,name,~] = fileparts(filename);

tokens = regexp( ...
    name, ...
    '(dia\d+_utt\d+)', ...
    'tokens', ...
    'once');

if isempty(tokens)

    error( ...
        'Could not find MELD video name in filename: %s', ...
        filename);

end

videoName = string(tokens{1});

end