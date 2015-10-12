echo $$ > .xhyvevm/xhyve_wrapper.pid
trap 'rm .xhyvevm/xhyve_wrapper.pid' INT EXIT
xhyve $@
