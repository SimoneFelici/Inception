.PHONY: up down restart logs build ps

up:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

restart:
	docker compose -f srcs/docker-compose.yml restart

build:
	docker compose -f srcs/docker-compose.yml up -d --build

logs:
	docker compose -f srcs/docker-compose.yml logs -f

ps:
	docker compose -f srcs/docker-compose.yml ps

shell:
	docker compose -f srcs/docker-compose.yml exec app sh
