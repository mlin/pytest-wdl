repo = EliLillyCo/LRL_cromwell_test_runner
package = pytest_cromwell
version = 0.1.1
tests = tests

BUILD = rm -Rf dist/* && python setup.py bdist_wheel && pip install --upgrade dist/*.whl $(installargs)
INSTALL_EXTRAS = pip install .[all]
TEST = pytest $(pytestops) $(tests)

all:
	$(BUILD)
	$(INSTALL_EXTRAS)
	$(TEST)

install:
	$(BUILD)

test:
	$(TEST)

lint:
	flake8 $(package)

reformat:
	black $(package)
	black $(tests)

clean:
	rm -Rf __pycache__
	rm -Rf **/__pycache__/*
	rm -Rf **/*.c
	rm -Rf **/*.so
	rm -Rf **/*.pyc
	rm -Rf dist
	rm -Rf build
	rm -Rf $(package).egg-info

docker:
	# build
	docker build -f Dockerfile -t $(repo):$(version) .
	# add alternate tags
	docker tag $(repo):$(version) $(repo):latest
	# push to Docker Hub
	docker login -u jdidion && \
	docker push $(repo)
release:

	$(clean)
	# tag
	git tag $(version)
	# build
	$(BUILD)
	$(TEST)
	python setup.py sdist bdist_wheel
	# release
	python setup.py sdist upload -r omics-pypi
	git push origin --tags
	$(github_release)
	#$(docker)

github_release:
	curl -v -i -X POST \
		-H "Content-Type:application/json" \
		-H "Authorization: token $(token)" \
		https://api.github.com/repos/$(repo)/releases \
		-d '{"tag_name":"$(version)","target_commitish": "master","name": "$(version)","body": "$(desc)","draft": false,"prerelease": false}'