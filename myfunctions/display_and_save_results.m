function display_and_save_results(im_mpad,im_actin,B,L,cellcentroid,...
    angposts, forceposts, xyposts, cellstats, labelposts, cellnetang,...
    cellnetforce,colnames,dataall)

% ; display and save results to disk
% ;
% ; inputs: 	all that you need...
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global allpar dat hglob

p = get(hglob.directory,'String');

% composite image
h1=figure(100);
subplot(1,2,1)
imshow(im_mpad, 'InitialMagnification', 100)
title('composite overview image')
green = cat(3, zeros(size(im_mpad)), ones(size(im_mpad)),...
    zeros(size(im_mpad)));
hold on 
hg = imshow(green); 
hold off
set(hg,'AlphaData',im_actin)
for i=1:max(L(:))
    boundary = B{i};
    line(boundary(:,2), boundary(:,1),'Color','y','LineWidth', 1)
    text(cellcentroid(i,1),cellcentroid(i,2),num2str(i),...
        'Color',[1 1 1],'HorizontalAlignment','center',...
        'FontSize',22)
end

% plot forces as arrows in image
subplot(1,2,2)
imshow(im_mpad, 'InitialMagnification', 100)
title('force vector map')
hold on
fac = allpar.force3;
sbl = allpar.force4/2;
u = cos(angposts).*forceposts*fac;
v = sin(angposts).*forceposts*fac;
sim = size(im_mpad);
x = xyposts(:,1);
y = xyposts(:,2);
quiver(x,y,u,v,'-r','Autoscale', 'off');
line([max([100,fac*sbl+sbl])-fac*sbl max([100,fac*sbl+sbl])+fac*sbl],...
    [sim(1)-100 sim(1)-100],'Color','w','LineWidth',2);
text(max([100,fac*sbl+sbl]),sim(1)-50,[num2str(round(sbl*2)) ' nN'],...
    'HorizontalAlignment','center','Color',[1 1 1],'FontSize',10);
hold off

% save figure
if allpar.stat1 == 1
    pout = [p '\results'];
    mkdir(pout);
    fnbase = dat.allfiles(dat.current).name;
    fnbase = fnbase(1:end-4);
    fn1 = [pout '\' fnbase '_overview.pdf'];
    saveas(h1,fn1);
end

% figures for individual cells
for i=1:max(L(:))
    h2 = figure(100+i);

    subplot(1,2,1)
    % region of interest around cell
    bbox = cellstats(i).BoundingBox;
    imshow(im_mpad(bbox(2):bbox(2)+bbox(4)-1,...
        bbox(1):bbox(1)+bbox(3)-1))
    title(['cell ' num2str(i)])
    % cell boundary
    boundary = B{i};
    line(boundary(:,2)-bbox(1), boundary(:,1)-bbox(2),...
        'Color','y','LineWidth', 1)
    % force vectors
    hold on
    u = cos(angposts(labelposts == i)).*forceposts(labelposts == i)*fac;
    v = sin(angposts(labelposts == i)).*forceposts(labelposts == i)*fac;
    x = xyposts(:,1);
    x = x(labelposts == i);
    x = x-bbox(1);
    y = xyposts(:,2);
    y = y(labelposts == i);
    y = y-bbox(2);
    quiver(x,y,u,v,'-r','Autoscale', 'off');
    line([max([100,fac*sbl+sbl])-fac*sbl max([100,fac*sbl+sbl])+fac*sbl],...
        [bbox(4)-100 bbox(4)-100],'Color','w','LineWidth',2);
    text(max([100,fac*sbl+sbl]),bbox(4)-60,[num2str(round(sbl*2)) ' nN'],...
        'HorizontalAlignment','center','Color',[1 0 0],'FontSize',10);
    hold off
    % net force vector
    xi0 = cellcentroid(i,1)-bbox(1);
    yi0 = cellcentroid(i,2)-bbox(2);
    u = cos(cellnetang(i)).*cellnetforce(i)*fac;
    v = sin(cellnetang(i)).*cellnetforce(i)*fac;
    hold on
    quiver(xi0,yi0,u*0.1,v*0.1,'-g','Autoscale', 'off','LineWidth',1);
    text(max([100,fac*sbl+sbl]),bbox(4)-10,[num2str(round(sbl*2)*10) ' nN'],...
        'HorizontalAlignment','center','Color',[0 1 0],'FontSize',10);
    hold off

    % statistics as text
    hp = uipanel('FontSize',10,...
         'BackgroundColor','white',...
         'Position',[.55 .2 .4 .65]);
    data_i = num2cell(dataall(:,i)',1);
    tablecontents = colnames;
    tablecontents(2,1:end) = data_i;

    t = uitable(hp,'Units','normalized','Position',...
        [0.05 0.05 0.9 0.9], 'Data', tablecontents',... 
        'ColumnName', [],...
        'RowName',[],...
        'ColumnFormat',{'char','numeric'},...
        'ColumnWidth',{120, 50});

    % save figure
    if allpar.stat1 == 1
        fni = [pout '\' fnbase '_cell' num2str(i) '.fig'];
        saveas(h2,fni,'fig');            
        fni = [pout '\' fnbase '_cell' num2str(i) '.pdf'];
        saveas(h2,fni,'pdf');
    end

end

% saving
if allpar.stat1 == 1
    % save results into spreadsheet
    outdata =  num2cell(dataall)';
    fnout = [pout '\' fnbase '_results.txt'];
    writetable(outdata,fnout,'\t',colnames);
    % save workspace state (w/o dat.stack)
    fnout = [pout '\' fnbase '_variables.mat'];
    dat2save = dat;
    dat2save = rmfield(dat2save,'stack');
    dat2save = rmfield(dat2save,'raw');
%     avoidVariable = 'dat';
%     save(fnout,'-regexp', ['^(?!', avoidVariable,'$).']);
    save(fnout,'allpar','dat2save')
end