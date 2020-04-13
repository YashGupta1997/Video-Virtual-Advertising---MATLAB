function [points_Out,points_In]= houghOperation(edges)

SE = strel('square',2);
edges = imerode(edges,SE);


edges=bwareaopen(edges,200);


[H,T,R]=hough(edges);
P  = houghpeaks(H,10,'threshold',ceil(0.2*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));

lines = houghlines(edges,T,R,P,'FillGap',5,'MinLength',20);


%% to find vanishing points
bg_forHoughLInes = ones(size(edges));
imshow(bg_forHoughLInes); hold on

[rows, columns] = size(edges);
xy_1 = zeros([2,2]);
max_len = 0;
h = 1;
for k = 1:length(lines)
    %%horizontal axis
    %      if (lines(k).theta <= -85) && (lines(k).theta >= -95)
    xy = [lines(k).point1; lines(k).point2];
    len(k) = norm(lines(k).point1 - lines(k).point2);
    avelen = 0.7*mean(len);
    if (len(k)> avelen)
        
        NewHoughLines(h) = lines(k);
        
        x1 = xy(1,1);
        y1 = xy(1,2);
        x2 = xy(2,1);
        y2 = xy(2,2);
        slope = (y2-y1)/(x2-x1);
        xLeft = 1; % x is on the left edge
        yLeft = slope * (xLeft - x1) + y1;
        xRight = columns; % x is on the reight edge.
        yRight = slope * (xRight - x1) + y1;
        plot([xLeft, xRight], [yLeft, yRight], 'LineWidth',1,'Color','blue');hold on
        
        xy_1 = xy;
        h = h+1;
    end
    %      end
end
%     saveas(gcf, 'Vanishingpoint_1.jpg')

%% intersection of hough Newlines

% outer horizontal Newlines
i = 1;
j=1;
for k = 1:length(NewHoughLines)
    if (NewHoughLines(k).theta >= -100 && NewHoughLines(k).theta <= -80) ||(NewHoughLines(k).theta <= 100 && NewHoughLines(k).theta >= 80)
        NewlinesHorz(i) = NewHoughLines(k);
        i = i+1;
    else       
        NewlinesVert(j) = NewHoughLines(k);
        j=j+1;
    end
end

tempH = {NewlinesHorz.rho};
tempH2 = abs(cell2mat(tempH));

j = 1;
for m = 1:length(NewlinesHorz)
    
    if (abs(NewlinesHorz(m).rho) == max(tempH2)) || (abs(NewlinesHorz(m).rho) == min(tempH2))
        OuterHorzLines(j) = NewlinesHorz(m);
        j = j+1;
    end
end

tempV = {NewlinesVert.theta};
tempV2 = (cell2mat(tempV));
j = 1;
k = 1;
for m = 1:length(NewlinesVert)
    
    if ((NewlinesVert(m).theta) == max(tempV2)) || (NewlinesVert(m).theta) == min(tempV2)
        OuterVertLines(j) = NewlinesVert(m);
        j = j+1;
        
    else
        InnerVertLines(k) = NewlinesVert(m);
        k = k+1;
    end
end

% outer vertical HOrizontal Intersection
a = 1;
for k = 1:length(OuterVertLines)
    for j = 1:length(OuterHorzLines)
        xy = [OuterHorzLines(j).point1; OuterHorzLines(j).point2];
        xy_1 = [OuterVertLines(k).point1; OuterVertLines(k).point2];
        %intersection of two Newlines (the current line and the previous one)
        slopee = @(line) (line(2,2) - line(1,2))/(line(2,1) - line(1,1));
        m1 = slopee(xy_1);
        m2 = slopee(xy);
        intercept = @(line,m) line(1,2) - m*line(1,1);
        b1 = intercept(xy_1,m1);
        b2 = intercept(xy,m2);
        xintersect = (b2-b1)/(m1-m2);
        xinter_Out(a) = xintersect;
        yintersect = m1*xintersect + b1;
        yinter_Out(a) = yintersect;
        plot(xintersect,yintersect,'m*','markersize',8, 'Color', 'red') ;hold on
        a= a+1;
    end
end


% inner vertical Outer Horizontal Intersection
a = 1;
for k = 1:length(InnerVertLines)
    for j = 1:length(OuterHorzLines)
        xy = [OuterHorzLines(j).point1; OuterHorzLines(j).point2];
        xy_1 = [InnerVertLines(k).point1; InnerVertLines(k).point2];
        %intersection of two Newlines (the current line and the previous one)
        slopee = @(line) (line(2,2) - line(1,2))/(line(2,1) - line(1,1));
        m1 = slopee(xy_1);
        m2 = slopee(xy);
        intercept = @(line,m) line(1,2) - m*line(1,1);
        b1 = intercept(xy_1,m1);
        b2 = intercept(xy,m2);
        xintersect = (b2-b1)/(m1-m2);
        xinter_In(a) = xintersect;
        yintersect = m1*xintersect + b1;
        yinter_In(a) = yintersect;
        plot(xintersect,yintersect,'*','markersize',8, 'Color', 'red');hold on
        a= a+1;
    end
end
% 
%  saveas(gcf, 'Outer_InnerIntersectionPoints_2.jpg')

points_Out = transpose([xinter_Out; yinter_Out]);
points_In = transpose([xinter_In; yinter_In]);
close(gcf)


end

