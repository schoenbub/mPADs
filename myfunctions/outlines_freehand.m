function L = outlines_freehand()

% ; draw cell outlines manually
% ;
% ; input: 	none
% ; output: label matrix
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

message = sprintf('Draw outline. When finished, double-click on it.');
uiwait(msgbox(message));
hFH = imfreehand(gca);
wait(hFH);

% Create a binary image ("mask") from the ROI object.
bw1 = hFH.createMask();
bwi = bw1;
% Display the freehand mask.
L = bwlabel(bw1,4);
rgb = label2rgb(L,'jet','k');
figure(2)
imshow(rgb);
% ask how to continue
button = questdlg('How would you like to proceed?',...
    'selection of outlines','next','finished','undo','next');
display(button);

while ~strcmp(button,'finished')
    switch button
        case 'next'
            figure(1)
            hFH = imfreehand(gca);
            wait(hFH);
            % Create a binary image ("mask") from the ROI object.
            bwi = hFH.createMask();
            bw1 = bw1 + bwi;
        case 'undo'
            bw1 = bw1 - bwi;
    end
    % Display the freehand mask.
    L = bwlabel(bw1,4);
    rgb = label2rgb(L,'jet','k');
    figure(2)
    imshow(rgb);
    % ask how to continue
    button = questdlg('How would you like to proceed?',...
    'selection of outlines','next','finished','undo','next');
end         