function coordinates=transformCord(points_Out,points_In)
OuterSortedPoints = sortrows(points_Out,1);
InnerSortedPoints = sortrows(points_In,1);
coordinates(1) = {[OuterSortedPoints(1,1) OuterSortedPoints(1,2)]};
coordinates(2) = {[OuterSortedPoints(3,1) OuterSortedPoints(3,2)]};
coordinates(3) = {[OuterSortedPoints(4,1) OuterSortedPoints(4,2)]};
coordinates(4) = {[OuterSortedPoints(6,1) OuterSortedPoints(6,2)]};    
coordinates=cell2mat(transpose(coordinates));
end