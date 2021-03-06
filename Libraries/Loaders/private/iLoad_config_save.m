function config = iLoad_config_save(config)
% iLoad_config_save: save the configuration and format customization
  data = config.loaders;
  format_names  ={};
  format_methods={};
  format_unique =ones(1,length(data));
  % remove duplicated format definitions
  for index=1:length(data)
    if ~isempty(data{index}.name) ...
      && any(strncmpi(data{index}.name,   format_names,   length(data{index}.name))) ... 
      && any(strncmpi(data{index}.method, format_methods, length(data{index}.method)))
      format_unique(index) = 0; % already exists. Skip it.
      format_names{index}  = '';
      format_methods{index}= '';
    else
      format_names{index} = data{index}.name;
      format_methods{index} = data{index}.method;
    end
  end
  data = data(find(format_unique));
  config.loaders = data;
  % save iLoad.ini configuration file
  % make header for iLoad.ini
  config.FileName=fullfile(prefdir, 'iLoad.ini'); % store preferences in PrefDir (Matlab)
  NL = sprintf('\n');
  str = [ '% iLoad configuration script file ' NL ...
          '%' NL ...
          '% Matlab ' version ' m-file ' config.FileName NL ...
          '% generated automatically on ' datestr(now) ' with iLoad('''',''save config'');' NL ...
          '%' NL ...
          '% The configuration may be specified as:' NL ...
          '%     config = { format1 .. formatN }; (a single cell of format definitions, see below).' NL ...
          '%   OR a structure' NL ...
          '%     config.loaders = { format1 .. formatN }; (see below)' NL ...
          '%     config.UseSystemDialogs=''yes'' to use built-in Matlab file selector (uigetfile)' NL ...
          '%                             ''no''  to use iLoad file selector           (uigetfiles)' NL ...
          '%' NL ...
          '% User definitions of specific import formats to be used by iLoad' NL ...
          '% Each format is specified as a structure with the following fields' NL ...
          '%   method:   function name to use, called as method(filename, options...)' NL ...
          '%   extension:a single or a cellstr of extensions associated with the method' NL ...
          '%   patterns: list of strings to search in data file. If all found, then method' NL ...
          '%             is qualified. The patterns can be regular expressions.' NL ...
          '%             When given as a string, the file is assumed to contain "text" data.' NL ...
          '%   name:     name of the method/format' NL ...
          '%   options:  additional options to pass to the method.' NL ...
          '%             If given as a string they are catenated with file name' NL ...
          '%             If given as a cell, they are given to the method as additional arguments' NL ...
          '%   postprocess: function called from iData/load after file import, to assign aliases, ...' NL ...
          '%             called as iData=postprocess(iData)' NL ...
          '%' NL ...
          '% all formats must be arranged in a cell, sorted from the most specific to the most general.' NL ...
          '% Formats will be tried one after the other, in the given order.' NL ...
          '% System wide loaders are tested after user definitions.' NL ...
          '%' NL ...
          '% NOTE: The resulting configuration must be named "config"' NL ...
          '%' NL ...
          class2str('config', config) ];
  [fid, message]=fopen(config.FileName,'w+');
  if fid == -1
    warning(['Error opening file ' config.FileName ' to save iLoad configuration.' ]);
    config.FileName = [];
  else
    fprintf(fid, '%s', str);
    fclose(fid);
    disp([ '% Saved iLoad configuration into ' config.FileName ]);
  end
  
end % iLoad_config_save
