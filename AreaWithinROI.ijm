// Ask user for threshold value or method
choice = getString("Enter threshold method or value:\n- Number (e.g., 10) for manual\n- 'RenyiEntropy' or 'Moments' for auto", "10");

// Prompt for folders
sourceDir = getDirectory("Choose a Folder with SB Images");
roiDir = getDirectory("Choose a Folder with ROI files");
destinationDir = getDirectory("Choose a Destination Folder");

if (!endsWith(sourceDir, File.separator)) sourceDir += File.separator;
if (!endsWith(roiDir, File.separator)) roiDir += File.separator;
if (!endsWith(destinationDir, File.separator)) destinationDir += File.separator;

list = getFileList(sourceDir);
roiList = getFileList(roiDir);
resultsPath = destinationDir + "Results.csv";

run("Clear Results");

for (i = 0; i < list.length; i++) {
    fileName = list[i];
    lowerName = toLowerCase(fileName);
    if (!(endsWith(lowerName, ".png") || endsWith(lowerName, ".tif"))) continue;

    open(sourceDir + fileName);
    baseName = substring(fileName, 0, lastIndexOf(fileName, "."));

    // Match ROI by longest matching prefix
    roiMatch = "";
    for (j = 0; j < roiList.length; j++) {
        roiFile = roiList[j];
        if (endsWith(toLowerCase(roiFile), ".roi")) {
            roiBase = substring(roiFile, 0, lastIndexOf(roiFile, "."));
            if (startsWith(baseName, roiBase)) {
                if (lengthOf(roiBase) > lengthOf(roiMatch)) {
                    roiMatch = roiBase;
                }
            }
        }
    }

    if (roiMatch == "") {
        close();
        continue;
    }

    // Load and apply ROI
    roiPath = roiDir + roiMatch + ".roi";
    if (isOpen("ROI Manager")) {
        roiManager("Reset");
    } else {
        run("ROI Manager...");
        roiManager("Reset");
    }
    roiManager("Open", roiPath);
    roiManager("Select", 0);

    // Apply threshold
    if (choice == "RenyiEntropy" || choice == "renyientropy") {
        setAutoThreshold("RenyiEntropy dark");
    } else if (choice == "Moments" || choice == "moments") {
        setAutoThreshold("Moments dark");
    } else {
        minVal = parseFloat(choice);
        if (isNaN(minVal)) {
            close();
            exit("Invalid threshold input.");
        }
        setThreshold(minVal, 255, "raw");
    }

    // Measure only thresholded signal within ROI
    run("Set Measurements...", "area mean min integrated limit display redirect=None decimal=3");
    roiManager("Select", 0);
    run("Measure");

    // Save image with threshold and ROI shown
    saveAs("PNG", destinationDir + baseName + "_THRESHOLDED.png");

    close();
    roiManager("Reset");
}

saveAs("Results", resultsPath);
if (isOpen("Results")) { selectWindow("Results"); run("Close"); }
if (isOpen("ROI Manager")) { selectWindow("ROI Manager"); run("Close"); }
