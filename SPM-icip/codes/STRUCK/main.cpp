/* 
 * Struck: Structured Output Tracking with Kernels
 * 
 * Code to accompany the paper:
 *   Struck: Structured Output Tracking with Kernels
 *   Sam Hare, Amir Saffari, Philip H. S. Torr
 *   International Conference on Computer Vision (ICCV), 2011
 * 
 * Copyright (C) 2011 Sam Hare, Oxford Brookes University, Oxford, UK
 * 
 * This file is part of Struck.
 * 
 * Struck is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Struck is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Struck.  If not, see <http://www.gnu.org/licenses/>.
 * 
 */
 
#include "Tracker.h"
#include "Config.h"

#include <iostream>
#include <fstream>

#include <opencv/cv.h>
#include <opencv/highgui.h>

using namespace std;
using namespace cv;

static const int kLiveBoxWidth = 80;
static const int kLiveBoxHeight = 80;

void rectangle(Mat& rMat, const FloatRect& rRect, const Scalar& rColour)
{
	IntRect r(rRect);
	rectangle(rMat, Point(r.XMin(), r.YMin()), Point(r.XMax(), r.YMax()), rColour);
}

int main(int argc, char* argv[])
{
	// read config file
	string configPath = "config.txt";
	if (argc > 1)
	{
		configPath = argv[1];
	}
	Config conf(configPath);
	cout << conf << endl;
	
	if (conf.features.size() == 0)
	{
		cout << "error: no features specified in config" << endl;
		return EXIT_FAILURE;
	}
	
	ofstream outFile;
	if (conf.resultsPath != "")
	{
		outFile.open(conf.resultsPath.c_str(), ios::out);
		if (!outFile)
		{
			cout << "error: could not open results file: " << conf.resultsPath << endl;
			return EXIT_FAILURE;
		}
	}
	
	// if no sequence specified then use the camera
	bool useCamera = (conf.sequenceName == "");
	
	VideoCapture cap;
	
	int startFrame = -1;
	int endFrame = -1;
	FloatRect initBB;
	string imgFormat;
	float scaleW = 1.f;
	float scaleH = 1.f;
	
	if (useCamera)
	{
		if (!cap.open(0))
		{
			cout << "error: could not start camera capture" << endl;
			return EXIT_FAILURE;
		}
		startFrame = 0;
		endFrame = INT_MAX;
		Mat tmp;
		cap >> tmp;
		scaleW = (float)conf.frameWidth/tmp.cols;
		scaleH = (float)conf.frameHeight/tmp.rows;

		initBB = IntRect(conf.frameWidth/2-kLiveBoxWidth/2, conf.frameHeight/2-kLiveBoxHeight/2, kLiveBoxWidth, kLiveBoxHeight);
		cout << "press 'i' to initialise tracker" << endl;
	}
	else
	{
		// parse frames file
		string framesFilePath = conf.sequenceBasePath+"/"+conf.sequenceName+"/"+conf.sequenceName+"_frames.txt";
		ifstream framesFile(framesFilePath.c_str(), ios::in);
		if (!framesFile)
		{
			cout << "error: could not open sequence frames file: " << framesFilePath << endl;
			return EXIT_FAILURE;
		}
		string framesLine;
		getline(framesFile, framesLine);
		sscanf(framesLine.c_str(), "%d,%d", &startFrame, &endFrame);
		if (framesFile.fail() || startFrame == -1 || endFrame == -1)
		{
			cout << "error: could not parse sequence frames file" << endl;
			return EXIT_FAILURE;
		}
		
		// imgFormat = conf.sequenceBasePath+"/"+conf.sequenceName+"/imgs/img%04d.png";
		imgFormat = conf.sequenceBasePath+"/"+conf.sequenceName+"/img/%04d.jpg";
		
		// read first frame to get size
		char imgPath[256];
		sprintf(imgPath, imgFormat.c_str(), startFrame);
		Mat tmp = cv::imread(imgPath, 0);
		scaleW = (float)conf.frameWidth/tmp.cols;
		scaleH = (float)conf.frameHeight/tmp.rows;
		
		// read init box from ground truth file
		string gtFilePath = conf.sequenceBasePath+"/"+conf.sequenceName+"/"+conf.sequenceName+"_gt.txt";
		ifstream gtFile(gtFilePath.c_str(), ios::in);
		if (!gtFile)
		{
			cout << "error: could not open sequence gt file: " << gtFilePath << endl;
			return EXIT_FAILURE;
		}
		string gtLine;
		getline(gtFile, gtLine);
		float xmin = -1.f;
		float ymin = -1.f;
		float width = -1.f;
		float height = -1.f;
		sscanf(gtLine.c_str(), "%f,%f,%f,%f", &xmin, &ymin, &width, &height);
		if (gtFile.fail() || xmin < 0.f || ymin < 0.f || width < 0.f || height < 0.f)
		{
			cout << "error: could not parse sequence gt file" << endl;
			return EXIT_FAILURE;
		}
		initBB = FloatRect(xmin*scaleW, ymin*scaleH, width*scaleW, height*scaleH);
	}
	
	
	
	Tracker tracker(conf);
	/*if (!conf.quietMode)
	{
		namedWindow("result");
	}
	
	Mat result(conf.frameHeight, conf.frameWidth, CV_8UC3);*/
	bool paused = false;
	bool doInitialise = false;
	srand(conf.seed);
	
	//-----------------------------------------------------------------------
	// =======================SPM INTEGRATION=======================
	//read theta
	string thetaFilePath = conf.sequenceBasePath+"/"+conf.sequenceName+"/theta.txt";
	ifstream thetaFile(thetaFilePath.c_str(), ios::in);
	if (!thetaFile)
	{
		cout << "error: could not open sequence theta file: " << thetaFilePath << endl;
		return EXIT_FAILURE;
	}
	string thetaLine;
	getline(thetaFile, thetaLine);
	float theta1 = -1.f;
	float theta2 = -1.f;
	float theta3 = -1.f;
	sscanf(thetaLine.c_str(), "%f %f %f", &theta1, &theta2, &theta3);
	
	if (thetaFile.fail())
	{
		cout << "error: could not parse sequence theta file" << endl;
		return EXIT_FAILURE;
	}
    // =======================SPM INTEGRATION=======================
    
	/*
	for (int frameInd = startFrame; frameInd <= endFrame; ++frameInd)
	{
		Mat frame;
		if (useCamera)
		{
			Mat frameOrig;
			cap >> frameOrig;
			resize(frameOrig, frame, Size(conf.frameWidth, conf.frameHeight));
			flip(frame, frame, 1);
			frame.copyTo(result);
			if (doInitialise)
			{
				if (tracker.IsInitialised())
				{
					tracker.Reset();
				}
				else
				{
					tracker.Initialise(frame, initBB);
				}
				doInitialise = false;
			}
			else if (!tracker.IsInitialised())
			{
				rectangle(result, initBB, CV_RGB(255, 255, 255));
			}
		}
		else
		{			
			char imgPath[256];
			sprintf(imgPath, imgFormat.c_str(), frameInd);
			Mat frameOrig = cv::imread(imgPath, 0);
			if (frameOrig.empty())
			{
				cout << "error: could not read frame: " << imgPath << endl;
				return EXIT_FAILURE;
			}
			resize(frameOrig, frame, Size(conf.frameWidth, conf.frameHeight));
			cvtColor(frame, result, CV_GRAY2RGB);
		
			if (frameInd == startFrame)
			{
				tracker.Initialise(frame, initBB);
			}
		}
		
		if (tracker.IsInitialised())
		{
			tracker.Track(frame);
			
			if (!conf.quietMode && conf.debugMode)
			{
				tracker.Debug();
			}
			
			rectangle(result, tracker.GetBB(), CV_RGB(0, 255, 0));
			
			if (outFile)
			{
				const FloatRect& bb = tracker.GetBB();
				outFile << bb.XMin()/scaleW << "," << bb.YMin()/scaleH << "," << bb.Width()/scaleW << "," << bb.Height()/scaleH << endl;
			}
		}
		
		if (!conf.quietMode)
		{
			imshow("result", result);
			int key = waitKey(paused ? 0 : 1);
			if (key != -1)
			{
				if (key == 27 || key == 113) // esc q
				{
					break;
				}
				else if (key == 112) // p
				{
					paused = !paused;
				}
				else if (key == 105 && useCamera)
				{
					doInitialise = true;
				}
			}
			if (conf.debugMode && frameInd == endFrame)
			{
				cout << "\n\nend of sequence, press any key to exit" << endl;
				waitKey();
			}
		}
	}
	*/
    // =======================SPM INTEGRATION=======================
	float x0 = initBB.XMin() + 0.5*initBB.Width();
	float y0 = initBB.YMin() + 0.5*initBB.Height();
    
	float h0 = initBB.Height();
	float w0 = initBB.Width();
	float aspect = w0/h0;
    // =======================SPM INTEGRATION=======================
	//outFile << initBB.XMin() << "," << initBB.YMin() << "," << initBB.Width() << "," << initBB.Height() << endl;
	for (int frameInd = startFrame; frameInd < endFrame; ++frameInd)
	{
		//read init frame
		Mat frame;
		char imgPath[256];
		sprintf(imgPath, imgFormat.c_str(), frameInd);
		Mat frameOrig = cv::imread(imgPath, 0);
		if (frameOrig.empty())
		{
			cout << "error: could not read frame: " << imgPath << endl;
			return EXIT_FAILURE;
		}
		resize(frameOrig, frame, Size(conf.frameWidth, conf.frameHeight));
		
		//init tracker
		tracker.Initialise(frame, initBB);
		
		//read next frame
		Mat frame2;
		char imgPath2[256];
		sprintf(imgPath2, imgFormat.c_str(), frameInd+1);
		Mat frameOrig2 = cv::imread(imgPath2, 0);
		if (frameOrig2.empty())
		{
			cout << "error: could not read frame2: " << imgPath2 << endl;
			return EXIT_FAILURE;
		}
		resize(frameOrig2, frame2, Size(conf.frameWidth, conf.frameHeight));
		
		
		//tracking one frame
		tracker.Track(frame2);
		
		const FloatRect& bb = tracker.GetBB();
		
		//scale estimation
		float x = bb.XMin() + 0.5 * bb.Width();
		float y = bb.YMin() + 0.5 * bb.Height();
		float height =  h0 *((theta1*x + theta2*y + theta3)/(theta1*x0 + theta2*y0 + theta3));
	    float scale = height/bb.Height();
		float width =  aspect * height;		
		float new_YMin = y - 0.5 * height;
		
		//save result
		cout<<scaleH<<"       "<<scaleW<<endl;
		outFile << bb.XMin() << "," << new_YMin << "," << width << "," << height << endl;
		
		//update init box
		initBB = FloatRect(bb.XMin(), new_YMin, width, height);
		
	}
	
	//-------------------------------------------------------------------
	
	if (outFile.is_open())
	{
		outFile.close();
	}
	
	return EXIT_SUCCESS;
}
