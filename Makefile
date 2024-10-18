name = inceptio
all:
	@printf "Launch configuration ${name}...\n"
	@echo "\n${YELLOW}Generating certificates...${DEF_COLOR}"
	@{ cd srcs/requirements/nginx/tools; \
		if [ ! -f afantini.42.fr.key ] || [ ! -f afantini.42.fr.pem ]; then \
			openssl req -newkey rsa:2048 -nodes -keyout afantini.42.fr.key -x509 -days 365 -out afantini.42.fr.pem \
			-subj "/C=IT/ST=Tuscany/L=Florence/O=42/OU=CS/CN=afantini/emailAddress=@student.42firenze.it"; \
		else \
			echo "${RED}Certificates already exist!${DEF_COLOR}"; \
		fi; }
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d

build:
	@printf "Building configuration ${name}...\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@printf "Stopping configuration ${name}...\n"
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env down

re: down
	@printf "Rebuild configuration ${name}...\n"
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf ~/data/mariadb/*

fclean:
	@printf "Total clean of all configurations docker\n"
	@docker stop $$(docker ps -qa)
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf ~/data/mariadb/*
	@{ cd srcs/requirements/nginx/tools; \
		sudo rm afantini.42.fr.*; \
		echo "Certificates have been deleted!"; }

.PHONY: all build down re clean fclean

.SILENT:
