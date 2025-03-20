export ARGUMENTS=${@} &&
  ${JQ} -n -f ${TEMPLATE_FILE} | ${YQ} --yaml-output > /singleton/file
