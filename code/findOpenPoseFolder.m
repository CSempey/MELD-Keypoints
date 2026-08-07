function openposeFolder = findOpenPoseFolder(tempFolder, videoName)

% ========================================================================
% FINDOPENPOSEFOLDER
%
% Finds:
%   dia23_utt6.mp4.openpose
%
% within the extracted ZIP contents.
%
% ========================================================================

folderName = sprintf('%s.mp4.openpose', videoName);

result = dir(fullfile(tempFolder, '**', folderName));

if isempty(result)

    openposeFolder = "";

else

    openposeFolder = fullfile( ...
        result(1).folder, ...
        result(1).name);

end

end