# ImageJ Macros

A collection of ImageJ/Fiji macros for batch fluorescence microscopy image processing, developed for undergraduate lab use.

## Macros

### `RawToRGB.ijm` — Merge channels into composite RGB
Takes separate single-channel `.tif` files (e.g. from a widefield or confocal acquisition) and merges them into a composite RGB PNG.

**Expects:** Files named with a `_w` separator, e.g. `Image01_w1DAPI.tif`, `Image01_w2GFP.tif`, `Image01_w3Cy5.tif`

**Prompts:**
1. Suffix for blue channel (default: `DAPI`)
2. Suffix for green channel (default: `GFP`)
3. Suffix for red channel (default: `Cy5`)
4. Input folder
5. Output folder

**Output:** `<base>_MERGED.png` for each image set, using Max Intensity Z-projection per channel before merging.

---

### `TraceToROI.ijm` — Convert traced images to ROI files
Converts binary/traced PNG or TIF images into ImageJ `.roi` files, and records the area of each ROI.

**Use this when you have hand-traced or segmented images and need to generate ROI files for use with `AreaWithinROI.ijm`.**

**Prompts:**
1. Source folder (containing `.png` or `.tif` images)
2. Destination folder

**Output:**
- `<filename>.roi` for each image
- `ROI_Measurements.csv` with filename and area for each ROI

---

### `AreaWithinROI.ijm` — Measure thresholded signal within ROIs
Batch-measures the thresholded signal intensity within pre-existing ROI files. Pairs each image with its matching `.roi` file by longest prefix match.

**Use this after generating ROI files with `TraceToROI.ijm`, or with manually drawn ROIs.**

**Prompts:**
1. Threshold method or value:
   - A number (e.g. `10`) for manual threshold
   - `RenyiEntropy` or `Moments` for auto-threshold
2. Source folder (`.png` or `.tif` images)
3. ROI folder (`.roi` files)
4. Destination folder

**Output:**
- `<filename>_THRESHOLDED.png` — image with threshold and ROI overlay
- `Results.csv` — area, mean, min, and integrated density measurements

---

### `BatchThresholdMacro.ijm` — Simple batch threshold and measure
Applies a threshold to every image in a folder, runs measurements, and saves output. No ROI files needed.

**Prompts:**
1. Threshold method or value (`RenyiEntropy`, `Moments`, or a number)
2. Source folder
3. Destination folder

**Output:**
- `<filename>_<threshold>.jpg` for each image (e.g. `_RenyiEntropy`, `_THRESHOLD10`)
- `Results.csv`

---

## Typical Workflow

```
Raw channel TIFs
      │
      ▼
 RawToRGB.ijm  ──► Merged RGB PNGs (for visual inspection)
      │
      ▼
 (Manual tracing / segmentation)
      │
      ▼
 TraceToROI.ijm  ──► .roi files + area CSV
      │
      ▼
 AreaWithinROI.ijm  ──► Thresholded measurements within ROIs
```

Or, for quick measurements without ROIs:

```
Images  ──►  BatchThresholdMacro.ijm  ──►  Results CSV
```

---

## Requirements

- [Fiji](https://fiji.sc/) (recommended) or [ImageJ](https://imagej.net/) 1.53+
- No additional plugins required

## Installation

1. Open Fiji/ImageJ
2. Go to **Plugins > Macros > Run...** and select the `.ijm` file, **or**
3. Drag and drop a `.ijm` file onto the Fiji toolbar to open it in the Script Editor, then click **Run**

To add a macro to the Plugins menu permanently:
- Copy the `.ijm` file to the `Fiji.app/macros/` directory
- Restart Fiji
