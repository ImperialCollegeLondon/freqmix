%Dino Sejdinovic, 2013
%D. Sejdinovic, A. Gretton and W. Bergsma.  A KERNEL TEST FOR THREE-VARIABLE INTERACTIONS, 2013.

%--standard Gaussian kernel

function [H]=GaussKern(x,y,sig)
H=sqdistance(x',y');
H=exp(-H/2/sig^2);
end



function d = sqdistance(a,b)
if (nargin ~= 2)
   error('Not enough input arguments');
end
if (size(a,1) ~= size(b,1))
   error('Inputs must have same dimensionality');
end
aa=sum(a.*a,1); bb=sum(b.*b,1); ab=a'*b; 
d = abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab);
end