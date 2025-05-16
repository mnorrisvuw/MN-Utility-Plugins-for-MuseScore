/*
 * Copyright (C) 2025 Michael Norris
 *
 */

// this version requires MuseScore Studio 4.4 or later

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Muse.UiComponents 1.0
import FileIO 3.0

MuseScore {
	version:  "1.0"
	description: "This plugin automatically makes recommended layout changes to the score, based on preferences curated by Michael Norris"
	menuPath: "Plugins.MNMakeRecommendedLayoutChanges"
	requiresScore: true
	title: "MN Make Recommended Layout Changes"
	id: mnmakerecommendedlayoutchanges
	thumbnailName: "MNMakeRecommendedLayoutChanges.png"	
	property var selectionArray: null
	property var firstMeasure: null
	property var numParts: 0
	property var isSoloScore: false
	property var inchesToMM: 25.4
	property var mmToInches: 0.039370079
	property var excerpts: null
	property var numExcerpts: 0
	property var amendedParts: false
	property var removeLayoutBreaksOption: false
	property var setSpacingOption: false
	property var setBravuraOption: false
	property var setTimesOption: false
	property var setFontSizesOption: false
	property var setPartsOption: false
	property var removeStretchesOption: false
	property var setTitleFrameOption: false
	property var formatTempoMarkingsOption: false
	property var spatium: 0
	
	onRun: {
		if (!curScore) return;
		
		// Show the options window
		options.open();		
	}
	
	function makeChanges() {
		removeLayoutBreaksOption = options.removeBreaks;
		setSpacingOption = options.setSpacing;
		setBravuraOption = options.setBravura;
		setTimesOption = options.setTimes;
		setFontSizesOption = options.setFontSizes;
		setPartsOption = options.setParts;
		setTitleFrameOption = options.setTitleFrame;
		removeStretchesOption = options.removeStretches;
		formatTempoMarkingsOption = options.formatTempoMarkings;
		options.close();
		
		var finalMsg = '';
		// get some variables
		spatium = curScore.style.value("spatium")*inchesToMM/mscoreDPI;


		curScore.startCmd();
		// select all
		doCmd ("select-all");
		firstMeasure = curScore.firstMeasure;
		var visibleParts = [];
		// ** calculate number of parts, but ignore hidden ones
		for (var i = 0; i < curScore.parts.length; i++) if (curScore.parts[i].show) visibleParts.push(curScore.parts[i]);
		numParts = visibleParts.length;
		isSoloScore = numParts == 1;
		excerpts = curScore.excerpts;
		numExcerpts = excerpts.length;
		if (numParts > 1 && numExcerpts < numParts) finalMsg = "<b>NOTE</b>: Parts for this score have not yet been created/opened, so I wasn’t able to change the part layout settings.\nYou can create them by clicking ‘Parts’, then ’Open All’. Once you have created and opened the parts, please run this plug-in again on the score to change the part layout settings. (Ignore this if you do not plan to create parts.)";
		
		// REMOVE LAYOUT BREAKS
		if (removeLayoutBreaksOption || removeStretchesOption) removeLayoutBreaksAndStretches();
		
		// SET ALL THE SPACING-RELATED SETTINGS
		if (setSpacingOption) setSpacing();
		
		// SET ALL THE OTHER STYLE SETTINGS
		if (setOtherStyleSettings) setOtherStyleSettings();
		
		// FONT SETTINGS
		if (setTimesOption) setTimes();
		if (setBravuraOption) setBravura();
		if (setFontSizesOption) setFontSizes();
		if (formatTempoMarkingsOption) formatTempoMarkings();
		
		// LAYOUT THE TITLE FRAME ON p. 1
		if (setTitleFrameOption) setTitleFrame();
		
		// SET PART SETTINGS
		if (setPartsOption) setPartSettings();
		
		
		// CHANGE INSTRUMENT NAMES
		//changeInstrumentNames();
		
		// SELECT NONE
		
		curScore.endCmd();
		cmd ('escape');
		cmd ('escape');
		cmd ('concert-pitch');
		cmd ('concert-pitch');
		var dialogMsg = '';
		if (amendedParts) {
			dialogMsg = '<p>Changes to the layout of the score and parts were made successfully.</p><p><b>NOTE</b>: If your parts were open, you may need to close and re-open them if the layout changes have not been updated.</p><p>Note that some changes may not be optimal, and further tweaks are likely to be required.</p>';
		} else {
			dialogMsg = '<p>Changes to the layout of the score were made successfully.</p><p>Note that some changes may not be optimal, and further tweaks are likely to be required.</p>';
			if (finalMsg != '') dialogMsg = dialogMsg + '<p>' + finalMsg + '</p>';
		}
		dialog.msg = dialogMsg;
		dialog.show();
	}
	
	function removeLayoutBreaksAndStretches () {
		var currMeasure = firstMeasure;
		var breaks = [];
		while (currMeasure) {
			if (removeLayoutBreaksOption) {
				var elems = currMeasure.elements;
				for (var i = 0; i < elems.length; i ++) if (elems[i].type == Element.LAYOUT_BREAK) breaks.push(elems[i]);
			}
			if (removeStretchesOption) if (currMeasure.userStretch != 1) currMeasure.userStretch = 1;
			
			currMeasure = currMeasure.nextMeasure;
		}
		for (var i = 0; i < breaks.length; i++ ) removeElement (breaks[i]);
	}
	
	function deleteObj (theElem) {
		//curScore.startCmd ();
		removeElement (theElem);
		//curScore.endCmd ();
	}
	
	function changeInstrumentNames () {
		// *** NEEDS API TO CHANGE TO BE WRITEABLE *** //
		/*
		var namesToChange = ["violin 1", "violins 1", "violin 2", "violins 2", "violas", "violas 1", "violas 2", "violoncellos", "cellos 1", "cellos 2", "contrabass", "contrabasses", "vlns. 1", "vln. 1", "vlns 1", "vln 1", "vn. 1", "vn 1", "vlns. 2", "vln. 2", "vlns 2", "vln 2", "vn. 2", "vlas. 1", "vla. 1", "vlas 1", "vla 1", "va. 1", "va 1", "vn 2", "vcs 1", "vcs. 1", "vc 1", "vcs. 1", "cellos 1", "vcs 2", "vcs. 2", "vc 2", "vcs. 2", "cellos 2", "vlas.", "vlas", "vcs.", "vcs", "cb", "cb.", "cbs", "cbs.", "db", "dbs", "db.", "dbs.","d.bs.","d.b.s"];
		
		var namesToChangeTo = ["Violin I", "Violin I", "Violin II", "Violin II", "Viola", "Viola I", "Viola II", "Cello", "Cello I", "Cello II", "Double Bass", "Double Bass", "Vn. I", "Vn. I", "Vn. I", "Vn. I", "Vn. I", "Vn. I", "Vn. II", "Vn. II", "Vn. II", "Vn. II", "Vn. II", "Vn. II", "Va. I", "Va. I", "Va. I", "Va. I", "Va. I", "Va. I", "Va. II", "Va. II", "Va. II", "Va. II", "Va. II", "Va. II", "Cello I", "Cello I", "Cello I", "Cello I", "Cello I", "Cello II", "Cello II", "Cello II", "Cello II", "Cello II", "Viola", "Viola", "Cello", "Cello", "D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B."];
		
		for (var i = 0; i < curScore.nstaves; i++) {
			var theStaff = curScore.staves[i];
			var fullStaffName = theStaff.part.longName.toLowerCase();
			var shortStaffName = theStaff.part.shortName.toLowerCase();
			var fullIndex = namesToChange.indexOf(fullStaffName);
			var shortIndex = namesToChange.indexOf(shortStaffName);
			var inst = theStaff.part.instrumentAtTick(0);
			if (fullIndex > -1 && fullIndex < namesToChangeTo.length) inst.longName = namesToChangeTo[fullIndex];
			if (shortIndex > -1 && shortIndex < namesToChangeTo.length) inst.shortName = namesToChangeTo[shortIndex];
		}*/
	}
	
	
	
	function setSpacing() {

		// change staff spacing
		// change min and max system distance
		setSetting ("minSystemDistance", 6.0);
		setSetting ("maxSystemDistance", 9.0);
		var lrMargin = 12.;
		var tbMargin = 15.;
		var lrIn = lrMargin*mmToInches;
		var tbIn = tbMargin*mmToInches;
		setSetting("pageEvenLeftMargin",lrIn);
		setSetting("pageOddLeftMargin",lrIn);
		setSetting("pageEvenTopMargin",tbIn);
		setSetting("pageOddTopMargin",tbIn);
		setSetting("pageEvenBottomMargin",tbIn);
		setSetting("pageOddBottomMargin",tbIn);
		var pageWidth = curScore.style.value("pageWidth") * inchesToMM;
		var pagePrintableWidth = (pageWidth - 2 * lrMargin) * mmToInches;
		setSetting("pagePrintableWidth",pagePrintableWidth);
		setSetting("staffLowerBorder",0);
		setSetting("frameSystemDistance",8);
		//setSetting("pagePrintableHeight",10/inchesToMM);
		
		// TO DO: SET SPATIUM
		// **** TEST 1B: CHECK STAFF SIZE ****)
		var staffSize = 6.8;
		if (numParts == 2) staffSize = 6.3;
		if (numParts == 3) staffSize = 6.2;
		if (numParts > 3 && numParts < 8) staffSize = 5.6 - Math.floor((numParts - 4) * 0.5) / 10.;
		if (numParts > 7) {
			staffSize = 5.2 - Math.floor((numParts - 8) * 0.5) / 10.;
			if (staffSize < 3.7) staffSize = 3.7;
		}
		var newSpatium = staffSize / 4.0;
		
		setSetting ("spatium",newSpatium/inchesToMM*mscoreDPI);
		spatium = curScore.style.value("spatium")*inchesToMM/mscoreDPI;

		// SET STAFF NAME VISIBILITY
		setSetting ("hideInstrumentNameIfOneInstrument",1);
		setSetting ("firstSystemInstNameVisibility",0);
		setSetting ("subsSystemInstNameVisibility",1);
		setSetting ("subsSystemInstNameVisibility", (numParts < 6) ? 2: 1);
		setSetting ("enableIndentationOnFirstSystem", !isSoloScore);
		setSetting ("enableVerticalSpread", 1);
		
		// STAFF SPACING
		setSetting ("minStaffSpread", 5);
		setSetting ("maxStaffSpread", isSoloScore ? 6 : 10);
		
		// SYSTEM SPACING
		setSetting ("minSystemSpread", isSoloScore ? 6 : 12);
		setSetting ("maxSystemSpread", isSoloScore ? 14 : 32);		
	}
	
	function setOtherStyleSettings() {
		
		// BAR SETTINGS
		setSetting ("minMeasureWidth", isSoloScore ? 14.0 : 16.0);
		setSetting ("measureSpacing",1.5);
		setSetting ("barWidth",0.16);
		setSetting ("showMeasureNumberOne", 0);
		setSetting ("minNoteDistance", isSoloScore ? 1.1 : 0.6);
		setSetting ("staffDistance", 5);
		setSetting ("barNoteDistance",1.4);
		setSetting ("barAccidentalDistance",0.8);

		
		// SLUR SETTINGS
		setSetting ("slurEndWidth",0.06);
		setSetting ("slurMidWidth",0.16);
		
		//setSetting("staffLowerBorder");
		setSetting ("lastSystemFillLimit", 0);
		setSetting ("crossMeasureValues",0);
		setSetting ("tempoFontStyle", 1);
		setSetting ("metronomeFontStyle", 0);
		setSetting ("staffLineWidth",0.1);
	}
	
	function setPartSettings () {
		
		if (isSoloScore || numExcerpts < numParts) return;
		var newSpatium = (6.8 / 4) / inchesToMM*mscoreDPI;
		
		for (var i = 0; i < numExcerpts; i++) {
			var thePart = excerpts[i];
			if (thePart != null) {
				setPartSetting (thePart, "spatium", newSpatium);
				setPartSetting (thePart, "enableIndentationOnFirstSystem", 0);
				setPartSetting (thePart, "enableVerticalSpread", 1);
				setPartSetting (thePart, "minSystemSpread", 6);
				setPartSetting (thePart, "maxSystemSpread", 11);
				setPartSetting (thePart, "minStaffSpread", 6);
				setPartSetting (thePart, "maxStaffSpread", 11);
				setPartSetting (thePart, "frameSystemDistance", 8);
				setPartSetting (thePart, "lastSystemFillLimit", 0);
				setPartSetting (thePart, "minNoteDistance", 1.3);
				setPartSetting (thePart, "createMultiMeasureRests", 1);
				setPartSetting (thePart, "minEmptyMeasures", 2);
				setPartSetting (thePart, "minMMRestWidth", 18);
				setPartSetting (thePart, "partInstrumentFrameType", 1);
				setPartSetting (thePart, "partInstrumentFramePadding", 0.8);
				
				if (setFontSizesOption) {
					setPartSetting (thePart, "tupletFontStyle", 2);
					setPartSetting (thePart, "tupletFontSize", 11);
					setPartSetting (thePart, "measureNumberFontSize", 8.5);
					setPartSetting (thePart, "pageNumberFontStyle",0);
					var fontsToTwelvePoint = ["longInstrument", "shortInstrument", "partInstrument", "tempo", "tempoChange", "metronome", "pageNumber", "expression", "staffText", "systemText", "rehearsalMark"];
					for (var j = 0; j < fontsToTwelvePoint.length; j++) setPartSetting (thePart, fontsToTwelvePoint[j]+"FontSize", 12);
				}
				
				if (setBravuraOption) {
					setPartSetting (thePart, "musicalSymbolFont", "Bravura");
					setPartSetting (thePart, "musicalTextFont", "Bravura Text");
				}
				
				if (setTimesOption) {
					var fontsToTimes = ["tuplet", "lyricsOdd", "lyricsEven", "hairpin", "romanNumeral", "volta", "stringNumber", "longInstrument", "shortInstrument","expression", "tempo", "tempoChange", "metronome", "measureNumber", "mmRestRange", "systemText", "staffText", "pageNumber", "instrumentChange"];
					for (var j = 0; j < fontsToTimes.length; j++) setPartSetting (thePart, fontsToTimes[j]+"FontFace", "Times New Roman Accidentals");
				}
				
				if (removeLayoutBreaksOption) {
					var currMeasure = thePart.partScore.firstMeasure;
					var breaks = [];
					while (currMeasure) {
						var elems = currMeasure.elements;
						for (var j = 0; j < elems.length; j ++) if (elems[j].type == Element.LAYOUT_BREAK) breaks.push(elems[j]);
						currMeasure = currMeasure.nextMeasure;
					}
					for (var j = 0; j < breaks.length; j++ ) removeElement (breaks[j]);
				}
			}
		}
		amendedParts = true;
		
	}
	
	function setFontSizes() {
		setSetting ("tupletFontStyle", 2);
		setSetting ("tupletFontSize", 11);
		setSetting ("measureNumberFontSize", 8.5);
		setSetting ("pageNumberFontStyle",0);
		setSetting ("titleFontSize", 24);
		setSetting ("subTitleFontSize", 13);
		setSetting ("composerFontSize", 10);
		setSetting ("partInstrumentFrameType", 1);
		setSetting ("partInstrumentFramePadding", 0.8);
		
		if (spatium > 1.5) {
			setSetting ("tempoFontSize", 12);
			setSetting ("tempoChangeFontSize", 12);
		} else {
			setSetting ("tempoFontSize", 13);
			setSetting ("tempoChangeFontSize", 13);
		}
		
		var fontsToTwelvePoint = ["longInstrument", "shortInstrument", "partInstrument", "metronome", "pageNumber", "expression", "staffText", "systemText", "rehearsalMark"];
		for (var i = 0; i < fontsToTwelvePoint.length; i++) setSetting (fontsToTwelvePoint[i]+"FontSize", 12);
	}
	
	function setBravura () {
		setSetting ("musicalSymbolFont", "Bravura");
		setSetting ("musicalTextFont", "Bravura Text");
	}
	
	function setTimes () {
		var fontsToTimes = ["tuplet", "lyricsOdd", "lyricsEven", "hairpin", "romanNumeral", "volta", "stringNumber","expression", "tempo", "tempoChange", "metronome", "measureNumber", "mmRestRange", "systemText", "staffText", "pageNumber"];
		for (var i = 0; i < fontsToTimes.length; i++) setSetting (fontsToTimes[i]+"FontFace", "Times New Roman");
		var fontsToTimes = ["longInstrument", "shortInstrument", "instrumentChange"];
		for (var i = 0; i < fontsToTimes.length; i++) setSetting (fontsToTimes[i]+"FontFace", "Times New Roman Accidentals");
	}
	
	function setTitleFrame () {
		doCmd ("select-all");
		doCmd ("insert-vbox");
		var vbox = curScore.selection.elements[0];
		doCmd ("title-text");
		var tempText = curScore.selection.elements[0];
		doCmd ("select-similar");
		var elems = curScore.selection.elements;
		var firstPageNum = firstMeasure.parent.parent.pagenumber;
		var topbox = null;
		for (var i = 0; i < elems.length; i++) {
			var e = elems[i];
			if (!e.is(tempText)) {
				//logError ("Found text object "+e.text);
				var eSubtype = e.subtypeName();
				if (eSubtype == "Title" && getPageNumber(e) == firstPageNum) {
					e.align = Align.HCENTER;
					e.offsetY = 0;
					e.offsetX = 0.;
					topbox = e.parent;
				}
				if (eSubtype == "Subtitle" && getPageNumber(e) == firstPageNum) {	
					e.align = Align.HCENTER;
					e.offsetY = 10. / spatium;
					e.offsetX = 0.;
				}
				if (eSubtype == "Composer" && getPageNumber(e) == firstPageNum) {
					e.text = e.text.toUpperCase();
					e.align = Align.BOTTOM | Align.RIGHT;
					e.offsetY = 0;
					e.offsetX = 0;
				}
			}
		}
		if (vbox == null) {
			logError ("checkScoreText () — vbox was null");
		} else {
			deleteObj (vbox);
		}
		if (topbox != null) {
			
			//curScore.startCmd ();
			topbox.autoscale = 0;
			topbox.boxHeight = 15;
			//curScore.endCmd ();
		}
	}
	
	function formatTempoMarkings () {
		doCmd ('select-all');
		var elems = curScore.selection.elements;
		var r = new RegExp('(.*?)(<sym>metNoteQuarterUp<\/sym>|<sym>metNoteHalfUp<\/sym>|<sym>metNote8thUp<\/sym>|\\uECA5|\\uECA7|\\uECA3)(.*?)( |\\u00A0|\\u2009)=( |\\u00A0|\\u2009)');
		var f = new RegExp('<\/?font.*?>','g');
		for (var i = 0; i < elems.length; i++) {
			var e = elems[i];
			if (e.type == Element.TEMPO_TEXT) {
				var t = e.text;
				if (t.match(r) && !t.includes('<b>')) {
					e.fontStyle = 0;
					//e.text = t.replace(r,'BOB'));
					// delete all font tags
					t = t.replace (f,'');
					if (t.match(r)[1] === '') {
						e.text = t.replace(r,'$2$3\u2009=\u2009');
					} else {
						e.text = '<b>'+t.replace(r,'$1</b>$2$3\u2009=\u2009');
					}
				}
			}
		}
	}
	
	function doCmd (theCmd) {
		//curScore.startCmd ();
		cmd (theCmd);
		//curScore.endCmd ();
	}
	
	function setSetting (theSetting, theValue) {
		if (curScore.style.value(theSetting) == theValue) return;
		curScore.style.setValue(theSetting,theValue);
	}
	
	function setPartSetting (thePart, theSetting, theValue) {
		if (thePart.partScore.style.value(theSetting) == theValue) return;
		if (thePart.partScore == null) return;
		thePart.partScore.style.setValue(theSetting,theValue);
	}
	
	function getPageNumber (e) {
		var p = e.parent;
		var ptype = null;
		if (p != null) ptype = p.type;
		while (p && ptype != Element.PAGE) {
			p = p.parent;
			if (p != null) ptype = p.type;
		}
		if (p != null) {
			return p.pagenumber;
		} else {
			return 0;
		}
	}
	
	StyledDialogView {
		id: dialog
		title: "CHECK COMPLETED"
		contentHeight: 300
		contentWidth: 500
		property var msg: ""
	
		Text {
			id: theText
			width: parent.width-40
			x: 20
			y: 20
	
			text: "MN MAKE RECOMMENDED LAYOUT CHANGES"
			font.bold: true
			font.pointSize: 18
		}
		
		Rectangle {
			x:20
			width: parent.width-45
			y:45
			height: 1
			color: "black"
		}
	
		ScrollView {
			id: view
			x: 20
			y: 60
			height: parent.height-100
			width: parent.width-40
			leftInset: 0
			leftPadding: 0
			ScrollBar.vertical.policy: ScrollBar.AsNeeded
			TextArea {
				height: parent.height
				textFormat: Text.RichText
				text: dialog.msg
				wrapMode: TextEdit.Wrap
				leftInset: 0
				leftPadding: 0
				readOnly: true
			}
		}
	
		ButtonBox {
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				margins: 10
			}
			buttons: [ ButtonBoxModel.Ok ]
			navigationPanel.section: dialog.navigationSection
			onStandardButtonClicked: function(buttonId) {
				if (buttonId === ButtonBoxModel.Ok) {
					dialog.close()
				}
			}
		}
	}
	
	StyledDialogView {
		id: options
		title: "MN MAKE RECOMMENDED LAYOUT CHANGES"
		contentHeight: 420
		contentWidth: 480
		property color backgroundColor: ui.theme.backgroundSecondaryColor
		property var removeBreaks: true
		property var setSpacing: true
		property var setBravura: true
		property var setOtherStyleSettings: true
		property var setTimes: true
		property var setTitleFrame: true
		property var setFontSizes: true
		property var setParts: true
		property var removeStretches: true
		property var formatTempoMarkings: true
	
		Text {
			id: styleText
			anchors {
				left: parent.left;
				leftMargin: 20;
				top: parent.top;
				topMargin: 20;
			}
			text: "Options"
			font.bold: true
			font.pointSize: 18
		}
		
		Rectangle {
			id: rect
			anchors {
				left: styleText.left;
				top: styleText.bottom;
				topMargin: 10;
			}
			width: parent.width-45
			height: 1
			color: "black"
		}
		
		GridLayout {
			id: grid
			columns: 2
			columnSpacing: 15
			rowSpacing: 15
			width: 280
			anchors {
				left: rect.left;
				top: rect.bottom;
				topMargin: 10;
			}
			Text {
				id: layoutLabel
				text: "Change layout"
				font.bold: true
				Layout.columnSpan: 2
			}
			CheckBox {
				text: "Remove existing layout breaks"
				checked: options.removeBreaks
				onClicked: {
					checked = !checked
					options.removeBreaks = checked
				}
			}
			CheckBox {
				text: "Tweak title frame layout"
				checked: options.setTitleFrame
				onClicked: {
					checked = !checked
					options.setTitleFrame = checked
				}
			}
			CheckBox {
				text: "Set staff/system spacing"
				checked: options.setSpacing
				onClicked: {
					checked = !checked
					options.setSpacing = checked
				}
			}
			CheckBox {
				text: "Change layout for all parts"
				checked: options.setParts
				onClicked: {
					checked = !checked
					options.setParts = checked
				}
			}
			CheckBox {
				text: "Remove all measure stretches"
				checked: options.removeStretches
				onClicked: {
					checked = !checked
					options.removeStretches = checked
				}
			}
			CheckBox {
				text: "Change style settings"
				checked: options.setOtherStyleSettings
				onClicked: {
					checked = !checked
					options.setOtherStyleSettings = checked
				}
			}
			
			Text {
				text: "Change fonts"
				font.bold: true
				Layout.columnSpan: 2
			}
			
			CheckBox {
				text: "Set music font to Bravura"
				checked: options.setBravura
				onClicked: {
					checked = !checked
					options.setBravura = checked
				}
			}
			CheckBox {
				text: "Set text font to Times New Roman*"
				checked: options.setTimes
				onClicked: {
					checked = !checked
					options.setTimes = checked
				}
			}
			CheckBox {
				text: "Set recommended font sizes"
				checked: options.setFontSizes
				onClicked: {
					checked = !checked
					options.setFontSizes = checked
				}
			}
			CheckBox {
				text: "Format tempo markings"
				checked: options.formatTempoMarkings
				onClicked: {
					checked = !checked
					options.formatTempoMarkings = checked
				}
			}
		}
		
		Text {
			text : '<p>*Requires installation of custom font ‘Times New Roman Accidentals’<br />(provided in download folder)</p>'
			textFormat: Text.RichText
			anchors {
				left: grid.left
				top: grid.bottom
				topMargin: 36
			}
		}
		
		ButtonBox {
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				margins: 10
			}
			buttons: [ ButtonBoxModel.Cancel, ButtonBoxModel.Ok ]
			navigationPanel.section: dialog.navigationSection
			onStandardButtonClicked: function(buttonId) {
				if (buttonId === ButtonBoxModel.Cancel) {
					options.close()
				}
				if (buttonId === ButtonBoxModel.Ok) {
					makeChanges()
				}
			}
		}
		
		
	}
}