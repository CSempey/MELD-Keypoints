function jsonFile = findOpenPoseJson( ...
    openposeFolder, ...
    videoName, ...
    frameNumber)

% ========================================================================
% FINDOPENPOSEJSON
%
% Returns path to a frame JSON file.
%
% ========================================================================

jsonName = sprintf( ...
    '%s_%012d_keypoints.json', ...
    videoName, ...
    frameNumber);

jsonFile = fullfile(openposeFolder, jsonName);

if ~isfile(jsonFile)

    jsonFile = "";

end

end