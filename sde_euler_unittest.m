function sde_euler_unittest(tests)
%SDE_EULER_UNITTEST  Suite of unit tests for SDE_EULER solver function.
%   SDE_EULER_UNITTEST will perform all tests. Detailed feedback is provided if
%   any of the tests fail. See code (type 'edit SDE_EULER_UNITTEST' in the
%   command window) for test details or to add additional tests. The SDELab
%   Toolbox must be on the Matlab path or in the same directory as this
%   function.
%
%   SDE_EULER_UNITTEST(TESTS) where TESTS = [N1 N2 ... NM] is a vector of
%   specific test numbers (indices, 1 ... N) to run. This capability is useful
%   for rerunning a particular test after a failure. If multiple test numbers
%   are specified, they may be listed in any order, but they will be evaluated
%   in ascending order.
%
%   Not part of the the SDELab Toolbox; used only for development.
%   
%   See also: SDE_EULER, SDEARGUMENTS, SDE_EULER_BENCHMARK, SDE_EULER_VALIDATE,
%       SDE_MILSTEIN_UNITTEST

%   Andrew D. Horchler, adh9@case.edu, Created 12-20-11
%   Revision: 1.0, 4-4-12


% make sure toolbox on path, otherwise ensure we're in right location and add it
if strfind(path,'SDELab')
    if exist('sde_euler','file') ~= 2
        error(  'SDELab:sde_euler_unittest:FunctionNotFound',...
               ['The SDELab Toolbox is appears to be on the Matlab path, '...
                'but the SDE_EULER solver function cannot be found.']);
    end
    pathadded = false;
else
    if exist('SDELab','dir') ~= 7
        error(  'SDELab:sde_euler_unittest:ToolboxNotFound',...
               ['The SDELab Toolbox is not be on the Matlab path and the '...
                'root directory of the of the toolbox, SDELab, is in the '...
                'same directory as this function.']);
    end
    addpath SDELab
    if exist('sde_euler','file') ~= 2
        rmpath SDELab
        error(  'SDELab:sde_euler_unittest:FunctionNotFoundAfterAdd',...
               ['The SDELab Toolbox was added to the Matlab path, but the '...
                'SDE_EULER solver function cannot be found.']);
    end
    pathadded = true;   % we'll reset path at end
end

% validate input argument if it exists
if nargin == 1
    if isempty(tests) || ~isnumeric(tests) || ~all(isfinite(tests))
        error('SDELab:sde_euler_unittest:InvalidArgument','Invalid argument.');
    end
    if any(tests < 1)
        error(  'SDELab:sde_euler_unittest:NotAnIndex',...
                'Tests are numbered as indices, from 1 to N.');
    end
    runtests = true;
    tests = floor(tests);
else
    runtests = false;
end

lnum1 = cell(71,1);
cmd = cell(71,1);
msg = cell(71,1);

lnum = cell(234,1);
f = cell(234,1);
g = cell(234,1);
tspan = cell(234,1);
y0 = cell(234,1);
opts = cell(234,1);
params = cell(234,1);
twoout = cell(234,1);


% error tests:

% number of arguments:

% only one function
st = dbstack;
i = 1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sde_euler:NotEnoughInputs';

% only one function with options
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,0:0.1:1,0,sdeset(''SDEType'',''Ito''));';
msg{i} = 'SDELab:sde_euler:NotEnoughInputsOptions';

% no tspan
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0);';
msg{i} = 'SDELab:sde_euler:NotEnoughInputs';

% no tspan with options
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0,sdeset(''SDEType'',''Ito''));';
msg{i} = 'SDELab:sde_euler:NotEnoughInputsOptions';

% no ICs
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1);';
msg{i} = 'SDELab:sde_euler:NotEnoughInputs';


% f:

