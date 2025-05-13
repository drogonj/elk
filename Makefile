all: up

up:
	docker compose up --build

down d:
	docker compose down

cv:
	docker volume prune -af

ci:
	docker image prune -af

cn:
	docker network prune -f

clean c: down ci cv cn
