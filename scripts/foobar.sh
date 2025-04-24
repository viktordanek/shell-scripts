export ARGUMENTS_VALUE=${@} &&
  export SINGLEOP_VALUE=$( ${SINGLEOP} ) &&
  ${JQ} -n -f ${TEMPLATE_FILE} | ${YQ} --yaml-output