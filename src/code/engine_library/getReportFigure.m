function [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle,varargin) %#ok<INUSL>
%GETREPORTFIGURE creates new figure with and set watermark if not on validated system.
%
%   WSettings  structure containing global settings see GETDEFAULTWORKFLOWSETTINGS
%
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols)
%       - nRows number of rows for creation of new axes 
%       - nCols number of rows for creation of new axes 
%       returns:
%       - ax_handles: array of axes handles
%       - figureHandle: figure handle
%
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle)
%       - figureHandle: figure handle of an existing figure, which will be
%           cleared and reused.
%           If figureHandle is empty or an invalid handle, a new figure is created.
%
% Options:
%   figureFormat:
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle,...
%           'figureFormat',figureFormat_value)
%           Figure format of the figure, possible values for figureFormat_value are
%               -'square'
%               -'portrait'
%               -'landscape'
%           Default is 'square'.
%
%   paperOrientation:
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle,...
%           'paperOrientation',paperOrientation_value)
%           paper orientation of the figure, possible values for paperOrientation_value are
%               -'landscape',
%               -'portrait'
%           Default orientation depends on the figure format.
%           
%   paperPosition:
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle,...
%           'paperPosition',paperPosition_value)
%           paperPosition of the figure (4x1 vector) 
%           of form [left bottom width height]
%           Default position depends on the figure format.
%
%   fontsize:
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle,,...
%           'fontsize',fontsize_value)
%           fontsize of legend, xlabel, ylabel and title
%           Default fontsize depends on the number of figures
%
%   axes_position:
%   [ax_handles,figureHandle]=getReportFigure(WSettings,nRows,nCols,figureHandle,,...
%           'axes_position',axes_position_value)
%           Position array for axes, unit is normalized
%           Each row (as 4x1 vector) defines one axis
%           nRows and Cols will be ignored 
%
%
% Example Call:
%   [ax_handles,figureHandle]=getReportFigure(WSettings,1,1,[],'paperposition',[0 0 30 30],...
%           'paperOrientation','landscape','fontsize',5,'figureFormat','landscape');
%   [ax_handles,f]=getReportFigure(WSettings,2,3,figureHandle);
%   [ax_handles,f]=getReportFigure(WSettings,2,3,figureHandle,'axes_position',[0.6 0.1 0.3 0.8;0.1 0.1 0.3 0.8]);
%

% Open Systems Pharmacology Suite;  http://open-systems-pharmacology.org



%% check Inputs --------------------------------------------------------------

% Check input options
[figureFormat,paperOrientation, paperPosition ,fontsize,axes_position] = ...
    checkInputOptions(varargin,{...
    'figureFormat',{'square','portrait','landscape'},'landscape',...
    'paperOrientation',{'landscape','portrait','default'},'landscape',...
    'PaperPosition',nan,'default',...
    'fontsize',nan,nan,...
    'axes_position',nan,nan,...
    });

if ~exist('nRows','var')
    nRows=1;
end

if ~exist('nCols','var')
    nCols=1;
end

% set watermark
 if isempty(WSettings.Watermark) || WSettings.isValidatedSystem
    timestamp = false;
 else
    timestamp = true;
end

% Get the fontsize if not user defined corresponding to the numbers of
% figures
if isnan(fontsize)
    switch max(nCols,nRows)
        case 1
            fontsize=12;
        case 2
            fontsize=11;
        case 3
            fontsize=10;
        otherwise
            fontsize=8;
    end
end
    
%% Create  the figure;
if exist('figureHandle','var') && ~isempty(figureHandle) && ishandle(figureHandle)
    clf(figureHandle);
else
    figureHandle=figure;
end

set(0, 'CurrentFigure', figureHandle);

