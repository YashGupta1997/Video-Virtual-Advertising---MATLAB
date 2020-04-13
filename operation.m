function r = operation(im)
im=rgb2gray(im);
edges=edge(im,'sobel');
imwrite(edges,'onlySobel.png')
se=strel('diamond',3);
dilated=imdilate(edges,se);

se = strel('square',5);
eroded = imerode(dilated,se);

c1=bwareaopen(eroded,500);

CC = bwconncomp(c1);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
BW = zeros(size(c1));
BW(CC.PixelIdxList{idx}) = 1;

BW1 = and(c1,BW);
BW2 = and(eroded,BW);
BW = BW1|BW2;

SE = strel('square',2);
Jerode = imerode(BW,SE);

final=bwareaopen(Jerode,200);

r = final;

end 