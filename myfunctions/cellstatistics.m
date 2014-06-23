function [cellstats, cellarea, cellellipt, cellcentroid, cellcirc] = cellstatistics(L,pixsiz)

% ; statistics of cell outlines
% ;
% ; inputs: L:          label matrix
% ;         pixsiz:     pixel size [µm]
% ; 
% ; output: cellstats:  cell array of cell statistics
% ;         cellarea:   list of cell areas [µm^2]
% ;         cellellipt: list of cell ellipticities (major/minor axis)
% ;         cellcentroid: xy list of cell centroids [pixel]
% ;         cellcirc:   list of cell circularities
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch


cellstats = regionprops(L,'Area','Centroid','BoundingBox',...
    'Perimeter','MajorAxisLength','MinorAxisLength');
% area in µm^2
cellarea = [cellstats.Area]*pixsiz*pixsiz;
% ellipticity
cellellipt = [cellstats.MajorAxisLength]./[cellstats.MinorAxisLength];
% centroid in pixel
cellcentroid = [cellstats.Centroid];
cellcentroid = reshape(cellcentroid,2,numel(cellcentroid)/2)';
% cell circularity
cellcirc = [cellstats.Perimeter]./(sqrt([cellstats.Area]/pi)*2*pi);
        