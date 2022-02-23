classdef frequencymixing
    %FREQUENCYMIXING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        config
        config_spectrum
        
        harmonicmixing = {}
        tripletmixing = {}
        quadrupletmixing = {}
        
        progression % details on which signals have been completed
        
        tables

        freq_channel_combinations
        
        logger
    end
    
    methods
        
        function obj = frequencymixing(config, config_spectrum)
            %FREQUENCYMIXING Construct an instance of this class
            
            obj.config = config;
            obj.config_spectrum = config_spectrum;            
            obj = obj.get_frequency_channel_combinations();            
            
            if obj.config.test_harmonics
                obj.tables.harmonic = obj.construct_table('harmonic');
            end                 
            if obj.config.test_triplets
                obj.tables.triplet = obj.construct_table('triplet');
            end
            if obj.config.test_quadruplets
                obj.tables.quadruplet = obj.construct_table('quadruplet');
            end            
        end
        
        function obj = run(obj, datacollection)
            % main function to run all samples   
            
            % store details on progression of run
            obj = obj.setup_progression(datacollection);

            % run triplet dependence tests
            if obj.config.test_triplets
                obj.logger.log('Running triplet dependence tests ...');
                triplet_mixing = cell(height(datacollection.data),1);
                
                % load existing temp files into empty cell array
                if obj.config.load_progression
                    [obj, triplet_mixing] = obj.load_existing_mixing(triplet_mixing, 'triplets');
                end
                
                if obj.config.parallel
                    % start parallel pool
                    obj.logger.log('Running triplet computations in parallel ...');
                    
                    % clear previous parallel pool
                    delete(gcp('nocreate'));parpool(obj.config.n_workers);
                    
                    % set up data queue
                    D = parallel.pool.DataQueue;
                    afterEach(D, @disp) 
                    
                    % loop over all samples
                    parfor i = 1:height(datacollection.data)
                        
                        % only run mixing if not already completed
                        if ismember(i, obj.progression.triplets.to_run)
                            % run triplet mixing on sample
                            triplet_mixing{i} = obj.run_sample(datacollection.data{i,'data'}{1},'triplet');                                            

                            % update data queue
                            send(D, i);     

                            % update progression
                            obj.update_progression(i, triplet_mixing{i}, 'triplets');
                        end
                    end                    
                else
                    % loop over all samples
                    obj.logger.log('Running signals sequentially (not parallel) ...');

                    for i = 1:height(datacollection.data)
                        
                        % subset of signals to run
                        if ismember(i, obj.progression.triplets.to_run)
                            
                            obj.logger.log(sprintf('Computing for signal %i',i));                            
                            triplet_mixing{i} = obj.run_sample(datacollection.data{i,'data'}{1},'triplet');
                            
                            % update progression
                            obj.update_progression(i, triplet_mixing{i}, 'triplets');     
                        end
                    end 
                    
                end
                obj.tripletmixing = triplet_mixing;
            end

            
            % run harmonic mixing tests
            if obj.config.test_harmonics
                obj.logger.log('Running harmonic dependence tests ...');
                harmonic_mixing = cell(height(datacollection.data),1);
                
                % load existing temp files into empty cell array
                if obj.config.load_progression
                    [obj, harmonic_mixing] = obj.load_existing_mixing(harmonic_mixing, 'harmonics');
                end
                
                if obj.config.parallel
                    % start parallel pool
                    obj.logger.log('Running harmonic computations in parallel ...');
                    
                    % clear previous parallel pool
                    delete(gcp('nocreate'));parpool(obj.config.n_workers);
                    
                    % set up data queue
                    D = parallel.pool.DataQueue;
                    afterEach(D, @disp) 
                    
                    % loop over all samples
                    parfor i = 1:height(datacollection.data)
                        
                        % only run mixing if not already completed
                        if ismember(i, obj.progression.harmonics.to_run)
                            % run triplet mixing on sample
                            harmonic_mixing{i} = obj.run_sample(datacollection.data{i,'data'}{1},'harmonic');                                            

                            % update data queue
                            send(D, i);     

                            % update progression
                            obj.update_progression(i, harmonic_mixing{i}, 'triplets');
                        end
                    end                    
                else
                    % loop over all samples
                    obj.logger.log('Running signals sequentially (not parallel) ...');

                    for i = 1:height(datacollection.data)
                        
                        % subset of signals to run
                        if ismember(i, obj.progression.harmonics.to_run)
                            
                            obj.logger.log(sprintf('Computing for signal %i',i));                            
                            harmonic_mixing{i} = obj.run_sample(datacollection.data{i,'data'}{1},'harmonic');
                            
                            % update progression
                            obj.update_progression(i, harmonic_mixing{i}, 'harmonics');     
                        end
                    end 
                    
                end
                obj.harmonicmixing = harmonic_mixing;
            end
            
            
            % combine quadruplets based on triplet tests
            if obj.config.test_quadruplets
               obj.logger.log('Running quadruplet dependence tests ...');
               
               quadruplet_mixing = cell(height(datacollection.data),1);                
                if obj.config.parallel
                    % start parallel pool                    
                    obj.logger.log('Running quadruplet computations in parallel ...');
                    
                    % clear previous parallel pool
                    delete(gcp('nocreate'));parpool(obj.config.n_workers);         
                    
                    % set up data queue
                    D = parallel.pool.DataQueue;
                    afterEach(D, @disp)   
                    
                    % loop over all samples
                    parfor i = 1:height(datacollection.data)                        
                        quadruplet_mixing{i} = obj.calculate_quadruplets(obj.tripletmixing{i},obj.harmonicmixing{i});
                        
                        % update data queue
                        send(D, i);  
                    end                    
                else
                    % loop over all samples
                    for i = 1:height(datacollection.data)
                        quadruplet_mixing{i} = obj.calculate_quadruplets(obj.tripletmixing{i},obj.harmonicmixing{i});
                    end         
                end
                obj.quadrupletmixing = quadruplet_mixing;
            end
            
            obj.logger.log('All frequency mixing tests completed ...');
            
            % remove temp files if they exist
            %remove_temp();
            
        end
        
        
        function results = calculate_quadruplets(obj, triplet_mixing, harmonic_mixing)
            
            % extract all triplet info for each quadruplet
            results = obj.tables.('quadruplet');
            
            % scan over quadruplets
            for i = 1:height(results)
                
               triplets = triplet_mixing(results.triplet_indexes{i},:);
               harmonics = harmonic_mixing(results.harmonic_indexes{i},:);
               
               results{i,'pvalues'} = {[triplets.pvalue; harmonics.pvalue]};
               results{i,'hvalues'} = {[triplets.hvalue; harmonics.hvalue]};
               results{i,'teststats'} = {[triplets.teststat; harmonics.teststat]};
               results{i,'hois'} = {[triplets.hoi; harmonics.hoi]};
               
               % two triplets to have evidence of frequency mixing
               %sorted_hoi = sort(triplets.hoi,'descend');
               %results{i,'hoi'} = mean(sorted_hoi(1:2));   
               
               % mean of all four triplets in quadruplet
               results{i,'hoi'} = mean(triplets.hoi(1:4)); 
            end
            
        end
        
        function obj = update_quadruplets(obj)
            % update the hoi for quadruplets
            
            for i = 1:length(obj.quadrupletmixing)
                result = obj.quadrupletmixing{i}; 
                
                hois = reshape(cell2mat(result{:,'hois'}),[6, height(result)])';
                result.hoi = mean(hois(:,1:4),2);               

                obj.quadrupletmixing{i} = result;
            end
            
        end
        
        function results = run_sample(obj, signal, type)
            % compute frequency mixing for a single signal
            
            % compute spectrum
            spectral_obj = freqmix.spectrum.spectrum(obj.config_spectrum);
            spectral_obj = spectral_obj.compute_spectrum(signal);            
            
            % define empty results table
            results = obj.tables.(type);
            
            % define indexes and tests
            if isequal(type,'triplet')
                freq_index = 1:3;channel_index = 4:6;
                test = @freqmix.frequencymixing.triplets.threeway_test;
            elseif isequal(type,'harmonic')
                freq_index = 1:2;channel_index = 3:4; 
                test = @freqmix.frequencymixing.harmonics.twoway_test;                
            end
            
            % extract instantaneous phase from spectrum
            phases = single(angle(spectral_obj.spectra));
            spectral_freqs = single(round(spectral_obj.freqs,obj.config.tolerance));
                   
            % scan over triplets
            for i = 1:height(results)
                %tic;
                freqs = round(results{i,freq_index},obj.config.tolerance);
                channels = results{i,channel_index};
                [dependence_result, triplet_type] = obj.run_dependence_test(phases,...
                                                            spectral_freqs,...
                                                            freqs,...
                                                            channels,...
                                                            test);
                                                        
                % extract important information from dependence test
                results.pvalue(i) = dependence_result.pvalue;   
                results.hvalue(i) = dependence_result.hvalue;
                results.teststat(i) = dependence_result.teststat;
                results.hoi(i) = dependence_result.hoi;
                results.quantile(i) = dependence_result.quantile;
                results.type(i) = triplet_type;
                %toc;
            end 
                           
        end
        
        function [dependence_result, triplet_type] = run_dependence_test(obj,all_phases,spectral_freqs,freqs,channels,test)
            % run a single dependence test
            
            index = find(ismember(spectral_freqs,freqs));            
            phases = [];
            
            for i = 1:width(freqs)
                phases(i,:) = all_phases(index(i), 1:obj.config.downsampling_frequency:end, channels(i));
            end
            
            dependence_result = test(phases,...
                                     obj.config.sigma,obj.config.n_bootstraps,...
                                     obj.config.alpha,obj.config.use_gpu);

            
            % only compute triplet type for triplets
            if obj.config.triplet_type && width(freqs)==3
                triplet_type = freqmix.frequencymixing.triplets.triplet_type(phases);
            else
                triplet_type = int8(0);
            end
                                 
        end
       
        
        function empty_table = construct_table(obj, type)  
            % constructing empty mixing tables 
            
            constructor = obj.get_table_constructors(type);                                
            empty_table = table('Size',[size(obj.freq_channel_combinations.(type),1),size(constructor,1)],... 
                                'VariableNames', constructor(:,1),...
                                'VariableTypes', constructor(:,2));   
                    
            empty_table(:,1:size(obj.freq_channel_combinations.(type),2)) = obj.freq_channel_combinations.(type);
            
            % find matching triplets and harmonics for each quadruplet for indexing later
            if isequal(type,'quadruplet')
               % find triplets
               triplet_table = obj.tables.('triplet');
               for i = 1:height(empty_table)
                   quad_freqs = empty_table{i,1:4};
                   quad_chans = empty_table{i,5:8};                   
                   
                   triplet_idx = [1 2 3; 1 2 4; 1 3 4; 2 3 4];
                   triplets= zeros(4,1);
                   
                   % loop over the 4 triplets within the quadruplet
                   for k = 1:4
                      [freqs,idx] = sort(quad_freqs(triplet_idx(k,:)));
                      chans = quad_chans(triplet_idx(k,idx));
                      freq_logic = (triplet_table.Freq1==freqs(1) & triplet_table.Freq2==freqs(2) & triplet_table.Freq3==freqs(3));
                      chan_logic = (triplet_table.Channel1==chans(1) & triplet_table.Channel2==chans(2) & triplet_table.Channel3==chans(3));
                      triplet_index = find(freq_logic & chan_logic);
                      triplets(k) = triplet_index;
                   end
                   empty_table.triplet_indexes{i} = triplets;                   
               end
               
               % find harmonics
               harmonic_table = obj.tables.('harmonic');
               for i = 1:height(empty_table)
                   quad_freqs = empty_table{i,1:4};
                   quad_chans = empty_table{i,5:8};                   
                   
                   harmonic_idx = [1;2];
                   harmonics = zeros(2,1);
                   
                   % loop over the 2 harmonics expected from the roots of
                   % the quadruplet
                   for k = 1:2
                      [freqs,idx] = sort(quad_freqs(harmonic_idx(k,:)));
                      chans = quad_chans(harmonic_idx(k,idx));
                      freq_logic = (harmonic_table.Freq1==freqs(1) & harmonic_table.Freq2==2*freqs(1));
                      chan_logic = (harmonic_table.Channel1==chans(1) & harmonic_table.Channel2==chans(1));
                      harmonic_index = find(freq_logic & chan_logic);
                      harmonics(k) = harmonic_index;
                   end
                   empty_table.harmonic_indexes{i} = harmonics;                   
               end                     
            end
            
            % check summative triplets
            if isequal(type,'triplet')                
                for i = 1:height(empty_table)
                    empty_table.summative(i) = (empty_table{i,'Freq1'} + empty_table{i,'Freq2'} == empty_table{i,'Freq3'});
                end
            end
      
                                
        end
        
        function obj = get_frequency_channel_combinations(obj)
            % combine all frequency mixing with all channel combinations
            import freqmix.frequencymixing.utils.*
            
            disp('Defining all frequency/channel mixing combinations to test ...');
            
            if obj.config.test_harmonics
                harmonic_ch_combs = channel_permutations(obj.config.channels,'harmonic');
                obj.freq_channel_combinations.harmonic = frequency_channel_combinations(obj.config.harmonics,harmonic_ch_combs,...
                                                                                         obj.config.within_channels,...
                                                                                         obj.config.between_channels);    
            end
            
            if obj.config.test_triplets
                triplet_ch_combs = channel_permutations(obj.config.channels,'triplet');
                obj.freq_channel_combinations.triplet = frequency_channel_combinations(obj.config.triplets,triplet_ch_combs,...
                                                                                        obj.config.within_channels,...
                                                                                        obj.config.between_channels);    
            end 
            
            if obj.config.test_quadruplets
                quadruplet_ch_combs = channel_permutations(obj.config.channels,'quadruplet');
                obj.freq_channel_combinations.quadruplet = frequency_channel_combinations(obj.config.quadruplets,quadruplet_ch_combs,...
                                                                                        obj.config.within_channels,...
                                                                                        obj.config.between_channels);    
            end       
            
            
        end
        
        function obj = setup_progression(obj, datacollection)   
            % creating arrays to detail which signals have been completed
            
            % only perform setup if they haven't previous been setup
            if obj.config.test_harmonics
                obj.progression.harmonics.completed = [];
                obj.progression.harmonics.to_run = datacollection.signal_info.signal_ids;
            end
            
            if obj.config.test_triplets
                obj.progression.triplets.completed = [];
                obj.progression.triplets.to_run = datacollection.signal_info.signal_ids;
            end 
            
            if obj.config.test_quadruplets
                obj.progression.quadruplets.completed = [];
                obj.progression.quadruplets.to_run = datacollection.signal_info.signal_ids;
            end                  
            
        end
        
        function obj = update_progression(obj, signal_id, mixing, type)
            
            % update the completed signals
            obj.progression.(type).completed = [obj.progression.(type).completed, signal_id];            
            obj.progression.(type).to_run = obj.progression.(type).to_run(~ismember(obj.progression.(type).to_run, obj.progression.(type).completed)); 
            
            % save progression in temp files
            if obj.config.save_progression
                
                % make temporary directory
                [~,~,~] = mkdir('./temp/'); 
                
                % define name of temporary file
                subfile = ['./temp/' type '_temp_s' num2str(signal_id)]; 
                
                % save the mixing results for a given signal
                save(subfile, 'mixing');  
            end
        end
        
        function [obj, mixing_array] = load_existing_mixing(obj, mixing_array, type)
            
            % find all temp files of mixing type
            folder = './temp/';
            files = dir(fullfile(folder,[type '_temp_s*.mat']));
            
            % loop over files
            for i = 1:length(files)                
                % extract string of file
                signal_id = sscanf(files(i).name, [type '_temp_s%f.mat']);                
                
                % update the progression array
                obj.progression.(type).completed = [obj.progression.(type).completed, signal_id];            
                obj.progression.(type).to_run = obj.progression.(type).to_run(~ismember(obj.progression.(type).to_run, obj.progression.(type).completed)); 
            end            

            
            % loop over all the completed mixing
            for signal_id = obj.progression.(type).completed
                subfile = ['./temp/' type '_temp_s' num2str(signal_id)]; 
                load(subfile); % loads into a variable called 'mixing'
                
                % assign to position in the mixing array
                mixing_array{signal_id} = mixing;
            end
            
        end
        

        
        function obj = check_config(obj)       
            % check all necessary details are present in config
            
        end
        
        function constructor = get_table_constructors(~,type)
            % constructors for creating the mixing tables
            
            if isequal(type, 'harmonic')
                constructor = [["Freq1", "single"]; ...
                               ["Freq2", "single"]; ...
                               ["Channel1", "int8"]; ...
                               ["Channel2", "int8"]; ...
                               ["hvalue", "single"]; ...
                               ["pvalue", "single"]; ...
                               ["teststat", "single"]; ...
                               ["quantile", "single"]; ...
                               ["hoi", "single"]; ...
                               ["clusterpvalue", "single"]];          
                
            elseif isequal(type, 'triplet')
                constructor = [["Freq1", "single"]; ...
                               ["Freq2", "single"]; ...
                               ["Freq3", "single"]; ...
                               ["Channel1", "int8"]; ...
                               ["Channel2", "int8"]; ...
                               ["Channel3", "int8"]; ...
                               ["hvalue", "single"]; ...
                               ["pvalue", "single"]; ...
                               ["teststat", "single"]; ...
                               ["quantile", "single"]; ...
                               ["hoi", "single"]; ...
                               ["type", "int8"]; ...
                               ["clusterpvalue", "single"];...
                               ["summative", "int8"]];
                           
            elseif isequal(type, 'quadruplet')                
                 constructor = [["R1", "single"]; ...
                               ["R2", "single"]; ...
                               ["E1", "single"]; ...
                               ["E2", "single"]; ...
                               ["Channel1", "int8"]; ...
                               ["Channel2", "int8"]; ...
                               ["Channel3", "int8"]; ...
                               ["Channel4", "int8"]; ... 
                               ["triplet_indexes","cell"];...
                               ["harmonic_indexes","cell"];...                          
                               ["hvalues", "cell"]; ...
                               ["pvalues", "cell"]; ...
                               ["teststats", "cell"];...
                               ["hois", "cell"];
                               ["hoi", "single"]];   
                
            end
            
        end
        
        
    end
    
    
    methods (Static)
        function remove_temp()
            rmdir('./temp/')
        end
    end

    
end

