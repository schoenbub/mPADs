function hexa_lattice = map_onto_hexa(objrefdc)

% ; map post/track IDs onto hexagonal lattice
% ; use bottom slice post positions
% ; will then be used for quasi-image operations based on post parameters
% ;
% ; input: refined objects
% ; output: post IDs in rectangular array that represents the 0°/60° axis
% ;         of the hexagonal lattice
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

global dat allpar

% slice numbers
slice_range = unique(objrefdc(5,:));
% objects in bottom slice
obj_bottom = objrefdc(:,objrefdc(5,:)==slice_range(1));
% their xy positions
xybottom =  obj_bottom(1:2,:);
% calculate pair distance and direction
nobj = size(xybottom,2);
x1matrix = repmat(xybottom(1,:),[nobj 1]);
y1matrix = repmat(xybottom(2,:),[nobj 1]);
dxmatrix = x1matrix - x1matrix';
dymatrix = y1matrix - y1matrix';
dd = sqrt(dxmatrix.^2 + dymatrix.^2);
aa = atan2(dymatrix, dxmatrix);
% plot pairwise distances
bindd = 0:1:300;
binaa = -pi:pi/16:pi;
figure(33)
subplot(2,3,1)
nndd = histc(dd(:),bindd);
bar(bindd,nndd)
%         subplot(2,3,2)
%         nnaa = histc(aa(:),binaa);
%         bar(binaa,nnaa)

% find first 0 element after nonzero elements (peak of nearest neighbor distance)
% moving average filter to guarantee unique maximum
windowSize = 7;
nnddlp = movavg(nndd,windowSize);
% figure(77)
% plot(bindd,nnddlp)
% figure(33)
[pks, locs] = findpeaks(nnddlp(2:200));
% last nonzero element before peak
isdist = sign(nndd(2:200));
nonzerodist = find(isdist,10,'first');
nonzerosmaller = nonzerodist(nonzerodist<locs(1));
idxddmin = nonzerosmaller(end);
% first zero element after peak
nodist = find(1-isdist);
above = nodist(nodist>locs(1));
idxddmax = above(1);

% average nearest neighbor distance
meandd = mean(dd(dd>idxddmin & dd<idxddmax));
dat.pitch = meandd;
allpar.pixelsize = allpar.mpadP/meandd;

%         display(meandd);        
% select angles from only these nearest neighbors
elemsnext = (dd>idxddmin & dd<idxddmax);
aanext = aa(elemsnext);
subplot(2,3,2)
rose(aanext(:),360)
% determine global rotation angle from fit of 3 peaks in 0...pi sector
binaa = (0:0.5:180)/180*pi;
nnaa = hist(aanext(aanext>0),binaa);
[pksaa, locaa] = findpeaks(nnaa);
subplot(2,3,3)
plot(binaa,nnaa)
hold on
plot(binaa(locaa),pksaa,'k^','markerfacecolor',[1 0 0])
hold off
% fitting to determine global rotation
pinit = zeros([1 5]);
pkssorted = sort(pksaa,'descend');
%         display(pkssorted(1:3));
pinit(2:4) = pkssorted(1:3);
idx1 = locaa(pksaa==pkssorted(1));
idx2 = locaa(pksaa==pkssorted(2));
idx3 = locaa(pksaa==pkssorted(3));
%         display([idx1 idx2 idx3])
pinit(1) = binaa(min([idx1 idx2 idx3]));
pinit(5) = 0.5/180*pi;
threepeakfunc = @(p) p(2)*exp(-(binaa-p(1)).^2/(2*p(5)^2)) +...
    p(3)*exp(-(binaa-(p(1)+pi/3)).^2/(2*p(5)^2)) + ...
    p(4)*exp(-(binaa-(p(1)+2*pi/3)).^2/(2*p(5)^2));
% least  fit
Goodn = @(pguess) sum((nnaa-threepeakfunc(pguess)).^2);
[pbest, ~, ~]=fminsearch(Goodn,pinit);

% plot fit into graph
hold on
plot(binaa,threepeakfunc(pbest),'-r')
hold off

% select point which is representative (the one which is participated
% in the distance that is closest to the mean)
vardd = (dd-meandd).^2;
minpp = min(vardd(:));
indmin = find(vardd == minpp);
[ip1, ~] = ind2sub(size(vardd),indmin);
% rotate data around one arbitrary point (first in list)
rm = rotmat(pbest(1));
xyreg = (xybottom-repmat(xybottom(:,ip1(1)),[1 nobj]))'*rm;

% indices in hexagonal lattice
idcs_hexa = NaN(size(xyreg));
dy = sqrt(3.)/2.*meandd;
iy = xyreg(:,2)/dy;
idcs_hexa(:,2) = round(iy);
ix = (xyreg(:,1)-(idcs_hexa(:,2) * meandd/2.))/meandd;
idcs_hexa(:,1) = round(ix);

% control: residuals small around 0 --> alignment was okay
subplot(2,3,4)
hist(iy-idcs_hexa(:,2))
subplot(2,3,5)
hist(ix-idcs_hexa(:,1))

% write indices into regular lattice
min_hexa = min(idcs_hexa);
max_hexa = max(idcs_hexa);
idcs_hexa = idcs_hexa - repmat(min_hexa,[nobj 1]) +1;
size_lattice = (max_hexa-min_hexa)+1;
hexa_lattice = NaN(size_lattice);
for i=1:nobj
    hexa_lattice(idcs_hexa(i,1),idcs_hexa(i,2)) = obj_bottom(6,i);
end
subplot(2,3,6)
imshow(hexa_lattice,[])
colormap jet
