%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Implemetation of the tracker described in paper
%	"MEEM: Robust Tracking via Multiple Experts using Entropy Minimization", 
%   Jianming Zhang, Shugao Ma, Stan Sclaroff, ECCV, 2014
%	
%	Copyright (C) 2014 Jianming Zhang
%
%	This program is free software: you can redistribute it and/or modify
%	it under the terms of the GNU General Public License as published by
%	the Free Software Foundation, either version 3 of the License, or
%	(at your option) any later version.
%
%	This program is distributed in the hope that it will be useful,
%	but WITHOUT ANY WARRANTY; without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	GNU General Public License for more details.
%
%	You should have received a copy of the GNU General Public License
%	along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%	If you have problems about this software, please contact: jmzhang@bu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0=cputime;
%=======================SPM INTEGRATION=======================%
%please change the img_path to the directory where our dataset is stored.
img_path = '../../dataset/';
%=======================SPM INTEGRATION=======================%
seq_names = {'1_car5','1_nonm7','1_nonm12','2_car3','2_people9','5_nonm1','5_people2','6_people2','6_people4','6_people8','7_nonm2','7_nonm3','7_people6','8_people2','8_people4','seq1','seq2','seq3'};
totalFrames = [250,206,210,200,806,480,768,334,485,1562,242,265,598,690,985,170,145,141];
for seq = 1%:numel(seq_names)
    data_path = [img_path,seq_names{seq}];
    load([data_path,'/theta.mat']);
    load([data_path,'/init_rect.txt']);
    res = MEEMTrack([data_path,'/img'],'jpg',true,init_rect,1,totalFrames(seq),theta);
    t1=cputime-t0;
    f = fopen(['MEEM_SP_',seq_names{seq},'.txt'],'w');
    for i = 1:length(res.res)
        pos = res.res(i,:);
        fprintf(f, [num2str(pos(1)),',', num2str(pos(2)),',' ,num2str(pos(3)),',',num2str(pos(4)),'\n']);
    end
    fclose(f);
end