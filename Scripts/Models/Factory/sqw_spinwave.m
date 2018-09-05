function s = sqw_spinwave(file)
% sqw_spinwave: build a SpinWave model (S. Petit/LLB)
%
% s = sqw_spinwave(file)
%
% input:
%   file: file name of a SpinWave input file
%
% output:
%   s: model [iFunc_Sqw4D]

if nargin < 1, file = ''; end
s = [];

if isempty(file)
  [filename, pathname, filterindex] = uigetfile('*.*', 'Pick a SpinWave template file');
  if isempty(filename) || isequal(filename, 0), return; end
  file = fullfile(pathname, filename);
end

% read the file content
try
  template = fileread(file);
catch ME
  disp([ mfilename ': ERROR: Can not read template ' file ]);
  return
end

% TEMPLATE ---------------------------------------------------------------------
% remove any SCAN stuff
for tok={'Q0X','Q0Y','Q0Z','WMAX','NP','DQX','DQY','DQZ','COUPE','EN0', ...
  'COUP1D','DQ1X','DQ1Y','DQ1Z','DQ2X','DQ2Y','DQ2Z','DQ3X','DQ3Y','DQ3Z', ...
  'NP1','NP2','NP3','NW'}
  template = regexprep(template, [ tok{1} '=\d+\.?\d*,?' ], '');
end
% must also remove 'FICH=filename' as we shall put our own
template = regexprep(template, 'FICH=\w+\.?\w*,?', '');
% and remove any empty lines
template = textscan(template, '%s', 'Delimiter', '\n\r'); template = strtrim(template{1});
template(cellfun(@isempty, template)) = [];
% rebuild single char
template = sprintf('%s\n', template{:});

% Search for $xx and %xx tokens in file. 
% This can include 'SIG' for excitation broadening
tokens1 = regexp(template, '\$\w*','match');
tokens1 = strrep(tokens1,   '$', '');
tokens2 = regexp(template, '\%\w*','match');
tokens2 = strrep(tokens2,   '%', '');

% Model structure --------------------------------------------------------------
[p,f] = fileparts(file);

s.Name       = [ 'SpinWave S.Petit (LLB) ' f ' [' mfilename ']' ];
s.Description= 'A spin-wave dispersion(HKL) from S. Petit';
s.Parameters = [ tokens1 tokens2 ];  % parameter names
s.Dimension  = 4;
s.Guess      = zeros(size(s.Parameters));

disp([ 'Building: ' s.Name ' from ' file ])

% store the template in the UserData
s.UserData.template = template;
s.UserData.filename = file;
s.UserData.dir      = ''; % will use temporary directory to generate files and run
s.UserData.executable = find_executable;

if isempty(s.UserData.executable)
  error([ mfilename ': SPINWAVE is not available. Install it from <http://www-llb.cea.fr/logicielsllb/SpinWave/SW.html>' ])
end

% get code to read xyzt and build HKL list and convolve DHO line shapes
script_hkl = sqw_phonons_templates;
if ismac,      precmd = 'DYLD_LIBRARY_PATH= ;';
elseif isunix, precmd = 'LD_LIBRARY_PATH= ; '; 
else           precmd = ''; end