% not a valid input, not []
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler('''',@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:InvalidFFUN';

% not a valid input, not float
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(uint8(0),@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:InvalidFFUN';

% not a valid input, not a matrix
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(ones(2,2,2),@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:InvalidFFUN';

% function doesn't exist
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@ff,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'MATLAB:UndefinedFunction';

% state argument not defined
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t)x+1,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNTooFewInputs';

% state output not specified
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@f1,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNNoOutput';

% state output not assigned in function
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@f2,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNUnassignedOutput';

% too many inputs required
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x,a)a*x+1,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNTooManyInputs';

% state output smaller
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x(1)+1,@(t,x)x+1,0:0.1:1,[0 0]);';
msg{i} = 'SDELab:sdearguments:FFUNDimensionMismatch';

% state output larger
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)[x;x]+1,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNDimensionMismatch';

% state output not a matrix
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)rand(1,1,2)+1,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNNotColumnVector';

% state output not a colum vector
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)[x,x]+1,@(t,x)x+1,0:0.1:1,[0 0]);';
msg{i} = 'SDELab:sdearguments:FFUNNotColumnVector';

% state output not non-empty
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)[],@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNNotColumnVector';

% state output not float
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)uint8(x)+1,@(t,x)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:FFUNNotColumnVector';


% g:

% not a function handle
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,'''',0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:InvalidGFUN';

% not a valid input, not float
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,uint8(0),0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:InvalidGFUN';

% not a valid input, not a matrix
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,ones(2,2,2),0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:InvalidGFUN';

% function doesn't exist
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@gg,0:0.1:1,0);';
msg{i} = 'MATLAB:UndefinedFunction';

% state argument not defined
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t)x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNTooFewInputs';

% state output not specified
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@g1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNNoOutput';

% state output not assigned in function
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@g2,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNUnassignedOutput';

% too many inputs required
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x,a)a*x+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNTooManyInputs';

% state output smaller
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x(1:2)+1,0:0.1:1,[0,0,0]);';
msg{i} = 'SDELab:sdearguments:GFUNDimensionMismatchDiagonal';

% state output larger
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)[x;x]+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNDimensionMismatchDiagonal';

% state output not a matrix
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)rand(1,1,2)+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNNotMatrix';

% state output number of rows not equal number of states for non-diagonal noise
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)rand(2)+1,0:0.1:1,0,sdeset(''Diagonal'',''no''));';
msg{i} = 'SDELab:sdearguments:GFUNDimensionMismatchNonDiagonal';

% state output not a column vector for diagonal noise
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)rand(2)+1,0:0.1:1,[0 0]);';
msg{i} = 'SDELab:sdearguments:GFUNDimensionMismatchDiagonal';

% state output not non-empty
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)[],0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNNotMatrix';

% state output not float
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)uint8(x)+1,0:0.1:1,0);';
msg{i} = 'SDELab:sdearguments:GFUNNotMatrix';


% tspan:

% scalar time
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0,0);';
msg{i} = 'SDELab:sdearguments:InvalidTSpanSize';

% const time
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,[0,0,0,0],0);';
msg{i} = 'SDELab:sdearguments:TspanNotMonotonic';

% non-monotonic time
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,sin(0:0.5*pi:2*pi),0);';
msg{i} = 'SDELab:sdearguments:TspanNotMonotonic';

% not float
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,uint8(0:9),0);';
msg{i} = 'SDELab:sdearguments:InvalidTSpanDataType';

% not non-empty
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,rand(0,9),0);';
msg{i} = 'SDELab:sdearguments:InvalidTSpanSize';

% not real
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,(0:0.1:1)+1i,0);';
msg{i} = 'SDELab:sdearguments:InvalidTSpanDataType';


% y0:

% not float
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,uint8(0));';
msg{i} = 'SDELab:sdearguments:Y0EmptyOrNotFloat';

% not non-empty
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,[]);';
msg{i} = 'SDELab:sdearguments:Y0EmptyOrNotFloat';


% options:

% invalid non-empty options
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,0);';
msg{i} = 'SDELab:sde_euler:InvalidSDESETStruct';

