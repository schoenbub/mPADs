function [out] = showPillars(Pillars, Cell, Celloutline, obj, n)

out=figure;
imshow(cat(3,Pillars, Cell, Celloutline)); hold on;
x_ref = obj(1,(obj(5,:)==1));
y_ref = obj(2,(obj(5,:)==1));
x_top = obj(1,(obj(5,:)==n+1));
y_top = obj(2,(obj(5,:)==n+1));

scatter(x_ref,y_ref,'+r');
scatter(x_top,y_top,'+b');

end