% the Model expression, calling spinwave executable
s.Expression = { ...
  [ 'target = this.UserData.dir;' ], ...
  'if ~isdir(target), target = tempname; mkdir(target); this.UserData.dir=target; end', ...
  [ '% replace tokens as variable parameters in the template ' num2str(numel(s.Parameters)) ]...
  'template = this.UserData.template;' ...
  'for index=1:numel(this.Parameters)' ...
  '  template = strrep(template, [ ''%'' this.Parameters{index} ], num2str(p(index)));' ...
  '  template = strrep(template, [ ''$'' this.Parameters{index} ], num2str(p(index)));' ...
  'end' ...
  'template = [ template sprintf(''FICH=results.dat\n'') ];' ...
  script_hkl{:}, ...
  'xu=unique(x(:)); yu=unique(y(:)); zu=unique(z(:)); tu=unique(t(:));', ...
  'ax={xu,yu,zu}; N_id = ''XYZ'';' ...
  'dax={(max(xu)-min(xu))/numel(xu),(max(yu)-min(yu))/numel(yu),(max(zu)-min(zu))/numel(zu)};' ...
  'sz= [ numel(xu) numel(yu) numel(zu) ];', ...
  '[dummy,L_id] = min(sz);             % the smallest Q dimension (loop)', ...
  'G_id = find(L_id ~= 1:length(sz));  % the other 2 sizes in grid', ...
  'signal = zeros([ sz numel(tu) ]);' ...
  'for ie=1:numel(tu)' ...
    'templateE = [ template sprintf(''COUPE,EN0=%g,NP1=%i,NP2=%i\n'', tu(ie), numel(ax{G_id(1)}), numel(ax{G_id(2)})) ];' ...
    'volHKL = zeros(sz);' ...
    'for is=1:numel(ax{L_id})' ...
      '% starting point' ...
      'Qs = ax{L_id};' ...
      [ 'disp([ ''SpinWave EN='' num2str(tu(ie)) ' ...
        ''' Q'' num2str(L_id) ''='' num2str(Qs(is)) ' ...
        ''' Q'' num2str(G_id(1)) ''='' mat2str([min(ax{G_id(1)}) max(ax{G_id(1)}) ]) ' ...
        ''' Q'' num2str(G_id(2)) ''='' mat2str([min(ax{G_id(2)}) max(ax{G_id(2)}) ]) ])' ] ... 
      'templateHKL = [ templateE   sprintf(''Q0%c=%g\n'',N_id(L_id),Qs(is)) ];' ...
      'templateHKL = [ templateHKL sprintf(''Q0%c=%g\n'',N_id(G_id(1)),min(ax{G_id(1)}) ) ];' ...
      'templateHKL = [ templateHKL sprintf(''Q0%c=%g\n'',N_id(G_id(2)),min(ax{G_id(2)}) ) ];' ...
      '% steps: 0 for L_id' ...
      'templateHKL = [ templateHKL sprintf(''DQ1%c=%g\n'',N_id(L_id),0) ];' ...
      'templateHKL = [ templateHKL sprintf(''DQ2%c=%g\n'',N_id(L_id),0) ];' ...
      'templateHKL = [ templateHKL sprintf(''DQ1%c=%g\n'',N_id(G_id(1)),dax{G_id(1)}) ];' ...
      'templateHKL = [ templateHKL sprintf(''DQ2%c=%g\n'',N_id(G_id(1)),0) ];' ...
      'templateHKL = [ templateHKL sprintf(''DQ1%c=%g\n'',N_id(G_id(2)),0) ];' ...
      'templateHKL = [ templateHKL sprintf(''DQ2%c=%g\n'',N_id(G_id(2)),dax{G_id(2)}) ];' ...
      '% execute' ...
      '% write the spinwave input file' ...
      'try' ...
        'fid = fopen(fullfile(target, ''input.txt''), ''w'');' ...
        'fprintf(fid, ''%s'', templateHKL);' ...
        'fclose(fid)' ...
        [ 'cmd = [ ''' precmd s.UserData.executable ' < '' fullfile(target,''input.txt'') '' > '' fullfile(target,''spinwave.log'') ];' ] ...
        [ '[status,result] = system(cmd);' ], ...
        '% get result 5th column and catenate' ...
        'cut2D = load(fullfile(target, ''results.dat''),''-ascii'');' ...
        'cut2D = cut2D(:,5);' ...
      'catch ME; disp(fileread(fullfile(target,''spinwave.log''))); ', ...
        'disp([ ''model '' this.Name '' '' this.Tag '': FAILED running SPINWAVE'' ]);' ...
        'disp([ ''  from '' target ]);' ...
        'disp(getReport(ME)); return', ...
      'end', ...
      'if     L_id == 1, volHKL(is,:,:) = cut2D;' ...
      'elseif L_id == 2, volHKL(:,is,:) = cut2D;' ...
      'else              volHKL(:,:,is) = cut2D; end' ...
    'end' ...
    'signal (:,:,:,ie) = volHKL;' ...
  'end' ...
  };


