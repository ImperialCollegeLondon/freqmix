classdef plotter
    %PLOTTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        config
    end
    
    methods
        function obj = plotter(config)
            %PLOTTER Construct an instance of this class
            %   Detailed explanation goes here
            obj.config = config;
        end
        
        function [] = run(obj, statistics)
            %METHOD1 Summary of this method goes here
            
            obj.check_folder(obj.config.folder)
            
            % plot harmonics
            obj.plot_mixing(statistics.harmonic_statistics, 'harmonics/')            
            
            % plot triplets
            obj.plot_mixing(statistics.triplet_statistics, 'triplets/')            
            
            % plot quadruplets
            obj.plot_mixing(statistics.quadruplet_statistics, 'quadruplets/')
 
            
        end
        
        function check_folder(obj,folder)
            if obj.config.saveplot
                if ~isfolder(folder)
                    mkdir(folder)
                end
            end
        end
             
        
        function plot_mixing(obj, statistics, sub_type)
            import freqmix.plotting.*
            
            sub_folder = [obj.config.folder,sub_type];
            obj.check_folder(sub_folder);
            
            if ~isempty(statistics.individual_test)
                for i = 1:size(statistics.individual_test,1)
                    individual = ['individual_test_',num2str(i)];
                    folder = char(join([sub_folder,'group_test/',comparison,'/'],''));
                    obj.check_folder(folder);
                    if ~isempty(statistics.individual_test{i})
                        plot_mixing(statistics.individual_test{i},'config',obj.config,'folder',folder)
                    end
                    
                end
            end
            
            if ~isempty(statistics.group_test)
                for i = 1:size(statistics.group_test,1)
                    comparison = [statistics.group_test{i,1},'_vs_',statistics.group_test{i,2}];
                    folder = char(join([sub_folder,'group_test/',comparison,'/'],''));
                    obj.check_folder(folder);
                    if ~isempty(statistics.group_test{i,3})
                        plot_mixing(statistics.group_test{i,3},'config',obj.config,'folder',folder)
                    end
                    
                end
            end            
            
            if ~isempty(statistics.regression_test)
                for i = 1:size(statistics.regression_test,1)
                    direction = statistics.regression_test{i,1};
                    folder = char(join([sub_folder,'group_test/',comparison,'/'],''));
                    obj.check_folder(folder);
                    if ~isempty(statistics.regression_test{i,2})
                        plot_mixing(statistics.regression_test{i,2},'config',obj.config,'folder',folder)
                    end
                    
                end             
            end            
            
            if ~isempty(statistics.surrogate_test)
                % not yet implemented - instead generating surrogates and
                % group testing
            end    
            
        end
        
    end
end

