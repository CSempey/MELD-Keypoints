function zipFile = findOpenPoseZip(openposeRootFolder, videoName)

% ========================================================================
% FINDOPENPOSEZIP
%
% Finds:
%   dia23_utt6.mp4.openpose.zip
%
% ========================================================================

zipName = sprintf('%s.mp4.openpose.zip', videoName);

result = dir(fullfile(openposeRootFolder, zipName));

if isempty(result)

    zipFile = "";

else

    zipFile = fullfile(result(1).folder, result(1).name);

end

end