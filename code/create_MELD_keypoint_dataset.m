%% ========================================================================
% CREATE MELD KEYPOINT DATASET
%
% Combines:
%   MELD Ground Truth
%   Pyppbox Identity Tracking
%   OpenPose Keypoints
%
% Outputs:
%   meld_dataset.mat
%   tracking_table.csv
%
%% ========================================================================

clear;
clc;

runTimer = tic;

%% ------------------------------------------------------------------------
% LOGGING
%% ------------------------------------------------------------------------

logFolder = 'logs';

if ~exist(logFolder,'dir')
    mkdir(logFolder);
end

timestamp = datestr(now,'yyyymmdd_HHMMSS');

logfile = fullfile( ...
    logFolder,...
    sprintf('processing_log_%s.txt',timestamp));

diary(logfile);

%% ------------------------------------------------------------------------
% PATHS
%% ------------------------------------------------------------------------

meld_csv = ...
    "C:\Data\MELD_Processing\MELD_groundtruth\test_sent_emo.csv";

pyppbox_folder = ...
    "C:\Data\MELD_Processing\MELD_pyppbox_Output\test\test_batch1";

openpose_folder = ...
    "C:\Data\MELD_Processing\openpose_output\test_openpose_output";

output_folder = ...
    "C:\Data\MELD_Processing\MELD_CombinedDataset\test";

if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

%% ------------------------------------------------------------------------
% MAIN CHARACTERS
%% ------------------------------------------------------------------------

mainCharacters = { ...
    'Rachel'
    'Monica'
    'Phoebe'
    'Ross'
    'Joey'
    'Chandler'};

%% ------------------------------------------------------------------------
% LOAD MELD DATA
%% ------------------------------------------------------------------------

fprintf('Loading MELD metadata...\n');

meldTable = readtable(meld_csv);

meldTable.videoName = strcat( ...
    "dia", string(meldTable.Dialogue_ID), ...
    "_utt", string(meldTable.Utterance_ID));

%% ------------------------------------------------------------------------
% INITIALISE OUTPUTS
%% ------------------------------------------------------------------------

meld_dataset = struct([]);

trackingData = table();

datasetIndex = 1;

%% ------------------------------------------------------------------------
% FIND PYPPBOX FILES
%% ------------------------------------------------------------------------

pyppboxFiles = dir(fullfile(pyppbox_folder,'*.txt'));

fprintf('Found %d pyppbox files\n',length(pyppboxFiles));

%% ------------------------------------------------------------------------
% PROCESS FILES
%% ------------------------------------------------------------------------

