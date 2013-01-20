enyo.kind({
	name: "AddressBar",
	kind: "onyx.InputDecorator",
	style: "position: absolute;",
	events: {
		onAddressChanged: ""
	},
	components: [
		{kind: "Signals", onkeydown: "handleKeyDown"},
		{name: "Input",
		kind: "onyx.Input",
		onfocus: "inputFocus",
		onblur: "inputBlur",
		style: "width: 100%; height: 100%; margin-left: 8px; margin-right: 8px; font-size: 16pt;",
		onkeydown: "handleKeyDown"}
	],
	handleKeyDown: function(inSender, inEvent) {
		if(inEvent.keyCode == 13) {
			this.doAddressChanged({value: this.$.Input.getValue()});
		}
	},
	inputFocus: function(inSender, inEvent) {
		this.$.Input.applyStyle("color", "black");
	},
	inputBlur: function(inSender, inEvent) {
		this.$.Input.applyStyle("color", "white");
	}
});

enyo.kind({
	name: "App",
	layoutKind: "FittableRowsLayout",
	components: [
		{kind: "Signals", onUrlChange: "handleUrlChange"},
		{name: "AddressBarAnimator", kind: "Animator", value: 1, onStep: "animatorStep"},
		{fit: true,
		ondragstart: "dragStarted",
		components:[
			{name: "AddressBar",
			kind: "AddressBar",
			classes: "onyx-toolbar",
			style: "height: 32px; left: 10px; right: 10px; top: 10px; z-index: 10; border-radius: 32px;",
			onAddressChanged: "openAddress"},
			{name: "WebView",
			kind: "WebView",
			style: "min-width: 100%; min-height: 100%;",
			onLoadStarted: "loadStarted",
			onLoadProgress: "loadProgress",
			onLoadStopped: "loadStopped",
			onLoadComplete: "loadComplete",
			onError: "loadError"},
			{name: "ProgressOrb",
			kind: "ProgressOrb",
			min: 0,
			max: 100,
			value: 0,
			style: "right: 8px; bottom: 8px; z-index: 10;",
			content: "R",
			ontap: "progressOrbTapped",
			loading: false}
		]},
		{kind: "CoreNavi", fingerTracking: true}
	],
	//Handlers
	animatorStep: function(inSender) {
		this.$.AddressBar.applyStyle("top", -64 + (74 * inSender.value) + "px");
	},
	loadStarted: function(inSender, inEvent) {
		this.$.ProgressOrb.loading = true;
		this.$.ProgressOrb.setContent("X");
		this.$.ProgressOrb.setValue(0);
		this.$.ProgressOrb.render();
	},
	loadProgress: function(inSender, inEvent) {
		this.$.ProgressOrb.setValue(inEvent.inProgress);
	},
	loadStopped: function(inSender, inEvent) {
		this.$.ProgressOrb.loading = false;
		this.$.ProgressOrb.setContent("R");
		this.$.ProgressOrb.render();
	},
	loadComplete: function(inSender, inEvent) {
		this.$.ProgressOrb.loading = false;
		this.$.ProgressOrb.setContent("R");
		this.$.ProgressOrb.render();
	},
	loadError: function(inSender, inEvent) {
		enyo.log(JSON.stringify(inEvent));
	},
	openAddress: function(inSender, inEvent) {
		this.$.WebView.setUrl(inEvent.value);
		this.hideAddressBar();
	},
	debugLogUrl: function(inSender, inEvent) {
		enyo.log(this.$.WebView.getUrl());
	},
	//Action Handlers
	progressOrbTapped: function(inSender, inEvent) {
		if(inSender.loading) {
			this.$.WebView.stopLoad();
		}
		else {
			this.$.WebView.reloadPage();
		}
		
		this.$.ProgressOrb.setValue(0);
	},
	dragStarted: function(inSender, inEvent) {
		if(inEvent.yDirection == -1) {
			this.hideAddressBar();
		}
		else if(inEvent.yDirection == 1 && inEvent.pageY <= document.body.scrollHeight / 4) {
			this.showAddressBar();
		}
	},
	//Helper Functions
	hideAddressBar: function() {
		this.$.AddressBar.hasNode().blur();
		this.$.AddressBarAnimator.setStartValue(this.$.AddressBarAnimator.value);
		this.$.AddressBarAnimator.setEndValue(0);
		this.$.AddressBarAnimator.play();
	},
	showAddressBar: function() {
		this.$.AddressBar.hasNode().focus();
		this.$.AddressBarAnimator.setStartValue(this.$.AddressBarAnimator.value);
		this.$.AddressBarAnimator.setEndValue(1);
		this.$.AddressBarAnimator.play();
	},
	handleBackGesture: function(inSender, inEvent) {
		//this.$.AppPanels.setIndex(0);
	},
	handleCoreNaviDragStart: function(inSender, inEvent) {
		/*
		if(enyo.Panels.isScreenNarrow()) {
			this.$.AppPanels.dragstartTransition(inEvent);
		}
		*/
	},
	handleCoreNaviDrag: function(inSender, inEvent) {
		/*
		if(enyo.Panels.isScreenNarrow()) {
			this.$.AppPanels.dragTransition(inEvent);
		}
		*/
	},
	handleCoreNaviDragFinish: function(inSender, inEvent) {
		/*
		if(enyo.Panels.isScreenNarrow()) {
			this.$.AppPanels.dragfinishTransition(inEvent);
		}
		*/
	},
});
