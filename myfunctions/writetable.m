function writetable(C,fn,delim,colnames)

% ; write cell table to delimited text file
% ; manual implementation 
% ;
% ; inputs: C:          cell array
% ;         fn:         full file name
% ;         delim:      delimiter: ',', '\t', ' ' or else
% ;         colnames:   column names (array of strings) for 1st row header
% ;         colformats: cell array of strings that specify format:
% ;                                '%s' for string, 
% ;                                '%d' for integer, 
% ;                                '%f' for floating numeric
% ;
% ; copyright by Ingmar Schoen, ETH Zurich, ingmar.schoen@hest.ethz.ch


[~,cols]=size(C);
rows = size(C,1);

% write first line
fid=fopen(fn,'wt');
fprintf(fid,['%s' delim],colnames{1:end-1});
fprintf(fid,'%s\n',colnames{end});

for i=1:rows
    for j=1:(cols-1)
        fprintf(fid,['%s' delim],num2str(C{i,j}));
    end
    fprintf(fid,'%s\n',num2str(C{i,end}));
end

fclose(fid);
