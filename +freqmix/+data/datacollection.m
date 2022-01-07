classdef datacollection
    %DATACOLLECTION A class for collecting all data associated with an
    %experiment
    %  Data of any type is parsed to the data collection. The data is then
    %  parsed to a data table which can then be parsed to other functions
    %  and classes for frequency mixing analysis.
    
    properties
        name = '' % string
        date_created = date % string

        data = table; % table
        data_type = 'undefined' % string
        
        signal_info = struct('n_signals',0,'signal_ids',[],'signal_names',{})
        sample_info = struct('n_samples',0,'sample_ids',[],'sample_names',{})
        group_info = struct('n_groups',0,'group_ids',[],'group_names',{})  
        channel_info = struct('n_channels',0,'channel_ids',[],'channel_names',{}) 

        timeseries_length = 0; % int
        
        generate_surrogate = false;
        
        metadata = table; % Table
        
        config = freqmix.config.config_data % config object for datacollection
        
        logger % logger object
        
        table_constructor = {} % column names for data table
       
    end
    
    methods
        function obj = datacollection(data, varargin)
            %DATACOLLECTION Construct an instance of this class
            %   Initialise this object by loading data
            
            
            obj = obj.parse_data(data);
            obj = obj.update_info();
            obj = obj.parse_varargin(varargin);
            
            obj = obj.generate_surrogate_data();
        end
        
       
        function obj = parse_data(obj,data)
            % load data into datacollection
            obj = obj.check_data(data);
            obj = obj.extract_info(data);
            
            obj.data = obj.construct_data_table();  
            obj = obj.extract_data(data);
            obj = obj.set_data_columns();
            
        end
        
        function data_table = construct_data_table(obj)
            % create empty data table
            constructor = [["signal_id", "int8"]; ...
                           ["signal_name", "string"]; ...
                           ["sample_id", "int8"]; ...
                           ["sample_name", "string"]; ...
                           ["group_id", "int8"]; ...
                           ["group_name", "string"]; ...
                           ["data", "cell"]; ...
                           ["channel_names", "cell"];
                           ["sampling_frequency", "single"];
                           ["delta_t", "single"];
                           ["spectrum", "cell"];
                           ["metadata", "single"]];
                                
            data_table = table('Size',[obj.signal_info.n_signals,size(constructor,1)],... 
                        'VariableNames', constructor(:,1),...
                        'VariableTypes', constructor(:,2));   
                    
            obj.table_constructor = constructor;
        end
        
        function obj = check_data(obj,data)
            % check to confirm data is of right type
            if ~iscell(data)
                error('Parsed data is not a cell array')
            end
            
        end
        
        function obj = extract_info(obj,data)
            % extract info about data
            [n_rows, n_columns] = size(data{1});            
            obj.signal_info(1).n_signals = length(data);            
            obj.timeseries_length = max(n_rows,n_columns);
            obj.channel_info(1).n_channels = min(n_rows,n_columns); 
            
            obj.signal_info(1).signal_ids = int8(1:obj.signal_info.n_signals);
            obj.sample_info(1).sample_ids = int8(1:obj.signal_info.n_signals);
            obj.group_info(1).group_ids = int8(zeros(1,obj.signal_info.n_signals));
            
