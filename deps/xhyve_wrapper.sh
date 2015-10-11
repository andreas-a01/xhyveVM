echo $$ > xhyve_wrapper.pid
xhyve $@
rm xhyve_wrapper.pid
