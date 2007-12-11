function b = subsasgn(a,S,val)
% b = subsasgn(a,index,b) : iData indexed assignement
%
%   @iData/subsasgn: function defines indexed assignement 
%   such as a(1:2,3) = b
%   The special syntax a{0} assigns the signal, and a{n} assigns the axis of rank n.
%     When the assigned value is a char, the axis definition is set (as in setaxis).
%     When the assigned value is numeric, the axis value is set (as in set).
%   The special syntax a{'alias'} is a quick way to define an alias.
%
% See also iData, iData/subsref

% This implementation is very general, except for a few lines
% EF 27/07/00 creation
% EF 23/09/07 iData implementation

b = a;  % will be refined during the index level loop

if isempty(S)
  return
end

% first handle object array for first index
if length(b(:)) > 1 & (strcmp(S(1).type,'()') | strcmp(S(1).type,'{}'))
  c = b(S(1).subs{:});
  d = c(:);
  for j = 1:length(d)
    d(j) = subsasgn(d(j),S(2:end),val);
  end
  if prod(size(c)) ~= 0 & prod(size(c)) == prod(size(d))
    c = reshape(d, size(c));
  else
    c = d;
  end
  b(S(1).subs{:}) = c;
else
  i = 0;
  while i < length(S)     % can handle multiple index levels
    i = i+1;
    s = S(i);
    switch s.type
    case '()'               % set Data using indexes (val must be num)
      if length(b(:)) > 1   % class array -> deal on all elements
        c = b(:);
        for j = 1:length(s.subs{:})
          c(j) = subsasgn(c(j),s,val);
        end
        b = reshape(c, size(b));
      else                  % single object
        % this is where specific class structure is taken into account
        d = get(b, 'Signal');
        d(s.subs{:}) = val;
        b = set(b, 'Signal', d);
        if isempty(val) % remove columns/rows in data: Update Error, Monitor and Axes
          for index=1:ndims(b)
            x = getaxis(b,index);
            if all(size(x) == size(b)) % meshgrid type axes
              x(s.subs{:}) = [];
              b = setaxis(b, index, x);
            else  % vector type axes
              x(s.subs{index}) = [];
            end
          end
        end
        
        % add command to history
        toadd = '(';
        if ~isempty(inputname(2))
          toadd = [ toadd inputname(2) ];
        elseif length(s.subs) == 1
          toadd = [ toadd mat2str(s.subs{1}) ];
        else
          toadd = [ toadd mat2str(s.subs{1}) ', ' mat2str(s.subs{2}) ];
        end
        toadd = [ toadd ') = ' ];
        if ~isempty(inputname(3))
          toadd = [ toadd inputname(3) ];
        elseif ischar(val)
          toadd = [ toadd '''' val '''' ];
        elseif isnumeric(val) | islogical(val)
          if length(size(val)) > 2, val=val(:); end
          if numel(val) > 100, val=val(1:100); end
          toadd = [ toadd mat2str(val) ];
        else
          toadd = [ toadd  '<not listable>' ];
        end
        if ~isempty(inputname(1))
          toadd = [ inputname(1) toadd ';' ];
        else
          toadd = [ a.Tag toadd ';' ];
        end
        b = iData_private_history(b, toadd);
        % final check
        b = iData(b);
      end                 % if single object
    case '{}'
      if length(b(:)) > 1   % object array -> deal on all elements
        c = b(:);
        for j = 1:length(c)
          c(j) = subsasgn(c(j),s,val);
        end
        b = reshape(c, size(b));
      else
        if isnumeric(s.subs{:}) & length(s.subs{:}) == 1
          if s.subs{:} == 0 & ischar(val)
            iData_private_error(mfilename, [ 'Can not redefine Axis 0-th Signal in object ' inputname(1) ' ' b.Tag ]);
          end
          if s.subs{:} <= length(b.Alias.Axis)
            ax= b.Alias.Axis{s.subs{:}}; % definition of Axis
          else 
            if ~ischar(val)
            iData_private_error(mfilename, [ num2str(s.subs{:}) '-th rank Axis  has not been defined yet, and can not be assigned in object ' inputname(1) ' ' b.Tag ]);
            end
            ax=s.subs{:}; 
          end
          if ischar(val), b = setaxis(b, s.subs{:}, val);
          else b = set(b, ax, val); end
        elseif ischar(s.subs{:}) & isnumeric(str2num(s.subs{:}))
          b=setaxis(b, s.subs{:}, val);
        elseif ischar(s.subs{:})
          b=setalias(b, s.subs{:}, val);
        else
          b{s.subs{:}} = val;       
        end
      end
    case '.'
      if length(b(:)) > 1   % object array -> deal on all elements
        c = b(:);
        for j = 1:length(c)
          c(j) = subsasgn(c(j),s,val);
        end
        b = reshape(c, size(b));
      else
        if i < length(S)
          next_s = S(i+1);
          if strcmp(next_s.type, '()') | strcmp(next_s.type, '{}')
            tmp = get(b,s.subs);
            tmp(next_s.subs{:}) = val;
            b = set(b, s.subs, tmp);
            i = i + 2;  % jump next
          else
            if strcmp(next_s.type, '.')
              c = getfield(b, s.subs);
              c = setfield(c, next_s.subs, val);
              b = setfield(b, s.subs, c);
              i = i+1;
            else
              iData_private_error(mfilename, [ 'can not handle ' next_s.type ' type subscript for object ' inputname(1) ' ' b.Tag ]);
            end
          end
        else
          b = set(b,s.subs,val);    % set field
        end
      end
    end   % switch s.type
  end % while s index level
  
end
