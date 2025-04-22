export ARGUMENTS_VALUE=${@} &&
  ${NOOP} &&
  ${JQ} -n -f ${TEMPLATE_FILE} | ${YQ} --yaml-output