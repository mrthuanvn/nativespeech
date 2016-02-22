Thanks to Adobe AIR 2.0 new NativeProcess API, NativeSpeech will interact with the operating systems to use their voice synthesis features (say for Mac OS X, SAPI for Windows via a bundled executable).

**Features**
  * listing of the voices available in the os
  * event/error handling

Windows support isn't perfect yet as it shows briefly an empty console when activating speech, and voice retrieving isn't implemented. I'm working on it.



**Requirements**
  * To compile the project correctly you need to have the Adobe AIR 2 beta 1 SDK (or newer).
  * To run the binary you need to install the Adobe AIR 2 beta 1 runtime.

You can find these files on the Adobe Labs website : http://labs.adobe.com/technologies/air2/

**Further reading**

Find more informations about this class on my blog :
  * in English : http://blog.technolog33k.fr/adobe-air/20-12-2009-voice-synthesis-in-adobe-air-with-the-nativeprocess-api/
  * in French : http://blog.technolog33k.fr/adobe-air/20-12-2009-synthese-vocale-dans-adobe-air-grace-a-lapi-nativeprocess/