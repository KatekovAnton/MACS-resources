
.PHONY: configure
configure:
	mkdir -p ToolsForNewGraphics/build && cd ToolsForNewGraphics/build && cmake -G Ninja ..

.PHONY: configure_xc
configure_xc:
	mkdir -p ToolsForNewGraphics/build && cd ToolsForNewGraphics/build && cmake -G Xcode ..

