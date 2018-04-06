#!/bin/bash
#############
# WPHACKFIX #
#############
# curl -s https://raw.githubusercontent.com/renatofrota/wp-hack-fix/master/wp-hack-fix.bash && bash wp-hack-fix.bash
# forcedly reinstall core
wp core download --force --version=$(wp core version)
# forcedly remove files that should not exist
for i in $(wp core verify-checksums 2>&1 | grep 'should not exist:' | cut -d : -f 3-); do rm -fv $i; done
# prevents add_filter and add_action in wp-config.php affecting wp-cli executions
sed -i 's|^add_filter|if function_exists("add_filter") add_filter|g' wp-config.php
sed -i 's|^add_action|if function_exists("add_action") add_action|g' wp-config.php
# forcedly reinstall plugins
for i in $(wp plugin list --skip-themes --skip-plugins --fields=name | grep -v '^name'); do echo -e "-----\n$i\n-----"; wp plugin install --skip-themes --skip-plugins --force "$i" --version=$(wp plugin list --skip-themes --skip-plugins --name="$i" --fields=version | grep -v '^version'); done
# forcedly reinstall themes
for i in $(wp theme list --skip-themes --skip-plugins --fields=name | grep -v '^name'); do echo -e "-----\n$i\n-----"; wp theme install --skip-themes --skip-plugins --force "$i" --version=$(wp theme list --skip-themes --skip-plugins --name="$i" --fields=version | grep -v '^version'); done
# check
wp core verify-checksums
# find nasty include/require on wp-config.php and index.php
echo -e "\nif you see any file other than 'wp-settings.php' and 'wp-blog-header.php' in the lines below, check your wp-config.php and index.php files for malware code injection:\n"
grep --color "include\|require" wp-config.php index.php
echo -e "\nAll done!"

killme() {
    [[ "$0" == "search-replace-ssl.bash" ]] && echo -n "Done! Self destroying... " && sleep 1 && rm -fv "$0" || echo "It's all done. Do not forget to remove this script.";
}
trap killme EXIT