%             obj.signal_info(1).signal_names = cellstr(string(obj.signal_info.signal_ids));
%             obj.sample_info(1).sample_names = cellstr(string(obj.sample_info.sample_ids));
%             obj.group_info(1).group_names = cellstr(string(obj.group_info.group_ids));
%             
        end
        
        
        function obj = extract_data(obj,data)
            % extract data and put in table
            for i = 1:obj.signal_info.n_signals
                if strcmp(obj.config.precision,'single')
                    obj.data{i,'data'} = {single(data{i})};
                else
                    obj.data{i,'data'} = data(i);                   
                end
            end     
        end
        
        function obj = set_data_columns(obj)
            % update data table with signal data
            
            obj.data(:,'signal_id') = num2cell(obj.signal_info.signal_ids)';
            obj.data(:,'sample_id') = num2cell(obj.sample_info.sample_ids)';
            obj.data(:,'group_id') = num2cell(obj.group_info.group_ids)';
            
            if ~isempty(obj.signal_info.signal_names)
                obj.data(:,'signal_name') = obj.signal_info.signal_names';
            end
            if ~isempty(obj.sample_info.sample_names)
                obj.data(:,'sample_name') = obj.sample_info.sample_names';
            end
            if ~isempty(obj.group_info.group_names)
                obj.data(:,'group_name') = obj.group_info.group_names';   
            end
            if ~isempty(obj.metadata)
                if ~iscell(obj.metadata)
                   obj.metadata = num2cell(obj.metadata); 
                end    
                obj.data(:,'metadata') = obj.metadata';
            end
        end

        
        function obj = update_info(obj)
            
            obj.signal_info(1).n_signals = length(obj.signal_info.signal_ids);
            obj.sample_info(1).n_samples = length(obj.sample_info.sample_ids);
            obj.group_info(1).n_groups = length(obj.group_info.group_ids);
            obj.channel_info(1).n_channels = length(obj.channel_info.channel_ids);
           
        end
        
        function obj = generate_surrogate_data(obj)
            % generating surrogate data from original signals
            
            if obj.generate_surrogate
                
                surrogate_table = obj.construct_data_table();
                for i = 1:height(obj.data)
                    signal = obj.data.data{i};
                    surrogate_signal = freqmix.data.surrogate.generate_surrogate_signal(signal);
                    surrogate_table.data{i} = surrogate_signal;
                    
                    surrogate_table.sample_id(i) = obj.data.sample_id(i);

                    surrogate_table.signal_id(i) = obj.data.signal_id(i) + obj.signal_info.n_signals;
                    surrogate_table.signal_name(i) = obj.data.signal_name(i)+'_surrogate';
                    
                    surrogate_table.sample_id(i) = obj.data.sample_id(i);
                    surrogate_table.sample_name(i) = obj.data.sample_name(i);
                    
                    surrogate_table.group_id(i) = obj.data.group_id(i) + max(obj.group_info.group_ids);
                    surrogate_table.group_name(i) = obj.data.group_name(i)+'_surrogate';
                    
                    
                end
                
                surrogate_table.channel_names = obj.data.channel_names;
                surrogate_table.sampling_frequency = obj.data.sampling_frequency;
                surrogate_table.delta_t = obj.data.delta_t;
                surrogate_table.metadata = obj.data.metadata;
  
                obj.data = [obj.data;surrogate_table];
                
            end
           
        end
       
       
        function obj = parse_varargin(obj,arguments)            
          
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'name',obj.name,@ischar); % add name
            addParameter(p,'data_type',obj.data_type,@ischar); % add data type 
            addParameter(p,'metadata',obj.metadata); % add metadata            
            addParameter(p,'logger',obj.logger); % add logger
            addParameter(p,'config',obj.config); % add config
            addParameter(p,'generate_surrogate',obj.generate_surrogate); % generate surrogate
            parse(p,arguments{:});             
            for i = 1:length(p.Parameters)
                obj.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end
            
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'signal_ids',obj.signal_info.signal_ids); % add signal ids
            addParameter(p,'signal_names',obj.signal_info.signal_names); % add signal names
            parse(p,arguments{:});             
            for i = 1:length(p.Parameters)
                obj.signal_info.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end
            if isempty(obj.signal_info.signal_names)
                obj.signal_info(1).signal_names = cellstr(string(obj.signal_info.signal_ids));
            end
            
            
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'sample_ids',obj.sample_info.sample_ids); % add sample ids
            addParameter(p,'sample_names',obj.sample_info.sample_names); % add sample names   
            parse(p,arguments{:});             
            for i = 1:length(p.Parameters)
                obj.sample_info.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end
            if isempty(obj.sample_info.sample_names)
                obj.sample_info(1).sample_names = cellstr(string(obj.sample_info.sample_ids));
            end
            
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'group_ids',obj.group_info.group_ids); % add group ids
            addParameter(p,'group_names',obj.group_info.group_names); % add group names    
            parse(p,arguments{:});             
            for i = 1:length(p.Parameters)
                obj.group_info.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end
            if isempty(obj.group_info.group_names)
                obj.group_info(1).group_names = cellstr(string(obj.group_info.group_ids));       
            end
            
            p = inputParser;p.KeepUnmatched=true;
            addParameter(p,'channel_names',obj.channel_info.channel_names); % add channel names    
            parse(p,arguments{:});             
            for i = 1:length(p.Parameters)
                obj.channel_info.(p.Parameters{i}) = p.Results.(p.Parameters{i});
            end            
            
            obj = obj.set_data_columns();
            
        end
        
    end
end


