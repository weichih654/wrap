#!/bin/bash
function make_warp() {
    local file_path=$1
    local is_wrapper=$(grep -rn "app wrapper" ${file_path} | grep -v grep)
    if [ -z "${is_wrapper}" ] && [ ! -f "${file_path}.orig" ]; then
        mv ${file_path}{,.orig}
cat << EOF > ${file_path}
#!/bin/bash
# app wrapper
echo "\`date\` \$0 \$@" >> /tmp/wrap_$(basename ${file_path}).log
ret_str=\$(${file_path}.orig "\$@" 2>&1)
ret=\$?
echo "\${ret} \${ret_str}" >> /tmp/wrap_$(basename ${file_path})_result.log
echo -e "\${ret_str}"
exit \${ret}
EOF
    fi
    chmod +x ${file_path}
}

function recover() {
    local file_path=$1
    local is_wrapper=$(grep -rn "app wrapper" ${file_path} | grep -v grep)
    if [ ! -z "${is_wrapper}" ] && [ -f "${file_path}.orig" ]; then
        rm -f ${file_path}
        mv ${file_path}.orig ${file_path}
    fi
}

if [ "$1" == "wrap" ]; then
    make_warp $2
elif [ "$1" == "recover" ]; then
    recover $2
else
    echo "nothing"
fi
