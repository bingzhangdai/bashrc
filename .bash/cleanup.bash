# cleanup
for handle in $CLEANUP_HANDLER; do
    if declare -F "$handle" > /dev/null; then
        $handle
        unset -f $handle
    else
        log WARN "cannot find cleanup callback: '$handle'"
    fi
done

unset handle
unset CLEANUP_HANDLER
