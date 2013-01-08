REM Ensure that all bundles are installed locally by running
REM    bundle install --no-deployment

REM Ensure that Codebase.jar has latest code by running
REM    bundle exec rake windows:package

REM Ensure that WIX Toolset is installed and available in PATH

REM Parse the RapidFTR.wxs file into an intermediate representation
candle -ext WixUtilExtension RapidFTR.wxs

REM Build the installer from the intermediate representation
light  -ext WixUtilExtension -ext WixUIExtension RapidFTR.wixobj

REM Test installer in debug mode by running
REM    msiexec /i RapidFTR.msi /l*v Log.txt
