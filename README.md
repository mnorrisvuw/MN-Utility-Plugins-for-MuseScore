# MN Layout Plugins for MuseScore

A set of plug-ins for [MuseScore Studio 4.4](https://musescore.org/en) that provides some very useful functionality for your scores.

<div align="center">
  <p>
    <a href="#includedplugins">Included plug-ins</a> •
    <a href="#installation">Installation</a> •
    <a href="#use">How to use</a> •
    <a href="#feedback">Feedback, requests and bug reports</a> •
    <a href="#license">License</a>
  </p>
</div>

<div align="center">
  <img
    max-width="600"
    width="75%"
    src="images/MNCreateTitlePageScreenshot.png"
    alt="Create Title Page screenshot"
  >
</div>


## <a id="includedplugins"></a>Included plug-ins

### <img width="200px" src="MNCreateTitlePage.png" alt="Create Title Page" style="vertical-align:top; margin-right:10px"> MN CREATE TITLE PAGE
* **MN Create Title Page** automatically creates a professional-looking title page from the Title, Subtitle and Composer information entered on your score
* It lets you choose from a number of different templates/styles, many of which have been loosely modelled on professional music publishers’ house styles.
* **MN Create Title Page** will also, if required, automatically create a ‘front matter page’, with boilerplate text entered for you to populate (e.g. programme note, performance notes, instrumentation, etc.)

***

### <img width="200px" src="MNMakeRecommendedLayoutChanges.png" alt="Check Make Recommended Layout Changes" style="vertical-align:top; margin-right:10px"> MN MAKE RECOMMENDED LAYOUT CHANGES

* **MN Make Recommended Layout Changes** automatically applies some key layout settings, as recommended by composer Michael Norris, such as:
  * **Spacing and layout**: staff size (based on the number of instruments), page margins, barline width, minimum bar width, spacing ratio, some style settings not optimal, bar number on first bar, staff spacing, system spacing, removes any manually added layout breaks, first system indentation
  * **Parts**: staff size (based on the number of instruments), page margins, barline width, minimum bar width, spacing ratio, some style settings not optimal, bar number on first bar, staff spacing, system spacing, first system indentation, multimeasure rests, multirest width
  * **Staff names and order**: Sets staff name visibility appropriate to ensemble size  * **Fonts**: sets music font to Bravura, sets all tuplet, bar number, technique, expression font to Times New Roman, part name frame and padding, page number style to plain
  * **Other**: slur line width, title frame height and distance to music***

## <a id="installation"></a>Installation

*MN Utility Plugins require MuseScore Studio 4.4 or later.*
* **Download** the project as a zip file either from the green Code button above, or from the direct download link below.
* **Extract it** using archive extraction software
* **Move the entire folder** into MuseScore’s plugins folder, configurable at [Preferences→General→Folders](https://musescore.org/en/handbook/4/preferences). The default directories are:
    * **Mac OS**: ~/Documents/MuseScore4/Plugins/
    * **Windows**: C:\Users\YourUserName\Documents\MuseScore4\Plugins\
    * **Linux**: ~/Documents/MuseScore4/Plugins
* **Open MuseScore** or quit and relaunch it if it was already open
* Click **Home→Plugins** or **Plugins→Manage plugins...**
* For each of the MN Utility plugins, click on their icon and click ‘**Enable**’
* The plugins should now be available from the **Plugins** menu

### Direct Download

Direct downloads of the Zip file can be found on the [releases page](https://github.com/mnorrisvuw/MN-Utility-Plugins-for-MuseScore/releases).

## <a id="use"></a>How to use
* **MN Create Title Page**: Before running this plug-in, make sure you have a vertical frame at the top of your first page of music which has the title of the piece, a subtitle (e.g. ‘for string quartet’) and the composer’s name. The plug-in will use this information to create a new, styled title page.

* **MN Make Recommended Layout Changes**: You can run this plug-in at any time; however, it’s recommend to ensure .



## <a id="feedback"></a>Feedback, requests and bug reports

* Please send all feedback, feature requests and bug reports to michael.norris@vuw.ac.nz

* For bug reports, especially the ‘non-completion bugs’ mentioned above (i.e. the final dialog box does not show), **please send me your MuseScore file and the name of the plug-in.**



## License

This project is licensed under the terms of the GNU General Public License v3.0.  
See [LICENSE](LICENSE) for details.
