function [] = polly_1v2_save_retrieving_results(data, taskInfo, config)
%polly_1v2_save_retrieving_results saving the retrieved results, including backscatter, extinction coefficients, lidar ratio, volume/particles depolarization ratio and so on.
%   Example:
%       [] = polly_1v2_save_retrieving_results(data, taskInfo, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       
%   History:
%       2018-12-31. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

missing_value = -999;

for iGroup = 1:size(data.cloudFreeGroups, 1)
    ncFile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_profiles.nc', rmext(taskInfo.dataFilename), datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HHMM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HHMM')));

    % filling missing values for reference height
    if isnan(data.refHIndx532(iGroup, 1))
        refH532 = [missing_value, missing_value];
    else
        refH532 = data.height(data.refHIndx532(iGroup, :));
    end

    % create .nc file by overwriting any existing file with the name filename
    ncID = netcdf.create(ncFile, 'clobber');

    % define dimensions
    dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
    dimID_method = netcdf.defDim(ncID, 'method', 1);
    dimID_refHeight = netcdf.defDim(ncID, 'reference_height', 2);

    % define variables
    varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_altitude);
    varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_klett_532 = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_raman_532 = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerExt_raman_532 = netcdf.defVar(ncID, 'aerExt_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerLR_raman_532 = netcdf.defVar(ncID, 'aerLR_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_RR_532 = netcdf.defVar(ncID, 'aerBsc_RR_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerExt_RR_532 = netcdf.defVar(ncID, 'aerExt_RR_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerLR_RR_532 = netcdf.defVar(ncID, 'aerLR_RR_532', 'NC_DOUBLE', dimID_altitude);
    varID_volDepol_532 = netcdf.defVar(ncID, 'volDepol_532', 'NC_DOUBLE', dimID_altitude);
    varID_parDepol_klett_532 = netcdf.defVar(ncID, 'parDepol_klett_532', 'NC_DOUBLE', dimID_altitude);
    varID_parDepol_raman_532 = netcdf.defVar(ncID, 'parDepol_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_temperature = netcdf.defVar(ncID, 'temperature', 'NC_DOUBLE', dimID_altitude);
    varID_pressure = netcdf.defVar(ncID, 'pressure', 'NC_DOUBLE', dimID_altitude);
    varID_reference_height_532 = netcdf.defVar(ncID, 'reference_height_532', 'NC_DOUBLE', dimID_refHeight);

    % leve define mode
    netcdf.endDef(ncID);

    % write data to .nc file
    netcdf.putVar(ncID, varID_height, data.height);
    netcdf.putVar(ncID, varID_altitude, data.alt);
    netcdf.putVar(ncID, varID_aerBsc_klett_532, fillmissing(data.aerBsc532_klett(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_raman_532, fillmissing(data.aerBsc532_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerExt_raman_532, fillmissing(data.aerExt532_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerLR_raman_532, fillmissing(data.LR532_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_aerBsc_RR_532, fillmissing(data.aerBsc532_RR(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerExt_RR_532, fillmissing(data.aerExt532_RR(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerLR_RR_532, fillmissing(data.LR532_RR(iGroup, :)));
    netcdf.putVar(ncID, varID_volDepol_532, fillmissing(data.voldepol532(iGroup, :)));
    netcdf.putVar(ncID, varID_parDepol_klett_532, fillmissing(data.pardepol532_klett(iGroup, :)));
    netcdf.putVar(ncID, varID_parDepol_raman_532, fillmissing(data.pardepol532_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_temperature, fillmissing(data.temperature(iGroup, :)));
    netcdf.putVar(ncID, varID_pressure, fillmissing(data.pressure(iGroup, :)));
    netcdf.putVar(ncID, varID_reference_height_532, refH532);

    % reenter define mode
    netcdf.reDef(ncID);

    % write attributes to the variables
    varID_global = netcdf.getConstant('GLOBAL');
    netcdf.putAtt(ncID, varID_global, 'latitude', data.lat);
    netcdf.putAtt(ncID, varID_global, 'longtitude', data.lon);
    netcdf.putAtt(ncID, varID_global, 'elev', data.alt0);
    netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
    netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
    netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
    netcdf.putAtt(ncID, varID_global, 'contact', sprintf('%s', processInfo.contact));

    netcdf.putAtt(ncID, varID_height, 'unit', 'm');
    netcdf.putAtt(ncID, varID_height, 'long_name', 'height (above surface)');
    netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');

    netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
    netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height above mean sea level');
    netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');


    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'standard_name', '\\beta_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR532, config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'standard_name', '\\beta_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta532 * 1e6, config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit', 'Mm^{-1}');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'standard_name', '\\alpha_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'standard_name', 'S_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method using RR signal');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'standard_name', '\\beta_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta532 * 1e6, config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'comment', sprintf('The results is retrieved with Raman method using RR signal. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'unit', 'Mm^{-1}');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with Raman method using RR signal');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'standard_name', '\\alpha_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'comment', sprintf('The results is retrieved with Raman method using RR signal. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method using the RR signal');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'standard_name', 'S_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'comment', sprintf('The results is retrieved with Raman method using RR signal. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_volDepol_532, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_532, 'long_name', 'volume depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_volDepol_532, 'standard_name', '\\delta_{vol, 532}');
    netcdf.putAtt(ncID, varID_volDepol_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_volDepol_532, 'comment', sprintf('depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));
    
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'long_name', 'particle depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'standard_name', '\\delta_{par, 532}');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_klett_532 * data.hRes, data.moldepol532(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));
    
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'long_name', 'particle depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'standard_name', '\\delta_{par, 532}');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_raman_532 * data.hRes, data.moldepol532(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));
    
    netcdf.putAtt(ncID, varID_temperature, 'unit', '\\circC');
    netcdf.putAtt(ncID, varID_temperature, 'long_name', 'Temperature');
    netcdf.putAtt(ncID, varID_temperature, 'standard_name', 'T');
    netcdf.putAtt(ncID, varID_temperature, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_temperature, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    
    netcdf.putAtt(ncID, varID_pressure, 'unit', 'hPa');
    netcdf.putAtt(ncID, varID_pressure, 'long_name', 'Pressure');
    netcdf.putAtt(ncID, varID_pressure, 'standard_name', 'P');
    netcdf.putAtt(ncID, varID_pressure, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_pressure, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    
    netcdf.putAtt(ncID, varID_reference_height_532, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'long_name', 'Reference height for 532 nm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'standard_name', '');
    netcdf.putAtt(ncID, varID_reference_height_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_reference_height_532, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));
    
    % close file
    netcdf.close(ncID);
    
end