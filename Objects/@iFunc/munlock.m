function a = munlock(a, varargin)
% b = munlock(s, parameters, ...) : free parameter lock (clear) for further fit using the model 's'
%
%   @iFunc/munlock unlock model parameters during further fit process.
%     to unlock/clear a parameter model, use munlock(model, parameter)
%
%   munlock(model, {Parameter1, Parameter2, ...})
%     unlock/free parameter for further fits
%   munlock(model)
%     display free parameters
%
% input:  s: object or array (iFunc)
% output: b: object or array (iFunc)
% ex:     b=munlock(a,'Intensity');
%
% Version: $Revision: 1.1 $
% See also iFunc, iFunc/fits, iFunc/mlock, iFunc/xlim

% calls subsasgn with 'clear' for each parameter given

% handle array of objects
if numel(a) > 1
  for index=1:numel(a)
    a(index) = feval(mfilename, a(index), varargin{:});
  end
  if nargout == 0 && ~isempty(inputname(1)) % update array inplace
    assignin('caller', inputname(1), a);
  end
  return
end

if nargin == 1 % display free parameters
  count = 0;
  if ~isempty(a.Parameters)
    for p=1:length(a.Parameters)
      [name, R] = strtok(a.Parameters{p}); % make sure we only get the first word (not following comments)
      
      if length(a.Constraint.fixed) >=p && ~a.Constraint.fixed(p)
        if (count == 0)
          fprintf(1, 'Unlocked/Free Parameters in %s %iD model "%s"\n', a.Tag, a.Dimension, a.Name)
        end
        count = count +1;
        fprintf(1,'%20s (free)\n', name);
      end
    end
  end
  if count == 0
    fprintf(1, 'No unlocked/free Parameters in %s %iD model "%s"\n', a.Tag, a.Dimension, a.Name);
  end
  return
end

% handle multiple parameter name arguments
if length(varargin) > 1
  for index=1:length(varargin)
    a = feval(mfilename, a, varargin{index});
  end
  return
else
  name = varargin{1};
end

% now with a single input argument
if ~ischar(name) && ~iscellstr(name)
  error([ mfilename ': can not unlock model parameters with a Parameter name if class ' class(name) ' in iFunc model ' a.Tag '.' ]);
end

if ischar(name), name = cellstr(name); end
% now with a single cellstr
for index=1:length(name)
  s    = struct('type', '.', 'subs', name{index});
  a = subsasgn(a, s, 'clear');
end

if nargout == 0 && ~isempty(inputname(1))
  assignin('caller',inputname(1),a);
end
