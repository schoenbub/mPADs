function L = outlines_adjustmanually(im)

% ; manually adjust existing mask
% ; operations: delete object, divide object, cut off region, fill region
% ;
% ; input: im:  image for overlay
% ;             import L from global dat.labelmask
% ; output: L:  label matrix with individual cells
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat allpar

minobjsize = allpar.outline3;

% load existing labelmatrix
L = dat.labelmask;
bw0 = (L>0); % for backup
bw1 = bw0;
rgb = label2rgb(L,'jet','k');
figure(2)
imshow(rgb);
% options what to do next
listopts = {'delete','divide','cut','fill','undo'};
[selected,v] = listdlg(...
    'PromptString','How would you like to proceed?',...
    'Name','manual modification of existing mask',...
    'CancelString','finished',...
    'SelectionMode','single',...
    'ListString',listopts);
display(selected);

% individual cases
while v==1
    switch selected
        case 1 % delete
            figure(2)
            message = sprintf(...
                ['Draw a ROI. All cells touching this ROI '...
                'will be deleted. '...
                'When finished, double-click on it.']);
            uiwait(msgbox(message));
            hFH = imfreehand(gca);
            wait(hFH);
            % Create a binary image ("mask") from the ROI object.
            bwi = hFH.createMask();
            % determine which cell(s) is(are) marked
            celllabels = unique(L(bwi));
            celllabels = celllabels(celllabels>0);
            display(celllabels);
            % delete that(these) cell(s)
            bw0 = bw1; %for backup
            for i=1:length(celllabels)
                bw1(L==celllabels(i)) = 0;
            end

        case 2 % divide
            % show overlay
            figure(1);
            imshow(im, []);
            colormap gray
            hold on
            hg = imshow(rgb);
            hold off
            set(hg,'AlphaData',0.15) 
            % message
            message = sprintf(...
                ['Draw dividing line between cells. '...
                'When finished, double-click on it.']);
            uiwait(msgbox(message));
            hFH = imfreehand(gca,'Closed',0);
            wait(hFH);
            % Create a binary image ("mask") from the ROI object.
            % a bit complicated: need to close line between
            % points
            bw0 = bw1; %for backup
            P0 = hFH.getPosition;
            D = round([0; cumsum(sum(abs(diff(P0)),2))]); % Need the distance between points...
            P = interp1(D,P0,D(1):.5:D(end)); % ...to close the gaps
            P = unique(round(P),'rows');
            S = sub2ind(size(bw1),P(:,2),P(:,1));
            bw1(S) = 0;

        case 3 % cut
            % overlay
            figure(1);
            imshow(im, []);
            colormap gray
            hold on
            hg = imshow(rgb);
            hold off
            set(hg,'AlphaData',0.15)
            % message
            message = sprintf(...
                ['Draw region that shall be cut off. '...
                'When finished, double-click on it.']);
            uiwait(msgbox(message));
            hFH = imfreehand(gca);
            wait(hFH);
            % Create a binary image ("mask") from the ROI object.
            bwi = createMask(hFH,hg);
            % delete that(these) cell(s)
            bw0 = bw1; %for backup
            bw1(bwi) = 0;

        case 4 % fuse
            % overlay
            figure(1);
            imshow(im, []);
            colormap gray
            hold on
            hg = imshow(rgb);
            hold off
            set(hg,'AlphaData',0.15)
            % message
            message = sprintf(...
                ['Draw region that shall be filled. '...
                'When finished, double-click on it.']);
            uiwait(msgbox(message));
            hFH = imfreehand(gca);
            wait(hFH);
            % Create a binary image ("mask") from the ROI object.
            bwi = createMask(hFH,hg);
            % delete that(these) cell(s)
            bw0 = bw1; %for backup
            bw1(bwi) = 1;

        case 5 % undo last
            bw1 = bw0;
    end
    %remove small objects
    bw1 = bwareaopen(bw1,minobjsize,4);
    % Display the freehand mask.
    L = bwlabel(bw1,4);
    rgb = label2rgb(L,'jet','k');
    figure(2)
    imshow(rgb);
    % onext round or cancel
    [selected,v] = listdlg(...
        'PromptString','How would you like to proceed?',...
        'Name','manual modification of existing mask',...
        'CancelString','finished',...
        'SelectionMode','single',...
        'ListString',listopts);

end         
