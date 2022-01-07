
function [zval] = simpleZTest(x,m,sigma)

% right tailed Z-test to get Z value
xmean = nanmean(x);
ser = sigma ./ sqrt(length(x));
zval = (xmean - m) ./ ser;

end
