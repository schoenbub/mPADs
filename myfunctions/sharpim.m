function out=sharpim(in)
h = fspecial('unsharp') ;
out=imfilter(in,h,'replicate');