% set Figure Format
screensize = get(0,'ScreenSize');
scaleVector=min([screensize(1,3)/1280 screensize(1,4)/1024]);
switch figureFormat
    case 'square'
        set(figureHandle,'Position',[300 300 600 504].*scaleVector)
        if strcmp(paperOrientation,'default')
            set(figureHandle, 'PaperOrientation', 'landscape');
        else
            set(figureHandle, 'PaperOrientation', paperOrientation);
        end
        if isnan(paperPosition)
            set(figureHandle, 'PaperPosition',[0 0 20 20]);
        else
            set(figureHandle, 'PaperPosition',paperPosition);
        end
    case 'portrait'
        set(figureHandle,'position',[300 150 600 650].*scaleVector)
        if strcmp(paperOrientation,'default')
            set(figureHandle, 'PaperOrientation', 'portrait');
        else
            set(figureHandle, 'PaperOrientation', paperOrientation);
        end
        if isnan(paperPosition)
            set(figureHandle, 'PaperPosition',[0 0 20 27]);
        else
            set(figureHandle, 'PaperPosition',paperPosition);
        end
    case 'landscape'
        set(figureHandle,'position',[193 273 921 530].*scaleVector)
        if strcmp(paperOrientation,'default')
            set(figureHandle, 'PaperOrientation', 'landscape');
        else
            set(figureHandle, 'PaperOrientation', paperOrientation);
        end
        if isnan(paperPosition)
            set(figureHandle, 'PaperPosition',[0 0 27 20]);
        else
            set(figureHandle, 'PaperPosition',paperPosition);
        end
    otherwise
        error('unkown Figure Format: %s',figureFormat);
end



% Create textbox
if ~isempty(WSettings.Watermark)
    annotation(figureHandle,'textbox',[0.01 0.45 0.99 0.1],...
    'String',{WSettings.Watermark},...
    'FontSize',24,...
    'FitBoxToText','off',...
    'Linestyle','None',...
    'VerticalAlignment','middle',...
    'HorizontalAlignment','center',...
    'color',[0.85 0.85 0.85]);
end
if timestamp
   
    % get creation information
    [st] = dbstack();
    if length(st)==1
        creation_txt = sprintf('created by: %s on %s',getenv('username'),datestr(now));
    else
        creation_txt = ...
            sprintf('created with: %s, created by: %s on %s',st(end).file,getenv('username'),datestr(now));
    end
    
    annotation(figureHandle,'textbox',[0.001 0.001 1 0.1],...
    'String',{creation_txt},...
    'FontSize',8,...
    'FitBoxToText','off',...
    'Linestyle','None',...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','left',...
    'interpreter','none',...
    'color',[0.5 0.5 0.5],...
    'Tag','Timestamp');
end

% reset colormap
colormap('default');

%% Generate axes
if isnan(axes_position)
    ax_handles=nan(nRows*nCols,1);
    for iAx=1:nRows*nCols
        ax_handles(iAx)=subplot(nRows,nCols,iAx);
    end
    
    % scale to provide place for picture bottomline (see printWithTimeStamp)
    if timestamp        
        f = 0.95;
        for iAx=1:nRows*nCols
            ps = get(ax_handles(iAx),'position');
            set(ax_handles(iAx),'position',[ps(1) 1-(1-ps(2))*f ps(3) ps(4)*f]);
        end
    end
    
else
    ax_handles=nan(size(axes_position,1),1);
    for iAx=1:size(axes_position,1)
        ax_handles(iAx)=axes('position',axes_position(iAx,:)); 
    end
    
end

% set axes Properties
for iAx=1:length(ax_handles)
    % fontsize:
    % Set Title
    t=get(ax_handles(iAx),'Title');
    set(t,'FontSize',fontsize);
    set(t,'FontWeight','bold');
    
    % Set Labels
    l=get(ax_handles(iAx),'xlabel');
    set(l,'FontSize',fontsize);
    set(l,'FontWeight','bold');
    l=get(ax_handles(iAx),'ylabel');
    set(l,'FontSize',fontsize);
    set(l,'FontWeight','bold');
    l=get(ax_handles(iAx),'zlabel');
    set(l,'FontSize',fontsize);
    set(l,'FontWeight','bold');
    
    % Set Ticks
    set(ax_handles(iAx),'Fontsize',fontsize);
    set(ax_handles(iAx),'FontWeight','bold');
    
    % Set legend
    l=legend;
    set(l,'FontSize',fontsize);
    set(l,'FontWeight','bold');
    
    % set hold on
    set(ax_handles(iAx),'NextPlot','add')
    
    % set box on
    set(ax_handles(iAx),'Box','on')
end

return
