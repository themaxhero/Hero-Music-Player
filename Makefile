dev:
	npx elm-live \
	-p 8000 \
	-H -v \
	--start-page=./dist/index.html \
	--open -- --debug ./src/Main.elm \
	--output=./dist/main.js