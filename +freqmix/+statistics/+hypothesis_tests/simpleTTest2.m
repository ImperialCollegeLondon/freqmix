function [t, df] = simpleTTest2(x1,x2,equal)
% A 2-sample t-test which computes only the t-value (and degrees of
% freedom), skipping the very time-consuming p-value computation. This
% function is good for permutation tests which need to compute t-values a
% large number of times as fast as possible. 
% This test assumes equal variances, and allows for unequal sample sizes. 


[d, n1] = size(x1); % should this be [n1,d]??
[d, n2] = size(x2);

xmean1 = sum(x1,2)/n1; % works faster then mean
xmean2 = sum(x2,2)/n2; % works faster then mean

xc = bsxfun(@minus,x1,xmean1);  % Remove mean
xstd1 = sqrt(sum(conj(xc).*xc,2)/(n1-1));

xc = bsxfun(@minus,x2,xmean2);  % Remove mean
xstd2 = sqrt(sum(conj(xc).*xc,2)/(n2-1));

% compute std  (based on the std function, but without unnecessary stages
% which make that function general, but slow (especially using repmat)
if equal
    sx1x2 = sqrt(((n1-1)*xstd1.^2 + (n2-1)*xstd2.^2)/(n1+n2-2));
    t = squeeze((xmean1 - xmean2) ./ (sx1x2 * sqrt(1/n1 + 1/n2)));
else    
    t = squeeze((xmean1 - xmean2) ./ sqrt(xstd1.^2/n1 + xstd2.^2/n2));
end

df = n1+n2-2;

end
