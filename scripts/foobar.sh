export ARGUMENTS_VALUE=${@} &&
  ${JQ} -n -f ${TEMPLATE_FILE} | ${YQ} --yaml-output