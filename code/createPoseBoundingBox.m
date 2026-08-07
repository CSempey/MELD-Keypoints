function bodyBox = createPoseBoundingBox(pose)

validRows = pose(:,3) > 0;

validPose = pose(validRows,:);

if isempty(validPose)

    bodyBox = [];

    return

end

bodyBox = [ ...
    min(validPose(:,1)) ...
    min(validPose(:,2)) ...
    max(validPose(:,1)) ...
    max(validPose(:,2)) ];

end