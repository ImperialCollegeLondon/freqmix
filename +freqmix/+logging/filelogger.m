classdef filelogger < freqmix.logging.base_logger
    % FILELOGGER  LOGGER class that prints to a file
    %
    %   class  filelogger  is inhereted from class logger and
    %   implements a logger that prints all information to
    %   a (temporary) file in binary mode.
    %
    % Methods:
    %   oFL = filelogger(filename, overwrite)   instantiate a filelogger object
    %
    %         filename  is the name of the logging file, and defaults to a
    %         temporary name if it is not given
    %
    %         overwrite  denotes whether the potentially existing content of
    %         the logging file should be overwritten, defaults to false.
    %
    %   str = oFL.log(str)    print log information to file
    %   delete(oFL)           delete filelogger object and closes file
    %
    % Properties:
    %   oFL.filename  the name of the logging file (read-only)
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
    %   displogger, textfilelogger, logger
   
    
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
        
        function obj = filelogger(filename, overwrite)
            % instantiate a filelogger object
            if nargin<1
                filename = [tempname(), '.log'];
            end
            obj.filename = filename;
            if nargin>1 && overwrite
                obj.filehandle = fopen(obj.filename, 'w');
            else
                obj.filehandle = fopen(obj.filename, 'a');
            end
            obj.level = 0;
        end
        
        function str = log(obj, str)
            % log  print log information to file
            fprintf(obj.filehandle, [repmat('\t',[1, obj.level]),'%s'], str);
        end
        
        function delete(obj)
            % delete  delete filelogger object
            fclose(obj.filehandle);
        end
        
    end
    
end


