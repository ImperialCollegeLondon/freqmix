function [results] = fourway_test(phases,sigma,numBootstraps,alpha,use_gpu)
%TWOWAY_TEST Summary of this function goes here
%   Detailed explanation goes here
import freqmix.frequencymixing.utils.*

X = phases(1,:);
Y = phases(2,:);
Z = phases(3,:);
W = phases(4,:);

n=length(X);
%TODO: add check that X,Y,Z same length

if use_gpu && gpuDeviceCount > 0
    K = GaussKern(gpuArray(X'),gpuArray(X'),sigma);
    L = GaussKern(gpuArray(Y'),gpuArray(Y'),sigma);
    M = GaussKern(gpuArray(Z'),gpuArray(Z'),sigma);
    J = GaussKern(gpuArray(W'),gpuArray(W'),sigma);

else 
    K = GaussKern(X',X',sigma);
    L = GaussKern(Y',Y',sigma);
    M = GaussKern(Z',Z',sigma);
    J = GaussKern(W',W',sigma);

end


Kc = empirically_centre(K);
clear K;
Lc = empirically_centre(L);
clear L;
Mc = empirically_centre(M);
clear M;
Jc = empirically_centre(J);
clear J;

totalMatrix = Kc.*Lc.*Mc.*Jc;

test_results = bootstrap_null(n,numBootstraps,totalMatrix,alpha,@freqmix.frequencymixing.utils.bootstrap_series,use_gpu);
clear totalMatrix

results = struct;
results.pvalue = test_results.pvalue;
results.hvalue = test_results.reject;
results.teststat = test_results.testStat;
results.quantile = test_results.quantile;
results.hoi = results.teststat/results.quantile;



end

