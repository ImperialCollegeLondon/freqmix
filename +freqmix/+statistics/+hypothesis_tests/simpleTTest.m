
function [t, df] = simpleTTest(x,m)
    %TTEST  Hypothesis test: Compares the sample average to a constant.
    %   [STATS] = TTEST(X,M) performs a T-test to determine
    %   if a sample from a normal distribution (in X) could have mean M.
    %  Modified from ttest function in statistical toolbox of Matlab
    % The  modification is that it returns only t value and df. 
    %  The reason is that calculating the critical value that
    % passes the threshold via the tinv function takes ages in the original
    % function and therefore it slows down functions with many
    % iterations.


    if nargin < 1, 
        error('Requires at least one input argument.'); 
    end

    if nargin < 2
        m = 0;
    end

    samplesize  = size(x,2);
    xmean = sum(x,2)/samplesize; % works faster then mean

    % compute std  (based on the std function, but without unnecessary stages
    % which make that function general, but slow (especially using repmat)
    xc = bsxfun(@minus,x,xmean);  % Remove mean
    xstd = sqrt(sum(conj(xc).*xc,2)/(samplesize-1));

    ser = xstd ./ sqrt(samplesize);
    t = (xmean - m) ./ ser;
    % stats = struct('tstat', tval, 'df', samplesize-1);
    df = samplesize-1;

end
