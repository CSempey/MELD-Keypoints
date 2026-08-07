function jsonData = loadOpenPoseFrame(jsonFile)

jsonText = fileread(jsonFile);

jsonData = jsondecode(jsonText);

end