
% This demo script runs the ECO tracker with deep features on the
% included "Crossing" video.

% Add paths
setup_paths();

% Load video information
% MotorRolling  CarScale  Matrix  Girl2  Biker
%=======================SPM INTEGRATION=======================%
%Note: please change the video_path to the directory where you put our dataset in.
video_path = '../../dataset';
%=======================SPM INTEGRATION=======================%
 
files = dir(video_path);
files = files(3:end); 

for i= 1:size(files, 1)
    
%     videoName = files{i, 1}; 
    
    videoName = files(i).name; 
    
    [seq, ground_truth] = load_video_info(video_path, videoName);
    
    % Run ECO
    results = testing_ECO(seq);
    result = results.res; 
    
%     txtName = ['ECO_SP_' videoName '.txt'];
%     fid = fopen(txtName, 'w');
%     for ii = 1:size(result, 1)
%         location = result(ii, :);
%         fprintf(fid, '%s\n', num2str(location));
%     end
%     
%     fclose(fid);
%     disp('saved txt results, done !');
    
end


