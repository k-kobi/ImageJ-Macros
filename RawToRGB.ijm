// ====== Ask user for inputs ======

suffixBlue = getString("Enter suffix for BLUE channel (e.g., DAPI):", "DAPI");
suffixGreen = getString("Enter suffix for GREEN channel (e.g., GFP):", "GFP");
suffixRed = getString("Enter suffix for RED channel (e.g., Cy5):", "Cy5");

inputDir = getDirectory("Choose the Input Folder");
outputDir = getDirectory("Choose the Output Folder");

if (!endsWith(inputDir, File.separator))  inputDir += File.separator;
if (!endsWith(outputDir, File.separator)) outputDir += File.separator;

list = getFileList(inputDir);

// ====== Helper function ======
function arrayContains(arr, value, n) {
    for (i = 0; i < n; i++) {
        if (arr[i] == value) {
            return true;
        }
    }
    return false;
}

// ====== Find unique base names ======

baseNames = newArray();
n = 0;

for (i = 0; i < list.length; i++) {
    fileName = list[i];
    if (endsWith(toLowerCase(fileName), ".tif")) {
        wIndex = lastIndexOf(fileName, "_w");
        if (wIndex != -1) {
            base = substring(fileName, 0, wIndex);
            if (!arrayContains(baseNames, base, n)) {
                baseNames[n] = base;
                n = n + 1;
            }
        }
    }
}

// ====== Process each base name ======

for (i = 0; i < baseNames.length; i++) {
    base = baseNames[i];

    // Build filenames
    blueFile = "";
    greenFile = "";
    redFile = "";

    for (j = 0; j < list.length; j++) {
        fileName = list[j];
        if (startsWith(fileName, base)) {
            lowerName = toLowerCase(fileName);
            if (indexOf(lowerName, toLowerCase(suffixBlue)) != -1) {
                blueFile = fileName;
            }
            else if (indexOf(lowerName, toLowerCase(suffixGreen)) != -1) {
                greenFile = fileName;
            }
            else if (indexOf(lowerName, toLowerCase(suffixRed)) != -1) {
                redFile = fileName;
            }
        }
    }

    if (blueFile != "" && greenFile != "" && redFile != "") {
        print("Processing " + base);

        // --- Process Blue ---
        open(inputDir + blueFile);
        run("Z Project...", "projection=[Max Intensity]");
        blueProj = getTitle();
        rename("Blue");
        selectWindow(blueFile);
        close();

        // --- Process Green ---
        open(inputDir + greenFile);
        run("Z Project...", "projection=[Max Intensity]");
        greenProj = getTitle();
        rename("Green");
        selectWindow(greenFile);
        close();

        // --- Process Red ---
        open(inputDir + redFile);
        run("Z Project...", "projection=[Max Intensity]");
        redProj = getTitle();
        rename("Red");
        selectWindow(redFile);
        close();

        // --- Merge ---
        run("Merge Channels...", "c1=Red c2=Green c3=Blue create");
        mergedName = base + "_MERGED";
        rename(mergedName);

        // --- Save Merged Image ---
        saveAs("PNG", outputDir + mergedName + ".png");

        // --- Close everything safely ---
        close(); // merged image
        if (isOpen("Blue")) close("Blue");
        if (isOpen("Green")) close("Green");
        if (isOpen("Red")) close("Red");

    } else {
        print("Skipping " + base + ": missing one or more channel files.");
    }
}
