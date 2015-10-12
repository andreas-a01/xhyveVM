echo $$ > .xhyvevm/xhyve_wrapper.pid
xhyve $@
rm .xhyvevm/xhyve_wrapper.pid
