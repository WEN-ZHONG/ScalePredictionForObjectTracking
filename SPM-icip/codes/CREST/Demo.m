function info = Demo()

varargin=cell(1,2);

varargin(1,1)={'train'};
varargin(1,2)={struct('gpus', 1)};

run ../matconvnet/matlab/vl_setupnn ;
addpath ../matconvnet/examples ;

opts.expDir = 'exp/' ;
opts.dataDir = 'exp/data/' ;
opts.modelType = 'tracking' ;
opts.sourceModelPath = 'exp/models/' ;
[opts, varargin] = vl_argparse(opts, varargin) ;

% experiment setup
opts.imdbPath = fullfile(opts.expDir, 'imdb.mat') ;
opts.imdbStatsPath = fullfile(opts.expDir, 'imdbStats.mat') ;
opts.vocEdition = '11' ;
opts.vocAdditionalSegmentations = false ;

global resize;
display=1;

g=gpuDevice(1);
clear g;                             

%=======================SPM INTEGRATION=======================%
%Note: please change the datasetPath to the directory where you put our dataset in.
datasetPath = '../../dataset';
%=======================SPM INTEGRATION=======================%
files = dir(datasetPath);
files = files(3:end); 
% for i=1:size(files, 1) 

%% 22:carscale   35:diving      65: jump    73:MotorRolling  15: box 

for i= 1:size(files, 1)
    
    test_seq = files(i).name; 
    
    [config]=config_list(test_seq);
    
    t0 = cputime();
    
    result=CREST_tracking(opts,varargin,config,display, test_seq);  
    
    t1 = cputime()-t0;
    disp(t1);
    
    %txtName = ['CREST_SP_' test_seq '.txt'];
%     fid = fopen([txtSavePath, txtName], 'w');
%     for ii = 1:size(result, 1)
%         location = result(ii, :);
%         fprintf(fid, '%s\n', num2str(location));
%     end
%     
%     fclose(fid);
    %disp('saved txt results, done !');
    
end
    
    
    
    
    
%% ################ origianl demo files 
    
% test_seq='Skiing';
% [config]=config_list(test_seq);
% result=CREST_tracking(opts,varargin,config,display);        
       

