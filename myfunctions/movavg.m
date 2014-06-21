function listout = movavg(listin,ws)

% ; moving average
% ; returns same number of elements
% ; average for elements at border are just calculated from valid overlap
% ; 
% ; input:  listin: list that shall be filtered
% ;         ws:     size of averaging window (must be uneven)
% ; 
% ; output: listout: filtered list
% ; 
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch

% half size of window, length of list
halfsize = floor(ws/2);
nn = length(listin);
% enforce uneven window size
window = halfsize*2+1;
listout = zeros([1 nn]);
for i =1:length(listin)
    listout(i) = mean(listin(max(1,i-halfsize):min(nn,i+halfsize)));
end

    