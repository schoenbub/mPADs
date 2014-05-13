function show_results_tracks(objref,fignum)

% ; assemble figure that summarizes the results from the refinement
% ; inputs are:
% ;         objref: refined objects
% ;         fignum: number of figure window
% ; output: none. 
% ; plotted is the original image with the tracks overlayed 
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat

% plot
figure(fignum);

sl = max(objref(5,:));
imshow(dat.stack(:,:,sl), []); 
title('post tracks')
for j = unique(objref(6,:))
    objs_j = objref(:,objref(6,:)==j);  % track j
    x = objs_j(1,:);  % x positions of this track
    y = objs_j(2,:);  % y positions of this track
    line(x,y,'Color','r','LineWidth',2);
end