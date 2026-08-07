function iou = calculateIoU(boxA, boxB)

% ========================================================================
% CALCULATEIOU
%
% Calculates Intersection over Union (IoU) between two bounding boxes.
%
% Input:
%
%   boxA = [x0 y0 x1 y1]
%   boxB = [x0 y0 x1 y1]
%
% Output:
%
%   iou = value between 0 and 1
%
% ========================================================================

%% Intersection rectangle

xA = max(boxA(1), boxB(1));
yA = max(boxA(2), boxB(2));

xB = min(boxA(3), boxB(3));
yB = min(boxA(4), boxB(4));

%% Intersection size

interWidth  = max(0, xB - xA);
interHeight = max(0, yB - yA);

interArea = interWidth * interHeight;

%% Area of each box

areaA = (boxA(3) - boxA(1)) * ...
        (boxA(4) - boxA(2));

areaB = (boxB(3) - boxB(1)) * ...
        (boxB(4) - boxB(2));

%% Union area

unionArea = areaA + areaB - interArea;

%% IoU

if unionArea <= 0

    iou = 0;

else

    iou = interArea / unionArea;

end

end