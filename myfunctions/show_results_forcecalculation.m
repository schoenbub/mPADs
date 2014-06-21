function show_results_forcecalculation(defl_ang_force,objrefdc,fignum)

% ; show results of force calculation
% ;
% ; input: refined objects
% ; output: post IDs in rectangular array that represents the 0°/60° axis
% ;         of the hexagonal lattice
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat allpar

hexad = dat.hexadefl;
hexaa = dat.hexaang;
hexaf = dat.hexaforce;
hx = dat.hexaposx;
hy = dat.hexaposy;

figure(fignum);
subplot(2,2,1);
xbmax = (floor(max(defl_ang_force(4,:))/10.)+1)*10;
xbin = 0.25:0.5:xbmax;
hist(defl_ang_force(4,:),xbin)
title('forces [nN]')

subplot(2,2,2);
xbin = -180:5:180;
hist(defl_ang_force(3,:)/pi*180,xbin)
title('angle [°]')

% plot deflections as arrows in image
subplot(2,2,3); %lower left
sl = max(objrefdc(5,:));
imshow(dat.stack(:,:,sl), []);
title('post deflections [real size]')
hold on
x = hx(~isnan(hx));
y = hy(~isnan(hy));
ha = hexaa(~isnan(hexaa));
hd = hexad(~isnan(hexad));
u = cos(ha).*hd;
v = sin(ha).*hd;
quiver(x,y,u,v,'-y','Autoscale', 'off');
sim = size(dat.stack(:,:,sl));
pixel_size = allpar.pixelsize;
line([max([100,5/pixel_size+25])-5/pixel_size, max([100,5/pixel_size+25])+5/pixel_size],[sim(1)-100 sim(1)-100],'Color','w','LineWidth',2);
text(max([100,5/pixel_size+25]),sim(1)-60,'10 µm','HorizontalAlignment','center','Color',[1 1 1],'FontSize',8);
hold off

% plot forces as arrows in image
subplot(2,2,4); %lower left
imshow(dat.stack(:,:,sl),[]);
title('forces [nN]')
hold on
hf = hexaf(~isnan(hexaf));
fac = allpar.force3;
sbl = allpar.force4/2;
u = cos(ha).*hf*fac;
v = sin(ha).*hf*fac;
quiver(x,y,u,v,'-r','Autoscale', 'off');
line([max([100,fac*sbl+sbl])-fac*sbl max([100,fac*sbl+sbl])+fac*sbl],...
    [sim(1)-100 sim(1)-100],'Color','w','LineWidth',2);
text(max([100,fac*sbl+sbl]),sim(1)-60,[num2str(round(sbl*2)) ' nN'],...
    'HorizontalAlignment','center','Color',[1 1 1],'FontSize',8);
hold off
