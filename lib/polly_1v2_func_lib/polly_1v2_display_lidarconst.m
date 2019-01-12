function [] = polly_1v2_display_lidarconst(data, taskInfo, config)
%polly_1v2_display_lidarconst Display the lidar constants.
%   Example:
%       [] = polly_1v2_display_lidarconst(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

if isempty(data.cloudFreeGroups)
    return;
end


thisTime = mean(data.mTime(data.cloudFreeGroups), 2);
LC532_klett = data.LC.LC_klett_532;
LC532_raman = data.LC.LC_raman_532;
LC532_aeronet = data.LC.LC_aeronet_532;

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% initialization
    fileLC532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename)));

    %% 532 nm
    thisTime = mean(data.mTime(data.cloudFreeGroups), 2);
    LC532_klett = data.LC.LC_klett_532;
    LC532_raman = data.LC.LC_raman_532;
    LC532_aeronet = data.LC.LC_aeronet_532;

    figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

    p1 = plot(thisTime, LC532_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
    p2 = plot(thisTime, LC532_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
    p3 = plot(thisTime, LC532_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

    xlim([data.mTime(1), data.mTime(end)]);
    ylim(config.LC532Range);

    xlabel('UTC');
    ylabel('C');
    title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '532', taskInfo.pollyVersion, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    set(gca, 'YMinorTick', 'on');
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    set(l, 'FontSize', 7);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, fileLC532, '-transparent', '-r300');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'));

    time = data.mTime;
    yLim532 = config.LC532Range;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display rcs 
    save(fullfile(tmpFolder, 'tmp.mat'), 'time', 'thisTime', 'LC532_klett', 'LC532_raman', 'LC532_aeronet', 'yLim532', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('python %s %s %s', fullfile(pyFolder, 'polly_1v2_display_lidarconst.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'polly_1v2_display_lidarconst.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end