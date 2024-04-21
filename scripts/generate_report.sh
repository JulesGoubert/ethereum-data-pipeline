#! /bin/bash

set -o errexit   
set -o nounset
set -o pipefail

# generate markdown report
template=../template.md
mkdocs_index=../reports/docs/index.md
md_report=../reports/ethereum-gas-report.md

sed -e "s|DATE|report generated on $(date)|" "${template}" > "${md_report}"
sed -e "s|DATE|report generated on $(date)|" "${template}" > "${mkdocs_index}"

for file in ../reports/docs/images/*; do
    placeholder=$(echo "${file}" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
    filepath=$(echo "${file}" | awk -F/ '{print $4"/"$5}')
    sed -i -e "s|${placeholder}|![${placeholder}](${filepath})|" "${mkdocs_index}"
    sed -i -e "s|${placeholder}|![${placeholder}](${file})|" "${md_report}"
done

for file in ../tables/*; do
    placeholder=$(echo "$file" | awk -F/ '{print $NF}' | awk -F. '{print $1}')
    sed -i "/${placeholder}/ {
        r ${file}
        d
    }" "${mkdocs_index}"
    sed -i "/${placeholder}/ {
        r ${file}
        d
    }" "${md_report}"
done

# generate pdf report
pdf_report="${md_report//.md/.pdf}"

pandoc "${md_report}" -o "${pdf_report}"

# generate mkdocs report
cd ../reports
mkdocs build
# mkdocs serve
