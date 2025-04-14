/*
 * Copyright (C) 2025 Michael Norris
 *
 */

// this version requires MuseScore Studio 4.4 or later

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Muse.Ui 1.0
import Muse.UiComponents 1.0
import FileIO 3.0

MuseScore {
	version:  "1.0"
	description: "This plugin automatically creates a title page based on the horizontal frame at the top of the page"
	menuPath: "Plugins.MNCreateTitlePage"
	requiresScore: true
	title: "MN Create Title Page"
	id: mncreatetitlepage
	thumbnailName: "MNCreateTitlePage.png"	
	property var selectionArray: []
	property var titlePageStyles: []
	property var spatium: 0
	property var theTitle: ''
	property var theSubtitle: ''
	property var theComposer: ''
	
	FileIO { id: stylesfile;
		source: Qt.resolvedUrl("./assets/styles.json").toString().slice(8);
		onError: { console.log(msg); }
	}

  onRun: {
		if (!curScore) return;
		
		spatium = curScore.style.value("spatium")*25.4/mscoreDPI;
		
		// ** CHECK THERE ISN’T ALREADY A TITLE PAGE ** //
		var firstBarInScore = curScore.firstMeasure;
		var firstPageOfMusic = firstBarInScore.parent.parent;
		
		// RETURN IF THERE'S ALREADY A TITLE PAGE (DO SOMETHING HERE)
		if (firstPageOfMusic.pagenumber > 1) {
			dialog.msg = 'This score appears to already have a title page.';
			dialog.show();
			return;	
		}
		
		checkTitle ();
		if (theTitle == '') {
			dialog.msg = 'I couldn’t find an existing title frame. Please create a standard vertical frame, and add in the Title, Subtitle and Composer texts before running this plugin.';
			dialog.show();
			return;
		}
		// *** SHOW THE TITLE PAGE STYLE DIALOG *** //
		var stylesText = stylesfile.read().trim();
		var stylesJSON = JSON.parse(stylesText);
		titlePageStyles = stylesJSON.titlepages;
		for (var i = 0; i < titlePageStyles.length; i++) {
			var titlePageStyle = titlePageStyles[i];
			var titlePageThumbnail = './thumbnails/'+titlePageStyle.thumbnail+'.png';
			var titlePageLabel = titlePageStyle.label;
			listmodel.append({src: titlePageThumbnail, label: titlePageLabel }); 
		 }
		styles.show();
	}
	
	function checkTitle () {
				
		// ** SELECT ALL THE SCORE TEXT ** //
		doCmd ("select-all");
		doCmd ("insert-vbox");
		var vbox = curScore.selection.elements[0];
		doCmd ("title-text");
		var tempText = curScore.selection.elements[0];
		doCmd ("select-similar");
		var elems = curScore.selection.elements;
		for (var i = 0; i < elems.length; i++) {
			var e = elems[i];
			if (!e.is(tempText)) {
				//logError ("Found text object "+e.text);
				var eSubtype = e.subtypeName();
				if (eSubtype == 'Title') theTitle = e.text;
				if (eSubtype == 'Subtitle') theSubtitle = e.text;
				if (eSubtype == 'Composer') theComposer = e.text;
			}
		}
		if (vbox != null) { deleteObj (vbox)};
		doCmd ("escape");
		doCmd ("escape");
	}
	
	function buttonClicked (chosenLabel) {
		
		styles.close ();
		
		var chosenTitlePageStyle = null;
		for (var i = 0; i < titlePageStyles.length && chosenTitlePageStyle == null; i++) {
			if (titlePageStyles[i].label === chosenLabel) chosenTitlePageStyle = titlePageStyles[i];
		}
		if (chosenTitlePageStyle == null) {
			dialog.msg = 'Couldn’t find chosen title page style.';
			dialog.show();
			return;
		}
		var composerStyle = chosenTitlePageStyle.composer;
		var titleStyle = chosenTitlePageStyle.title;
		var subtitleStyle = chosenTitlePageStyle.subtitle;
		var lineStyle = ("line" in chosenTitlePageStyle) ? chosenTitlePageStyle.line : null;
		var line2Style = ("line2" in chosenTitlePageStyle) ? chosenTitlePageStyle.line2 : null;	
		
		// ** SELECT ALL THE SCORE TEXT ** //
		doCmd ("select-all");
		doCmd ("insert-vbox");
		var vbox = curScore.selection.elements[0];
		doCmd ("title-text");
		doCmd ("select-similar");
		if (vbox != null) removeElement (vbox);
		// add another vbox
		doCmd ("insert-vbox");
		var titlePageBox = curScore.selection.elements[0];
		doCmd ("page-break");
		var newTitle = null;
		if (theTitle !== '') {
			doCmd ("title-text");
			newTitle = curScore.selection.elements[0];
			newTitle.text = theTitle;
		}
		var newSubtitle = null;
		if (theSubtitle != '') {
			doCmd ("subtitle-text");
			newSubtitle = curScore.selection.elements[0];
			newSubtitle.text = theSubtitle;
		}
		var newComposer = null;
		if (theComposer != '') {
			doCmd ("composer-text");
			newComposer = curScore.selection.elements[0];
			newComposer.text = theComposer;
		}
		if (lineStyle != null) {
			doCmd ("title-text");
			var newLine = curScore.selection.elements[0];
			newLine.text = "———————————————————————";
		}
		if (line2Style != null) {
			doCmd ("title-text");
			var newLine2 = curScore.selection.elements[0];
			newLine2.text = "———————————————————————";
		}
		doCmd ("escape");
		doCmd ("escape");
		var titlePage = titlePageBox.parent;
		var titlePageHeight = titlePage.bbox.height;		
		var fontStyles = {'PLAIN' : 0, 'BOLD' : 1, 'ITALIC' : 2};
		var alignStyles = {'LEFT' : Align.LEFT, 'HCENTER' : Align.HCENTER, 'RIGHT' : Align.RIGHT, 'RIGHT VCENTER' : (Align.RIGHT | Align.VCENTER), 'HCENTER BOTTOM' : (Align.HCENTER | Align.BOTTOM), 'LEFT VCENTER' : (Align.LEFT | Align.VCENTER) };
		
		// NOW SET UP THE FONT STYLING AS PER THE TEMPLATES
		
		if (newComposer != null) {
			newComposer.fontSize = ("fontsize" in composerStyle) ? composerStyle.fontsize : 32.0;
			if ("font" in composerStyle) newComposer.fontFace = composerStyle.font;
			if ("fontstyle" in composerStyle) newComposer.fontStyle = fontStyles[composerStyle.fontstyle];
			newComposer.align = ("align" in composerStyle) ? alignStyles[composerStyle.align] : Align.CENTER;
			if ("offsety" in composerStyle) newComposer.offsetY = composerStyle.offsety / spatium;
			if ("offsetx" in composerStyle) newComposer.offsetX = composerStyle.offsetx / spatium;
			if ("case" in composerStyle) {
				if (composerStyle.case == "UPPER") newComposer.text = newComposer.text.toUpperCase();
			}
		}
		if (newTitle != null) {
			newTitle.fontSize = ("fontsize" in titleStyle) ? titleStyle.fontsize : 28.0;
			if ("font" in titleStyle) newTitle.fontFace = titleStyle.font;
			if ("fontstyle" in titleStyle) newTitle.fontStyle = fontStyles[titleStyle.fontstyle];
			newTitle.align = ("align" in titleStyle) ? alignStyles[titleStyle.align] : Align.CENTER;
			if ("offsety" in titleStyle) newTitle.offsetY = titleStyle.offsety / spatium;
			if ("offsetx" in titleStyle) newTitle.offsetX = titleStyle.offsetx / spatium;
			if ("case" in titleStyle) {
				if (titleStyle.case == "UPPER") newTitle.text = newTitle.text.toUpperCase();
			}
		}
		if (newSubtitle != null) {
			newSubtitle.fontSize = ("fontsize" in subtitleStyle) ? subtitleStyle.fontsize : 22.0;
			if ("font" in subtitleStyle) newSubtitle.fontFace = subtitleStyle.font;
			if ("fontstyle" in subtitleStyle) newSubtitle.fontStyle = fontStyles[subtitleStyle.fontstyle];
			newSubtitle.align = ("align" in subtitleStyle) ? alignStyles[subtitleStyle.align] : Align.CENTER;
			if ("offsety" in subtitleStyle) newSubtitle.offsetY = subtitleStyle.offsety / spatium;
			if ("offsetx" in subtitleStyle) newSubtitle.offsetX = subtitleStyle.offsetx / spatium;
			if ("case" in subtitleStyle) {
				if (subtitleStyle.case == "UPPER") newSubtitle.text = newSubtitle.text.toUpperCase();
			}
		}
		if (newLine != null) {
			newLine.fontSize = ("fontsize" in lineStyle) ? lineStyle.fontsize : 22.0;
			if ("font" in lineStyle) newLine.fontFace = lineStyle.font;
			if ("fontstyle" in lineStyle) newLine.fontStyle = fontStyles[lineStyle.fontstyle];
			newLine.align = ("align" in lineStyle) ? alignStyles[lineStyle.align] : Align.CENTER;
			if ("offsety" in lineStyle) newLine.offsetY = lineStyle.offsety / spatium;
			if ("offsetx" in lineStyle) newLine.offsetX = lineStyle.offsetx / spatium;
		}
		
		if (newLine2 != null) {
			newLine2.fontSize = ("fontsize" in line2Style) ? line2Style.fontsize : 22.0;
			if ("font" in line2Style) newLine2.fontFace = line2Style.font;
			if ("fontstyle" in line2Style) newLine2.fontStyle = fontStyles[line2Style.fontstyle];
			newLine2.align = ("align" in line2Style) ? alignStyles[line2Style.align] : Align.CENTER;
			if ("offsety" in line2Style) newLine2.offsetY = line2Style.offsety / spatium;
			if ("offsetx" in line2Style) newLine2.offsetX = line2Style.offsetx / spatium;
		}
		curScore.startCmd();
		titlePageBox.boxHeight = 300; //titlePageHeight - (titlePageBox.pagePos.y * 2);
		curScore.endCmd();
		dialog.msg = '<p>Title page created.</p><p>IMPORTANT: If you wish to exclude the title page from the parts, please select the title page frame and tick ‘Properties→Exclude from parts’ (I cannot do this automatically).</p>';
		dialog.show();
	}
	
	function doCmd (theCmd) {
		curScore.startCmd ();
		cmd (theCmd);
		curScore.endCmd ();
	}
	
	function deleteObj (theElem) {
		curScore.startCmd ();
		removeElement (theElem);
		curScore.endCmd ();
	}

	
	StyledDialogView {
		id: dialog
		title: "CHECK COMPLETED"
		contentHeight: 232
		contentWidth: 456
		property var msg: ""
	
		Text {
			id: theText
			width: parent.width-40
			x: 20
			y: 20
	
			text: "MN CREATE TITLE PAGE"
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
		id: styles
		title: "TITLE PAGE STYLES"
		contentHeight: 550
		contentWidth: 800
		property color backgroundColor: ui.theme.backgroundSecondaryColor
		
		Rectangle {
			color: styles.backgroundColor
			anchors.fill: parent
		}
	
		Text {
			id: styleText
			width: parent.width-40
			x: 20
			y: 20
	
			text: "Choose your title page style"
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
		
		ListModel {
			id: listmodel
		}
		
		Component {
			id: listitem
			Grid {
				columns: 1
				spacing: 5
				padding: 5
				width: 280
				height: 386
				horizontalItemAlignment: Grid.AlignHCenter

				Rectangle {
					id: rect
					property var borderColor: "lightgray"
					color: "transparent"
					border.color: borderColor
					border.width: 4
					width: 272
					height: 381
					Image { 
						source: model.src
						fillMode: Image.PreserveAspectFit
						width: parent.width - 8
						x: 4
						y: 4
						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							onClicked: {
							   buttonClicked (model.label);
							}
							onEntered: {
								rect.borderColor = "gray";
							}
							onExited: {
								rect.borderColor = "lightgray";
							}
						}
					}
				}
				
				Text {
					text: model.label
				}
			}
		}
	
		ListView {
			id: stylesListView
			x: 20
			y: 60
			height: parent.height-100
			width: parent.width-40
			contentWidth: parent.width-40
			orientation: Qt.Horizontal
			model: listmodel
			delegate: listitem
			clip: true
			ScrollBar.horizontal: ScrollBar {
				policy: ScrollBar.AlwaysOn
				width: 40
			}
		}
	}
}
