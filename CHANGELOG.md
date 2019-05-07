## Pollynet Processing Chain Changelog

### Version 1.1

#### Notable Changes

|Time|Changes|Reasoning|
|:--:|:------|:--------|
|2019-01-21|Using converted extinction coefficients from backscatter coefficients for lidar calibration.|Extinction coefficients retrieved with Raman method loses the information under the full FOV and has very large uncertainty|
|2019-01-28|Add lidar calibration for 387 and 607 nm|Might be useful for retrieving aerosol properties below clouds with raman method.|
|2019-02-12|Add a function to read logbook from Martin's program and implement the visualization for calibration constants|Monitor the long term behavior of the system|
|2019-02-20|Add function to save the volume depolarization ratio|User demands|
|2019-02-26|Use previous calibrated results with a time lag less than a week as default values instead of pre-set default values in `*_default.json`|Remove the repeated step to set up a new default file in case settings of the lidar were changed|
|2019-03-28|Change the water vapor calibration function. Remove the SNR determination and replace with fixed integration height|SNR determination can not catch the lofted moist layer and will lead to large calibration error.|
|2019-03-31|Add more iteration times for the quasi-retrieving method|Make the quasi backscatter at 355 and 532 nm converged to the true values|

### Version 1.0

Basic funtionality, including:

    - aerosol retrieving
    - water vapor calibration
    - depolarization calibration
    - lidar calibration
    - data visualization