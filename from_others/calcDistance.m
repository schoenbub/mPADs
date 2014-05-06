function [d MAP] = calcDistance(obj, k, cutoff, mask, nx, ny)

if ~exist('mask', 'var')|| isempty(mask)
    mask = ones(ceil(max(obj(1,:))), ceil(max(obj(2,:))));
end
MAP = zeros(nx,ny);

n=numel(obj(1,:));
d=[];
for i=1:n
    if obj(5,i)==k+1
        if round(obj(1,i))<=nx && round(obj(2,i)) < ny && mask(round(obj(1,i)),round(obj(2,i)))==1
            link = obj(6,i);
            a = (obj(1,i)-obj(1,link));
            b = (obj(2,i)-obj(2,link));
            d(end+1)=sqrt(a^2+b^2);
            if d(end)<= cutoff 
                %MAP(round(obj(1,i)0-1):(round(obj(1,i)+1)),round(obj(2,i)-1):(round(obj(2,i)+1))) = d(end);
              MAP(round(obj(1,i)),round(obj(2,i))) = d(end);
              
            end
        end
    end
end

% remove distances longer than cutoff, if cutoff is given
if exist('cutoff', 'var')
    d=d.*(d(:)<=cutoff)';
    d(d==0)=[];         % delete entries that were > cutoff
end
%hist(d,100);

end
