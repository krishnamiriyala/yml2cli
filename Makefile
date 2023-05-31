.PHONY: all clean test reinstall

PROJECT=yml2cli

version:
	TZ=UTC git --no-pager show --quiet --abbrev=12 --date='format-local:%Y%m%d%H%M%S' --format="%cd" > VERSION
	sed -i "s/{{VERSION_PLACEHOLDER}}/v0.0.0-alpha-`cat VERSION`/g" setup.py

build: lint
	python3 -m build

reinstall: uninstall clean install

install_tools:
	python3 -m pip install --upgrade pip
	pip3 install build pycodestyle pyflakes pylint twine
	pip3 install -r requirements.txt

install: clean build
	sudo pip3 install dist/*.whl

uninstall:
	sudo pip3 uninstall -y dist/*.whl

addlicense:
	docker run -it -v ${PWD}:/src ghcr.io/google/addlicense -c "Krishna Miriyala<krishnambm@gmail.com>" -l mit **/*.py

lint:
	pyflakes ${PROJECT}/*.py
	pycodestyle ${PROJECT}/*.py --ignore=E501
	pylint ${PROJECT}/*.py -d C0116,C0114,W0703
	yamllint -s */*.yml

lint_fix:
	autopep8 -i ${PROJECT}/*.py

clean:
	rm -rf VERSION ./dist ./*egg-info*

publish: clean build install
	twine upload dist/*
