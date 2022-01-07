classdef textfilelogger < freqmix.logging.base_logger
    % TEXTFILELOGGER  LOGGER class that prints to a text file
    %
    %   class  textfilelogger  is inhereted from class logger and
    %   implements a logger that prints all information to
    %   a (temporary) file in text mode.
    %
    % Methods:
    %   oTL = textfilelogger(filename, overwrite)  instantiate a textfilelogger object
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
    %   oTL.filename  the name of the logging file (read-only)
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
        filename = '';  % name of logging file
    end
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    properties (SetAccess = protected, GetAccess = protected)
        filehandle = [];
    end
    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    methods
        
        function obj = textfilelogger(filename, overwrite)
            if nargin<1
                filename = [tempname(), '.txt'];
            end
            obj.filename = filename;
            if nargin>1 && overwrite
                obj.filehandle = fopen(obj.filename, 'wt');
            else
                obj.filehandle = fopen(obj.filename, 'at');
            end
            obj.level = 0;
        end
        
        function str = log(obj, str)
            fprintf(obj.filehandle, [repmat('\t',[1, obj.level]),'%s\n'], str);
        end
        
        function delete(obj)
            fclose(obj.filehandle);
        end
        
    end
    
end


