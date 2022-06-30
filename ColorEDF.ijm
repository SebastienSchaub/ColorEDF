macro "ColorEDF"{
	OrgID=getImageID();
	OrgTitle=getTitle();
	Stack.getDimensions(W, H, NCH, NS, NF);
	run("RGB Color", "frames keep slices keep");
	if ((NS==1) & (NF>1)){
		run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
		Stack.getDimensions(k, k, k, NS, NF);
	}
	run("8-bit");
	WBID=getImageID();
	rename("B&W");
	n=nImages();
	run("Easy mode...");
	while (n==nImages()){
		wait(100);
	}
	setBatchMode(true);
	
	roiManager("reset");
	selectImage("Height-Map");
	for (i=1;i<=NS;i++){
		setThreshold(i-0.5, i+0.5);
		run("Create Selection");
		if  (selectionType()>0){
			roiManager("Add");
			k=roiManager("count");
			roiManager("select", k-1);
			roiManager("rename", "Z="+i);
			roiManager("deselect")
		}
	}
	close("Output");
	close("B&W");
	close("Height-Map");
	
	selectImage(OrgID);
	run("Duplicate...", "title=ColoredEDF-Z duplicate");
	for (iz=1;iz<=NS;iz++){
		index=findRoiWithName("Z="+iz);
		for (ic=1;ic<=NCH;ic++){
			for (it=1;it<=NF;it++){
				Stack.setPosition(ic,iz,it);
				if (index>-1) {
					roiManager("select", index);
					run("Make Inverse");
				}
				else run("Select All");
				run("Clear","frame slice");
				print(index+": iz="+iz+": ic="+ic+" ; it="+it);
				wait(100);
			}
		}
		run("Select None");
	}
	run("Z Project...", "projection=[Sum Slices]");
	rename(OrgTitle+"-EDF");
	EDFID=getImageID();
	close("ColoredEDF-Z");
	for (ic=1;ic<=NCH;ic++){
		selectImage(OrgID);
		Stack.setPosition(ic,1,1);
		getMinAndMax(min, max);
		selectImage(EDFID);
		Stack.setPosition(ic,1,1);
		setMinAndMax(min, max);
	}
	setBatchMode("exit and display");
}

function findRoiWithName(roiName) { 
	nR = roiManager("Count"); 
 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName)) { 
			return i; 
		} 
	} 
	return -1; 
} 