% invalid empty options
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,'''');';
msg{i} = 'SDELab:sde_euler:InvalidSDESETStruct';

% invalid empty options
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,zeros(0,1));';
msg{i} = 'SDELab:sde_euler:InvalidSDESETStruct';

% invalid empty options
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,zeros(0,0,0));';
msg{i} = 'SDELab:sde_euler:InvalidSDESETStruct';

% inavlid RandSeed, not a matrix
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',ones(1,1,2)));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';

% inavlid RandSeed, not a scalar
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',[0,0]));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';

% inavlid RandSeed, not finite
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',NaN));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';

% inavlid RandSeed, not real
st = dbstack;
i = i+1;
lnum{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',1i));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';

% inavlid RandSeed, not numeric
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',logical(0)));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';

% RandSeed too small
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',-1));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';

% RandSeed too large
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandSeed'',2^32));';
msg{i} = 'SDELab:sdearguments:InvalidRandSeed';


% RandFUN:

% inavlid RandFUN
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandFUN'',0));';
msg{i} = 'SDELab:sdearguments:RandFUNNotAFunctionHandle';

% undefined RandFUN
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandFUN'',@rr));';
msg{i} = 'MATLAB:UndefinedFunction';

% empty RandFUN output, D > N, nargout == 2
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = '[y,w]=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)[]));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray1';

% non-matrix RandFUN output, D > N, nargout == 2
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = '[y,w]=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)randn(p,q,2)));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray1';

% non-float RandFUN output, D > N, nargout == 2
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = '[y,w]=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)uint8(randn(p,q))));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray1';

% RandFUN output size mismatch, D > N, nargout == 2
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = '[y,w]=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)randn(1,q)));';
msg{i} = 'SDELab:sde_euler:RandFUNDimensionMismatch1';

% empty RandFUN output, D > N, nargout == 1
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)[]));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray2';

% non-matrix RandFUN output, D > N, nargout == 1
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)randn(p,q,2)));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray2';

% non-float RandFUN output, D > N, nargout == 1
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)uint8(randn(p,q))));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray2';

% RandFUN output size mismatch, D > N, nargout == 1
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)[x,x]+1,0:0.1:1,0,sdeset(''Diagonal'',''no'',''RandFUN'',@(p,q)randn(p,1)));';
msg{i} = 'SDELab:sde_euler:RandFUNDimensionMismatch2';

% empty RandFUN output, D <= N
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,[0,0],sdeset(''RandFUN'',@(p,q)[]));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray3';

% non-matrix RandFUN output, D <= N
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,[0,0],sdeset(''RandFUN'',@(p,q)randn(p,q,2)));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray3';

% non-float RandFUN output, D <= N
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,[0,0],sdeset(''RandFUN'',@(p,q)uint8(randn(p,q))));';
msg{i} = 'SDELab:sde_euler:RandFUNNot2DArray3';

% RandFUN output size mismatch, D <= N
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,[0,0],sdeset(''RandFUN'',@(p,q)randn(1,q)));';
msg{i} = 'SDELab:sde_euler:RandFUNDimensionMismatch3';

% RandFUN only has one input
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandFUN'',@(p)randn(p)));';
msg{i} = 'SDELab:sde_euler:RandFUNTooFewInputs';

% RandFUN output not specified
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandFUN'',@r1));';
msg{i} = 'SDELab:sde_euler:RandFUNNoOutput';

% RandFUN output not assigned
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandFUN'',@r2));';
msg{i} = 'SDELab:sde_euler:RandFUNUnassignedOutput';

% RandFUN requires more than two inputs
st = dbstack;
i = i+1;
lnum1{i} = st.line;
cmd{i} = 'y=sde_euler(@(t,x)x+1,@(t,x)x+1,0:0.1:1,0,sdeset(''RandFUN'',@(m,n,p)p*randn(m,n)));';
msg{i} = 'SDELab:sde_euler:RandFUNTooManyInputs';



% normal unit tests:

% cases where no FOR loop is required, no parameter arguments:

% with numeric inputs

st = dbstack;
i = 1;
lnum{i} = st.line;
f{i} = '1';             % constant, autonomous, scalar
g{i} = '1';             % constant, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '1';             % constant, autonomous, scalar
g{i} = '1';             % constant, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1]';       	% constant, autonomous, vector
g{i} = '[1;1]';     	% constant, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% scalar ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1]';       	% constant, autonomous, vector
g{i} = '[1;1]';     	% constant, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';     	% scalar ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1]';       	% constant, autonomous, vector
g{i} = '[1,1;1,1]';   	% constant, autonomous, matrix, diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% scalar ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1]';       	% constant, autonomous, vector
g{i} = '[1,1;1,1]';    	% constant, autonomous, matrix, diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';     	% scalar ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1]';       	% constant, autonomous, vector
g{i} = '[1,1,1;1,1,1]';	% constant, autonomous, matrix, diagonal, D == 3
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% scalar ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1]';       	% constant, autonomous, vector
g{i} = '[1,1,1;1,1,1]';	% constant, autonomous, matrix, diagonal, D == 3
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';     	% scalar ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1;1]';      	% constant, autonomous, vector
g{i} = '[1,1;1,1;1,1]';	% constant, autonomous, matrix, diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% scalar ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '[1;1;1]';      	% constant, autonomous, vector
g{i} = '[1,1;1,1;1,1]';	% constant, autonomous, matrix, diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';     	% scalar ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [0 1];


% with function inputs

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';      	% constant, autonomous, scalar
g{i} = '@(t,x)1';     	% constant, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';     	% constant, autonomous, scalar
g{i} = '@(t,x)1';      	% constant, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';      	% constant, autonomous, scalar
g{i} = '@(t,x)[1,1]';  	% constant, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';      	% constant, autonomous, scalar
g{i} = '@(t,x)[1,1]';  	% constant, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';     	% constant, autonomous, scalar
g{i} = '@(t,x)1';      	% constant, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';      	% constant, autonomous, scalar
g{i} = '@(t,x)1';    	% constant, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1]';       % constant, autonomous, vector
g{i} = '@(t,x)ones(2,3)';	% constant, autonomous, scalar, non-diagonal, D == 3
tspan{i} = '0:0.5:10';   	% constant step-size, increasing
y0{i} = '[0,0]';          	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1]';       % constant, autonomous, vector
g{i} = '@(t,x)ones(2,3)';	% constant, autonomous, scalar, non-diagonal, D == 3
tspan{i} = '0:0.1:10';   	% non-constant step-size, increasing
y0{i} = '[0,0]';          	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [0 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1]';  	% constant, autonomous, vector
g{i} = '@(t,x)1';     	% constant, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1]';  	% constant, autonomous, vector
g{i} = '@(t,x)1';     	% constant, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1;1]';  	% constant, autonomous, vector
g{i} = '@(t,x)ones(3,2)';	% constant, autonomous, scalar, non-diagonal, D == 2
tspan{i} = '0:0.5:10';   	% constant step-size, increasing
y0{i} = '[0,0,0]';       	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1;1]';  	% constant, autonomous, vector
g{i} = '@(t,x)ones(3,2)';	% constant, autonomous, scalar, non-diagonal, D == 2
tspan{i} = '0:0.1:10';   	% non-constant step-size, increasing
y0{i} = '[0,0,0]';       	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1;1]';	% constant, autonomous, vector
g{i} = '@(t,x)ones(3)';	% constant, autonomous, scalar, non-diagonal, D == 3
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];
 
st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1;1]';	% constant, autonomous, vector
g{i} = '@(t,x)ones(3)';	% constant, autonomous, scalar, non-diagonal, D == 3
tspan{i} = '0:0.1:10'; 	% non-constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% default options, no parameter arguments:

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = '';
params{i} = '';
twoout{i} = [1 1];


% with options, no parameter arguments:

% non-diagonal, Stratonovich:

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.5:10';      % constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.1:10';      % non-constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';    	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';    	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'')';
params{i} = '';
twoout{i} = [1 1];


% diagonal, Ito:

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];


% non-diagonal, Ito:

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.5:10';      % constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.1:10';      % non-constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';    	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';    	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'')';
params{i} = '';
twoout{i} = [1 1];


% diagonal, Stratonovich, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% non-diagonal, Stratonovich, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.5:10';      % constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.1:10';      % non-constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';    	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';    	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% diagonal, Ito, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% non-diagonal, Ito, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.5:10';      % constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.1:10';      % non-constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';    	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';    	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstFFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% diagonal, Stratonovich, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% non-diagonal, Stratonovich, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.5:10';      % constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.1:10';      % non-constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';    	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';    	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% diagonal, Ito, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1'; 	% non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0;0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% non-diagonal, Ito, constant FFUN

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1'; 	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.5:0';	% constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '10:-0.1:0';	% non-constant step-size, decreasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.5:5';	% constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '-5:0.1:5';	% non-constant step-size, increasing, negative to positive
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.5:-5';	% constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '5:-0.1:-5';	% non-constant step-size, decreasing, positive to negative
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';   	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';       	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.5:10';      % constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';         % non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 3
tspan{i} = '0:0.1:10';      % non-constant step-size, increasing
y0{i} = '[0,0]';            % vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0,0]';     	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)[x,x]+1';	% non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0,0]';    	% vector ICs, N == 3
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '[0,0]';     	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x(1)+1';	% non-homogeneous, autonomous, scalar, non-diagonal, D == 1
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '[0,0]';    	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, vector
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, matrix, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)x+1';    	% non-homogeneous, autonomous, scalar
g{i} = '@(t,x)x+1';     % non-homogeneous, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';            % scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''SDEType'',''Ito'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 1];


% cases that miss no FOR loop case, D > N, nargout == 1, no parameter arguments:

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';      	% constant, autonomous, scalar
g{i} = '@(t,x)[1,1]';  	% constant, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.5:10';	% constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 0];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)1';      	% constant, autonomous, scalar
g{i} = '@(t,x)[1,1]';  	% constant, autonomous, vector, non-diagonal, D == 2
tspan{i} = '0:0.1:10';	% non-constant step-size, increasing
y0{i} = '0';          	% scalar ICs, N == 1
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 0];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1]';       % constant, autonomous, vector
g{i} = '@(t,x)ones(2,3)';	% constant, autonomous, scalar, non-diagonal, D == 3
tspan{i} = '0:0.5:10';   	% constant step-size, increasing
y0{i} = '[0,0]';          	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 0];

st = dbstack;
i = i+1;
lnum{i} = st.line;
f{i} = '@(t,x)[1;1]';       % constant, autonomous, vector
g{i} = '@(t,x)ones(2,3)';	% constant, autonomous, scalar, non-diagonal, D == 3
tspan{i} = '0:0.1:10';   	% non-constant step-size, increasing
y0{i} = '[0,0]';          	% vector ICs, N == 2
opts{i} = ',sdeset(''Diagonal'',''no'',''ConstFFUN'',''yes'',''ConstGFUN'',''yes'')';
params{i} = '';
twoout{i} = [1 0];



nb =  char(160);    % non-breaking space
bs = '\b';          % backspace;
sp = ' ';           % space

m = length(lnum1);
num = 0;

if runtests
    ts = sort(tests(tests<=m));
else
    ts = 1:m;
end
lts = length(ts);
lne = 2*length(num2str(lts));

if ~isempty(ts)
    fprintf(1,sp(ones(1,ceil(log10(length(ts)+1))+45+0.5*lne)));
end
for i = ts
    errv = true;
    try 
        eval(cmd{i});
    catch err
        if ~strcmp(err.identifier,msg{i})
            errmsg = ['Error test ' num2str(i) ' (of ' num2str(m) ') '...
                      'assertion failed. See line ' num2str(lnum1{i}-1) ...
                      ' of SDE_EULER_UNITTEST.m  for details.\n\n' nb nb ...
                      'Error ID:' nb nb nb msg{i} '\n' nb nb 'Expression:'...
                      nb cmd{i}];
            me = MException('SDELab:sde_euler_unittest:AssertError',errmsg);
            rep = getReport(err,'extended');
            me2 = MException('SDELab:sde_euler_unittest:AssertErrorCause',rep);
            throw(addCause(me,me2));
        end
        errv = false;
    end
    if errv
        errmsg = ['Error test ' num2str(i) ' (of ' num2str(m) ') not '...
                  'triggered. See line ' num2str(lnum1{i}-1) ' of '...
                  'SDE_EULER_UNITTEST.m for details.\n\n' nb nb 'Error ID:'...
                  nb nb nb msg{i} '\n' nb nb 'Expression:' nb cmd{i}];
        me = MException('SDELab:sde_euler_unittest:EvaluationError',errmsg);
        rep = getReport(err,'extended');
        me2 = MException('SDELab:sde_euler_unittest:EvaluationErrorCause',rep);
        throw(addCause(me,me2));
    end
    num = num+1;
    if num > 1
        fprintf(1,[bs(mod(0:2*ceil(log10(num+1))-1+90+lne,2)+1) '%d'],num);
        fprintf(1,' (of %d) error tests performed successfully...\n',lts);
    end
end
if num == 1
    pause(0.1);
    fprintf(1,[bs(mod(0:1+90+lne,2)+1) '%d'],num);
    pause(0.1);
    fprintf(1,' error test performed successfully.\n');
elseif num > 1
    pause(0.01);
    fprintf(1,[bs(mod(0:2*ceil(log10(num+1))-1+90+lne,2)+1) 'All %d'],num);
    fprintf(1,' error tests performed successfully.\n');
end


pm = m;
m = length(lnum);

if runtests
    ts = tests(tests > pm)-pm;
    ts = ts(ts <= m*14);
    lts = length(ts);
	mm = lts+1;
else
    mm = 0;
    for j = 1:m
        if twoout{j}(1) == 1
            mm = mm+6;
        end
        if twoout{j}(2) == 1
            mm = mm+8;
        end
    end
    lts = mm;
end
num = 0;
cnt = 0;

lnu = 2*length(num2str(lts));

if ~isempty(ts) || ~runtests
    fprintf(1,sp(ones(1,ceil(log10(mm))+44+0.5*lnu)));
    ms = 1:m;
else
    ms = [];
end
for j = ms
    n = 0;
    if twoout{j}(1) == 1
        n = n+6;
    end
    if twoout{j}(2) == 1
        n = n+8;
    end
    
    if runtests
        tts = ts(ts <= cnt+n);
        tts = mod(tts(tts > cnt)-1,n)+1;
    else
        tts = 1:n;
    end
    
    if ~isempty(tts)
        lnum2 = cell(n,1);
        cmd = cell(n,1);
        test1 = cell(n,1);
        test2 = cell(n,1);

        if twoout{j}(1) == 1
            % output is not empty
            st = dbstack;
            i = 1;
            lnum2{i} = st.line;
            cmd{i} = ['y=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'isempty(y)';
            test2{i} = false;

            % output is float
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['y=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'isfloat(y)';
            test2{i} = true;

            % output is matrix
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['y=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'ndims(y)';
            test2{i} = 2;

            % output is same dimension as Y0
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['y=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'size(y,2)';
            ic = eval(y0{j});
            test2{i} = size(ic(:),1);

            % length of output same as TSPAN
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['y=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'size(y,1)';
            test2{i} = length(eval(tspan{j}));

            % first value is Y0
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['y=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'y(1,:)''';
            ic = eval(y0{j});
            test2{i} = ic(:);
        end
        if twoout{j}(2) == 1    % output and check Wiener increments
            % output is not empty
            st = dbstack;
            if twoout{j}(1) == 1
                i = i+1;
            else
                i = 1;
            end
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = '[isempty(y) isempty(w)]';
            test2{i} = false;

            % output is float
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = '[isfloat(y) isfloat(w)]';
            test2{i} = true;

            % output is matrix
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = '[ndims(y) ndims(w)]';
            test2{i} = 2;

            % output of Y is same dimension as Y0
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'size(y,2)';
            ic = eval(y0{j});
            test2{i} = size(ic(:),1);

            % output of W is same dimension as output of Y0 or GFUN
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'size(w,2)';
            t = eval(tspan{j});
            ic = eval(y0{j});
            eg = eval(g{j});
            if isa(eg,'function_handle')
                gout = feval(eg,t(1),ic(:));
            else
                gout = eg;
            end
            if isempty(strfind(opts{j},'''Diagonal'',''no'''))
                test2{i} = size(ic(:),1);
            else
                test2{i} = size(gout,2);
            end

            % length of output same as TSPAN
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = '[size(y,1) size(w,1)]';
            test2{i} = length(eval(tspan{j}));

            % first value of Y is Y0
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'y(1,:)''';
            ic = eval(y0{j});
            test2{i} = ic(:);

            % first value of W is 0
            st = dbstack;
            i = i+1;
            lnum2{i} = st.line;
            cmd{i} = ['[y,w]=sde_euler(' f{j} ',' g{j} ',' tspan{j} ',' y0{j} opts{j} params{j} ');'];
            test1{i} = 'w(1,:)';
            test2{i} = 0;
        end

        for i = tts
            try
                eval(cmd{i});
            catch err
                errmsg = ['Error during evaluation of unit test ' num2str(cnt+i) ...
                          '. See lines ' num2str(lnum{j}) ' and '...
                          num2str(lnum2{i}-1) ' of SDE_EULER_UNITTEST.m for '...
                          'details.\n\n' nb nb 'Expression:' nb cmd{i}];
                me = MException('SDELab:sde_euler_unittest:EvaluationError',errmsg);
                rep = getReport(err,'extended');
                me2 = MException('SDELab:sde_euler_unittest:EvaluationErrorCause',rep);
                throw(addCause(me,me2));
            end
            errmsg = ['Unit test ' num2str(cnt+i) ' assertion failed. See lines '...
                      num2str(lnum{j}) ' and ' num2str(lnum2{i}-1) ' of '...
                      'SDE_EULER_UNITTEST.m for details.\n' nb nb 'Expression:'...
                      nb cmd{i} '\n\n' nb nb 'Assertion:' nb nb test1{i} nb '=='...
                      nb mat2str(test2{i})];
            assert(all(eval(test1{i}) == test2{i}),sprintf(errmsg));
            num = num+1;
            if mod(num,10) == 0
                fprintf(1,[bs(mod(0:2*ceil(log10(num+1))-1+88+lnu,2)+1) '%d'],num);
                fprintf(1,' (of %d) unit tests performed successfully...\n',lts);
            end
        end
    end
    cnt = cnt+n;
end
if num == 0
    if ~isempty(ms)
        fprintf(1,bs(mod(0:1+88+lnu,2)+1));
    end
elseif num == 1
    fprintf(1,[bs(mod(0:1+88+lnu,2)+1) '%d'],num);
    fprintf(1,' unit test performed successfully.\n');
else
    pause(0.01);
    fprintf(1,[bs(mod(0:2*ceil(log10(num+1))-1+88+lnu,2)+1) 'All %d'],num);
    fprintf(1,' unit tests performed successfully.\n');
end

% reset path to prior state if we added toolbox
if pathadded
    rmpath SDELab
end



function f1(t,x)        %#ok<*DEFNU,*INUSL>
y = x+1;                %#ok<*NASGU>


function y = f2(t,x)    %#ok<*STOUT>
x+1;                    %#ok<*VUNUS>


function g1(t,x)
y = x+1;


function y = g2(t,x)
x+1;


function r1(m,n)
y = randn(m,n);


function y = r2(m,n)
randn(m,n);