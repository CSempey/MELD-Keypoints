# MELD-Keypoints

MELD-Keypoints is a speaker-specific multimodal keypoint enhancement of the MELD (Multimodal EmotionLines Dataset) corpus.

The dataset combines:

- MELD emotion annotations
- Pyppbox speaker identification
- OpenPose body keypoints
- OpenPose face keypoints
- OpenPose hand keypoints
- Speaker-to-skeleton matching metadata

while preserving the original MELD train, development and test partitions.

## Important - Relationship to MELD

MELD-Keypoints is a derived dataset based on MELD (Multimodal EmotionLines Dataset).

This repository does not contain or redistribute the original MELD video data.

Users must obtain MELD separately from the original dataset source and comply with the original MELD licence terms and usage requirements.

## Current Release

### v0.1

IMVIP 2026 Conference paper release.

Current statistics:

- Videos processed: 5,601/13,848
- Keypoint records: 283,093

Processing of the remaining MELD videos is ongoing.

## Dataset Downloads

### MELD-Keypoints v0.1

IMVIP 2026 Conference paper release.

Statistics:

- Videos processed: 5,601/13,848
- Keypoint records: 283,093

Dataset Downloads

Link to MELD-Keypoints v0.1 folder containing dev_meld_dataset.mat, test_meld_dataset.mat and train_meld_dataset.mat

https://ulster-my.sharepoint.com/:f:/r/personal/sempey-c1_ulster_ac_uk/Documents/Data/MELD-Keypoints-v0.1?d=wb3faed1de4a44e2389a9727d90ebaf68&csf=1&web=1&e=n7uvOo

NOTE: Temporary hosting on OneDrive, will be moved to Pure and links updated.

## Repository Structure

```text
code/
docs/
tracking_tables/
