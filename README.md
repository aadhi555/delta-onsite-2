To test.. ensure that: 
1) In nginx.conf file.. comment out: "server backend4:5000;"
2) In docker-compose.yaml comment out: "backend4:" and "build: ./backend4"

and then run test.sh
When it waits for you to press enter:
1) Remove the comments from nginx.conf and docker-compose.yaml
2) Reload nginx in another terminal using:
    docker compose up -d --build backend4 && docker compose exec nginx nginx -s reload

and then press enter