% build the iFunc
s = iFunc(s);
s = iFunc_Sqw4D(s); % overload Sqw4D flavour

end % sqw_spinwave

% ------------------------------------------------------------------------------

function executable = find_executable
  % find_executable: locate executable, return it
  
  % stored here so that they are not searched for further calls
  persistent found_executable
  
  if ~isempty(found_executable)
    executable = found_executable;
    return
  end
  
  if ismac,      precmd = 'DYLD_LIBRARY_PATH= ;';
  elseif isunix, precmd = 'LD_LIBRARY_PATH= ; '; 
  else           precmd=''; end
  
  if ispc, ext='.exe'; else ext=''; end
  
  executable  = [];
  this_path   = fullfile(fileparts(which(mfilename)));
  
  % what we may use
  for exe =  { 'spinwave', 'spinwave2p2', [ 'spinwave_' computer('arch') ] }
    if ~isempty(executable), break; end
    for try_target={ ...
      fullfile(this_path, [ exe{1} ext ]), ...
      fullfile(this_path, [ exe{1} ]), ...
      [ exe{1} ext ], ... 
      fullfile(this_path, 'private', [ exe{1} ext ]), ...
      fullfile(this_path, 'private', [ exe{1} ]), ...
      exe{1} }
      
      [status, result] = system([ precmd try_target{1} ]);

      if status ~= 127
        % the executable is found
        executable = try_target{1};
        disp([ mfilename ': found ' exe{1} ' as ' try_target{1} ])
        break
      end
    end
  
  end
  
  if isempty(executable)
    executable = compile_spinwave;
  end
  
  found_executable = executable;
  
end % find_executable

% ------------------------------------------------------------------------------
function executable = compile_spinwave
  % compile spinwave 2.2 from S. Petit LLB
  executable = '';
  if ismac,      precmd = 'DYLD_LIBRARY_PATH= ;';
  elseif isunix, precmd = 'LD_LIBRARY_PATH= ; '; 
  else           precmd=''; end
  
  if ispc, ext='.exe'; else ext=''; end

  % search for a fortran compiler
  fc = '';
  for try_fc={getenv('FC'),'gfortran','g95','pgfc','ifort'}
    if ~isempty(try_fc{1})
      [status, result] = system([ precmd try_fc{1} ]);
      if status == 4 || ~isempty(strfind(result,'no input file'))
        fc = try_fc{1};
        break;
      end
    end
  end
  if isempty(fc)
    if ~ispc
      disp([ mfilename ': ERROR: FORTRAN compiler is not available from PATH:' ])
      disp(getenv('PATH'))
      disp([ mfilename ': Try again after extending the PATH with e.g.' ])
      disp('setenv(''PATH'', [getenv(''PATH'') '':/usr/local/bin'' '':/usr/bin'' '':/usr/share/bin'' ]);');
    end
    error('%s: Can''t find a valid Fortran compiler. Install any of: gfortran, g95, pgfc, ifort\n', ...
    mfilename);
  end
  
  % when we get there, target is spinwave_arch, not existing yet
  this_path = fileparts(which(mfilename));
  target = fullfile(this_path, 'private', [ 'spinwave_' computer('arch') ext ]);

  % attempt to compile as local binary
  if isempty(dir(fullfile(this_path,'private','spinwave'))) % no executable available
    fprintf(1, '%s: compiling binary...\n', mfilename);
    % gfortran -o spinwave -O2 -static spinwave.f90
    cmd = {fc, '-o', target, '-O2', '-static', ...
       fullfile(this_path,'private', 'spinwave.f90')}; 
    disp([ sprintf('%s ', cmd{:}) ]);
    [status, result] = system([ precmd sprintf('%s ', cmd{:}) ]);
    if status ~= 0 % not OK, compilation failed
      disp(result)
      warning('%s: Can''t compile spinwave.f90 as binary\n       in %s\n', ...
        mfilename, fullfile(this_path, 'private'));
    else
      delete(fullfile(this_path,'private', '*.mod'));
      executable = target;
    end
  end
  
end % compile_spinwave
