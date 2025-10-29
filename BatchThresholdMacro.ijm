// Ask user for threshold value or method
choice = getString("Enter threshold method or value:\n- Number (e.g., 10) for manual\n- 'RenyiEntropy' or 'Moments' for auto", "10");

// Prompt for folders
sourceDir = getDirectory("Choose a Source Folder");
list = getFileList(sourceDir);
destinationDir = getDirectory("Choose a Destination Folder");

if (!endsWith(sourceDir, File.separator))  sourceDir += File.separator;
if (!endsWith(destinationDir, File.separator)) destinationDir += File.separator;

resultsPath = destinationDir + "Results.csv";

// Loop over image files
for (i = 0; i < list.length; i++) {
    path = sourceDir + list[i];
    lowerName = toLowerCase(list[i]);

    if (endsWith(lowerName, ".png") || endsWith(lowerName, ".tif") || endsWith(lowerName, ".tiff")) {
        open(path);
        fileName = getTitle();
        selectWindow(fileName);

        // Apply chosen threshold method
        thresholdLabel = "";

        if (choice == "RenyiEntropy" || choice == "renyientropy") {
            setAutoThreshold("RenyiEntropy dark");
            thresholdLabel = "_RenyiEntropy";
        } else if (choice == "Moments" || choice == "moments") {
            setAutoThreshold("Moments dark");
            thresholdLabel = "_Moments";
        } else {
            minVal = parseFloat(choice);
            if (isNaN(minVal)) {
                showMessage("Invalid input. Please enter a number or a valid method.");
                exit();
            }
            setThreshold(minVal, 255, "raw");
            thresholdLabel = "_THRESHOLD" + minVal;
        }

        run("Measure");

        fileNameNoExt = substring(fileName, 0, lastIndexOf(fileName, "."));
        newFileName = destinationDir + fileNameNoExt + thresholdLabel + ".jpg";

        saveAs("Jpeg", newFileName);
        close();
    }
}

saveAs("Results", resultsPath);
