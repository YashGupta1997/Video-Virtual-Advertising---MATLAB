%%
close all
clear variables

%% point initialisation
fname = 'Vid3.mp4';
vidReader = VideoReader(fname);

im=read(vidReader,25);
% figure;imshow(im);

ad=imread('logo.png');
edges= operation(im);
% figure; imshow(edges);

% 
[points_Out,points_In]=houghOperation(edges);
% im = insertMarker(im,points_Out,'*',  'Color' ,'red', 'size',6);
% im = insertMarker(im,rmmissing(points_In),'*',  'Color' ,'red', 'size',6);


coordinates=(transformCord(points_Out,points_In));
im = insertMarker(im,coordinates(),'X', 'size',10,'color','red');
% figure; imshow(im);
% imwrite(im,'frame_with_tracking_points.png')
% figure; imshow(im);
% figure;imshow(ad);

%% ad corner matrix

[r,c,nrgb]=size(ad);
admat=[1 r; 1  1; c 1; c r];
%%%admat=[1   1; c  1; c r; 1 r];
tform=estimateGeometricTransform(admat,coordinates,'projective');
transAd=imwarp(ad,tform);
imwrite(transAd,'TransformedAd2.png');
% figure; imshow(transAd);





%% video player

outputname = 'Test';
profile = 'MPEG-4';
framerate = 25;
quality = 50;

wobj = VideoWriter(outputname,profile);
wobj.FrameRate = framerate;
wobj.Quality = quality;
open(wobj);

videoPlayer = vision.VideoPlayer('Position',[50,50,1100,600],'Name','Virtual Advertising');

%% tracker initialisation
pointTracker = vision.PointTracker('MaxBidirectionalError', inf);

initialize(pointTracker,coordinates,im);

%% processing


nframes=vidReader.NumFrames;
for i =1:nframes
    frame=read(vidReader,i);
    frameg=rgb2gray(frame);
    [points,point_validity] = pointTracker(frame); 
    tformnew=estimateGeometricTransform(admat,points,'projective');
    tad=imwarp(ad,tformnew);
    
    Background = ones(size(frame));
    R = (imrotate(tad,0,'loose'));
    resizedAd = imcomplement(imresize(R,1));
    arr=points(2,:);
    J = imtranslate(resizedAd,[arr(1)-210 arr(2)],'FillValues',255,'OutputView','full');
    %56 365
    C = (imfuse(Background,J,'blend'));
%      h=size(frame);
%      C = imresize(C,[h(1) h(2)]);
    alpha = 0.3;
%     OverlayedImage =  alpha*C +(1-alpha)*frame;
    alphablend = vision.AlphaBlender;
    hist = alphablend(C,frame,'Operation','Highlight selected pixels');
%     hist = imhistmatch(OverlayedImage,frame);
    hist = imhistmatch(hist,frame);
    hist = insertMarker(hist,points,'*',  'Color' ,'red', 'size',6);
    videoPlayer(hist);
    writeVideo(wobj,hist);
end

close(wobj);


