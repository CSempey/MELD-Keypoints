function tempFolder = extractOpenPoseZip(zipFile, videoName)

% ========================================================================
% EXTRACTOPENPOSEZIP
%
% Extracts a video's OpenPose ZIP into a temporary folder.
%
% ========================================================================

tempFolder = fullfile(tempdir, char(videoName));

if exist(tempFolder, 'dir')
    rmdir(tempFolder, 's');
end

mkdir(tempFolder);

unzip(zipFile, tempFolder);

end