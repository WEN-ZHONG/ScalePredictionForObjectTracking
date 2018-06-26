Following these steps to run the BIT-SP tracker on our dataset:
1.Download the BIT code from https://github.com/caibolun/BIT 
2.Replace run_tracker.m, tracker.m in the BIT-master directory with the ones in this directory.
3.Replate get_ROI.m in iles in the /BIT directory with get_ROI.m in this directory.
4.Copy the scale_estimation.m to the /BIT directory. 
5.In the run_tracker.m, change the base_path (Line 9) to the directory where our dataset stored.
6.run run_tracker.m