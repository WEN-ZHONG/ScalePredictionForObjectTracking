function config = config_list( test_seq )
%Test file configuration
    global resize;
%=======================SPM INTEGRATION=======================%
%Note: please change the test_source to the directory where you put our dataset in.
    test_source='../../dataset';
%=======================SPM INTEGRATION=======================%
    imgList=parseImg([test_source '/' test_seq '/img/']);
    load([test_source '/' test_seq '/theta.mat']);
    switch(test_seq)
        case 'David'
            imgList = imgList(300:end);
        case 'Tiger1'
            imgList = imgList(6:end);
        case 'Jump'
            resize=70;
        case 'Skater2'
            resize=70;
        case 'Girl2'
            resize=70;
        otherwise
            resize=100;
    end
    
    %gtPath = fullfile(test_source, test_seq, 'groundtruth_rect.txt');
    gtPath = fullfile(test_source, test_seq, 'groundtruth.txt');
    
%     txtName = [test_seq '_gt.txt'];
% 
%     gtPath = fullfile(test_source, test_seq, txtName);
    
    if(~exist(gtPath,'file'))
        error('%s does not exist!!',gtPath);
    end

    gt = importdata(gtPath);
    switch(test_seq)
        case 'Tiger1'
            gt = gt(6:end,:);
        case {'Board','Twinnings'}
            gt = gt(1:end-1,:);
    end
    
    nFrames = min(length(imgList), size(gt,1));
    
    config.imgList=imgList;
    config.gt=gt;
    config.nFrames=nFrames;
    config.name=test_seq;
    config.theta=theta;
end

