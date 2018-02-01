VERSION=latest

build:
	docker build -t meuhmeuhconcept/mariadb:$(VERSION) .
