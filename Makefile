.PHONY: up down restart logs build ps

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

build:
	docker compose up -d --build

logs:
	docker compose logs -f

ps:
	docker compose ps

shell:
	docker compose exec app sh
