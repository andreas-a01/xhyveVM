.PHONY: path vmdir setup clean

xhyvevm:
	@echo "Create executable"
	mkdir -p bin
	(cd bin; ln -sf ../scripts/xhyvevm.rb xhyvevm; chmod +x xhyvevm)
	@echo ""

path: xhyvevm
	@echo "Run the following to xhyvevm to your PATH:"
	@echo 'export PATH=$${PATH}:$${PWD}/bin'

vmdir:
	@echo "Create VMs dir"
	mkdir -p ~/xhyveVM/
	@echo ""

setup: vmdir path

clean:
	${RM} -r bin/
