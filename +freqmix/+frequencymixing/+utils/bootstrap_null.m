function [ results ] = bootstrap_null(m,numBootstrap,...
                                        statMatrix,alpha, wild_bootstrap, use_gpu)

%memory_percentage = gpuDevice(1).AvailableMemory/gpuDevice(1).TotalMemory;
%enough_gpu_memory = (memory_percentage > 0.1);
import freqmix.frequencymixing.utils.*


if use_gpu && gpuDeviceCount % & enough_gpu_memory
    % Running on GPU
    % Calculating diagonal is much quicker than for loop due to memory
    % efficiency
    if numBootstrap < 10001
        processes = gpuArray(single(wild_bootstrap(double(m),numBootstrap)));
        testStat = gpuArray(single(m*mean2(statMatrix)));
        m_inv = (1/m);

        gstatMatrix = gpuArray(single(statMatrix));

        testStats = diag(m_inv*(processes'*gstatMatrix*processes));
    else
        processes = gpuArray(single(wild_bootstrap(double(m),numBootstrap)));
        testStat = gpuArray(single(m*mean(statMatrix,'all')));
        m_inv = (1/m);
        
        testStats = gpuArray(zeros(numBootstrap,1));

        for process = 1:numBootstrap
            vec = processes(:,process);
            testStats(process) = m_inv*(vec'*statMatrix*vec);
        end        
    end
else
    % Running on CPU
    % For loop is faster than calculating diagonal of triple matrix
    % multiplication
    processes = wild_bootstrap(m,numBootstrap);
    testStat = m*mean(statMatrix,'all');
    m_inv = (1/m);

    testStats = zeros(numBootstrap,1);

    for process = 1:numBootstrap    
        vec = processes(:,process);
        testStats(process) = m_inv*(vec'*statMatrix*vec);
    end

end

results.testStat = gather(testStat);
tmp = quantile(testStats,1-alpha);
results.reject = gather(testStat > tmp);
results.quantile = gather(tmp);
results.pvalue = gather(sum(testStats > testStat)/length(testStats));

end

