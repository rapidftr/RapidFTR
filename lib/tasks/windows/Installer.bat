REM Install the following to generate the Setup package:
REM     RailsInstaller
REM     JDK
REM     Wix Toolset (optionally may require .Net 4.0 and wic_enu)

REM Make gems install with no documentation:
echo gem: --no-ri --no-rdoc > "C:\Documents and Settings\All Users\gemrc"
echo gem: --no-ri --no-rdoc > "C:\Documents and Settings\All Users\Application Data\gemrc"
echo gem: --no-ri --no-rdoc > "C:\gemrc"
echo gem: --no-ri --no-rdoc > "C:\Program Files\gemrc"
echo gem: --no-ri --no-rdoc > "C:\ProgramData\gemrc"

REM Update Gem version
gem install rubygems-update -v 1.8.25
update_rubygems

REM Ensure that all gems are installed locally by running
bundle install --path=vendor\bundle --without cucumber development test

REM REM Ensure zipruby gem is separately installed, it won't install thru bundler
REM REM    gem install zipruby -v 0.3.6 --platform --install-dir=vendor/bundle/ruby/1.8/

REM Set RAILS_ENV
set RAILS_ENV=standalone

REM Ensure that Codebase.jar has latest code by running
bundle exec rake windows:package

REM Ensure that WIX Toolset is installed and available in PATH
set PATH=%PATH%;"C:\Program Files\WiX Toolset v3.7\bin"

REM Parse the RapidFTR.wxs file into an intermediate representation
cd lib\tasks\windows
candle -ext WixUtilExtension RapidFTR.wxs

REM Build the installer from the intermediate representation
light  -ext WixUtilExtension -ext WixUIExtension RapidFTR.wixobj

REM Test installer in debug mode by running
msiexec /i RapidFTR.msi /l*v Log.txt
