URL_ROOT="http://pi.local:4701/wp-login.php"
OUT_DIR=docs

SAN_STYLESHEET_NAME=stylesheet.css

all: clean scrape-processed

scrape-processed: scrape-raw sanitize-output

scrape-raw:
	wget --execute="robots = off" --mirror --convert-links --no-parent -r -np -nH -k -P $(OUT_DIR) $(URL_ROOT)

sanitize-output:
	cd $(OUT_DIR); \
		rm wp-login.php*; \
		mv wp-admin/load-styles.php* wp-admin/$(SAN_STYLESHEET_NAME); \
		sed -i "s/load-styles.php?[^']*/$(SAN_STYLESHEET_NAME)/" index.html; \
		sed -i '/<p id="nav">/{N;N;d;}' index.html; \
		sed -i "/<\/h1>/r ../static/login-error.html" index.html; \
		sed -i "/<\/body>/r ../static/script.html" index.html; \
		sed -i 's/action="wp-login.php"/action="javascript:void(0);"/' index.html; \
		sed -i '/name="redirect_to"/d' index.html; \
		rename "s/\?ver=[0-9]*//" wp-admin/images/*; \
		sed -i "s/?ver=[0-9]*//g" "wp-admin/$(SAN_STYLESHEET_NAME)"

clean:
	rm -rf $(OUT_DIR)
