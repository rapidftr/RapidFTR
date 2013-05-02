RapidFTR

RapidFTR is an application that lets aid workers collect, sort and share informa
tion about children in emergency situations. RapidFTR is specifically designed t
o streamline and speed up Family Tracing and Reunification efforts both in the i
mmediate aftermath of a crisis and during ongoing recovery efforts. RapidFTR all
ows for quick input of essential data about a child on a mobile phone, including
 a photograph, the child's age, family, health status and location information.D
ata is saved automatically and uploaded to a central database whenever networkac
cess becomes available. Registered aid workers will be able to create and modify
 entries for children in their care as well as search all existing records inord
er to help distressed parents find information about their missing children.

System Requirements
OS      : Windows XP SP3 and above
Version : 32-bit
Browser : Google Chrome (https://www.google.com/intl/en/chrome/browser/index.htm
l?standalone=1#eula), Firefox (http://www.mozilla.org/en-US/firefox/new/?from=ge
tfirefox)

RapidFTR installation steps:

1) Install the following software
    1. RailsInstaller - Windows Ruby 1.8 version (Available for download at http
://railsinstaller.org/)
    2. CouchDB        - Windows 1.2.1 version (Available at http://couchdb.apach
e.org/)
    3. ImageMagick    - static, x86 release (e.g. ImageMagick-x.y.z-Q16-x86-stat
ic.exe) (Available at http://www.imagemagick.org/script/binary-releases.php)
    4. NodeJS         - (Available at http://nodejs.org/download/)
    5. WIC            - Required only for Windows XP, download "wic_x86_enu.exe"
 (Available at http://www.microsoft.com/en-in/download/details.aspx?id=32)
    6. DotNet Framework-4.0 for XP SP3, 4.5 for Vista and above (Available at ht
tp://www.microsoft.com/en-in/download/details.aspx?id=17718)
    7. JDK            - Only the JDK release, not the JRE (Available at http://w
ww.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)

2) Install RapidFTR.msi
3) During the first installation - you will be prompted if you have a CouchDB us
ername/password. Say no - and it will create a default CouchDB username and pass
word
4) During subsequent installations, say "yes" and enter the CouchDB username/pas
sword

For comprehensive installation details, refer: (https://github.com/rapidftr/Rapi
dFTR/wiki/Windows-Offline-Installer-1580)