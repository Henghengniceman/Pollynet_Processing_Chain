function [signalSM] = smoothWin(signal, win, method)
%SMOOTHWIN smooth the signal with a height dependent window
%   Example:
%       [signal] = smoothWin(signal, win, method)
%   Inputs:
%       signal: array
%           signal array.
%       win: scalar or matrix
%           if win is a scalar, the signal will be smoothed by a fixed sliding 
%           window;
%           if win is a matrix, the window can be specified by the win matrix in 
%           different range
%       method: char
%           smoothing method. (default, 'moving')
%   Outputs:
%       signalSM: array
%           smoothed signal
%   History:
%       2018-08-20. First edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('method', 'var')
    method = 'moving';
end

signalSM = NaN(length(signal), 1);
if isscalar(win)
    signalSM = smooth(signal, win, method);
    return
end

if ismatrix(win)
    if size(win, 2) == 3
        for iWin = 1:size(win, 1)
            startIndx = max(1, win(iWin, 1) - fix((win(iWin, 3) - 1)/2));
            endIndx = min(length(signal), win(iWin, 2) + fix(win(iWin, 3)/2));
            tmp = smooth(signal(startIndx:endIndx), win(iWin, 3), method);
            signalSM(win(iWin, 1):win(iWin, 2)) = tmp((win(iWin, 1) - ...
            startIndx + 1):(win(iWin, 2) - startIndx + 1));
        end
    end
end


end