for fileIdx = 1:length(pyppboxFiles)

    videoTimer = tic;

    tempFolder = "";

    try

        fprintf('\n');
        fprintf('=====================================\n');
        fprintf('Processing file %d of %d\n', ...
            fileIdx,length(pyppboxFiles));

        pyppboxFile = fullfile( ...
            pyppboxFiles(fileIdx).folder, ...
            pyppboxFiles(fileIdx).name);

        %% ------------------------------------------------------------
        % VIDEO NAME
        %% ------------------------------------------------------------

        videoName = extractVideoName( ...
            pyppboxFiles(fileIdx).name);

        fprintf('Video: %s\n',videoName);

        %% ------------------------------------------------------------
        % MELD ROW
        %% ------------------------------------------------------------

        rowMask = meldTable.videoName == videoName;

        if ~any(rowMask)

            fprintf('Video not found in MELD\n');

            trackingData = addTrackingRow( ...
                trackingData,...
                pyppboxFiles(fileIdx).name,...
                videoName,...
                "",...
                "",...
                0,...
                0,...
                0,...
                0,...
                0,...
                "No MELD Match");

            continue;

        end

        meldRow = meldTable(rowMask,:);

        speakerName = string(meldRow.Speaker(1));
        emotionLabel = string(meldRow.Emotion(1));

        %% ------------------------------------------------------------
        % LOAD PYPPBOX
        %% ------------------------------------------------------------

        pyppboxData = loadPyppboxFile(pyppboxFile);

        counts = countIdentities( ...
            pyppboxData,...
            speakerName);

        totalFramesVideo = ...
            numel(unique(pyppboxData.FrameNumber));

        %% ------------------------------------------------------------
        % SPEAKER CHECK
        %% ------------------------------------------------------------

        if ~ismember(char(speakerName),mainCharacters)

            fprintf('Speaker not trained: %s\n',speakerName);

            trackingData = addTrackingRow( ...
                trackingData,...
                pyppboxFiles(fileIdx).name,...
                videoName,...
                speakerName,...
                emotionLabel,...
                totalFramesVideo,...
                0,...
                0,...
                counts.UnknownCount,...
                counts.ErrorUTACount,...
                "Speaker Not Trained");

            continue;

        end



        %% ------------------------------------------------------------
        % SPEAKER ROWS
        %% ------------------------------------------------------------

        speakerRows = pyppboxData( ...
            pyppboxData.FaceIDLabel == speakerName,:);

        speakerFramesFound = height(speakerRows);

        %% ------------------------------------------------------------
        % SPEAKER NOT FOUND
        %% ------------------------------------------------------------

        if speakerFramesFound == 0

            fprintf('Speaker not found in pyppbox\n');

            trackingData = addTrackingRow( ...
                trackingData,...
                pyppboxFiles(fileIdx).name,...
                videoName,...
                speakerName,...
                emotionLabel,...
                totalFramesVideo,...
                0,...
                0,...
                counts.UnknownCount,...
                counts.ErrorUTACount,...
                "Speaker Not Found");

            continue;

        end

        %% ------------------------------------------------------------
        % OPENPOSE ZIP
        %% ------------------------------------------------------------

        zipFile = findOpenPoseZip( ...
            openpose_folder,...
            videoName);

        if strlength(zipFile) == 0

            trackingData = addTrackingRow( ...
                trackingData,...
                pyppboxFiles(fileIdx).name,...
                videoName,...
                speakerName,...
                emotionLabel,...
                totalFramesVideo,...
                speakerFramesFound,...
                0,...
                counts.UnknownCount,...
                counts.ErrorUTACount,...
                "OpenPose ZIP Missing");

            continue;

        end

        %% ------------------------------------------------------------
        % EXTRACT ZIP
        %% ------------------------------------------------------------

        tempFolder = extractOpenPoseZip( ...
            zipFile,...
            videoName);

        openposeFolder = findOpenPoseFolder( ...
            tempFolder,...
            videoName);

        if strlength(openposeFolder) == 0

            if exist(tempFolder,'dir')
                rmdir(tempFolder,'s');
            end

            trackingData = addTrackingRow( ...
                trackingData,...
                pyppboxFiles(fileIdx).name,...
                videoName,...
                speakerName,...
                emotionLabel,...
                totalFramesVideo,...
                speakerFramesFound,...
                0,...
                counts.UnknownCount,...
                counts.ErrorUTACount,...
                "OpenPose Folder Missing");

            continue;

        end

        %% ------------------------------------------------------------
        % PROCESS SPEAKER FRAMES
        %% ------------------------------------------------------------

        extractedFrames = 0;

        for row = 1:height(speakerRows)

            frameNumber = ...
                speakerRows.FrameNumber(row);

            bbox = ...
                speakerRows.BoundingBoxCoordinates(row,:);

            jsonFile = findOpenPoseJson( ...
                openposeFolder,...
                videoName,...
                frameNumber);

            if strlength(jsonFile) == 0
                continue;
            end

            jsonData = loadOpenPoseFrame(jsonFile);

            if isempty(jsonData.people)
                continue;
            end

            [bestPerson,matchScore,metrics] = ...
                matchOpenPosePerson( ...
                jsonData.people,...
                bbox);

            if isempty(bestPerson)
                continue;
            end

            extractedFrames = extractedFrames + 1;

            %% ----------------------------------------------------
            % KEYPOINTS
            %% ----------------------------------------------------

            pose = reshape( ...
                bestPerson.pose_keypoints_2d,...
                [3 25])';

            face = reshape( ...
                bestPerson.face_keypoints_2d,...
                [3 70])';

            leftHand = reshape( ...
                bestPerson.hand_left_keypoints_2d,...
                [3 21])';

            rightHand = reshape( ...
                bestPerson.hand_right_keypoints_2d,...
                [3 21])';

            %% ----------------------------------------------------
            % SAVE ENTRY
            %% ----------------------------------------------------

            meld_dataset(datasetIndex).videoName = videoName;
            meld_dataset(datasetIndex).sourceFile = ...
                pyppboxFiles(fileIdx).name;
            meld_dataset(datasetIndex).speaker = speakerName;
            meld_dataset(datasetIndex).emotion = emotionLabel;

            meld_dataset(datasetIndex).frameNumber = frameNumber;

            meld_dataset(datasetIndex).bbox = bbox;
            meld_dataset(datasetIndex).bodyBox = metrics.bodyBox;

            meld_dataset(datasetIndex).matchScore = matchScore;
            meld_dataset(datasetIndex).scoreGap = metrics.scoreGap;
            meld_dataset(datasetIndex).secondBestScore = ...
                metrics.secondBestScore;

            meld_dataset(datasetIndex).pose = pose;
            meld_dataset(datasetIndex).face = face;
            meld_dataset(datasetIndex).leftHand = leftHand;
            meld_dataset(datasetIndex).rightHand = rightHand;

            meld_dataset(datasetIndex).poseValidCount = ...
                metrics.poseValidCount;

            meld_dataset(datasetIndex).faceValidCount = ...
                metrics.faceValidCount;

            meld_dataset(datasetIndex).leftHandValidCount = ...
                metrics.leftHandValidCount;

            meld_dataset(datasetIndex).rightHandValidCount = ...
                metrics.rightHandValidCount;

            datasetIndex = datasetIndex + 1;

        end

        %% ------------------------------------------------------------
        % STATUS
        %% ------------------------------------------------------------

        if extractedFrames == 0
            status = "No OpenPose Matches";
        else
            status = "Processed";
        end

        %% ------------------------------------------------------------
        % TRACKING
        %% ------------------------------------------------------------

        trackingData = addTrackingRow( ...
            trackingData,...
            pyppboxFiles(fileIdx).name,...
            videoName,...
            speakerName,...
            emotionLabel,...
            totalFramesVideo,...
            speakerFramesFound,...
            extractedFrames,...
            counts.UnknownCount,...
            counts.ErrorUTACount,...
            status);

        %% ------------------------------------------------------------
        % CLEANUP
        %% ------------------------------------------------------------

        if exist(tempFolder,'dir')
            rmdir(tempFolder,'s');
        end

        catch ME

            fprintf('\nERROR PROCESSING FILE\n');
            fprintf('%s\n',pyppboxFiles(fileIdx).name);
            fprintf('%s\n',ME.message);
        
            if strlength(tempFolder) > 0 && ...
                    exist(tempFolder,'dir')
        
                rmdir(tempFolder,'s');
        
            end
        
        end

    videoTime = toc(videoTimer);
    
    elapsedTime = toc(runTimer);
    
    averageTimePerFile = ...
        elapsedTime / fileIdx;
    
    remainingFiles = ...
        length(pyppboxFiles) - fileIdx;
    
    estimatedRemaining = ...
        averageTimePerFile * remainingFiles;

    if mod(fileIdx,100) == 0
    
        try
    
            save( ...
                fullfile(output_folder,'test_meld_dataset.mat'), ...
                'meld_dataset', ...
                '-v7.3');
    
            writetable( ...
                trackingData,...
                fullfile(output_folder,'test_tracking_table.csv'));
    
            fprintf('Checkpoint saved.\n');
    
        catch ME
    
            fprintf('\nCHECKPOINT SAVE FAILED\n');
            fprintf('%s\n', ME.message);
    
        end
    
        fprintf('\n');
        fprintf('Processed %d of %d\n', ...
            fileIdx, ...
            length(pyppboxFiles));
    
        fprintf('Video Time: %.2f sec\n', ...
            videoTime);
    
        fprintf('Average Time/File: %.2f sec\n', ...
            averageTimePerFile);
    
        fprintf('Estimated Time Remaining: %.1f min\n', ...
            estimatedRemaining / 60);
    
        fprintf('-----------------------------------\n');
    
    end

end

%% ------------------------------------------------------------------------
% SAVE OUTPUTS
%% ------------------------------------------------------------------------

fprintf('\nSaving dataset...\n');

save( ...
    fullfile(output_folder,'test_meld_dataset.mat'), ...
    'meld_dataset', ...
    '-v7.3');

writetable( ...
    trackingData,...
    fullfile(output_folder,'test_tracking_table.csv'));

fprintf('\nFinished.\n');

%% ------------------------------------------------------------------------
% RUN SUMMARY
%% ------------------------------------------------------------------------

totalTime = toc(runTimer);

fprintf('\n');
fprintf('=====================================\n');
fprintf('RUN COMPLETE\n');
fprintf('Videos Processed: %d\n', height(trackingData));
fprintf('Dataset Entries: %d\n', numel(meld_dataset));
fprintf('Total Time: %.2f seconds\n', totalTime);
fprintf('Total Time: %.2f minutes\n', totalTime/60);
fprintf('Total Time: %.2f hours\n', totalTime/3600);
fprintf('=====================================\n');

diary off;