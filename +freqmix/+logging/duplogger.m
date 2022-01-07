classdef duplogger < freqmix.logging.base_logger
    % DUPLOGGER  LOGGER class that duplicates logs to multiple loggers
    %
    %   class  duplogger  is inhereted from class logger and
    %   implements a logger that duplicates and prints all information to
    %   multiple loggers.
    %
    % Methods:
    %   oTL = duplogger(filename, overwrite)  instantiate a textfilelogger object
    %
    %         filename  is the name of the logging file, and defaults to a
    %         temporary name if it is not given
    %
    %         overwrite  denotes whether the potentially existing content of
    %         the logging file should be overwritten, defaults to false.
    %
    %   str = oTL.log(str)    print log information to file
    %   delete(oTL)           delete textfilelogger object and closes file
    %
    % Properties:
    %
    % File information:
    %   version 1.0 (feb 2014)
    %   (c) Martin Vogel
    %   email: matlab@martin-vogel.info
    %
    % Revision history:
    %   1.0 (feb 2014) initial release version
    %
    % See also:
    %   displogger, filelogger, logger
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    properties (SetAccess = public, GetAccess = public)
    end
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    properties (SetAccess = protected, GetAccess = public)
        loggers = {};
    end
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    properties (SetAccess = protected, GetAccess = protected)
    end
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    methods
        
        function obj = duplogger(loggers) 
            % instantiate duplogger object
            if nargin < 1
                obj.loggers = {};
            else
                obj.loggers = loggers;
            end
        end
        
        function levels = push(obj)
            % push  push level of all connected loggers by one
            for oi=1:length(obj.loggers)
                levels(oi) = obj.loggers{oi}.push(); %#ok<AGROW>
            end
        end
        
        function levels = pop(obj)
            % pop  pop level of all connected loggers by one
            for oi=1:length(obj.loggers)
                levels(oi) = obj.loggers{oi}.pop(); %#ok<AGROW>
            end
        end
        
        function strs = log(obj, str)
            % log  print information to all connected loggers 
            for oi=1:length(obj.loggers)
                strs{oi} = obj.loggers{oi}.log(str); %#ok<AGROW>
            end
        end
        
        function delete(obj)
            % delete  delete duplogger object
            obj.loggers = {};
        end
        
    end
    
end


