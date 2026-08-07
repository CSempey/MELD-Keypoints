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

Conference paper release.

Current statistics:

- Videos processed: 5,601
- Keypoint records: 283,093

Processing of the remaining MELD videos is ongoing.

## Repository Structure

```text
code/
docs/
tracking_tables/
