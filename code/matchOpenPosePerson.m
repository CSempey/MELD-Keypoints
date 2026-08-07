function [bestPerson, bestScore, metrics] = ...
    matchOpenPosePerson(people, pyppboxBox)

% ========================================================================
% MATCHOPENPOSEPERSON
%
% Finds the OpenPose person that best matches the supplied pyppbox
% bounding box.
%
% Input:
%
%   people
%       jsonData.people
%
%   pyppboxBox
%       [x0 y0 x1 y1]
%
% Output:
%
%   bestPerson
%
%   bestScore
%
%   metrics
%
% ========================================================================

%% Debug output

debugMode = false;

%% Initialise

bestPerson = [];
bestScore = -inf;
metrics = struct();

%% Buffer around pyppbox bbox

buffer = 10;

bbox = pyppboxBox;

bbox(1) = bbox(1) - buffer;
bbox(2) = bbox(2) - buffer;
bbox(3) = bbox(3) + buffer;
bbox(4) = bbox(4) + buffer;

%% Check number of people that OpenPose detected

if debugMode

    fprintf('\nNumber of OpenPose people: %d\n', ...
        length(people));

end

%% Store scores for debugging

allScores = zeros(1,length(people));

%% Loop through OpenPose people

for p = 1:length(people)

    %% Pose keypoints

    pose = reshape( ...
        people(p).pose_keypoints_2d, ...
        [3 25])';

    %% Keep only valid pose keypoints

    validIdx = pose(:,3) > 0;

    validPose = pose(validIdx,:);

    if isempty(validPose)
        continue
    end

    %% OpenPose body bounding box

    bodyBox = [ ...
        min(validPose(:,1)), ...
        min(validPose(:,2)), ...
        max(validPose(:,1)), ...
        max(validPose(:,2))];

    %% IoU score

    iouScore = calculateIoU( ...
        bbox, ...
        bodyBox);

    %% Percentage of points inside bbox

    inside = ...
        validPose(:,1) >= bbox(1) & ...
        validPose(:,1) <= bbox(3) & ...
        validPose(:,2) >= bbox(2) & ...
        validPose(:,2) <= bbox(4);

    insideRatio = mean(inside);

    %% Combined score

    score = (0.5 * iouScore) + ...
            (0.5 * insideRatio);

    allScores(p) = score;

    if debugMode

        fprintf('\nPerson %d\n',p);
        fprintf('IoU = %.3f\n',iouScore);
        fprintf('Inside Ratio = %.3f\n',insideRatio);
        fprintf('Overall Score = %.3f\n',score);

    end


    %% Keep best match

    if score > bestScore

        bestScore = score;

        bestPerson = people(p);

        %% Metrics

        metrics.poseValidCount = ...
            sum(validIdx);

        metrics.bodyBox = bodyBox;

        metrics.iouScore = iouScore;

        metrics.insideRatio = insideRatio;

        metrics.openPosePersonIndex = p;

        %% Face

        face = reshape( ...
            people(p).face_keypoints_2d,...
            [3 70])';

        metrics.faceValidCount = ...
            sum(face(:,3) > 0);

        %% Left Hand

        leftHand = reshape( ...
            people(p).hand_left_keypoints_2d,...
            [3 21])';

        metrics.leftHandValidCount = ...
            sum(leftHand(:,3) > 0);

        %% Right Hand

        rightHand = reshape( ...
            people(p).hand_right_keypoints_2d,...
            [3 21])';

        metrics.rightHandValidCount = ...
            sum(rightHand(:,3) > 0);

        %% Store additional diagnostics

        metrics.iouScore = iouScore;
        metrics.insideRatio = insideRatio;

    end

end

%% Guard against the case where all OpenPose Detections are invalid

if isempty(bestPerson)

    metrics.poseValidCount = 0;
    metrics.faceValidCount = 0;
    metrics.leftHandValidCount = 0;
    metrics.rightHandValidCount = 0;

    metrics.secondBestScore = 0;
    metrics.scoreGap = 0;

    return

end

if debugMode

    fprintf('\nAll Scores:\n');
    disp(allScores);

end

%% Calculate score gap

sortedScores = sort(allScores,'descend');

if length(sortedScores) >= 2

    secondBestScore = sortedScores(2);

else

    secondBestScore = 0;

end

metrics.secondBestScore = secondBestScore;
metrics.scoreGap = bestScore - secondBestScore;

if debugMode

    fprintf('\nSecond Best Score = %.3f\n', ...
        metrics.secondBestScore);
    
    fprintf('Score Gap = %.3f\n', ...
        metrics.scoreGap);

end

end