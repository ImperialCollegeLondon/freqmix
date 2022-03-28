function [t] = simpleCorrCoef(x,y,varargin)

x(isnan(y),:) = [];
y(isnan(y)) = [];

[r1,~] = size(x);

% De-mean Columns:
x = bsxfun(@minus,x,nansum(x,1)./size(x,1)); 
y = bsxfun(@minus,y,nansum(y,1)./size(y,1));

    % Normalize by the L2-norm (Euclidean) of Rows:
x = x.*repmat(sqrt(1./max(eps,nansum(abs(x).^2,1))),[size(x,1),1]); 
y = y.*repmat(sqrt(1./max(eps,nansum(abs(y).^2,1))),[size(y,1),1]);

% Compute Pair-wise Correlation Coefficients:
r = nansum(x.*y);

% Calculate p-values if requested:
t = (r.*sqrt(r1-2))./sqrt(1-r.^2);


end

% 
% x = [x(:) y(:)];
% x = single(x);
% 
% % Deal with empty inputs
% [~,m] = size(x);
% 
% % Compute correlations.
% t = isnan(x);
% [r, n] = correl(x);
% 
% % Operate on half of symmetric matrix.
% lowerhalf = (tril(ones(m),-1)>0);
% rv = r(lowerhalf);
% % Tstat = +/-Inf and p = 0 if abs(r) == 1, NaN if r == NaN.
% Tstat = rv .* sqrt((n-2) ./ (1 - rv.^2));



% % ------------------------------------------------
% function [r,n] = correl(x)
% %CORREL Compute correlation matrix without error checking.
% 
% [n,m] = size(x);
% r = cov(x);
% d = sqrt(diag(r)); % sqrt first to avoid under/overflow
% r = r ./ d ./ d'; % r = r ./ d*d';
% % Fix up possible round-off problems, while preserving NaN: put exact 1 on the
% % diagonal, and limit off-diag to [-1,1].
% r = (r+r')/2;
% t = abs(r) > 1;
% r(t) = sign(r(t));
% r(1:m+1:end) = sign(diag(r));
% 
% 
