// === Choose folders ===
sourceDir = getDirectory("Choose a Source Folder");
list = getFileList(sourceDir);
destinationDir = getDirectory("Choose a Destination Folder");

// Ensure paths end with correct separator
if (!endsWith(sourceDir, File.separator))  sourceDir += File.separator;
if (!endsWith(destinationDir, File.separator)) destinationDir += File.separator;

// Start CSV contents
csvHeader = "Filename,Area\n";
csvContents = csvHeader;

// === Start processing ===
for (i = 0; i < list.length; i++) {
    path = sourceDir + list[i];
    
    if (endsWith(toLowerCase(list[i]), ".png") || endsWith(toLowerCase(list[i]), ".tif")) {
        open(path);
        fileName = getTitle();
        selectWindow(fileName);

        // Convert to 8-bit
        run("8-bit");

        // Threshold and create mask
        setThreshold(1, 255);
        run("Convert to Mask");
        run("Create Selection");

        // Initialize ROI Manager
        if (isOpen("ROI Manager")) {
            roiManager("Reset");
        } else {
            run("ROI Manager...");
            roiManager("Reset");
        }

        // Add selection
        roiManager("Add");

        // Save the ROI
        fileNameNoExt = substring(fileName, 0, lastIndexOf(fileName, "."));
        roiSavePath = destinationDir + fileNameNoExt + ".roi";
        roiManager("Save", roiSavePath);

        // === Measure Area Only ===
        run("Set Measurements...", "area redirect=None decimal=3");
        roiManager("Select", 0);
        roiManager("Measure");

        // Get Area from last measurement
        area = getResult("Area", nResults()-1);

        // Add to csvContents string
        csvContents += fileNameNoExt + "," + area + "\n";

        // Cleanup
        close();
        roiManager("Reset");
        run("Clear Results"); // Important: clear after each image
    }
}

// === Save CSV ===
resultsPath = destinationDir + "ROI_Measurements.csv";
File.saveString(csvContents, resultsPath);
