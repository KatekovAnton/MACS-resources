
.PHONY: configure_mac
configure_mac:
	mkdir -p ToolsForNewGraphics/build && cd ToolsForNewGraphics/build && cmake -G Ninja ..

.PHONY: configure
configure:
	mkdir -p ToolsForNewGraphics/build && cd ToolsForNewGraphics/build && cmake -G Xcode ..

