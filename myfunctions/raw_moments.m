% raw image moments according to the wikipedia article
function outmom = raw_moments(im,i,j)
    outmom = sum(sum( ((1:size(im,1))'.^j * (1:size(im,2)).^i) .* im ));
end