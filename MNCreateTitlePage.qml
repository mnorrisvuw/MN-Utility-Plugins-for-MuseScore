/*
 * Copyright (C) 2025 Michael Norris
 *
 */

// this version requires MuseScore Studio 4.4 or later

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.15
import Muse.UiComponents 1.0
import FileIO 3.0


MuseScore {
	version:  "1.0"
	description: "This plugin automatically creates a title page based on the horizontal frame at the top of the page"
	menuPath: "Plugins.MNCreateTitlePage";
	requiresScore: true
	title: "MN Create Title Page"
	id: mncreatetitlepage
	thumbnailName: "MNCreateTitlePage.png"	
	property var selectionArray: [];

  onRun: {
		if (!curScore) return;
		
		var theTitle = '';
		var theSubtitle = '';
		var theComposer = '';
		var mainVbox = null;
		var spatium = curScore.style.value("spatium")*25.4/mscoreDPI;
		
		// ** CHECK THERE ISN’T ALREADY A TITLE PAGE ** //
		var firstBarInScore = curScore.firstMeasure;
		var firstPageOfMusic = firstBarInScore.parent.parent;
		
		// RETURN IF THERE'S ALREADY A TITLE PAGE (DO SOMETHING HERE)
		if (firstPageOfMusic.pagenumber > 1) return;

		// ** SAVE CURRENT SELECTION ** //
		saveSelection();
		
		// ** BEGIN BY GETTING THE INFO ON THE TOP PAGE ** //
		curScore.startCmd();
		curScore.selection.selectRange(0,curScore.lastSegment.tick + 1,0,curScore.nstaves);

		
		// ** SELECT ALL THE SCORE TEXT ** //
		cmd ("insert-vbox");
		var vbox = curScore.selection.elements[0];
		cmd ("title-text");
		var tempText = curScore.selection.elements[0];
		cmd ("select-similar");
		var elems = curScore.selection.elements;
		
		for (var i = 0; i < elems.length; i++) {
			var e = elems[i];
			if (!e.is(tempText)) {
				//logError ("Found text object "+e.text);
				var eSubtype = e.subtypeName();
				if (eSubtype == 'Title') {
					theTitle = e.text;
					mainVbox = e.parent;
				}
				if (eSubtype == 'Subtitle') theSubtitle = e.text;
				if (eSubtype == 'Composer') theComposer = e.text;
			}
		}
		if (vbox != null) removeElement (vbox);
				
		// add another vbox
		cmd ("insert-vbox");
		var titlePageBox = curScore.selection.elements[0];
		cmd ("page-break");
		var newTitle = null;
		if (theTitle !== '') {
			cmd ("title-text");
			newTitle = curScore.selection.elements[0];
			newTitle.text = theTitle;
		}
		var newSubtitle = null;
		if (theSubtitle != '') {
			cmd ("subtitle-text");
			newSubtitle = curScore.selection.elements[0];
			newSubtitle.text = theSubtitle;
		}
		var newComposer = null;
		if (theComposer != '') {
			cmd ("composer-text");
			newComposer = curScore.selection.elements[0];
			newComposer.text = theComposer;
		}
		cmd ("title-text");
		var newLine = curScore.selection.elements[0];
		newLine.text = "———————————————————————";
		cmd ("escape");
		cmd ("escape");
		var titlePage = titlePageBox.parent;
		var titlePageHeight = titlePage.bbox.height;
		//titlePage.bbox.height = 150;
		
		// NOW ALIGN TEXT
		if (newTitle != null) {
			//newTitle.offsetY = 120 / spatium;
			newTitle.fontSize = 28.0;
			newTitle.fontStyle = 2;
			newTitle.align = Align.CENTER;
		}
		if (newSubtitle != null) {
			//newSubtitle.offsetY = 130 / spatium;
			newSubtitle.fontSize = 22.0;
			newSubtitle.align = Align.CENTER;
		}
		if (newLine != null) {
			newLine.offsetY = -30 / spatium;
			newLine.fontSize = 20.0;
			newLine.align = Align.CENTER;
		}
		if (newComposer != null) {
			newComposer.offsetY = -60 / spatium;
			newComposer.fontSize = 36.0;
			newComposer.align = Align.CENTER;
		}
		titlePageBox.boxHeight = 300; //titlePageHeight - (titlePageBox.pagePos.y * 2);

		curScore.endCmd();
		dialog.msg = '<p>Title page created.</p><p>IMPORTANT: In order to remove the title page from the parts, please select the title page frame and tick ‘Properties→Exclude from parts’ (I cannot do this automatically).</p>';
		dialog.show();
		//restoreSelection();
	}
	
	function saveSelection () {
		selectionArray = [];
		if (curScore.selection.isRange) {
			selectionArray[0] = curScore.selection.startSegment.tick;
			selectionArray[1] = curScore.selection.endSegment.tick;
			selectionArray[2] = curScore.selection.startStaff;
			selectionArray[3] = curScore.selection.endStaff;
		}
	}
	
	function restoreSelection () {
		if (selectionArray.length == 0) {
			curScore.selection.clear();
		} else {
			var st = selectionArray[0];
			var et = selectionArray[1];
			var ss = selectionArray[2];
			var es = selectionArray[3];
			curScore.selection.selectRange(st,et+1,ss,es + 1);
		}
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
}
