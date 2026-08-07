function counts = countIdentities(pyppboxData,speakerName)

% ========================================================================
% COUNTIDENTITIES
%
% Counts speaker, Unknown and ERROR_UTA detections.
%
% ========================================================================

labels = pyppboxData.FaceIDLabel;

counts.SpeakerCount = sum(labels == speakerName);

counts.UnknownCount = sum(labels == "Unknown");

counts.ErrorUTACount = sum(labels == "ERROR_UTA");

end